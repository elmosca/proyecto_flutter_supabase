import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Crear un nuevo usuario
  Future<void> createUser(app_user.User user) async {
    try {
      await _supabase
          .from('users')
          .insert({
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
            'password_hash': 'temp_password_hash', // Se generará automáticamente
          });
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  /// Obtener estudiantes por tutor
  Future<List<app_user.User>> getStudentsByTutor(int tutorId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('tutor_id', tutorId)
          .eq('role', 'student');

      // La respuesta exitosa no es una excepción

      return (response as List)
          .map((json) {
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
              'tutor_id': json['tutor_id'] is String ? int.tryParse(json['tutor_id']) : json['tutor_id'],
              'academic_year': json['academic_year'],
              'created_at': json['created_at'],
              'updated_at': json['updated_at'],
            };
            return app_user.User.fromJson(userData);
          })
          .toList();
    } catch (e) {
      throw Exception('Error al obtener estudiantes: $e');
    }
  }

  /// Eliminar un usuario
  Future<void> deleteUser(int userId) async {
    try {
      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  /// Obtener todos los usuarios
  Future<List<app_user.User>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select();

      // La respuesta exitosa no es una excepción

      return (response as List)
          .map((json) {
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
              'tutor_id': json['tutor_id'] is String ? int.tryParse(json['tutor_id']) : json['tutor_id'],
              'academic_year': json['academic_year'],
              'created_at': json['created_at'],
              'updated_at': json['updated_at'],
            };
            return app_user.User.fromJson(userData);
          })
          .toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  /// Obtener usuario por ID
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
        'id': response['id'] is String ? int.parse(response['id']) : response['id'],
        'fullName': response['full_name'],
        'email': response['email'],
        'nre': response['nre'],
        'role': response['role'],
        'phone': response['phone'],
        'biography': response['biography'],
        'status': response['status'],
        'specialty': response['specialty'],
        'tutor_id': response['tutor_id'] is String ? int.tryParse(response['tutor_id']) : response['tutor_id'],
        'academic_year': response['academic_year'],
        'createdAt': response['created_at'],
        'updatedAt': response['updated_at'],
      };

      return app_user.User.fromJson(userData);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  /// Actualizar usuario
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
