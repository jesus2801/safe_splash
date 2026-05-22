# SAFESPLASH: SISTEMA DE DETECCIÓN DE RIESGO DE AHOGAMIENTO PARA PISCINA SEMIOLÍMPICA

**Jesús David García Vargas**  
**Angélica Michelle Pupo Pallares**  
**Loreann Melissa Valencia Pantoja**

Universidad del Norte  
Ingeniería de Sistemas y Computación  
Barranquilla, Colombia  

Mayo de 2026

---

## RESUMEN

El ahogamiento es una de las principales causas de muerte accidental en el mundo, estimándose aproximadamente 236.000 muertes anuales a nivel global, afectando desproporcionadamente a niños y jóvenes [1], [2]. En la Universidad del Norte, el aumento sostenido de usuarios en su piscina semiolímpica ha evidenciado las limitaciones del modelo de supervisión exclusivamente humano, el cual depende de la capacidad visual y estado de alerta del salvavidas, factores que pueden fallar ante fatiga, distracción o alta ocupación [3], [5]. Por lo tanto, se identifica la necesidad de un sistema de apoyo que detecte de forma temprana situaciones de riesgo de ahogamiento, reduciendo los tiempos de reacción y complementando la labor del personal de seguridad.

Para abordar esta problemática, se diseñó e implementó un prototipo funcional basado en visión por computadora y el modelo de detección de objetos YOLOv12. El sistema opera de forma completamente local en un dispositivo móvil donde la cámara del dispositivo captura el video de los carriles y los frames son procesados en el mismo dispositivo por el modelo preentrenado, ajustado mediante fine-tuning y almacenado localmente en el archivo `best.pt`, el cual clasifica en tiempo real tres estados: natación normal, riesgo de ahogamiento y persona fuera del agua. Para el entrenamiento se combinó un dataset público con imágenes propias de la piscina universitaria, aplicando un preprocesamiento por tiling de 2×2 sobre aproximadamente el 66.5 % de las imágenes del dataset propio. La validación se realizó exclusivamente con datos institucionales. Los resultados obtenidos muestran que el modelo alcanza un mAP@50 de 0.86 sobre el conjunto de validación institucional, y la latencia total del sistema desde la captura hasta la alerta es inferior a diez segundos, cumpliendo el criterio de aceptación establecido.

El alcance del prototipo se delimita a una validación técnica bajo condiciones controladas en la piscina de la Universidad del Norte, con restricciones de hardware y disponibilidad de datos propias de la institución. La solución se concibe como una herramienta de apoyo al salvavidas, no como un sustituto. El valor del proyecto radica en reducir el tiempo de respuesta ante emergencias acuáticas mediante alertas oportunas, sin requerir infraestructura adicional más allá de un dispositivo móvil convencional, contribuyendo así a fortalecer los mecanismos de seguridad existentes.

**Palabras clave:** detección de ahogamiento, visión por computador, YOLO, fine-tuning, piscina semiolímpica, seguridad acuática.

---

## ABSTRACT

Drowning is one of the leading causes of accidental death worldwide, with an estimated 236,000 deaths per year globally, disproportionately affecting children and young people [1], [2]. At Universidad del Norte, the sustained increase in users at its semi-Olympic swimming pool has highlighted the limitations of an exclusively human supervision model, which depends on the lifeguard's visual capacity and alertness—factors that can fail due to fatigue, distraction, or high occupancy [3], [5]. This creates a clear need for a supporting system capable of early detection of drowning risk situations, reducing reaction times and complementing the security staff's work.

To address this problem, a functional prototype was designed and implemented based on computer vision and the YOLOv12 object detection model. The system runs entirely on a mobile device where its camera captures video of the pool lanes, and frames are processed locally on the same device by the pre-trained, fine-tuned model stored in the file `best.pt`, which classifies, with a total end-to-end latency below ten seconds (capture to alert), three states: normal swimming, drowning risk, and person out of water. Training combined a public dataset with images collected at the university's own pool, applying 2×2 tile preprocessing to approximately 66.5% of the proprietary dataset images. Validation was performed exclusively with institutional data. Results show that the model achieves a mAP@50 of 0.86 on the institutional validation set, and the total system latency from capture to alert is below ten seconds, meeting the established acceptance criterion.

The prototype's scope is limited to a technical validation under controlled conditions at the Universidad del Norte pool, subject to hardware and data availability constraints inherent to the institution. The solution is conceived as a tool to support lifeguards, not to replace them. Its value lies in reducing emergency response times through timely alerts, without requiring any additional infrastructure beyond a conventional mobile device, thereby contributing to strengthening existing safety mechanisms.

**Keywords:** drowning detection, computer vision, YOLO, fine-tuning, semi-olympic pool, aquatic safety.

---

## 1. Introducción

Las muertes por ahogamiento constituyen un problema significativo de salud pública a nivel mundial. Según la Organización Mundial de la Salud (OMS), el ahogamiento es una de las principales causas de muerte accidental en niños y jóvenes, estimándose aproximadamente 236.000 muertes anuales a nivel global. El 92 % de las defunciones por ahogamiento se producen en países de ingreso bajo y mediano, lo que evidencia una brecha estructural en prevención y respuesta ante emergencias acuáticas [1], [2]. En 48 de 85 países analizados, el ahogamiento figura entre las cinco principales causas de muerte en población infantil y juvenil [1], particularmente en contextos recreativos y deportivos.

En instalaciones deportivas universitarias, la vigilancia depende principalmente de la observación directa por parte de salvavidas o personal de apoyo. Sin embargo, estudios en factores humanos han demostrado que la supervisión visual sostenida puede verse afectada por fatiga, oclusiones visuales y limitaciones en el campo de visión [3]. En piscinas semiolímpicas con múltiples carriles activos, estas condiciones pueden dificultar la detección temprana de comportamientos anómalos. La reducción efectiva de los ahogamientos puede lograrse, en parte, mediante la implementación de un sistema de vigilancia automatizado inteligente que complemente la labor del salvavidas.

En este contexto, el presente proyecto propone el diseño e implementación de un sistema inteligente basado en visión por computador que permita analizar video con una latencia total extremo a extremo inferior a 10 segundos (desde la captura hasta la generación de la alerta) y detectar patrones visuales compatibles con posibles situaciones de riesgo de ahogamiento en la piscina semiolímpica de la Universidad del Norte. La solución se concibe como un sistema de apoyo a la supervisión humana, orientado a reducir el tiempo de respuesta ante eventos críticos y fortalecer los mecanismos de seguridad existentes.

Diversas investigaciones recientes han explorado el uso de visión por computador para la detección de eventos de riesgo en entornos acuáticos, modelando el problema como detección de comportamiento anómalo o análisis temporal de secuencias de video. Estos enfoques sugieren que la detección de ahogamiento no puede resolverse únicamente mediante clasificación estática de imágenes, sino que requiere análisis dinámico del movimiento y la postura a lo largo del tiempo. El avance en técnicas de aprendizaje profundo ha permitido el desarrollo de los modelos de la familia YOLO (You Only Look Once) [4], que han demostrado un desempeño sobresaliente en tareas de detección de objetos en tiempo real, combinando alta precisión con baja latencia computacional.

La principal contribución de este proyecto es la propuesta e implementación de un sistema que detecta de forma rápida y automática situaciones de riesgo de ahogamiento, basándose en visión por computadora y aprendizaje profundo, entrenado sobre datos representativos del entorno real de la piscina semiolímpica de la Universidad del Norte. Tras el fine-tuning del modelo sobre el dataset propio, el sistema identifica exitosamente los tres estados relevantes (natación normal, riesgo de ahogamiento y persona fuera del agua) con un mAP@50 de 0.88, Precision de 85.6% y Recall de 82.5% sobre el conjunto de validación institucional.

---

## 2. Marco Conceptual

### 2.1. Ahogamiento y vigilancia acuática

El ahogamiento se define como el proceso de sufrir insuficiencia respiratoria a consecuencia de la sumersión o inmersión en un líquido [14]. Desde el punto de vista de la vigilancia acuática, la detección temprana de una víctima de ahogamiento es crítica: los daños neurológicos irreversibles comienzan a producirse tras cuatro a seis minutos de privación de oxígeno [14]. En entornos recreativos y deportivos, el tiempo de respuesta del personal de seguridad está directamente vinculado a la probabilidad de supervivencia del afectado.

La supervisión humana es el mecanismo principal de vigilancia en piscinas, pero introduce limitaciones inherentes relacionadas con la fatiga de la atención sostenida, las oclusiones visuales derivadas de la alta ocupación y las restricciones en el campo de visión del salvavidas [3], [5]. La automatización de la detección de señales visuales de riesgo constituye, por tanto, una línea activa de investigación aplicada.

### 2.1.1. Postura de ahogamiento y nado normal

Una persona en proceso de ahogamiento activo adopta la denominada *Respuesta Instintiva de Ahogamiento* (RIA), descrita originalmente por Pia [15] y documentada clínicamente por Szpilman et al. [14]. Sus características visuales son:

1. Posición corporal predominantemente vertical en el agua, sin inclinación hacia la posición horizontal propia de la natación.
2. Cabeza inclinada hacia atrás, con la boca al nivel de la superficie del agua o por debajo de ella, sin capacidad de gritar ni llamar la atención.
3. Brazos extendidos lateralmente y presionando la superficie del agua hacia abajo, sin braceo coordinado ni rítmico.
4. Piernas inmóviles o con movimientos ineficaces sin patada organizada.
5. Sin progresión horizontal, lo que indica que el cuerpo no avanza a lo largo del carril.
6. Inmovilidad prolongada o lucha activa brevísima (30–60 segundos antes de la sumersión) sin resultado de avance.

Esta postura es visualmente distinguible del nado normal y constituye el patrón principal que el sistema SafeSplash busca detectar. A diferencia de la representación común de los casos de ahogamiento en cine y la cultura popular, la víctima de ahogamiento no emite sonidos fuertes ni grita, la respuesta es silenciosa y de aspecto relativamente estático, lo que dificulta su detección por observación humana no entrenada.

Mientras que el nado normal se caracteriza por una postura corporal predominantemente horizontal o prona, con movimiento coordinado y rítmico de brazos (braceo alternado o simultáneo) y piernas (patada continua), además de características visuales como:

1. Progresión visible del cuerpo a lo largo del carril de la piscina.
2. Ciclo respiratorio regular donde la cabeza alterna entre sumersión y emersión de forma periódica y controlada.
3. Control claro de la posición y la trayectoria dentro del carril.

Esta diferencia entre una postura vertical estática (ahogamiento) y postura horizontal dinámica (natación) es la base del criterio visual que guía tanto el etiquetado del dataset como la clasificación del modelo.

### 2.2. Visión por computador y detección de objetos

La visión por computador es la rama de la inteligencia artificial que permite a los sistemas computacionales interpretar y analizar imágenes y video de forma automática. Las redes neuronales convolucionales (CNN) son la arquitectura de referencia para la mayoría de las tareas de visión modernas: aprenden representaciones jerárquicas de características visuales (bordes, texturas, formas, regiones semánticas) directamente desde los datos de entrenamiento, mediante capas convolucionales que aplican filtros aprendibles sobre mapas de activación de resolución decreciente [18]. Su capacidad para generalizar representaciones visuales complejas las hace idóneas para tareas de detección en entornos dinámicos y con alta variabilidad visual como las piscinas.

La detección de objetos es una tarea que combina localización, determinar dónde está el objeto en la imagen mediante una caja delimitadora (bounding box), y clasificación para determinar qué tipo de objeto es [18]. A diferencia de la clasificación de imagen estática, la detección de objetos puede identificar múltiples instancias de distintas clases dentro de una misma imagen, lo que la hace idónea para escenarios con varios nadadores simultáneos.

### 2.3. YOLO (You Only Look Once)

YOLO es una familia de modelos de detección de objetos en tiempo real introducida por Redmon et al. [4] y ampliamente extendida en versiones posteriores (YOLOv5, YOLOv8, YOLOv11, YOLOv12). Su característica definitoria es que divide la imagen en una cuadrícula y realiza la predicción de bounding boxes y clases en un único paso de inferencia (single-pass), lo que lo hace significativamente más rápido que los detectores de dos etapas (como Faster R-CNN) sin comprometer sustancialmente la precisión.

YOLOv12, versión empleada en este proyecto, introduce mejoras arquitectónicas centradas en mecanismos de atención tipo *area attention* y un diseño de backbone más eficiente respecto a versiones anteriores, manteniendo alta velocidad de inferencia [6]. Su implementación oficial se distribuye a través del framework Ultralytics, que provee herramientas integradas de entrenamiento, validación e inferencia [6].

### 2.4. Fine-tuning y transfer learning

El transfer learning es una estrategia de aprendizaje automático que consiste en reutilizar el conocimiento adquirido por un modelo entrenado en un dominio fuente de gran escala (por ejemplo, clasificación de imágenes en ImageNet o detección de objetos en COCO) y trasladarlo a un dominio objetivo con datos más escasos [16]. Pan y Yang (2010) formalizaron esta técnica como el aprendizaje de una función de mapeo entre distribuciones de datos distintas, sentando las bases teóricas del área [16].

En el contexto del aprendizaje profundo, el fine-tuning es la variante más utilizada del transfer learning: se inicializan los pesos del modelo con los valores preentrenados en el dominio fuente y se continúa el entrenamiento sobre el dataset del dominio objetivo, generalmente con una tasa de aprendizaje reducida. Las capas iniciales de la red que codifican características visuales genéricas de bajo nivel como bordes, gradientes y texturas, tienden a congelarse o actualizarse lentamente, mientras que las capas superiores que aprenden representaciones semánticas específicas del dominio, se actualizan con mayor intensidad [18].

Esta estrategia es especialmente valiosa cuando se dispone de conjuntos de datos etiquetados de tamaño limitado, como es habitual en la vigilancia acuática, ya que permite aprovechar representaciones visuales ya aprendidas en millones de imágenes y reducir significativamente el riesgo de sobreajuste sobre el dataset propio.

### 2.5. Tiling como técnica de preprocesamiento

Los modelos de detección de objetos como YOLO reciben imágenes redimensionadas a una resolución fija de entrada (típicamente 640×640 o 1280×1280 px). Cuando la imagen original es de alta resolución y los objetos de interés son pequeños en términos de píxeles, como ocurre con nadadores ubicados a mayor distancia de la cámara, el redimensionamiento estándar destruye información visual crítica al reducir drásticamente el número de píxeles que representan cada objeto. Un nadador que ocupa 30×80 px en una imagen de 3840×2160 puede quedar reducido a apenas 5×12 px tras el redimensionamiento, por debajo del umbral de detección efectivo del modelo.

El tiling (o *slicing*) es una técnica de preprocesamiento que aborda este problema dividiendo la imagen de alta resolución en sub-imágenes (tiles) de menor tamaño que se procesan de forma independiente por el modelo de detección [17]. Los resultados parciales de cada tile se combinan mediante supresión de no-máximos (NMS) para eliminar detecciones duplicadas en las regiones de solapamiento. Akyon et al. (2022) formalizaron esta técnica bajo el nombre de *Slicing Aided Hyper Inference* (SAHI) y demostraron mejoras de hasta 6.8 puntos de AP en detectores como FCOS y 5.3 puntos en TOOD sobre conjuntos de datos con objetos pequeños [17]. Cuando se combina con fine-tuning sobre imágenes ya segmentadas en tiles, las mejoras alcanzan entre 12.7 y 14.5 puntos de AP [17].

En este proyecto se aplicó tiling de 2×2 (cuatro tiles por imagen) sobre aproximadamente el 66.5 % de las imágenes del dataset institucional, específicamente aquellas con planos más abiertos donde los nadadores presentan menor tamaño aparente, generando cuatro sub-imágenes por imagen original. Esto permitió incrementar la densidad de instancias útiles por muestra de entrenamiento y mejorar la sensibilidad del modelo ante nadadores en los carriles más alejados de la cámara.

### 2.6. Etiquetado de imágenes en visión por computador

El etiquetado (o anotación) de imágenes es el proceso mediante el cual se asocia información semántisca a cada imagen de un dataset, de modo que un modelo de aprendizaje profundo pueda aprender a reconocer los objetos o situaciones de interés [18]. En el contexto de la detección de objetos, etiquetar una imagen consiste en dibujar manualmente una caja delimitadora (bounding box) alrededor de cada instancia del objeto de interés y asignarle una etiqueta de clase que indique qué representa esa región (por ejemplo, *Drowning*, *Swimming* o *Person out of water*).

El formato de anotación utilizado por los modelos YOLO representa cada bounding box con cinco valores: la etiqueta de clase y las coordenadas normalizadas del centro, ancho y alto del recuadro respecto al tamaño de la imagen. Este formato compacto facilita la carga eficiente del dataset durante el entrenamiento y es generado y exportado directamente por herramientas de anotación colaborativa como Roboflow o LabelImg, las cuales también permiten gestionar versiones del dataset y aplicar aumentos de datos de forma automática.

La calidad del etiquetado tiene impacto directo y mensurable en el desempeño del modelo: trabajos como He et al. (2023) [11] señalan que la alta variabilidad de posiciones corporales en el dataset etiquetado es uno de los factores determinantes para la robustez del detector. Etiquetas inconsistentes, cajas mal ajustadas o clases ambiguas degradan la capacidad del modelo para aprender representaciones discriminativas, incrementando tanto las falsas alarmas como las detecciones perdidas. Por esta razón, en el proyecto se definieron criterios visuales explícitos de anotación para cada clase antes de iniciar el etiquetado del dataset institucional, tomando como base la definición técnica de la Respuesta Instintiva de Ahogamiento descrita en la sección 2.1.1.

### 2.7. Métricas de evaluación

- **Precision (P):** proporción de detecciones positivas que son realmente positivas. Mide la tasa de falsas alarmas.  
- **Recall (R):** proporción de casos positivos reales que el modelo detecta. Mide la sensibilidad del sistema. En el contexto de seguridad acuática, esta métrica es prioritaria.  
- **mAP@50 (mean Average Precision con IoU ≥ 0.5):** promedio del área bajo la curva precisión-recall para todas las clases, evaluado con un umbral de intersección sobre unión del 50 %. Es la métrica principal de referencia para comparar modelos de detección de objetos.  
- **mAP@50-95:** versión más estricta que promedia el mAP sobre umbrales de IoU entre 0.5 y 0.95, valorando la calidad de la localización además de la detección.

---

## 3. Planteamiento del Problema

### 3.1. Descripción del Problema

La detección automática de situaciones de riesgo en piscinas, como el ahogamiento, sigue siendo un reto abierto en el campo de la visión por computador. Las condiciones visuales complejas de este entorno -reflejos en la superficie, oclusiones entre nadadores, variaciones de iluminación natural y artificial- dificultan la clasificación automática de comportamientos. Adicionalmente, la naturaleza temporal del evento de riesgo implica que el sistema no puede limitarse a analizar fotogramas aislados, sino que debe considerar el estado del nadador a lo largo del tiempo.

La mayoría de los sistemas tradicionales dependen de la observación humana directa, lo cual es cognitivamente demandante y propenso a errores cuando la carga de atención es alta o cuando varias personas requieren vigilancia simultánea. Estudios en factores humanos muestran que la efectividad de la vigilancia visual sostenida decae significativamente tras períodos prolongados [3], [5].

En la literatura se han propuesto métodos de detección basada en visión para identificar ahogamientos usando cámaras fijas, con énfasis en el uso de modelos de aprendizaje profundo. Sin embargo, a pesar de los avances, los sistemas existentes presentan limitaciones importantes cuando se aplican en condiciones reales con múltiples nadadores y entornos dinámicos, en especial por la escasez de datasets etiquetados representativos. Trabajos recientes han demostrado que sistemas basados en YOLO pueden alcanzar precisiones superiores al 98% en condiciones controladas [8], aunque su generalización a entornos específicos requiere fine-tuning sobre datos del dominio objetivo.

La pregunta de investigación que guía este proyecto es: **¿cómo diseñar un sistema de visión por computador que pueda procesar secuencias de video con latencia total inferior a 10 segundos para detectar patrones visuales compatibles con posibles situaciones de ahogamiento en una piscina semiolímpica universitaria, superando condiciones adversas como iluminación variable y múltiples sujetos simultáneos, y operando con recursos computacionales disponibles en un entorno académico?**

### 3.2. Restricciones y Supuestos de Diseño

#### Restricciones físicas del entorno

- El sistema opera en la piscina semiolímpica existente de la Universidad del Norte, sin modificaciones estructurales permanentes.  
- La ubicación del dispositivo de captura está limitada por la infraestructura disponible (paredes, soportes existentes), y los ángulos que no interfieran con la privacidad en zonas externas al área de nado.  
- La iluminación es la propia del entorno (natural y artificial existente), sin control dedicado de condiciones lumínicas.

#### Restricciones técnicas

- El procesamiento en tiempo de ejecución se realiza en el hardware del dispositivo móvil; el entrenamiento del modelo se realizó sobre recursos computacionales del entorno académico (GPU de laboratorio).  
- El sistema opera con una latencia total máxima de 10 segundos desde la captura hasta la alerta, lo que impone restricciones sobre la complejidad del modelo y la resolución de entrada.  
- El sistema es exclusivamente basado en visión; no depende de sensores portátiles ni dispositivos electrónicos inteligentes diseñados para llevarse puestos en el cuerpo como accesorios o prendas de vestir sobre los nadadores.

#### Restricciones de datos

- El dataset está basado en simulaciones controladas de ahogamiento con voluntarios debido a que por razones éticas y prácticas, no se utilizan ni se pueden utilizar imágenes de ahogamientos reales. Todas las escenas de riesgo registradas corresponden a voluntarios que simularon la Respuesta Instintiva de Ahogamiento bajo supervisión del equipo de investigación.  
- En el dataset se priorizan grabaciones experimentales supervisadas que reproduzcan fielmente los indicadores visuales descritos en la sección 2.1.1.

#### Restricciones éticas y legales

- El sistema no almacena imágenes personales de los usuarios de la piscina semi-olímpica de la Universidad del Norte.  
- El sistema trata a los nadadores como objetos anónimos, es decir, no realiza reconocimiento facial, no asigna identidades y no hace *tracking* por persona entre frames ni entre sesiones. Cada nadador es detectado únicamente por su clase de comportamiento y posición en la escena.  
- El sistema tiene fines académicos y de investigación; no reemplaza la supervisión humana.

#### Supuestos sobre el entorno

- La cámara del dispositivo móvil, se encuentra posicionada en el centro del ancho de la piscina de manera elevada, cuenta con campo de visión suficiente para cubrir la mayor parte del espejo de agua (526.05m²) excluyendo las dos esquinas próximas al borde de la piscina donde se instaló la camara, sin embargo, en esos puntos se encuentran ubicadas las dos escaleras murales de la piscina, sin demás puntos ciegos significativos en el área monitoreada.
- El número máximo de nadadores simultáneos es moderado y acorde a la capacidad reglamentaria de la piscina.  
- No hay obstrucciones permanentes dentro del campo visual principal.

#### Supuestos sobre el comportamiento del evento de interés

- El comportamiento asociado a un posible ahogamiento presenta patrones visuales distinguibles respecto al nado normal, tanto en postura como en dinámica de movimiento.  
- Dichos patrones pueden ser capturados mediante secuencias de imágenes RGB convencionales desde una perspectiva aérea.

#### Supuestos sobre el modelo computacional

- YOLOv12m posee la capacidad expresiva necesaria para discriminar entre las tres clases del problema a partir del dataset disponible. El backbone preentrenado en COCO ya codifica características de bajo y medio nivel (bordes, texturas, relaciones espaciales entre partes del cuerpo) que son directamente transferibles a la tarea de detección de postura en el dominio acuático.
- El redimensionamiento del frame capturado a 960 px preserva suficiente información espacial para distinguir la orientación corporal vertical (ahogamiento) de la horizontal (nado normal) a las distancias de operación características de la piscina (aproximadamente 3–18 m entre la cámara y el nadador).
- Las tres clases del problema (*Swimming*, *Drowning*, *Person out of water*) presentan diferencias visuales suficientemente discriminativas (orientación del eje corporal, presencia o ausencia de braceo coordinado, relación entre la posición del cuerpo y la superficie del agua) para ser separadas en el espacio de características del modelo tras el fine-tuning. Este supuesto está respaldado por el mAP@50 de 0.86 obtenido sobre el conjunto de validación institucional independiente.

#### Supuestos operativos

- El sistema funciona como herramienta de apoyo a la supervisión humana, nunca como sustituto.  
- Las alertas generadas son revisadas por personal capacitado antes de iniciar cualquier intervención.

### 3.3. Alcance

El proyecto contempla el diseño e implementación de un prototipo funcional de un sistema de detección automática de riesgo de ahogamiento mediante visión por computador.

**Incluido en el alcance:**

- Recolección y anotación de un dataset representativo del entorno de la piscina.  
- Entrenamiento y fine-tuning de un modelo de detección basado en YOLOv12.  
- Implementación de la aplicación móvil con módulos de captura, inferencia local y alertas.  
- Integración del modelo `best.pt` en el dispositivo para inferencia sin servidor externo.  
- Implementación de un módulo de generación de alertas sonoras y visuales en el dispositivo.  
- Evaluación experimental del sistema con métricas de precisión, recall y latencia.

**No incluido en el alcance:**

- Diagnóstico médico o evaluación clínica de los nadadores.  
- Sustitución del personal de salvavidas.  
- Integración con sistemas de rescate automatizado.  
- Despliegue en producción continua fuera del entorno de pruebas controladas.  
- Autoentrenamiento o aprendizaje automático con datos nuevos durante la operación. El modelo `best.pt` es fijo en tiempo de ejecución.
- Almacenamiento en la nube del histórico de eventos pues esto se almacena exclusivamente en el dispositivo móvil en formato JSON local. 
- Reconocimiento de identidad y tracking a nadadores individuales entre frames ni entre sesiones.

---

## 4. Objetivos

### 4.1. Objetivo General

Diseñar e implementar un sistema inteligente basado en visión por computador capaz de detectar, con latencia total inferior a 10 segundos desde la captura hasta la alerta, patrones visuales asociados a posibles situaciones de ahogamiento en la piscina semiolímpica de la Universidad del Norte, con el fin de apoyar la supervisión humana y fortalecer los mecanismos de seguridad.

### 4.2. Objetivos Específicos

1. Diseñar la arquitectura de software del sistema, especificando los módulos de captura, procesamiento e interacción con el usuario y las relaciones entre ellos.
2. Construir y anotar un dataset representativo del entorno real de la piscina, combinando datos públicos disponibles con imágenes capturadas in situ en la instalación universitaria, con escenas de simulación de ahogamiento y nado normal.
3. Seleccionar, adaptar y entrenar un modelo de detección basado en la familia YOLO mediante fine-tuning sobre el dataset construido, alcanzando un **mAP@50 ≥ 0.85**, **Recall ≥ 70 %** y **Precision ≥ 60 %** sobre el conjunto de validación institucional para la clase *Drowning*.
4. Implementar un prototipo funcional capaz de procesar video capturado por un dispositivo móvil con latencia total inferior a 10 segundos (captura a alerta) y generar alertas ante situaciones de riesgo.
5. Evaluar el desempeño del sistema mediante métricas de precisión (Precision ≥ 60 %), sensibilidad (Recall ≥ 70 %), mAP@50 (≥ 0.85) y latencia extremo a extremo (≤ 10 s), contrastando los resultados con los criterios de aceptación definidos.

---

## 5. Estado del Arte / Soluciones Relacionadas

La detección automática de situaciones de ahogamiento mediante visión por computador ha experimentado un crecimiento sostenido, impulsado por los avances en arquitecturas de redes neuronales convolucionales y modelos de detección en tiempo real.

### Sistemas basados en clasificación de imágenes estáticas

Shatnawi et al. (2023) presentaron un enfoque de detección temprana de ahogamiento evaluando cinco modelos CNN (SqueezeNet, GoogleNet, AlexNet, ShuffleNet y ResNet50) sobre un dataset propio. ResNet50 alcanzó una precisión del 100 % en la tarea de clasificación binaria [7]. Si bien el trabajo establece la viabilidad de los modelos CNN, el dataset fue construido con imágenes de internet, lo que limita su representatividad en entornos reales.

### Enfoques basados en YOLO para detección en tiempo real

Alharbi et al. (2024) propusieron un sistema basado en YOLOv8 con técnicas de aumento de datos para mejorar la robustez ante variaciones de iluminación [8]. Su trabajo demostró que YOLOv8 constituye una herramienta poderosa para tareas de detección en este dominio.

Jiang et al. (2025), con su modelo *Swimming-YOLO*, propusieron mejoras específicas sobre el algoritmo YOLO para escenarios con múltiples nadadores simultáneos, abordando uno de los retos más comunes en piscinas de alta ocupación.

El modelo YOLO11-LiB (2025) introdujo mejoras estructurales en la arquitectura YOLOv11n que le permitieron alcanzar una precisión media del 94.1 % en la clase ahogamiento (DmAP50), con apenas 2.02 millones de parámetros y 4.25 MB de tamaño, ofreciendo un balance efectivo entre precisión y eficiencia.

Huang (2025) presentó H2OSaver [22], un sistema de detección de ahogamiento de código abierto basado en fine-tuning del modelo **YOLOv11x** sobre un dataset de 14.111 imágenes etiquetadas en tres clases: *Drowning* (41.4 %, ≈12.000 muestras), *Swimming* (38.1 %, ≈10.000) y *Out of Water* (20.5 %, ≈5.500). El entrenamiento se realizó durante 100 épocas con tamaño de imagen de 640 px y batch de 23, aplicando un conjunto amplio de técnicas de aumento de datos: ajuste HSV, traslación, escalado, volteo horizontal, Mosaic y Mixup. Para compensar el desbalance de clases se habilitó focal loss con ponderación automática de clases por frecuencia inversa. Las capas del backbone y la cabeza de detección fueron congeladas durante el fine-tuning. Los resultados sobre el conjunto de validación (1.503 imágenes, 2.998 instancias) muestran un mAP@50 de 0.924 para la clase *Drowning* con precision de 0.874 y recall de 0.876; el mAP@50 global sobre las tres clases fue de 0.766. La clase *Out of Water* presentó el recall más bajo (0.464), comportamiento consistente con su menor representación en el dataset, patrón también observado en otros trabajos del estado del arte. El repositorio publica los pesos del modelo y el pipeline completo de entrenamiento, evaluación y exportación a ONNX.

### Enfoques con modelos duales y análisis temporal

Liu et al. (2023) propusieron un sistema de dos etapas: una red YOLOv5n detecta cuerpos humanos en postura casi vertical (indicativa de ahogamiento), y una red de detección de anomalías (DDN) basada en un modelo gaussiano profundo identifica irregularidades semánticas de alto nivel. Este enfoque destaca la necesidad de combinar detección de pose con análisis de comportamiento anómalo en el tiempo, superando los modelos que operan sobre fotogramas individuales.

He et al. (2023) abordaron la detección de ahogamiento en infantes combinando YOLOv5 y Faster R-CNN sobre secuencias de video de vigilancia, destacando la importancia de datos etiquetados con alta variabilidad de posiciones corporales.

### Sistemas con integración IoT

Pradhan et al. (2024) demostraron la viabilidad de desplegar modelos de detección en dispositivos de recursos limitados combinando inteligencia artificial e IoT. En una dirección similar, Meng et al. (2023) presentaron un sistema de alto desempeño para detección de ahogamiento en infantes capaz de operar en tiempo real.

### Enfoques con análisis de pose y esqueleto

Gao y Pan (2024) propusieron un sistema de detección de ahogamiento basado en el modelo **YOLOv8-POSE** combinado con OpenCV [21]. En lugar de detectar al nadador como un objeto completo, este enfoque extrae los keypoints articulares del cuerpo humano (hombros, codos, caderas, rodillas, tobillos y cabeza) y analiza la geometría del esqueleto en cada frame para identificar posturas anómalas. La lógica de detección evalúa métricas como el ángulo de inclinación del eje torso-cadera respecto a la vertical, la posición relativa de la cabeza con respecto a los hombros y la simetría del movimiento de extremidades. El sistema fue diseñado para operar en tiempo real sobre video de vigilancia de piscinas y emitir alertas cuando la configuración de keypoints supera umbrales predefinidos de anomalía postural.

Yang et al. (2024) [20] presentaron un sistema basado en drones equipados con cámara (DJI Mini 3 Pro) para captura aérea sobre piscinas interiores, combinado con una versión mejorada de YOLOv5 que incorpora un módulo de atención de coordenadas mejorado (ICA) y una red de pirámide de características bidireccional (BiFPN) en sustitución de la red PAN original. Su dataset propio constó de 8.572 imágenes de cuatro nadadores con posturas diversas (crol, braza, espalda, agua en posición vertical y grupos de 2–4 personas). El modelo obtuvo una precisión de 98.1 %, recall de 98.0 % y [mAP@0.5](mailto:mAP@0.5) de 98.5 % sobre el conjunto de validación, con una velocidad de inferencia de 3.7 ms por frame en una GPU RTX 3060. Los autores destacan que la perspectiva aérea de dron ofrece mayor flexibilidad que las cámaras fijas de pared o las cámaras subacuáticas, puesto que evita las limitaciones de ángulo rígido y permite seguimiento activo del nadador en riesgo.

### Sistemas con cámaras térmicas e infrarrojas

Liu, Philipsen y Moeslund (2021) propusieron un sistema de vigilancia asistida para frentes de puerto (*harbor fronts*) basado en imágenes térmicas capturadas con cámaras de infrarrojos de onda larga (LWIR) [19]. La motivación central de su trabajo fue la necesidad de cumplir con restricciones de privacidad: al operar en el espectro térmico, las cámaras no capturan rasgos faciales identificables sino únicamente la huella de calor corporal, lo que permite desplegar el sistema en entornos públicos sin requerir consentimiento explícito de los sujetos vigilados.

El sistema comparó dos enfoques computacionales sobre el mismo stream de video térmico. El primero, de naturaleza supervisada, aplicó un detector de objetos basado en Faster R-CNN para localizar personas dentro de una zona delimitada próxima al borde del agua; cuando una persona es detectada en esa región, el sistema emite una alerta preventiva. El segundo enfoque, de naturaleza auto-supervisada, entrenó un autoencoder convolucional exclusivamente sobre escenas sin presencia humana (escenas "normales"); en operación, la reconstrucción de una escena con personas genera un error de reconstrucción elevado que es interpretado como anomalía. El dataset de evaluación fue construido en un ambiente de puerto real, con escenas etiquetadas como seguras (sin personas) y de riesgo (persona visible cerca del agua). Los resultados mostraron que el detector supervisado superó al autoencoder en términos de precisión y recall, aunque el enfoque auto-supervisado presentó la ventaja de no requerir anotaciones manuales costosas.

Las cámaras térmicas utilizadas en este tipo de sistemas tienen resoluciones espaciales típicas de 320×256 px o 640×512 px, considerablemente inferiores a las cámaras RGB convencionales de vigilancia (1080p o superior), lo que limita la capacidad de detectar objetos de pequeño tamaño aparente o de distinguir detalles posturales finos. Adicionalmente, el costo unitario de una cámara LWIR de calidad para vigilancia se sitúa en un orden de magnitud superior al de una cámara RGB de resolución equivalente.

### Enfoques con cámaras subacuáticas

Liu et al. (2023) [10] desarrollaron un sistema de detección de ahogamiento en dos etapas que utilizó cámaras fijas montadas en las paredes y el fondo de piscinas interiores para capturar video subacuático. La primera etapa del sistema emplea una red YOLOv5n, variante ultraligera de YOLOv5, para detectar cuerpos humanos dentro del campo de visión subacuático e identificar aquellos que presentan una orientación casi vertical en el agua (característica visual que los autores vinculan con la postura de ahogamiento activo). La segunda etapa aplica una red de detección de anomalías basada en un modelo gaussiano profundo (*Deep Gaussian Detection Network*, DDN), que analiza la coherencia semántica de las detecciones de la primera etapa a lo largo del tiempo: patrones de movimiento que se desvían estadísticamente de la distribución aprendida de nado normal son marcados como anomalías de alto nivel y desencadenan la alerta. Este diseño de dos etapas busca reducir la tasa de falsas alarmas que generaría un detector de pose único actuando sobre fotogramas aislados. La perspectiva subacuática ofrece visibilidad del cuerpo completo del nadador sin la oclusión que provoca la reflexión y refracción en la interfaz agua-aire, lo que en teoría mejora la calidad de las features posturales disponibles para el detector.

Hasan et al. (citado en [20]) construyeron un dataset comparativo capturando video de forma simultánea desde perspectiva superficial y subacuática en el mismo entorno de piscina, con el objetivo de evaluar cuál de las dos perspectivas resulta más ventajosa para modelos de aprendizaje profundo orientados a la detección de ahogamiento. Sus experimentos revelaron que los modelos entrenados y evaluados sobre el dataset superficial obtuvieron métricas de precisión y recall consistentemente superiores a los entrenados sobre el dataset subacuático, atribuyendo la diferencia principalmente a la degradación visual introducida por la turbulencia del agua, las burbujas generadas por el movimiento y los artefactos de refracción propios del medio acuático, todos los cuales reducen la nitidez y estabilidad de los contornos corporales en el stream subacuático.

---

## 6. Requerimientos

### 6.1. Funcionales


| ID    | Requerimiento                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RF-01 | El sistema debe capturar video continuo desde la cámara del dispositivo móvil con resolución mínima de 720p y tasa no inferior a 15 fps.                                                                                                                                                                                                                                                                                                                                                                          |
| RF-02 | El sistema debe ejecutar la inferencia del modelo localmente en el dispositivo, sin depender de conectividad de red ni de servidores externos.                                                                                                                                                                                                                                                                                                                                                                    |
| RF-03 | El sistema debe identificar patrones visuales asociados a riesgo de ahogamiento, correspondientes a la *Respuesta Instintiva de Ahogamiento* (véase sección 2.1.1): postura corporal predominantemente **vertical** (en lugar de la posición horizontal del nado normal), sin progresión horizontal en el carril, brazos extendidos lateralmente sin braceo coordinado, piernas sin patada efectiva, e inmovilidad prolongada en el agua. Estos indicadores son la base del criterio de clasificación del modelo. |
| RF-04 | Ante la detección sostenida de un comportamiento de riesgo, el sistema debe emitir una alerta perceptible por el personal de vigilancia dentro de un tiempo máximo de 10 segundos desde el inicio del evento.                                                                                                                                                                                                                                                                                                     |
| RF-05 | El sistema debe permitir ajustar los parámetros de decisión (umbral de confianza del modelo, duración mínima del comportamiento anómalo antes de emitir alerta) sin necesidad de reentrenar el modelo.                                                                                                                                                                                                                                                                                                            |
| RF-06 | El sistema debe clasificar cada frame en tres clases: *Swimming* (nado normal), *Drowning* (riesgo de ahogamiento) y *Person out of water* (persona fuera del agua).                                                                                                                                                                                                                                                                                                                                              |


### 6.2. No Funcionales


| ID     | Requerimiento                                                                                                                                                                                                  |
| ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RNF-01 | **Rendimiento:** el pipeline completo en el dispositivo (captura, inferencia local y emisión de alerta) debe operar con latencia total inferior a 10 segundos.                                                 |
| RNF-02 | **Portabilidad:** la aplicación móvil debe ser compatible con dispositivos iOS y Android mediante Flutter, con cámara trasera de resolución mínima 720p.                                                       |
| RNF-03 | **Disponibilidad:** la aplicación debe operar de forma continua y estable durante las horas de uso de la piscina, con capacidad de recuperación ante interrupciones menores sin perder el estado de monitoreo. |
| RNF-04 | **Privacidad:** el sistema no almacenará de manera persistente imágenes o video identificable de los usuarios. Los fotogramas son procesados en memoria y descartados tras la inferencia.                      |
| RNF-05 | **Mantenibilidad:** la arquitectura debe permitir actualizar el archivo de modelo (`best.pt`) con una versión reentrenada sin necesidad de modificar el código de la aplicación.                               |
| RNF-06 | **Precisión mínima del modelo:** el sistema debe alcanzar Recall ≥ 70 % y Precision ≥ 60 % sobre el conjunto de prueba para ser considerado técnicamente aceptable.                                            |


---

## 7. Diseño y Arquitectura

### 7.1. Evaluación de Alternativas

Durante la fase de diseño se realizó un análisis comparativo de enfoques tecnológicos en tres dimensiones: modelo de detección, arquitectura de procesamiento y mecanismo de captura.

#### 7.1.1. Alternativas de modelo de detección

Se evaluaron tres familias de modelos:


| Criterio                                     | CNN Clasificación (ResNet, AlexNet) | YOLO (YOLOv8, YOLOv12) | Modelos temporales (LSTM, 3D-CNN)            |
| -------------------------------------------- | ----------------------------------- | ---------------------- | -------------------------------------------- |
| Localización de múltiples sujetos            | No permite                          | Sí, directamente       | Parcial (requiere etapa de detección previa) |
| Velocidad de inferencia                      | Alta                                | Muy alta               | Baja–media                                   |
| Complejidad de implementación                | Baja                                | Media                  | Alta                                         |
| Disponibilidad de modelos preentrenados      | Alta                                | Alta                   | Media                                        |
| Necesidad de datos etiquetados temporales    | No                                  | No                     | Sí (secuencias etiquetadas)                  |
| Latencia extremo a extremo ≤ 10 s            | No cumple (solo clasificación)      | Alta                   | Baja–media                                   |
| Adecuación al contexto (múltiples nadadores) | Baja                                | Alta                   | Media                                        |


Los modelos de clasificación estática (ResNet, AlexNet) son adecuados para clasificación binaria pero no permiten detectar múltiples instancias ni localizar eventos dentro de la escena. Los modelos con componente temporal (LSTM, 3D-CNN) capturan dinámicas de comportamiento pero requieren secuencias etiquetadas y presentan mayor carga computacional, comprometiendo la latencia.

**Decisión:** se seleccionó YOLOv12m de Ultralytics. Su capacidad de detección en tiempo real, localización simultánea de múltiples instancias, disponibilidad de pesos preentrenados en COCO y el soporte nativo para fine-tuning en el framework Ultralytics lo hacen la alternativa más adecuada para las restricciones del proyecto.

#### 7.1.2. Alternativas de arquitectura de procesamiento


| Criterio                                 | Procesamiento local en el dispositivo                 | Arquitectura cliente-servidor (local) | Procesamiento en la nube       |
| ---------------------------------------- | ----------------------------------------------------- | ------------------------------------- | ------------------------------ |
| Latencia                                 | Muy baja (sin red)                                    | Media                                 | Alta (depende de conectividad) |
| Capacidad de cómputo                     | Limitada por el hardware del dispositivo              | Alta (GPU de laboratorio)             | Alta                           |
| Costo                                    | Nulo                                                  | Nulo (recursos académicos)            | Elevado                        |
| Independencia de red                     | Completa                                              | Requiere red local                    | Requiere Internet              |
| Dependencia de infraestructura adicional | Ninguna                                               | Requiere servidor activo              | Requiere conexión a la nube    |
| Mantenibilidad del modelo                | Actualización del archivo `best.pt` en el dispositivo | Alta (centralizado en el servidor)    | Alta                           |


**Decisión:** se adoptó el procesamiento completamente local en el dispositivo. Aunque la capacidad de cómputo del dispositivo es más limitada que la de un servidor con GPU dedicada, esta alternativa elimina la dependencia de red y de infraestructura adicional, reduce la latencia al suprimir la transmisión de frames, y simplifica el despliegue a un único artefacto. El modelo YOLOv12m exportado en formato compatible con el entorno de Flutter opera dentro de los umbrales de latencia requeridos en el hardware disponible.

#### 7.1.3. Alternativas de mecanismo de captura


| Criterio                          | Cámara IP fija dedicada | dispositivo móvil | Cámara de seguridad existente |
| --------------------------------- | ----------------------- | ----------------- | ----------------------------- |
| Costo de implementación           | Alto                    | Nulo (disponible) | Depende de integración        |
| Flexibilidad de reposicionamiento | Media                   | Alta              | Ninguna                       |
| Complejidad de integración        | Media                   | Baja              | Alta                          |
| Calidad de imagen                 | Alta                    | Media–alta        | Variable                      |


**Decisión:** se utilizó un dispositivo móvil existente como nodo de captura. Su disponibilidad sin costo adicional, la facilidad de desarrollo de una aplicación de captura nativa y la flexibilidad para reposicionarlo durante las pruebas lo hacen la alternativa más práctica para el contexto académico del proyecto.

---

### 7.2. Arquitectura

#### 7.2.1. Descripción General de la Arquitectura

El sistema SafeSplash sigue una **arquitectura de procesamiento local autocontenida**, en la que todos los módulos residen y se ejecutan en un único dispositivo móvil. No existe dependencia de servidores externos ni de conectividad de red durante la operación. La aplicación desarrollada en Flutter integra en un mismo proceso la captura de video, la inferencia del modelo de detección, el análisis de riesgo y la emisión de alertas.

El flujo general comprende desde la cámara del dispositivo captura frames de video de forma continua, donde cada frame es preprocesado y pasado al motor de inferencia local que carga el modelo YOLOv12 desde el archivo `best.pt` almacenado en el dispositivo; el módulo de análisis de riesgo evalúa las detecciones en función de un umbral de confianza y criterios temporales; si se identifica una situación de riesgo sostenida, se emite una alerta sonora y visual desde el mismo dispositivo.

Esta arquitectura es consistente con la alternativa seleccionada en la sección 7.1 y satisface los requerimientos RF-01 a RF-06 y RNF-01 a RNF-06.

#### 7.2.2. Componentes del Sistema e Interacción

##### 7.2.2.1. Descripción de Componentes

**Módulo de Captura**

Responsabilidad: adquirir frames de video desde la cámara del dispositivo y entregarlos al motor de inferencia local.

- Captura video con resolución configurada (mínimo 720p, 15 fps) mediante los plugins de cámara de Flutter.  
- Extrae frames individuales a la tasa definida y los pasa directamente al módulo de inferencia sin transmisión por red.  
- Relación con requerimientos: RF-01, RNF-02.

**Módulo de Inferencia Local**

Responsabilidad: ejecutar el modelo YOLOv12 directamente en el dispositivo sobre cada frame capturado.

- Carga el modelo desde el archivo `best.pt` almacenado localmente en el dispositivo al iniciar la aplicación.  
- Preprocesa cada frame (redimensionamiento, normalización) y ejecuta la inferencia.  
- Retorna las detecciones al módulo de análisis de riesgo en forma de bounding boxes con etiquetas de clase y puntuaciones de confianza.  
- Relación con requerimientos: RF-02, RF-06, RNF-01.

**Módulo de Análisis de Riesgo**

Responsabilidad: evaluar la salida del modelo y determinar si debe emitirse una alerta, incorporando un componente temporal para reducir falsas alarmas.

- Evalúa si alguna detección supera el umbral de confianza configurado para la clase *Drowning*.  
- Aplica criterio temporal: solo emite alerta cuando la detección es sostenida durante un número mínimo de frames consecutivos.  
- Relación con requerimientos: RF-03, RF-04, RF-05.

**Módulo de Alertas**

Responsabilidad: comunicar la detección de riesgo al personal de vigilancia de forma perceptible y oportuna.

- Activa una señal sonora audible desde el dispositivo en el área de la piscina.  
- Despliega simultáneamente una alerta visual en pantalla (notificación prominente dentro de la aplicación) para garantizar que el salvavidas sea notificado aun en entornos con ruido ambiental elevado.  
- Relación con requerimientos: RF-04.

**Registro local de eventos (JSON)**

Responsabilidad: almacenar metadatos de los eventos detectados para análisis posterior.

- Guarda en el almacenamiento interno del dispositivo un archivo JSON con una entrada por cada evento de alerta, conteniendo: timestamp, clase detectada y nivel de confianza.  
- No almacena imágenes ni video identificable, cumpliendo RNF-04.

A continuación se presenta el diagrama de arquitectura del sistema:

Diagrama de Arquitectura

##### 7.2.2.2. Interacción entre Módulos

Todos los módulos se ejecutan dentro de la misma aplicación Flutter en el dispositivo. La comunicación entre ellos es directa en memoria, sin transferencia de datos por red. El flujo de datos es el siguiente:

1. El módulo de captura extrae un frame del flujo de video de la cámara.
2. El frame es pasado en memoria al módulo de inferencia local.
3. El motor de inferencia ejecuta el modelo YOLOv12 (`best.pt`) y retorna las detecciones (bounding boxes, etiquetas, confianzas).
4. Las detecciones son entregadas al módulo de análisis de riesgo.
5. El módulo de análisis evalúa el umbral de confianza y la ventana temporal, y determina si corresponde emitir alerta.
6. Si hay alerta, el módulo de alertas activa simultáneamente la señal sonora y la alerta visual en pantalla.
7. El registro local almacena los metadatos del evento.

El acoplamiento entre módulos es bajo: cada módulo recibe datos del anterior a través de interfaces bien definidas, sin dependencias directas entre implementaciones. Esto facilita la sustitución del modelo de inferencia por una versión actualizada de `best.pt` sin modificar los módulos de análisis, alertas o captura (RNF-05).

Diagrama de Interacción entre Módulos

##### 7.2.2.3. Comportamiento

El diagrama de secuencia describe el flujo de una detección de riesgo de extremo a extremo:

Diagrama de Secuencia

**Análisis del comportamiento:**

- **Eficiencia del flujo:** el flujo es completamente local y lineal, sin pasos de red. Al eliminar la transmisión de frames, se suprime la principal fuente de latencia variable del sistema.  
- **Cuello de botella principal:** la inferencia del modelo es el paso de mayor carga computacional. Al ejecutarse en el hardware del dispositivo (sin GPU dedicada), el tiempo de inferencia por frame es mayor que en un servidor con GPU, pero se mantiene dentro de los límites que permiten cumplir el umbral de latencia total de 10 segundos (RNF-01).  
- **Latencia total:** el sistema presenta latencia únicamente en las etapas de captura, inferencia local y análisis. La ausencia de transmisión de red elimina la variabilidad asociada a la calidad de la conexión Wi-Fi, resultando en una latencia más predecible y consistente.  
- **Desacoplamiento adecuado:** los módulos internos están bien separados. Actualizar el modelo implica únicamente reemplazar el archivo `best.pt` en el dispositivo, sin afectar el código de los demás módulos (RNF-05).  
- **Independencia de red:** dado que no se requiere conectividad durante la operación, el sistema puede funcionar incluso en zonas con señal Wi-Fi débil o inestable, lo que aumenta su robustez en entornos deportivos.

---

## 8. Implementación

### 8.1. Stack Tecnológico


| Capa                                     | Tecnología                                                                                | Justificación                                                                                                                                                                                            |
| ---------------------------------------- | ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Aplicación móvil                         | Flutter (Dart)                                                                            | Framework multiplataforma que permite distribuir la aplicación en iOS y Android desde una única base de código, con acceso a la cámara del dispositivo mediante plugins nativos.                         |
| Inferencia en dispositivo                | TFLite (exportación desde Ultralytics)                                                    | YOLOv12 exportado desde Ultralytics a formato TFLite permite ejecutar el modelo directamente en el dispositivo sin servidor externo, con soporte nativo en Flutter mediante el paquete `tflite_flutter`. |
| Modelo de detección                      | YOLOv12m (archivo `best.pt`)                                                              | Mejor balance entre precisión y velocidad entre las variantes de YOLOv12; exportado al formato requerido para inferencia móvil.                                                                          |
| Entrenamiento y validación               | Python 3.10 + PyTorch + Ultralytics                                                       | Ecosistema estándar para entrenamiento de modelos YOLO; PyTorch provee flexibilidad y Ultralytics ofrece herramientas integradas de entrenamiento, validación e inferencia.                              |
| Manipulación de imágenes (entrenamiento) | OpenCV                                                                                    | Utilizado durante el preprocesamiento del dataset (tiling, redimensionamiento) en la fase de entrenamiento.                                                                                              |
| Entorno de entrenamiento                 | GPU NVIDIA RTX A5000 (24 GB VRAM), 16 GB RAM del sistema, Python 3.10 (entorno académico) | Especificaciones utilizadas en el entrenamiento del modelo. Se establecen como requisitos mínimos recomendados para cualquier reentrenamiento futuro del modelo.                                         |
| Anotación de datos                       | Roboflow                                                                                  | Plataforma web que facilita la anotación colaborativa en formato compatible con Ultralytics YOLO.                                                                                                        |
| Registro de eventos                      | Archivo JSON (almacenamiento local del dispositivo)                                       | Formato ligero y legible para persistir metadatos de alertas (timestamp, clase, confianza) sin dependencias externas ni bases de datos adicionales.                                                      |


### 8.2. Componentes

#### 8.2.1. Módulo de Captura e Inferencia Local (App Móvil) - Implementado

La aplicación móvil fue desarrollada con Flutter, lo que permite su ejecución en distintas plataformas desde una única base de código. Accede a la cámara del dispositivo mediante los plugins de Flutter correspondientes y captura frames de video de forma continua. Cada frame es pasado directamente, en memoria, al motor de inferencia local sin ninguna transmisión de red.

El modelo YOLOv12m, exportado desde Ultralytics al formato compatible con el entorno de inferencia móvil y almacenado en el archivo `best.pt`, es cargado una única vez al iniciar la aplicación y permanece en memoria durante toda la sesión de monitoreo. La inferencia se ejecuta sobre cada frame capturado directamente en el dispositivo.

Decisión técnica relevante: se eliminó la dependencia de un servidor externo. El procesamiento completamente local simplifica el despliegue, elimina la latencia de red y hace el sistema operativo en cualquier condición de conectividad.

#### 8.2.2. Módulo de Análisis de Riesgo - Implementado

El módulo de análisis de riesgo evalúa la salida del motor de inferencia local. Determina si alguna detección de la clase *Drowning* supera el umbral de confianza configurado y si dicha detección persiste durante un número mínimo de frames consecutivos definido por parámetro.

Decisión técnica relevante: el umbral de confianza predeterminado para emisión de alerta se estableció en 0.5, con una ventana temporal de 3 frames consecutivos con detección de riesgo antes de activar la alerta. Estos valores son configurables desde la interfaz de la aplicación sin reentrenar el modelo (RF-05).

#### 8.2.3. Dataset y Entrenamiento - Implementado

El dataset de entrenamiento se construyó en dos etapas:

**Etapa 1 - Dataset público:** se utilizó el *Swimming and Drowning Detection Dataset* disponible en Roboflow, etiquetado con las tres clases de interés (*Swimming*, *Drowning*, *Person out of water*). Este dataset provee variedad de escenarios acuáticos pero no representa específicamente las condiciones de la piscina de la Universidad del Norte.

**Etapa 2 - Dataset propio:** se recolectaron imágenes en la piscina semiolímpica de la Universidad del Norte durante sesiones supervisadas con voluntarios que simularon comportamientos normales y de riesgo bajo protocolos controlados. Estas imágenes fueron anotadas manualmente en Roboflow.

> **Figura 1. Sesión de recolección de datos en la piscina semiolímpica de la Universidad del Norte. Voluntarios simulando comportamientos de natación normal y de riesgo bajo supervisión del equipo.**

Sobre aproximadamente el 66.5 % de las imágenes del dataset propio se aplicó preprocesamiento por tiling 2×2, generando cuatro sub-imágenes por imagen original, con el objetivo de incrementar la densidad de instancias y mejorar la sensibilidad del modelo ante nadadores a mayor distancia de la cámara.

El entrenamiento se realizó en dos etapas:

- **Etapa 1:** fine-tuning del modelo YOLOv12m preentrenado en COCO sobre el dataset público optimizado.
- **Etapa 2:** fine-tuning del modelo resultante de la Etapa 1 sobre el dataset combinado (público + institucional), usando exclusivamente datos institucionales para validación.

**Entorno de entrenamiento y requisitos mínimos para reentrenamiento futuro**

El entrenamiento se ejecutó en una estación de trabajo con la siguiente configuración de hardware, que constituye la **especificación mínima recomendada** para cualquier reentrenamiento futuro del modelo:


| Componente      | Especificación utilizada                        | Justificación                                                                                                                                                                                                  |
| --------------- | ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GPU             | NVIDIA RTX A5000 (24 GB VRAM)                   | YOLOv12m con tamaño de imagen 1280 px requiere ≥ 10 GB de VRAM para un batch size operativo. La RTX A5000 permite batches suficientemente grandes para convergencia estable sin gradient accumulation forzada. |
| RAM del sistema | 16 GB                                           | Necesario para la carga simultánea del dataset en memoria durante el preprocesamiento y el pipeline de entrenamiento de Ultralytics.                                                                           |
| Almacenamiento  | SSD con ≥ 20 GB libres                          | Para la escritura de checkpoints, logs y resultados intermedios de ambas etapas de entrenamiento.                                                                                                              |
| SO / Runtime    | Linux (Ubuntu) o macOS, Python 3.10, CUDA 11.8+ | Requerido por PyTorch y el framework Ultralytics en su versión compatible con YOLOv12.                                                                                                                         |


#### 8.2.4. Módulo de Alertas - Implementado

El módulo de alertas opera completamente en el dispositivo: cuando el módulo de análisis de riesgo determina que existe una situación de riesgo sostenida, la aplicación activa simultáneamente una señal sonora (buzzer) audible en el área de la piscina y una alerta visual prominente en la pantalla del dispositivo. La combinación de ambos canales garantiza que el salvavidas sea notificado incluso en condiciones de ruido ambiental elevado. Al no depender de ninguna respuesta externa, la latencia de la alerta es mínima y predecible.

### 8.3. Integraciones


| Integración                                        | Estado     | Descripción                                                                                                                                                                      |
| -------------------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| App Móvil ↔ Modelo YOLOv12m local (`best.pt`)      | Operativa  | La aplicación carga el modelo al iniciar y ejecuta inferencias en el dispositivo sobre cada frame capturado. No requiere red.                                                    |
| App Móvil ↔ Cámara del dispositivo                 | Operativa  | Los plugins de Flutter acceden a la cámara del dispositivo y entregan frames al módulo de inferencia en memoria.                                                                 |
| App Móvil ↔ Registro local de eventos (JSON)       | Operativa  | La aplicación escribe un archivo JSON en el almacenamiento interno del dispositivo con una entrada por evento de alerta (timestamp, clase, confianza). No se almacenan imágenes. |
| Roboflow ↔ Pipeline de entrenamiento (Ultralytics) | Finalizada | El dataset fue exportado desde Roboflow en formato YOLO y utilizado en el entrenamiento con Ultralytics. El modelo resultante fue exportado al formato de inferencia móvil.      |


---

## 9. Despliegue y Operación

### Requisitos de infraestructura

- **Dispositivo móvil:** compatible con Flutter (iOS o Android), cámara trasera de resolución mínima 720p. El dispositivo debe estar conectado a la corriente eléctrica (cargador) durante toda la sesión de uso debido a que la ejecución continua del modelo de inferencia local genera una carga computacional y térmica sostenida que agota la batería en menos de 120 minutos en la mayoría de los dispositivos de gama media y puede provocar limitaciones de rendimiento por temperatura (*thermal throttling*). El uso del cargador garantiza estabilidad de frecuencia de CPU/GPU y latencia constante a lo largo de la sesión.  
- **Toma de corriente próxima:** se requiere una toma de corriente eléctrica accesible en el área de posicionamiento del dispositivo (borde de piscina o soporte elevado).  
- **Archivo de modelo:** `best.pt` exportado al formato de inferencia móvil, instalado en el almacenamiento interno de la aplicación antes del despliegue.

### Puesta en marcha

1. Instalar la aplicación Flutter compilada en el dispositivo.
2. Verificar que el archivo `best.pt` (o su equivalente exportado) esté incluido en los assets de la aplicación.
3. Abrir la aplicación e iniciar la sesión de monitoreo desde la pantalla principal.
4. El sistema carga el modelo en memoria, activa la cámara y comienza el monitoreo de forma automática.

### Condiciones de operación

- El dispositivo debe posicionarse en un soporte fijo en posición elevada de modo que la cámara abarque la superficie descrita de la piscina (todos los carriles en uso). La posición recomendada es una posición central elevada que minimice oclusiones entre carriles. Desde esta posición el campo visual cubre la mayor parte del espejo de agua sin puntos ciegos en los carriles monitoreados. No se requieren cámaras adicionales para cubrir el área completa en la configuración de referencia.  
- Los parámetros de umbral de confianza y ventana temporal pueden ajustarse desde la aplicación sin reentrenar el modelo (RNF-05).  
- El sistema no almacena imágenes ni video de los usuarios; los frames son procesados en memoria y descartados tras la inferencia en cumplimiento de RNF-04 y del principio de tratamiento anónimo de los nadadores.

---

## 10. Validación

### 10.1. Pruebas por Componentes

**Módulo de captura**

Se verificó la correcta adquisición de frames desde la cámara del dispositivo mediante los plugins de Flutter. Se midió la tasa efectiva de frames capturados y la estabilidad del pipeline de captura durante sesiones de 30 minutos. **Resultado:** el módulo opera de forma continua sin pérdida de frames significativa. La tasa de captura se mantiene estable en las condiciones de uso previstas.

**Módulo de inferencia local**

Se evaluó la carga del modelo `best.pt` en el dispositivo, la consistencia de las predicciones y el tiempo de inferencia por frame sobre una muestra de imágenes del dataset institucional. **Resultado:** el modelo se carga correctamente al iniciar la aplicación y permanece en memoria durante toda la sesión. Las predicciones son consistentes entre ejecuciones sucesivas sobre el mismo frame. El tiempo de inferencia por frame en el dispositivo es compatible con el umbral de latencia total establecido en RNF-01.

**Módulo de análisis de riesgo y alertas**

Se verificó el comportamiento del módulo con secuencias sintéticas de detecciones de prueba que cubren los casos: detección de riesgo puntual (sin alerta esperada), detección de riesgo sostenida (alerta esperada) y detección de nado normal (sin alerta). **Resultado:** el módulo responde correctamente en todos los casos de prueba para los valores de umbral y ventana temporal configurados.

### 10.2. Pruebas de Integración

Las pruebas de integración se realizaron en la piscina semiolímpica de la Universidad del Norte en sesiones con voluntarios previamente informados y bajo supervisión del equipo de investigación y del personal de la instalación. Se ejecutaron un total de **ocho escenarios** con personas reales en el agua, abarcando condiciones de iluminación, número de nadadores y tipos de comportamiento variados.

**Configuración de las pruebas:**

- Dispositivo: smartphone Android con cámara trasera 1080p, conectado a la corriente, posicionado en soporte elevado en uno de los extremos de la piscina cubriendo 5 carriles.
- Número de voluntarios: hasta 4 personas en agua simultáneamente.
- Sesiones realizadas: 3 sesiones de 30–45 minutos cada una en diferentes franjas horarias (mañana con luz natural predominante, tarde con mezcla de luz natural y artificial, noche con iluminación artificial exclusiva).


| Escenario | Descripción                                                                                      | # Voluntarios          | Resultado esperado                                                                         | Resultado observado                                                                                                                                                                        |
| --------- | ------------------------------------------------------------------------------------------------ | ---------------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| E-01      | Nado normal continuo de un voluntario durante 2 minutos en carril central.                       | 1                      | Sin alerta generada.                                                                       | Sin alerta. Correcto.                                                                                                                                                                      |
| E-02      | Simulación de inmovilidad total en posición vertical sostenida (> 5 s).                          | 1                      | Alerta generada en ≤ 10 s.                                                                 | Alerta generada. Latencia total medida: 4–7 s desde inicio del evento.                                                                                                                     |
| E-03      | Múltiples nadadores simultáneos: 3 nadan normalmente, 1 simula riesgo.                           | 4                      | Detección individual por nadador; alerta solo ante el sujeto de riesgo.                    | Detecciones independientes correctas. Alerta emitida únicamente ante el voluntario simulando riesgo. Los demás nadadores clasificados como *Swimming*.                                     |
| E-04      | Variación de iluminación: transición de luz natural a artificial (tarde/noche).                  | 2                      | Sistema continúa operando sin interrupciones.                                              | Operación continua. Ligera reducción transitoria de confianza de predicción durante la transición (confianza media bajó de 0.82 a 0.71 durante ~30 s), sin falsa negativa ni falsa alarma. |
| E-05      | Simulación de riesgo en el carril más alejado de la cámara (máxima distancia).                   | 1                      | Alerta generada en ≤ 10 s.                                                                 | Alerta generada, con confianza de predicción más baja (0.56–0.62) respecto a carriles cercanos (0.78–0.85), dentro del umbral configurado.                                                 |
| E-06      | Nado activo con agitación intensa de la superficie (estilo crol rápido).                         | 2                      | Sin alerta generada (agitación pero nado normal).                                          | Sin alerta. El modelo distinguió correctamente entre agitación de nado normal y postura de riesgo.                                                                                         |
| E-07      | Persona parada en el borde de la piscina fuera del agua durante la sesión.                       | 2 (1 en agua, 1 fuera) | Clasificación *Person out of water* para la persona en borde; *Swimming* para la que nada. | Clasificaciones correctas en ambos casos. Sin alerta.                                                                                                                                      |
| E-08      | Sesión nocturna con iluminación artificial exclusiva, 3 nadadores normales y 1 simulando riesgo. | 4                      | Alerta generada en ≤ 10 s para el sujeto de riesgo; sin alerta para los demás.             | Alerta generada correctamente. Latencia medida: 6–9 s. Confianza de predicción ligeramente inferior a la sesión diurna (0.65–0.72), dentro del umbral.                                     |


**Flujo completo verificado:** el sistema opera de forma completamente local y continua durante todas las sesiones de prueba (≥ 30 minutos cada una), sin interrupciones por conectividad ni por agotamiento de recursos. En todas las sesiones con dispositivo conectado a la corriente, no se observó degradación de rendimiento por temperatura. Se cumple el criterio de aceptación de estabilidad operativa (CA-06).

### 10.3. Pruebas de Usabilidad

Se realizaron pruebas de usabilidad con el personal de apoyo de la piscina para evaluar la claridad de las alertas y la utilidad percibida del sistema.

**Hallazgos principales:**

- La señal sonora del dispositivo es perceptible y distinguible en el ambiente de la piscina.  
- La alerta visual en pantalla complementa el sonido y es claramente identificable en la interfaz de la aplicación.  
- El tiempo de respuesta del sistema es considerado aceptable por el personal de vigilancia consultado.  
- Se identificó como mejora futura la conveniencia de una alerta visual complementaria (luz o pantalla) para entornos con niveles de ruido ambiental elevado.

**Nivel de cumplimiento:** el sistema es percibido como una herramienta útil de apoyo, con la condición de que el salvavidas comprenda que se trata de un sistema de soporte y no de reemplazo de la supervisión humana.

---

## 11. Resultados y Discusión

### 11.1. Resultados del Modelo de Detección

El entrenamiento se realizó en dos etapas. La primera etapa consistió en fine-tuning sobre el dataset público optimizado (*splash_optimized*). Los resultados del mejor modelo obtenido en esta etapa, evaluado sobre el conjunto de prueba, son los siguientes:

Resultados del modelo - Etapa 1 (dataset público)

*Figura 1. Métricas del modelo entrenado en la Etapa 1 (dataset público), evaluado sobre el conjunto de prueba. Imagen de tamaño de entrada 1280 px.*


| Métrica   | Valor  |
| --------- | ------ |
| mAP@50    | 0.8386 |
| mAP@50-95 | 0.4480 |
| Precision | 0.8703 |
| Recall    | 0.7757 |


Resultados por clase:


| Clase               | Precision | Recall | mAP@50-95 |
| ------------------- | --------- | ------ | --------- |
| Drowning            | 0.801     | 0.842  | 0.458     |
| Person out of water | 0.941     | 0.675  | 0.420     |
| Swimming            | 0.869     | 0.809  | 0.466     |


La segunda etapa incorporó el dataset institucional (imágenes propias de la piscina de la Universidad del Norte) para el fine-tuning del modelo de la Etapa 1. La validación de esta etapa se realizó exclusivamente sobre datos institucionales. Los resultados del modelo final son los siguientes:

Resultados del modelo final (dataset institucional)

![Val_pred](https://i.imgur.com/vzu7gl3.jpeg)

*Figura 2. Métricas del modelo final, evaluado sobre el conjunto de validación institucional (1478 imágenes, 2748 instancias).*


| Métrica           | Valor |
| ----------------- | ----- |
| mAP@50            | 0.879 |
| mAP@50-95         | 0.530 |
| Precision (Box P) | 0.856 |
| Recall (R)        | 0.825 |


### 11.2. Discusión

**Cumplimiento de criterios de aceptación:**


| Criterio                                 | Umbral | Resultado        | ¿Cumple? |
| ---------------------------------------- | ------ | ---------------- | -------- |
| Recall ≥ 70 %                            | 70 %   | 82.5 %           | Sí       |
| Precision ≥ 60 %                         | 60 %   | 85.6 %           | Sí       |
| Latencia total ≤ 10 s                    | 10 s   | < 10 s           | Sí       |
| Prototipo funcional de extremo a extremo | -      | Verificado       | Sí       |
| Estabilidad operativa ≥ 30 min           | 30 min | Verificado       | Sí       |
| Validación en entorno controlado         | -      | Piscina Uninorte | Sí       |


**Análisis por clase:**

La clase *Drowning* presenta un recall de 0.842 en la Etapa 1 y 0.825 en la evaluación final, superando el umbral mínimo del 70 %. Esto es especialmente relevante dado que en el contexto de seguridad acuática, una falsa negativa (evento de ahogamiento no detectado) tiene consecuencias más graves que una falsa positiva. El modelo alcanza un equilibrio adecuado entre sensibilidad y especificidad para el propósito del sistema.

La clase *Person out of water* muestra el recall más bajo (0.675 en Etapa 1), lo que es esperable dado que esta clase requiere distinguir a una persona completamente fuera del agua, una situación cuya frecuencia en el dataset es menor. No obstante, esta clase no es la de mayor criticidad para el objetivo de detección de ahogamiento.

La mejora en mAP@50 entre la Etapa 1 (0.8386) y el modelo final validado sobre datos institucionales (0.879) evidencia el beneficio del fine-tuning con datos propios de la piscina objetivo. El modelo generaliza mejor al entorno específico después de haber sido expuesto a imágenes representativas de las condiciones reales de iluminación, ángulo de cámara y composición visual de la piscina universitaria.

**Limitaciones identificadas:**

- El dataset está basado exclusivamente en simulaciones controladas de ahogamiento: no se dispone de grabaciones de ahogamientos reales por razones éticas, lo que puede introducir diferencias visuales respecto a situaciones reales no entrenadas (p. ej., pánico extremo, ropa inusual, posiciones atípicas).  
- El dataset propio es de tamaño limitado, lo que restringe la variabilidad de escenarios cubiertos.  
- Las pruebas se realizaron bajo condiciones controladas; el desempeño en condiciones de alta ocupación simultánea con muchos nadadores puede diferir.  
- La calidad de la detección en condiciones de iluminación cambiante (transición luz natural/artificial) presenta ligeras reducciones de confianza que podrían aumentar la latencia de detección en estos momentos.

**Comparación con el estado del arte:**

Los resultados del sistema SafeSplash (mAP@50 de 0.879) son comparables con los reportados en trabajos recientes de la literatura (YOLO11-LiB: DmAP50 del 94.1 % en su clase objetivo; Alharbi et al. con YOLOv8: > 98 % en condiciones controladas). La diferencia en los valores más altos de la literatura se explica principalmente por las restricciones de tamaño del dataset propio y las condiciones reales, no ideales, del entorno de evaluación. El sistema supera ampliamente los criterios de aceptación iniciales definidos para el proyecto.

---

## 12. Referencias

[1] World Health Organization: WHO, "Ahogamientos," Dec. 13, 2024. [https://www.who.int/es/news-room/fact-sheets/detail/drowning](https://www.who.int/es/news-room/fact-sheets/detail/drowning)

[2] World Drowning Prevention Day 2022. [https://www.who.int/campaigns/world-drowning-prevention-day/2022](https://www.who.int/campaigns/world-drowning-prevention-day/2022)

[3] C. D. Wickens, J. G. Hollands, S. Banbury y R. Parasuraman, *Engineering Psychology and Human Performance*, 4th ed. Upper Saddle River, NJ: Pearson, 2013.

[4] J. Redmon, S. Divvala, R. Girshick y A. Farhadi, "You only look once: Unified, real-time object detection," in *Proc. IEEE Conf. Computer Vision and Pattern Recognition (CVPR)*, 2016, pp. 779–788.

[5] J. S. Warm, R. Parasuraman y G. Matthews, "Vigilance requires hard mental work and is stressful," *Human Factors*, vol. 50, no. 3, pp. 433–441, 2008.

[6] Ultralytics, "YOLOv12: You Only Look Once, version 12," 2025. [https://github.com/ultralytics/ultralytics](https://github.com/ultralytics/ultralytics)

[7] M. Shatnawi, A. Al-Bdour, Q. Al-Zoubi y M. Tarawneh, "Deep Learning and Vision-Based Early Drowning Detection," *Information*, vol. 14, no. 7, p. 388, 2023.

[8] N. Alharbi, A. Al-Shareeda, S. Al-Shareeda y otros, "Improved Automatic Drowning Detection Approach with YOLOv8," *IEEE Access*, 2024.

[9] X. Jiang y otros, "Swimming-YOLO: A multi-swimmer detection algorithm for pool surveillance," 2025.

[10] Y. Liu y otros, "Two-stage drowning detection from underwater surveillance cameras using YOLOv5n and deep Gaussian detection network," *Expert Systems with Applications*, 2023.

[11] Z. He y otros, "Automatic infant drowning detection from surveillance video using YOLOv5 and Faster R-CNN," 2023.

[12] S. Pradhan y otros, "AI and IoT-based drowning prevention strategy in swimming pools," *Internet of Things*, 2024.

[13] T. Meng y otros, "High-performance infant drowning detection system using deep learning," 2023.

[14] D. Szpilman, J. J. L. M. Bierens, A. J. Handley y J. P. Orlowski, "Drowning," *New England Journal of Medicine*, vol. 366, no. 22, pp. 2102–2110, 2012. DOI: 10.1056/NEJMra1013317

[15] F. Pia, "Observations on the drowning of nonswimmers," *Journal of Physical Education*, vol. 71, no. 6, pp. 164–167, 1974.

[16] S. J. Pan y Q. Yang, "A survey on transfer learning," *IEEE Trans. Knowledge Data Eng.*, vol. 22, no. 10, pp. 1345–1359, 2010. DOI: 10.1109/TKDE.2009.191

[17] F. C. Akyon, S. O. Altinuc y A. Temizel, "Slicing aided hyper inference and fine-tuning for small object detection," in *Proc. IEEE Int. Conf. Image Processing (ICIP)*, 2022, pp. 966–970. arXiv:2202.06934

[18] I. Goodfellow, Y. Bengio y A. Courville, *Deep Learning*. Cambridge, MA: MIT Press, 2016. [http://www.deeplearningbook.org](http://www.deeplearningbook.org)

[19] J. Liu, M. P. Philipsen y T. B. Moeslund, "Supervised versus self-supervised assistant for surveillance of harbor fronts," in *Proc. 16th Int. Joint Conf. Computer Vision, Imaging and Computer Graphics Theory and Applications (VISAPP)*, 2021, pp. 610–617. DOI: 10.5220/0010323906100617

[20] R. Yang, K. Wang y L. Yang, "An improved YOLOv5 algorithm for drowning detection in the indoor swimming pool," *Appl. Sci.*, vol. 14, no. 1, p. 200, 2024. DOI: 10.3390/app14010200

[21] Q. Gao y J. Pan, "Design of drowning detection method based on YOLOv8," in *Proc. IEEE 6th Int. Conf. Civil Aviation Safety and Information Technology (ICCASIT)*, 2024.

[22] E. Huang, "H2OSaver: High-efficiency drowning target detection system," repositorio GitHub, 2025. Disponible en: [https://github.com/esonhjz/H20Saver/](https://github.com/esonhjz/H20Saver/)

---

## ANEXOS

### Anexo A. Diagrama de secuencia PlantUML

### Anexo B. Evidencia fotográfica de la sesión de recolección de datos

> **Figura A1. Sesión de recolección de datos en la piscina semiolímpica de la Universidad del Norte. El equipo capturó imágenes de voluntarios simulando estados de natación normal y situaciones de riesgo bajo protocolos supervisados, utilizadas para construir el dataset institucional de entrenamiento.**

### Anexo C. Criterios de aceptación - tabla de verificación


| ID    | Criterio                                            | Umbral          | Resultado medido       | Estado   |
| ----- | --------------------------------------------------- | --------------- | ---------------------- | -------- |
| CA-01 | Recall (detección de riesgo)                        | ≥ 70 %          | 82.5 %                 | Cumplido |
| CA-02 | Precision                                           | ≥ 60 %          | 85.6 %                 | Cumplido |
| CA-03 | Latencia de respuesta                               | ≤ 10 s          | < 10 s                 | Cumplido |
| CA-04 | Prototipo funcional extremo a extremo               | Flujo completo  | Verificado             | Cumplido |
| CA-05 | Operación bajo hardware académico                   | GPU laboratorio | GPU NVIDIA laboratorio | Cumplido |
| CA-06 | Estabilidad operativa ≥ 30 min                      | 30 min          | Verificado             | Cumplido |
| CA-07 | Validación en entorno controlado (piscina Uninorte) | Pruebas reales  | Realizadas             | Cumplido |


