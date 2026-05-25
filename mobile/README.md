# Splash — Safe Splash (app móvil)

Detección de ahogamiento en tiempo real con **YOLOv12** exportado a TFLite en el dispositivo.

Guías del monorepo: **[Instalacion.md](../Instalacion.md)** (instalación y despliegue) · **[Desarrollo.md](../Desarrollo.md)** (detalle técnico).

## Features

- Live camera monitoring with ML inference
- YOLO-based detection (drowning, swimming, out of water)
- Audio alarm on repeated drowning detections
- Optimized for real-time performance (background isolate processing)

## Running the App

### Android
```bash
flutter pub get
flutter run
```

### iOS (Mac Required)
See **[IOS_SETUP.md](IOS_SETUP.md)** for detailed instructions.

Quick version:
```bash
flutter pub get
cd ios && pod install && cd ..
flutter run
```

## Model

Place your trained YOLO TFLite model at `assets/models/model.tflite`.

The model should output 3 classes:
- 0: drowning
- 1: out of water  
- 2: swimming

## Requirements

- Flutter SDK 3.11+
- Android: minSdk 24, JDK 17
- iOS: 12.0+ (requires Mac with Xcode for building)
