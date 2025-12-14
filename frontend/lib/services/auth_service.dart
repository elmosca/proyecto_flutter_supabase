// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';
import '../models/user.dart';
import '../utils/app_exception.dart';
import '../utils/network_error_detector.dart';
import 'supabase_interceptor.dart';
import 'email_notification_service.dart';

/// Servicio para gestionar la autenticación con Supabase.
///
/// Este servicio encapsula todas las operaciones relacionadas con
/// autenticación, sesión y perfil del usuario:
/// - Inicio y cierre de sesión usando Supabase Auth
/// - Suscripción a cambios del estado de autenticación
/// - Lectura/actualización del perfil en la tabla `users`
/// - Persistencia local y recuperación de la sesión
///
/// Seguridad:
/// - Requiere inicializar correctamente `Supabase.instance` antes de su uso
/// - Respeta las políticas RLS configuradas en la base de datos
///
/// Excepciones lanzadas habituales:
/// - [ConfigurationException] si el cliente de Supabase no está inicializado
/// - [AuthenticationException] en errores de autenticación/sesión
/// - Excepciones derivadas por red a través de `NetworkErrorDetector`
class AuthService {
  supabase.SupabaseClient get _supabase {
    try {
      return supabase.Supabase.instance.client;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error accediendo a Supabase client: $e');
      }
      throw ConfigurationException(
        'configuration_missing',
        technicalMessage: 'Supabase client not initialized: $e',
        originalError: e,
      );
    }
  }

  static const String _sessionKey = 'user_session';

  /// Obtiene el usuario actual autenticado
  supabase.User? get currentUser => _supabase.auth.currentUser;

  /// Stream de cambios en el estado de autenticación
  Stream<supabase.AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  /// Inicia sesión con email y password usando Supabase Auth.
  ///
  /// Parámetros:
  /// - [email]: Correo electrónico del usuario
  /// - [password]: Contraseña del usuario
  ///
  /// Retorna:
  /// - Un mapa con la forma `{ success: true, user: {...} }` cuando es exitoso
  ///
  /// Lanza:
  /// - [AuthenticationException] si las credenciales son inválidas o hay
  ///   problemas al crear el perfil de usuario
  /// - Errores interceptados de Supabase o de red
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
        throw AuthenticationException(
          'invalid_credentials',
          technicalMessage: 'Authentication failed: user is null',
        );
      }

      print('✅ Login exitoso con Supabase Auth');

      // Obtener el perfil completo del usuario desde la tabla users
      final userProfile = await getCurrentUserProfile();

      if (userProfile == null) {
        throw AuthenticationException(
          'profile_not_found',
          technicalMessage:
              'User profile not found after successful authentication',
        );
      }

      // Crear respuesta en el formato esperado
      return {
        'success': true,
        'user': {
          'id': userProfile.id,
          'email': userProfile.email,
          'full_name': userProfile.fullName,
          'role': userProfile.role.name,
          'status': userProfile.status.name,
          'created_at': userProfile.createdAt.toIso8601String(),
          'updated_at': userProfile.updatedAt.toIso8601String(),
        },
      };
    } catch (e) {
      print('❌ Error en login: $e');

      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      // Error genérico de autenticación
      throw AuthenticationException(
        'authentication_generic',
        technicalMessage: 'Authentication error: $e',
        originalError: e,
      );
    }
  }

  /// Verifica si hay una sesión activa de Supabase y construye el perfil.
  ///
  /// Retorna:
  /// - [User] completo desde la tabla `users` si existe
  /// - `null` si no hay sesión
  ///
  /// Notas:
  /// - Consulta la tabla `users` por email para obtener el ID entero y
  ///   metadatos del perfil
  Future<User?> getCurrentUserFromSupabase() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('ℹ️ No hay usuario autenticado en Supabase');
        return null;
      }

      print('✅ Usuario encontrado en Supabase: ${user.email}');

      // Obtener perfil completo desde la base de datos
      // SIEMPRE consultar la tabla users primero (ID int)
      print('🔍 Debug - Consultando tabla users para: ${user.email}');

      final response = await _supabase
          .from('users')
          .select()
          .eq('email', user.email!)
          .single();

      print('🔍 Debug - Perfil obtenido desde users: $response');

      // Crear objeto User desde el perfil de la base de datos
      final userId = response['id'] as int;
      final String email = (response['email'] as String);
      final String roleName = email.toLowerCase() == 'admin@jualas.es'
          ? 'admin'
          : (response['role'] as String);

      return User(
        id: userId,
        email: email,
        fullName: response['full_name'] as String,
        role: UserRole.values.firstWhere(
          (role) => role.name == roleName,
          orElse: () => UserRole.student,
        ),
        status: UserStatus.values.firstWhere(
          (status) => status.name == response['status'],
          orElse: () => UserStatus.active,
        ),
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: DateTime.parse(response['updated_at'] as String),
      );
    } catch (e) {
      print('❌ Error obteniendo usuario de Supabase: $e');
      return null;
    }
  }

  /// Cierra la sesión actual.
  ///
  /// Lanza:
  /// - [AuthenticationException] si falla el cierre de sesión
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw AuthenticationException(
        'session_expired',
        technicalMessage: 'Error during sign out: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene el perfil completo del usuario actual.
  ///
  /// Retorna el modelo [User] si puede mapear los datos de la tabla `users`.
  Future<User?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      print('✅ Usuario encontrado en Supabase: ${user.email}');

      // Buscar el usuario en la tabla users por email
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('email', user.email!);

      print('🔍 Respuesta de la consulta users: $response');

      if (response.isNotEmpty && response.length == 1) {
        final userData = response.first;
        // Usar directamente la respuesta de la base de datos (ya tiene los nombres correctos)
        final userDataMap = {
          'id': userData['id'] is String
              ? int.parse(userData['id'])
              : userData['id'],
          'full_name': userData['full_name'],
          'email': userData['email'],
          'nre': userData['nre'],
          'role':
              (userData['email'] as String).toLowerCase() == 'admin@jualas.es'
              ? 'admin'
              : userData['role'],
          'phone': userData['phone'],
          'biography': userData['biography'],
          'status': userData['status'],
          'specialty': userData['specialty'],
          'tutor_id': userData['tutor_id'] is String
              ? int.tryParse(userData['tutor_id'])
              : userData['tutor_id'],
          'academic_year': userData['academic_year'],
          'created_at': userData['created_at'],
          'updated_at': userData['updated_at'],
        };

        return User.fromJson(userDataMap);
      }

      // Si no se encuentra en la tabla users, crear un usuario temporal
      print(
        '⚠️ Usuario no encontrado en tabla users, creando usuario temporal',
      );
      return User(
        id: int.tryParse(user.id) ?? 0,
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
      print('❌ Error al obtener perfil: $e');
      return null;
    }
  }

  /// Convierte la respuesta de `signIn` a un objeto [User].
  ///
  /// Lanza [ValidationException] si el JSON no es válido.
  User? createUserFromLoginResponse(Map<String, dynamic> loginResponse) {
    try {
      print('🔍 Debug - Respuesta de login: $loginResponse');

      if (loginResponse['success'] == true && loginResponse['user'] != null) {
        final userData = Map<String, dynamic>.from(loginResponse['user']);

        print('🔍 Debug - Datos del usuario: $userData');

        // Asegurar que el ID sea int (puede venir como int o String)
        if (userData['id'] is String) {
          userData['id'] = int.parse(userData['id']);
        }

        // Usar los nombres de la base de datos directamente (snake_case)
        final convertedData = <String, dynamic>{
          'id': userData['id'],
          'full_name': userData['full_name'] ?? 'Usuario',
          'email': userData['email'] ?? '',
          'nre': userData['nre'] ?? '',
          'role': userData['role'] ?? 'student',
          'phone': userData['phone'] ?? '',
          'biography': userData['biography'] ?? '',
          'status': userData['status'] ?? 'active',
          'specialty': userData['specialty'] ?? '',
          'tutor_id': userData['tutor_id'],
          'academic_year': userData['academic_year'] ?? '',
          'created_at':
              userData['created_at'] ?? DateTime.now().toIso8601String(),
          'updated_at':
              userData['updated_at'] ?? DateTime.now().toIso8601String(),
        };

        print('🔍 Debug - Datos finales del usuario: $convertedData');

        // Forzar rol admin para el correo admin@jualas.es
        if ((convertedData['email'] as String).toLowerCase() ==
            'admin@jualas.es') {
          convertedData['role'] = 'admin';
        }

        return User.fromJson(convertedData);
      }
      print('❌ Debug - Respuesta de login inválida o sin usuario');
      return null;
    } catch (e) {
      print('❌ Debug - Error al crear usuario: $e');
      throw ValidationException(
        'invalid_json',
        technicalMessage: 'Error creating user from login response: $e',
        originalError: e,
      );
    }
  }

  /// Actualiza el perfil del usuario en la tabla `users`.
  ///
  /// Parámetros:
  /// - [fullName]: Nombre completo requerido
  /// - [phone]: Teléfono (opcional)
  /// - [biography]: Biografía (opcional)
  ///
  /// Lanza:
  /// - [AuthenticationException] si no hay usuario autenticado o falla la
  ///   actualización
  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? biography,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage:
              'User not authenticated when trying to update profile',
        );
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw AuthenticationException(
        'profile_update_failed',
        technicalMessage: 'Error updating user profile: $e',
        originalError: e,
      );
    }
  }

  /// Verifica si el usuario está autenticado.
  bool get isAuthenticated => currentUser != null;

  /// Obtiene el ID del usuario actual.
  String? get currentUserId => currentUser?.id;

  /// Obtiene el email del usuario actual.
  String? get currentUserEmail => currentUser?.email;

  /// Verifica si el usuario tiene un rol específico.
  Future<bool> hasRole(UserRole role) async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.role == role;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si el usuario es administrador.
  Future<bool> get isAdmin async => hasRole(UserRole.admin);

  /// Verifica si el usuario es tutor.
  Future<bool> get isTutor async => hasRole(UserRole.tutor);

  /// Verifica si el usuario es estudiante.
  Future<bool> get isStudent async => hasRole(UserRole.student);

  /// Parsea el rol del usuario basado en su email.
  UserRole _parseUserRoleFromEmail(String email) {
    if (email.toLowerCase() == 'admin@jualas.es') {
      return UserRole.admin;
    } else if (email.contains('@alumno.cifpcarlos3.es')) {
      return UserRole.student;
    } else if (email.contains('admin.test@cifpcarlos3.es') ||
        email.contains('admin@cifpcarlos3.es')) {
      return UserRole.admin;
    } else if (email.contains('tutor.test@cifpcarlos3.es') ||
        (email.contains('@cifpcarlos3.es') && !email.contains('admin'))) {
      return UserRole.tutor;
    }
    return UserRole.student; // Por defecto
  }

  /// Guarda la sesión del usuario en `SharedPreferences`.
  Future<void> saveUserSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode({
        'id': user.id,
        'email': user.email,
        'full_name': user.fullName,
        'role': user.role.name,
        'status': user.status.name,
        'academic_year': user.academicYear,
        'created_at': user.createdAt.toIso8601String(),
        'updated_at': user.updatedAt.toIso8601String(),
      });
      await prefs.setString(_sessionKey, userJson);
      print('✅ Sesión guardada en SharedPreferences');
    } catch (e) {
      print('❌ Error guardando sesión: $e');
    }
  }

  /// Recupera la sesión del usuario desde `SharedPreferences`.
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
        id: userData['id'] is int ? userData['id'] : (userData['id'] as String).hashCode,
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
        academicYear: userData['academic_year'] as String?,
        createdAt: DateTime.parse(userData['created_at'] as String),
        updatedAt: DateTime.parse(userData['updated_at'] as String),
      );

      print('✅ Sesión recuperada desde SharedPreferences (academicYear: ${user.academicYear})');
      return user;
    } catch (e) {
      print('❌ Error recuperando sesión: $e');
      return null;
    }
  }

  /// Elimina la sesión guardada.
  Future<void> clearSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      print('✅ Sesión eliminada de SharedPreferences');
    } catch (e) {
      print('❌ Error eliminando sesión: $e');
    }
  }

  /// Solicita un email para restablecer la contraseña.
  ///
  /// Parámetros:
  /// - [email]: Correo electrónico del usuario
  ///
  /// Lanza:
  /// - [AuthenticationException] si falla la solicitud
  /// Solicita el restablecimiento de contraseña.
  ///
  /// Si el usuario es un estudiante con tutor asignado, se notifica al tutor.
  /// Si no, se envía el email tradicional de Supabase.
  ///
  /// Retorna un mapa con:
  /// - sentToTutor: true si se envió al tutor, false si se envió email directo
  /// - tutorName: nombre del tutor (si aplica)
  Future<Map<String, dynamic>> resetPasswordForEmail(String email) async {
    try {
      print('🔐 Solicitando reset de contraseña para: $email');

      // Buscar al usuario por email
      final userResponse = await _supabase
          .from('users')
          .select('id, full_name, email, role, tutor_id')
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) {
        throw AuthenticationException(
          'user_not_found',
          technicalMessage: 'No se encontró un usuario con ese email',
        );
      }

      final userId = userResponse['id'] as int;
      final userFullName = userResponse['full_name'] as String;
      final userRole = userResponse['role'] as String;
      final tutorId = userResponse['tutor_id'] as int?;

      print(
        '👤 Usuario encontrado: $userFullName (ID: $userId, Rol: $userRole)',
      );

      // Si es un estudiante con tutor asignado, notificar al tutor
      if (userRole == 'student' && tutorId != null) {
        print('👨‍🏫 Buscando tutor con ID: $tutorId');

        // Obtener información del tutor
        final tutorResponse = await _supabase
            .from('users')
            .select('id, full_name, email')
            .eq('id', tutorId)
            .single();

        final tutorName = tutorResponse['full_name'] as String;
        final tutorEmail = tutorResponse['email'] as String;

        print('✅ Tutor encontrado: $tutorName ($tutorEmail)');

        // Crear notificación interna para el tutor
        await _supabase.from('notifications').insert({
          'user_id': tutorId,
          'type': 'password_reset_request',
          'title': 'Solicitud de Restablecimiento de Contraseña',
          'message':
              'El estudiante $userFullName ($email) ha solicitado restablecer su contraseña. Por favor, accede a la gestión de estudiantes para generar una nueva contraseña temporal.',
          'read_at': null, // null = no leída
          'created_at': DateTime.now().toIso8601String(),
        });

        print('✅ Notificación interna creada para el tutor');

        // Enviar email al tutor
        try {
          await EmailNotificationService.sendPasswordResetRequestToTutor(
            tutorEmail: tutorEmail,
            tutorName: tutorName,
            studentEmail: email,
            studentName: userFullName,
          );
          print('✅ Email enviado al tutor');
        } catch (emailError) {
          print('⚠️ Error enviando email al tutor: $emailError');
          // No lanzar error, la notificación interna ya fue creada
        }

        print(
          '✅ Solicitud enviada al tutor. El tutor recibirá una notificación y un email.',
        );

        return {
          'sentToTutor': true,
          'tutorName': tutorName,
          'tutorEmail': tutorEmail,
        };
      } else {
        // Si es un tutor o admin, o un estudiante sin tutor, usar el flujo tradicional
        print(
          '⚠️ Usuario sin tutor asignado o no es estudiante. Usando flujo tradicional de Supabase.',
        );

        // Determinar la URL de redirección según la plataforma
        String redirectUrl;
        if (kIsWeb) {
          final baseUrl = Uri.base.origin;
          redirectUrl = '$baseUrl/reset-password?type=reset';
        } else {
          // En desktop/mobile, usar deep link
          redirectUrl = 'tfgapp://reset-password?type=reset';
        }

        print('🔗 Redirect URL: $redirectUrl');

        await _supabase.auth.resetPasswordForEmail(
          email,
          redirectTo: redirectUrl,
        );

        print('✅ Email de reset de contraseña enviado');

        return {'sentToTutor': false};
      }
    } catch (e) {
      print('❌ Error solicitando reset de contraseña: $e');

      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw AuthenticationException(
        'password_reset_failed',
        technicalMessage: 'Error requesting password reset: $e',
        originalError: e,
      );
    }
  }

  /// Actualiza la contraseña del usuario después de recibir el link de reset.
  ///
  /// Parámetros:
  /// - [newPassword]: Nueva contraseña
  ///
  /// Lanza:
  /// - [AuthenticationException] si falla la actualización
  Future<void> updatePassword(String newPassword) async {
    try {
      print('🔐 Actualizando contraseña');

      final response = await _supabase.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw AuthenticationException(
          'password_update_failed',
          technicalMessage: 'Password update failed: user is null',
        );
      }

      print('✅ Contraseña actualizada exitosamente');
    } catch (e) {
      print('❌ Error actualizando contraseña: $e');

      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw AuthenticationException(
        'password_update_failed',
        technicalMessage: 'Error updating password: $e',
        originalError: e,
      );
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
