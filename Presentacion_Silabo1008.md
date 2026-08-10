Inteligencia Computacional - 2026 2

Talavera comentarios: 
Todos han llevado Data Mining, ML (Según Talavera)
Gestión de proyectos de Ciencia de Datos se va a abrir
Las medidas en la vida real son subaditivas

# Inteligencia Computacional — Apuntes de clase

## 1. Introducción al curso

La **Inteligencia Computacional** estudia técnicas de inteligencia artificial inspiradas en la naturaleza para resolver problemas complejos y apoyar la toma de decisiones en contextos de incertidumbre.

El curso pone énfasis en:

* Diseño de modelos inteligentes.
* Implementación de modelos.
* Análisis crítico de resultados.
* Aplicación a problemas reales de análisis de datos.
* Apoyo a la toma de decisiones.

### Herramientas

* Python
* MATLAB

### Principales enfoques del curso

1. Aprendizaje por refuerzo.
2. Sistemas difusos.
3. Sistemas neuro-difusos y neuroevolutivos.
4. Clustering o agrupamiento no supervisado.

---

# 2. Logro de aprendizaje final

Al terminar el curso se espera poder diseñar e implementar sistemas de inteligencia computacional basados en:

* Aprendizaje por refuerzo.
* Clustering.
* Sistemas de inferencia difusa.

Además, se espera poder analizar críticamente los resultados obtenidos y trabajar de manera colaborativa.

## Competencias generales

* Liderazgo y trabajo colaborativo.
* Pensamiento crítico.
* Aprendizaje continuo.

## Competencias específicas

* Transformación de información digital.
* Innovación y creatividad en el manejo de tecnología.

---

# 3. Estructura del curso

El curso está dividido en cuatro unidades principales.

## Unidad 1 — Aprendizaje por refuerzo

**Semanas 1 a 4**

Se estudia cómo construir agentes inteligentes capaces de aprender a tomar decisiones secuenciales.

## Unidad 2 — Sistemas difusos aplicados

**Semanas 4 a 7**

Se estudian sistemas capaces de trabajar con incertidumbre y ambigüedad mediante lógica difusa.

## Semana 8

Exámenes parciales.

## Unidad 3 — Sistemas neuro-difusos y neuroevolutivos

**Semanas 9 a 11**

Se combinan redes neuronales, lógica difusa y algoritmos evolutivos.

## Unidad 4 — Clustering

**Semanas 12 a 14**

Se estudian técnicas de aprendizaje no supervisado para identificar grupos y patrones en los datos.

## Semana 15

Presentaciones del trabajo final.

## Semana 16

Exámenes finales.

---

# 4. Unidad 1 — Aprendizaje por refuerzo

## Objetivo

Modelar, implementar y evaluar agentes inteligentes capaces de aprender a tomar decisiones secuenciales en entornos con incertidumbre.

Uno de los principales problemas del aprendizaje por refuerzo es encontrar un equilibrio entre:

* **Exploración:** probar acciones nuevas para descubrir mejores alternativas.
* **Explotación:** utilizar las acciones que ya sabemos que funcionan bien.

## Idea general

En aprendizaje por refuerzo existe un **agente** que interactúa con un **entorno**.

El agente realiza una acción y el entorno responde con:

* Un nuevo estado.
* Una recompensa.

De forma simplificada:

```text
Agente
   |
   | Acción
   v
Entorno
   |
   | Estado + recompensa
   v
Agente
```

El agente aprende mediante prueba y error.

Su objetivo es aprender una estrategia de decisiones que permita obtener la mayor recompensa posible.

---

## Diferencia con Machine Learning tradicional

En aprendizaje supervisado normalmente tenemos algo similar a:

```text
Datos X
  |
  v
Modelo
  |
  v
Predicción Y
```

En aprendizaje por refuerzo el aprendizaje ocurre mediante interacción:

```text
Agente
  |
  | Acción
  v
Entorno
  |
  | Recompensa
  | Nuevo estado
  v
Agente
```

Por lo tanto, no necesariamente existe una etiqueta correcta para cada observación.

El agente debe descubrir qué decisiones generan mejores resultados.

---

## Temas de la unidad

### Problema de aprendizaje por refuerzo

Se estudia cómo formular problemas en los que un agente debe tomar decisiones continuamente.

### Métodos de solución

Se analizarán diferentes formas de aprender políticas de decisión.

### Aprendizaje por diferencia temporal

También conocido como:

**Temporal Difference Learning**

Permite actualizar estimaciones a medida que el agente interactúa con el entorno.

---

## Q-Learning

Q-Learning es un algoritmo de aprendizaje por refuerzo utilizado para aprender qué acción tomar en cada estado.

La idea principal es aprender una función:

```text
Q(estado, acción)
```

Esta función representa qué tan conveniente es ejecutar determinada acción cuando el agente se encuentra en un estado específico.

El agente intenta seleccionar las acciones con valores Q altos.

---

## SARSA

SARSA también es un algoritmo basado en valores.

Su nombre proviene de la secuencia:

```text
State
Action
Reward
State
Action
```

A diferencia de otros métodos, actualiza el aprendizaje utilizando la acción que realmente seguirá el agente.

---

## DYNA

También denominado:

**Dynamic Reinforcement Learning**

Combina aprendizaje a partir de experiencias reales con un modelo interno del entorno.

La idea es que el agente pueda:

1. Interactuar con el entorno.
2. Aprender de esas interacciones.
3. Construir un modelo del entorno.
4. Simular experiencias adicionales.
5. Aprender también de esas simulaciones.

---

## Deep Reinforcement Learning

Combina:

```text
Deep Learning
+
Reinforcement Learning
```

Las redes neuronales permiten aproximar funciones complejas cuando el número de estados o acciones es demasiado grande.

---

## Casos de estudio

Durante la unidad se trabajarán casos como:

* Mountain in a Car.
* Dyna Maze World.
* Aplicaciones relacionadas con quimioterapia.

---

# 5. Unidad 2 — Sistemas difusos aplicados

## Objetivo

Diseñar, implementar y evaluar sistemas de inferencia difusa para resolver problemas en los que existe:

* Incertidumbre.
* Ambigüedad.
* Información imprecisa.

Se busca justificar las decisiones considerando:

* Interpretabilidad.
* Robustez.
* Desempeño.

---

# 6. Lógica difusa

La lógica tradicional suele trabajar con valores binarios:

```text
Verdadero = 1
Falso = 0
```

La lógica difusa permite representar grados intermedios de pertenencia.

Por ejemplo:

```text
Temperatura alta = 0.8
```

Esto significa que una temperatura puede pertenecer en cierto grado al concepto de "temperatura alta".

No necesariamente tiene que clasificarse simplemente como:

```text
Alta
o
No alta
```

---

## Sistemas de inferencia difusa

Los sistemas de inferencia difusa utilizan reglas para transformar información de entrada en decisiones.

Ejemplo conceptual:

```text
SI temperatura es alta
Y humedad es alta
ENTONCES riesgo es alto
```

Estas reglas permiten construir sistemas relativamente interpretables.

---

## Temas de la unidad

* Lógica difusa.
* Sistemas de inferencia difusa para la toma de decisiones.
* Medidas difusas.
* Integrales difusas no aditivas.
* Reglas difusas.
* Operadores de agregación.

Las implementaciones pueden realizarse utilizando:

* MATLAB.
* Python.

---

# 7. Unidad 3 — Sistemas neuro-difusos y neuroevolutivos

## Objetivo

Integrar diferentes enfoques de inteligencia computacional:

```text
Redes neuronales
+
Lógica difusa
+
Algoritmos evolutivos
```

El objetivo es resolver problemas complejos considerando tanto desempeño como interpretabilidad.

---

## Idea principal

Estos modelos son considerados sistemas híbridos.

Buscan aprovechar las fortalezas de diferentes métodos.

Por ejemplo:

* Las redes neuronales pueden aprender patrones complejos.
* La lógica difusa permite representar conocimiento mediante reglas.
* Los algoritmos evolutivos pueden optimizar estructuras y parámetros.

---

## ANFIS

ANFIS significa:

**Adaptive Neuro-Fuzzy Inference System**

Es un sistema que combina:

```text
Redes neuronales
+
Sistemas de inferencia difusa
```

La idea es utilizar mecanismos de aprendizaje para ajustar automáticamente un sistema difuso.

---

## Optimización evolutiva de reglas difusas

Los algoritmos evolutivos pueden utilizarse para modificar y mejorar:

* Reglas difusas.
* Parámetros.
* Estructura del sistema.

---

## Aprendizaje adaptativo

El sistema modifica sus parámetros utilizando información obtenida de los datos.

La idea central de esta unidad es permitir que el sistema aprenda:

* La estructura de un sistema difuso.
* Los parámetros de un sistema difuso.

---

# 8. Unidad 4 — Clustering

## Objetivo

Analizar, diseñar e implementar modelos de agrupamiento no supervisado.

Estos métodos permiten:

* Identificar patrones.
* Segmentar datos.
* Encontrar estructuras ocultas.
* Trabajar con espacios multidimensionales.

---

# 9. Aprendizaje no supervisado

En aprendizaje no supervisado no existe necesariamente una variable objetivo conocida.

Por ejemplo:

```text
Datos de clientes
        |
        v
Algoritmo de clustering
        |
        v
Grupo 1
Grupo 2
Grupo 3
```

El algoritmo busca encontrar grupos de observaciones similares.

---

# 10. Self-Organizing Maps — SOM

Los **Self-Organizing Maps** o mapas auto-organizados son una técnica utilizada para representar y agrupar información.

Son particularmente útiles para trabajar con datos multidimensionales.

Permiten transformar información compleja en representaciones más fáciles de visualizar.

---

# 11. Fuzzy C-Means

Fuzzy C-Means es un algoritmo de **soft clustering**.

En clustering tradicional una observación suele pertenecer únicamente a un grupo.

Ejemplo:

```text
Cliente A -> Cluster 1
```

En soft clustering una observación puede pertenecer parcialmente a distintos grupos.

Ejemplo:

```text
Cliente A

Cluster 1 = 70%
Cluster 2 = 25%
Cluster 3 = 5%
```

Por lo tanto, la pertenencia a los grupos no necesariamente es absoluta.

---

## Evaluación del clustering

También se analizarán aspectos como:

* Calidad de los clusters.
* Visualización de grupos.
* Robustez de los resultados.

---

# 12. Mapa general del curso

```text
INTELIGENCIA COMPUTACIONAL
|
|-- Aprendizaje por refuerzo
|      |
|      `-- Aprender qué decisiones tomar
|
|-- Sistemas difusos
|      |
|      `-- Razonar con incertidumbre y ambigüedad
|
|-- Neuro-difusos y neuroevolutivos
|      |
|      `-- Combinar modelos y permitir aprendizaje adaptativo
|
`-- Clustering
       |
       `-- Encontrar grupos y patrones sin etiquetas
```

Una forma simple de recordar los cuatro bloques es:

```text
DECIDIR
   |
   |-- Reinforcement Learning

RAZONAR CON INCERTIDUMBRE
   |
   |-- Fuzzy Logic

COMBINAR + APRENDER
   |
   |-- Neuro-Fuzzy / Neuroevolution

DESCUBRIR PATRONES
   |
   `-- Clustering
```

---

# 13. Evaluación del curso

La nota final se calcula mediante:

```text
NF = 0.25 EP + 0.35 EF + 0.40 TF
```

Donde:

```text
EP = Examen parcial
EF = Examen final
TF = Trabajo final
```

## Pesos

| Evaluación     | Peso |
| -------------- | ---: |
| Examen parcial |  25% |
| Examen final   |  35% |
| Trabajo final  |  40% |

Los exámenes parcial y final son individuales.

---

# 14. Trabajo final

El trabajo final representa el **40% de la nota del curso**.

Incluye:

* Práctica Calificada 1.
* Práctica Calificada 2.
* Informe 1.
* Informe 2.
* Presentación final.

## Componentes

| Componente            | Puntaje | Modalidad  |
| --------------------- | ------: | ---------- |
| Práctica Calificada 1 |    0–10 | Individual |
| Práctica Calificada 2 |    0–10 | Individual |
| Informe 1             |     0–5 | Grupal     |
| Informe 2             |     0–5 | Grupal     |
| Presentación final    |    0–10 | Grupal     |

---

# 15. Factor de pares

El trabajo grupal utiliza un **Factor de Pares (FP)**.

Este factor depende de la contribución de cada integrante al proyecto.

Los integrantes del equipo evalúan la participación de sus compañeros.

Los valores posibles son:

| Desempeño     | Factor |
| ------------- | -----: |
| Sobresaliente |   1.05 |
| Suficiente    |   1.00 |
| Regular       |   0.90 |
| Insuficiente  |   0.80 |

Esto significa que la contribución individual puede modificar la nota obtenida en la parte grupal.

---

# 16. Fechas importantes

## Agosto

* **10 de agosto:** inicio de clases.
* **31 de agosto:** Práctica Calificada 1.

## Septiembre / octubre

* **28 de septiembre al 3 de octubre:** exámenes parciales.
* **8 de octubre:** feriado por Combate de Angamos.
* **21 de octubre:** Práctica Calificada 2.

## Noviembre

* **16 al 21 de noviembre:** presentaciones del trabajo final.
* **21 de noviembre:** último día de clases.
* **23 al 29 de noviembre:** exámenes finales.

---

# 17. Metodología del curso

Las clases combinarán diferentes formas de aprendizaje.

## 1. Exposición del docente

Se construirá primero la base teórica necesaria para entender los modelos.

## 2. Lecturas

Se revisarán:

* Lecturas obligatorias.
* Lecturas complementarias.

## 3. Casos de estudio

Los conceptos serán aplicados en diferentes problemas y situaciones.

## 4. Experiencias reales

Se revisarán experiencias de implementación en:

* Empresas.
* Centros de investigación.

---

# 18. Bibliografía

## Computational Intelligence

Engelbrecht, A. P. (2020).

**Computational Intelligence: An Introduction.**

3.ª edición.

---

## Reinforcement Learning

Sutton, R. & Barto, A. (2018).

**Reinforcement Learning.**

2.ª edición.

---

## Fuzzy Logic

Klir (1995).

**Fuzzy Logic Systems for Engineering: A Tutorial.**

---

## Deep Learning

Goodfellow, I., Bengio, Y. & Courville, A. (2016).

**Deep Learning.**

---

## Clustering

Xu & Wunsch (2009).

**Clustering.**

---

# 19. Semana 1

El primer tema del curso es:

## El problema de aprendizaje por refuerzo

Las primeras implementaciones estarán enfocadas en agentes que aprenden mediante prueba y error.

Para trabajar durante las primeras clases se necesita tener instalado Python.

### Librerías

```python
import numpy as np
import matplotlib.pyplot as plt
```

Es decir:

* NumPy.
* Matplotlib.

---

# 20. Resumen rápido

## Inteligencia Computacional

Busca construir modelos inteligentes capaces de resolver problemas complejos y tomar decisiones en situaciones de incertidumbre.

### Unidad 1 — Reinforcement Learning

```text
Agente + Entorno + Acciones + Recompensas
```

El agente aprende mediante prueba y error.

Principales temas:

* Temporal Difference.
* Q-Learning.
* SARSA.
* DYNA.
* Deep Reinforcement Learning.

### Unidad 2 — Fuzzy Systems

```text
Incertidumbre + grados de pertenencia + reglas
```

Principales temas:

* Lógica difusa.
* Inferencia difusa.
* Reglas.
* Operadores de agregación.
* Integrales difusas.

### Unidad 3 — Sistemas híbridos

```text
Neural Networks
+
Fuzzy Logic
+
Evolutionary Algorithms
```

Principales temas:

* ANFIS.
* Optimización evolutiva.
* Aprendizaje adaptativo.

### Unidad 4 — Clustering

```text
Datos sin etiquetas
        |
        v
Descubrimiento de grupos
```

Principales temas:

* Self-Organizing Maps.
* Fuzzy C-Means.
* Calidad de clusters.
* Visualización.
* Robustez.

---

# 21. Idea central para recordar

```text
Reinforcement Learning
        =
Aprender a decidir

Fuzzy Logic
        =
Razonar con incertidumbre

Neuro-Fuzzy / Neuroevolution
        =
Combinar modelos que aprenden

Clustering
        =
Descubrir patrones sin etiquetas
```
