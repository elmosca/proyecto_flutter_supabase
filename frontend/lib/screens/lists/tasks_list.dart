import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../blocs/tasks_bloc.dart';
import '../../utils/task_localizations.dart';
import '../../widgets/navigation/app_bar_actions.dart';
import '../forms/task_form.dart';

class TasksList extends StatefulWidget {
  final int? projectId;
  final bool isEmbedded;

  const TasksList({
    super.key,
    required this.projectId,
    this.isEmbedded = false,
  });

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    // Cargar tareas al inicializar
    context.read<TasksBloc>().add(
      TasksLoadRequested(projectId: widget.projectId),
    );
  }

  Future<void> _loadCurrentUser() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _currentUser = authState.user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final body = BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TasksFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.messageKey,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TasksBloc>().add(
                      TasksLoadRequested(projectId: widget.projectId),
                    ),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          } else if (state is TasksLoaded) {
            final tasks = state.tasks;

            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      l10n.tasksListEmpty,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _createTask,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.taskCreateButton),
                    ),
                  ],
                ),
              );
            }

            // Agrupar tareas por estado
            final tasksByStatus = _groupTasksByStatus(tasks);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TasksBloc>().add(
                  TasksLoadRequested(projectId: widget.projectId),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _getTotalSections(tasksByStatus),
                itemBuilder: (context, index) {
                  return _buildSectionByIndex(index, tasksByStatus, l10n);
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      );

    if (widget.isEmbedded) {
      return body;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.tasksListTitle),
          actions: _currentUser != null
              ? AppBarActions.build(
                  context,
                  _currentUser!,
                  additionalActions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => context.read<TasksBloc>().add(
                        TasksLoadRequested(projectId: widget.projectId),
                      ),
                      tooltip: l10n.tasksListRefresh,
                    ),
                  ],
                )
              : [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => context.read<TasksBloc>().add(
                      TasksLoadRequested(projectId: widget.projectId),
                    ),
                    tooltip: l10n.tasksListRefresh,
                  ),
                ],
        ),
        body: body,
        floatingActionButton: FloatingActionButton(
          onPressed: _createTask,
          child: const Icon(Icons.add),
        ),
      );
    }
  }

  Widget _buildTaskCard(Task task, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.status.isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(task.status, l10n),
                const SizedBox(width: 8),
                _buildComplexityChip(task.complexity, l10n),
                if (task.estimatedHours != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('${task.estimatedHours}h'),
                    backgroundColor: Colors.blue[100],
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
            if (task.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Vence: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTaskAction(value, task),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(l10n.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _viewTaskDetails(task),
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status, AppLocalizations l10n) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case TaskStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case TaskStatus.inProgress:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case TaskStatus.completed:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
    }

    return Chip(
      label: Text(
        TaskLocalizations.getTaskStatusDisplayName(status, l10n),
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildComplexityChip(
    TaskComplexity complexity,
    AppLocalizations l10n,
  ) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (complexity) {
      case TaskComplexity.simple:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case TaskComplexity.medium:
        backgroundColor = Colors.yellow[100]!;
        textColor = Colors.yellow[800]!;
        break;
      case TaskComplexity.complex:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
    }

    return Chip(
      label: Text(
        TaskLocalizations.getTaskComplexityDisplayName(complexity, l10n),
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }

  void _createTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<TasksBloc>(),
          child: TaskForm(projectId: widget.projectId),
        ),
      ),
    );
  }

  void _editTask(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<TasksBloc>(),
          child: TaskForm(projectId: widget.projectId, task: task),
        ),
      ),
    );
  }

  void _viewTaskDetails(Task task) {
    if (_currentUser != null) {
      context.go('/tasks/${task.id}', extra: _currentUser);
    } else {
      // Cargar usuario si no está disponible
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.go('/tasks/${task.id}', extra: authState.user);
      } else {
        // Fallback: intentar obtener usuario del AuthBloc
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          context.go('/tasks/${task.id}', extra: authState.user);
        }
        // Si no hay usuario autenticado, no navegar (no debería pasar)
      }
    }
  }

  void _handleTaskAction(String action, Task task) {
    switch (action) {
      case 'edit':
        _editTask(task);
        break;
      case 'delete':
        _showDeleteConfirmation(task);
        break;
    }
  }

  void _showDeleteConfirmation(Task task) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(
          '¿Estás seguro de que quieres eliminar la tarea "${task.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TasksBloc>().add(TaskDeleteRequested(task.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  /// Agrupa las tareas por estado
  Map<TaskStatus, List<Task>> _groupTasksByStatus(List<Task> tasks) {
    final Map<TaskStatus, List<Task>> grouped = {
      TaskStatus.pending: [],
      TaskStatus.inProgress: [],
      TaskStatus.completed: [],
    };

    for (final task in tasks) {
      grouped[task.status]?.add(task);
    }

    return grouped;
  }

  /// Obtiene el número total de secciones (encabezados + tareas)
  int _getTotalSections(Map<TaskStatus, List<Task>> tasksByStatus) {
    int count = 0;
    for (final tasks in tasksByStatus.values) {
      if (tasks.isNotEmpty) {
        count += 1 + tasks.length; // 1 para el encabezado + tareas
      }
    }
    return count;
  }

  /// Construye una sección o tarea según el índice
  Widget _buildSectionByIndex(
    int index,
    Map<TaskStatus, List<Task>> tasksByStatus,
    AppLocalizations l10n,
  ) {
    int currentIndex = 0;
    
    // Orden de estados: Pendiente, En Progreso, Completada
    final statusOrder = [
      TaskStatus.pending,
      TaskStatus.inProgress,
      TaskStatus.completed,
    ];

    for (final status in statusOrder) {
      final tasks = tasksByStatus[status] ?? [];
      if (tasks.isEmpty) continue;

      // Encabezado de sección
      if (index == currentIndex) {
        return _buildStatusHeader(status, tasks.length, l10n);
      }
      currentIndex++;

      // Tareas de esta sección
      for (final task in tasks) {
        if (index == currentIndex) {
          return _buildTaskCard(task, l10n);
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  /// Construye el encabezado de una sección de estado
  Widget _buildStatusHeader(
    TaskStatus status,
    int taskCount,
    AppLocalizations l10n,
  ) {
    String title;
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case TaskStatus.pending:
        title = TaskLocalizations.getTaskStatusDisplayName(status, l10n);
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.schedule;
        break;
      case TaskStatus.inProgress:
        title = TaskLocalizations.getTaskStatusDisplayName(status, l10n);
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        icon = Icons.play_circle_outline;
        break;
      case TaskStatus.completed:
        title = TaskLocalizations.getTaskStatusDisplayName(status, l10n);
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$taskCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
