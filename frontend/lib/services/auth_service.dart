// ignore_for_file: avoid_print
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';
import '../models/user.dart';

class AuthService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;
  static const String _sessionKey = 'user_session';

  /// Obtiene el usuario actual autenticado
  supabase.User? get currentUser => _supabase.auth.currentUser;

  /// Stream de cambios en el estado de autenticación
  Stream<supabase.AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Inicia sesión con email y password usando Supabase Auth
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Intentando login con Supabase Auth para: $email');
      
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (authResponse.user == null) {
        throw const AuthException('Credenciales inválidas');
      }
      
      print('✅ Login exitoso con Supabase Auth');
      
      // Crear respuesta en el formato esperado
      return {
        'success': true,
        'user': {
          'id': authResponse.user!.id,
          'email': authResponse.user!.email,
          'full_name': authResponse.user!.userMetadata?['full_name'] ?? 'Usuario',
          'role': _parseUserRoleFromEmail(email).name,
          'status': 'active',
          'created_at': authResponse.user!.createdAt,
          'updated_at': authResponse.user!.updatedAt,
        }
      };
    } catch (e) {
      print('❌ Error en login: $e');
      throw AuthException('Error de autenticación: $e');
    }
  }

  /// Verifica si hay una sesión activa de Supabase
  Future<User?> getCurrentUserFromSupabase() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('ℹ️ No hay usuario autenticado en Supabase');
        return null;
      }

      print('✅ Usuario encontrado en Supabase: ${user.email}');
      
      // Crear objeto User desde Supabase
      return User(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] ?? 'Usuario',
        role: _parseUserRoleFromEmail(user.email ?? ''),
        status: UserStatus.active,
        createdAt: DateTime.parse(user.createdAt),
        updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
      );
    } catch (e) {
      print('❌ Error obteniendo usuario de Supabase: $e');
      return null;
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
      
      // Crear un objeto User desde los datos de Supabase Auth
      return User(
        id: user.id,
        fullName: user.userMetadata?['full_name'] ?? 'Usuario',
        email: user.email ?? '',
        nre: '',
        role: _parseUserRoleFromEmail(user.email ?? ''),
        phone: '',
        biography: '',
        status: UserStatus.active,
        createdAt: DateTime.parse(user.createdAt),
        updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
      );
    } catch (e) {
      throw AuthException('Error al obtener perfil: $e');
    }
  }

  /// Convierte la respuesta de login_user a un objeto User
  User? createUserFromLoginResponse(Map<String, dynamic> loginResponse) {
    try {
      print('🔍 Debug - Respuesta de login: $loginResponse');
      
      if (loginResponse['success'] == true && loginResponse['user'] != null) {
        final userData = Map<String, dynamic>.from(loginResponse['user']);
        
        print('🔍 Debug - Datos del usuario: $userData');
        
        // Convertir el ID a String para compatibilidad (puede venir como int o String)
        if (userData['id'] is int) {
          userData['id'] = userData['id'].toString();
        }
        
        // Convertir snake_case a camelCase para el modelo User
        final convertedData = <String, dynamic>{
          'id': userData['id'],
          'fullName': userData['full_name'] ?? 'Usuario',
          'email': userData['email'] ?? '',
          'nre': userData['nre'] ?? '',
          'role': userData['role'] ?? 'student',
          'phone': userData['phone'] ?? '',
          'biography': userData['biography'] ?? '',
          'status': userData['status'] ?? 'active',
          'createdAt': userData['created_at'] ?? DateTime.now().toIso8601String(),
          'updatedAt': userData['updated_at'] ?? DateTime.now().toIso8601String(),
        };
        
        print('🔍 Debug - Datos finales del usuario: $convertedData');
        
        return User.fromJson(convertedData);
      }
      print('❌ Debug - Respuesta de login inválida o sin usuario');
      return null;
    } catch (e) {
      print('❌ Debug - Error al crear usuario: $e');
      throw AuthException('Error al crear usuario desde respuesta de login: $e');
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
          .eq('email', user.email!);
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

  /// Parsea el rol del usuario basado en su email
  UserRole _parseUserRoleFromEmail(String email) {
    if (email.contains('@alumno.cifpcarlos3.es')) {
      return UserRole.student;
    } else if (email.contains('@cifpcarlos3.es') && !email.contains('admin')) {
      return UserRole.tutor;
    } else if (email.contains('admin@cifpcarlos3.es')) {
      return UserRole.admin;
    }
    return UserRole.student; // Por defecto
  }

  /// Guarda la sesión del usuario en SharedPreferences
  Future<void> saveUserSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode({
        'id': user.id,
        'email': user.email,
        'full_name': user.fullName,
        'role': user.role.name,
        'status': user.status,
        'created_at': user.createdAt.toIso8601String(),
        'updated_at': user.updatedAt.toIso8601String(),
      });
      await prefs.setString(_sessionKey, userJson);
      print('✅ Sesión guardada en SharedPreferences');
    } catch (e) {
      print('❌ Error guardando sesión: $e');
    }
  }

  /// Recupera la sesión del usuario desde SharedPreferences
  Future<User?> getSavedUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_sessionKey);
      
      if (userJson == null) {
        print('ℹ️ No hay sesión guardada');
        return null;
      }
      
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      final user = User(
        id: userData['id'] as String,
        email: userData['email'] as String,
        fullName: userData['full_name'] as String,
        role: UserRole.values.firstWhere(
          (role) => role.name == userData['role'],
          orElse: () => UserRole.student,
        ),
        status: UserStatus.values.firstWhere(
          (status) => status.name == userData['status'],
          orElse: () => UserStatus.active,
        ),
        createdAt: DateTime.parse(userData['created_at'] as String),
        updatedAt: DateTime.parse(userData['updated_at'] as String),
      );
      
      print('✅ Sesión recuperada desde SharedPreferences');
      return user;
    } catch (e) {
      print('❌ Error recuperando sesión: $e');
      return null;
    }
  }

  /// Elimina la sesión guardada
  Future<void> clearSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      print('✅ Sesión eliminada de SharedPreferences');
    } catch (e) {
      print('❌ Error eliminando sesión: $e');
    }
  }
}

/// Excepción personalizada para errores de autenticación
class AuthException implements Exception {
  final String message;
  
  const AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}
