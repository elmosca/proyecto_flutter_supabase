import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import 'user_management_service.dart';

/// Servicio para operaciones básicas de usuarios.
///
/// Proporciona operaciones CRUD sobre la tabla `users` de Supabase:
/// - Creación, lectura, actualización y eliminación de usuarios
/// - Consultas por tutor y por ID
/// - Mapeo automático entre formato de BD y modelo [User]
///
/// ## Funcionalidades principales:
/// - Crear usuarios con datos completos
/// - Obtener estudiantes asignados a un tutor
/// - Consultar usuarios por ID
/// - Actualizar información de usuario
/// - Eliminar usuarios
///
/// ## Seguridad:
/// - Requiere autenticación: Sí
/// - Roles permitidos: Todos (con restricciones por RLS)
/// - Políticas RLS aplicadas: Los usuarios solo pueden ver/editar según su rol
///
/// ## Ejemplo de uso:
/// ```dart
/// final service = UserService();
/// final students = await service.getStudentsByTutor(tutorId: 123);
/// ```
///
/// Ver también: [UserManagementService], [User]
class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Crea un nuevo usuario en la tabla `users`.
  ///
  /// Parámetros:
  /// - [user]: Objeto [User] con todos los datos del usuario
  ///
  /// Lanza:
  /// - [Exception] si falla la inserción en la base de datos
  Future<void> createUser(app_user.User user) async {
    try {
      await _supabase.from('users').insert({
        'full_name': user.fullName,
        'email': user.email,
        'nre': user.nre,
        'role': user.role.name,
        'phone': user.phone,
        'biography': user.biography,
        'status': user.status.name,
        'specialty': user.specialty,
        'academic_year': user.academicYear,
        'tutor_id': user.tutorId,
        // password_hash ahora es nullable - las contraseñas se gestionan en Supabase Auth (auth.users)
      });
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  /// Obtiene todos los estudiantes asignados a un tutor específico.
  ///
  /// Parámetros:
  /// - [tutorId]: ID del tutor
  ///
  /// Retorna:
  /// - Lista de [User] con rol 'student' asignados al tutor
  ///
  /// Lanza:
  /// - [Exception] si falla la consulta
  Future<List<app_user.User>> getStudentsByTutor(int tutorId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('tutor_id', tutorId)
          .eq('role', 'student');

      // La respuesta exitosa no es una excepción

      return (response as List).map((json) {
        // Mapear los nombres de columnas de la base de datos a los nombres del modelo
        final userData = {
          'id': json['id'] is String ? int.parse(json['id']) : json['id'],
          'full_name': json['full_name'],
          'email': json['email'],
          'nre': json['nre'],
          'role': json['role'],
          'phone': json['phone'],
          'biography': json['biography'],
          'status': json['status'],
          'specialty': json['specialty'],
          'tutor_id': json['tutor_id'] is String
              ? int.tryParse(json['tutor_id'])
              : json['tutor_id'],
          'academic_year': json['academic_year'],
          'created_at': json['created_at'],
          'updated_at': json['updated_at'],
        };
        return app_user.User.fromJson(userData);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener estudiantes: $e');
    }
  }

  /// Elimina un usuario de la base de datos y de Supabase Auth.
  ///
  /// Parámetros:
  /// - [userId]: ID del usuario a eliminar
  ///
  /// Lanza:
  /// - [Exception] si falla la eliminación
  Future<void> deleteUser(int userId) async {
    try {
      // Obtener el email del usuario antes de eliminarlo para poder eliminarlo de Auth
      final userResponse = await _supabase
          .from('users')
          .select('email, role')
          .eq('id', userId)
          .single();

      final userEmail = userResponse['email'] as String?;
      final userRole = userResponse['role'] as String?;

      // Eliminar de la tabla users primero
      await _supabase.from('users').delete().eq('id', userId);

      // Si el usuario es estudiante o tutor, eliminarlo también de Auth
      if (userEmail != null && (userRole == 'student' || userRole == 'tutor')) {
        try {
          final userManagementService = UserManagementService();
          await userManagementService.deleteUserFromAuth(userEmail);
          debugPrint('✅ Usuario eliminado de Auth: $userEmail');
        } catch (e) {
          // Si falla la eliminación de Auth, registrar pero no fallar
          // El usuario ya fue eliminado de la tabla users
          debugPrint('⚠️ Error eliminando usuario de Auth (no crítico): $e');
        }
      }
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  /// Obtiene todos los usuarios de la base de datos.
  ///
  /// Retorna:
  /// - Lista completa de [User] de todos los roles
  ///
  /// Lanza:
  /// - [Exception] si falla la consulta
  Future<List<app_user.User>> getAllUsers() async {
    try {
      final response = await _supabase.from('users').select();

      // La respuesta exitosa no es una excepción

      return (response as List).map((json) {
        // Mapear los nombres de columnas de la base de datos a los nombres del modelo
        final userData = {
          'id': json['id'] is String ? int.parse(json['id']) : json['id'],
          'full_name': json['full_name'],
          'email': json['email'],
          'nre': json['nre'],
          'role': json['role'],
          'phone': json['phone'],
          'biography': json['biography'],
          'status': json['status'],
          'specialty': json['specialty'],
          'tutor_id': json['tutor_id'] is String
              ? int.tryParse(json['tutor_id'])
              : json['tutor_id'],
          'academic_year': json['academic_year'],
          'created_at': json['created_at'],
          'updated_at': json['updated_at'],
        };
        return app_user.User.fromJson(userData);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  /// Obtiene un usuario específico por su ID.
  ///
  /// Parámetros:
  /// - [userId]: ID del usuario a buscar
  ///
  /// Retorna:
  /// - [User] si se encuentra, `null` si no existe
  ///
  /// Lanza:
  /// - [Exception] si falla la consulta
  Future<app_user.User?> getUserById(int userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      // La respuesta exitosa no es una excepción

      // Mapear los nombres de columnas de la base de datos a los nombres del modelo
      final userData = {
        'id': response['id'] is String
            ? int.parse(response['id'])
            : response['id'],
        'fullName': response['full_name'],
        'email': response['email'],
        'nre': response['nre'],
        'role': response['role'],
        'phone': response['phone'],
        'biography': response['biography'],
        'status': response['status'],
        'specialty': response['specialty'],
        'tutor_id': response['tutor_id'] is String
            ? int.tryParse(response['tutor_id'])
            : response['tutor_id'],
        'academic_year': response['academic_year'],
        'createdAt': response['created_at'],
        'updatedAt': response['updated_at'],
      };

      return app_user.User.fromJson(userData);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  /// Actualiza la información de un usuario existente.
  ///
  /// Parámetros:
  /// - [user]: Objeto [User] con los datos actualizados
  ///
  /// Lanza:
  /// - [Exception] si falla la actualización
  Future<void> updateUser(app_user.User user) async {
    try {
      await _supabase
          .from('users')
          .update({
            'full_name': user.fullName,
            'email': user.email,
            'nre': user.nre,
            'phone': user.phone,
            'biography': user.biography,
            'specialty': user.specialty,
            'academic_year': user.academicYear,
            'tutor_id': user.tutorId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }
}
