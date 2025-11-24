// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anteproject_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnteprojectMessage _$AnteprojectMessageFromJson(Map<String, dynamic> json) =>
    AnteprojectMessage(
      id: (json['id'] as num).toInt(),
      anteprojectId: (json['anteproject_id'] as num).toInt(),
      senderId: (json['sender_id'] as num).toInt(),
      content: json['content'] as String,
      isRead: json['is_read'] as bool,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sender: json['sender'] == null
          ? null
          : User.fromJson(json['sender'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnteprojectMessageToJson(AnteprojectMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'anteproject_id': instance.anteprojectId,
      'sender_id': instance.senderId,
      'content': instance.content,
      'is_read': instance.isRead,
      'read_at': instance.readAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'sender': instance.sender,
    };
