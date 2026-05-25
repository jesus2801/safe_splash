import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

/// Converts a [CameraImage] in YUV420 to an [img.Image] in RGB.
///
/// UV indexing can vary slightly by OEM; this matches common Android layouts.
img.Image? yuv420ToRgb(CameraImage image) {
  if (image.planes.length < 3) return null;
  final p1 = image.planes[1];
  final p2 = image.planes[2];
  return yuv420ToRgbFromPlanes(
    width: image.width,
    height: image.height,
    yPlane: image.planes[0].bytes,
    yRowStride: image.planes[0].bytesPerRow,
    uPlane: p1.bytes,
    uRowStride: p1.bytesPerRow,
    uPixelStride: p1.bytesPerPixel ?? 1,
    vPlane: p2.bytes,
    vRowStride: p2.bytesPerRow,
    vPixelStride: p2.bytesPerPixel ?? 1,
  );
}

/// YUV420 → RGB using explicit strides (works with [CameraImage] or copied bytes).
///
/// Writes directly into a packed `Uint8List` (RGB row-major) and wraps it in an
/// [img.Image]. This avoids the per-pixel virtual call overhead of
/// `setPixelRgb` and is significantly faster on real devices.
img.Image? yuv420ToRgbFromPlanes({
  required int width,
  required int height,
  required Uint8List yPlane,
  required int yRowStride,
  required Uint8List uPlane,
  required int uRowStride,
  required int uPixelStride,
  required Uint8List vPlane,
  required int vRowStride,
  required int vPixelStride,
}) {
  try {
    final rgb = Uint8List(width * height * 3);
    var dst = 0;
    for (var y = 0; y < height; y++) {
      final yRow = y * yRowStride;
      final uvRow = (y >> 1);
      final uRowBase = uvRow * uRowStride;
      final vRowBase = uvRow * vRowStride;
      for (var x = 0; x < width; x++) {
        final uvCol = x >> 1;
        final yp = yPlane[yRow + x];
        final up = uPlane[uRowBase + uvCol * uPixelStride];
        final vp = vPlane[vRowBase + uvCol * vPixelStride];

        final uOff = up - 128;
        final vOff = vp - 128;

        var r = yp + ((1437 * vOff) >> 10); // ~1.402
        var g = yp - ((352 * uOff + 731 * vOff) >> 10); // ~0.344, ~0.714
        var b = yp + ((1815 * uOff) >> 10); // ~1.772

        if (r < 0) {
          r = 0;
        } else if (r > 255) {
          r = 255;
        }
        if (g < 0) {
          g = 0;
        } else if (g > 255) {
          g = 255;
        }
        if (b < 0) {
          b = 0;
        } else if (b > 255) {
          b = 255;
        }

        rgb[dst++] = r;
        rgb[dst++] = g;
        rgb[dst++] = b;
      }
    }
    return img.Image.fromBytes(
      width: width,
      height: height,
      bytes: rgb.buffer,
      order: img.ChannelOrder.rgb,
    );
  } catch (_) {
    return null;
  }
}

/// Same as [yuv420ToRgbFromPlanes] but reads the map produced by [buildCameraFrameSnapshot].
img.Image? yuv420ToRgbFromSnapshot(Map<String, Object?> m) {
  final width = m['w']! as int;
  final height = m['h']! as int;
  return yuv420ToRgbFromPlanes(
    width: width,
    height: height,
    yPlane: m['y']! as Uint8List,
    yRowStride: m['yrs']! as int,
    uPlane: m['u']! as Uint8List,
    uRowStride: m['urs']! as int,
    uPixelStride: m['ups']! as int,
    vPlane: m['v']! as Uint8List,
    vRowStride: m['vrs']! as int,
    vPixelStride: m['vps']! as int,
  );
}

/// When the app is portrait-locked, map sensor orientation to a clockwise
/// [img.copyRotate] angle so the pool appears upright in the model input.
int uprightRotationDegrees(CameraDescription camera) {
  if (camera.lensDirection == CameraLensDirection.back) {
    return (camera.sensorOrientation + 360 - 90) % 360;
  }
  return (camera.sensorOrientation + 360 - 270) % 360;
}

Float32List letterboxToFloatNhwc(
  img.Image source, {
  required int targetSize,
  required double normalizeScale,
}) {
  final w = source.width;
  final h = source.height;
  final scale = math.min(targetSize / w, targetSize / h);
  final nw = (w * scale).round();
  final nh = (h * scale).round();
  
  // Use faster nearest-neighbor interpolation instead of default bilinear
  final resized = img.copyResize(
    source,
    width: nw,
    height: nh,
    interpolation: img.Interpolation.nearest,
  );
  
  // Pre-allocate output buffer and fill directly with letterbox padding
  final total = targetSize * targetSize * 3;
  final buf = Float32List(total);
  const padValue = 114.0 / 255.0; // Pre-normalized padding value
  buf.fillRange(0, total, padValue);
  
  // Calculate offsets for centering
  final dx = (targetSize - nw) ~/ 2;
  final dy = (targetSize - nh) ~/ 2;
  
  // Copy resized image directly to float buffer (skip intermediate canvas)
  final resizedBytes = resized.getBytes(order: img.ChannelOrder.rgb);
  for (var y = 0; y < nh; y++) {
    final srcRowStart = y * nw * 3;
    final dstRowStart = ((dy + y) * targetSize + dx) * 3;
    for (var x = 0; x < nw; x++) {
      final srcIdx = srcRowStart + x * 3;
      final dstIdx = dstRowStart + x * 3;
      buf[dstIdx] = resizedBytes[srcIdx] * normalizeScale;
      buf[dstIdx + 1] = resizedBytes[srcIdx + 1] * normalizeScale;
      buf[dstIdx + 2] = resizedBytes[srcIdx + 2] * normalizeScale;
    }
  }
  return buf;
}

/// If the model expects NCHW `[1, 3, H, W]`, reorder from [letterboxToFloatNhwc].
Float32List nhwcToNchw(Float32List nhwc, int h, int w) {
  final out = Float32List(3 * h * w);
  final plane = h * w;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final idx = (y * w + x) * 3;
      final r = nhwc[idx];
      final g = nhwc[idx + 1];
      final b = nhwc[idx + 2];
      final base = y * w + x;
      out[base] = r;
      out[plane + base] = g;
      out[2 * plane + base] = b;
    }
  }
  return out;
}
