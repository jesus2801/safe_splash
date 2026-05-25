import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../core/debug_logger.dart';
import '../../../core/model_config.dart';
import 'camera_image_utils.dart';
import 'frame_inference_outcome.dart';
import 'yolo_output_parser.dart';

/// Top-level entry for [Isolate.spawn] — keeps YUV decode, letterbox, and TFLite
/// off the UI isolate so CameraX / Flutter stay responsive.
@pragma('vm:entry-point')
void drowningInferenceIsolateMain(SendPort handshake) {
  final port = ReceivePort();
  handshake.send(port.sendPort);

  Interpreter? interpreter;
  var inputIsNchw = false;
  var inputH = ModelConfig.inputSize;
  var inputW = ModelConfig.inputSize;

  port.listen((Object? message) {
    if (message is! List<Object?>) return;
    if (message.isEmpty) return;
    final cmd = message[0];
    if (cmd is! String) return;

    switch (cmd) {
      case 'init':
        final modelBytes = message[1] as Uint8List;
        final reply = message[2] as SendPort;
        try {
          final i = Interpreter.fromBuffer(modelBytes);
          final shape = i.getInputTensor(0).shape;
          if (shape.length == 4) {
            if (shape[3] == 3) {
              inputIsNchw = false;
              inputH = shape[1];
              inputW = shape[2];
            } else if (shape[1] == 3) {
              inputIsNchw = true;
              inputH = shape[2];
              inputW = shape[3];
            } else {
              i.close();
              reply.send(<Object?>['initErr', 'Unexpected input layout: $shape']);
              return;
            }
          } else {
            i.close();
            reply.send(<Object?>['initErr', 'Unexpected input rank: ${shape.length}']);
            return;
          }
          i.allocateTensors();
          interpreter = i;
          reply.send(<Object?>['initOk', null]);
        } catch (e, st) {
          DebugLogger.error('Isolate init', e, st);
          reply.send(<Object?>['initErr', e.toString()]);
        }
      case 'infer':
        final reply = message[1] as SendPort;
        final snap = message[2] as Map<String, Object?>;
        final interp = interpreter;
        if (interp == null) {
          reply.send(<Object>[false, false, false, 0]);
          return;
        }
        try {
          final out = _runFrameInference(
            interp,
            inputIsNchw: inputIsNchw,
            inputH: inputH,
            inputW: inputW,
            snap: snap,
          );
          reply.send(out);
        } catch (e, st) {
          DebugLogger.error('Inference run', e, st);
          reply.send(<Object>[false, false, false, 0]);
        }
      case 'shutdown':
        interpreter?.close();
        interpreter = null;
        port.close();
      default:
        break;
    }
  });
}

List<Object> _runFrameInference(
  Interpreter interpreter, {
  required bool inputIsNchw,
  required int inputH,
  required int inputW,
  required Map<String, Object?> snap,
}) {
  var rgb = yuv420ToRgbFromSnapshot(snap);
  if (rgb == null) {
    DebugLogger.error('YUV decode', 'Failed for frame ${snap['w']}x${snap['h']}');
    return <Object>[false, false, false, 0];
  }

  final rot = snap['rot']! as int;
  if (rot != 0) {
    rgb = img.copyRotate(rgb, angle: rot, interpolation: img.Interpolation.nearest);
  }

  final nhwc = letterboxToFloatNhwc(
    rgb,
    targetSize: inputH,
    normalizeScale: ModelConfig.normalizeScale,
  );

  final Float32List inputBytes;
  if (inputIsNchw) {
    inputBytes = nhwcToNchw(nhwc, inputH, inputW);
  } else {
    inputBytes = nhwc;
  }

  final inTensor = interpreter.getInputTensor(0);
  inTensor.data = inputBytes.buffer.asUint8List(
    inputBytes.offsetInBytes,
    inputBytes.lengthInBytes,
  );
  interpreter.invoke();

  final outTensor = interpreter.getOutputTensor(0);
  final outBytes = outTensor.data;
  final floatCount = outBytes.lengthInBytes ~/ 4;
  // Try to alias the tensor buffer as Float32List (host endianness, requires
  // 4-byte alignment). Falls back to a manual decode if alignment forbids it.
  Float32List floats;
  if (outBytes.offsetInBytes % 4 == 0) {
    floats = outBytes.buffer.asFloat32List(outBytes.offsetInBytes, floatCount);
  } else {
    floats = Float32List(floatCount);
    final bd = outBytes.buffer.asByteData(
      outBytes.offsetInBytes,
      outBytes.lengthInBytes,
    );
    for (var i = 0; i < floatCount; i++) {
      floats[i] = bd.getFloat32(i * 4, Endian.host);
    }
  }

  final parsed = YoloOutputParser.parse(floats, outTensor.shape);
  final outcome = YoloOutputParser.evaluateOutcomes(parsed);
  YoloOutputParser.debugPrintInferenceSnapshot(
    frameW: snap['w']! as int,
    frameH: snap['h']! as int,
    frameRot: snap['rot']! as int,
    outputShape: outTensor.shape,
    floats: floats,
    postNms: parsed,
    outcome: outcome,
  );
  return <Object>[
    outcome.drowningAlert,
    outcome.swimmingHint,
    outcome.outOfWaterHint,
    parsed.length,
  ];
}

/// Owns the background isolate that runs TFLite inference.
class DrowningInferenceIsolate {
  Isolate? _isolate;
  SendPort? _send;

  Future<String?> start(Uint8List modelBytes) async {
    final handshake = ReceivePort();
    _isolate = await Isolate.spawn(
      drowningInferenceIsolateMain,
      handshake.sendPort,
      debugName: 'drowning_inference',
    );

    final workerSend = await handshake.first as SendPort;
    handshake.close();
    _send = workerSend;

    final ack = ReceivePort();
    workerSend.send(<Object?>['init', modelBytes, ack.sendPort]);
    final response = await ack.first as List<Object?>;
    ack.close();

    final status = response[0] as String;
    if (status == 'initErr') {
      dispose();
      return response[1] as String? ?? 'Model init failed.';
    }
    return null;
  }

  Future<FrameInferenceOutcome> inferFrame(Map<String, Object?> snapshot) async {
    final send = _send;
    if (send == null) return FrameInferenceOutcome.none;

    final reply = ReceivePort();
    send.send(<Object?>['infer', reply.sendPort, snapshot]);
    final result = await reply.first;
    reply.close();
    if (result is List && result.length >= 4) {
      return FrameInferenceOutcome(
        drowningAlert: result[0] == true,
        swimmingHint: result[1] == true,
        outOfWaterHint: result[2] == true,
        boxCount: result[3] as int? ?? 0,
      );
    }
    return FrameInferenceOutcome.none;
  }

  void dispose() {
    try {
      _send?.send(<Object?>['shutdown']);
    } catch (_) {}
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _send = null;
  }
}
