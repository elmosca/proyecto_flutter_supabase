import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String email;
  final String? nre;
  final UserRole role;
  final String? phone;
  final String? biography;
  @JsonKey(defaultValue: UserStatus.active)
  final UserStatus status;
  @JsonKey(name: 'specialty')
  final String? specialty;
  @JsonKey(name: 'tutor_id')
  final int? tutorId;
  @JsonKey(name: 'academic_year')
  final String? academicYear;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.nre,
    required this.role,
    this.phone,
    this.biography,
    required this.status,
    this.specialty,
    this.tutorId,
    this.academicYear,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: (json['id'] as num).toInt(),
        fullName: json['full_name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        nre: json['nre'] as String?,
        role: UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == json['role'],
          orElse: () => UserRole.student,
        ),
        phone: json['phone'] as String?,
        biography: json['biography'] as String?,
        status: UserStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
          orElse: () => UserStatus.active,
        ),
        specialty: json['specialty'] as String?,
        tutorId: json['tutor_id'] != null ? (json['tutor_id'] as num).toInt() : null,
        academicYear: json['academic_year'] as String?,
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Error en User.fromJson: $e');
      debugPrint('❌ JSON que causó el error: $json');
      rethrow;
    }
  }
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? nre,
    UserRole? role,
    String? phone,
    String? biography,
    UserStatus? status,
    String? specialty,
    int? tutorId,
    String? academicYear,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      nre: nre ?? this.nre,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      biography: biography ?? this.biography,
      status: status ?? this.status,
      specialty: specialty ?? this.specialty,
      tutorId: tutorId ?? this.tutorId,
      academicYear: academicYear ?? this.academicYear,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, fullName: $fullName, email: $email, role: $role, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('tutor')
  tutor,
  @JsonValue('student')
  student,
}

enum UserStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.tutor:
        return 'Tutor';
      case UserRole.student:
        return 'Alumno';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.tutor:
        return 'Tutor';
      case UserRole.student:
        return 'Alumno';
    }
  }
}

extension UserStatusExtension on UserStatus {
  String get displayName {
    switch (this) {
      case UserStatus.active:
        return 'Activo';
      case UserStatus.inactive:
        return 'Inactivo';
    }
  }

  bool get isActive => this == UserStatus.active;
}
