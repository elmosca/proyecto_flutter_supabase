import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/models.dart';

class AuthService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  /// Obtiene el usuario actual autenticado
  supabase.User? get currentUser => _supabase.auth.currentUser;

  /// Stream de cambios en el estado de autenticación
  Stream<supabase.AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Inicia sesión con email y password
  Future<supabase.AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw const AuthException('Error en la autenticación');
      }
      
      return response;
    } on supabase.AuthException catch (e) {
      throw AuthException('Error de autenticación: ${e.message}');
    } catch (e) {
      throw AuthException('Error inesperado: $e');
    }
  }

  /// Cierra la sesión actual
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException('Error al cerrar sesión: $e');
    }
  }

  /// Obtiene el perfil completo del usuario actual
  Future<User?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Obtener datos del perfil desde la tabla users
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return User.fromJson(response);
    } catch (e) {
      throw AuthException('Error al obtener perfil: $e');
    }
  }

  /// Actualiza el perfil del usuario
  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? biography,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AuthException('Usuario no autenticado');
      }

      await _supabase
          .from('users')
          .update({
            'full_name': fullName,
            'phone': phone,
            'biography': biography,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      throw AuthException('Error al actualizar perfil: $e');
    }
  }

  /// Verifica si el usuario está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Obtiene el ID del usuario actual
  String? get currentUserId => currentUser?.id;

  /// Obtiene el email del usuario actual
  String? get currentUserEmail => currentUser?.email;

  /// Verifica si el usuario tiene un rol específico
  Future<bool> hasRole(UserRole role) async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.role == role;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si el usuario es administrador
  Future<bool> get isAdmin async => hasRole(UserRole.admin);

  /// Verifica si el usuario es tutor
  Future<bool> get isTutor async => hasRole(UserRole.tutor);

  /// Verifica si el usuario es estudiante
  Future<bool> get isStudent async => hasRole(UserRole.student);
}

/// Excepción personalizada para errores de autenticación
class AuthException implements Exception {
  final String message;
  
  const AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}
