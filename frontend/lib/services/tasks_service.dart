import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/models.dart';
import '../utils/notification_localizations.dart';
import 'logging_service.dart';

class TasksService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  /// Obtiene todas las tareas del usuario actual
  Future<List<Task>> getTasks() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
      }

      // Obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;

      // Obtener tareas asignadas al usuario
      final response = await _supabase
          .from('task_assignees')
          .select('''
            task_id,
            tasks (
              *,
              comments (*),
              milestones (*)
            )
          ''')
          .eq('user_id', userId)
          .order('assigned_at', ascending: false);

      return response.map<Task>((json) {
        final taskData = json['tasks'] as Map<String, dynamic>;
        return Task.fromJson(taskData);
      }).toList();
    } catch (e) {
      throw TasksException('Error al obtener tareas: $e');
    }
  }

  /// Obtiene tareas del estudiante actual (usando ID de la tabla users)
  /// Incluye tanto tareas de proyectos como de anteproyectos
  Future<List<Map<String, dynamic>>> getStudentTasks() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
      }

      // Obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;

      // Obtener tareas asignadas al estudiante
      final response = await _supabase
          .from('task_assignees')
          .select('''
            task_id,
            tasks (
              *,
              comments (*),
              milestones (*)
            )
          ''')
          .eq('user_id', userId)
          .order('assigned_at', ascending: false);

      // Convertir a lista de Map para el dashboard
      final tasks = <Map<String, dynamic>>[];
      for (final item in response) {
        if (item['tasks'] != null) {
          final taskData = item['tasks'] as Map<String, dynamic>;
          tasks.add(taskData);
        }
      }

      return tasks;
    } catch (e) {
      throw TasksException('Error al obtener tareas del estudiante: $e');
    }
  }

  /// Obtiene tareas por proyecto
  Future<List<Task>> getTasksByProject(int projectId) async {
    try {
      // Inicializar posiciones Kanban si es necesario
      await initializeKanbanPositions(projectId);

      final response = await _supabase
          .from('tasks')
          .select('''
            *,
            comments (*),
            milestones (*)
          ''')
          .eq('project_id', projectId)
          .order('kanban_position', ascending: true)
          .order('created_at', ascending: false);

      return response.map<Task>(Task.fromJson).toList();
    } catch (e) {
      throw TasksException('Error al obtener tareas del proyecto: $e');
    }
  }

  /// Obtiene tareas del proyecto asignadas al usuario actual
  Future<List<Task>> getProjectTasksForUser(int projectId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
      }

      // Obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;

      // Obtener tareas del proyecto asignadas al usuario
      final response = await _supabase
          .from('task_assignees')
          .select('''
            task_id,
            tasks!inner (
              *,
              comments (*),
              milestones (*)
            )
          ''')
          .eq('user_id', userId)
          .eq('tasks.project_id', projectId)
          .order('assigned_at', ascending: false);

      return response.map<Task>((json) {
        final taskData = json['tasks'] as Map<String, dynamic>;
        return Task.fromJson(taskData);
      }).toList();
    } catch (e) {
      throw TasksException(
        'Error al obtener tareas del proyecto para el usuario: $e',
      );
    }
  }

  /// Obtiene una tarea específica por ID
  Future<Task?> getTask(int id) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('''
            *,
            comments (*),
            milestones (*)
          ''')
          .eq('id', id)
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw TasksException('Error al obtener tarea: $e');
    }
  }

  /// Crea una nueva tarea
  Future<Task> createTask(Task task) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
      }

      final data = task.toJson();
      // Remover campos que se generan automáticamente
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      data.remove('completed_at');

      // Obtener la siguiente posición Kanban
      final maxPosition = await _getMaxKanbanPosition(task.projectId ?? 0);
      data['kanban_position'] = maxPosition + 1;

      final response = await _supabase
          .from('tasks')
          .insert(data)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw TasksException('Error al crear tarea: $e');
    }
  }

  /// Actualiza una tarea existente
  Future<Task> updateTask(int id, Task task) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
      }

      final data = task.toJson();
      // Remover campos que no se pueden actualizar
      data.remove('id');
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();

      // Si kanbanPosition es null, asignar una posición por defecto
      if (data['kanban_position'] == null) {
        final maxPosition = await _getMaxKanbanPosition(task.projectId ?? 0);
        data['kanban_position'] = maxPosition + 1;
      }

      final response = await _supabase
          .from('tasks')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw TasksException('Error al actualizar tarea: $e');
    }
  }

  /// Cambia el estado de una tarea
  Future<void> updateTaskStatus(int id, TaskStatus status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
      }

      final updateData = {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Si se completa, añadir fecha de completado
      if (status == TaskStatus.completed) {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await _supabase.from('tasks').update(updateData).eq('id', id);

      // Crear notificación de cambio de estado
      await _createStatusChangeNotification(id, status);
    } catch (e) {
      throw TasksException('Error al actualizar estado de tarea: $e');
    }
  }

  /// Asigna un usuario a una tarea
  Future<void> assignUserToTask(int taskId, int userId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
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
      throw TasksException('Error al asignar usuario a tarea: $e');
    }
  }

  /// Desasigna un usuario de una tarea
  Future<void> unassignUserFromTask(int taskId, int userId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
      }

      await _supabase
          .from('task_assignees')
          .delete()
          .eq('task_id', taskId)
          .eq('user_id', userId);
    } catch (e) {
      throw TasksException('Error al desasignar usuario de tarea: $e');
    }
  }

  /// Añade un comentario a una tarea
  Future<Comment> addComment(
    int taskId,
    String content, {
    bool isInternal = false,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
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
      throw TasksException('Error al añadir comentario: $e');
    }
  }

  /// Obtiene comentarios de una tarea
  Future<List<Comment>> getTaskComments(int taskId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('*')
          .eq('task_id', taskId)
          .order('created_at', ascending: true);

      return response.map<Comment>(Comment.fromJson).toList();
    } catch (e) {
      throw TasksException('Error al obtener comentarios: $e');
    }
  }

  /// Actualiza la posición Kanban de una tarea
  Future<void> updateKanbanPosition(int taskId, int newPosition) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
      }

      await _supabase
          .from('tasks')
          .update({
            'kanban_position': newPosition,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', taskId);
    } catch (e) {
      throw TasksException('Error al actualizar posición Kanban: $e');
    }
  }

  /// Actualiza múltiples posiciones Kanban de una vez
  Future<void> updateMultipleKanbanPositions(
    Map<int, int> positionUpdates,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
      }

      // Actualizar cada tarea individualmente
      for (final entry in positionUpdates.entries) {
        await _supabase
            .from('tasks')
            .update({
              'kanban_position': entry.value,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', entry.key);
      }
    } catch (e) {
      throw TasksException('Error al actualizar posiciones Kanban: $e');
    }
  }

  /// Recalcula las posiciones Kanban para evitar conflictos
  Future<void> recalculateKanbanPositions(int? projectId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
      }

      // Obtener todas las tareas del proyecto ordenadas por estado y posición actual
      final response = projectId != null
          ? await _supabase
                .from('tasks')
                .select('id, status, kanban_position')
                .eq('project_id', projectId)
                .order('status')
                .order('kanban_position')
          : await _supabase
                .from('tasks')
                .select('id, status, kanban_position')
                .order('status')
                .order('kanban_position');

      // Agrupar por estado y recalcular posiciones
      final Map<String, List<Map<String, dynamic>>> tasksByStatus = {};
      for (final task in response) {
        final status = task['status'] as String;
        tasksByStatus.putIfAbsent(status, () => []).add(task);
      }

      // Actualizar posiciones secuencialmente por estado
      for (final statusTasks in tasksByStatus.values) {
        for (int i = 0; i < statusTasks.length; i++) {
          final taskId = statusTasks[i]['id'] as int;
          final newPosition =
              (i + 1) * 100; // Espaciar posiciones para futuras inserciones

          await _supabase
              .from('tasks')
              .update({
                'kanban_position': newPosition,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', taskId);
        }
      }
    } catch (e) {
      throw TasksException('Error al recalcular posiciones Kanban: $e');
    }
  }

  /// Obtiene tareas por estado
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('*')
          .eq('status', status.name)
          .order('kanban_position', ascending: true);

      return response.map<Task>(Task.fromJson).toList();
    } catch (e) {
      throw TasksException('Error al obtener tareas por estado: $e');
    }
  }

  /// Obtiene tareas por complejidad
  Future<List<Task>> getTasksByComplexity(TaskComplexity complexity) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('*')
          .eq('complexity', complexity.name)
          .order('created_at', ascending: false);

      return response.map<Task>(Task.fromJson).toList();
    } catch (e) {
      throw TasksException('Error al obtener tareas por complejidad: $e');
    }
  }

  /// Obtiene tareas con fecha límite próxima
  Future<List<Task>> getTasksWithUpcomingDeadline({int daysAhead = 7}) async {
    try {
      final deadline = DateTime.now().add(Duration(days: daysAhead));

      final response = await _supabase
          .from('tasks')
          .select('*')
          .not('due_date', 'is', null)
          .lte('due_date', deadline.toIso8601String())
          .neq('status', 'completed')
          .order('due_date', ascending: true);

      return response.map<Task>(Task.fromJson).toList();
    } catch (e) {
      throw TasksException(
        'Error al obtener tareas con fecha límite próxima: $e',
      );
    }
  }

  /// Elimina una tarea
  Future<void> deleteTask(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const TasksException('Usuario no autenticado');
      }

      // Verificar que la tarea no esté completada
      final task = await getTask(id);
      if (task?.status == TaskStatus.completed) {
        throw const TasksException('No se puede eliminar una tarea completada');
      }

      await _supabase.from('tasks').delete().eq('id', id);
    } catch (e) {
      throw TasksException('Error al eliminar tarea: $e');
    }
  }

  // Métodos privados de ayuda

  /// Obtiene la máxima posición Kanban para un proyecto
  Future<int> _getMaxKanbanPosition(int projectId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('kanban_position')
          .eq('project_id', projectId)
          .not('kanban_position', 'is', null)
          .order('kanban_position', ascending: false)
          .limit(1)
          .single();

      return (response['kanban_position'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Inicializa las posiciones Kanban para tareas que no las tienen
  Future<void> initializeKanbanPositions(int projectId) async {
    try {
      // Obtener tareas sin posición Kanban
      final tasksWithoutPosition = await _supabase
          .from('tasks')
          .select('id, status')
          .eq('project_id', projectId)
          .isFilter('kanban_position', null);

      if (tasksWithoutPosition.isEmpty) return;

      // Agrupar por estado
      final Map<TaskStatus, List<Map<String, dynamic>>> tasksByStatus = {};
      for (final task in tasksWithoutPosition) {
        final status = TaskStatus.values.firstWhere(
          (s) => s.name == task['status'],
          orElse: () => TaskStatus.pending,
        );
        tasksByStatus.putIfAbsent(status, () => []).add(task);
      }

      // Asignar posiciones secuenciales por estado
      for (final entry in tasksByStatus.entries) {
        final status = entry.key;
        final tasks = entry.value;

        // Obtener la máxima posición actual para este estado
        final maxPosition = await _getMaxKanbanPositionForStatus(
          projectId,
          status,
        );

        // Actualizar cada tarea con una posición secuencial
        for (int i = 0; i < tasks.length; i++) {
          await _supabase
              .from('tasks')
              .update({'kanban_position': maxPosition + i + 1})
              .eq('id', tasks[i]['id']);
        }
      }
    } catch (e) {
      LoggingService.error(
        'Error initializing Kanban positions: $e',
        'TaskService',
      );
    }
  }

  /// Obtiene la máxima posición Kanban para un estado específico
  Future<int> _getMaxKanbanPositionForStatus(
    int projectId,
    TaskStatus status,
  ) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('kanban_position')
          .eq('project_id', projectId)
          .eq('status', status.name)
          .not('kanban_position', 'is', null)
          .order('kanban_position', ascending: false)
          .limit(1)
          .single();

      return (response['kanban_position'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Crea notificación de cambio de estado
  Future<void> _createStatusChangeNotification(
    int taskId,
    TaskStatus status,
  ) async {
    try {
      final task = await getTask(taskId);
      if (task == null) return;

      final notificationData = {
        'user_id': task.projectId, // Notificar al tutor del proyecto
        'type': 'task_status_changed',
        'title': NotificationLocalizations.getTaskStatusUpdatedTitle(),
        'message': NotificationLocalizations.getTaskStatusChangedMessage(
          task.title,
          status.name,
        ),
        'action_url': '/tasks/$taskId',
        'metadata': {'task_id': taskId, 'new_status': status.name},
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('notifications').insert(notificationData);
    } catch (e) {
      // No fallar si la notificación falla
      LoggingService.error(
        'Error al crear notificación de cambio de estado',
        e,
        'TaskStatus',
      );
    }
  }

  /// Crea notificación de asignación
  Future<void> _createAssignmentNotification(int taskId, int userId) async {
    try {
      final task = await getTask(taskId);
      if (task == null) return;

      final notificationData = {
        'user_id': userId,
        'type': 'task_assigned',
        'title': NotificationLocalizations.getTaskAssignedTitle(),
        'message': NotificationLocalizations.getTaskAssignedMessage(task.title),
        'action_url': '/tasks/$taskId',
        'metadata': {'task_id': taskId, 'project_id': task.projectId},
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('notifications').insert(notificationData);
    } catch (e) {
      // No fallar si la notificación falla
      LoggingService.error(
        'Error al crear notificación de asignación',
        e,
        'TaskAssignment',
      );
    }
  }

  /// Crea notificación de nuevo comentario
  Future<void> _createCommentNotification(int taskId, String content) async {
    try {
      final task = await getTask(taskId);
      if (task == null) return;

      // Notificar a todos los usuarios asignados a la tarea
      final assignees = await _supabase
          .from('task_assignees')
          .select('user_id')
          .eq('task_id', taskId);

      for (final assignee in assignees) {
        final commentPreview = content.length > 50
            ? '${content.substring(0, 50)}...'
            : content;
        final notificationData = {
          'user_id': assignee['user_id'],
          'type': 'new_comment',
          'title': NotificationLocalizations.getNewCommentTitle(),
          'message': NotificationLocalizations.getNewCommentMessage(
            task.title,
            commentPreview,
          ),
          'action_url': '/tasks/$taskId',
          'metadata': {'task_id': taskId, 'comment_preview': content},
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('notifications').insert(notificationData);
      }
    } catch (e) {
      // No fallar si la notificación falla
      LoggingService.error(
        'Error al crear notificación de comentario',
        e,
        'TaskComment',
      );
    }
  }
}

/// Excepción personalizada para errores de tareas
class TasksException implements Exception {
  final String message;

  const TasksException(this.message);

  @override
  String toString() => 'TasksException: $message';
}
