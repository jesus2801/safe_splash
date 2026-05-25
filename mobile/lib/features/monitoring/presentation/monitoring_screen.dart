import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/detection_constants.dart';
import '../application/monitoring_controller.dart';
import 'widgets/drowning_alert_banner.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  late final MonitoringController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MonitoringController();
    _controller.addListener(_onChanged);
    unawaited(_controller.start());
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        foregroundColor: Colors.white,
        title: const Text('Monitoring'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBody(scheme),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: DrowningAlertBanner(
                  visible: _controller.drowningAlert || _controller.alarmActive,
                ),
              ),
            ),
          ),
          if (_controller.alarmActive)
            Positioned(
              left: 12,
              right: 12,
              top: kToolbarHeight + 56,
              child: SafeArea(
                top: false,
                child: _AlarmRibbon(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme scheme) {
    if (_controller.errorMessage != null) {
      return _ErrorPane(
        message: _controller.errorMessage!,
        onBack: () => Navigator.of(context).maybePop(),
      );
    }

    if (_controller.initializing) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mist),
      );
    }

    final cam = _controller.camera;
    if (cam == null || !cam.value.isInitialized) {
      return _ErrorPane(
        message: 'Camera is not ready.',
        onBack: () => Navigator.of(context).maybePop(),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview fills the screen (cropping if needed to avoid black bars)
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: cam.value.previewSize?.height ?? 1280,
              height: cam.value.previewSize?.width ?? 720,
              child: CameraPreview(cam),
            ),
          ),
        ),
        // Recording info bar at bottom
        Positioned(
          left: 12,
          right: 12,
          bottom: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: scheme.error, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recording · ~${DetectionConstants.sampleInterval.inSeconds}s between inferences',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_controller.lastInferenceAt != null)
                    Text(
                      _formatTime(_controller.lastInferenceAt!),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _AlarmRibbon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.red.shade700.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Alarm sounding · repeated drowning detections',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.foam,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: onBack,
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
