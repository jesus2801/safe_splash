# cv_olimpic_pool
# RESUMEN 
El incremento en la afluencia de usuarios a la piscina semiolímpica de la Universidad del Norte ha intensificado la necesidad de fortalecer los mecanismos de prevención y detección temprana de situaciones de riesgo en el entorno acuático. Actualmente, la identificación de un posible evento de ahogamiento depende exclusivamente de la supervisión humana, lo que introduce limitaciones asociadas a tiempos de reacción, fatiga operativa y cobertura visual en escenarios de alta ocupación.
El presente proyecto propone el diseño e implementación de un sistema inteligente de detección de riesgo de ahogamiento basado en técnicas de visión por computador y modelos de detección de objetos en tiempo real (YOLO) que emplea una cámara fija estratégicamente ubicada para capturar video de los carriles de la piscina y procesar los frames mediante un modelo entrenado para identificar patrones visuales y comportamentales asociados a posibles situaciones de riesgo. La solución se concibe como un sistema de apoyo a la supervisión humana, cuyo propósito es generar alertas oportunas ante comportamientos anómalos o estados prolongados compatibles con riesgo de ahogamiento, contribuyendo así a reducir el tiempo de respuesta ante emergencias.

# INTRODUCCIÓN
Las muertes por ahogamiento constituyen un problema significativo de salud pública a nivel mundial. Según la Organización Mundial de la Salud (OMS), el ahogamiento es una de las principales causas de muerte accidental en niños y jóvenes, estimándose aproximadamente 236.000 muertes anuales a nivel global. Además, el 92% de las defunciones por ahogamiento se producen en países de ingreso bajo y mediano, lo que evidencia una brecha estructural en prevención y respuesta ante emergencias acuáticas [1], [2]. Donde en 48 de 85 países analizados, el ahogamiento figura entre las cinco principales causas de muerte en población infantil y juvenil [1]. particularmente en contextos recreativos y deportivos.
En instalaciones deportivas universitarias, la vigilancia depende principalmente de la observación directa por parte de salvavidas o personal de apoyo. Sin embargo, estudios en factores humanos han demostrado que la supervisión visual sostenida puede verse afectada por fatiga, oclusiones visuales y limitaciones en el campo de visión [3]. En piscinas semiolímpicas con múltiples carriles activos, estas condiciones pueden dificultar la detección temprana de comportamientos anómalos, es por esto que la reducción efectiva de los ahogamientos y la garantía de la seguridad en las piscinas pueden lograrse mediante la implementación de un sistema de vigilancia automatizado inteligente.
En este contexto, el presente proyecto propone el diseño e implementación de un sistema inteligente basado en visión por computador que permita analizar video en tiempo cercano al real y detectar patrones visuales compatibles con posibles situaciones de riesgo de ahogamiento en la piscina semiolímpica de la Universidad del Norte. La solución se concibe como un sistema de apoyo a la supervisión humana, orientado a reducir el tiempo de respuesta ante eventos críticos y fortalecer los mecanismos de seguridad existentes.
Diversas investigaciones recientes han explorado el uso de visión por computador para la detección de eventos de riesgo en entornos acuáticos, modelando el problema como detección de comportamiento anómalo o análisis temporal de secuencias de video, estos enfoques sugieren que la detección de ahogamiento no puede resolverse únicamente mediante clasificación estática de imágenes, sino que requiere análisis dinámico del movimiento y la postura a lo largo del tiempo. avance en técnicas de visión por computador y aprendizaje profundo ha permitido el desarrollo de sistemas capaces de detectar objetos y patrones complejos en tiempo real, que se ve reflejado en particular, en la implementación de los modelos de la familia YOLO (You Only Look Once) introducidos por Joseph Redmon et al. [4], los cuales han demostrado un desempeño sobresaliente en tareas de detección de objetos en tiempo real, combinando alta precisión con baja latencia computacional.
La principal contribución de este estudio es la propuesta de una técnica innovadora que detecta de forma rápida y automática a las víctimas de ahogamiento basándose en visión por computadora y aprendizaje profundo. Investigamos varios modelos preentrenados para identificar casos de ahogamiento en una piscina. Tras ajustar estos modelos y entrenarlos con nuestro conjunto de datos, todos ellos identificaron con éxito los casos de ahogamiento entre los eventos de natación normales con una precisión de predicción y un nivel de confianza muy altos.

# Planteamiento del Problema
¿Cómo diseñar un sistema de visión por computador que pueda procesar secuencias de video en tiempo cercano al real para detectar patrones visuales compatibles con posibles situaciones de ahogamiento en una piscina semiolímpica universitaria, superando condiciones adversas como iluminación variable y múltiples sujetos simultáneos, y operando con recursos computacionales disponibles en un entorno académico?

# OBJETIVOS
# Objetivo General
El objetivo general de este proyecto es diseñar e implementar un sistema inteligente basado en visión por computador capaz de detectar, en tiempo cercano al real, patrones visuales asociados a posibles situaciones de ahogamiento en la piscina semiolímpica de la Universidad del Norte, con el fin de apoyar la supervisión humana y fortalecer los mecanismos de seguridad.
# Objetivos Específicos
•	Diseñar la arquitectura de software del sistema, incluyendo módulos de captura de video, procesamiento, inferencia y generación de alertas.
•	Seleccionar, adaptar y entrenar un modelo de detección basado en YOLO para el entorno específico de piscina semiolímpica.
•	Definir criterios técnicos de riesgo basados en patrones observables (inmovilidad prolongada, postura anómala, ausencia de desplazamiento, entre otros).
•	Implementar un prototipo funcional capaz de procesar video en tiempo cercano al real bajo restricciones de hardware académico.
•	Evaluar el desempeño del sistema mediante métricas como precisión, recall, matriz de confusión, y latencia de procesamiento.

# ALCANCE
El proyecto contempla el diseño e implementación de un prototipo funcional de un sistema de detección automática de riesgo de ahogamiento mediante visión por computador.
Se incluye dentro del alcance:
•	Instalación y configuración de una cámara fija con la cobertura necesaria de los carriles de la piscina semiolímpica.
•	Captura continua de video para procesamiento computacional.
•	Implementación de un modelo de detección adaptado al entorno acuático.
•	Definición e implementación de reglas de decisión para clasificar comportamientos como potencialmente riesgosos.
•	Generación de alertas digitales ante detección de eventos sospechosos.
•	Evaluación experimental del sistema bajo condiciones controladas.
No se incluye:
•	Diagnóstico médico o evaluación clínica de estados fisiológicos.
•	Sustitución del personal de salvavidas.
•	Integración con sistemas de rescate automatizado.
El alcance se limita a la validación técnica de un prototipo académico bajo restricciones de tiempo, recursos computacionales y disponibilidad de datos.

