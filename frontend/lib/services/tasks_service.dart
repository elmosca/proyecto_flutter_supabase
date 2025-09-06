import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/models.dart';
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
          .eq('user_id', user.id)
          .order('assigned_at', ascending: false);

      return response.map<Task>((json) {
        final taskData = json['tasks'] as Map<String, dynamic>;
        return Task.fromJson(taskData);
      }).toList();
    } catch (e) {
      throw TasksException('Error al obtener tareas: $e');
    }
  }

  /// Obtiene tareas por proyecto
  Future<List<Task>> getTasksByProject(int projectId) async {
    try {
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
      final maxPosition = await _getMaxKanbanPosition(task.projectId);
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

      await _supabase
          .from('tasks')
          .update(updateData)
          .eq('id', id);

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

      await _supabase
          .from('task_assignees')
          .upsert({
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
  Future<Comment> addComment(int taskId, String content, {bool isInternal = false}) async {
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
      throw TasksException('Error al obtener tareas con fecha límite próxima: $e');
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

      await _supabase
          .from('tasks')
          .delete()
          .eq('id', id);
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
          .order('kanban_position', ascending: false)
          .limit(1)
          .single();

      return response['kanban_position'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Crea notificación de cambio de estado
  Future<void> _createStatusChangeNotification(int taskId, TaskStatus status) async {
    try {
      final task = await getTask(taskId);
      if (task == null) return;

      final notificationData = {
        'user_id': task.projectId, // Notificar al tutor del proyecto
        'type': 'task_status_changed',
        'title': 'Estado de tarea actualizado',
        'message': 'La tarea "${task.title}" cambió a estado: ${_getStatusDisplayName(status)}',
        'action_url': '/tasks/$taskId',
        'metadata': {
          'task_id': taskId,
          'new_status': status.name,
        },
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('notifications')
          .insert(notificationData);
    } catch (e) {
      // No fallar si la notificación falla
      LoggingService.error('Error al crear notificación de cambio de estado', e, 'TaskStatus');
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
        'title': 'Tarea asignada',
        'message': 'Se te ha asignado la tarea: "${task.title}"',
        'action_url': '/tasks/$taskId',
        'metadata': {
          'task_id': taskId,
          'project_id': task.projectId,
        },
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('notifications')
          .insert(notificationData);
    } catch (e) {
      // No fallar si la notificación falla
      LoggingService.error('Error al crear notificación de asignación', e, 'TaskAssignment');
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
        final notificationData = {
          'user_id': assignee['user_id'],
          'type': 'new_comment',
          'title': 'Nuevo comentario en tarea',
          'message': 'Nuevo comentario en "${task.title}": ${content.length > 50 ? '${content.substring(0, 50)}...' : content}',
          'action_url': '/tasks/$taskId',
          'metadata': {
            'task_id': taskId,
            'comment_preview': content,
          },
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase
            .from('notifications')
            .insert(notificationData);
      }
    } catch (e) {
      // No fallar si la notificación falla
      LoggingService.error('Error al crear notificación de comentario', e, 'TaskComment');
    }
  }

  /// Helper method to get status display name without BuildContext
  String _getStatusDisplayName(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pendiente';
      case TaskStatus.inProgress:
        return 'En Progreso';
      case TaskStatus.underReview:
        return 'En Revisión';
      case TaskStatus.completed:
        return 'Completada';
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
