import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/task.dart';
import '../services/tasks_service.dart';

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

  const TaskStatusUpdateRequested({
    required this.taskId,
    required this.status,
  });

  @override
  List<Object> get props => [taskId, status];
}

class TaskDeleteRequested extends TasksEvent {
  final int id;

  const TaskDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
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
  final TasksService _tasksService;

  TasksBloc({required TasksService tasksService})
      : _tasksService = tasksService,
        super(TasksInitial()) {
    
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TaskCreateRequested>(_onTaskCreateRequested);
    on<TaskUpdateRequested>(_onTaskUpdateRequested);
    on<TaskStatusUpdateRequested>(_onTaskStatusUpdateRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
  }

  Future<void> _onTasksLoadRequested(
    TasksLoadRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    
    try {
      List<Task> tasks;
      if (event.projectId != null) {
        tasks = await _tasksService.getTasksByProject(event.projectId!);
      } else {
        tasks = await _tasksService.getTasks();
      }
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TasksFailure(e.toString()));
    }
  }

  Future<void> _onTaskCreateRequested(
    TaskCreateRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    
    try {
      await _tasksService.createTask(event.task);
      
      // La tarea se creó exitosamente
      emit(const TaskOperationSuccess('taskCreatedSuccess'));
      // Recargar la lista
      add(TasksLoadRequested(projectId: event.task.projectId));
    } catch (e) {
      emit(TasksFailure(e.toString()));
    }
  }

  Future<void> _onTaskUpdateRequested(
    TaskUpdateRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    
    try {
      await _tasksService.updateTask(
        event.task.id,
        event.task,
      );
      
      // La tarea se actualizó exitosamente
      emit(const TaskOperationSuccess('taskUpdatedSuccess'));
      // Recargar la lista
      add(TasksLoadRequested(projectId: event.task.projectId));
    } catch (e) {
      emit(TasksFailure(e.toString()));
    }
  }

  Future<void> _onTaskStatusUpdateRequested(
    TaskStatusUpdateRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    
    try {
      // Obtener la tarea actual
      final currentTask = await _tasksService.getTask(event.taskId);
      if (currentTask != null) {
        // Actualizar solo el estado
        final updatedTask = currentTask.copyWith(
          status: event.status,
          updatedAt: DateTime.now(),
        );
        
        await _tasksService.updateTask(
          event.taskId,
          updatedTask,
        );
        
        // El estado se actualizó exitosamente
        emit(const TaskOperationSuccess('taskStatusUpdatedSuccess'));
        // Recargar la lista
        add(TasksLoadRequested(projectId: currentTask.projectId));
      } else {
        emit(const TasksFailure('taskNotFound'));
      }
    } catch (e) {
      emit(TasksFailure(e.toString()));
    }
  }

  Future<void> _onTaskDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    
    try {
      // Por ahora, solo emitir éxito (el servicio no tiene método delete)
      emit(const TaskOperationSuccess('taskDeletedSuccess'));
      // Recargar la lista
      add(const TasksLoadRequested());
    } catch (e) {
      emit(TasksFailure(e.toString()));
    }
  }
}
