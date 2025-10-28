import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../router/app_router.dart';

class AppSideDrawer extends StatelessWidget {
  final User user;

  const AppSideDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = _menuItemsForRole(l10n, user.role);

    // Debug: Verificar que se está construyendo el AppSideDrawer - NUEVO DRAWER
    debugPrint(
      '📱 AppSideDrawer: Construyendo Drawer para usuario: ${user.fullName}',
    );
    debugPrint('📱 AppSideDrawer: Rol del usuario: ${user.role}');
    debugPrint('📱 AppSideDrawer: Número de items del menú: ${items.length}');

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(l10n),
            ...items.map(
              (item) => ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                onTap: () {
                  Navigator.of(context).pop();
                  item.onTap(context, user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) => DrawerHeader(
    decoration: const BoxDecoration(),
    child: Align(
      alignment: Alignment.bottomLeft,
      child: Text(
        l10n.dashboard,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
  );

  List<_DrawerItem> _menuItemsForRole(AppLocalizations l10n, UserRole role) {
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

    switch (role) {
      case UserRole.student:
        return [
          ...common,
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
        ];
      case UserRole.tutor:
        return [
          ...common,
          _DrawerItem(
            icon: Icons.assignment,
            label: l10n.anteprojects,
            onTap: (ctx, user) => ctx.go('/anteprojects', extra: user),
          ),
          _DrawerItem(
            icon: Icons.people,
            label: l10n.myStudents,
            onTap: (ctx, user) => ctx.go('/students', extra: user),
          ),
          _DrawerItem(
            icon: Icons.gavel,
            label: l10n.approvalWorkflow,
            onTap: (ctx, user) => ctx.go('/approval-workflow', extra: user),
          ),
        ];
      case UserRole.admin:
        return [
          ...common,
          _DrawerItem(
            icon: Icons.people_alt,
            label: l10n.totalUsers,
            onTap: (ctx, user) => ctx.go('/admin/users'),
          ),
          _DrawerItem(
            icon: Icons.settings,
            label: 'Configuración',
            onTap: (ctx, user) => ctx.go('/admin/settings'),
          ),
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
