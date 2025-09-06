import '../l10n/app_localizations.dart';
import '../models/task.dart';

/// Helper para obtener las traducciones de tareas
class TaskLocalizations {
  static String getTaskStatusDisplayName(TaskStatus status, AppLocalizations l10n) {
    switch (status) {
      case TaskStatus.pending:
        return l10n.taskStatusPending;
      case TaskStatus.inProgress:
        return l10n.taskStatusInProgress;
      case TaskStatus.underReview:
        return l10n.taskStatusUnderReview;
      case TaskStatus.completed:
        return l10n.taskStatusCompleted;
    }
  }

  static String getTaskComplexityDisplayName(TaskComplexity complexity, AppLocalizations l10n) {
    switch (complexity) {
      case TaskComplexity.simple:
        return l10n.taskComplexitySimple;
      case TaskComplexity.medium:
        return l10n.taskComplexityMedium;
      case TaskComplexity.complex:
        return l10n.taskComplexityComplex;
    }
  }
}
