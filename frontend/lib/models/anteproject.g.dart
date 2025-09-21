// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anteproject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Anteproject _$AnteprojectFromJson(Map<String, dynamic> json) => Anteproject(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  projectType: $enumDecode(_$ProjectTypeEnumMap, json['project_type']),
  description: json['description'] as String,
  academicYear: json['academic_year'] as String,
  expectedResults: json['expected_results'] as Map<String, dynamic>,
  timeline: json['timeline'] as Map<String, dynamic>,
  status: $enumDecode(_$AnteprojectStatusEnumMap, json['status']),
  tutorId: (json['tutor_id'] as num?)?.toInt(),
  submittedAt: json['submitted_at'] == null
      ? null
      : DateTime.parse(json['submitted_at'] as String),
  reviewedAt: json['reviewed_at'] == null
      ? null
      : DateTime.parse(json['reviewed_at'] as String),
  projectId: (json['project_id'] as num?)?.toInt(),
  tutorComments: json['tutor_comments'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AnteprojectToJson(Anteproject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'project_type': _$ProjectTypeEnumMap[instance.projectType]!,
      'description': instance.description,
      'academic_year': instance.academicYear,
      'expected_results': instance.expectedResults,
      'timeline': instance.timeline,
      'status': _$AnteprojectStatusEnumMap[instance.status]!,
      'tutor_id': instance.tutorId,
      'submitted_at': instance.submittedAt?.toIso8601String(),
      'reviewed_at': instance.reviewedAt?.toIso8601String(),
      'project_id': instance.projectId,
      'tutor_comments': instance.tutorComments,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$ProjectTypeEnumMap = {
  ProjectType.execution: 'execution',
  ProjectType.research: 'research',
  ProjectType.bibliographic: 'bibliographic',
  ProjectType.management: 'management',
};

const _$AnteprojectStatusEnumMap = {
  AnteprojectStatus.draft: 'draft',
  AnteprojectStatus.submitted: 'submitted',
  AnteprojectStatus.underReview: 'under_review',
  AnteprojectStatus.approved: 'approved',
  AnteprojectStatus.rejected: 'rejected',
};
