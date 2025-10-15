import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class DashboardQuickActions extends StatelessWidget {
  final ValueChanged<DashboardAction> onActionSelected;

  const DashboardQuickActions({super.key, required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<DashboardAction>(
      onSelected: onActionSelected,
      icon: const Icon(Icons.more_horiz),
      itemBuilder: (context) => [
        PopupMenuItem<DashboardAction>(
          value: DashboardAction.viewTasks,
          child: Text(l10n.viewAllTasks),
        ),
        PopupMenuItem<DashboardAction>(
          value: DashboardAction.openKanban,
          child: Text(l10n.kanbanBoardTitle),
        ),
        PopupMenuItem<DashboardAction>(
          value: DashboardAction.createTask,
          child: Text(l10n.createTask),
        ),
      ],
    );
  }
}

enum DashboardAction { viewTasks, openKanban, createTask }
