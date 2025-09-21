import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';

class UserManagementService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  /// Crea un nuevo tutor (solo administradores)
  Future<Map<String, dynamic>> createTutor({
    required String email,
    required String password,
    required String fullName,
    String? specialty,
    String? phone,
  }) async {
    try {
      // ignore: avoid_print
      print('🔍 Debug - Creando tutor: $email');
      
      final response = await _supabase.rpc('create_tutor', params: {
        'tutor_email': email,
        'tutor_password': password,
        'tutor_full_name': fullName,
        'tutor_specialty': specialty,
        'tutor_phone': phone,
      });

      // ignore: avoid_print
      print('✅ Debug - Respuesta crear tutor: $response');
      return response;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Debug - Error al crear tutor: $e');
      throw UserManagementException('Error al crear tutor: $e');
    }
  }

  /// Importa estudiantes desde CSV (solo tutores)
  Future<Map<String, dynamic>> importStudentsFromCsv({
    required List<Map<String, dynamic>> studentsData,
  }) async {
    try {
      // ignore: avoid_print
      print('🔍 Debug - Importando ${studentsData.length} estudiantes');
      
      final response = await _supabase.rpc('import_students_csv', params: {
        'students_data': studentsData,
      });

      // ignore: avoid_print
      print('✅ Debug - Respuesta importar estudiantes: $response');
      return response;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Debug - Error al importar estudiantes: $e');
      throw UserManagementException('Error al importar estudiantes: $e');
    }
  }

  /// Obtiene todos los tutores (solo administradores)
  Future<List<User>> getTutors() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('role', 'tutor')
          .order('created_at', ascending: false);

      return response.map<User>(User.fromJson).toList();
    } catch (e) {
      throw UserManagementException('Error al obtener tutores: $e');
    }
  }

  /// Obtiene estudiantes de un tutor específico
  Future<List<User>> getStudentsByTutor(int tutorId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('role', 'student')
          .eq('tutor_id', tutorId)
          .order('created_at', ascending: false);

      return response.map<User>(User.fromJson).toList();
    } catch (e) {
      throw UserManagementException('Error al obtener estudiantes: $e');
    }
  }

  /// Obtiene todos los estudiantes (solo administradores)
  Future<List<User>> getAllStudents() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('role', 'student')
          .order('created_at', ascending: false);

      return response.map<User>(User.fromJson).toList();
    } catch (e) {
      throw UserManagementException('Error al obtener estudiantes: $e');
    }
  }

  /// Actualiza un usuario
  Future<User> updateUser(int userId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return User.fromJson(response);
    } catch (e) {
      throw UserManagementException('Error al actualizar usuario: $e');
    }
  }

  /// Desactiva un usuario
  Future<void> deactivateUser(int userId) async {
    try {
      await _supabase
          .from('users')
          .update({'status': 'inactive'})
          .eq('id', userId);
    } catch (e) {
      throw UserManagementException('Error al desactivar usuario: $e');
    }
  }

  /// Activa un usuario
  Future<void> activateUser(int userId) async {
    try {
      await _supabase
          .from('users')
          .update({'status': 'active'})
          .eq('id', userId);
    } catch (e) {
      throw UserManagementException('Error al activar usuario: $e');
    }
  }
}

class UserManagementException implements Exception {
  final String message;
  const UserManagementException(this.message);
  
  @override
  String toString() => 'UserManagementException: $message';
}
