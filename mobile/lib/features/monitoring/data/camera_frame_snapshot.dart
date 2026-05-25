import 'dart:typed_data';

import 'package:camera/camera.dart';

import 'camera_image_utils.dart';

/// Sendable snapshot of a [CameraImage] for background-isolate inference.
///
/// Copies plane bytes so the isolate does not touch plugin-owned buffers.
Map<String, Object?> buildCameraFrameSnapshot(
  CameraImage image,
  CameraDescription cameraDescription,
) {
  final p0 = image.planes[0];
  final p1 = image.planes[1];
  final p2 = image.planes[2];
  return <String, Object?>{
    'w': image.width,
    'h': image.height,
    'rot': uprightRotationDegrees(cameraDescription),
    'y': Uint8List.fromList(p0.bytes),
    'yrs': p0.bytesPerRow,
    'u': Uint8List.fromList(p1.bytes),
    'urs': p1.bytesPerRow,
    'ups': p1.bytesPerPixel ?? 1,
    'v': Uint8List.fromList(p2.bytes),
    'vrs': p2.bytesPerRow,
    'vps': p2.bytesPerPixel ?? 1,
  };
}
