import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../models/anteproject.dart';
import '../../models/project.dart';
import '../../blocs/anteprojects_bloc.dart';
import '../../blocs/tasks_bloc.dart';
import '../../services/tasks_service.dart';
import '../../services/projects_service.dart';
import '../../services/theme_service.dart';
import '../../themes/role_themes.dart';
import '../../router/app_router.dart';
import '../forms/anteproject_form.dart';
import '../lists/anteprojects_list.dart';
import '../lists/tasks_list.dart';
import '../kanban/kanban_board.dart';
import '../anteprojects/anteproject_detail_screen.dart';
import '../forms/task_form.dart';
import '../selection/context_selection_dialog.dart';
import 'components/dashboard_quick_actions.dart';
import '../../widgets/common/language_selector.dart';
import '../../widgets/notifications/notifications_bell.dart';
import '../notifications/notifications_screen.dart';

class StudentDashboard extends StatefulWidget {
  final User user;

  const StudentDashboard({super.key, required this.user});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool _isLoading = true;
  Timer? _loadingTimer;

  // Datos del dashboard
  List<Anteproject> _anteprojects = [];
  List<Map<String, dynamic>> _tasks = [];
  int _completedTasks = 0;
  Project? _userProject;

  @override
  void initState() {
    super.initState();
    // Simular carga de datos
    _loadData();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final anteprojectsService = context
          .read<AnteprojectsBloc>()
          .anteprojectsService;
      final tasksService = context.read<TasksBloc>().tasksService;
      final projectsService = ProjectsService();

      final anteprojects = await anteprojectsService.getStudentAnteprojects();
      final tasks = await tasksService.getStudentTasks();
      final userProject = await projectsService.getUserProject();

      debugPrint('🔍 Proyecto del estudiante cargado: ${userProject?.title}');

      // Contar tareas completadas
      final completedTasks = tasks
          .where((task) => task['status'] == 'completed')
          .length;

      if (mounted) {
        setState(() {
          _anteprojects = anteprojects;
          _tasks = tasks;
          _completedTasks = completedTasks;
          _userProject = userProject;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar datos del dashboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${RoleThemes.getEmojiForRole(widget.user.role)} ${l10n.dashboardStudent}',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: ThemeService.instance.currentPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          const LanguageSelectorAppBar(),
          NotificationsBell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: l10n.logoutTooltip,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createAnteproject,
        backgroundColor: ThemeService.instance.currentPrimaryColor,
        tooltip: l10n.createAnteprojectTooltip,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDashboardContent() => LayoutBuilder(
    builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 600;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(isCompact: isCompact),
            const SizedBox(height: 24),
            _buildStatistics(isCompact: isCompact),
            const SizedBox(height: 24),
            _buildAnteprojectsSection(isCompact: isCompact),
            const SizedBox(height: 24),
            _buildProjectsSection(isCompact: isCompact),
            const SizedBox(height: 24),
            _buildTasksSection(isCompact: isCompact),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );

  Widget _buildUserInfo({required bool isCompact}) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: ThemeService.instance.currentGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      RoleThemes.getEmojiForRole(widget.user.role),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.user.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${l10n.role}: ${l10n.studentRole}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics({required bool isCompact}) {
    final l10n = AppLocalizations.of(context)!;

    final stats = [
      _buildStatCard(
        l10n.anteprojects,
        _anteprojects.length.toString(),
        Icons.description,
        Colors.blue,
        onTap: _viewAllAnteprojects,
      ),
      _buildStatCard(
        l10n.pendingTasks,
        _tasks.length.toString(),
        Icons.pending,
        Colors.orange,
        onTap: () => _promptContextSelection(kanban: false),
      ),
      _buildStatCard(
        l10n.completed,
        _completedTasks.toString(),
        Icons.check_circle,
        Colors.green,
        onTap: () => _promptContextSelection(kanban: true),
      ),
    ];

    if (isCompact) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: stats[0]),
              const SizedBox(width: 8),
              Expanded(child: stats[1]),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: stats[2])]),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: stats[0]),
        const SizedBox(width: 8),
        Expanded(child: stats[1]),
        const SizedBox(width: 8),
        Expanded(child: stats[2]),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnteprojectsSection({required bool isCompact}) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.myAnteprojects,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _viewAllAnteprojects,
                  child: Text(l10n.viewAll),
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.myAnteprojects,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: _viewAllAnteprojects,
                child: Text(l10n.viewAll),
              ),
            ],
          ),
        const SizedBox(height: 8),
        if (_anteprojects.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.noAnteprojects,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...(_anteprojects.take(3).map(_buildAnteprojectPreview)),
      ],
    );
  }

  Widget _buildProjectsSection({required bool isCompact}) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompact)
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.myProjects,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.myProjects,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        if (_userProject == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.noProjectsAssigned,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          _buildProjectPreview(_userProject!),
      ],
    );
  }

  Widget _buildProjectPreview(Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.blue, width: 2),
      ),
      child: InkWell(
        onTap: () => _viewProjectDetails(project),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.work, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.flag, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          _getProjectStatusText(project.status.name),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnteprojectPreview(Anteproject anteproject) {
    final l10n = AppLocalizations.of(context)!;
    // Si está aprobado, mostrar una tarjeta especial
    if (anteproject.status.name == 'approved') {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.green, width: 2),
        ),
        child: InkWell(
          onTap: () => _viewAnteprojectDetails(anteproject),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anteproject.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.approved,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.anteprojectApprovedMessage,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      l10n.academicYearLabel(anteproject.academicYear),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Para otros estados, mostrar la tarjeta normal
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.description,
          color: _getStatusColor(anteproject.status.name),
        ),
        title: Text(
          anteproject.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          l10n.statusLabel(_getStatusText(anteproject.status.name)),
          style: TextStyle(
            color: _getStatusColor(anteproject.status.name),
            fontSize: 12,
          ),
        ),
        trailing: Chip(
          label: Text(
            _getStatusText(anteproject.status.name),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: _getStatusColor(anteproject.status.name),
        ),
        onTap: () => _viewAnteprojectDetails(anteproject),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'submitted':
        return Colors.blue;
      case 'under_review':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'draft':
        return l10n.draft;
      case 'submitted':
        return l10n.submitted;
      case 'under_review':
        return l10n.underReview;
      case 'approved':
        return l10n.approvedStatus;
      case 'rejected':
        return l10n.rejectedStatus;
      default:
        return l10n.unknown;
    }
  }

  Widget _buildTasksSection({required bool isCompact}) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pendingTasks,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: DashboardQuickActions(
                  onActionSelected: _handleQuickAction,
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.pendingTasks,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DashboardQuickActions(onActionSelected: _handleQuickAction),
            ],
          ),
        const SizedBox(height: 8),
        if (_tasks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.noPendingTasks,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _promptContextSelection(
                      kanban: false,
                      createTask: true,
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createTask),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _promptContextSelection(kanban: true),
                    icon: const Icon(Icons.dashboard),
                    label: Text(l10n.kanbanBoardTitle),
                  ),
                ],
              ),
            ),
          )
        else
          ...(_tasks.take(3).map(_buildTaskPreview)),
      ],
    );
  }

  Widget _buildTaskPreview(dynamic task) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.task, color: _getTaskStatusColor(task['status'])),
        title: Text(
          task['title'] ?? 'Sin título',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          l10n.statusLabel(_getTaskStatusText(task['status'])),
          style: TextStyle(
            color: _getTaskStatusColor(task['status']),
            fontSize: 12,
          ),
        ),
        trailing: Chip(
          label: Text(
            _getTaskStatusText(task['status']),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: _getTaskStatusColor(task['status']),
        ),
        onTap: () => _promptContextSelection(kanban: false),
      ),
    );
  }

  Color _getTaskStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getTaskStatusText(String? status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'pending':
        return l10n.pending;
      case 'in_progress':
        return l10n.inProgress;
      case 'completed':
        return l10n.completedStatus;
      default:
        return l10n.unknownStatus;
    }
  }

  Future<void> _logout() async {
    try {
      // Usar el router para logout
      AppRouter.logout(context);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al cerrar sesión: $e');
      }
    }
  }

  void _createAnteproject() {
    final antecedentService = context
        .read<AnteprojectsBloc>()
        .anteprojectsService;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (BuildContext context) => BlocProvider<AnteprojectsBloc>(
              create: (_) =>
                  AnteprojectsBloc(anteprojectsService: antecedentService),
              child: const AnteprojectForm(),
            ),
          ),
        )
        .then((_) => _loadData());
  }

  void _viewAllAnteprojects() {
    final service = context.read<AnteprojectsBloc>().anteprojectsService;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (BuildContext context) => BlocProvider<AnteprojectsBloc>(
              create: (_) => AnteprojectsBloc(anteprojectsService: service),
              child: const AnteprojectsList(),
            ),
          ),
        )
        .then((_) => _loadData());
  }

  void _viewAnteprojectDetails(Anteproject anteproject) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                AnteprojectDetailScreen(anteproject: anteproject),
          ),
        )
        .then((_) => _loadData()); // Recargar datos al volver
  }

  Future<void> _handleQuickAction(DashboardAction action) async {
    switch (action) {
      case DashboardAction.viewTasks:
        await _promptContextSelection(kanban: false);
        break;
      case DashboardAction.openKanban:
        await _promptContextSelection(kanban: true);
        break;
      case DashboardAction.createTask:
        await _promptContextSelection(kanban: false, createTask: true);
        break;
    }
  }

  Future<void> _promptContextSelection({
    required bool kanban,
    bool createTask = false,
  }) async {
    try {
      debugPrint(
        '🔍 Iniciando _promptContextSelection - kanban: $kanban, createTask: $createTask',
      );

      final projectsService = ProjectsService();
      final selection = await showProjectContextDialog(
        context,
        projectsService: projectsService,
      );

      debugPrint('🔍 Selección obtenida: ${selection?.projectId}');

      if (!mounted || selection == null) {
        debugPrint('❌ No hay selección o contexto no montado');
        return;
      }

      if (createTask) {
        debugPrint(
          '🔍 Navegando a TaskForm con projectId: ${selection.projectId}',
        );
        await _navigateToTaskForm(projectId: selection.projectId);
        return;
      }

      if (kanban) {
        debugPrint(
          '🔍 Navegando a Kanban con projectId: ${selection.projectId}',
        );
        await _navigateToKanban(projectId: selection.projectId);
      } else {
        debugPrint(
          '🔍 Navegando a TaskList con projectId: ${selection.projectId}',
        );
        await _navigateToTaskList(projectId: selection.projectId);
      }
    } catch (e) {
      debugPrint('❌ Error en _promptContextSelection: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorGettingProject(e.toString()),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToTaskList({required int? projectId}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => BlocProvider<TasksBloc>(
          create: (_) => TasksBloc(tasksService: TasksService()),
          child: TasksList(projectId: projectId),
        ),
      ),
    );
  }

  Future<void> _navigateToKanban({required int? projectId}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => BlocProvider<TasksBloc>(
          create: (_) => TasksBloc(tasksService: TasksService()),
          child: KanbanBoard(projectId: projectId),
        ),
      ),
    );
  }

  Future<void> _navigateToTaskForm({required int? projectId}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => BlocProvider<TasksBloc>(
          create: (_) => TasksBloc(tasksService: TasksService()),
          child: TaskForm(projectId: projectId),
        ),
      ),
    );
  }

  String _getProjectStatusText(String status) {
    switch (status) {
      case 'draft':
        return 'Borrador';
      case 'planning':
        return 'Planificación';
      case 'development':
        return 'Desarrollo';
      case 'review':
        return 'Revisión';
      case 'completed':
        return 'Completado';
      default:
        return status;
    }
  }

  Future<void> _viewProjectDetails(Project project) async {
    try {
      final projectsService = ProjectsService();
      final anteproject = await projectsService.getAnteprojectFromProject(
        project.id,
      );

      if (anteproject == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.anteprojectNotFound),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnteprojectDetailScreen(
              anteproject: anteproject,
              project: project, // Pasar el proyecto para habilitar pestañas
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al navegar a detalles del proyecto: $e');
    }
  }
}
