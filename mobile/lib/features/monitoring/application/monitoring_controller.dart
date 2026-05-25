import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/debug_logger.dart';
import '../../../core/detection_constants.dart';
import '../data/camera_frame_snapshot.dart';
import '../data/yolo_tflite_detector.dart';
import 'drowning_alarm.dart';

/// Owns camera preview, periodic inference, drowning UI state, and the
/// audible alarm that fires after repeated drowning detections.
class MonitoringController extends ChangeNotifier {
  MonitoringController({DrowningAlarm? alarm})
      : _detector = YoloTfliteDetector(),
        _alarm = alarm ?? DrowningAlarm();

  final YoloTfliteDetector _detector;
  final DrowningAlarm _alarm;

  CameraController? _camera;
  Timer? _sampleTimer;
  bool _inferBusy = false;
  bool _disposed = false;

  /// Set right before sampling; the camera stream callback fulfills it with a
  /// snapshot built from the *next* preview frame and clears the field. This
  /// avoids holding plugin-owned [CameraImage] buffers between callbacks
  /// (which can be invalidated by the platform) and skips the per-frame
  /// allocation cost when we are not actively sampling.
  Completer<Map<String, Object?>>? _frameRequest;

  String? _errorMessage;
  bool _initializing = true;
  bool _drowningAlert = false;
  bool _alarmActive = false;
  int _drowningStreak = 0;
  DateTime? _lastInferenceAt;
  DateTime? _lastAlarmAt;

  String? get errorMessage => _errorMessage;
  bool get initializing => _initializing;
  bool get drowningAlert => _drowningAlert;
  bool get alarmActive => _alarmActive;
  DateTime? get lastInferenceAt => _lastInferenceAt;
  CameraController? get camera => _camera;

  Future<void> start() async {
    _errorMessage = null;
    _initializing = true;
    notifyListeners();

    final modelError = await _detector.load();
    if (modelError != null) {
      _errorMessage = modelError;
      _initializing = false;
      notifyListeners();
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _errorMessage = 'No cameras available on this device.';
        _initializing = false;
        notifyListeners();
        return;
      }

      // Get all back-facing cameras
      final backCameras = cameras
          .where((c) => c.lensDirection == CameraLensDirection.back)
          .toList();

      if (backCameras.isEmpty) {
        _errorMessage = 'No back camera available on this device.';
        _initializing = false;
        notifyListeners();
        return;
      }

      // Try to find the ultra-wide (0.5x) lens by name/ID heuristics
      final selectedCamera = _selectUltraWideOrFallback(backCameras);

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium, // 720x480 - smaller frames for faster inference
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      // If ultra-wide is available, set zoom to minimum (0.5x or similar)
      try {
        final minZoom = await controller.getMinZoomLevel();
        if (minZoom < 1.0) {
          await controller.setZoomLevel(minZoom);
          DebugLogger.event('Using ultra-wide lens at ${minZoom}x zoom');
        }
      } catch (e) {
        DebugLogger.error('Could not set zoom level', e);
      }

      await controller.startImageStream((image) {
        final waiter = _frameRequest;
        if (waiter == null || waiter.isCompleted) {
          return;
        }
        _frameRequest = null;
        try {
          final snap = buildCameraFrameSnapshot(image, selectedCamera);
          waiter.complete(snap);
        } catch (e, st) {
          waiter.completeError(e, st);
        }
      });

      _camera = controller;
      _scheduleNextInference(delay: DetectionConstants.firstSampleDelay);
    } catch (e, st) {
      DebugLogger.error('Camera init', e, st);
      _errorMessage = 'Could not start the camera. Try again.';
    }

    _initializing = false;
    notifyListeners();
  }

  /// Selects an ultra-wide camera by heuristics (name/id patterns) to avoid
  /// the overhead of initializing each camera just to check zoom levels.
  /// Falls back to the first back camera if no ultra-wide is detected.
  CameraDescription _selectUltraWideOrFallback(
    List<CameraDescription> backCameras,
  ) {
    if (backCameras.length == 1) {
      return backCameras.first;
    }

    // Common patterns for ultra-wide camera names/identifiers
    const ultraWidePatterns = ['ultra', 'wide', '0.5', '0.6'];
    
    // First try to find by name pattern
    for (final cam in backCameras) {
      final nameLower = cam.name.toLowerCase();
      for (final pattern in ultraWidePatterns) {
        if (nameLower.contains(pattern)) {
          DebugLogger.event('Selected ultra-wide by name: ${cam.name}');
          return cam;
        }
      }
    }

    // On many Android devices, the ultra-wide is often the camera with
    // a higher ID number (e.g., camera "2" vs main camera "0")
    // We'll use the last back camera in the list as a heuristic
    if (backCameras.length >= 2) {
      // Sort by camera name (often numeric IDs) and pick the highest
      final sorted = List<CameraDescription>.from(backCameras)
        ..sort((a, b) => a.name.compareTo(b.name));
      
      // The ultra-wide is often not the main camera (index 0)
      // Try the last one first, as it's often the ultra-wide
      final candidate = sorted.last;
      DebugLogger.event('Using camera by heuristic (last in list): ${candidate.name}');
      return candidate;
    }

    DebugLogger.event('No ultra-wide detected, using default back camera');
    return backCameras.first;
  }

  /// Next inference is scheduled only **after** the previous run completes
  /// (plus [DetectionConstants.sampleInterval]), so work never piles up.
  void _scheduleNextInference({required Duration delay}) {
    if (_disposed) return;
    _sampleTimer?.cancel();
    _sampleTimer = Timer(delay, () {
      unawaited(_runInferenceCycle());
    });
  }

  Future<void> _runInferenceCycle() async {
    if (_disposed) return;

    if (_inferBusy) {
      _scheduleNextInference(delay: DetectionConstants.sampleInterval);
      return;
    }

    final cam = _camera;
    if (cam == null || !cam.value.isInitialized) {
      _scheduleNextInference(delay: DetectionConstants.sampleInterval);
      return;
    }

    _inferBusy = true;
    try {
      final completer = Completer<Map<String, Object?>>();
      _frameRequest = completer;
      final snapshot = await completer.future
          .timeout(DetectionConstants.frameWaitTimeout);
      if (_disposed) return;

      final outcome = await _detector.inferFrameAsync(snapshot);
      if (_disposed) return;
      _lastInferenceAt = DateTime.now();

      if (outcome.drowningAlert) {
        _drowningStreak += 1;
        DebugLogger.streak(_drowningStreak, DetectionConstants.consecutiveDrowningTriggers);
        _showDrowningAlert();
        if (_drowningStreak >= DetectionConstants.consecutiveDrowningTriggers) {
          _maybeFireAlarm();
        }
      } else {
        if (_drowningStreak > 0) {
          DebugLogger.event('Drowning streak reset (was $_drowningStreak)');
        }
        _drowningStreak = 0;
      }
    } on TimeoutException {
      DebugLogger.error('Inference cycle', 'No frame within timeout');
    } catch (e, st) {
      DebugLogger.error('Inference cycle', e, st);
    } finally {
      _frameRequest = null;
      _inferBusy = false;
      if (!_disposed) {
        notifyListeners();
        _scheduleNextInference(delay: DetectionConstants.sampleInterval);
      }
    }
  }

  void _showDrowningAlert() {
    if (_disposed) return;
    _drowningAlert = true;
    notifyListeners();
    HapticFeedback.heavyImpact();
    Future<void>.delayed(DetectionConstants.alertHold, () {
      if (_disposed) return;
      _drowningAlert = false;
      notifyListeners();
    });
  }

  void _maybeFireAlarm() {
    if (_disposed || _alarmActive) return;
    final now = DateTime.now();
    final last = _lastAlarmAt;
    if (last != null &&
        now.difference(last) < DetectionConstants.alarmCooldown) {
      DebugLogger.alarm('Skipped (cooldown active)');
      return;
    }
    _alarmActive = true;
    _lastAlarmAt = now;
    notifyListeners();
    DebugLogger.alarm('TRIGGERED - ${DetectionConstants.alarmDuration.inSeconds}s');
    unawaited(_alarm.trigger(DetectionConstants.alarmDuration));
    Future<void>.delayed(DetectionConstants.alarmDuration, () {
      if (_disposed) return;
      _alarmActive = false;
      DebugLogger.alarm('Stopped');
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _sampleTimer?.cancel();
    _sampleTimer = null;
    final pending = _frameRequest;
    _frameRequest = null;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(StateError('MonitoringController disposed'));
    }
    final cam = _camera;
    _camera = null;
    _detector.close();
    unawaited(_alarm.dispose());
    if (cam != null) {
      unawaited(_disposeCamera(cam));
    }
    super.dispose();
  }

  Future<void> _disposeCamera(CameraController cam) async {
    try {
      if (cam.value.isStreamingImages) {
        await cam.stopImageStream();
      }
    } catch (e) {
      DebugLogger.error('stopImageStream', e);
    }
    await cam.dispose();
  }
}
