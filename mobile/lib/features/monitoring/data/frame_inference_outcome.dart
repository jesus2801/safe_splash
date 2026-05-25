/// Per-frame classification flags from the worker isolate.
class FrameInferenceOutcome {
  const FrameInferenceOutcome({
    required this.drowningAlert,
    required this.swimmingHint,
    this.outOfWaterHint = false,
    this.boxCount = 0,
  });

  final bool drowningAlert;

  /// Subtle UI when swimming is confident and drowning is not firing this frame.
  final bool swimmingHint;
  
  /// When person is detected out of water
  final bool outOfWaterHint;
  
  /// Total number of detected boxes after NMS
  final int boxCount;

  static const FrameInferenceOutcome none = FrameInferenceOutcome(
    drowningAlert: false,
    swimmingHint: false,
    outOfWaterHint: false,
    boxCount: 0,
  );
}
