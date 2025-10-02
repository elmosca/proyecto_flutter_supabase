/// Utilidades para localización de notificaciones
/// Este archivo proporciona métodos para obtener textos localizados
/// sin necesidad de acceso al BuildContext
class NotificationLocalizations {
  /// Obtiene el nombre del estado de la tarea en español
  static String getTaskStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'in_progress':
        return 'En Progreso';
      case 'under_review':
        return 'En Revisión';
      case 'completed':
        return 'Completada';
      default:
        return status;
    }
  }

  /// Obtiene el nombre del estado de la tarea en inglés
  static String getTaskStatusDisplayNameEn(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'under_review':
        return 'Under Review';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  /// Obtiene el título de notificación de cambio de estado
  static String getTaskStatusUpdatedTitle({bool isEnglish = false}) {
    return isEnglish ? 'Task status updated' : 'Estado de tarea actualizado';
  }

  /// Obtiene el mensaje de cambio de estado
  static String getTaskStatusChangedMessage(
    String taskTitle,
    String status, {
    bool isEnglish = false,
  }) {
    final statusDisplay = isEnglish
        ? getTaskStatusDisplayNameEn(status)
        : getTaskStatusDisplayName(status);

    return isEnglish
        ? 'Task "$taskTitle" changed to status: $statusDisplay'
        : 'La tarea "$taskTitle" cambió a estado: $statusDisplay';
  }

  /// Obtiene el título de notificación de asignación
  static String getTaskAssignedTitle({bool isEnglish = false}) {
    return isEnglish ? 'Task assigned' : 'Tarea asignada';
  }

  /// Obtiene el mensaje de asignación
  static String getTaskAssignedMessage(
    String taskTitle, {
    bool isEnglish = false,
  }) {
    return isEnglish
        ? 'You have been assigned the task: "$taskTitle"'
        : 'Se te ha asignado la tarea: "$taskTitle"';
  }

  /// Obtiene el título de notificación de comentario
  static String getNewCommentTitle({bool isEnglish = false}) {
    return isEnglish ? 'New comment on task' : 'Nuevo comentario en tarea';
  }

  /// Obtiene el mensaje de comentario
  static String getNewCommentMessage(
    String taskTitle,
    String commentPreview, {
    bool isEnglish = false,
  }) {
    return isEnglish
        ? 'New comment on "$taskTitle": $commentPreview'
        : 'Nuevo comentario en "$taskTitle": $commentPreview';
  }
}
