import 'package:flutter/material.dart';

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

  const AppTopBar({
    super.key,
    required this.user,
    required this.titleKey,
    this.showNotifications = true,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final String titleText = _resolveTitle(l10n, titleKey);

    debugPrint(
      '🔧 AppTopBar: Construyendo AppBar para usuario: ${user.fullName}',
    );
    debugPrint('🔧 AppTopBar: Título: $titleText');

    return AppBar(
      title: Row(
        children: [
          Text(RoleThemes.getEmojiForRole(user.role)),
          const SizedBox(width: 8),
          Flexible(child: Text(titleText, overflow: TextOverflow.ellipsis)),
        ],
      ),
      backgroundColor: ThemeService.instance.currentPrimaryColor,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
            debugPrint('📱 AppTopBar: Abriendo drawer manualmente');
          },
        ),
      ),
      actions: [
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
