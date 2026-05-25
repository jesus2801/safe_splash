/// Contract between your exported YOLO `.tflite` and this app.
///
/// When you copy a model from another repo, verify:
/// - [assetPath] matches [pubspec.yaml] `flutter.assets`.
/// - [inputSize] matches the model's letterboxed square side (Ultralytics often 640).
/// - Class indices **must match training** (`classLabels` order = model output order).
/// - Output layout: see [YoloOutputParser] — default expects one float tensor shaped
///   `[1, num_boxes, 4 + num_classes]` **or** `[1, 4 + num_classes, num_boxes]` (auto-detected).
/// - If scores cluster near 0.5 with [useSigmoidOnClassScores] true, try **false** (many
///   Ultralytics TFLite exports already apply sigmoid / output probabilities).
abstract final class ModelConfig {
  static const String assetPath = 'assets/models/model.tflite';

  /// Square letterbox side length (must match model input after NHWC layout).
  static const int inputSize = 640;

  static const int numClasses = 3;

  /// Training label order: **0 = drowning**, 1 = out of water, 2 = swimming.
  static const int drowningClassIndex = 0;

  static const int outOfWaterClassIndex = 1;

  static const int swimmingClassIndex = 2;

  static const List<String> classLabels = <String>[
    'drowning',
    'out of water',
    'swimming',
  ];

  /// Multiply RGB uint8 by this after letterbox (typical: `1/255`).
  static const double normalizeScale = 1.0 / 255.0;

  /// Many Ultralytics `.tflite` exports already emit class probabilities in `[0,1]`.
  /// If raw logits need squashing, set to `true`.
  static const bool useSigmoidOnClassScores = false;
}
