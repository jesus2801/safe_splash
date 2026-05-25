import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/model_config.dart';
import 'drowning_inference_isolate.dart';
import 'frame_inference_outcome.dart';

/// Loads model bytes on the UI isolate and runs inference on a **worker isolate**
/// so decoding + [Interpreter.invoke] never block the main thread.
class YoloTfliteDetector {
  DrowningInferenceIsolate? _isolate;

  bool get isReady => _isolate != null;

  Future<String?> load() async {
    try {
      final data = await rootBundle.load(ModelConfig.assetPath);
      final modelBytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      final worker = DrowningInferenceIsolate();
      final err = await worker.start(modelBytes);
      if (err != null) {
        worker.dispose();
        return err;
      }
      _isolate = worker;
      return null;
    } on FlutterError catch (e) {
      return 'Missing model asset: ${ModelConfig.assetPath}\n$e';
    } catch (e) {
      return 'Failed to load model: $e';
    }
  }

  void close() {
    _isolate?.dispose();
    _isolate = null;
  }

  Future<FrameInferenceOutcome> inferFrameAsync(
    Map<String, Object?> snapshot,
  ) async {
    final iso = _isolate;
    if (iso == null) return FrameInferenceOutcome.none;
    return iso.inferFrame(snapshot);
  }
}
