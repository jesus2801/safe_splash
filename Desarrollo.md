# Manual de desarrollo — Safe Splash

Guía para mantener y ampliar el **monorepo** (entrenamiento + app en un solo repositorio):

| Parte | Carpeta | Enfoque |
|-------|---------|---------|
| **I** | `training/` | YOLOv12, evaluación, inferencia GPU, export TFLite |
| **II** | `mobile/` | Flutter, cámara, TFLite on-device, alertas |

```
<repo>/
├── training/          # src/, scripts/, dataset/, runs/
├── mobile/            # lib/, android/, ios/, assets/
├── README.md
├── Instalacion.md
└── Desarrollo.md
```

Instalación: **[Instalacion.md](Instalacion.md)**. Detalle ML: **[training/README.md](training/README.md)**.

---

# Parte I — Entrenamiento (`training/`)

## 1. Propósito

Pipeline ML (fork [H20Saver](https://github.com/EsonH/H20Saver)): **YOLOv12**, entrenamiento en dos etapas y scripts con **tracking + suavizado temporal**. El artefacto para la app es **`.tflite` @ 640×640** en `mobile/assets/models/` (Parte II, §6).

## 2. Stack y módulos

| Módulo | Rol |
|--------|-----|
| `training/src/train.py` | Stage 1 — `dataset/` |
| `training/src/finetune.py` | Stage 2 — `uninorte_dataset/` |
| `training/src/data_analysis.py` | Stats de clases/bboxes |
| `training/src/model_evaluation.py` | P/R/mAP → `report.json` |
| `training/scripts/predict.py` | Inferencia imágenes |
| `training/scripts/predict_video.py` | Vídeo/stream + umbral ahogamiento |
| `training/scripts/split_dataset.py` | Split train/val/test (Roboflow) |

## 3. Estructura

```
training/
├── src/
├── scripts/
├── dataset/                  # gitignored
├── uninorte_dataset/         # gitignored
├── runs/detect/              # gitignored
├── requirements.txt
└── setup.py
```

| Ruta | Descripción |
|------|-------------|
| `runs/detect/stage1_public/weights/best.pt` | Salida stage 1 |
| `runs/detect/stage2_uninorte/weights/best.pt` | **Modelo a desplegar** |
| `dataset/data.yaml` / `uninorte_dataset/data.yaml` | Config YOLO; orden de clases = `mobile` `ModelConfig` |

## 4. Flujo ML → app

```
training/dataset/
    → train.py → stage1 best.pt
         → finetune.py → stage2 best.pt
              → model_evaluation.py
              → predict*.py
              → yolo export tflite imgsz=640
              → mobile/assets/models/model.tflite
```

Mismo `--imgsz` en stage 1 y 2 (p. ej. 1280 en A100). Export a la app solo a **640**.

## 5. Dónde cambiar qué

| Cambio | Ubicación |
|--------|-----------|
| Hiperparámetros entrenamiento | `training/src/train.py`, `finetune.py` |
| GPU / backbone / batch | CLI o defaults en esos scripts |
| Rutas Roboflow | `normalize_data_yaml()` en train/finetune |
| Métricas | `training/src/model_evaluation.py` |
| Alertas en vídeo demo | `training/scripts/predict_video.py` |
| UI Flutter / umbrales runtime | `mobile/` (Parte II) |

## 6. Comandos (desde `training/`)

```bash
cd training
.\.venv\Scripts\activate

python src/data_analysis.py --name public
python src/train.py
python src/finetune.py --weights runs/detect/stage1_public/weights/best.pt

python src/model_evaluation.py \
    --weights runs/detect/stage2_uninorte/weights/best.pt \
    --data uninorte_dataset/data.yaml --split test

python scripts/predict_video.py --source uninorte/videos/drowning.mp4 \
    --weights runs/detect/stage2_uninorte/weights/best.pt

yolo export model=runs/detect/stage2_uninorte/weights/best.pt format=tflite imgsz=640
cp runs/detect/stage2_uninorte/weights/best.tflite ../mobile/assets/models/model.tflite
# Windows PowerShell: Copy-Item runs/detect/stage2_uninorte/weights/best.tflite ..\mobile\assets\models\model.tflite
```

## 7. Artefactos y git

| Elemento | Notas |
|----------|--------|
| `.venv/` | Dentro de `training/`, no versionar |
| `runs/`, datasets | No versionar |
| PR con nuevo modelo | Incluir métricas + commit del `.tflite` en `mobile/assets/` si el equipo lo versiona |

**Checklist PR (ML):**

- [ ] `data_analysis.py` OK
- [ ] Fine-tune desde `best.pt` stage 1 correcto
- [ ] mAP *Drowning* aceptable en test
- [ ] `predict_video.py` con umbral razonable
- [ ] TFLite probado en `mobile/` (dispositivo físico)

## 8. Problemas frecuentes

| Problema | Revisar |
|----------|---------|
| OOM | `--imgsz`, `--batch`, `--cache disk` |
| Clases ≠ app | YAML vs `mobile/lib/core/model_config.dart` |
| Comando falla “file not found” | ¿Estás en `training/`? |

## 9. Convenciones

- Scripts Python: cwd = **`training/`**
- Commits en monorepo: indicar área (`training:`, `mobile:`) si ayuda al review
- Docs raíz: `Instalacion.md`, `Desarrollo.md`; detalle ML en `training/README.md`

---

# Parte II — App móvil (`mobile/`)

> Código Flutter en **`mobile/`**. Modelo generado en **`training/`** (Parte I).

---

## 1. Propósito

**Safe Splash**: monitoreo en tiempo real, inferencia en **isolate**, alarma tras racha de detecciones de ahogamiento. Sin backend.

## 2. Componentes clave

| Componente | Ruta (bajo `mobile/`) |
|---|---|
| `SplashApp` | `lib/app/splash_app.dart` |
| Navegación | splash → home → monitoring |
| `MonitoringController` | `lib/features/monitoring/application/` |
| `YoloTfliteDetector` + isolate | `lib/features/monitoring/data/` |
| `YoloOutputParser` | `yolo_output_parser.dart` |
| `ModelConfig` / `DetectionConstants` | `lib/core/` |

## 3. Estructura

```
mobile/
├── android/
├── ios/
├── assets/models/model.tflite
├── lib/
│   ├── main.dart
│   ├── app/
│   ├── core/
│   └── features/
│       ├── splash/
│       ├── home/
│       └── monitoring/
├── test/
├── pubspec.yaml
└── IOS_SETUP.md
```

## 4. Capas

| Capa | Carpeta | Rol |
|---|---|---|
| Presentación | `features/*/presentation/` | UI, banner |
| Aplicación | `monitoring/application/` | Estado, alarma |
| Datos | `monitoring/data/` | Cámara, TFLite, parser |
| Core | `lib/core/` | Modelo, umbrales, tema |

## 5. Build y comandos (desde `mobile/`)

```bash
cd mobile
flutter pub get
flutter run
flutter analyze
flutter test
flutter build apk --release
```

## 6. Integrar modelo

1. Export en `training/` (Parte I, §6).
2. Copiar `best.tflite` a `../mobile/assets/models/model.tflite` (ver [Instalacion.md](Instalacion.md), Parte I §7)
3. `pubspec.yaml` → `assets/models/`
4. Ajustar `lib/core/model_config.dart` si aplica.
5. Probar en dispositivo físico.

| Índice | Clase |
|---|---|
| 0 | drowning |
| 1 | out of water |
| 2 | swimming |

## 7. Flujo de desarrollo

```bash
git clone <URL_DEL_REPOSITORIO> safe-splash
cd safe-splash/mobile
flutter pub get
flutter run
```

| Cambio | Dónde (`mobile/`) |
|---|---|
| Pantalla nueva | `lib/features/<nombre>/` |
| Umbrales / muestreo | `lib/core/detection_constants.dart` |
| Contrato modelo | `lib/core/model_config.dart` |
| Parser YOLO | `yolo_output_parser.dart` |
| Permisos / package ID | `android/`, `ios/` |

Ramas monorepo: `feature/<nombre>`, `fix/<descripcion>` (pueden tocar `training/` y `mobile/` en el mismo PR si el cambio es end-to-end).

**PR app:** pasos en dispositivo; si hay nuevo `.tflite`, referenciar checkpoint y métricas de `training/runs/`.

## 8. Problemas y deuda técnica

| Problema | Revisar |
|---|---|
| Modelo ausente | `assets/models/`, `pubspec.yaml` |
| Clases invertidas | `ModelConfig` vs `training` YAML |
| UI lenta | Inferencia solo en isolate |

Deuda: tests limitados, signing release Android template, `applicationId` genérico, sin DI en `MonitoringController`.

## 9. Decisiones técnicas (app)

| Decisión | Motivo |
|---|---|
| Isolate para TFLite | No bloquear cámara |
| Muestreo + `_inferBusy` | CPU/batería |
| Alarma por racha | Filtrar ruido de un frame |
| TFLite local | Sin red, privacidad |

Complementa el suavizado temporal de `training/scripts/predict_video.py` en validación offline.

---

## Convenciones del monorepo

| Documento | Contenido |
|---|---|
| `README.md` (raíz) | Visión del producto |
| `training/README.md` | Entrenamiento, GPUs, flags |
| `Instalacion.md` | Instalación `training/` + `mobile/` |
| `Desarrollo.md` | Este manual |

Un PR puede modificar solo `training/`, solo `mobile/`, o ambos (p. ej. nuevo modelo + assets + ajuste de `ModelConfig`).

---

*Monorepo Safe Splash: `training/` (Ultralytics) + `mobile/` (Flutter ^3.11.1).*
