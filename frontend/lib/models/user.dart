import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Modelo que representa al usuario de la aplicación.
///
/// Mapea a la tabla `users` de la base de datos y contiene información de
/// identidad, contacto, rol, estado y metadatos de creación/actualización.
///
/// Ejemplo JSON:
/// ```json
/// {
///   "id": 1,
///   "full_name": "Ada Lovelace",
///   "email": "ada@example.com",
///   "role": "student",
///   "status": "active",
///   "created_at": "2025-01-01T00:00:00Z",
///   "updated_at": "2025-01-10T12:00:00Z"
/// }
/// ```
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
      // Conversión robusta del ID
      int parseId(dynamic idValue) {
        if (idValue == null) {
          throw ArgumentError('ID no puede ser null');
        }
        if (idValue is int) return idValue;
        if (idValue is num) return idValue.toInt();
        final parsed = int.tryParse(idValue.toString());
        if (parsed != null) return parsed;
        throw ArgumentError('No se pudo convertir ID a int: $idValue (tipo: ${idValue.runtimeType})');
      }
      
      // Conversión robusta del tutor_id
      int? parseTutorId(dynamic tutorIdValue) {
        if (tutorIdValue == null) return null;
        if (tutorIdValue is int) return tutorIdValue;
        if (tutorIdValue is num) return tutorIdValue.toInt();
        final parsed = int.tryParse(tutorIdValue.toString());
        return parsed;
      }
      
      return User(
        id: parseId(json['id']),
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
        tutorId: parseTutorId(json['tutor_id']),
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
  /// Administrador del sistema.
  @JsonValue('admin')
  admin,

  /// Tutor docente.
  @JsonValue('tutor')
  tutor,

  /// Estudiante.
  @JsonValue('student')
  student,
}

enum UserStatus {
  /// Usuario activo.
  @JsonValue('active')
  active,

  /// Usuario inactivo.
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
