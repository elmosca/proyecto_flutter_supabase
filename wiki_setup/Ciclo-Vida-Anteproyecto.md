# Ciclo de Vida del Anteproyecto

En este documento explico cómo funciona el ciclo de vida de un anteproyecto, desde que el estudiante lo crea hasta que el tutor lo aprueba o rechaza.

> Si necesitas más contexto sobre la arquitectura, echa un vistazo a [Arquitectura del Sistema](01-Arquitectura).

## Índice

1.  ¿Qué es un anteproyecto?
2.  Estados del anteproyecto
3.  Crear un anteproyecto
4.  Enviar para revisión
5.  Revisión por el tutor
6.  Aprobación y creación de proyecto
7.  Rechazo y solicitud de cambios

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

## 6. Aprobación y Creación de Proyecto

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

## 7. Rechazo y Solicitud de Cambios

### Rechazar el anteproyecto

Si el tutor rechaza el anteproyecto, el estado cambia a `rejected` y el estudiante tiene que crear un nuevo anteproyecto. El anteproyecto rechazado no se puede editar ni reenviar.

### Solicitar cambios

Si el tutor pide cambios, el estado cambia a `under_review` y el estudiante puede volver a editar el anteproyecto. Una vez hechos los cambios, el estudiante lo vuelve a enviar (`submitted`) y el tutor lo revisa de nuevo.

Este ciclo se puede repetir las veces que haga falta hasta que el tutor apruebe el anteproyecto o lo rechace.
