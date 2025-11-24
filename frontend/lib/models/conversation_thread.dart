import 'user.dart';

/// Modelo para hilos/temas de conversación
class ConversationThread {
  final int id;
  final int? projectId;
  final int? anteprojectId;
  final String title;
  final int createdBy;
  final DateTime lastMessageAt;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relación con el creador
  final User? creator;

  // Contador de mensajes no leídos (calculado)
  final int? unreadCount;

  ConversationThread({
    required this.id,
    this.projectId,
    this.anteprojectId,
    required this.title,
    required this.createdBy,
    required this.lastMessageAt,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
    this.unreadCount,
  });

  /// Determina si es un hilo de proyecto o anteproyecto
  bool get isProjectThread => projectId != null;
  bool get isAnteprojectThread => anteprojectId != null;

  /// Obtiene el ID del contexto (proyecto o anteproyecto)
  int get contextId => projectId ?? anteprojectId!;

  /// Crear ConversationThread desde JSON
  factory ConversationThread.fromJson(Map<String, dynamic> json) {
    return ConversationThread(
      id: json['id'] as int,
      projectId: json['project_id'] as int?,
      anteprojectId: json['anteproject_id'] as int?,
      title: json['title'] as String,
      createdBy: json['created_by'] as int,
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      creator: json['creator'] != null
          ? User.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int?,
    );
  }

  /// Convertir ConversationThread a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'anteproject_id': anteprojectId,
      'title': title,
      'created_by': createdBy,
      'last_message_at': lastMessageAt.toIso8601String(),
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crear una copia con campos modificados
  ConversationThread copyWith({
    int? id,
    int? projectId,
    int? anteprojectId,
    String? title,
    int? createdBy,
    DateTime? lastMessageAt,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? creator,
    int? unreadCount,
  }) {
    return ConversationThread(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      anteprojectId: anteprojectId ?? this.anteprojectId,
      title: title ?? this.title,
      createdBy: createdBy ?? this.createdBy,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creator: creator ?? this.creator,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  String toString() {
    return 'ConversationThread(id: $id, title: $title, '
        'projectId: $projectId, anteprojectId: $anteprojectId, '
        'unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationThread && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

