import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../blocs/auth_bloc.dart';
import '../../services/tasks_service.dart';
import '../../services/theme_service.dart';
import '../../services/academic_permissions_service.dart';
import '../../widgets/files/file_list_widget.dart';
import '../../widgets/navigation/persistent_scaffold.dart';
import '../../utils/task_localizations.dart';
import '../kanban/kanban_board.dart';
import '../lists/tasks_list.dart';
import '../../blocs/tasks_bloc.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final User? user;
  final bool useOwnScaffold;

  const TaskDetailScreen({
    super.key,
    required this.task,
    this.user,
    this.useOwnScaffold = false, // Por defecto usar PersistentScaffold
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Task _currentTask;
  bool _isEditingDescription = false;
  late TextEditingController _descriptionController;
  User? _currentUser;
  bool _isReadOnly = false;
  final AcademicPermissionsService _academicPermissionsService = AcademicPermissionsService();

  @override
  void initState() {
    super.initState();
    // 2 pestañas: Detalles, Archivos
    _tabController = TabController(length: 2, vsync: this);
    _currentTask = widget.task;
    _descriptionController = TextEditingController(
      text: _currentTask.description,
    );
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    User? user;
    if (widget.user != null) {
      user = widget.user;
    } else {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
        user = authState.user;
      }
    }
    
    if (user != null) {
      // Verificar modo solo lectura
      final isReadOnly = await _academicPermissionsService.isReadOnly(user);
      if (mounted) {
      setState(() {
          _currentUser = user;
          _isReadOnly = isReadOnly;
      });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
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

    final tabBar = TabBar(
      controller: _tabController,
      indicatorColor: theme.colorScheme.onPrimary,
      labelColor: theme.colorScheme.onPrimary,
      unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
      tabs: [
        Tab(text: l10n.details),
        Tab(text: l10n.filesAttached),
      ],
    );

    final body = TabBarView(
      controller: _tabController,
      children: [
        _buildDetailsTab(context),
        _buildFilesTab(context),
      ],
    );

    if (_currentUser != null) {
      return PersistentScaffold(
        title: l10n.taskDetails,
        titleKey: 'tasks',
        user: _currentUser!,
        body: Column(
          children: [
            Container(
              color: theme.primaryColor,
              child: tabBar,
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taskDetails),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        bottom: tabBar,
      ),
      body: body,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Descripción',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_isEditingDescription)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditingDescription = true;
                            });
                          },
                          icon: Icon(
                            Icons.edit,
                            size: 18,
                            color: theme.colorScheme.onPrimary,
                          ),
                          label: Text(
                            'Editar Descripción',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isEditingDescription) ...[
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Escribe la descripción de la tarea...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isEditingDescription = false;
                              _descriptionController.text =
                                  _currentTask.description;
                            });
                          },
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _saveDescription,
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                  ] else
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
            TaskLocalizations.getTaskStatusDisplayName(
              _currentTask.status,
              l10n,
            ),
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
        TaskLocalizations.getTaskComplexityDisplayName(
          _currentTask.complexity,
          l10n,
        ),
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
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
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  void _saveDescription() async {
    try {
      final updatedTask = _currentTask.copyWith(
        description: _descriptionController.text,
        updatedAt: DateTime.now(),
      );

      final tasksService = TasksService();
      await tasksService.updateTask(_currentTask.id, updatedTask);

      setState(() {
        _currentTask = updatedTask;
        _isEditingDescription = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Descripción actualizada correctamente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la descripción: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildKanbanTab() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    if (_currentTask.projectId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                l10n.kanbanOnlyForProjects,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return KanbanBoard(
      projectId: _currentTask.projectId,
      isEmbedded: true,
    );
  }

  Widget _buildTasksListTab() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    if (_currentTask.projectId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                l10n.kanbanOnlyForProjects,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider<TasksBloc>(
      create: (context) =>
          TasksBloc(tasksService: TasksService())
            ..add(TasksLoadRequested(projectId: _currentTask.projectId)),
      child: TasksList(
        projectId: _currentTask.projectId,
        isEmbedded: true,
      ),
    );
  }
}
