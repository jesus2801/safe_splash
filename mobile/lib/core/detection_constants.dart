/// Runtime tuning for sampling and drowning gate.
abstract final class DetectionConstants {
  /// Minimum time **after the previous inference finished** before the next one
  /// runs (backpressure: never stacks work while the model is still running).
  static const Duration sampleInterval = Duration(seconds: 2);

  /// Short delay after the preview stream starts before the first inference.
  static const Duration firstSampleDelay = Duration(milliseconds: 600);

  /// Minimum class score for a **drowning** box to trigger the strong alert UI.
  /// Lowered from 0.3 to catch more potential drowning events.
  static const double drowningScoreThreshold = 0.2;

  /// Minimum score for **swimming** to show the subtle hint (suppressed if drowning fires).
  static const double swimmingHintThreshold = 0.25;

  /// How long the drowning alert stays visible after a trigger.
  static const Duration alertHold = Duration(seconds: 2);

  /// Pre-NMS: drop low-confidence anchors before NMS (reduces thousands of junk boxes).
  /// Keep this lower than drowningScoreThreshold/swimmingHintThreshold so valid
  /// detections aren't discarded before NMS can rank them.
  static const double preNmsScoreThreshold = 0.15;

  static const double nmsIouThreshold = 0.5;

  /// Number of consecutive drowning detections required before the audible
  /// alarm fires. Avoids reacting to a single noisy frame.
  static const int consecutiveDrowningTriggers = 2;

  /// How long the audible alarm plays once triggered.
  static const Duration alarmDuration = Duration(seconds: 6);

  /// Minimum gap between two consecutive alarm activations so a sustained
  /// detection does not chain alarms back-to-back.
  static const Duration alarmCooldown = Duration(seconds: 4);

  /// Hard timeout for awaiting a fresh camera frame inside an inference cycle.
  static const Duration frameWaitTimeout = Duration(seconds: 2);
}

