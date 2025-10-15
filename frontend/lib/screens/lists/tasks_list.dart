import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../models/task.dart';
import '../../blocs/tasks_bloc.dart';
import '../../utils/task_localizations.dart';
import '../forms/task_form.dart';
import '../details/task_detail_screen.dart';

class TasksList extends StatefulWidget {
  final int? projectId;

  const TasksList({super.key, required this.projectId});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  @override
  void initState() {
    super.initState();
    // Cargar tareas al inicializar
    context.read<TasksBloc>().add(
      TasksLoadRequested(projectId: widget.projectId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tasksListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TasksBloc>().add(
              TasksLoadRequested(projectId: widget.projectId),
            ),
            tooltip: l10n.tasksListRefresh,
          ),
        ],
      ),
      body: BlocBuilder<TasksBloc, TasksState>(
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

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TasksBloc>().add(
                  TasksLoadRequested(projectId: widget.projectId),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskCard(task, l10n);
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        child: const Icon(Icons.add),
      ),
    );
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
      case TaskStatus.underReview:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
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
}
