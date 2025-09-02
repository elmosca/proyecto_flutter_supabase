import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable()
class Project {
  final int id;
  final String title;
  final String description;
  final ProjectStatus status;
  final DateTime? startDate;
  final DateTime? estimatedEndDate;
  final DateTime? actualEndDate;
  final int tutorId;
  final int? anteprojectId;
  final String? githubRepositoryUrl;
  final String githubMainBranch;
  final DateTime? lastActivityAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.startDate,
    this.estimatedEndDate,
    this.actualEndDate,
    required this.tutorId,
    this.anteprojectId,
    this.githubRepositoryUrl,
    required this.githubMainBranch,
    this.lastActivityAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  Project copyWith({
    int? id,
    String? title,
    String? description,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? estimatedEndDate,
    DateTime? actualEndDate,
    int? tutorId,
    int? anteprojectId,
    String? githubRepositoryUrl,
    String? githubMainBranch,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      estimatedEndDate: estimatedEndDate ?? this.estimatedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      tutorId: tutorId ?? this.tutorId,
      anteprojectId: anteprojectId ?? this.anteprojectId,
      githubRepositoryUrl: githubRepositoryUrl ?? this.githubRepositoryUrl,
      githubMainBranch: githubMainBranch ?? this.githubMainBranch,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum ProjectStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('planning')
  planning,
  @JsonValue('development')
  development,
  @JsonValue('review')
  review,
  @JsonValue('completed')
  completed,
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.draft:
        return 'Borrador';
      case ProjectStatus.planning:
        return 'Planificación';
      case ProjectStatus.development:
        return 'En Desarrollo';
      case ProjectStatus.review:
        return 'En Revisión';
      case ProjectStatus.completed:
        return 'Completado';
    }
  }

  String get shortName {
    switch (this) {
      case ProjectStatus.draft:
        return 'Borrador';
      case ProjectStatus.planning:
        return 'Planificación';
      case ProjectStatus.development:
        return 'Desarrollo';
      case ProjectStatus.review:
        return 'Revisión';
      case ProjectStatus.completed:
        return 'Completado';
    }
  }

  bool get isCompleted => this == ProjectStatus.completed;
  bool get isInDevelopment => this == ProjectStatus.development;
  bool get isInPlanning => this == ProjectStatus.planning;
  bool get isInReview => this == ProjectStatus.review;
  bool get isDraft => this == ProjectStatus.draft;
}
