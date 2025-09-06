import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../models/task.dart';
import '../../blocs/tasks_bloc.dart';
import '../../utils/task_localizations.dart';
import '../forms/task_form.dart';

class KanbanBoard extends StatefulWidget {
  final int projectId;

  const KanbanBoard({
    super.key,
    required this.projectId,
  });

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  @override
  void initState() {
    super.initState();
    // Cargar tareas al inicializar
    context.read<TasksBloc>().add(TasksLoadRequested(projectId: widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kanbanBoardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TasksBloc>().add(TasksLoadRequested(projectId: widget.projectId)),
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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.messageKey,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TasksBloc>().add(TasksLoadRequested(projectId: widget.projectId)),
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
                    Icon(
                      Icons.dashboard,
                      size: 64,
                      color: Colors.grey[400],
                    ),
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
                context.read<TasksBloc>().add(TasksLoadRequested(projectId: widget.projectId));
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumn(TaskStatus.pending, tasks, l10n),
                    _buildColumn(TaskStatus.inProgress, tasks, l10n),
                    _buildColumn(TaskStatus.underReview, tasks, l10n),
                    _buildColumn(TaskStatus.completed, tasks, l10n),
                  ],
                ),
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

  Widget _buildColumn(TaskStatus status, List<Task> tasks, AppLocalizations l10n) {
    final columnTasks = tasks.where((task) => task.status == status).toList();
    final columnTitle = _getColumnTitle(status, l10n);
    final columnColor = _getColumnColor(status);

    return Container(
      width: 300,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: columnColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  columnTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${columnTasks.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: columnTasks.length,
              itemBuilder: (context, index) {
                final task = columnTasks[index];
                return _buildTaskCard(task, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _editTask(task),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildComplexityChip(task.complexity, l10n),
                  if (task.estimatedHours != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${task.estimatedHours}h',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (task.dueDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${task.dueDate!.day}/${task.dueDate!.month}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplexityChip(TaskComplexity complexity, AppLocalizations l10n) {
    Color backgroundColor;
    Color textColor;

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        TaskLocalizations.getTaskComplexityDisplayName(complexity, l10n),
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getColumnTitle(TaskStatus status, AppLocalizations l10n) {
    switch (status) {
      case TaskStatus.pending:
        return l10n.kanbanColumnPending;
      case TaskStatus.inProgress:
        return l10n.kanbanColumnInProgress;
      case TaskStatus.underReview:
        return l10n.kanbanColumnUnderReview;
      case TaskStatus.completed:
        return l10n.kanbanColumnCompleted;
    }
  }

  Color _getColumnColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.underReview:
        return Colors.purple;
      case TaskStatus.completed:
        return Colors.green;
    }
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
}
