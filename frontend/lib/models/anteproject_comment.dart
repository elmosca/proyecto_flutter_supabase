import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import '../l10n/app_localizations.dart';

part 'anteproject_comment.g.dart';

enum AnteprojectSection {
  general,
  description,
  objectives,
  expectedResults,
  timeline,
  methodology,
  resources,
  other;

  /// Obtiene el nombre de visualización localizado para esta sección.
  ///
  /// Requiere un [BuildContext] para acceder a [AppLocalizations].
  ///
  /// Ejemplo:
  /// ```dart
  /// Text(section.getDisplayName(context))
  /// ```
  String getDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case AnteprojectSection.general:
        return l10n.sectionGeneral;
      case AnteprojectSection.description:
        return l10n.sectionDescription;
      case AnteprojectSection.objectives:
        return l10n.sectionObjectives;
      case AnteprojectSection.expectedResults:
        return l10n.sectionExpectedResults;
      case AnteprojectSection.timeline:
        return l10n.sectionTimeline;
      case AnteprojectSection.methodology:
        return l10n.sectionMethodology;
      case AnteprojectSection.resources:
        return l10n.sectionResources;
      case AnteprojectSection.other:
        return l10n.sectionOther;
    }
  }

  /// @deprecated Use [getDisplayName] instead. This getter is kept for backward compatibility.
  @Deprecated('Use getDisplayName(BuildContext context) instead')
  String get displayName {
    switch (this) {
      case AnteprojectSection.general:
        return 'General';
      case AnteprojectSection.description:
        return 'Descripción';
      case AnteprojectSection.objectives:
        return 'Objetivos';
      case AnteprojectSection.expectedResults:
        return 'Resultados Esperados';
      case AnteprojectSection.timeline:
        return 'Temporalización';
      case AnteprojectSection.methodology:
        return 'Metodología';
      case AnteprojectSection.resources:
        return 'Recursos';
      case AnteprojectSection.other:
        return 'Otros';
    }
  }
}

@JsonSerializable()
class AnteprojectComment {
  final int id;
  final int anteprojectId;
  final int authorId;
  final String content;
  final bool isInternal;
  final AnteprojectSection section;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relación con el autor
  final User? author;

  const AnteprojectComment({
    required this.id,
    required this.anteprojectId,
    required this.authorId,
    required this.content,
    required this.isInternal,
    required this.section,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory AnteprojectComment.fromJson(Map<String, dynamic> json) {
    try {
      // Debug: imprimir el JSON recibido
      debugPrint(
        '🔍 Debug - JSON recibido en AnteprojectComment.fromJson: $json',
      );

      // Manejar la relación con el autor
      User? author;
      if (json['author'] != null) {
        debugPrint('🔍 Debug - Author data: ${json['author']}');
        author = User.fromJson(json['author']);
      }

      return AnteprojectComment(
        id: json['id'] as int,
        anteprojectId: json['anteproject_id'] as int,
        authorId: json['author_id'] as int,
        content: json['content'] as String? ?? '',
        isInternal: json['is_internal'] as bool? ?? false,
        section: AnteprojectSection.values.firstWhere(
          (e) => e.toString().split('.').last == json['section'],
          orElse: () => AnteprojectSection.general,
        ),
        createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
        author: author,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Debug - Error en AnteprojectComment.fromJson: $e');
      debugPrint('❌ Debug - Stack trace: $stackTrace');
      debugPrint('❌ Debug - JSON que causó el error: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$AnteprojectCommentToJson(this);

  AnteprojectComment copyWith({
    int? id,
    int? anteprojectId,
    int? authorId,
    String? content,
    bool? isInternal,
    AnteprojectSection? section,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? author,
  }) {
    return AnteprojectComment(
      id: id ?? this.id,
      anteprojectId: anteprojectId ?? this.anteprojectId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      isInternal: isInternal ?? this.isInternal,
      section: section ?? this.section,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
    );
  }

  @override
  String toString() {
    return 'AnteprojectComment(id: $id, anteprojectId: $anteprojectId, authorId: $authorId, content: $content, isInternal: $isInternal, section: $section, createdAt: $createdAt, updatedAt: $updatedAt, author: $author)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnteprojectComment &&
        other.id == id &&
        other.anteprojectId == anteprojectId &&
        other.authorId == authorId &&
        other.content == content &&
        other.isInternal == isInternal &&
        other.section == section &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.author == author;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        anteprojectId.hashCode ^
        authorId.hashCode ^
        content.hashCode ^
        isInternal.hashCode ^
        section.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        author.hashCode;
  }
}
