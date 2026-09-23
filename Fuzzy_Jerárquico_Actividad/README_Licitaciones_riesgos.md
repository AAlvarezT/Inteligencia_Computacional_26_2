# Sistema fuzzy jerárquico para alertas de riesgo en licitaciones

## Propósito y alcance

El script `Licitaciones_riesgos.m` combina señales de **proveedor**, **proceso** y **aspectos económicos** mediante tres sistemas Mamdani. Sus salidas (`IF_proveedor`, `IF_proceso`, `IF_economico`) alimentan un cuarto sistema (`ExpertoRiesgos`) que devuelve `riesgoFraude` en una escala de 0 a 10. **El resultado es una prioridad de revisión, no una probabilidad calibrada ni una conclusión de que ocurrió fraude.**

Este README documenta la lógica propuesta en el código discutido. Las publicaciones sustentan que ciertas observaciones son señales de alerta; **no prescriben las funciones de pertenencia, pesos, interacciones ni umbrales numéricos elegidos aquí**. Estos últimos son hipótesis del prototipo que requieren validación.

## Entradas y sentido de la escala

Todas las entradas deben estar entre 0 y 10: un valor mayor representa una señal **más intensa o mejor corroborada**, nunca simplemente más cantidad de un dato crudo. En las tres funciones de pertenencia actuales, `Bajo` usa `[0 0 2 4]`, `Medio` usa `[2 5 8]` y `Alto` usa `[6 8 10 10]`; hay solapamiento entre categorías.

| Variable | Significado que se debe operacionalizar | Respaldo y alcance |
| --- | --- | --- |
| `vinculoPEPR3` | Intensidad y pertinencia de un vínculo comprobado con una persona políticamente expuesta o con quien decide la contratación. Precisar qué significa «R3» en el proyecto. | GAFI indica debida diligencia basada en riesgo y advierte que las señales no deben estigmatizar a todas las PEP [3]. El mero vínculo no equivale a fraude. |
| `sanciones` | Gravedad, vigencia y pertinencia de sanciones **verificadas**, distinguiendo coincidencias de nombres de identidades confirmadas. | Una alerta de cumplimiento es conceptualmente distinta de una conclusión de fraude; la ponderación elevada es una decisión conservadora del modelo, no una magnitud tomada de [1]–[3]. |
| `antiguedadRiesgo` | Poca trayectoria **junto con falta de evidencia verificable** de capacidad o existencia; 10 significa mayor incertidumbre. | El Banco Mundial recomienda verificar existencia, instalaciones y antecedentes de proveedores sospechosos [1]. Ser una empresa nueva, por sí solo, no prueba irregularidad. |
| `desajusteGiroObjeto` | Desajuste entre actividad/capacidad acreditada y objeto contractual, después de considerar subcontratación legítima. | Se relaciona con la verificación de capacidad del postor en [1]; la conversión exacta a 0–10 es una hipótesis local. |
| `coparticipacionRecurrente` | Reaparición de los mismos postores **con patrones anómalos de ofertas**, no solo coincidencia en el mercado. | El Banco Mundial describe patrones coordinados y ofertas de cobertura [1]. |
| `rotacionGanadores` | Alternancia de adjudicaciones entre un grupo de postores, medida respecto de lo esperable por zona, rubro y período. | El Banco Mundial menciona la rotación aparente; la OCDE identifica patrones inusuales de ofertas [1, 2]. |
| `requisitosDireccionados` | Especificaciones injustificadamente estrechas que favorecen a un postor. | El Banco Mundial menciona especificaciones que solo un participante puede satisfacer [1]. |
| `fraccionamiento` | Concentración de contratos pequeños relacionados en tiempo, objeto o adjudicatario, considerando justificaciones legítimas. | El Banco Mundial identifica muchos contratos pequeños como señal que amerita examen [1]. |
| `precioAnomalo` | Desviación **injustificada** frente a una referencia comparable de mercado, costo, calidad y alcance. | El Banco Mundial señala sobreprecios y también ofertas anormalmente bajas como motivos de revisión [1]. La variable debe aclarar cuál de estos fenómenos representa. |

**Antes de puntuar:** documentar fuente, fecha, unidad de observación, reglas de comparación y tratamiento de datos faltantes para cada variable. Un dato no disponible no debe codificarse automáticamente como 0 («sin riesgo»).

## Relaciones de cada subsistema

El código crea una regla para cada combinación de etiquetas (`Bajo`, `Medio`, `Alto`). Dentro de cada regla, las condiciones se unen con `AND`. La función `decidirNivel` asigna su consecuente mediante los siguientes puntajes de diseño. Los valores de esta tabla **no son coeficientes estimados por los documentos**.

### 1. Proveedor

| Entrada | Bajo | Medio | Alto |
| --- | ---: | ---: | ---: |
| Vínculo PEP/R3 | 0 | 1 | 2 |
| Sanciones | 0 | 2 | 5 |
| Riesgo por antigüedad | 0 | 0,5 | 1 |
| Desajuste giro–objeto | 0 | 1 | 2 |

Se suma **1** si el vínculo PEP/R3 es alto y las sanciones son al menos medias; se suma **1** si el riesgo por antigüedad y el desajuste son ambos altos. La intención es que un vínculo PEP aislado suscite examen contextual, mientras que una sanción pertinente y confirmada se priorice. La segunda interacción conecta la incertidumbre sobre la trayectoria con la falta de adecuación al objeto. GAFI respalda la evaluación contextual de PEP [3]; el Banco Mundial respalda las verificaciones de proveedores [1]. **La interacción y su tamaño son decisiones de modelado.**

### 2. Proceso

| Entrada | Bajo | Medio | Alto |
| --- | ---: | ---: | ---: |
| Coparticipación recurrente | 0 | 1 | 2 |
| Rotación de ganadores | 0 | 1 | 2 |
| Requisitos direccionados | 0 | 1 | 2 |

Se suma **2** si coparticipación y rotación son al menos medias; se suma **1** si coparticipación y requisitos direccionados son al menos medios. Esta lógica pone el foco en la **coincidencia de patrones**: que los mismos proveedores participen repetidamente puede ser normal en un mercado pequeño; si además alternan victorias o aparecen requisitos estrechos, la hipótesis de coordinación merece una revisión más cercana. Las señales están documentadas en [1, 2]; los bonos numéricos son hipótesis.

### 3. Económico

| Entrada | Bajo | Medio | Alto |
| --- | ---: | ---: | ---: |
| Fraccionamiento | 0 | 1 | 2 |
| Precio anómalo | 0 | 1 | 3 |

Se suma **2** si ambos son al menos medios. Muchos contratos pequeños pueden responder a necesidades reales y un precio diferente puede reflejar calidad o alcance; la concurrencia de ambos motiva mayor prioridad de examen. El Banco Mundial identifica ambos tipos de alerta [1]. Las puntuaciones concretas son hipótesis.

### 4. Nivel final

| Índice parcial | Bajo | Medio | Alto |
| --- | ---: | ---: | ---: |
| Proveedor | 0 | 1 | 2 |
| Proceso | 0 | 1 | 3 |
| Económico | 0 | 1 | 2 |

Se suma **1** si proceso y economía son al menos medios y **1** si proveedor y proceso son al menos medios. Así se priorizan señales convergentes entre dimensiones. El peso mayor del proceso expresa una preferencia de diseño que debe discutirse con especialistas, no un resultado causal publicado.

En **cada uno** de los cuatro sistemas, un puntaje de regla menor que 2 produce `Bajo`; desde 2 y menor que 5 produce `Medio`; desde 5 produce `Alto`. Estos cortes determinan **las etiquetas consecuentes de las reglas**, no umbrales directos sobre el número final que devuelve `evalfis`. Como las funciones de pertenencia se solapan, varias reglas pueden activarse al mismo tiempo y Mamdani agrega y desfuzifica sus resultados. Por ejemplo, `riesgoFraude = 6,4` no debe interpretarse como «64 % de probabilidad de fraude».

## Ejemplos de razonamiento de reglas

| Contexto | Consecuente esperado de la combinación lingüística | Interpretación |
| --- | --- | --- |
| Proveedor: PEP alto; sanciones, antigüedad y desajuste bajos | `Medio` | El vínculo merece revisión contextual, pero no basta para afirmar fraude alto. |
| Proveedor: sanciones altas; las demás señales bajas | `Alto` | Una sanción alta, confirmada y pertinente se deriva a revisión prioritaria. |
| Proceso: coparticipación y rotación medias; requisitos bajos | `Medio` | La coincidencia aumenta la atención, sin llegar por sí misma al corte alto. |
| Proceso: coparticipación alta, rotación media, requisitos medios | `Alto` | Se combinan un patrón reiterado, alternancia y condiciones potencialmente restrictivas. |
| Económico: precio alto y fraccionamiento bajo | `Medio` | Primero hay que contrastar precio con alcance y calidad. |
| Económico: precio alto y fraccionamiento medio | `Alto` | Ambas señales justifican revisar expediente y comparables. |

Estos ejemplos se refieren a **etiquetas de antecedentes y consecuentes**, no prometen un valor exacto de `evalfis` para una entrada numérica concreta.

## Uso en MATLAB

La función `crearFIS` requiere el cuarto argumento que selecciona la lógica: `"proveedor"`, `"proceso"`, `"economico"` o `"final"`. Por ejemplo:

```matlab
proveedor = crearFIS("Proveedor", ...
    ["vinculoPEPR3", "sanciones", "antiguedadRiesgo", ...
     "desajusteGiroObjeto"], "IF_proveedor", "proveedor");

ifProveedor = evalfis(proveedor, [8 2 7 6]);
ifProceso   = evalfis(proceso, [7 5 8]);
ifEconomico = evalfis(economico, [3 9]);
riesgoFraude = evalfis(experto, [ifProveedor ifProceso ifEconomico]);

fuzzyLogicDesigner(proveedor)  % inspeccionar variables, reglas e inferencia
```

Las tres restantes llamadas a `crearFIS` deben incluir respectivamente `"proceso"`, `"economico"` y `"final"`. El ejemplo presupone que esos tres sistemas ya fueron creados antes de llamar a `evalfis`.

## Qué falta para justificar el modelo empíricamente

1. Definir la medición reproducible de las nueve entradas: población, ventanas temporales, normalización, referencias de mercado y verificación manual de coincidencias PEP/sanciones.
2. Reunir expedientes revisados y etiquetados. Separar alertas infundadas, irregularidades administrativas y casos confirmados, según una definición explícita de resultado.
3. Revisar pesos, interacciones, cortes y funciones de pertenencia con especialistas y datos; medir sensibilidad, falsos positivos y consistencia por sector y tamaño de mercado.
4. Fijar un protocolo de revisión humana y conservar las evidencias que activaron cada alerta.

## Referencias

1. Banco Mundial, Integrity Vice Presidency. *Warning Signs of Fraud and Corruption in Procurement*. https://documents1.worldbank.org/curated/en/223241573576857116/pdf/Warning-Signs-of-Fraud-and-Corruption-in-Procurement.pdf
2. OCDE (2025). *Managing Public Procurement Risks in Greece*, sección «Managing public procurement risks in practice». https://www.oecd.org/en/publications/managing-public-procurement-risks-in-greece_27156f7c-en/full-report/managing-public-procurement-risks-in-practice_af2e5d51.html
3. GAFI/FATF (2013). *Guidance: Politically Exposed Persons (Recommendations 12 and 22)*. https://www.fatf-gafi.org/content/dam/fatf-gafi/guidance/Guidance-PEP-Rec12-22.pdf

Estas fuentes son **guías y documentos institucionales**, no artículos experimentales que hayan validado este FIS concreto.
