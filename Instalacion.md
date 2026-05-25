# Instalación — Safe Splash

Un **solo repositorio** con dos carpetas en la raíz:

| Carpeta | Propósito |
|---------|-----------|
| **`training/`** | Entrenar YOLOv12, evaluar e inferir en GPU |
| **`mobile/`** | App Flutter — detección en tiempo real (TFLite) |

```
<repo>/
├── training/          # Python, Ultralytics, datasets, runs/
├── mobile/            # Flutter (Safe Splash)
├── README.md
├── Instalacion.md     # este documento
└── Desarrollo.md
```

Más contexto del pipeline ML: **[training/README.md](training/README.md)**.

---

# Parte I — Entrenamiento (`training/`)

## 1. Qué hace esta carpeta

Detector **YOLOv12** para la piscina de Uninorte con tres clases:

| Índice | Clase |
|--------|--------|
| 0 | Drowning (ahogamiento) |
| 1 | Person out of water (fuera del agua) |
| 2 | Swimming (natación) |

Flujo: **entrenamiento en dataset público** → **fine-tune Uninorte** → **exportar TFLite** → copiar a `mobile/assets/models/` (Parte II).

## 2. Requisitos

| Recurso | Mínimo | Recomendado |
|---------|--------|-------------|
| GPU NVIDIA + CUDA | 6 GB VRAM | A100 40 GB (Colab Pro) |
| Python | 3.10+ | 3.12 |
| SO | Windows 10/11, Linux | — |
| Git | Sí | — |
| Datasets | `training/dataset/`, `training/uninorte_dataset/` (gitignored) | Ver READMEs en cada carpeta |

TensorRT es **opcional** (export `.engine` en GPU NVIDIA).

## 3. Instalación local (Windows / Linux)

```powershell
git clone <URL_DEL_REPOSITORIO> safe-splash
cd safe-splash/training

python -m venv .venv
.\.venv\Scripts\activate          # Windows PowerShell
# source .venv/bin/activate       # Linux / macOS

pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt
```

Comprobar GPU:

```python
import torch
print(torch.cuda.is_available(), torch.cuda.get_device_name(0))
```

> Todos los comandos Python de esta parte se ejecutan desde **`training/`**.

## 4. Instalación en Google Colab

1. **Runtime → GPU → A100** (Pro/Pro+).
2. Clonar el monorepo en Drive y entrar en `training/`:

```bash
%cd /content/drive/MyDrive
!git clone <URL_DEL_REPOSITORIO> safe-splash || echo "ya existe"
%cd safe-splash/training
!pip install -q -r requirements.txt
!nvidia-smi | head -n 20
```

Si no es A100, baja `--imgsz` y `--batch` (ver [training/README.md](training/README.md)).

## 5. Preparar datos y entrenar

Datasets dentro de `training/` (no versionados):

- `training/dataset/` — stage 1 (público)
- `training/uninorte_dataset/` — stage 2; ver `uninorte_dataset/README.md`

```bash
cd training   # si no estás ya ahí

python src/data_analysis.py --name public
python src/train.py
# → runs/detect/stage1_public/weights/best.pt

python src/data_analysis.py --data uninorte_dataset/data.yaml --name uninorte
python src/finetune.py --weights runs/detect/stage1_public/weights/best.pt
# → runs/detect/stage2_uninorte/weights/best.pt
```

## 6. Evaluación e inferencia de prueba

```bash
python src/model_evaluation.py \
    --weights runs/detect/stage2_uninorte/weights/best.pt \
    --data uninorte_dataset/data.yaml \
    --split test

python scripts/predict.py --source uninorte/data \
    --weights runs/detect/stage2_uninorte/weights/best.pt

python scripts/predict_video.py \
    --source uninorte/videos/drowning.mp4 \
    --weights runs/detect/stage2_uninorte/weights/best.pt \
    --drowning-threshold 5
```

## 7. Exportar modelo para la app (`mobile/`)

La app espera **`model.tflite`** a **640×640** (Parte II). Desde `training/`:

```bash
yolo export model=runs/detect/stage2_uninorte/weights/best.pt format=tflite imgsz=640
```

Copiar al monorepo (ruta relativa desde la raíz del repo):

```bash
# Desde training/ (ajusta la ruta del .tflite generado por Ultralytics)
cp runs/detect/stage2_uninorte/weights/best.tflite ../mobile/assets/models/model.tflite
```

```powershell
# Windows PowerShell (desde training/)
Copy-Item runs/detect/stage2_uninorte/weights/best.tflite ..\mobile\assets\models\model.tflite
```

Si cambian resolución, clases u orden de etiquetas, actualiza `mobile/lib/core/model_config.dart` (Parte II, §2.3).

## 8. Problemas frecuentes (entrenamiento)

| Síntoma | Qué hacer |
|---------|-----------|
| OOM | `--imgsz`, `--batch` explícito, `--cache disk` |
| AutoBatch en 16 y falla | `--batch 8` manual |
| Colab desconecta | `--resume`; guardar `runs/` en Drive |
| `dataset/` no encontrado | Rutas bajo `training/`; revisar `data.yaml` |

---

# Parte II — App móvil (`mobile/`)

> Misma clonación del monorepo; el trabajo Flutter se hace siempre dentro de **`mobile/`**.

---

## 1. Descripción general

**Safe Splash** detecta ahogamiento en tiempo real con la cámara del dispositivo. Inferencia **on-device** con YOLO en **TensorFlow Lite** (ahogamiento, natación, fuera del agua). Alarma sonora y háptica tras detecciones repetidas, **sin red**.

| Modo | Descripción |
|---|---|
| **Debug** | Hot reload, logs, firma debug Android |
| **Dispositivo** | USB, release o profile |
| **Distribución** | APK/AAB firmado o IPA vía Xcode |

### 1.1 Tecnologías

| Capa | Tecnología |
|---|---|
| UI | Flutter SDK **≥ 3.11**, Dart **^3.11.1** |
| Cámara | `camera` ^0.11 |
| ML | `tflite_flutter` ^0.11 |
| Modelo | `model.tflite` @ 640×640 |
| Android | minSdk 24, JDK 17 |
| iOS | 12.0+, Xcode (solo macOS) |

---

## 2. Requisitos previos

### 2.1 Software

- **Flutter** stable: [docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- `flutter doctor -v` sin bloqueos para Android y/o iOS
- **Android:** Studio, SDK, JDK 17, `flutter doctor --android-licenses`
- **iOS (macOS):** Xcode, CocoaPods — ver **`mobile/IOS_SETUP.md`**
- **Git** para clonar el monorepo

### 2.2 Hardware (dispositivo)

Cámara trasera recomendada; **probar en teléfono físico** (emulador limitado para TFLite/cámara).

### 2.3 Modelo ML

Ruta en el proyecto:

```
mobile/assets/models/model.tflite
```

Contrato por defecto (`mobile/lib/core/model_config.dart`):

| Parámetro | Valor |
|---|---|
| Entrada | **640×640** (letterbox) |
| Clases | 0 drowning, 1 out of water, 2 swimming |
| Normalización | RGB × `1/255` |

Generar/copiar con **Parte I, §7**.

### 2.4 Permisos

Cámara, vibración (Android `VIBRATE`), wake lock en Android. Safe Splash **no graba audio**.

---

## 3. Instalación del entorno

### 3.1 Clonar el monorepo

```bash
git clone <URL_DEL_REPOSITORIO> safe-splash
cd safe-splash/mobile
```

### 3.2 Dependencias Flutter

```bash
flutter pub get
```

### 3.3 Modelo TFLite

```bash
# Desde mobile/ — tras export en training/ (Parte I, §7)
cp ../training/runs/detect/stage2_uninorte/weights/best.tflite assets/models/model.tflite
# o la ruta real del export
```

```powershell
# Windows PowerShell (desde mobile/)
Copy-Item ..\training\runs\detect\stage2_uninorte\weights\best.tflite assets\models\model.tflite
```

Verificar en `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/models/
```

### 3.4 iOS (solo macOS)

```bash
cd ios && pod install && cd ..
```

### 3.5 Ejecutar (debug)

```bash
flutter doctor -v
flutter devices
flutter run
```

Primera build: **5–15 min**. Conceder permiso de **cámara** y validar inferencia sin error TFLite en consola.

> Todos los comandos `flutter` de esta parte se ejecutan desde **`mobile/`**.

---

## 4. Despliegue

### 4.1 Android

```bash
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

Firma release: configurar keystore en `mobile/android/app/build.gradle.kts`. Revisar `applicationId` antes de tienda.

### 4.2 iOS

Ver **`mobile/IOS_SETUP.md`**. Resumen:

```bash
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
flutter build ios --release
```

### 4.3 Versionado

En `mobile/pubspec.yaml`: `version: 1.0.0+1`.

---

## 5. Verificación

| Verificación | Acción |
|---|---|
| Flutter | `flutter --version` ≥ 3.11 |
| Modelo | `mobile/assets/models/model.tflite` existe |
| App | `flutter run` sin error TFLite |
| Funcional | Etiquetas + alarma tras racha de ahogamiento en dispositivo físico |

---

## 6. Solución de problemas (app)

| Problema | Solución |
|---|---|
| Asset TFLite no cargado | Copiar modelo, `pubspec.yaml`, `flutter pub get`, `flutter clean` |
| Scores incoherentes | Alinear `mobile/lib/core/model_config.dart` con export (Parte I, §7) |
| Gradle / JDK | JDK 17; `flutter clean` desde `mobile/` |
| Cámara denegada | Ajustes del SO o reinstalar app |
| `pod install` | Ver `mobile/IOS_SETUP.md` |

---

## 7. Mantenimiento

```bash
git pull origin main

# App
cd mobile && flutter pub get && flutter run

# Nuevo modelo
cd training && yolo export ...
cp runs/detect/stage2_uninorte/weights/best.tflite ../mobile/assets/models/model.tflite
# PowerShell: Copy-Item runs/detect/stage2_uninorte/weights/best.tflite ..\mobile\assets\models\model.tflite
cd ../mobile && flutter clean && flutter pub get && flutter build apk --release
```

---

## 8. Referencias

| Recurso | Ruta |
|---|---|
| Pipeline ML | [training/README.md](training/README.md) |
| Desarrollo | [Desarrollo.md](Desarrollo.md) |
| iOS | [mobile/IOS_SETUP.md](mobile/IOS_SETUP.md) |
| ModelConfig | `mobile/lib/core/model_config.dart` |
| Flutter install | [docs.flutter.dev](https://docs.flutter.dev/get-started/install) |

---

*Monorepo: `training/` (Python/Ultralytics) + `mobile/` (Flutter ^3.11.1).*
