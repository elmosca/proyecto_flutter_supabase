// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  status: $enumDecode(_$ProjectStatusEnumMap, json['status']),
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  estimatedEndDate: json['estimatedEndDate'] == null
      ? null
      : DateTime.parse(json['estimatedEndDate'] as String),
  actualEndDate: json['actualEndDate'] == null
      ? null
      : DateTime.parse(json['actualEndDate'] as String),
  tutorId: (json['tutorId'] as num).toInt(),
  anteprojectId: (json['anteprojectId'] as num?)?.toInt(),
  githubRepositoryUrl: json['githubRepositoryUrl'] as String?,
  githubMainBranch: json['githubMainBranch'] as String,
  lastActivityAt: json['lastActivityAt'] == null
      ? null
      : DateTime.parse(json['lastActivityAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'status': _$ProjectStatusEnumMap[instance.status]!,
  'startDate': instance.startDate?.toIso8601String(),
  'estimatedEndDate': instance.estimatedEndDate?.toIso8601String(),
  'actualEndDate': instance.actualEndDate?.toIso8601String(),
  'tutorId': instance.tutorId,
  'anteprojectId': instance.anteprojectId,
  'githubRepositoryUrl': instance.githubRepositoryUrl,
  'githubMainBranch': instance.githubMainBranch,
  'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$ProjectStatusEnumMap = {
  ProjectStatus.draft: 'draft',
  ProjectStatus.planning: 'planning',
  ProjectStatus.development: 'development',
  ProjectStatus.review: 'review',
  ProjectStatus.completed: 'completed',
};
