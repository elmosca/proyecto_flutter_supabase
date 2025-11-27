import 'user.dart';

/// Modelo para los mensajes de proyectos entre estudiantes y tutores
class ProjectMessage {
  final int id;
  final int projectId;
  final int senderId;
  final String content;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relación con el remitente
  final User? sender;

  ProjectMessage({
    required this.id,
    required this.projectId,
    required this.senderId,
    required this.content,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
  });

  /// Crear ProjectMessage desde JSON (de Supabase)
  factory ProjectMessage.fromJson(Map<String, dynamic> json) {
    return ProjectMessage(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      senderId: json['sender_id'] as int,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sender: json['sender'] != null
          ? User.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convertir ProjectMessage a JSON (para Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'sender_id': senderId,
      'content': content,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crear una copia del mensaje con campos modificados
  ProjectMessage copyWith({
    int? id,
    int? projectId,
    int? senderId,
    String? content,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? sender,
  }) {
    return ProjectMessage(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
    );
  }

  @override
  String toString() {
    return 'ProjectMessage(id: $id, projectId: $projectId, senderId: $senderId, '
        'content: ${content.substring(0, content.length > 50 ? 50 : content.length)}..., '
        'isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

