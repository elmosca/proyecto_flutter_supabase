import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../services/theme_service.dart';
import '../notifications/notifications_bell.dart';
import '../common/language_selector.dart';
import '../../router/app_router.dart';
import '../../themes/role_themes.dart';
import 'messages_button.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final User user;
  final String titleKey;
  final bool showNotifications;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final TabBar? tabBar; // TabBar opcional para incluir dentro del AppBar

  const AppTopBar({
    super.key,
    required this.user,
    required this.titleKey,
    this.showNotifications = true,
    this.actions,
    this.bottom,
    this.tabBar,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final String titleText = _resolveTitle(l10n, titleKey);
    final bool isTasksScreen = titleKey == 'tasks';
    
    // Verificar si estamos en la ruta de tasks
    final router = GoRouter.of(context);
    final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
    final bool isOnTasksRoute = currentLocation == '/tasks' || 
                                currentLocation.startsWith('/tasks/');

    debugPrint(
      '🔧 AppTopBar: Construyendo AppBar para usuario: ${user.fullName}',
    );
    debugPrint('🔧 AppTopBar: Título: $titleText');
    debugPrint('🔧 AppTopBar: Ruta actual: $currentLocation');

    // Widget del título (clickeable si estamos en tasks)
    Widget titleWidget = Row(
      children: [
        Text(RoleThemes.getEmojiForRole(user.role)),
        const SizedBox(width: 8),
        Flexible(
          child: isTasksScreen && isOnTasksRoute
              ? GestureDetector(
                  onTap: () {
                    // Si estamos en /tasks, refrescar navegando a la misma ruta
                    context.go('/tasks', extra: user);
                  },
                  child: Text(
                    titleText,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dotted,
                    ),
                  ),
                )
              : Text(titleText, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    return AppBar(
      title: titleWidget,
      backgroundColor: ThemeService.instance.currentPrimaryColor,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false, // Desactivar leading automático
      leading: Container(
        padding: const EdgeInsets.only(left: 8),
        child: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
              debugPrint('📱 AppTopBar: Abriendo drawer manualmente');
            },
          ),
        ),
      ),
      leadingWidth: 56, // Ancho estándar con padding adicional
      actions: [
        // Botones de navegación rápida: Tareas y Kanban
        IconButton(
          icon: const Icon(Icons.task_alt),
          tooltip: l10n.tasks,
          onPressed: () {
            context.go('/tasks', extra: user);
          },
        ),
        IconButton(
          icon: const Icon(Icons.view_kanban),
          tooltip: l10n.kanbanBoard,
          onPressed: () {
            context.go('/kanban', extra: user);
          },
        ),
        const LanguageSelectorAppBar(),
        if (showNotifications) NotificationsBell(user: user),
        MessagesButton(user: user),
        ...?actions,
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: l10n.logoutTooltip,
          onPressed: () => AppRouter.logout(context),
        ),
      ],
      bottom: bottom,
    );
  }

  String _resolveTitle(AppLocalizations l10n, String key) {
    switch (key) {
      case 'dashboardStudent':
        return l10n.dashboardStudent;
      case 'dashboardTutor':
        return l10n.dashboardTutor;
      case 'dashboardAdmin':
        return l10n.dashboardAdmin;
      case 'dashboard':
        return l10n.dashboard;
      case 'projects':
        return l10n.projects;
      case 'anteprojects':
        return l10n.anteprojects;
      case 'tasks':
        return l10n.tasks;
      case 'kanban':
        return l10n.kanbanBoard;
      case 'notifications':
        return l10n.notifications;
      case 'conversations':
        return l10n.conversations;
      case 'approvalWorkflow':
        return l10n.approvalWorkflow;
      case 'myStudents':
        return l10n.myStudents;
      case 'dashboardAdminUsersManagement':
        return l10n.dashboardAdminUsersManagement;
      case 'settings':
        return l10n.systemSettings;
      case 'help':
        return l10n.helpGuide;
      case 'tutorMessages':
        return l10n.tutorMessages;
      case 'studentMessages':
        return l10n.studentMessages;
      default:
        return l10n.dashboard;
    }
  }
}
