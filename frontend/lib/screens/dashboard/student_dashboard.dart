import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../models/anteproject.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/anteprojects_bloc.dart';
import '../../blocs/tasks_bloc.dart';
import '../../services/anteprojects_service.dart';
import '../../services/tasks_service.dart';
import '../../services/theme_service.dart';
import '../../themes/role_themes.dart';
import '../../router/app_router.dart';
import '../forms/anteproject_form.dart';
import '../lists/anteprojects_list.dart';
import '../lists/tasks_list.dart';
import '../kanban/kanban_board.dart';
import '../anteprojects/anteproject_detail_screen.dart';
import '../forms/task_form.dart';
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
  List<dynamic> _tasks = [];
  int _completedTasks = 0;

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
      // Cargar anteproyectos del estudiante
      final anteprojectsService = AnteprojectsService();
      final anteprojects = await anteprojectsService.getStudentAnteprojects();
      
      // Cargar tareas del estudiante
      final tasksService = TasksService();
      final tasks = await tasksService.getStudentTasks();
      
      // Contar tareas completadas
      final completedTasks = tasks.where((task) => task['status'] == 'completed').length;
      
      if (mounted) {
        setState(() {
          _anteprojects = anteprojects;
          _tasks = tasks;
          _completedTasks = completedTasks;
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
        title: Row(
          children: [
            Text(RoleThemes.getEmojiForRole(widget.user.role)),
            const SizedBox(width: 8),
            Text(l10n.dashboardStudent),
          ],
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

  Widget _buildDashboardContent() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información del usuario
        _buildUserInfo(),
        const SizedBox(height: 24),

        // Resumen de estadísticas
        _buildStatistics(),
        const SizedBox(height: 24),

        // Anteproyectos
        _buildAnteprojectsSection(),
        const SizedBox(height: 24),

        // Tareas pendientes
        _buildTasksSection(),
        const SizedBox(height: 24),

      ],
    ),
  );

  Widget _buildUserInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: ThemeService.instance.currentGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
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
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${l10n.role}: ${l10n.studentRole}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                RoleBadge(role: widget.user.role),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
    children: [
      Expanded(
        child: _buildStatCard(
          l10n.anteprojects,
          _anteprojects.length.toString(),
          Icons.description,
          Colors.blue,
          onTap: _viewAllAnteprojects,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildStatCard(
          l10n.pendingTasks,
          _tasks.length.toString(),
          Icons.pending,
          Colors.orange,
          onTap: _viewAllTasks,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildStatCard(
          l10n.completed,
          _completedTasks.toString(),
          Icons.check_circle,
          Colors.green,
          onTap: _viewKanbanBoard,
        ),
      ),
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

  Widget _buildAnteprojectsSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.myAnteprojects,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
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

  Widget _buildTasksSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.pendingTasks,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _viewKanbanBoard,
                  child: Text(l10n.kanbanBoardTitle),
                ),
                TextButton(
                  onPressed: _viewAllTasks,
                  child: Text(l10n.viewAllTasks),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_tasks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    l10n.noPendingTasks,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _createTask,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.createTask),
                      ),
                      OutlinedButton.icon(
                        onPressed: _viewKanbanBoard,
                        icon: const Icon(Icons.dashboard),
                        label: Text(l10n.kanbanBoardTitle),
                      ),
                    ],
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
        leading: Icon(
          Icons.task,
          color: _getTaskStatusColor(task['status']),
        ),
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
        onTap: _viewAllTasks,
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => BlocProvider<AnteprojectsBloc>(
          create: (_) => AnteprojectsBloc(
            anteprojectsService: AnteprojectsService(),
          ),
          child: const AnteprojectForm(),
        ),
      ),
    ).then((_) => _loadData()); // Recargar datos al volver
  }

  void _viewAllAnteprojects() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => BlocProvider<AnteprojectsBloc>(
          create: (_) => AnteprojectsBloc(
            anteprojectsService: AnteprojectsService(),
          ),
          child: const AnteprojectsList(),
        ),
      ),
    ).then((_) => _loadData()); // Recargar datos al volver
  }

  void _viewAnteprojectDetails(Anteproject anteproject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnteprojectDetailScreen(anteproject: anteproject),
      ),
    ).then((_) => _loadData()); // Recargar datos al volver
  }

  void _viewAllTasks() {
    // Obtener projectId del usuario autenticado
    final authState = context.read<AuthBloc>().state;
    final projectId = authState is AuthAuthenticated ? authState.user.id : 1;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => BlocProvider<TasksBloc>(
          create: (_) => TasksBloc(
            tasksService: TasksService(),
          ),
          child: TasksList(projectId: projectId),
        ),
      ),
    );
  }

  void _viewKanbanBoard() {
    // Obtener projectId del usuario autenticado
    final authState = context.read<AuthBloc>().state;
    final projectId = authState is AuthAuthenticated ? authState.user.id : 1;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => BlocProvider<TasksBloc>(
          create: (_) => TasksBloc(
            tasksService: TasksService(),
          ),
          child: KanbanBoard(projectId: projectId),
        ),
      ),
    );
  }

  void _createTask() {
    // Obtener projectId del usuario autenticado
    final authState = context.read<AuthBloc>().state;
    final projectId = authState is AuthAuthenticated ? authState.user.id : 1;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => BlocProvider<TasksBloc>(
          create: (_) => TasksBloc(
            tasksService: TasksService(),
          ),
          child: TaskForm(projectId: projectId),
        ),
      ),
    );
  }
}
