# Cronograma del Prototipo

El desarrollo del proyecto se organiza a lo largo de 16 semanas, estructuradas en fases que abarcan desde la exploración inicial del problema hasta la implementación, validación y entrega del prototipo funcional del sistema de detección de riesgo de ahogamiento basado en visión por computador.

## Fase 1: Exploración y definición del problema (Semanas 1–3)

### 1.1 Semana 1
1.1.1 Exploración de posibles temas de proyecto.  
1.1.2 Revisión inicial de problemas donde aplicar técnicas de visión por computador.  
1.1.3 Identificación de áreas potenciales de aplicación.  

### 1.2 Semana 2
1.2.1 Selección inicial de un proyecto candidato.  
1.2.2 Evaluación de la viabilidad técnica del enfoque propuesto.  
1.2.3 Identificación de dificultades técnicas que impiden continuar con la primera idea seleccionada.  

### 1.3 Semana 3
1.3.1 Cambio de enfoque del proyecto tras los problemas identificados.  
1.3.2 Selección definitiva del proyecto: sistema de detección de riesgo de ahogamiento en piscina mediante visión por computador.  
1.3.3 Definición preliminar del problema y del alcance del sistema.  

## Fase 2: Diseño conceptual del sistema (Semanas 4–7)

### 2.1 Semana 4
2.1.1 Revisión del estado del arte sobre detección de ahogamiento mediante visión por computador.  
2.1.2 Análisis de modelos de aprendizaje profundo aplicables al problema.  
2.1.3 Evaluación de arquitecturas de detección en tiempo real.  

### 2.2 Semana 5
2.2.1 Selección del modelo base de detección: YOLO.  
2.2.2 Definición del enfoque de captura de video en la piscina.  
2.2.3 Discusión de posibles configuraciones de cámara (posición, número de cámaras, perspectiva).  

### 2.3 Semana 6
2.3.1 Definición de la arquitectura general del sistema.  
2.3.2 Definición del uso de una cámara de celular para captura de video.  
2.3.3 Definición de una aplicación móvil para transmisión de imágenes al servidor.  
2.3.4 Definición del servidor para procesamiento e inferencia del modelo.  
2.3.5 Búsqueda y evaluación de datasets disponibles para entrenamiento.  

### 2.4 Semana 7
2.4.1 Selección de dataset público para entrenamiento inicial.  
2.4.2 Entrenamiento preliminar del modelo YOLO utilizando un modelo disponible en GitHub.  
2.4.3 Entrenamiento limitado por infraestructura a 30 epochs.  
2.4.4 Obtención de resultados preliminares con aproximadamente 87% de accuracy para la clase *drowning*.  
2.4.5 Definición de las clases del modelo: drowning, swimming y out of water.  
2.4.6 Planificación del entrenamiento extendido del modelo.  

## Fase 3: Construcción del modelo base (Semanas 8–9)

### 3.1 Semana 8
3.1.1 Entrenamiento extendido del modelo utilizando los equipos del laboratorio de Ingeniería de Sistemas.  
3.1.2 Entrenamiento entre 80 y 100 epochs para mejorar el desempeño del modelo.  
3.1.3 Recolección de muestras de datos en la piscina donde se aplicará el proyecto.  
3.1.4 Evaluación preliminar del modelo con datos reales.  

### 3.2 Semana 9
3.2.1 Limpieza y anotación de los datos recolectados en la piscina.  
3.2.2 Proceso de *fine-tuning* del modelo utilizando datos propios del entorno real.  
3.2.3 Evaluación del desempeño del modelo mediante métricas como precisión, recall y F1-score.  
3.2.4 Obtención de la primera versión estable del modelo entrenado.  

## Fase 4: Integración del sistema (Semanas 10–12)

### 4.1 Semana 10
4.1.1 Desarrollo del pipeline de procesamiento en el servidor.  
4.1.2 Implementación de la recepción de video.  
4.1.3 Implementación de la extracción de fotogramas.  
4.1.4 Implementación de la inferencia utilizando el modelo YOLO.  
4.1.5 Pruebas iniciales utilizando video pregrabado.  

### 4.2 Semana 11
4.2.1 Desarrollo del módulo de transmisión desde el dispositivo móvil.  
4.2.2 Implementación de la comunicación entre el dispositivo móvil y el servidor de procesamiento.  
4.2.3 Integración inicial del sistema completo: captura de video, transmisión e inferencia del modelo.  

### 4.3 Semana 12
4.3.1 Implementación de lógica temporal para reducir falsos positivos.  
4.3.2 Desarrollo del sistema de generación de alertas.  
4.3.3 Pruebas de funcionamiento del prototipo en condiciones controladas.  

## Fase 5: Validación experimental (Semanas 13–14)

### 5.1 Semana 13
5.1.1 Instalación del sistema en la piscina de prueba.  
5.1.2 Ejecución de pruebas con voluntarios en condiciones controladas.  
5.1.3 Simulación de escenarios de nado normal.  
5.1.4 Simulación de reposo en el agua.  
5.1.5 Simulación de situaciones de riesgo.  

### 5.2 Semana 14
5.2.1 Análisis de resultados obtenidos durante las pruebas.  
5.2.2 Identificación de errores del modelo (falsos positivos y falsos negativos).  
5.2.3 Ajuste de parámetros del modelo y de la lógica de decisión.  

## Fase 6: Evaluación final (Semana 15)

### 6.1 Semana 15
6.1.1 Evaluación final del desempeño del sistema.  
6.1.2 Medición de métricas finales de precisión.  
6.1.3 Medición de métricas finales de recall.  
6.1.4 Cálculo del F1-score.  
6.1.5 Medición de la latencia del sistema.  
6.1.6 Análisis y documentación de los resultados experimentales.  

## Fase 7: Documentación y entrega (Semana 16)

### 7.1 Semana 16
7.1.1 Redacción final del informe del proyecto.  
7.1.2 Preparación de la presentación de sustentación.  
7.1.3 Entrega del prototipo funcional del sistema.  
