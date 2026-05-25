import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/debug_logger.dart';
import '../../../core/detection_constants.dart';
import '../../../core/model_config.dart';
import 'frame_inference_outcome.dart';

/// One decoded candidate before NMS.
class YoloCandidate {
  YoloCandidate({
    required this.cx,
    required this.cy,
    required this.w,
    required this.h,
    required this.classId,
    required this.score,
  });

  final double cx;
  final double cy;
  final double w;
  final double h;
  final int classId;
  final double score;
}

/// Parses a single float32 YOLO output tensor into boxes, then NMS.
///
/// Supported layouts (batch ignored, `B` = 1):
/// - `[B, num_boxes, 4 + num_classes]`
/// - `[B, 4 + num_classes, num_boxes]`
///
/// Coordinates are assumed **normalized** `cx, cy, w, h` in `[0, 1]` as in many
/// Ultralytics TFLite exports. If your export uses grid-relative logits, adjust
/// decoding here after inspecting `interpreter.getOutputTensor(0).shape`.
class YoloOutputParser {
  static double _sigmoid(double x) => 1.0 / (1.0 + math.exp(-x));

  static List<YoloCandidate> parse(Float32List flat, List<int> shape) {
    if (shape.isEmpty) return const [];

    // Flatten batch: keep trailing dims only.
    List<int> s = shape;
    if (s.first == 1 && s.length > 1) {
      s = s.sublist(1);
    }
    if (s.length != 2) {
      // Some exports are already `[num_boxes, attrs]` without batch.
      if (s.length == 3 && s[0] == 1) {
        s = s.sublist(1);
      }
    }
    if (s.length != 2) {
      return const [];
    }

    final d1 = s[0];
    final d2 = s[1];
    final expected = 4 + ModelConfig.numClasses;

    late final int numBoxes;
    late final int features;
    late final bool transposed;

    if (d2 == expected && d1 >= expected) {
      numBoxes = d1;
      features = d2;
      transposed = false;
    } else if (d1 == expected && d2 >= expected) {
      numBoxes = d2;
      features = d1;
      transposed = true;
    } else {
      // Heuristic: the larger axis is usually anchor/box dimension.
      if (d1 > d2) {
        numBoxes = d1;
        features = d2;
        transposed = false;
      } else {
        numBoxes = d2;
        features = d1;
        transposed = true;
      }
    }

    if (features < 4 + ModelConfig.numClasses) {
      return const [];
    }

    double at(int box, int feat) {
      if (!transposed) {
        return flat[box * features + feat];
      }
      return flat[feat * numBoxes + box];
    }

    final candidates = <YoloCandidate>[];
    for (var b = 0; b < numBoxes; b++) {
      final cx = at(b, 0).clamp(0.0, 1.0);
      final cy = at(b, 1).clamp(0.0, 1.0);
      final w = at(b, 2).clamp(0.0, 1.0);
      final h = at(b, 3).clamp(0.0, 1.0);

      var bestId = 0;
      var bestScore = double.negativeInfinity;
      for (var c = 0; c < ModelConfig.numClasses; c++) {
        var s = at(b, 4 + c);
        if (ModelConfig.useSigmoidOnClassScores) {
          s = _sigmoid(s);
        }
        if (s > bestScore) {
          bestScore = s;
          bestId = c;
        }
      }

      if (bestScore < DetectionConstants.preNmsScoreThreshold) continue;

      candidates.add(
        YoloCandidate(
          cx: cx,
          cy: cy,
          w: w,
          h: h,
          classId: bestId,
          score: bestScore,
        ),
      );
    }

    final nms = _nms(candidates, DetectionConstants.nmsIouThreshold);
    return nms;
  }

  /// Best winning score seen after NMS for each class id present in [boxes].
  static Map<int, double> bestScoresByClass(List<YoloCandidate> boxes) {
    final m = <int, double>{};
    for (final b in boxes) {
      final prev = m[b.classId];
      if (prev == null || b.score > prev) {
        m[b.classId] = b.score;
      }
    }
    return m;
  }

  /// Strong drowning alert vs subtle swimming hint (swimming suppressed if drowning).
  static FrameInferenceOutcome evaluateOutcomes(List<YoloCandidate> boxes) {
    final drowning = boxes.any(
      (e) =>
          e.classId == ModelConfig.drowningClassIndex &&
          e.score > DetectionConstants.drowningScoreThreshold,
    );
    final swimmingRaw = boxes.any(
      (e) =>
          e.classId == ModelConfig.swimmingClassIndex &&
          e.score > DetectionConstants.swimmingHintThreshold,
    );
    final outOfWaterRaw = boxes.any(
      (e) =>
          e.classId == ModelConfig.outOfWaterClassIndex &&
          e.score > DetectionConstants.swimmingHintThreshold,
    );
    final swimmingHint = swimmingRaw && !drowning;
    final outOfWaterHint = outOfWaterRaw && !drowning && !swimmingHint;
    return FrameInferenceOutcome(
      drowningAlert: drowning,
      swimmingHint: swimmingHint,
      outOfWaterHint: outOfWaterHint,
      boxCount: boxes.length,
    );
  }

  static bool hasHighConfidenceDrowning(List<YoloCandidate> boxes) {
    return evaluateOutcomes(boxes).drowningAlert;
  }

  /// Compact per-frame log (isolate-safe).
  static void debugPrintInferenceSnapshot({
    required int frameW,
    required int frameH,
    required int frameRot,
    required List<int> outputShape,
    required Float32List floats,
    required List<YoloCandidate> postNms,
    required FrameInferenceOutcome outcome,
  }) {
    final best = bestScoresByClass(postNms);
    final bestDrowning = best[ModelConfig.drowningClassIndex] ?? 0.0;
    final bestSwimming = best[ModelConfig.swimmingClassIndex] ?? 0.0;

    DebugLogger.inferenceSummary(
      frameW: frameW,
      frameH: frameH,
      boxCount: postNms.length,
      bestDrowning: bestDrowning,
      bestSwimming: bestSwimming,
      drowningAlert: outcome.drowningAlert,
      swimmingHint: outcome.swimmingHint,
    );

    // Only log box details when something was detected
    if (postNms.isNotEmpty) {
      const maxBoxes = 3;
      for (var i = 0; i < postNms.length && i < maxBoxes; i++) {
        final b = postNms[i];
        final label = (b.classId >= 0 && b.classId < ModelConfig.classLabels.length)
            ? ModelConfig.classLabels[b.classId]
            : '?';
        DebugLogger.detectionBox(
          index: i,
          label: label,
          classId: b.classId,
          score: b.score,
          cx: b.cx,
          cy: b.cy,
          w: b.w,
          h: b.h,
        );
      }
    }
  }

  static List<YoloCandidate> _nms(List<YoloCandidate> input, double iouThresh) {
    final sorted = [...input]..sort((a, b) => b.score.compareTo(a.score));
    final out = <YoloCandidate>[];
    while (sorted.isNotEmpty) {
      final best = sorted.removeAt(0);
      out.add(best);
      sorted.removeWhere((o) => _iou(best, o) >= iouThresh);
    }
    return out;
  }

  static double _iou(YoloCandidate a, YoloCandidate b) {
    final ax1 = a.cx - a.w / 2;
    final ay1 = a.cy - a.h / 2;
    final ax2 = a.cx + a.w / 2;
    final ay2 = a.cy + a.h / 2;
    final bx1 = b.cx - b.w / 2;
    final by1 = b.cy - b.h / 2;
    final bx2 = b.cx + b.w / 2;
    final by2 = b.cy + b.h / 2;

    final ix1 = math.max(ax1, bx1);
    final iy1 = math.max(ay1, by1);
    final ix2 = math.min(ax2, bx2);
    final iy2 = math.min(ay2, by2);
    final iw = math.max(0.0, ix2 - ix1);
    final ih = math.max(0.0, iy2 - iy1);
    final inter = iw * ih;
    final ua = a.w * a.h + b.w * b.h - inter;
    if (ua <= 0) return 0;
    return inter / ua;
  }
}
