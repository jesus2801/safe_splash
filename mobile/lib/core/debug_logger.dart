import 'package:flutter/foundation.dart';

/// Centralized debug logging for the drowning detection pipeline.
///
/// Controls verbosity and ensures logs are actionable for debugging.
abstract final class DebugLogger {
  static const String _tag = 'Splash';

  /// Log levels: 0=errors only, 1=important events, 2=all inference frames
  static const int _level = kDebugMode ? 1 : 0;

  /// Logs errors that need attention (always shown).
  static void error(String context, Object error, [StackTrace? st]) {
    debugPrint('[$_tag:ERROR] $context: $error');
    if (st != null && _level >= 2) {
      debugPrint(st.toString());
    }
  }

  /// Logs important state changes (alarm, detection events).
  static void event(String message) {
    if (_level >= 1) {
      debugPrint('[$_tag] $message');
    }
  }

  /// Logs per-frame inference results (only at verbose level).
  static void frame(String message) {
    if (_level >= 2) {
      debugPrint('[$_tag:frame] $message');
    }
  }

  /// Compact one-line inference summary - always shown in debug mode.
  /// Format: "INF 320x240 | 2 boxes | swim=0.49 drown=0.00 | hint=true"
  static void inferenceSummary({
    required int frameW,
    required int frameH,
    required int boxCount,
    required double bestDrowning,
    required double bestSwimming,
    required bool drowningAlert,
    required bool swimmingHint,
  }) {
    if (!kDebugMode) return;

    final status = drowningAlert
        ? 'DROWNING'
        : swimmingHint
            ? 'swimming'
            : 'clear';

    debugPrint(
      '[$_tag] ${frameW}x$frameH | '
      '${boxCount}box | '
      'd=${bestDrowning.toStringAsFixed(2)} s=${bestSwimming.toStringAsFixed(2)} | '
      '$status',
    );
  }

  /// Logs detection box details (only when there ARE detections).
  static void detectionBox({
    required int index,
    required String label,
    required int classId,
    required double score,
    required double cx,
    required double cy,
    required double w,
    required double h,
  }) {
    if (_level >= 1) {
      debugPrint(
        '[$_tag]   #$index $label($classId) '
        'score=${score.toStringAsFixed(3)} '
        'pos=(${cx.toStringAsFixed(2)},${cy.toStringAsFixed(2)}) '
        'size=(${w.toStringAsFixed(2)}x${h.toStringAsFixed(2)})',
      );
    }
  }

  /// Logs alarm state changes.
  static void alarm(String action) {
    debugPrint('[$_tag:ALARM] $action');
  }

  /// Logs drowning streak progression.
  static void streak(int count, int threshold) {
    if (_level >= 1) {
      debugPrint('[$_tag] Drowning streak: $count/$threshold');
    }
  }
}
