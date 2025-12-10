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
                        item.onTap(context, user);
                      }
                    });
                    return;
                  }

                  // Si no hay pantallas modales, navegar directamente
                  item.onTap(context, user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) => const DrawerHeader(
    decoration: BoxDecoration(
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
        // Nombre de la aplicación
        Text(
          'Sistema TFG',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        // Nombre del centro
        Text(
          'CIFP CARLOS III',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
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

    // Opción de ayuda que se agrega al final de cada menú
    final helpItem = _DrawerItem(
      icon: Icons.help_outline,
      label: l10n.helpGuide,
      onTap: (ctx, user) => ctx.go('/help', extra: user),
    );

    switch (role) {
      case UserRole.student:
        return [
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
          helpItem, // Agregar guía de uso para estudiantes
        ];
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
