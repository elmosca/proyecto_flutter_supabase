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
import '../../services/user_service.dart';
import '../../services/anteprojects_service.dart';
import '../../services/projects_service.dart';
import '../../services/tasks_service.dart';
import '../../services/settings_service.dart';
import '../../services/academic_permissions_service.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/navigation/app_side_drawer.dart';
import '../../widgets/common/read_only_banner.dart';
import '../forms/anteproject_form.dart';

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
  final UserService _userService = UserService();
  final SettingsService _settingsService = SettingsService();
  final AcademicPermissionsService _academicPermissionsService = AcademicPermissionsService();
  
  String? _tutorName;
  bool _isReadOnly = false; // Modo solo lectura para años académicos anteriores
  // Estado local del usuario para mostrar información actualizada
  User? _currentUser; 

  @override
  void initState() {
    super.initState();
    // Inicializar con el usuario recibido
    _currentUser = widget.user;
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

      // Inicializar con el usuario actual como fallback
      User? refreshedUser;
      List<Anteproject> anteprojects = [];
      List<Project> projects = [];
      List<Task> tasks = [];

      // Cargar datos principales en paralelo (sin el usuario para evitar errores)
      try {
        final mainFutures = await Future.wait([
          _anteprojectsService.getStudentAnteprojects(),
          _projectsService.getStudentProjects(),
          _tasksService.getTasks(),
        ]);

        anteprojects = mainFutures[0] as List<Anteproject>;
        projects = mainFutures[1] as List<Project>;
        tasks = mainFutures[2] as List<Task>;
      } catch (e) {
        debugPrint('⚠️ Error al cargar datos principales: $e');
        // Continuar con listas vacías
      }

      // Intentar recargar el usuario por separado para obtener datos frescos
      try {
        refreshedUser = await _userService.getUserById(widget.user.id);
      } catch (e) {
        debugPrint('⚠️ Error al recargar usuario, usando datos originales: $e');
        // Usar el usuario original como fallback
        refreshedUser = null;
      }

      if (!mounted) return;

      // Cargar información del tutor si existe
      String? tutorName;
      final userToCheck = refreshedUser ?? widget.user;
      if (userToCheck.tutorId != null) {
        try {
          final tutor = await _userService.getUserById(userToCheck.tutorId!);
          tutorName = tutor?.fullName;
        } catch (e) {
          debugPrint('⚠️ Error al cargar tutor: $e');
          // Continuar sin tutor
        }
      }

      // Verificar si el usuario está en modo solo lectura
      final userForPermissions = refreshedUser ?? widget.user;
      final isReadOnly = await _academicPermissionsService.isReadOnly(userForPermissions);

      if (mounted) {
        setState(() {
          _anteprojects = anteprojects;
          _projects = projects;
          _tasks = tasks;
          // Usar usuario refrescado si está disponible, sino el original
          _currentUser = refreshedUser ?? widget.user;
          _tutorName = tutorName;
          _isLoading = false;
          _isReadOnly = isReadOnly;
        });

        // Actualizar el AuthBloc si obtuvimos un usuario más fresco
        // Esto asegura que otras pantallas (como Mensajes) tengan los datos actualizados (ej. año académico)
        if (refreshedUser != null) {
          context.read<AuthBloc>().add(AuthUserChanged(user: refreshedUser));
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error crítico al cargar datos del dashboard: $e');
      debugPrint('   Stack trace: $stackTrace');
      
      if (!mounted) return;

      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        return;
      }

      // En caso de error crítico, al menos mostrar el usuario original
      if (mounted) {
        setState(() {
          _currentUser = widget.user;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar algunos datos: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
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
    final dashboardContent = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _buildDashboardContent();
    
    // Envolver con banner de solo lectura si aplica
    final body = _isReadOnly && !_isLoading
        ? Column(
            children: [
              ReadOnlyBanner(
                academicYear: _currentUser?.academicYear ?? widget.user.academicYear ?? '',
              ),
              Expanded(child: dashboardContent),
            ],
          )
        : dashboardContent;

    if (!widget.useOwnScaffold) {
      return body;
    }

    return Scaffold(
      appBar: AppTopBar(user: widget.user, titleKey: 'dashboardStudent'),
      drawer: AppSideDrawer(user: widget.user),
      body: body,
      // Ocultar FABs en modo solo lectura
      floatingActionButton: _isReadOnly ? null : Column(
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
    // Usar _currentUser en lugar de widget.user para asegurar datos frescos
    final user = _currentUser ?? widget.user;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(AppConfig.platformColor),
              child: Text(
                (user.fullName.isNotEmpty ? user.fullName[0] : '?').toUpperCase(),
                style: textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (user.nre != null && user.nre!.isNotEmpty)
                    Text(
                      'NRE: ${user.nre}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(AppConfig.platformColor).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(AppConfig.platformColor).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          user.role.displayName,
                          style: textTheme.labelSmall?.copyWith(
                            color: const Color(AppConfig.platformColor),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (user.academicYear != null &&
                          user.academicYear!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            '${l10n.academicYear}: ${user.academicYear}',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (user.specialty != null &&
                          user.specialty!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            user.specialty!,
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                      if (_tutorName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.school, size: 12, color: Colors.purple),
                              const SizedBox(width: 4),
                              Text(
                                '${l10n.tutor}: $_tutorName',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.purple,
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
            title: 'Mis Anteproyectos',
            value: _anteprojects.length.toString(),
            icon: Icons.description,
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
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

  Widget _buildQuickActions() {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
    final textTheme = Theme.of(context).textTheme;

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
                style: textTheme.labelSmall?.copyWith(
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Anteproyectos Pendientes de Revisión',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Proyectos Activos',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...(_projects.take(3).map((project) => _buildProjectCard(project))),
      ],
    );
  }

  Widget _buildUpcomingTasksSection() {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tareas Próximas (7 días)',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis Anteproyectos',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  Icon(Icons.assignment, size: 48, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text(
                    'No tienes anteproyectos aún',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primer anteproyecto para comenzar',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis Tareas',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  Icon(Icons.task_alt, size: 48, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text(
                    'No tienes tareas aún',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tareas para organizar tu trabajo en el proyecto',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          anteproject.title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              statusText,
              style: textTheme.bodyMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (anteproject.description.isNotEmpty)
              Text(
                anteproject.description.length > 50
                    ? '${anteproject.description.substring(0, 50)}...'
                    : anteproject.description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.work, color: Colors.white),
        ),
        title: Text(
          project.title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Proyecto activo',
          style: textTheme.bodyMedium?.copyWith(color: Colors.green.shade700),
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

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(
          task.title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTaskStatusText(task.status),
              style: textTheme.bodySmall?.copyWith(color: statusColor),
            ),
            if (task.dueDate != null)
              Text(
                'Vence: ${_formatDate(task.dueDate!)}',
                style: textTheme.bodySmall?.copyWith(
                  color: task.dueDate!.isBefore(DateTime.now())
                      ? Colors.red
                      : colorScheme.onSurfaceVariant,
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
      final l10n = AppLocalizations.of(context)!;
      
      // Verificar si el estudiante está en el año académico activo
      final activeAcademicYear = await _settingsService.getStringSetting('academic_year');
      if (activeAcademicYear != null && 
          activeAcademicYear.isNotEmpty &&
          widget.user.academicYear != activeAcademicYear) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotCreateAnteprojectWrongAcademicYear),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      
      // Verificar si el estudiante ya tiene un anteproyecto aprobado
      final hasApproved = await _anteprojectsService.hasApprovedAnteproject();
      
      if (hasApproved) {
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
        return;
      }
      
      // Verificar si el estudiante ya tiene un borrador
      final hasDraft = await _anteprojectsService.hasDraftAnteproject();
      
      if (hasDraft) {
        // Buscar el borrador existente
        final draftAnteproject = _anteprojects.firstWhere(
          (ap) => ap.status == AnteprojectStatus.draft,
          orElse: () => _anteprojects.first,
        );
        
        // Mostrar SnackBar con mensaje y opción de ir al borrador
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotCreateAnteprojectWithDraft),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: l10n.goToDraft,
                onPressed: () {
                  if (mounted) {
                    context.go('/anteprojects/${draftAnteproject.id}');
                  }
                },
              ),
            ),
          );
        }
        return;
      }
      
      // Si no tiene restricciones, navegar al formulario de creación
      if (mounted) {
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AnteprojectForm()))
            .then((_) => _loadData());
      }
    } catch (e) {
      debugPrint('Error al verificar restricciones de anteproyecto: $e');
      // Si hay error, permitir navegar de todas formas
      // El servicio lanzará la excepción si realmente hay restricciones
      if (mounted) {
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AnteprojectForm()))
            .then((_) => _loadData());
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
