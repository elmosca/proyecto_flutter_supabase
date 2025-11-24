import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/task.dart';
import '../services/tasks_service.dart';
import '../utils/app_exception.dart';
import '../utils/error_translator.dart';

// cspell:ignore anteproject reordenamiento

// Events
abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class TasksLoadRequested extends TasksEvent {
  final int? projectId;

  const TasksLoadRequested({this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class TaskCreateRequested extends TasksEvent {
  final Task task;

  const TaskCreateRequested(this.task);

  @override
  List<Object> get props => [task];
}

class TaskUpdateRequested extends TasksEvent {
  final Task task;

  const TaskUpdateRequested(this.task);

  @override
  List<Object> get props => [task];
}

class TaskStatusUpdateRequested extends TasksEvent {
  final int taskId;
  final TaskStatus status;

  const TaskStatusUpdateRequested({required this.taskId, required this.status});

  @override
  List<Object> get props => [taskId, status];
}

class TaskDeleteRequested extends TasksEvent {
  final int id;

  const TaskDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class TaskReorderRequested extends TasksEvent {
  final int taskId;
  final TaskStatus newStatus;
  final double newPosition;

  const TaskReorderRequested({
    required this.taskId,
    required this.newStatus,
    required this.newPosition,
  });

  @override
  List<Object> get props => [taskId, newStatus, newPosition];
}

class TaskPositionUpdateRequested extends TasksEvent {
  final int taskId;
  final double newPosition;

  const TaskPositionUpdateRequested({
    required this.taskId,
    required this.newPosition,
  });

  @override
  List<Object> get props => [taskId, newPosition];
}

// States
abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<Task> tasks;

  const TasksLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class TasksFailure extends TasksState {
  final String messageKey;

  const TasksFailure(this.messageKey);

  @override
  List<Object> get props => [messageKey];
}

class TaskOperationSuccess extends TasksState {
  final String messageKey;

  const TaskOperationSuccess(this.messageKey);

  @override
  List<Object> get props => [messageKey];
}

// BLoC
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TasksService tasksService;
  List<Task> _cachedTasks = const [];
  int? _currentProjectId;

  TasksBloc({required this.tasksService}) : super(TasksInitial()) {
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TaskCreateRequested>(_onTaskCreateRequested);
    on<TaskUpdateRequested>(_onTaskUpdateRequested);
    on<TaskStatusUpdateRequested>(_onTaskStatusUpdateRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
    on<TaskReorderRequested>(_onTaskReorderRequested);
    on<TaskPositionUpdateRequested>(_onTaskPositionUpdateRequested);
  }

  Future<void> _onTasksLoadRequested(
    TasksLoadRequested event,
    Emitter<TasksState> emit,
  ) async {
    _currentProjectId = event.projectId;
    emit(TasksLoading());

    try {
      List<Task> tasks;
      if (event.projectId != null) {
        tasks = await tasksService.getProjectTasksForUser(event.projectId!);
      } else {
        tasks = await tasksService.getTasks();
      }
      _cachedTasks = List<Task>.from(tasks);
      emit(TasksLoaded(tasks));
    } catch (e) {
      // Manejar errores usando el nuevo sistema
      if (e is AppException) {
        final fallbackMessage = ErrorTranslator.getFallbackMessage(e);
        emit(TasksFailure(fallbackMessage));
      } else {
        emit(TasksFailure('Error inesperado: ${e.toString()}'));
      }
    }
  }

  Future<void> _onTaskCreateRequested(
    TaskCreateRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());

    try {
      await tasksService.createTask(event.task);

      // La tarea se creó exitosamente
      emit(const TaskOperationSuccess('taskCreatedSuccess'));
      // Recargar la lista
      add(TasksLoadRequested(projectId: event.task.projectId));
    } catch (e) {
      // Manejar errores usando el nuevo sistema
      if (e is AppException) {
        final fallbackMessage = ErrorTranslator.getFallbackMessage(e);
        emit(TasksFailure(fallbackMessage));
      } else {
        emit(TasksFailure('Error inesperado: ${e.toString()}'));
      }
    }
  }

  Future<void> _onTaskUpdateRequested(
    TaskUpdateRequested event,
    Emitter<TasksState> emit,
  ) async {
    List<Task> baseTasks;
    if (state is TasksLoaded) {
      baseTasks = List<Task>.from((state as TasksLoaded).tasks);
    } else {
      baseTasks = List<Task>.from(_cachedTasks);
    }

    if (baseTasks.isEmpty) {
      try {
        await tasksService.updateTask(event.task.id, event.task);
        emit(const TaskOperationSuccess('taskUpdatedSuccess'));
        add(
          TasksLoadRequested(
            projectId: event.task.projectId ?? _currentProjectId,
          ),
        );
      } catch (error) {
        // Manejar errores usando el nuevo sistema
        if (error is AppException) {
          final fallbackMessage = ErrorTranslator.getFallbackMessage(error);
          emit(TasksFailure(fallbackMessage));
        } else {
          emit(TasksFailure('Error inesperado: ${error.toString()}'));
        }
      }
      return;
    }

    final originalTasks = List<Task>.from(baseTasks);
    final taskIndex = originalTasks.indexWhere(
      (task) => task.id == event.task.id,
    );
    if (taskIndex == -1) {
      emit(const TasksFailure('taskNotFound'));
      return;
    }

    final updatedTasks = List<Task>.from(originalTasks);
    updatedTasks[taskIndex] = event.task;
    _cachedTasks = List<Task>.from(updatedTasks);
    emit(TasksLoaded(updatedTasks));

    try {
      await tasksService.updateTask(event.task.id, event.task);
      emit(const TaskOperationSuccess('taskUpdatedSuccess'));
      add(
        TasksLoadRequested(
          projectId: event.task.projectId ?? _currentProjectId,
        ),
      );
    } catch (e) {
      _cachedTasks = List<Task>.from(originalTasks);
      emit(TasksLoaded(originalTasks));
      emit(TasksFailure(e.toString()));
    }
  }

  Future<void> _onTaskStatusUpdateRequested(
    TaskStatusUpdateRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());

    try {
      final updatedTask = await tasksService.updateTaskStatus(
        event.taskId,
        event.status,
      );

      emit(const TaskOperationSuccess('taskStatusUpdatedSuccess'));
      add(
        TasksLoadRequested(
          projectId: updatedTask.projectId ?? _currentProjectId,
        ),
      );
    } catch (e) {
      // Manejar errores usando el nuevo sistema
      if (e is AppException) {
        final fallbackMessage = ErrorTranslator.getFallbackMessage(e);
        emit(TasksFailure(fallbackMessage));
      } else {
        emit(TasksFailure('Error inesperado: ${e.toString()}'));
      }
    }
  }

  Future<void> _onTaskDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());

    try {
      await tasksService.deleteTask(event.id);
      emit(const TaskOperationSuccess('taskDeletedSuccess'));
      add(TasksLoadRequested(projectId: _currentProjectId));
    } catch (e) {
      // Manejar errores usando el nuevo sistema
      if (e is AppException) {
        final fallbackMessage = ErrorTranslator.getFallbackMessage(e);
        emit(TasksFailure(fallbackMessage));
      } else {
        emit(TasksFailure('Error inesperado: ${e.toString()}'));
      }
    }
  }

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

      // Emitir el estado actualizado con la tarea del servidor
      emit(TasksLoaded(_cachedTasks));
      emit(const TaskOperationSuccess('taskReorderedSuccess'));
      
      // Recargar desde el servidor para asegurar sincronización completa
      // Usar un pequeño delay para evitar race conditions y asegurar que
      // la actualización en la BD se haya propagado
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

  Future<void> _onTaskPositionUpdateRequested(
    TaskPositionUpdateRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final task = await tasksService.getTask(event.taskId);
      if (task == null) {
        emit(const TasksFailure('taskNotFound'));
        return;
      }

      await tasksService.updateKanbanPosition(
        event.taskId,
        event.newPosition,
        projectId: task.projectId,
      );

      emit(const TaskOperationSuccess('taskPositionUpdatedSuccess'));
      add(TasksLoadRequested(projectId: task.projectId ?? _currentProjectId));
    } catch (e) {
      // Manejar errores usando el nuevo sistema
      if (e is AppException) {
        final fallbackMessage = ErrorTranslator.getFallbackMessage(e);
        emit(TasksFailure(fallbackMessage));
      } else {
        emit(TasksFailure('Error inesperado: ${e.toString()}'));
      }
    }
  }

  List<Task> _buildOptimisticState({
    required List<Task> tasks,
    required int taskId,
    required TaskStatus fromStatus,
    required TaskStatus toStatus,
    required double targetIndex,
  }) {
    // Crear una copia de las tareas y remover la tarea que se está moviendo
    final workingTasks = List<Task>.from(tasks);
    final movingIndex = workingTasks.indexWhere((task) => task.id == taskId);

    if (movingIndex == -1) {
      return tasks;
    }

    // Remover la tarea de su posición actual
    final movingTask = workingTasks.removeAt(movingIndex);
    
    // Actualizar la tarea con el nuevo estado y posición
    final updatedTask = movingTask.copyWith(
      status: toStatus,
      kanbanPosition: targetIndex,
      updatedAt: DateTime.now(),
    );

    // Insertar la tarea en la nueva columna
    return _insertTaskIntoColumn(
      tasks: workingTasks,
      task: updatedTask,
      fromStatus: fromStatus,
      toStatus: toStatus,
      targetIndex: targetIndex,
    );
  }

  List<Task> _insertTaskIntoColumn({
    required List<Task> tasks,
    required Task task,
    required TaskStatus fromStatus,
    required TaskStatus toStatus,
    required double targetIndex,
  }) {
    final insertionIndex = _calculateAdjustedTargetIndex(
      tasks: tasks,
      taskId: task.id,
      fromStatus: fromStatus,
      toStatus: toStatus,
      targetIndex: targetIndex,
    );

    final result = <Task>[];
    int columnPosition = 0;
    bool inserted = false;

    for (final current in tasks) {
      if (current.status == toStatus) {
        if (columnPosition == insertionIndex && !inserted) {
          result.add(task);
          inserted = true;
        }
        result.add(current);
        columnPosition++;
      } else {
        result.add(current);
      }
    }

    if (!inserted) {
      result.add(task);
    }

    return result;
  }

  int _calculateAdjustedTargetIndex({
    required List<Task> tasks,
    required int taskId,
    required TaskStatus fromStatus,
    required TaskStatus toStatus,
    required double targetIndex,
  }) {
    final destinationTasks =
        tasks
            .where((task) => task.status == toStatus && task.id != taskId)
            .toList()
          ..sort(
            (a, b) => (a.kanbanPosition ?? 0).compareTo(b.kanbanPosition ?? 0),
          );

    int adjustedIndex = targetIndex.floor();

    if (fromStatus == toStatus) {
      final sourceTasks =
          tasks.where((task) => task.status == fromStatus).toList()..sort(
            (a, b) => (a.kanbanPosition ?? 0).compareTo(b.kanbanPosition ?? 0),
          );

      final originalIndex = sourceTasks.indexWhere((task) => task.id == taskId);

      if (originalIndex != -1 && adjustedIndex > originalIndex) {
        adjustedIndex -= 1;
      }
    }

    if (adjustedIndex < 0) {
      adjustedIndex = 0;
    } else if (adjustedIndex > destinationTasks.length) {
      adjustedIndex = destinationTasks.length;
    }

    return adjustedIndex;
  }
}
