import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../models/anteproject.dart';
import '../../models/task.dart';
import '../../models/project.dart';
import '../../blocs/auth_bloc.dart';
import '../../services/theme_service.dart';
import '../../services/anteprojects_service.dart';
import '../../services/projects_service.dart';
import '../../services/tasks_service.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/navigation/app_side_drawer.dart';

class StudentDashboardScreen extends StatefulWidget {
  final User user;
  final bool useOwnScaffold;

  const StudentDashboardScreen({
    super.key,
    required this.user,
    this.useOwnScaffold = true,
  });

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _isLoading = true;
  Timer? _loadingTimer;

  // Datos del dashboard
  List<Anteproject> _anteprojects = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];

  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  final ProjectsService _projectsService = ProjectsService();
  final TasksService _tasksService = TasksService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Cargar datos en paralelo
      final futures = await Future.wait([
        _anteprojectsService.getStudentAnteprojects(),
        _projectsService.getStudentProjects(),
        _tasksService.getTasks(),
      ]);

      if (!mounted) return;

      final anteprojects = futures[0] as List<Anteproject>;
      final projects = futures[1] as List<Project>;
      final tasks = futures[2] as List<Task>;

      if (mounted) {
        setState(() {
          _anteprojects = anteprojects;
          _projects = projects;
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cargar datos del dashboard: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (!mounted) return;

      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        return;
      }

      // Mostrar mensaje de error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Getters para estadísticas
  List<Anteproject> get _pendingAnteprojects {
    return _anteprojects
        .where(
          (a) =>
              a.status == AnteprojectStatus.submitted ||
              a.status == AnteprojectStatus.underReview,
        )
        .toList();
  }

  List<Anteproject> get _approvedAnteprojects {
    return _anteprojects
        .where((a) => a.status == AnteprojectStatus.approved)
        .toList();
  }

  List<Task> get _pendingTasks {
    return _tasks.where((t) => t.status == TaskStatus.pending).toList();
  }

  // List<Task> get _inProgressTasks {
  //   return _tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  // }

  // List<Task> get _completedTasks {
  //   return _tasks.where((t) => t.status == TaskStatus.completed).toList();
  // }

  List<Task> get _upcomingTasks {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      final dueDate = t.dueDate!;
      return dueDate.isAfter(now) && dueDate.isBefore(nextWeek);
    }).toList()..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _buildDashboardContent();

    if (!widget.useOwnScaffold) {
      return body;
    }

    return Scaffold(
      appBar: AppTopBar(user: widget.user, titleKey: 'dashboardStudent'),
      drawer: AppSideDrawer(user: widget.user),
      body: body,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _createAnteproject,
            backgroundColor: ThemeService.instance.currentPrimaryColor,
            tooltip: 'Crear Anteproyecto',
            heroTag: 'create_anteproject',
            child: const Icon(Icons.add, color: Colors.white),
          ),
          if (_approvedAnteprojects.isNotEmpty) ...[
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: _createTask,
              backgroundColor: ThemeService.instance.currentAccentColor,
              tooltip: 'Crear Tarea',
              heroTag: 'create_task',
              child: const Icon(Icons.task, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDashboardContent() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfo(),
        const SizedBox(height: 24),
        _buildStatistics(),
        const SizedBox(height: 24),
        _buildQuickActions(),
        const SizedBox(height: 24),
        if (_pendingAnteprojects.isNotEmpty) ...[
          _buildPendingAnteprojectsSection(),
          const SizedBox(height: 24),
        ],
        if (_approvedAnteprojects.isNotEmpty) ...[
          _buildProjectsSection(),
          const SizedBox(height: 24),
        ],
        if (_upcomingTasks.isNotEmpty) ...[
          _buildUpcomingTasksSection(),
          const SizedBox(height: 24),
        ],
        _buildAnteprojectsSection(),
        const SizedBox(height: 24),
        _buildTasksSection(),
      ],
    ),
  );

  Widget _buildUserInfo() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(AppConfig.platformColor),
              child: Text(
                widget.user.fullName.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 24, color: Colors.white),
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
                    ),
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  if (widget.user.specialty != null &&
                      widget.user.specialty!.isNotEmpty)
                    Text(
                      widget.user.specialty!,
                      style: const TextStyle(
                        color: Color(AppConfig.platformColor),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (widget.user.academicYear != null &&
                      widget.user.academicYear!.isNotEmpty)
                    Text(
                      '${l10n.academicYear}: ${widget.user.academicYear}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Anteproyectos Pendientes',
            value: _pendingAnteprojects.length.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
            onTap: _viewAnteprojects,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: 'Proyectos Activos',
            value: _projects.length.toString(),
            icon: Icons.work,
            color: Colors.green,
            onTap: _viewProjects,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: 'Tareas Pendientes',
            value: _pendingTasks.length.toString(),
            icon: Icons.task_alt,
            color: Colors.blue,
            onTap: _viewTasks,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: 'Crear Anteproyecto',
                icon: Icons.add_circle,
                color: Colors.blue,
                onTap: _createAnteproject,
              ),
            ),
            const SizedBox(width: 8),
            if (_approvedAnteprojects.isNotEmpty)
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Crear Tarea',
                  icon: Icons.task,
                  color: Colors.green,
                  onTap: _createTask,
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionCard(
                title: 'Tablero Kanban',
                icon: Icons.view_kanban,
                color: Colors.purple,
                onTap: _viewKanban,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingAnteprojectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Anteproyectos Pendientes de Revisión',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _viewAnteprojects,
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...(_pendingAnteprojects
            .take(3)
            .map((anteproject) => _buildAnteprojectCard(anteproject))),
      ],
    );
  }

  Widget _buildProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Proyectos Activos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _viewProjects,
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_projects.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No tienes proyectos activos aún. Cuando tu anteproyecto sea aprobado, aparecerá aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          )
        else
          ...(_projects.take(3).map((project) => _buildProjectCard(project))),
      ],
    );
  }

  Widget _buildUpcomingTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tareas Próximas (7 días)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: _viewTasks, child: const Text('Ver todas')),
          ],
        ),
        const SizedBox(height: 8),
        ...(_upcomingTasks.take(5).map((task) => _buildTaskCard(task))),
      ],
    );
  }

  Widget _buildAnteprojectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mis Anteproyectos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _viewAnteprojects,
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_anteprojects.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.assignment, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'No tienes anteproyectos aún',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primer anteproyecto para comenzar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _createAnteproject,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Anteproyecto'),
                  ),
                ],
              ),
            ),
          )
        else
          ...(_anteprojects
              .take(5)
              .map((anteproject) => _buildAnteprojectCard(anteproject))),
      ],
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mis Tareas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: _viewTasks, child: const Text('Ver todas')),
          ],
        ),
        const SizedBox(height: 8),
        if (_tasks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.task_alt, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'No tienes tareas aún',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tareas para organizar tu trabajo en el proyecto',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  if (_approvedAnteprojects.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _createTask,
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Tarea'),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          ...(_tasks.take(5).map((task) => _buildTaskCard(task))),
      ],
    );
  }

  Widget _buildAnteprojectCard(Anteproject anteproject) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (anteproject.status) {
      case AnteprojectStatus.submitted:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Enviado';
        break;
      case AnteprojectStatus.underReview:
        statusColor = Colors.blue;
        statusIcon = Icons.reviews;
        statusText = 'En Revisión';
        break;
      case AnteprojectStatus.approved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Aprobado';
        break;
      case AnteprojectStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Rechazado';
        break;
      case AnteprojectStatus.draft:
        statusColor = Colors.grey;
        statusIcon = Icons.edit;
        statusText = 'Borrador';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          anteproject.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              statusText,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
            ),
            if (anteproject.description.isNotEmpty)
              Text(
                anteproject.description.length > 50
                    ? '${anteproject.description.substring(0, 50)}...'
                    : anteproject.description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _viewAnteprojectDetail(anteproject),
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.work, color: Colors.white),
        ),
        title: Text(
          project.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Proyecto activo',
          style: TextStyle(color: Colors.green.shade700),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _viewProjectDetail(project),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color statusColor;
    IconData statusIcon;

    switch (task.status) {
      case TaskStatus.pending:
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
        break;
      case TaskStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle;
        break;
      case TaskStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTaskStatusText(task.status),
              style: TextStyle(color: statusColor, fontSize: 12),
            ),
            if (task.dueDate != null)
              Text(
                'Vence: ${_formatDate(task.dueDate!)}',
                style: TextStyle(
                  color: task.dueDate!.isBefore(DateTime.now())
                      ? Colors.red
                      : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _viewTaskDetail(task),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTaskStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pendiente';
      case TaskStatus.inProgress:
        return 'En Progreso';
      case TaskStatus.completed:
        return 'Completada';
    }
  }

  // Navegación
  Future<void> _createAnteproject() async {
    try {
      // Verificar si el estudiante ya tiene un anteproyecto aprobado
      final hasApproved = await _anteprojectsService.hasApprovedAnteproject();
      
      if (hasApproved) {
        final l10n = AppLocalizations.of(context)!;
        
        // Buscar el anteproyecto aprobado y su proyecto asociado
        final approvedAnteproject = _anteprojects.firstWhere(
          (ap) => ap.status == AnteprojectStatus.approved,
          orElse: () => _anteprojects.first,
        );
        
        // Mostrar SnackBar con mensaje y opción de ir al proyecto
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotCreateAnteprojectWithApproved),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: l10n.goToProject,
                onPressed: () async {
                  try {
                    if (approvedAnteproject.projectId != null) {
                      final project = await _projectsService
                          .getProject(approvedAnteproject.projectId!);
                      if (mounted && project != null) {
                        context.go('/projects/${project.id}');
                      }
                    } else {
                      // Si no hay proyecto, mostrar el anteproyecto
                      if (mounted) {
                        context.go('/anteprojects/${approvedAnteproject.id}');
                      }
                    }
                  } catch (e) {
                    debugPrint('Error al navegar al proyecto: $e');
                  }
                },
              ),
            ),
          );
        }
      } else {
        // Si no tiene aprobado, navegar normalmente
        if (mounted) {
          context.go('/anteprojects', extra: widget.user);
        }
      }
    } catch (e) {
      debugPrint('Error al verificar anteproyecto aprobado: $e');
      // Si hay error, permitir navegar de todas formas
      // El servicio lanzará la excepción si realmente hay un aprobado
      if (mounted) {
        context.go('/anteprojects', extra: widget.user);
      }
    }
  }

  void _createTask() {
    // Navegar a tareas, donde se puede crear una nueva
    context.go('/tasks', extra: widget.user);
  }

  void _viewAnteprojects() {
    context.go('/anteprojects', extra: widget.user);
  }

  void _viewProjects() {
    context.go('/projects', extra: widget.user);
  }

  void _viewTasks() {
    context.go('/tasks', extra: widget.user);
  }

  void _viewKanban() {
    context.go('/kanban', extra: widget.user);
  }

  void _viewAnteprojectDetail(Anteproject anteproject) {
    context.go('/anteprojects/${anteproject.id}', extra: widget.user);
  }

  void _viewProjectDetail(Project project) {
    context.go('/projects/${project.id}', extra: widget.user);
  }

  void _viewTaskDetail(Task task) {
    context.go('/tasks/${task.id}', extra: widget.user);
  }
}
