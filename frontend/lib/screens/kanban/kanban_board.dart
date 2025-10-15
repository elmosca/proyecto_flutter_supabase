import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/tasks_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../models/task.dart';
import '../../services/logging_service.dart';
import '../forms/task_form.dart';

class KanbanBoard extends StatefulWidget {
  final int? projectId;
  final bool isEmbedded;

  const KanbanBoard({
    super.key,
    required this.projectId,
    this.isEmbedded = false,
  });

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  // Tarea siendo arrastrada actualmente
  Task? _draggingTask;

  // Índice donde se insertaría la tarea (para placeholder)
  int? _dropTargetIndex;
  TaskStatus? _dropTargetStatus;

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

    final body = BlocConsumer<TasksBloc, TasksState>(
      listener: (context, state) {
        if (state is TasksFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.messageKey),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is TaskOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.taskUpdatedSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TasksLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TasksFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  state.messageKey,
                  style: TextStyle(color: Colors.red[700]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<TasksBloc>().add(
                    TasksLoadRequested(projectId: widget.projectId),
                  ),
                  child: Text(l10n.tasksListRefresh),
                ),
              ],
            ),
          );
        }

        if (state is TasksLoaded) {
          return _buildKanbanBoard(state.tasks, l10n);
        }

        return Center(child: Text(l10n.tasksListEmpty));
      },
    );

    if (widget.isEmbedded) {
      return body;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.kanbanBoardTitle),
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
        body: body,
        floatingActionButton: FloatingActionButton(
          onPressed: _createTask,
          child: const Icon(Icons.add),
        ),
      );
    }
  }

  Widget _buildKanbanBoard(List<Task> allTasks, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: TaskStatus.values.map((status) {
        return Expanded(child: _buildColumn(status, allTasks, l10n));
      }).toList(),
    );
  }

  Widget _buildColumn(
    TaskStatus status,
    List<Task> tasks,
    AppLocalizations l10n,
  ) {
    final columnTasks = tasks.where((task) => task.status == status).toList();
    columnTasks.sort(
      (a, b) => (a.kanbanPosition ?? 0).compareTo(b.kanbanPosition ?? 0),
    );

    final columnTitle = _getColumnTitle(status, l10n);
    final columnColor = _getColumnColor(status);

    return DragTarget<Task>(
      onAcceptWithDetails: (details) {
        final task = details.data;
        _handleTaskDrop(task, status, columnTasks.length);
      },
      onWillAcceptWithDetails: (details) {
        // Permitir drop siempre, tanto para cambio de estado como reordenamiento
        return true;
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de la columna
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? columnColor.withValues(alpha: 0.8)
                      : columnColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
              // Lista de tareas con scroll
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? columnColor.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    border: isHighlighted
                        ? Border.all(
                            color: columnColor,
                            width: 2,
                            style: BorderStyle.solid,
                          )
                        : null,
                  ),
                  child: _buildTaskList(columnTasks, status, l10n),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskList(
    List<Task> tasks,
    TaskStatus columnStatus,
    AppLocalizations l10n,
  ) {
    if (tasks.isEmpty) {
      // Zona de drop para columnas vacías
      return DragTarget<Task>(
        onWillAcceptWithDetails: (details) {
          if (_draggingTask == null) return false;
          setState(() {
            _dropTargetIndex = 0;
            _dropTargetStatus = columnStatus;
          });
          return true;
        },
        onLeave: (_) {
          setState(() {
            _dropTargetIndex = null;
            _dropTargetStatus = null;
          });
        },
        onAcceptWithDetails: (details) {
          setState(() {
            _dropTargetIndex = null;
            _dropTargetStatus = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          final showPlaceholder = candidateData.isNotEmpty;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: showPlaceholder
                  ? _buildInsertionPlaceholder()
                  : Text(
                      l10n.tasksListEmpty,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length * 2 + 1, // Espacios + tarjetas + espacio final
      itemBuilder: (context, index) {
        // Índices impares son tarjetas, pares son zonas de drop
        if (index.isEven) {
          // Zona de drop
          final dropIndex = index ~/ 2;
          return _buildDropZone(columnStatus, dropIndex, tasks);
        } else {
          // Tarjeta
          final taskIndex = index ~/ 2;
          final task = tasks[taskIndex];

          // No mostrar la tarjeta que se está arrastrando
          if (_draggingTask?.id == task.id) {
            return _buildDraggingPlaceholder();
          }

          return _buildTaskCard(task, l10n, taskIndex, key: ValueKey(task.id));
        }
      },
    );
  }

  Widget _buildTaskCard(
    Task task,
    AppLocalizations l10n,
    int taskIndex, {
    Key? key,
  }) {
    return Draggable<Task>(
      key: key,
      data: task,
      onDragStarted: () {
        setState(() {
          _draggingTask = task;
        });
      },
      onDragEnd: (_) {
        setState(() {
          _draggingTask = null;
          _dropTargetIndex = null;
          _dropTargetStatus = null;
        });
      },
      onDraggableCanceled: (_, __) {
        setState(() {
          _draggingTask = null;
          _dropTargetIndex = null;
          _dropTargetStatus = null;
        });
      },
      feedback: _buildDragFeedback(task),
      childWhenDragging: const SizedBox.shrink(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _editTask(task),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getColumnColor(task.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.drag_indicator,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${task.estimatedHours}h',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
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
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye una zona de drop entre tarjetas
  Widget _buildDropZone(
    TaskStatus status,
    int dropIndex,
    List<Task> columnTasks,
  ) {
    final isTargeted =
        _dropTargetStatus == status && _dropTargetIndex == dropIndex;

    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) {
        if (_draggingTask == null) {
          return false;
        }

        setState(() {
          _dropTargetIndex = dropIndex;
          _dropTargetStatus = status;
        });
        return true;
      },
      onLeave: (_) {
        if (_dropTargetIndex == dropIndex && _dropTargetStatus == status) {
          setState(() {
            _dropTargetIndex = null;
            _dropTargetStatus = null;
          });
        }
      },
      onAcceptWithDetails: (details) {
        final task = details.data;
        _handleTaskDrop(task, status, dropIndex);

        setState(() {
          _dropTargetIndex = null;
          _dropTargetStatus = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        if (isTargeted || candidateData.isNotEmpty) {
          return _buildInsertionPlaceholder();
        }
        return const SizedBox(height: 4);
      },
    );
  }

  /// Placeholder visual cuando se arrastra una tarea
  Widget _buildInsertionPlaceholder() {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[400],
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// Placeholder para la tarea que se está arrastrando
  Widget _buildDraggingPlaceholder() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Icon(Icons.drag_indicator, color: Colors.grey[400], size: 32),
      ),
    );
  }

  Widget _buildDragFeedback(Task task) {
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(8),
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _getColumnColor(task.status), width: 2),
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getColumnColor(task.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.drag_indicator,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplexityChip(
    TaskComplexity complexity,
    AppLocalizations l10n,
  ) {
    String complexityText;
    Color color;

    switch (complexity) {
      case TaskComplexity.simple:
        complexityText = l10n.taskComplexitySimple;
        color = Colors.green;
        break;
      case TaskComplexity.medium:
        complexityText = l10n.taskComplexityMedium;
        color = Colors.orange;
        break;
      case TaskComplexity.complex:
        complexityText = l10n.taskComplexityComplex;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        complexityText,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getColumnTitle(TaskStatus status, AppLocalizations l10n) {
    switch (status) {
      case TaskStatus.pending:
        return l10n.taskStatusPending;
      case TaskStatus.inProgress:
        return l10n.taskStatusInProgress;
      case TaskStatus.underReview:
        return l10n.taskStatusUnderReview;
      case TaskStatus.completed:
        return l10n.taskStatusCompleted;
    }
  }

  Color _getColumnColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.underReview:
        return Colors.orange;
      case TaskStatus.completed:
        return Colors.green;
    }
  }

  void _handleTaskDrop(Task task, TaskStatus newStatus, int targetIndex) {
    LoggingService.debug('🔄 Drag & Drop: ${task.title}');
    LoggingService.debug('   Estado actual: ${task.status.name}');
    LoggingService.debug('   Estado nuevo: ${newStatus.name}');
    LoggingService.debug('   Índice destino: $targetIndex');

    context.read<TasksBloc>().add(
      TaskReorderRequested(
        taskId: task.id,
        newStatus: newStatus,
        newPosition: targetIndex.toDouble(),
      ),
    );

    setState(() {
      _draggingTask = null;
      _dropTargetIndex = null;
      _dropTargetStatus = null;
    });
  }

  Future<void> _editTask(Task task) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: TaskForm(projectId: widget.projectId, task: task),
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: TaskForm(projectId: widget.projectId),
        ),
      ),
    );
  }
}
