# Ciclo de Vida del Estudiante

En este documento explico cómo funciona el flujo de trabajo de un estudiante en la aplicación. Desde que hace login hasta que gestiona sus tareas y anteproyectos.

> Si necesitas más contexto sobre la arquitectura, echa un vistazo a [Arquitectura del Sistema](01-Arquitectura).

## Índice

1.  Dashboard del estudiante
2.  Crear y gestionar anteproyectos
3.  Gestión de proyectos
4.  Tareas y tablero Kanban
5.  Comunicación con el tutor

---

## 1. Dashboard del Estudiante

### Cómo llega el estudiante a su dashboard

Cuando un estudiante hace login correctamente, la app lo redirige automáticamente a su dashboard. Esto se hace en `app_router.dart` con la función `goToDashboard()`:

```dart
static void goToDashboard(BuildContext context, User user) {
  final route = _getDashboardRoute(user.role);
  // Para estudiante: '/dashboard/student'
  context.go(route, extra: user);
}
```

La función `_getDashboardRoute()` comprueba el rol del usuario y devuelve la ruta correcta. En el caso de los estudiantes, es `/dashboard/student`.

### Construcción del dashboard

El dashboard se define como una ruta en el router (ver `app_router.dart`):

```dart
GoRoute(
  path: '/dashboard/student',
  name: 'student-dashboard',
  builder: (context, state) {
    final user = state.extra as User?;
    if (user == null) {
      return const LoginScreenBloc();
    }
    return StudentDashboardScreen(user: user);
  },
),
```

Si por alguna razón no hay un usuario en el estado (por ejemplo, si alguien intenta acceder directamente a la URL sin estar logueado), la app lo redirige a la pantalla de login.

### Carga de datos iniciales

Cuando se monta el widget `StudentDashboardScreen`, se ejecuta el método `_loadData()` que carga tres cosas en paralelo:

- Los anteproyectos del estudiante
- Los proyectos activos
- Las tareas pendientes

Esto lo hace con `Future.wait()` para que sea más rápido:

```dart
final futures = await Future.wait([
  _anteprojectsService.getStudentAnteprojects(),
  _projectsService.getStudentProjects(),
  _tasksService.getTasks(),
]);
```

Una vez cargados los datos, el dashboard muestra tres tarjetas con las estadísticas principales:
- **Anteproyectos Pendientes:** Cuántos anteproyectos tiene el estudiante en revisión.
- **Proyectos Activos:** Cuántos proyectos aprobados tiene en desarrollo.
- **Tareas Pendientes:** Cuántas tareas tiene sin completar.

---

## 2. Crear y Gestionar Anteproyectos

### ¿Qué es un anteproyecto?

Un anteproyecto es la propuesta inicial que hace el estudiante para su TFG. Tiene que incluir el título, descripción, objetivos, tipo de proyecto y los hitos que espera cumplir.

El tutor tiene que revisar y aprobar el anteproyecto antes de que el estudiante pueda empezar a trabajar en el proyecto real.

### Crear un anteproyecto

Desde el dashboard, el estudiante puede hacer clic en "Crear Anteproyecto" para abrir el formulario. El formulario está en `anteproject_form.dart` e incluye estos campos:

- **Título:** El nombre del proyecto.
- **Descripción:** Una explicación detallada de qué va el proyecto (mínimo 200 palabras).
- **Tipo de Proyecto:** Puede ser de ejecución, investigación, bibliográfico o de gestión.
- **Objetivos:** Los objetivos específicos que quiere conseguir.
- **Año Académico:** El año en el que se va a hacer el proyecto.
- **Hitos:** Los resultados esperados con sus fechas.

### Guardar como borrador

Si el estudiante todavía no tiene todo listo, puede guardar el anteproyecto como borrador. Esto lo hace con el botón "Guardar Borrador", que crea el anteproyecto con el estado `draft`:

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

### Enviar para revisión

Cuando el anteproyecto está completo, el estudiante lo envía para que el tutor lo revise. Esto cambia el estado a `submitted`:

```dart
status: AnteprojectStatus.submitted, // Cambiar a 'submitted'
submittedAt: DateTime.now(),
```

Una vez enviado, el estudiante **no puede editarlo**. Tiene que esperar a que el tutor lo revise.

### Estados del anteproyecto

Un anteproyecto puede tener estos estados:

- **`draft`:** Borrador. El estudiante lo está creando o editando.
- **`submitted`:** Enviado para revisión. El tutor tiene que revisarlo.
- **`under_review`:** En revisión. El tutor está revisándolo o ha pedido cambios.
- **`approved`:** Aprobado. El tutor lo ha aprobado y se crea automáticamente un proyecto.
- **`rejected`:** Rechazado. El tutor lo ha rechazado y el estudiante tiene que crear uno nuevo.

---

## 3. Gestión de Proyectos

### ¿Qué es un proyecto?

Un proyecto es el TFG en sí. Se crea automáticamente cuando el tutor aprueba un anteproyecto. A partir de ese momento, el estudiante puede empezar a trabajar en él.

### Cómo se crea un proyecto

Cuando el tutor aprueba un anteproyecto, el sistema crea automáticamente un proyecto asociado. Esto se hace en el método `_createProjectFromAnteproject()` del servicio `AnteprojectsService`.

El proyecto se crea con el estado `planning` (planificación) y se vincula al anteproyecto:

```dart
final projectData = {
  'title': title,
  'description': description,
  'tutor_id': tutorId,
  'anteproject_id': anteprojectId,
  'status': 'planning', // Estado inicial
  // ...
};
```

### Estados del proyecto

Un proyecto puede tener estos estados:

- **`planning`:** Planificación. El estudiante define las tareas y los hitos.
- **`development`:** Desarrollo. El estudiante está trabajando en el proyecto.
- **`completed`:** Completado. El proyecto está terminado y entregado.

### Ver los proyectos

El estudiante puede ver sus proyectos desde el dashboard o desde la sección "Proyectos". La app carga los proyectos con el método `getStudentProjects()` del servicio `ProjectsService`.

---

## 4. Tareas y Tablero Kanban

### ¿Qué son las tareas?

Las tareas son las unidades de trabajo más pequeñas del proyecto. El estudiante divide el proyecto en tareas para hacer un seguimiento más detallado del progreso.

**Importante:** Las tareas son una herramienta de organización personal. El estudiante las gestiona de forma autónoma, sin intervención del tutor. El tutor no tiene acceso a las tareas ni al tablero Kanban.

### Crear una tarea

Desde el dashboard o desde la sección "Tareas", el estudiante puede crear una nueva tarea. El formulario incluye:

- **Título:** Nombre de la tarea.
- **Descripción:** Qué hay que hacer.
- **Proyecto:** A qué proyecto pertenece.
- **Fecha de vencimiento:** Cuándo tiene que estar lista (opcional).
- **Complejidad:** Simple, media o compleja.
- **Horas estimadas:** Cuánto tiempo va a llevar.

Cuando se crea una tarea, su estado inicial es `pending` (pendiente).

### Tablero Kanban

El tablero Kanban es una forma visual de organizar las tareas. Tiene tres columnas:

- **Pendiente (`pending`):** Tareas que todavía no se han empezado.
- **En Progreso (`in_progress`):** Tareas en las que se está trabajando.
- **Completada (`completed`):** Tareas terminadas.

El estudiante puede arrastrar y soltar las tareas entre columnas para cambiar su estado. Esto se hace con drag and drop, y cuando se suelta una tarea en otra columna, se actualiza su estado en la base de datos.

### Mover tareas

Cuando el estudiante arrastra una tarea a otra columna, se ejecuta el método `_onTaskMoved()` que actualiza el estado de la tarea:

```dart
await _tasksService.updateTask(
  task.copyWith(
    status: newStatus,
    kanbanPosition: newPosition,
  ),
);
```

El campo `kanban_position` guarda la posición de la tarea dentro de su columna para mantener el orden.

---

## 5. Comunicación con el Tutor

### Comentarios en anteproyectos

El tutor puede dejar comentarios en los anteproyectos cuando los revisa. El estudiante puede ver estos comentarios en la pantalla de detalle del anteproyecto.

Si el tutor pide cambios, el anteproyecto pasa al estado `under_review` y el estudiante puede editarlo de nuevo. Una vez hechos los cambios, lo vuelve a enviar (`submitted`).

### Notificaciones

Cuando el tutor deja un comentario o cambia el estado de un anteproyecto, el estudiante recibe una notificación. Las notificaciones se muestran en el icono de la campana en la barra superior.

---

## Conclusión

Este es el flujo completo de un estudiante en la aplicación. Desde que hace login hasta que gestiona sus anteproyectos, proyectos y tareas. Las tareas son una herramienta personal de organización que el estudiante gestiona de forma autónoma.
