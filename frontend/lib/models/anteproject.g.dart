// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anteproject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Anteproject _$AnteprojectFromJson(Map<String, dynamic> json) => Anteproject(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  projectType: $enumDecode(_$ProjectTypeEnumMap, json['projectType']),
  description: json['description'] as String,
  academicYear: json['academicYear'] as String,
  expectedResults: json['expectedResults'] as Map<String, dynamic>,
  timeline: json['timeline'] as Map<String, dynamic>,
  status: $enumDecode(_$AnteprojectStatusEnumMap, json['status']),
  tutorId: (json['tutorId'] as num).toInt(),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
  projectId: (json['projectId'] as num?)?.toInt(),
  tutorComments: json['tutorComments'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AnteprojectToJson(Anteproject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'projectType': _$ProjectTypeEnumMap[instance.projectType]!,
      'description': instance.description,
      'academicYear': instance.academicYear,
      'expectedResults': instance.expectedResults,
      'timeline': instance.timeline,
      'status': _$AnteprojectStatusEnumMap[instance.status]!,
      'tutorId': instance.tutorId,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'projectId': instance.projectId,
      'tutorComments': instance.tutorComments,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
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
