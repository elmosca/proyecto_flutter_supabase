# Ciclo de Vida de la Tarea - Documentación Técnica

Este documento explica detalladamente el funcionamiento completo del ciclo de vida de la **Tarea** en la aplicación, basado en el código fuente real del proyecto.

## Tabla de Contenidos

1. [Introducción](#1-introducción)
2. [Estados de la Tarea](#2-estados-de-la-tarea)
3. [Creación de Tareas](#3-creación-de-tareas)
4. [Tablero Kanban](#4-tablero-kanban)
5. [Transiciones de Estado](#5-transiciones-de-estado)
6. [Movimiento de Tareas (Drag and Drop)](#6-movimiento-de-tareas-drag-and-drop)
7. [Asignación de Tareas](#7-asignación-de-tareas)
8. [Comentarios en Tareas](#8-comentarios-en-tareas)
9. [Modelo de Datos](#9-modelo-de-datos)
10. [Permisos y Seguridad](#10-permisos-y-seguridad)

---

## 1. Introducción

Las tareas son las unidades de trabajo más pequeñas dentro de un proyecto. **Las tareas son propiedad y responsabilidad exclusiva del estudiante**, permitiéndole dividir el proyecto en partes manejables y hacer un seguimiento detallado del progreso. Las tareas se organizan en un tablero Kanban y pasan por varios estados a medida que el estudiante las completa.

**Importante**: Aunque el tutor puede visualizar las tareas de los proyectos que supervisa para seguimiento, las tareas son gestionadas completamente por el estudiante. El tutor no crea, edita ni gestiona tareas directamente.

**Flujo general:**
```
Creación (por estudiante) → Pendiente → En Progreso → En Revisión → Completada
```

---

## 2. Estados de la Tarea

El modelo `Task` define los siguientes estados posibles:

| Estado | Valor en BD | Descripción |
| :--- | :--- | :--- |
| **Pendiente** | `pending` | La tarea está pendiente de iniciar. Es el estado inicial cuando se crea una nueva tarea. |
| **En Progreso** | `in_progress` | La tarea está siendo trabajada actualmente por el estudiante. |
| **En Revisión** | `under_review` | La tarea está completada y esperando revisión. |
| **Completada** | `completed` | La tarea ha sido completada y revisada. |

**Referencia de código:**
- Archivo: `frontend/lib/models/task.dart`
- Líneas: 158-175

```dart
enum TaskStatus {
  /// Tarea pendiente de iniciar.
  @JsonValue('pending')
  pending,

  /// Tarea en progreso de desarrollo.
  @JsonValue('in_progress')
  inProgress,

  /// Tarea en revisión o testing.
  @JsonValue('under_review')
  underReview,

  /// Tarea completada y finalizada.
  @JsonValue('completed')
  completed,
}
```

---

## 3. Creación de Tareas

**Importante**: Las tareas son creadas y gestionadas exclusivamente por el estudiante. El estudiante es responsable de dividir su proyecto en tareas y gestionar su progreso.

### 3.1. Acceso al Formulario

El estudiante puede crear tareas desde el dashboard o desde la lista de tareas:

```dart
void _createTask() {
  context.go('/tasks', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/student_dashboard_screen.dart`
- Líneas: 779-782

### 3.2. Formulario de Tarea

El formulario `TaskForm` permite crear y editar tareas:

```dart
class TaskForm extends StatefulWidget {
  final int? projectId;
  final Task? task;

  const TaskForm({
    super.key,
    this.projectId,
    this.task,
  });
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/forms/task_form.dart`
- Líneas: 1-50 (aproximadamente)

### 3.3. Campos del Formulario

El formulario incluye los siguientes campos:

- **Título**: Título de la tarea (requerido)
- **Descripción**: Descripción detallada de la tarea
- **Proyecto**: Proyecto al que pertenece la tarea (requerido)
- **Fecha de Vencimiento**: Fecha límite para completar la tarea (opcional)
- **Complejidad**: Nivel de complejidad (simple, medium, complex)
- **Horas Estimadas**: Estimación de tiempo de trabajo
- **Etiquetas**: Etiquetas para categorizar la tarea

### 3.4. Creación en la Base de Datos

El servicio `TasksService` crea la tarea en la base de datos:

```dart
Future<Task> createTask(Task task) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    final data = task.toJson();
    // Remover campos que se generan automáticamente
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    data.remove('completed_at');

    // Validar que se proporcione un projectId
    if (task.projectId == null) {
      throw ValidationException('missing_task_context', ...);
    }

    // Verificar que el proyecto existe
    final projectExists = await _verifyProjectExists(task.projectId!);
    if (!projectExists) {
      throw ValidationException('invalid_project_relation', ...);
    }

    // Obtener la siguiente posición Kanban
    final maxPosition = await _getMaxKanbanPosition(
      projectId: task.projectId,
    );
    data['kanban_position'] = maxPosition + 1;

    final response = await _supabase
        .from('tasks')
        .insert(data)
        .select()
        .single();

    final createdTask = Task.fromJson(response);

    // Asignar automáticamente la tarea al usuario que la crea
    try {
      await _assignTaskToUser(createdTask.id, user.email!);
    } catch (e) {
      // No fallar la creación si no se puede asignar
    }

    return createdTask;
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 300-375

### 3.5. Estado Inicial

Cuando se crea una nueva tarea, su estado inicial es `pending`:

```dart
final newTask = Task(
  id: 0,
  title: _titleController.text.trim(),
  description: _descriptionController.text.trim(),
  status: TaskStatus.pending, // Estado inicial
  projectId: effectiveProjectId,
  complexity: _selectedComplexity,
  estimatedHours: _estimatedHours,
  // ...
);
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/forms/task_form.dart`
- Líneas: 200-300 (aproximadamente)

---

## 4. Tablero Kanban

### 4.1. Componente Kanban

El tablero Kanban muestra las tareas organizadas por columnas según su estado:

```dart
class KanbanBoard extends StatefulWidget {
  final int? projectId;
  final bool isEmbedded;

  const KanbanBoard({
    super.key,
    this.projectId,
    this.isEmbedded = false,
  });
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/kanban/kanban_board.dart`
- Líneas: 1-50 (aproximadamente)

### 4.2. Columnas del Tablero

El tablero Kanban tiene columnas correspondientes a los estados de las tareas:

- **Pendiente** (`pending`): Tareas que aún no se han iniciado
- **En Progreso** (`in_progress`): Tareas en desarrollo activo
- **En Revisión** (`under_review`): Tareas completadas esperando revisión
- **Completada** (`completed`): Tareas finalizadas

```dart
Widget _buildColumn(
  TaskStatus status,
  List<Task> tasks,
  AppLocalizations l10n,
) {
  final columnTasks = tasks.where((t) => t.status == status).toList();
  // ... construir columna ...
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/kanban/kanban_board.dart`
- Líneas: 200-300 (aproximadamente)

### 4.3. Posición Kanban

El campo `kanban_position` almacena la posición de la tarea dentro de su columna para mantener el orden:

```dart
class Task {
  @JsonKey(name: 'kanban_position')
  final double? kanbanPosition;
  // ...
}
```

**Referencia de código:**
- Archivo: `frontend/lib/models/task.dart`
- Líneas: 60-61

---

## 5. Transiciones de Estado

Esta sección describe qué acciones provocan un cambio de estado.

| Transición | Acción | Descripción |
| :--- | :--- | :--- |
| Creación → `pending` | Crear tarea | Cuando se crea una nueva tarea, su estado inicial es `pending`. |
| `pending` → `in_progress` | Iniciar tarea | El estudiante comienza a trabajar en la tarea. |
| `in_progress` → `under_review` | Marcar para revisión | El estudiante completa la tarea y la marca para revisión. |
| `under_review` → `completed` | Aprobar tarea | El estudiante marca la tarea como completada. |
| `under_review` → `in_progress` | Continuar trabajo | El estudiante vuelve a trabajar en la tarea si necesita hacer cambios. |
| `completed` → `in_progress` | Reabrir tarea | La tarea se puede reabrir si es necesario. |

**Referencia de código:**
- Servicio: `frontend/lib/services/tasks_service.dart`
- BLoC: `frontend/lib/blocs/tasks_bloc.dart`

### 5.1. Actualización de Estado

El servicio actualiza el estado de una tarea:

```dart
Future<Task> updateTaskStatus(int id, TaskStatus status) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    final updateData = <String, dynamic>{
      'status': status.dbValue,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Si se completa, añadir fecha de completado
    if (status == TaskStatus.completed) {
      updateData['completed_at'] = DateTime.now().toIso8601String();
    } else {
      updateData['completed_at'] = null;
    }

    final response = await _supabase
        .from('tasks')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

    // Crear notificación de cambio de estado
    await _createStatusChangeNotification(id, status);
    return Task.fromJson(response);
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 439-489

---

## 6. Movimiento de Tareas (Drag and Drop)

### 6.1. Interfaz Drag and Drop

El tablero Kanban permite mover tareas entre columnas mediante drag and drop:

```dart
void _handleTaskDrop(Task task, TaskStatus newStatus, int targetIndex) {
  // Evitar procesar múltiples drops simultáneos
  if (_isProcessingDrop) {
    LoggingService.debug('⚠️ Drop ya en proceso, ignorando');
    return;
  }

  // Marcar que estamos procesando el drop
  setState(() {
    _isProcessingDrop = true;
    _draggingTask = null;
    _dropTargetIndex = null;
    _dropTargetStatus = null;
  });

  // Enviar el evento al BLoC
  context.read<TasksBloc>().add(
    TaskReorderRequested(
      taskId: task.id,
      newStatus: newStatus,
      newPosition: targetIndex.toDouble(),
    ),
  );

  // Resetear la bandera después de un breve delay
  Future.delayed(const Duration(milliseconds: 500), () {
    if (mounted) {
      setState(() {
        _isProcessingDrop = false;
      });
    }
  });
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/kanban/kanban_board.dart`
- Líneas: 400-450 (aproximadamente)

### 6.2. Procesamiento en el BLoC

El BLoC procesa el movimiento de tareas con actualización optimista:

```dart
Future<void> _onTaskReorderRequested(
  TaskReorderRequested event,
  Emitter<TasksState> emit,
) async {
  final currentState = state;
  if (currentState is! TasksLoaded) {
    emit(const TasksFailure('tasksNotLoaded'));
    return;
  }

  final originalTasks = List<Task>.from(currentState.tasks);
  final movingIndex = originalTasks.indexWhere(
    (task) => task.id == event.taskId,
  );

  if (movingIndex == -1) {
    emit(const TasksFailure('taskNotFound'));
    return;
  }

  final fromStatus = originalTasks[movingIndex].status;
  final toStatus = event.newStatus;

  // Actualización optimista: remover de columna original e insertar en nueva
  final optimisticTasks = _buildOptimisticState(
    tasks: originalTasks,
    taskId: event.taskId,
    fromStatus: fromStatus,
    toStatus: toStatus,
    targetIndex: event.newPosition,
  );

  _cachedTasks = List<Task>.from(optimisticTasks);
  emit(TasksLoaded(_cachedTasks));

  try {
    final resultTask = await tasksService.moveTask(
      taskId: event.taskId,
      fromStatus: fromStatus,
      toStatus: toStatus,
      targetIndex: event.newPosition.toInt(),
      projectId: originalTasks[movingIndex].projectId,
    );

    // Actualizar el cache con la tarea devuelta del servidor
    _cachedTasks = _cachedTasks.map((task) {
      if (task.id == resultTask.id) {
        return resultTask;
      }
      return task;
    }).toList();

    // Emitir el estado actualizado
    emit(TasksLoaded(_cachedTasks));
    emit(const TaskOperationSuccess('taskReorderedSuccess'));

    // Recargar desde el servidor después de un delay
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        if (!isClosed) {
          add(
            TasksLoadRequested(
              projectId: resultTask.projectId ?? _currentProjectId,
            ),
          );
        }
      },
    );
  } catch (e) {
    // Rollback al estado original en caso de error
    _cachedTasks = List<Task>.from(originalTasks);
    emit(TasksLoaded(originalTasks));
    emit(TasksFailure(e.toString()));
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/blocs/tasks_bloc.dart`
- Líneas: 309-386

### 6.3. Movimiento en el Servicio

El servicio maneja el movimiento de tareas y recalcula las posiciones:

```dart
Future<Task> moveTask({
  required int taskId,
  required TaskStatus fromStatus,
  required TaskStatus toStatus,
  required int targetIndex,
  required int? projectId,
}) async {
  try {
    final currentTask = await getTask(taskId);
    if (currentTask == null) {
      throw ValidationException('resource_not_found', ...);
    }

    final effectiveProjectId = projectId ?? currentTask.projectId;

    // Si cambia de columna, remover de la columna original
    if (fromStatus != toStatus) {
      await _removeTaskFromColumn(
        projectId: effectiveProjectId,
        status: fromStatus,
        taskId: taskId,
      );
    }

    // Calcular la nueva posición
    final positionResult = await _computeTargetPosition(
      projectId: effectiveProjectId,
      toStatus: toStatus,
      excludeTaskId: taskId,
      targetIndex: targetIndex,
    );

    // Actualizar la tarea
    final updatePayload = {
      'status': toStatus.dbValue,
      'kanban_position': positionResult.position,
      'updated_at': DateTime.now().toIso8601String(),
      if (toStatus == TaskStatus.completed)
        'completed_at': DateTime.now().toIso8601String(),
      if (fromStatus == TaskStatus.completed &&
          toStatus != TaskStatus.completed)
        'completed_at': null,
    };

    final updatedTask = await _supabase
        .from('tasks')
        .update(updatePayload)
        .eq('id', taskId)
        .select()
        .single();

    return Task.fromJson(updatedTask);
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 713-800

---

## 7. Asignación de Tareas

### 7.1. Asignación Automática

Cuando un estudiante crea una tarea, se asigna automáticamente a sí mismo:

```dart
// Asignar automáticamente la tarea al usuario que la crea
try {
  await _assignTaskToUser(createdTask.id, user.email!);
  debugPrint('✅ Tarea ${createdTask.id} asignada exitosamente');
} catch (e) {
  debugPrint('❌ Error asignando tarea ${createdTask.id}: $e');
  // No fallar la creación si no se puede asignar
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 347-355

### 7.2. Asignación Manual

El estudiante puede asignar tareas a otros usuarios:

```dart
Future<void> assignUserToTask(int taskId, int userId) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    await _supabase.from('task_assignees').upsert({
      'task_id': taskId,
      'user_id': userId,
      'assigned_by': user.id,
      'assigned_at': DateTime.now().toIso8601String(),
    });

    // Crear notificación de asignación
    await _createAssignmentNotification(taskId, userId);
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 491-528

### 7.3. Desasignación

Se puede quitar un usuario asignado de una tarea:

```dart
Future<void> unassignUserFromTask(int taskId, int userId) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    await _supabase
        .from('task_assignees')
        .delete()
        .eq('task_id', taskId)
        .eq('user_id', userId);
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 530-563

---

## 8. Comentarios en Tareas

### 8.1. Añadir Comentarios

Los usuarios pueden añadir comentarios a las tareas:

```dart
Future<Comment> addComment(
  int taskId,
  String content, {
  bool isInternal = false,
}) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    final commentData = {
      'task_id': taskId,
      'author_id': user.id,
      'content': content,
      'is_internal': isInternal,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from('comments')
        .insert(commentData)
        .select()
        .single();

    // Crear notificación de nuevo comentario
    await _createCommentNotification(taskId, content);

    return Comment.fromJson(response);
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 565-616

### 8.2. Obtener Comentarios

Se pueden obtener todos los comentarios de una tarea:

```dart
Future<List<Comment>> getTaskComments(int taskId) async {
  try {
    final response = await _supabase
        .from('comments')
        .select('*')
        .eq('task_id', taskId)
        .order('created_at', ascending: true);

    return response.map<Comment>(Comment.fromJson).toList();
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 618-645

---

## 9. Modelo de Datos

### 9.1. Estructura del Modelo

El modelo `Task` contiene la siguiente información:

```dart
class Task {
  final int id;
  final int? projectId;
  final int? anteprojectId;
  final int? milestoneId;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final double? kanbanPosition;
  final int? estimatedHours;
  final int? actualHours;
  final TaskComplexity complexity;
  final List<String>? tags;
  final bool isAutoGenerated;
  final String? generationSource;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Referencia de código:**
- Archivo: `frontend/lib/models/task.dart`
- Líneas: 45-96

### 9.2. Niveles de Complejidad

Las tareas pueden tener diferentes niveles de complejidad:

```dart
enum TaskComplexity {
  /// Tarea simple, requiere poco tiempo y esfuerzo.
  @JsonValue('simple')
  simple,

  /// Tarea de complejidad media, requiere tiempo moderado.
  @JsonValue('medium')
  medium,

  /// Tarea compleja, requiere mucho tiempo y esfuerzo.
  @JsonValue('complex')
  complex,
}
```

**Referencia de código:**
- Archivo: `frontend/lib/models/task.dart`
- Líneas: 177-190

### 9.3. Relación con Proyectos

Las tareas se asocian a proyectos mediante el campo `project_id`:

```dart
@JsonKey(name: 'project_id')
final int? projectId;
```

**Referencia de código:**
- Archivo: `frontend/lib/models/task.dart`
- Líneas: 47-48

### 9.4. Relación con Asignados

Las tareas se asignan a usuarios mediante la tabla `task_assignees`:

```dart
// Estructura de la tabla task_assignees
{
  'task_id': taskId,
  'user_id': userId,
  'assigned_by': assignedByUserId,
  'assigned_at': DateTime.now().toIso8601String(),
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 502-507

---

## 10. Permisos y Seguridad

### 10.1. Row Level Security (RLS)

Las políticas RLS aseguran que cada usuario solo vea y gestione sus propias tareas. Las tareas son propiedad del estudiante:

```sql
-- Política para que estudiantes vean y gestionen solo sus tareas asignadas
CREATE POLICY "Students can view their assigned tasks" ON tasks
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM task_assignees
            WHERE task_id = tasks.id
            AND user_id = public.user_id()
        )
    );

-- Política para que estudiantes actualicen sus tareas asignadas
CREATE POLICY "Students can update their assigned tasks" ON tasks
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM task_assignees
            WHERE task_id = tasks.id
            AND user_id = public.user_id()
        )
    );
```

**Nota sobre tutores**: Aunque las políticas RLS permiten a los tutores ver las tareas de los proyectos que supervisan (para seguimiento y supervisión), las tareas son propiedad y responsabilidad exclusiva del estudiante. El tutor puede visualizar el progreso pero no puede crear, editar o gestionar tareas directamente.

**Referencia de código:**
- Archivo: `docs/base_datos/migraciones/schema_completo.sql` (sección RLS)
- Líneas: 250-300 (aproximadamente)

### 10.2. Verificación de Propiedad

El sistema verifica que el usuario tenga permiso para modificar una tarea. Las tareas son propiedad del estudiante y solo el estudiante asignado puede modificarlas:

```dart
// Verificar que el usuario es el asignado a la tarea
final task = await getTask(taskId);
if (task == null) {
  throw ValidationException('resource_not_found', ...);
}

// Verificar asignación
final isAssigned = await _isUserAssignedToTask(taskId, userId);

if (!isAssigned) {
  throw AuthenticationException('unauthorized', ...);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 400-500 (aproximadamente)

**Nota**: Aunque las políticas RLS permiten a los tutores ver las tareas de sus proyectos para supervisión, las tareas son propiedad y responsabilidad del estudiante. El tutor puede visualizar el progreso pero no gestiona directamente las tareas.

---

## Resumen del Flujo de la Tarea

### Flujo Principal

```
1. Estudiante crea tarea
   ↓ Estado: pending
   ↓ Asignación automática al estudiante
   ↓ Posición Kanban: final de columna "Pendiente"
   ↓
2. Estudiante inicia trabajo
   ↓ Estado: in_progress
   ↓ Movimiento mediante drag and drop o edición
   ↓
3. Estudiante completa tarea
   ↓ Estado: under_review
   ↓ Movimiento a columna "En Revisión"
   ↓
4. Estudiante marca como completada
   ↓ Estado: completed
   ↓ Fecha de completado registrada
```

### Puntos Clave

- **Estado inicial**: Todas las tareas comienzan en estado `pending`
- **Asignación automática**: Se asignan automáticamente al usuario que las crea
- **Posición Kanban**: Se calcula automáticamente para mantener el orden
- **Drag and Drop**: Permite mover tareas entre columnas visualmente
- **Actualización optimista**: El UI se actualiza inmediatamente, luego se sincroniza con el servidor
- **Notificaciones**: Se generan notificaciones cuando cambia el estado o se asignan tareas

---

**Última actualización**: Diciembre 2025  
**Versión del documento**: 1.0

