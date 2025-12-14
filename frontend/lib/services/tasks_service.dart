// cspell:ignore reindex recalcula recalcular
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/models.dart';
import '../utils/app_exception.dart';
import '../utils/network_error_detector.dart';
import 'supabase_interceptor.dart';
import '../utils/notification_localizations.dart';
import 'logging_service.dart';
import 'academic_permissions_service.dart';

/// Servicio para gestión de tareas y sistema Kanban.
///
/// Proporciona operaciones CRUD y funcionalidades avanzadas para tareas:
/// - Creación, edición y eliminación de tareas
/// - Gestión de asignaciones a usuarios
/// - Sistema Kanban con posicionamiento automático
/// - Filtrado y búsqueda por estado, prioridad, fecha
/// - Generación automática de tareas desde anteproyectos
/// - Gestión de hitos y dependencias
///
/// ## Funcionalidades principales:
/// - CRUD completo de tareas con validaciones
/// - Sistema Kanban con drag & drop
/// - Asignación de tareas a usuarios específicos
/// - Filtrado por estado, prioridad, fecha de vencimiento
/// - Generación automática desde anteproyectos aprobados
/// - Gestión de hitos y dependencias entre tareas
///
/// ## Seguridad:
/// - Requiere autenticación: Sí
/// - Roles permitidos: Todos (con restricciones por RLS)
/// - Políticas RLS aplicadas: Los usuarios solo ven tareas asignadas
///
/// ## Ejemplo de uso:
/// ```dart
/// final service = TasksService();
/// final tasks = await service.getTasks();
/// ```
///
/// Ver también: [Task], [TaskStatus], [TaskComplexity]
class TasksService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;
  final AcademicPermissionsService _academicPermissionsService = AcademicPermissionsService();
  static const double _positionGapThreshold = 0.0001;

  /// Obtiene todas las tareas asignadas al usuario actual.
  ///
  /// Retorna:
  /// - Lista de [Task] asignadas al usuario, ordenadas por fecha de asignación
  ///
  /// Lanza:
  /// - [AuthenticationException] si no hay usuario autenticado
  /// - [DatabaseException] si falla la consulta
  Future<List<Task>> getTasks() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error getting tasks: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene tareas del estudiante actual con información detallada.
  ///
  /// Incluye tanto tareas de proyectos como de anteproyectos con metadatos
  /// adicionales para la visualización en el dashboard del estudiante.
  ///
  /// Retorna:
  /// - Lista de mapas con tareas y metadatos asociados
  ///
  /// Lanza:
  /// - [AuthenticationException] si no hay usuario autenticado
  /// - [DatabaseException] si falla la consulta
  Future<List<Map<String, dynamic>>> getStudentTasks() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error getting student tasks: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene tareas por proyecto
  Future<List<Task>> getTasksByProject(int projectId) async {
    try {
      // Inicializar posiciones Kanban si es necesario
      await initializeKanbanPositions(projectId: projectId);

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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error getting project tasks: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene tareas del proyecto asignadas al usuario actual
  Future<List<Task>> getProjectTasksForUser(int projectId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
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

  // Los anteproyectos ya no tienen tareas - solo proyectos

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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error getting task: $e',
        originalError: e,
      );
    }
  }

  /// Crea una nueva tarea
  Future<Task> createTask(Task task) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Verificar permisos de escritura por año académico para estudiantes
      final userResponse = await _supabase
          .from('users')
          .select('role, academic_year')
          .eq('email', user.email!)
          .single();
      final userRole = userResponse['role'] as String;
      final studentAcademicYear = userResponse['academic_year'] as String?;

      if (userRole == 'student') {
        final canWrite = await _academicPermissionsService.canWriteByAcademicYear(studentAcademicYear);
        if (!canWrite) {
          throw ValidationException(
            'read_only_mode',
            technicalMessage:
                'No puedes crear tareas porque tu año académico ya no está activo.',
          );
        }
      }

      final data = task.toJson();
      // Remover campos que se generan automáticamente
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      data.remove('completed_at');

      // Obtener la siguiente posición Kanban
      if (task.projectId == null) {
        throw ValidationException(
          'missing_task_context',
          technicalMessage: 'Task context is missing',
        );
      }

      final projectExists = await _verifyProjectExists(task.projectId!);
      if (!projectExists) {
        throw ValidationException(
          'invalid_project_relation',
          technicalMessage: 'Invalid project relation',
        );
      }

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
        debugPrint('✅ Tarea ${createdTask.id} asignada exitosamente');
      } catch (e) {
        debugPrint('❌ Error asignando tarea ${createdTask.id}: $e');
        debugPrint('❌ Stack trace: ${StackTrace.current}');
        // No fallar la creación si no se puede asignar
      }

      return createdTask;
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error creating task: $e',
        originalError: e,
      );
    }
  }

  /// Actualiza una tarea existente
  Future<Task> updateTask(int id, Task task) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Verificar permisos de escritura por año académico para estudiantes
      final userResponse = await _supabase
          .from('users')
          .select('role, academic_year')
          .eq('email', user.email!)
          .single();
      final userRole = userResponse['role'] as String;
      final studentAcademicYear = userResponse['academic_year'] as String?;

      if (userRole == 'student') {
        final canWrite = await _academicPermissionsService.canWriteByAcademicYear(studentAcademicYear);
        if (!canWrite) {
          throw ValidationException(
            'read_only_mode',
            technicalMessage:
                'No puedes editar tareas porque tu año académico ya no está activo.',
          );
        }
      }

      final data = task.toJson();
      // Remover campos que no se pueden actualizar
      data.remove('id');
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();

      // Asegurar que al menos uno de project_id o anteproject_id esté presente
      // para cumplir con la restricción de la base de datos
      if (data['project_id'] == null && data['anteproject_id'] == null) {
        // Si ambos son null, mantener los valores originales de la base de datos
        final originalTask = await getTask(id);
        if (originalTask != null) {
          data['project_id'] = originalTask.projectId;
        }
      }

      // Si kanbanPosition es null, asignar una posición por defecto
      if (data['kanban_position'] == null) {
        final maxPosition = await _getMaxKanbanPosition(
          projectId: task.projectId,
        );
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error updating task: $e',
        originalError: e,
      );
    }
  }

  /// Cambia el estado de una tarea
  Future<Task> updateTaskStatus(int id, TaskStatus status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error updating task status: $e',
        originalError: e,
      );
    }
  }

  /// Asigna un usuario a una tarea
  Future<void> assignUserToTask(int taskId, int userId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error assigning user to task: $e',
        originalError: e,
      );
    }
  }

  /// Quita un usuario asignado de una tarea
  Future<void> unassignUserFromTask(int taskId, int userId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      await _supabase
          .from('task_assignees')
          .delete()
          .eq('task_id', taskId)
          .eq('user_id', userId);
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error removing user from task: $e',
        originalError: e,
      );
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
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error adding comment: $e',
        originalError: e,
      );
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error getting comments: $e',
        originalError: e,
      );
    }
  }

  /// Actualiza directamente la posición Kanban de una tarea
  Future<void> updateKanbanPosition(
    int taskId,
    double newPosition, {
    required int? projectId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      await _supabase
          .from('tasks')
          .update({
            'kanban_position': newPosition,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', taskId);

      if (projectId != null) {
        await _reindexColumn(
          projectId: projectId,
          status: await _getTaskStatus(taskId),
        );
      }
    } catch (error) {
      LoggingService.error(
        'Error al actualizar posición Kanban de la tarea $taskId',
        error,
        'TasksService.updateKanbanPosition',
      );
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(error)) {
        throw SupabaseErrorInterceptor.handleError(error);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(error)) {
        throw NetworkErrorDetector.detectNetworkError(error);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error updating Kanban position: $error',
        originalError: error,
      );
    }
  }

  Future<TaskStatus> _getTaskStatus(int taskId) async {
    final response = await _supabase
        .from('tasks')
        .select('status')
        .eq('id', taskId)
        .single();

    return TaskStatus.values.firstWhere(
      (status) => status.dbValue == response['status'],
      orElse: () => TaskStatus.pending,
    );
  }

  Future<Task> moveTask({
    required int taskId,
    required TaskStatus fromStatus,
    required TaskStatus toStatus,
    required int targetIndex,
    required int? projectId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException(
        'not_authenticated',
        technicalMessage: 'User not authenticated',
      );
    }

    try {
      final currentTask = await getTask(taskId);
      if (currentTask == null) {
        throw ValidationException(
          'resource_not_found',
          technicalMessage: 'Task not found',
        );
      }

      final effectiveProjectId = projectId ?? currentTask.projectId;

      if (fromStatus != toStatus) {
        await _removeTaskFromColumn(
          projectId: effectiveProjectId,
          status: fromStatus,
          taskId: taskId,
        );
      }

      final positionResult = await _computeTargetPosition(
        projectId: effectiveProjectId,
        toStatus: toStatus,
        excludeTaskId: taskId,
        targetIndex: targetIndex,
      );
      if (positionResult.reindexed) {
        LoggingService.info(
          'Reindex ejecutado para ${toStatus.name} (projectId: $effectiveProjectId)',
          'TasksService.moveTask',
        );
      }

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

      LoggingService.info(
        'Tarea $taskId movida de ${fromStatus.name} a ${toStatus.name} en posición ${positionResult.position}',
        'TasksService.moveTask',
      );

      return Task.fromJson(updatedTask);
    } catch (error, stackTrace) {
      LoggingService.error(
        'Error moviendo la tarea $taskId',
        error,
        'TasksService.moveTask',
      );
      LoggingService.debug('$stackTrace', 'TasksService.moveTask');
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(error)) {
        throw SupabaseErrorInterceptor.handleError(error);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(error)) {
        throw NetworkErrorDetector.detectNetworkError(error);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error moving task: $error',
        originalError: error,
      );
    }
  }

  Future<_MovePositionResult> _computeTargetPosition({
    required int? projectId,
    required TaskStatus toStatus,
    required int excludeTaskId,
    required int targetIndex,
  }) async {
    var query = _supabase
        .from('tasks')
        .select('id, kanban_position')
        .eq('status', toStatus.dbValue);

    if (projectId != null) {
      query = query.eq('project_id', projectId);
    } else {
      query = query.isFilter('project_id', null);
    }

    final List<Map<String, dynamic>> rows = await query;

    final List<Map<String, dynamic>> tasks =
        rows
            .where((row) => row['id'] != excludeTaskId)
            .map<Map<String, dynamic>>((row) => row)
            .toList()
          ..sort(
            (a, b) => (a['kanban_position'] as num).compareTo(
              b['kanban_position'] as num,
            ),
          );

    if (tasks.isEmpty) {
      return const _MovePositionResult(position: 1.0, reindexed: false);
    }

    if (targetIndex <= 0) {
      final double firstPosition = (tasks.first['kanban_position'] as num)
          .toDouble();
      final double newPosition = firstPosition / 2;
      if (firstPosition - newPosition > _positionGapThreshold) {
        return _MovePositionResult(position: newPosition, reindexed: false);
      }
      await _reindexColumn(projectId: projectId, status: toStatus);
      return const _MovePositionResult(position: 1.0, reindexed: true);
    }

    if (targetIndex >= tasks.length) {
      final double lastPosition = (tasks.last['kanban_position'] as num)
          .toDouble();
      final double newPosition = lastPosition + 1;
      if (newPosition - lastPosition > _positionGapThreshold) {
        return _MovePositionResult(position: newPosition, reindexed: false);
      }
      await _reindexColumn(projectId: projectId, status: toStatus);
      return const _MovePositionResult(position: 1.0, reindexed: true);
    }

    final double previousPosition =
        (tasks[targetIndex - 1]['kanban_position'] as num).toDouble();
    final double nextPosition = (tasks[targetIndex]['kanban_position'] as num)
        .toDouble();
    final double gap = nextPosition - previousPosition;

    if (gap > _positionGapThreshold) {
      return _MovePositionResult(
        position: (previousPosition + nextPosition) / 2,
        reindexed: false,
      );
    }

    await _reindexColumn(projectId: projectId, status: toStatus);
    return _MovePositionResult(position: previousPosition + 1, reindexed: true);
  }

  Future<void> _removeTaskFromColumn({
    required int? projectId,
    required TaskStatus status,
    required int taskId,
  }) async {
    var query = _supabase
        .from('tasks')
        .select('id')
        .eq('status', status.dbValue);

    if (projectId != null) {
      query = query.eq('project_id', projectId);
    } else {
      query = query.isFilter('project_id', null);
    }

    final tasks = await query.order('kanban_position');

    if (tasks.any((row) => row['id'] == taskId)) {
      await _reindexColumn(projectId: projectId, status: status);
    }
  }

  Future<void> _reindexColumn({
    required int? projectId,
    required TaskStatus status,
  }) async {
    var query = _supabase
        .from('tasks')
        .select('id')
        .eq('status', status.dbValue);

    if (projectId != null) {
      query = query.eq('project_id', projectId);
    } else {
      query = query.isFilter('project_id', null);
    }

    final tasks = await query.order('kanban_position');

    double position = 1;
    for (final task in tasks) {
      await _supabase
          .from('tasks')
          .update({
            'kanban_position': position,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', task['id']);
      position += 1;
    }
  }

  /// Recalcula las posiciones Kanban para evitar conflictos
  Future<void> recalculateKanbanPositions({required int? projectId}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      for (final status in TaskStatus.values) {
        await _reindexColumn(projectId: projectId, status: status);
      }
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error recalculating Kanban positions: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene tareas por estado
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('*')
          .eq('status', status.dbValue)
          .order('kanban_position', ascending: true);

      return response.map<Task>(Task.fromJson).toList();
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error getting tasks by status: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene tareas por complejidad
  Future<List<Task>> getTasksByComplexity(TaskComplexity complexity) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('*')
          .eq('complexity', complexity.dbValue)
          .order('created_at', ascending: false);

      return response.map<Task>(Task.fromJson).toList();
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error getting tasks by complexity: $e',
        originalError: e,
      );
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

  /// Asigna una tarea a un usuario
  Future<void> _assignTaskToUser(int taskId, String userEmail) async {
    try {
      debugPrint(
        '🔍 Iniciando asignación de tarea $taskId al usuario $userEmail',
      );

      // Obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id, email')
          .eq('email', userEmail)
          .single();

      final userId = userResponse['id'] as int;
      final userEmailFromDB = userResponse['email'] as String;
      debugPrint(
        '🔍 Usuario encontrado con ID: $userId, email: $userEmailFromDB',
      );

      // Verificar si ya existe la asignación
      final existingAssignment = await _supabase
          .from('task_assignees')
          .select('id')
          .eq('task_id', taskId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingAssignment != null) {
        debugPrint('⚠️ La tarea $taskId ya está asignada al usuario $userId');
        return;
      }

      // Crear la asignación en task_assignees
      await _supabase.from('task_assignees').insert({
        'task_id': taskId,
        'user_id': userId,
        'assigned_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Tarea $taskId asignada al usuario $userId');
    } catch (e) {
      debugPrint('❌ Error asignando tarea al usuario: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      // No fallar la creación de la tarea si no se puede asignar
    }
  }

  /// Elimina una tarea
  Future<void> deleteTask(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Verificar permisos de escritura por año académico para estudiantes
      final userResponse = await _supabase
          .from('users')
          .select('role, academic_year')
          .eq('email', user.email!)
          .single();
      final userRole = userResponse['role'] as String;
      final studentAcademicYear = userResponse['academic_year'] as String?;

      if (userRole == 'student') {
        final canWrite = await _academicPermissionsService.canWriteByAcademicYear(studentAcademicYear);
        if (!canWrite) {
          throw ValidationException(
            'read_only_mode',
            technicalMessage:
                'No puedes eliminar tareas porque tu año académico ya no está activo.',
          );
        }
      }

      // Verificar que la tarea no esté completada
      final task = await getTask(id);
      if (task?.status == TaskStatus.completed) {
        throw BusinessLogicException(
          'cannot_delete_completed_task',
          technicalMessage: 'Cannot delete a completed task',
        );
      }

      await _supabase.from('tasks').delete().eq('id', id);
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error deleting task: $e',
        originalError: e,
      );
    }
  }

  // Métodos privados de ayuda

  /// Obtiene la máxima posición Kanban para un proyecto
  Future<double> _getMaxKanbanPosition({required int? projectId}) async {
    try {
      var query = _supabase.from('tasks').select('kanban_position');

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      } else {
        query = query.isFilter('project_id', null);
      }

      final response = await query
          .not('kanban_position', 'is', null)
          .order('kanban_position', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return 0;
      }

      return (response['kanban_position'] as num).toDouble();
    } catch (e) {
      return 0;
    }
  }

  /// Inicializa las posiciones Kanban para tareas que no las tienen
  Future<void> initializeKanbanPositions({required int? projectId}) async {
    try {
      // Obtener tareas sin posición Kanban
      var query = _supabase
          .from('tasks')
          .select('id, status')
          .isFilter('kanban_position', null);

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      } else {
        query = query.isFilter('project_id', null);
      }

      final tasksWithoutPosition = await query;

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
          projectId: projectId,
          status: status,
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
  Future<double> _getMaxKanbanPositionForStatus({
    required int? projectId,
    required TaskStatus status,
  }) async {
    try {
      var query = _supabase
          .from('tasks')
          .select('kanban_position')
          .eq('status', status.dbValue);

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      } else {
        query = query.isFilter('project_id', null);
      }

      final response = await query
          .not('kanban_position', 'is', null)
          .order('kanban_position', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return 0;
      }

      return (response['kanban_position'] as num).toDouble();
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

      final assignees = await _supabase
          .from('task_assignees')
          .select('user_id')
          .eq('task_id', taskId);

      if (assignees.isEmpty) {
        return;
      }

      final List<Map<String, dynamic>> notifications = assignees.map((
        assignee,
      ) {
        return {
          'user_id': assignee['user_id'],
          'type': 'task_status_changed',
          'title': NotificationLocalizations.getTaskStatusUpdatedTitle(),
          'message': NotificationLocalizations.getTaskStatusChangedMessage(
            task.title,
            status.dbValue,
          ),
          'action_url': '/tasks/$taskId',
          'metadata': {'task_id': taskId, 'new_status': status.dbValue},
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await _supabase.from('notifications').insert(notifications);
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

  Future<bool> _verifyProjectExists(int projectId) async {
    final response = await _supabase
        .from('projects')
        .select('id')
        .eq('id', projectId)
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  // Los anteproyectos ya no tienen tareas - solo proyectos
}

/// Excepción personalizada para errores de tareas
class TasksException implements Exception {
  final String message;

  const TasksException(this.message);

  @override
  String toString() => 'TasksException: $message';
}

class _MovePositionResult {
  final double position;
  final bool reindexed;

  const _MovePositionResult({required this.position, required this.reindexed});
}
