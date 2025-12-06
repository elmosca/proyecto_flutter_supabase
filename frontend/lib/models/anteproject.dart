import 'package:json_annotation/json_annotation.dart';

part 'anteproject.g.dart';

/// Modelo que representa un anteproyecto de TFG.
///
/// Mapea a la tabla `anteprojects` de Supabase y contiene toda la información
/// necesaria para la gestión de anteproyectos: metadatos, contenido, estado,
/// fechas y relaciones con tutores y proyectos.
///
/// ## Propiedades principales:
/// - [id]: Identificador único autoincremental
/// - [title]: Título del anteproyecto (requerido)
/// - [projectType]: Tipo de proyecto (TFG, TFM, etc.)
/// - [description]: Descripción detallada del proyecto
/// - [status]: Estado actual del anteproyecto
/// - [timeline]: Cronograma de actividades (Map<String, dynamic>)
/// - [expectedResults]: Resultados esperados (Map<String, dynamic>)
///
/// ## Ejemplo JSON:
/// ```json
/// {
///   "id": 1,
///   "title": "Sistema de gestión de TFG",
///   "project_type": "tfg",
///   "description": "Desarrollo de una aplicación web...",
///   "academic_year": "2024-2025",
///   "status": "submitted",
///   "tutor_id": 123,
///   "created_at": "2025-01-01T00:00:00Z",
///   "updated_at": "2025-01-10T12:00:00Z"
/// }
/// ```
///
/// ## Estados posibles:
/// - [draft]: Borrador inicial, editable por el estudiante
/// - [submitted]: Enviado para revisión, no editable
/// - [under_review]: En revisión por el tutor
/// - [approved]: Aprobado por el tutor
/// - [rejected]: Rechazado con comentarios
/// - [changes_requested]: Requiere modificaciones
///
/// Ver también: [ProjectType], [AnteprojectStatus]
@JsonSerializable()
class Anteproject {
  final int id;
  final String title;
  @JsonKey(name: 'project_type')
  final ProjectType projectType;
  final String description;
  @JsonKey(name: 'academic_year')
  final String academicYear;
  final String? objectives;
  @JsonKey(name: 'expected_results')
  final Map<String, dynamic> expectedResults;
  final Map<String, dynamic> timeline;
  final AnteprojectStatus status;
  @JsonKey(name: 'tutor_id')
  final int? tutorId;
  @JsonKey(name: 'submitted_at')
  final DateTime? submittedAt;
  @JsonKey(name: 'reviewed_at')
  final DateTime? reviewedAt;
  @JsonKey(name: 'project_id')
  final int? projectId;
  @JsonKey(name: 'tutor_comments')
  final String? tutorComments;
  @JsonKey(name: 'github_repository_url')
  final String? githubRepositoryUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Anteproject({
    required this.id,
    required this.title,
    required this.projectType,
    required this.description,
    required this.academicYear,
    this.objectives,
    required this.expectedResults,
    required this.timeline,
    required this.status,
    this.tutorId,
    this.submittedAt,
    this.reviewedAt,
    this.projectId,
    this.tutorComments,
    this.githubRepositoryUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Anteproject.fromJson(Map<String, dynamic> json) =>
      _$AnteprojectFromJson(json);
  Map<String, dynamic> toJson() => _$AnteprojectToJson(this);

  Anteproject copyWith({
    int? id,
    String? title,
    ProjectType? projectType,
    String? description,
    String? academicYear,
    Map<String, dynamic>? expectedResults,
    Map<String, dynamic>? timeline,
    AnteprojectStatus? status,
    int? tutorId,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    int? projectId,
    String? tutorComments,
    String? githubRepositoryUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Anteproject(
      id: id ?? this.id,
      title: title ?? this.title,
      projectType: projectType ?? this.projectType,
      description: description ?? this.description,
      academicYear: academicYear ?? this.academicYear,
      objectives: objectives,
      expectedResults: expectedResults ?? this.expectedResults,
      timeline: timeline ?? this.timeline,
      status: status ?? this.status,
      tutorId: tutorId ?? this.tutorId,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      projectId: projectId ?? this.projectId,
      tutorComments: tutorComments ?? this.tutorComments,
      githubRepositoryUrl: githubRepositoryUrl ?? this.githubRepositoryUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Anteproject(id: $id, title: $title, projectType: $projectType, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Anteproject && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Tipos de proyecto de TFG disponibles.
enum ProjectType {
  /// Proyecto de ejecución o realización de un producto.
  @JsonValue('execution')
  execution,

  /// Proyecto de investigación experimental o innovación.
  @JsonValue('research')
  research,

  /// Proyecto bibliográfico o documental.
  @JsonValue('bibliographic')
  bibliographic,

  /// Proyecto de gestión, análisis de mercado, viabilidad o mercadotecnia.
  @JsonValue('management')
  management,
}

/// Estados posibles de un anteproyecto en el flujo de aprobación.
enum AnteprojectStatus {
  /// Borrador inicial, editable por el estudiante.
  @JsonValue('draft')
  draft,

  /// Enviado para revisión, no editable por el estudiante.
  @JsonValue('submitted')
  submitted,

  /// En revisión por el tutor asignado.
  @JsonValue('under_review')
  underReview,

  /// Aprobado por el tutor, puede convertirse en proyecto.
  @JsonValue('approved')
  approved,

  /// Rechazado con comentarios del tutor.
  @JsonValue('rejected')
  rejected,
}

extension ProjectTypeExtension on ProjectType {
  String get displayName {
    switch (this) {
      case ProjectType.execution:
        return 'Proyecto de ejecución o realización de un producto';
      case ProjectType.research:
        return 'Proyecto de research experimental o innovación';
      case ProjectType.bibliographic:
        return 'Proyecto bibliográfico o documental';
      case ProjectType.management:
        return 'Proyecto de management, análisis de mercado, viabilidad o mercadotecnia';
    }
  }

  String get shortName {
    switch (this) {
      case ProjectType.execution:
        return 'Ejecución';
      case ProjectType.research:
        return 'Investigación';
      case ProjectType.bibliographic:
        return 'Bibliográfico';
      case ProjectType.management:
        return 'Gestión';
    }
  }
}

extension AnteprojectStatusExtension on AnteprojectStatus {
  String get displayName {
    switch (this) {
      case AnteprojectStatus.draft:
        return 'Borrador';
      case AnteprojectStatus.submitted:
        return 'Enviado';
      case AnteprojectStatus.underReview:
        return 'En Revisión';
      case AnteprojectStatus.approved:
        return 'Aprobado';
      case AnteprojectStatus.rejected:
        return 'Rechazado';
    }
  }

  bool get isSubmitted => this == AnteprojectStatus.submitted;
  bool get isUnderReview => this == AnteprojectStatus.underReview;
  bool get isApproved => this == AnteprojectStatus.approved;
  bool get isRejected => this == AnteprojectStatus.rejected;
  bool get isFinal => isApproved || isRejected;
}
