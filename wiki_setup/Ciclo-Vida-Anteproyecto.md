# Ciclo de Vida del Anteproyecto

En este documento explico cómo funciona el ciclo de vida de un anteproyecto, desde que el estudiante lo crea hasta que el tutor lo aprueba o rechaza.

> Si necesitas más contexto sobre la arquitectura, echa un vistazo a [Arquitectura del Sistema](01-Arquitectura).

## Índice

1.  ¿Qué es un anteproyecto?
2.  Estados del anteproyecto
3.  Crear un anteproyecto
4.  Enviar para revisión
5.  Revisión por el tutor
6.  Temporalización del anteproyecto
7.  Aprobación y creación de proyecto
8.  Rechazo y solicitud de cambios

---

## 1. ¿Qué es un Anteproyecto?

El anteproyecto es la propuesta inicial que un estudiante tiene que hacer para su TFG. Básicamente, es un documento donde el estudiante explica qué quiere hacer, por qué es interesante y cómo piensa hacerlo.

El tutor tiene que revisar y aprobar el anteproyecto antes de que el estudiante pueda empezar a trabajar en el proyecto real. Si el tutor lo aprueba, el sistema crea automáticamente un proyecto asociado.

---

## 2. Estados del Anteproyecto

Un anteproyecto puede estar en uno de estos estados:

| Estado | Valor en BD | Descripción |
| :--- | :--- | :--- |
| **Borrador** | `draft` | El estudiante lo está creando o editando. Es el estado inicial. |
| **Enviado** | `submitted` | El estudiante lo ha enviado para revisión. No se puede editar. |
| **En Revisión** | `under_review` | El tutor está revisándolo o ha pedido cambios. El estudiante puede editarlo. |
| **Aprobado** | `approved` | El tutor lo ha aprobado. Se crea automáticamente un proyecto. |
| **Rechazado** | `rejected` | El tutor lo ha rechazado. El estudiante tiene que crear uno nuevo. |

El enum en el código está en `frontend/lib/models/anteproject.dart` (líneas 167-188).

---

## 3. Crear un Anteproyecto

### Acceso al formulario

Desde el dashboard, el estudiante puede hacer clic en "Crear Anteproyecto" para abrir el formulario (`AnteprojectForm`).

### Campos del formulario

El formulario tiene estos campos:

- **Título:** El nombre del proyecto.
- **Descripción:** Una explicación detallada de qué va el proyecto (mínimo 200 palabras).
- **Tipo de Proyecto:** Puede ser de ejecución, investigación, bibliográfico o de gestión.
- **Objetivos:** Los objetivos específicos que quiere conseguir.
- **Año Académico:** El año en el que se va a hacer el proyecto.
- **Hitos:** Los resultados esperados con sus fechas.

### Guardar como borrador

Si el estudiante todavía no tiene todo listo, puede guardar el anteproyecto como borrador con el botón "Guardar Borrador". Esto crea el anteproyecto con el estado `draft`:

```dart
final anteproject = Anteproject(
  id: 0,
  title: _titleController.text.trim(),
  description: _descriptionController.text.trim(),
  projectType: _projectType!,
  status: AnteprojectStatus.draft, // Estado borrador
  // ...
);
```

El borrador se guarda en la base de datos y el estudiante puede volver a editarlo más tarde.

### Creación en la base de datos

El servicio `AnteprojectsService` se encarga de crear el anteproyecto en la base de datos (ver `frontend/lib/services/anteprojects_service.dart`, líneas 416-526).

Cuando se crea un anteproyecto, también se crea una relación en la tabla `anteproject_students` para vincular al estudiante con el anteproyecto.

---

## 4. Enviar para Revisión

### Cambio de estado

Cuando el anteproyecto está completo, el estudiante lo envía para que el tutor lo revise. Esto cambia el estado a `submitted`:

```dart
status: AnteprojectStatus.submitted,
submittedAt: DateTime.now(),
```

Una vez enviado, el estudiante **no puede editarlo**. Tiene que esperar a que el tutor lo revise.

### Notificación al tutor

Cuando se envía un anteproyecto, el sistema envía una notificación al tutor para que sepa que tiene un anteproyecto pendiente de revisión.

---

## 5. Revisión por el Tutor

El tutor puede revisar el anteproyecto desde su dashboard o desde la sección "Flujo de Aprobación". Cuando abre un anteproyecto, puede hacer tres cosas:

- **Aprobar:** Si el anteproyecto está bien.
- **Rechazar:** Si el anteproyecto no es viable.
- **Pedir cambios:** Si el anteproyecto necesita mejoras.

En los tres casos, el tutor tiene que dejar comentarios para que el estudiante sepa por qué ha tomado esa decisión.

---

## 6. Temporalización del Anteproyecto

### ¿Qué es la temporalización?

La temporalización es el cronograma de fechas de revisión que el tutor establece para el anteproyecto. Es el plan de cuándo se van a hacer las revisiones del proyecto a lo largo de su desarrollo.

**Importante:** El estudiante **NO crea la temporalización**. Cuando el estudiante crea el anteproyecto, puede definir hitos con fechas estimadas, pero el campo `timeline` del anteproyecto se guarda vacío (`{}`). La temporalización la crea el tutor una vez que el estudiante ha enviado el anteproyecto para revisión.

### ¿Cuándo se crea la temporalización?

La temporalización se crea **después de que el estudiante envía el anteproyecto** (estado `submitted`). El tutor puede acceder a la gestión de temporalización desde la pantalla de revisión del anteproyecto, antes o después de aprobarlo.

### ¿Cómo funciona la creación de la temporalización?

Una vez que el estudiante ha enviado el anteproyecto, el tutor tiene tres formas de crear la temporalización:

#### 1. **Creación Manual**

El tutor puede crear todas las fechas de revisión manualmente desde cero:

1. Accede a la pantalla de gestión de temporalización desde la revisión del anteproyecto.
2. Establece la **fecha de inicio** y la **fecha final** del proyecto.
3. Añade cada fecha de revisión una por una haciendo clic en "Añadir fecha de revisión".
4. Para cada fecha, define:
   - La fecha concreta de la revisión.
   - La descripción de qué se va a revisar en esa fecha.
5. Guarda el cronograma.

Esta opción es útil cuando el tutor quiere tener control total sobre las fechas o cuando los hitos del estudiante no son adecuados para generar fechas automáticamente.

#### 2. **Generación Automática**

El sistema puede generar automáticamente las fechas de revisión basándose en los hitos que el estudiante definió en el anteproyecto:

1. El tutor establece la **fecha de inicio** y la **fecha final** del proyecto.
2. Hace clic en el botón "Generar fechas basadas en hitos".
3. El sistema analiza los hitos definidos por el estudiante.
4. Genera automáticamente fechas de revisión distribuidas a lo largo del período, asociando cada fecha a un hito del anteproyecto.
5. El tutor guarda el cronograma generado.

El método `generateReviewDatesFromMilestones()` del servicio `ScheduleService` se encarga de esta generación automática (ver `frontend/lib/services/schedule_service.dart`).

Esta opción es útil cuando los hitos del estudiante están bien definidos y el tutor quiere ahorrar tiempo.

#### 3. **Modo Mixto (Automático + Modificación Manual)**

Esta es la opción más flexible y la más común en la práctica:

1. El tutor genera las fechas automáticamente usando el botón "Generar fechas basadas en hitos".
2. El sistema crea las fechas iniciales basándose en los hitos del estudiante.
3. El tutor revisa las fechas generadas y puede **modificarlas**:
   - **Cambiar las fechas**: Ajusta cualquier fecha de revisión si considera que no es adecuada.
   - **Editar las descripciones**: Modifica las descripciones de las revisiones para que sean más específicas.
   - **Añadir nuevas fechas**: Si necesita más puntos de revisión, puede añadir fechas adicionales manualmente.
   - **Eliminar fechas**: Quita fechas que no sean necesarias o que se hayan generado incorrectamente.
4. El tutor guarda el cronograma final.

Esta opción combina la rapidez de la generación automática con la flexibilidad de poder ajustar las fechas según el criterio profesional del tutor.

### Interfaz de Gestión de Temporalización

El tutor accede a la pantalla de gestión de temporalización desde la revisión del anteproyecto. Esta pantalla permite:

- **Establecer rango de fechas**: Fecha de inicio y fecha final del proyecto.
- **Ver y gestionar fechas de revisión**: Lista de todas las fechas con sus descripciones.
- **Añadir fechas manualmente**: Botón para crear nuevas fechas de revisión una por una.
- **Editar fechas existentes**: Modificar la fecha o la descripción de cualquier revisión haciendo clic en ella.
- **Eliminar fechas**: Quitar fechas que no sean necesarias.
- **Generar automáticamente**: Botón para generar todas las fechas basándose en los hitos del anteproyecto.
- **Regenerar automáticamente**: Si ya hay fechas, puede regenerarlas desde cero basándose en los hitos actualizados.

### Ejemplo de Flujo de Temporalización

Un ejemplo típico sería:

1. El estudiante envía un anteproyecto con 4 hitos definidos.
2. El tutor abre el anteproyecto para revisarlo.
3. El tutor accede a la gestión de temporalización.
4. El tutor establece: fecha de inicio (1 de septiembre) y fecha final (30 de mayo).
5. El tutor hace clic en "Generar fechas basadas en hitos".
6. El sistema crea automáticamente 4 fechas de revisión, una por cada hito.
7. El tutor revisa las fechas y ve que:
   - La segunda fecha está muy cerca de la primera → La mueve una semana más tarde.
   - La tercera fecha necesita una descripción más específica → La edita.
   - Faltan dos revisiones intermedias → Añade dos fechas manualmente.
8. El tutor guarda el cronograma final con 6 fechas de revisión.

### Guardado de la Temporalización

Cuando el tutor guarda el cronograma:

1. Se crea o actualiza un registro en la tabla `schedules` con las fechas de inicio y fin.
2. Se crean o actualizan los registros en la tabla `review_dates` con cada fecha de revisión.
3. Se actualiza el campo `timeline` del anteproyecto con un resumen de las fechas en formato JSON.

El método `_updateAnteprojectTimeline()` actualiza el campo `timeline` del anteproyecto con las fechas de revisión (ver `frontend/lib/services/schedule_service.dart`, líneas 311-338).

### Importante sobre la Temporalización

- **Solo el tutor puede crear y modificar la temporalización**: El estudiante no tiene acceso a esta funcionalidad.
- **La temporalización es independiente del estado del anteproyecto**: El tutor puede crear o modificar el cronograma en cualquier momento durante la revisión.
- **La temporalización se puede actualizar**: Si el tutor necesita ajustar las fechas, puede volver a la pantalla de gestión y modificarlas.
- **La temporalización se vincula al anteproyecto**: Una vez creada, queda asociada al anteproyecto y se puede consultar desde la vista de detalles.

---

## 7. Aprobación y Creación de Proyecto

### Aprobar el anteproyecto

Cuando el tutor aprueba un anteproyecto, el estado cambia a `approved` y el sistema crea automáticamente un proyecto asociado.

El método `_createProjectFromAnteproject()` del servicio `AnteprojectsService` se encarga de esto (ver líneas 1329-1428).

### Creación del proyecto

El proyecto se crea con estos datos:

- **Título:** El mismo que el anteproyecto.
- **Descripción:** La misma que el anteproyecto.
- **Tutor:** El mismo que el anteproyecto.
- **Estado:** `planning` (planificación).

El proyecto se vincula al anteproyecto mediante el campo `anteproject_id`, y el anteproyecto se vincula al proyecto mediante el campo `project_id`.

---

## 8. Rechazo y Solicitud de Cambios

### Rechazar el anteproyecto

Si el tutor rechaza el anteproyecto, el estado cambia a `rejected` y el estudiante tiene que crear un nuevo anteproyecto. El anteproyecto rechazado no se puede editar ni reenviar.

### Solicitar cambios

Si el tutor pide cambios, el estado cambia a `under_review` y el estudiante puede volver a editar el anteproyecto. Una vez hechos los cambios, el estudiante lo vuelve a enviar (`submitted`) y el tutor lo revisa de nuevo.

Este ciclo se puede repetir las veces que haga falta hasta que el tutor apruebe el anteproyecto o lo rechace.
