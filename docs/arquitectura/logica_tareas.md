# 🧭 Lógica de Tareas (Proyectos y Anteproyectos)

Este documento describe el ciclo de vida completo de las tareas en la plataforma FCT, cubriendo tanto los anteproyectos como los proyectos finales. Resume cómo se modelan, qué servicios intervienen, cómo fluye la información entre frontend y backend, y qué reglas diferencian cada contexto.

---

## 1. Modelo de datos relevante

- **Tabla `tasks`** (`20240815000001_create_initial_schema.sql`)
  - Campos clave: `id`, `project_id`, `anteproject_id`, `milestone_id`, `title`, `description`, `status`, `due_date`, `completed_at`, `kanban_position`, `estimated_hours`, `actual_hours`, `complexity`, `tags`, `is_auto_generated`, `generation_source`, marcas temporales.
  - Restricciones: al menos uno de `project_id` o `anteproject_id` debe tener valor; claves foráneas con `projects`, `anteprojects` y `milestones`.
  - Índices: `idx_tasks_kanban` y `idx_tasks_project_status_position` optimizan consultas por tablero Kanban.
- **Tabla `task_assignees`**: relaciona tareas con usuarios responsables (`assigned_at`, `assigned_by`).
- **Tabla `comments`**: comentarios por tarea (incluye flag `is_internal`).
- **Enum `TaskStatus`** (modelo Flutter `TaskStatus` ↔ valores Supabase `pending`, `in_progress`, `under_review`, `completed`).
- **Enum `TaskComplexity`**: `simple`, `medium`, `complex`, con horas sugeridas.
- **Triggers y funciones** (`20240815000002_create_triggers_and_functions.sql`):
  - `notify_task_assigned`, `notify_comment_added` generan notificaciones en la tabla `notifications`.
  - `log_task_activity` registra cambios en `activity_log`.
- **Migración 20241004T120000**: convierte `kanban_position` a `double precision` y normaliza posiciones.

**Nota:** los anteproyectos no tienen hitos (`milestones`), pero las tareas pueden asociarse a ellos a través de `anteproject_id`. Las tareas de proyectos pueden asociarse a hitos específicos (`milestone_id`) y heredan el contexto del anteproyecto aprobado.

---

## 2. Origen y clasificación de tareas

- **Generación manual**: alumnos/tutores crean tareas directamente desde las pantallas de proyectos o anteproyectos.
- **Generación automática**: servicios MCP pueden proponer tareas (`is_auto_generated = true`, `generation_source` identifica el origen).
- **Plantillas**: se contempla reutilizar tareas base para buenas prácticas (mismo mecanismo de inserción en tabla `tasks`).

Cada tarea puede existir en:
- Un **anteproyecto** (planificación inicial, sin hitos), útil para preparar trabajo previo.
- Un **proyecto** (ejecución formal) donde también se usan hitos y tablero Kanban completo.

---

## 3. Ciclo de vida funcional

### 3.1 Creación

1. Usuario completa formulario en la UI.
2. `TasksBloc` emite `TaskCreateRequested` con el objeto `Task` (`frontend/lib/blocs/tasks_bloc.dart`).
3. `TasksService.createTask`:
   - Verifica usuario autenticado.
   - Normaliza payload (`toJson`, elimina campos calculados).
   - Calcula `kanban_position` consecutiva (`_getMaxKanbanPosition`).
   - Inserta en Supabase (`tasks.insert`).
4. Supabase aplica RLS según rol y asignaciones.
5. `TasksBloc` emite `TaskOperationSuccess('taskCreatedSuccess')` y recarga contexto (`TasksLoadRequested`).

### 3.2 Asignación de responsables

1. UI invoca `TasksService.assignUserToTask`.
2. Se crea/actualiza fila en `task_assignees` (`upsert`).
3. Trigger `notify_task_assigned` genera notificación para el usuario asignado.
4. El BLoC actualiza estado tras la operación (generalmente mediante recarga).

### 3.3 Carga y visualización

- **Panel general**: `TasksBloc` lanza `TasksLoadRequested` sin IDs → `TasksService.getTasks()` consulta las tareas asignadas al usuario a través de `task_assignees` (join con `tasks`).
- **Contexto proyecto/anteproyecto**: si se pasa `projectId` o `anteprojectId`, el BLoC usa `getStudentTasks()` y filtra localmente para ese contexto. El resultado se cachea en `_cachedTasks` para actualizaciones optimistas.
- **Kanban**: antes de devolver datos, el servicio puede llamar a `initializeKanbanPositions` para tareas sin posición; la UI renderiza columnas en función del enum `TaskStatus`.

### 3.4 Actualización de contenido

1. Formulario emite `TaskUpdateRequested`.
2. `TasksBloc` realiza actualización optimista en memoria y lanza `TasksService.updateTask`.
3. El servicio asegura que `project_id` o `anteproject_id` sigan presentes y recalcula `kanban_position` si fuese `null`.
4. En éxito: `TaskOperationSuccess('taskUpdatedSuccess')` + recarga. En error: rollback al estado previo.

### 3.5 Cambio de estado y orden Kanban

- **Cambio simple** (`TaskStatusUpdateRequested`):
  1. Se obtiene tarea actual (`getTask`).
  2. Se modifica solo `status` y `updated_at` (y `completed_at` si aplica).
  3. Se persiste con `updateTask`.
  4. Se emite éxito y se recarga el tablero.

- **Reordenamiento arrastrar/soltar** (`TaskReorderRequested`):
  1. `TasksBloc` construye estado optimista con `_buildOptimisticState` (mueve tarea entre columnas y ajusta `kanban_position`).
  2. `TasksService.moveTask`:
     - Opcionalmente reindexa columna origen (`_removeTaskFromColumn`).
     - Calcula nueva posición (`_computeTargetPosition`), ejecutando `_reindexColumn` si el espacio entre posiciones es insuficiente.
     - Actualiza `status`, `kanban_position`, timestamps y `completed_at` según transición.
  3. El servicio devuelve la tarea actualizada; el BLoC la reemplaza en cache y emite `TaskOperationSuccess('taskReorderedSuccess')` seguido de recarga.

- **Ajuste fino de posición** (`TaskPositionUpdateRequested`): actualiza únicamente `kanban_position` y vuelve a cargar el contexto.

### 3.6 Comentarios y actividad

1. `TasksService.addComment` inserta en `comments` y dispara `notify_comment_added`, que notifica a todos los asignados (excepto al autor).
2. `log_task_activity` registra el evento en `activity_log`.
3. `getTaskComments` permite a la UI mostrar el histórico.

### 3.7 Eliminación

- `TasksService.deleteTask` elimina la fila si la tarea no está en `completed`. Actualmente el BLoC solo emite éxito y recarga; la eliminación física se controla desde el servicio y respeta RLS.

---

## 4. Diferencias entre anteproyectos y proyectos

| Aspecto | Anteproyecto | Proyecto |
| --- | --- | --- |
| Clave relacional | `anteproject_id` obligatorio, `project_id` nulo | `project_id` obligatorio, `anteproject_id` opcional (hereda si proviene de anteproyecto) |
| Hitos (`milestones`) | No aplica | Opcional (`milestone_id`) para agrupar tareas por fase |
| Tablero Kanban | Se usa principalmente para planificación (estados básicos) | Se usa durante ejecución; reordenamiento intenso y métricas |
| Flujo de aprobación | Las tareas ayudan a preparar la defensa del anteproyecto | Las tareas tienen seguimiento formal, notificaciones y posibles entregables |
| Generación automática | Basada en análisis del anteproyecto | Basada en transición a proyecto y plantillas de ejecución |

En ambos casos se reutiliza la misma tabla para mantener trazabilidad continua: al aprobar un anteproyecto, las tareas pueden migrarse o duplicarse al proyecto manteniendo historial.

---

## 5. Interacción frontend

- **BLoC principal**: `frontend/lib/blocs/tasks_bloc.dart`
  - Eventos clave: `TasksLoadRequested`, `TaskCreateRequested`, `TaskUpdateRequested`, `TaskStatusUpdateRequested`, `TaskReorderRequested`, `TaskPositionUpdateRequested`, `TaskDeleteRequested`.
  - Estados: `TasksInitial`, `TasksLoading`, `TasksLoaded`, `TasksFailure(messageKey)`, `TaskOperationSuccess(messageKey)`.
  - Cache local `_cachedTasks` permite actualizaciones optimistas y rollback en errores.

- **Servicios**: `frontend/lib/services/tasks_service.dart`
  - Acceso directo a Supabase (`SupabaseClient`).
  - Métodos adicionales: filtrado por usuario (`getTasks`, `getStudentTasks`, `getProjectTasksForUser`), reindexación de Kanban, notificaciones (`_createStatusChangeNotification`, etc.).

- **UI**: pantallas en `frontend/lib/screens/projects` y `frontend/lib/screens/anteprojects` instancian el BLoC y renderizan columnas Kanban, formularios y detalles de tarea. Todos los textos usan `AppLocalizations` según la política de i18n.

---

## 6. Interacción backend (Supabase)

- **RLS**: 
  - Solo usuarios asignados o tutores autorizados pueden leer/editar tareas asociadas.
  - Políticas específicas en migraciones `20240815000004_configure_rls_fixed.sql` y `20240815000006_configure_rls.sql`.

- **Notificaciones**: triggers mencionados insertan en `notifications`, permitiendo a la app mostrar alertas (y extensiones vía correo en el futuro).

- **Registro**: `activity_log` guarda cada operación, útil para auditoría y métricas.

- **Reindexación Kanban**: la lógica reside en `TasksService`, apoyada por migraciones que aseguran precisión en tipo `double precision` y por funciones privadas que recalculan posiciones cuando no hay huecos suficientes.

---

## 7. Flujo resumido (proyecto típico)

1. **Planificación**: tareas creadas desde anteproyecto (`anteproject_id`) para validar alcance.
2. **Aprobación**: al pasar a proyecto, se reutiliza el conjunto de tareas (`project_id`), se asignan responsables y comienza el seguimiento.
3. **Ejecución**: cambios de estado y reordenamientos en Kanban; notificaciones mantienen informados a equipo y tutores.
4. **Cierre**: tareas completadas registran `completed_at`; comentarios y actividad quedan disponibles para reportes y evaluaciones.

---

## 8. Referencias cruzadas

- `frontend/lib/models/task.dart`
- `frontend/lib/services/tasks_service.dart`
- `frontend/lib/blocs/tasks_bloc.dart`
- Migraciones en `docs/base_datos/migraciones/`
- Documento general: `docs/arquitectura/logica_datos.md`

Mantener este documento actualizado cada vez que se modifiquen flujos de tareas, se añadan estados o se amplíen las reglas de negocio relacionadas con anteproyectos y proyectos.

---

## 9. Propuesta de diagrama visual

Para complementar la comprensión del ciclo de vida, se sugiere crear un diagrama de secuencia o estado con estas capas:

- **Frontend**: eventos BLoC clave (`TaskCreateRequested`, `TaskReorderRequested`, etc.).
- **Servicios**: métodos correspondientes en `TasksService` con llamadas a Supabase y lógica de reindexación.
- **Supabase**: operaciones en tablas (`tasks`, `task_assignees`, `comments`) y triggers/funciones relacionadas.
- **Notificaciones**: flujos derivados (`notifications`, `activity_log`).

El diagrama debería reflejar ambos contextos (anteproyecto y proyecto) destacando cuándo interviene cada ID y cómo se sincroniza el tablero Kanban después de cada operación. Guardar la versión inicial en `docs/arquitectura/diagramas/` para facilitar su actualización futura.


