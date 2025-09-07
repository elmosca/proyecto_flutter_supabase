import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../blocs/comments_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../services/tasks_service.dart';
import '../../services/comments_service.dart';
import '../../widgets/comments/comments_widget.dart';
import '../../widgets/files/file_list_widget.dart';
import '../../utils/task_localizations.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Task _currentTask;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentTask = widget.task;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshTask() async {
    try {
      final tasksService = TasksService();
      final updatedTask = await tasksService.getTask(_currentTask.id);
      if (mounted && updatedTask != null) {
        setState(() {
          _currentTask = updatedTask;
        });
      }
    } catch (e) {
      // Manejar error silenciosamente
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taskDetails),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
          tabs: [
            Tab(text: l10n.details),
            Tab(text: l10n.commentsTitle),
            Tab(text: l10n.filesAttached),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab de Detalles
          _buildDetailsTab(context),
          
          // Tab de Comentarios
          _buildCommentsTab(context),
          
          // Tab de Archivos
          _buildFilesTab(context),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y estado
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _currentTask.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusChip(context),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildComplexityChip(context),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Descripción
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentTask.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Información adicional
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    'Creado el',
                    dateFormat.format(_currentTask.createdAt),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.update,
                    'Actualizado el',
                    dateFormat.format(_currentTask.updatedAt),
                  ),
                  if (_currentTask.dueDate != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.event,
                      'Fecha límite',
                      dateFormat.format(_currentTask.dueDate!),
                    ),
                  ],
                  if (_currentTask.completedAt != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.check_circle,
                      'Completado el',
                      dateFormat.format(_currentTask.completedAt!),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.timer,
                    'Horas estimadas',
                    '${_currentTask.estimatedHours ?? 0} horas',
                  ),
                  if (_currentTask.actualHours != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.access_time,
                      'Horas reales',
                      '${_currentTask.actualHours} horas',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    
    if (authState is! AuthAuthenticated) {
      return const Center(
        child: Text('Debes iniciar sesión para ver los comentarios'),
      );
    }
    
    return BlocProvider<CommentsBloc>(
      create: (_) => CommentsBloc(
        commentsService: CommentsService(),
        currentUser: authState.user,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CommentsWidget(
          taskId: _currentTask.id,
          currentUser: authState.user,
        ),
      ),
    );
  }

  Widget _buildFilesTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FileListWidget(
        attachableType: 'task',
        attachableId: _currentTask.id,
        showUploadButton: true,
        onFileUploaded: _refreshTask,
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (_currentTask.status) {
      case TaskStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.schedule;
        break;
      case TaskStatus.inProgress:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.play_circle_outline;
        break;
      case TaskStatus.underReview:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        icon = Icons.rate_review;
        break;
      case TaskStatus.completed:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 6),
          Text(
            TaskLocalizations.getTaskStatusDisplayName(_currentTask.status, l10n),
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplexityChip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    
    switch (_currentTask.complexity) {
      case TaskComplexity.simple:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case TaskComplexity.medium:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case TaskComplexity.complex:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        TaskLocalizations.getTaskComplexityDisplayName(_currentTask.complexity, l10n),
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }


  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
