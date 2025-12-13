import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../router/app_router.dart';
import '../../services/projects_service.dart';

class AppSideDrawer extends StatefulWidget {
  final User user;

  const AppSideDrawer({super.key, required this.user});

  @override
  State<AppSideDrawer> createState() => _AppSideDrawerState();
}

class _AppSideDrawerState extends State<AppSideDrawer> {
  bool _hasApprovedProject = false;

  @override
  void initState() {
    super.initState();
    _checkApprovedProject();
  }

  Future<void> _checkApprovedProject() async {
    // Solo verificar para estudiantes
    if (widget.user.role != UserRole.student) {
      setState(() {
        _hasApprovedProject = false;
      });
      return;
    }

    try {
      final projectsService = ProjectsService();
      final projects = await projectsService.getStudentProjects();

      if (mounted) {
        setState(() {
          _hasApprovedProject = projects.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al verificar proyectos en drawer: $e');
      if (mounted) {
        setState(() {
          _hasApprovedProject = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = _menuItemsForRole(l10n, widget.user.role, _hasApprovedProject);

    // Debug: Verificar que se está construyendo el AppSideDrawer - NUEVO DRAWER
    debugPrint(
      '📱 AppSideDrawer: Construyendo Drawer para usuario: ${widget.user.fullName}',
    );
    debugPrint('📱 AppSideDrawer: Rol del usuario: ${widget.user.role}');
    debugPrint('📱 AppSideDrawer: Tiene proyecto aprobado: $_hasApprovedProject');
    debugPrint('📱 AppSideDrawer: Número de items del menú: ${items.length}');

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(l10n, widget.user),
            ...items.map(
              (item) => ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                onTap: () {
                  Navigator.of(context).pop(); // Cerrar el drawer

                  // Cerrar cualquier pantalla de detalle abierta antes de navegar
                  // Esto asegura que siempre volvamos a la pantalla base
                  final navigator = Navigator.of(context, rootNavigator: false);

                  // Si hay pantallas modales abiertas, cerrarlas primero
                  if (navigator.canPop()) {
                    // Cerrar todas las pantallas modales hasta llegar a la pantalla base
                    // Esto cierra las pantallas de detalle abiertas con Navigator.push
                    navigator.popUntil((route) => route.isFirst);

                    // Pequeño delay para asegurar que las pantallas se cierren
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        item.onTap(context, widget.user);
                      }
                    });
                    return;
                  }

                  // Si no hay pantallas modales, navegar directamente
                  item.onTap(context, widget.user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, User user) => DrawerHeader(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2D5573), // Azul CIFP
          Color(0xFF1E3A52),
        ],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            // Logo del CIFP - Solo símbolo
            Image.asset(
              'assets/logos/cifp_logo_symbol.png',
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.school, color: Colors.white, size: 40);
              },
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sistema TFG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'CIFP CARLOS III',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        // Información del usuario
        Text(
          user.fullName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user.role.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            ),
            if (user.academicYear != null && user.academicYear!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                'Curso ${user.academicYear}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );

  List<_DrawerItem> _menuItemsForRole(AppLocalizations l10n, UserRole role, bool hasApprovedProject) {
    final common = <_DrawerItem>[
      _DrawerItem(
        icon: Icons.dashboard,
        label: l10n.dashboard,
        onTap: (ctx, user) => AppRouter.goToDashboard(ctx, user),
      ),
      _DrawerItem(
        icon: Icons.notifications,
        label: l10n.notifications,
        onTap: (ctx, user) => ctx.go('/notifications', extra: user),
      ),
    ];

    // Opción de ayuda que se agrega al final de cada menú
    final helpItem = _DrawerItem(
      icon: Icons.help_outline,
      label: l10n.helpGuide,
      onTap: (ctx, user) => ctx.go('/help', extra: user),
    );

    switch (role) {
      case UserRole.student:
        final studentItems = <_DrawerItem>[
          ...common,
          _DrawerItem(
            icon: Icons.message,
            label: l10n.messages,
            onTap: (ctx, user) => ctx.go('/student/messages', extra: user),
          ),
          _DrawerItem(
            icon: Icons.description,
            label: l10n.anteprojects,
            onTap: (ctx, user) => ctx.go('/anteprojects', extra: user),
          ),
          _DrawerItem(
            icon: Icons.assignment_turned_in,
            label: l10n.projects,
            onTap: (ctx, user) => ctx.go('/projects', extra: user),
          ),
        ];

        // Solo agregar Tareas y Kanban si el estudiante tiene un proyecto aprobado
        if (hasApprovedProject) {
          studentItems.addAll([
            _DrawerItem(
              icon: Icons.task_alt,
              label: l10n.tasks,
              onTap: (ctx, user) => ctx.go('/tasks', extra: user),
            ),
            _DrawerItem(
              icon: Icons.view_kanban,
              label: l10n.kanbanBoard,
              onTap: (ctx, user) => ctx.go('/kanban', extra: user),
            ),
          ]);
        }

        studentItems.add(helpItem); // Agregar guía de uso para estudiantes
        return studentItems;
      case UserRole.tutor:
        return [
          common[0], // Panel Principal
          _DrawerItem(
            icon: Icons.people,
            label: l10n.myStudents,
            onTap: (ctx, user) => ctx.go('/students', extra: user),
          ),
          common[1], // Notificaciones
          _DrawerItem(
            icon: Icons.message,
            label: l10n.messages,
            onTap: (ctx, user) => ctx.go('/tutor/messages', extra: user),
          ),
          _DrawerItem(
            icon: Icons.assignment,
            label: l10n.anteprojects,
            onTap: (ctx, user) => ctx.go('/anteprojects', extra: user),
          ),
          _DrawerItem(
            icon: Icons.gavel,
            label: l10n.approvalWorkflow,
            onTap: (ctx, user) => ctx.go('/approval-workflow', extra: user),
          ),
          helpItem, // Agregar guía de uso para tutores
        ];
      case UserRole.admin:
        return [
          ...common, // incluye Dashboard y Notificaciones
          _DrawerItem(
            icon: Icons.people_alt,
            label: l10n.totalUsers,
            onTap: (ctx, user) => ctx.go('/admin/users'),
          ),
          _DrawerItem(
            icon: Icons.gavel,
            label: l10n.approvalWorkflow,
            onTap: (ctx, user) =>
                ctx.go('/admin/approval-workflow', extra: user),
          ),
          _DrawerItem(
            icon: Icons.settings,
            label: l10n.settings,
            onTap: (ctx, user) => ctx.go('/admin/settings'),
          ),
          helpItem, // Agregar guía de uso para administradores
        ];
    }
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final void Function(BuildContext context, User user) onTap;

  _DrawerItem({required this.icon, required this.label, required this.onTap});
}
