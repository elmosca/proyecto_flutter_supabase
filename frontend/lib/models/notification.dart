import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Modelo que representa una notificación del sistema
class Notification {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime? readAt;
  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.actionUrl,
    this.metadata,
    this.readAt,
    required this.createdAt,
  });

  /// Crea un Notification desde un JSON
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      actionUrl: json['action_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte un Notification a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'action_url': actionUrl,
      'metadata': metadata,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Indica si la notificación está leída
  bool get isRead => readAt != null;

  /// Indica si es una notificación privada (comunicación entre usuarios)
  bool get isPrivate {
    return type == 'anteproject_comment' ||
        type == 'anteproject_message' ||
        type == 'project_message' ||
        type == 'task_assigned' ||
        type == 'task_status_changed' ||
        type == 'comment_added';
  }

  /// Indica si es una notificación administrativa del sistema
  bool get isSystemNotification {
    return type == 'user_created' ||
        type == 'user_deleted' ||
        type == 'system_error' ||
        type == 'security_alert' ||
        type == 'backup_completed' ||
        type == 'settings_changed' ||
        type == 'bulk_operation' ||
        type == 'system_maintenance' ||
        type == 'announcement' ||
        type == 'system_notification';
  }

  /// Crea una copia del Notification con valores modificados
  Notification copyWith({
    int? id,
    int? userId,
    String? type,
    String? title,
    String? message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Extension para obtener iconos según el tipo de notificación
extension NotificationTypeExtension on Notification {
  IconData get icon {
    switch (type) {
      case 'user_created':
      case 'user_deleted':
        return Icons.person;
      case 'system_error':
      case 'security_alert':
        return Icons.error;
      case 'settings_changed':
        return Icons.settings;
      case 'backup_completed':
      case 'bulk_operation':
        return Icons.check_circle;
      case 'system_maintenance':
        return Icons.build;
      case 'announcement':
      case 'system_notification':
        return Icons.announcement;
      case 'anteproject_comment':
        return Icons.comment;
      case 'anteproject_message':
      case 'project_message':
        return Icons.message;
      case 'password_reset_request':
        return Icons.lock_reset;
      case 'task_assigned':
        return Icons.assignment;
      case 'task_status_changed':
        return Icons.update;
      default:
        return Icons.notifications;
    }
  }

  Color get iconColor {
    if (isRead) return Colors.grey;
    switch (type) {
      case 'system_error':
      case 'security_alert':
        return Colors.red;
      case 'user_created':
        return Colors.green;
      case 'settings_changed':
        return Colors.blue;
      case 'announcement':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  /// Obtiene el nombre de visualización del tipo traducido
  String getTypeDisplayName(AppLocalizations l10n) {
    switch (type) {
      case 'user_created':
        return l10n.newUser;
      case 'user_deleted':
        return l10n.userDeleted;
      case 'system_error':
        return l10n.systemError;
      case 'security_alert':
        return l10n.securityAlert;
      case 'settings_changed':
        return l10n.settingsChanged;
      case 'backup_completed':
        return l10n.backupCompleted;
      case 'bulk_operation':
        return l10n.bulkOperation;
      case 'system_maintenance':
        return l10n.systemMaintenance;
      case 'announcement':
        return l10n.announcement;
      case 'system_notification':
        return l10n.systemNotification;
      case 'anteproject_comment':
        return l10n.comment;
      case 'anteproject_message':
        return l10n.messageInAnteproject;
      case 'project_message':
        return l10n.messageInProject;
      case 'password_reset_request':
        return l10n.passwordResetRequest;
      case 'task_assigned':
        return l10n.taskAssigned;
      case 'task_status_changed':
        return l10n.statusChanged;
      default:
        return l10n.notifications;
    }
  }

  /// Getter legacy para compatibilidad (usa español por defecto)
  /// @deprecated Usa getTypeDisplayName(AppLocalizations) en su lugar
  @Deprecated('Use getTypeDisplayName(AppLocalizations) instead')
  String get typeDisplayName {
    switch (type) {
      case 'user_created':
        return 'Nuevo Usuario';
      case 'user_deleted':
        return 'Usuario Eliminado';
      case 'system_error':
        return 'Error del Sistema';
      case 'security_alert':
        return 'Alerta de Seguridad';
      case 'settings_changed':
        return 'Configuración Cambiada';
      case 'backup_completed':
        return 'Copia de Seguridad';
      case 'bulk_operation':
        return 'Operación Masiva';
      case 'system_maintenance':
        return 'Mantenimiento';
      case 'announcement':
        return 'Anuncio';
      case 'system_notification':
        return 'Notificación del Sistema';
      case 'anteproject_comment':
        return 'Comentario';
      case 'anteproject_message':
        return 'Mensaje en Anteproyecto';
      case 'project_message':
        return 'Mensaje en Proyecto';
      case 'password_reset_request':
        return 'Solicitud de Restablecimiento';
      case 'task_assigned':
        return 'Tarea Asignada';
      case 'task_status_changed':
        return 'Estado Cambiado';
      default:
        return 'Notificación';
    }
  }
}
