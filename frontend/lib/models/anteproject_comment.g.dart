// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anteproject_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnteprojectComment _$AnteprojectCommentFromJson(Map<String, dynamic> json) =>
    AnteprojectComment(
      id: (json['id'] as num).toInt(),
      anteprojectId: (json['anteprojectId'] as num).toInt(),
      authorId: (json['authorId'] as num).toInt(),
      content: json['content'] as String,
      isInternal: json['isInternal'] as bool,
      section: $enumDecode(_$AnteprojectSectionEnumMap, json['section']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      author: json['author'] == null
          ? null
          : User.fromJson(json['author'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnteprojectCommentToJson(AnteprojectComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'anteprojectId': instance.anteprojectId,
      'authorId': instance.authorId,
      'content': instance.content,
      'isInternal': instance.isInternal,
      'section': _$AnteprojectSectionEnumMap[instance.section]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'author': instance.author,
    };

const _$AnteprojectSectionEnumMap = {
  AnteprojectSection.general: 'general',
  AnteprojectSection.description: 'description',
  AnteprojectSection.objectives: 'objectives',
  AnteprojectSection.expectedResults: 'expectedResults',
  AnteprojectSection.timeline: 'timeline',
  AnteprojectSection.methodology: 'methodology',
  AnteprojectSection.resources: 'resources',
  AnteprojectSection.other: 'other',
};
