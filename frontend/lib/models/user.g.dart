// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  nre: json['nre'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  phone: json['phone'] as String?,
  biography: json['biography'] as String?,
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.active,
  specialty: json['specialty'] as String?,
  tutorId: (json['tutor_id'] as num?)?.toInt(),
  academicYear: json['academic_year'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'email': instance.email,
  'nre': instance.nre,
  'role': _$UserRoleEnumMap[instance.role]!,
  'phone': instance.phone,
  'biography': instance.biography,
  'status': _$UserStatusEnumMap[instance.status]!,
  'specialty': instance.specialty,
  'tutor_id': instance.tutorId,
  'academic_year': instance.academicYear,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.tutor: 'tutor',
  UserRole.student: 'student',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.inactive: 'inactive',
};
