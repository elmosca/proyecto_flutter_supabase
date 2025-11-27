import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';
import '../utils/app_exception.dart';
import '../utils/network_error_detector.dart';
import 'supabase_interceptor.dart';

/// Servicio para gestión avanzada de usuarios (administradores y tutores).
///
/// Proporciona operaciones administrativas sobre usuarios:
/// - Creación de tutores mediante RPC
/// - Importación masiva de estudiantes desde CSV
/// - Consultas específicas por rol (tutores, estudiantes)
/// - Activación/desactivación de usuarios
/// - Actualización de perfiles
///
/// ## Funcionalidades principales:
/// - Crear tutores con autenticación automática
/// - Importar estudiantes en lote desde CSV
/// - Gestionar estudiantes por tutor
/// - Activar/desactivar cuentas de usuario
/// - Consultar usuarios por rol
///
/// ## Seguridad:
/// - Requiere autenticación: Sí
/// - Roles permitidos: admin, tutor (con restricciones)
/// - Políticas RLS aplicadas: Restricciones por rol en funciones RPC
///
/// ## Ejemplo de uso:
/// ```dart
/// final service = UserManagementService();
/// final result = await service.createTutor(
///   email: 'tutor@example.com',
///   password: 'password123',
///   fullName: 'Juan Tutor'
/// );
/// ```
///
/// Ver también: [UserService], [User]
class UserManagementService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  /// Crea un nuevo tutor mediante función RPC de Supabase.
  ///
  /// Parámetros:
  /// - [email]: Email del tutor (debe ser único)
  /// - [password]: Contraseña para autenticación
  /// - [fullName]: Nombre completo del tutor
  /// - [specialty]: Especialidad del tutor (opcional)
  /// - [phone]: Teléfono de contacto (opcional)
  ///
  /// Retorna:
  /// - Mapa con resultado de la operación
  ///
  /// Lanza:
  /// - [DatabaseException] si falla la creación
  /// - Errores de red interceptados
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

      final response = await _supabase.rpc(
        'create_tutor',
        params: {
          'tutor_email': email,
          'tutor_password': password,
          'tutor_full_name': fullName,
          'tutor_specialty': specialty,
          'tutor_phone': phone,
        },
      );

      // ignore: avoid_print
      print('✅ Debug - Respuesta crear tutor: $response');
      return response;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Debug - Error al crear tutor: $e');
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in UserManagementService: $e',
        originalError: e,
      );
    }
  }

  /// Importa estudiantes masivamente desde datos CSV procesados.
  ///
  /// Parámetros:
  /// - [studentsData]: Lista de mapas con datos de estudiantes procesados
  ///
  /// Retorna:
  /// - Mapa con resultado de la importación (estudiantes creados, errores)
  ///
  /// Lanza:
  /// - [DatabaseException] si falla la importación
  Future<Map<String, dynamic>> importStudentsFromCsv({
    required List<Map<String, dynamic>> studentsData,
  }) async {
    try {
      // ignore: avoid_print
      print('🔍 Debug - Importando ${studentsData.length} estudiantes');

      final response = await _supabase.rpc(
        'import_students_csv',
        params: {'students_data': studentsData},
      );

      // ignore: avoid_print
      print('✅ Debug - Respuesta importar estudiantes: $response');
      return response;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Debug - Error al importar estudiantes: $e');
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in UserManagementService: $e',
        originalError: e,
      );
    }
  }

  /// Crea estudiantes masivamente usando la Edge Function.
  /// 
  /// Esta función evita los límites de rate limiting del cliente al procesar
  /// múltiples usuarios desde el servidor con permisos de administrador.
  ///
  /// Parámetros:
  /// - [students]: Lista de mapas con datos de estudiantes (debe incluir email, password, full_name)
  /// - [tutorId]: ID del tutor al que se asignarán los estudiantes (opcional)
  ///
  /// Retorna:
  /// - Mapa con resultados: { results: [...], errors: [...], summary: {...} }
  ///
  /// Lanza:
  /// - [DatabaseException] si falla la creación masiva
  Future<Map<String, dynamic>> bulkCreateStudents({
    required List<Map<String, dynamic>> students,
    int? tutorId,
  }) async {
    try {
      debugPrint('🚀 Creando ${students.length} estudiantes masivamente...');

      final response = await _supabase.functions
          .invoke(
            'super-action',
            body: {
              'action': 'bulk_create_students',
              'students': students,
              'tutor_id': tutorId,
            },
          )
          .timeout(
            const Duration(minutes: 5), // Timeout más largo para importaciones grandes
            onTimeout: () {
              throw DatabaseException(
                'edge_function_timeout',
                technicalMessage:
                    'La Edge Function tardó demasiado en responder. Esto puede ocurrir con importaciones muy grandes. Intenta dividir el CSV en lotes más pequeños.',
              );
            },
          );

      debugPrint(
        '✅ Respuesta de Edge Function recibida: status=${response.status}',
      );
      debugPrint('✅ Datos de respuesta: ${response.data}');

      // Verificar el estado de la respuesta
      if (response.status != 200) {
        final errorMessage =
            response.data?['error'] ??
            response.data?['message'] ??
            'Error desconocido al crear estudiantes masivamente';
        throw DatabaseException(
          'edge_function_error',
          technicalMessage:
              'Error en Edge Function: $errorMessage. Verifica que la Edge Function "super-action" esté desplegada correctamente.',
          originalError: response.data,
        );
      }

      // Verificar que la respuesta indica éxito
      if (response.data == null || response.data['success'] != true) {
        final errorMessage =
            response.data?['error'] ?? 'La Edge Function no retornó éxito';
        throw DatabaseException(
          'edge_function_error',
          technicalMessage:
              'Error en Edge Function: $errorMessage. Verifica los logs de la Edge Function en Supabase Dashboard.',
          originalError: response.data,
        );
      }

      debugPrint('✅ Estudiantes creados masivamente exitosamente');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      // Re-lanzar excepciones de tipo AppException
      if (e is AppException) {
        rethrow;
      }

      throw DatabaseException(
        'bulk_creation_failed',
        technicalMessage: 'Error creando estudiantes masivamente: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene todos los tutores del sistema.
  ///
  /// Retorna:
  /// - Lista de [User] con rol 'tutor' ordenados por fecha de creación
  ///
  /// Lanza:
  /// - [DatabaseException] si falla la consulta
  Future<List<User>> getTutors() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('role', 'tutor')
          .order('created_at', ascending: false);

      return response.map<User>(User.fromJson).toList();
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in UserManagementService: $e',
        originalError: e,
      );
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
  /// - [DatabaseException] si falla la consulta
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in UserManagementService: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene todos los estudiantes del sistema.
  ///
  /// Retorna:
  /// - Lista de [User] con rol 'student' ordenados por fecha de creación
  ///
  /// Lanza:
  /// - [DatabaseException] si falla la consulta
  Future<List<User>> getAllStudents() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('role', 'student')
          .order('created_at', ascending: false);

      return response.map<User>(User.fromJson).toList();
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in UserManagementService: $e',
        originalError: e,
      );
    }
  }

  /// Crea un nuevo alumno mediante Edge Function para invitar usuario con contraseña temporal.
  /// El alumno recibirá un email de Supabase Auth con la contraseña y toda su información.
  /// Requiere rol admin o tutor.
  Future<User> createStudent({
    required String email,
    required String password,
    required String fullName,
    String? academicYear,
    int? tutorId,
    String? phone,
    String? nre,
    String? specialty,
    String? biography,
  }) async {
    try {
      // Obtener información del tutor si está asignado (antes de crear el usuario)
      String? tutorName;
      String? tutorEmail;
      String? tutorPhone;
      if (tutorId != null) {
        try {
          final tutorResponse = await _supabase
              .from('users')
              .select('full_name, email, phone')
              .eq('id', tutorId)
              .single();
          tutorName = tutorResponse['full_name'] as String?;
          tutorEmail = tutorResponse['email'] as String?;
          tutorPhone = tutorResponse['phone'] as String?;
        } catch (e) {
          debugPrint('⚠️ Error obteniendo información del tutor: $e');
          // Continuar sin información del tutor
        }
      }

      // Obtener información del usuario actual que creó el estudiante
      final currentUser = _supabase.auth.currentUser;
      String createdBy = 'administrador';
      String createdByName = 'Sistema';
      if (currentUser != null) {
        try {
          final creatorResponse = await _supabase
              .from('users')
              .select('full_name, role')
              .eq('email', currentUser.email!)
              .single();
          final creatorRole = creatorResponse['role'] as String?;
          createdByName = creatorResponse['full_name'] as String? ?? 'Sistema';
          createdBy = creatorRole == 'admin' ? 'administrador' : 'tutor';
        } catch (e) {
          debugPrint('⚠️ Error obteniendo información del creador: $e');
          // Usar valores por defecto
        }
      }

      // Invitar usuario usando Edge Function (envía email con contraseña temporal)
      debugPrint('📧 Invitando usuario con contraseña temporal: $email');

      final authResponse = await _supabase.functions
          .invoke(
            'super-action',
            body: {
              'action': 'invite_user',
              'user_data': {
                'email': email,
                'password': password,
                'full_name': fullName,
                'role': 'student',
                'tutor_name': tutorName,
                'tutor_email': tutorEmail,
                'tutor_phone': tutorPhone,
                'academic_year': academicYear,
                'student_phone': phone,
                'student_nre': nre,
                'student_specialty': specialty,
                'created_by': createdBy,
                'created_by_name': createdByName,
              },
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw DatabaseException(
                'edge_function_timeout',
                technicalMessage:
                    'La Edge Function tardó demasiado en responder. Por favor, verifica que la Edge Function "super-action" esté desplegada correctamente en Supabase.',
              );
            },
          );

      debugPrint(
        '✅ Respuesta de Edge Function recibida: status=${authResponse.status}',
      );
      debugPrint('✅ Datos de respuesta: ${authResponse.data}');

      // Verificar el estado de la respuesta
      if (authResponse.status != 200) {
        final errorMessage =
            authResponse.data?['error'] ??
            authResponse.data?['message'] ??
            'Error desconocido al crear usuario';

        // Detectar si el error es porque el email ya está registrado
        final errorCode = authResponse.data?['error_code'];
        final errorDetails = authResponse.data?['details'];
        final errorString = errorDetails?.toString() ?? errorMessage;
        
        if (errorCode == 'email_already_registered' ||
            errorMessage.contains('already been registered') ||
            errorMessage.contains('already registered') ||
            errorMessage.contains('email address has already') ||
            errorString.contains('already been registered') ||
            errorString.contains('email_already_registered')) {
          throw AuthenticationException(
            'email_already_registered',
            technicalMessage:
                'Este correo electrónico ya está registrado en el sistema. Si acabas de eliminar un usuario con este correo, por favor espera unos minutos antes de intentar crear otro usuario con el mismo email.',
          );
        }

        throw DatabaseException(
          'edge_function_error',
          technicalMessage:
              'Error en Edge Function: $errorMessage. El usuario NO se creó en Auth. Verifica que la Edge Function "super-action" esté desplegada correctamente.',
          originalError: authResponse.data,
        );
      }

      // Verificar que la respuesta indica éxito
      if (authResponse.data == null || authResponse.data['success'] != true) {
        final errorMessage =
            authResponse.data?['error'] ?? 'La Edge Function no retornó éxito';
        final errorCode = authResponse.data?['error_code'];
        final errorDetails = authResponse.data?['details'];
        final errorString = errorDetails?.toString() ?? errorMessage;

        // Detectar si el error es porque el email ya está registrado
        if (errorCode == 'email_already_registered' ||
            errorMessage.contains('already been registered') ||
            errorMessage.contains('already registered') ||
            errorMessage.contains('email address has already') ||
            errorString.contains('already been registered') ||
            errorString.contains('email_already_registered')) {
          throw AuthenticationException(
            'email_already_registered',
            technicalMessage:
                'Este correo electrónico ya está registrado en el sistema. Si acabas de eliminar un usuario con este correo, por favor espera unos minutos antes de intentar crear otro usuario con el mismo email.',
          );
        }

        throw DatabaseException(
          'edge_function_error',
          technicalMessage:
              'Error en Edge Function: $errorMessage. El usuario NO se creó en Auth. Verifica los logs de la Edge Function en Supabase Dashboard.',
          originalError: authResponse.data,
        );
      }

      debugPrint(
        '✅ Usuario invitado exitosamente. Recibirá email de Supabase Auth con contraseña temporal.',
      );

      // Insertar en la tabla users
      final insert = {
        'email': email,
        'full_name': fullName,
        'role': 'student',
        // password_hash ahora es nullable - las contraseñas se gestionan en Supabase Auth (auth.users)
        if (academicYear != null) 'academic_year': academicYear,
        if (tutorId != null) 'tutor_id': tutorId,
        if (phone != null) 'phone': phone,
        if (nre != null) 'nre': nre,
        if (specialty != null) 'specialty': specialty,
        if (biography != null) 'biography': biography,
        'status': 'active',
      };

      final response = await _supabase
          .from('users')
          .insert(insert)
          .select()
          .single();
      final createdStudent = User.fromJson(response);

      debugPrint(
        '✅ Estudiante creado en base de datos. Email de invitación enviado por Supabase Auth.',
      );

      return createdStudent;
    } catch (e) {
      // Nota: Si Supabase envía el email antes de detectar rate limiting,
      // el usuario puede quedar creado en auth.users pero no en la tabla users.
      // Esto requiere limpieza manual desde el dashboard de Supabase.
      // No podemos eliminar usuarios desde el cliente sin permisos admin.

      // Verificar si el error es de email ya registrado
      final errorString = e.toString();
      if (errorString.contains('already been registered') ||
          errorString.contains('email_already_registered') ||
          errorString.contains('email address has already') ||
          (e is AuthenticationException && e.code == 'email_already_registered')) {
        throw AuthenticationException(
          'email_already_registered',
          technicalMessage:
              'Este correo electrónico ya está registrado en el sistema. Si acabas de eliminar un usuario con este correo, por favor espera unos minutos antes de intentar crear otro usuario con el mismo email.',
          originalError: e,
        );
      }

      // Verificar si el error es de rate limiting y si vino del signUp
      if (errorString.contains('only request this after') ||
          errorString.contains('rate limit') ||
          errorString.contains('too many requests') ||
          (e is AuthenticationException && e.code == 'rate_limit_exceeded')) {
        // Si el usuario fue creado en Auth pero falló el insert en users,
        // el email ya fue enviado. No podemos revertirlo desde aquí.
        // El administrador debe limpiar manualmente desde Supabase Dashboard
        // si es necesario.
      }
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      // Si es una AppException, re-lanzarla
      if (e is AppException) {
        rethrow;
      }
      
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error creating student: $e',
        originalError: e,
      );
    }
  }

  /// Actualiza la contraseña de un estudiante.
  /// Solo puede ser usado por administradores o tutores del estudiante.
  ///
  /// Parámetros:
  /// - [studentEmail]: Email del estudiante cuya contraseña se va a actualizar
  /// - [newPassword]: Nueva contraseña para el estudiante
  ///
  /// Lanza:
  /// - [AuthenticationException] si falla la actualización de la contraseña
  /// - [DatabaseException] si falla la consulta
  Future<void> updateStudentPassword({
    required String studentEmail,
    required String newPassword,
  }) async {
    try {
      // Obtener información del estudiante
      final studentResponse = await _supabase
          .from('users')
          .select('id, full_name, email')
          .eq('email', studentEmail)
          .eq('role', 'student')
          .single();

      final studentId = studentResponse['id'] as int;

      // Obtener el usuario actual para verificar permisos
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'Usuario no autenticado',
        );
      }

      // Verificar que el usuario actual es admin o tutor del estudiante
      final currentUserResponse = await _supabase
          .from('users')
          .select('role, id')
          .eq('email', currentUser.email!)
          .single();

      final currentUserRole = currentUserResponse['role'] as String;
      final currentUserId = currentUserResponse['id'] as int;

      if (currentUserRole != 'admin') {
        // Si no es admin, verificar que es tutor del estudiante
        final studentData = await _supabase
            .from('users')
            .select('tutor_id')
            .eq('id', studentId)
            .single();

        final tutorId = studentData['tutor_id'] as int?;
        if (tutorId != currentUserId) {
          throw AuthenticationException(
            'permission_denied',
            technicalMessage:
                'No tienes permisos para actualizar la contraseña de este estudiante',
          );
        }
      }

      // Actualizar la contraseña usando Edge Function en Supabase
      debugPrint('🔐 Intentando actualizar contraseña para: $studentEmail');
      debugPrint('🔐 Llamando a Edge Function: super-action');

      // Añadir timeout de 30 segundos para evitar que se quede colgado
      final response = await _supabase.functions
          .invoke(
            'super-action',
            body: {
              'action': 'reset_password',
              'user_email': studentEmail,
              'new_password': newPassword,
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw DatabaseException(
                'edge_function_timeout',
                technicalMessage:
                    'La Edge Function tardó demasiado en responder. La contraseña NO se actualizó. Por favor, verifica que la Edge Function "super-action" esté desplegada correctamente en Supabase.',
              );
            },
          );

      debugPrint(
        '✅ Respuesta de Edge Function recibida: status=${response.status}',
      );
      debugPrint('✅ Datos de respuesta: ${response.data}');

      // Verificar el estado de la respuesta
      if (response.status != 200) {
        final errorMessage =
            response.data?['error'] ??
            response.data?['message'] ??
            'Error desconocido al actualizar contraseña';
        throw DatabaseException(
          'edge_function_error',
          technicalMessage:
              'Error en Edge Function: $errorMessage. La contraseña NO se actualizó. Verifica que la Edge Function "super-action" esté desplegada correctamente.',
          originalError: response.data,
        );
      }

      // Verificar que la respuesta indica éxito
      if (response.data == null || response.data['success'] != true) {
        final errorMessage =
            response.data?['error'] ?? 'La Edge Function no retornó éxito';
        throw DatabaseException(
          'edge_function_error',
          technicalMessage:
              'Error en Edge Function: $errorMessage. La contraseña NO se actualizó. Verifica los logs de la Edge Function en Supabase Dashboard.',
          originalError: response.data,
        );
      }

      debugPrint('✅ Contraseña actualizada exitosamente en Supabase Auth');
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      // Re-lanzar excepciones de tipo AppException
      if (e is AppException) {
        rethrow;
      }

      throw DatabaseException(
        'password_update_failed',
        technicalMessage: 'Error actualizando contraseña: $e',
        originalError: e,
      );
    }
  }

  /// Elimina un usuario de Supabase Auth.
  ///
  /// Parámetros:
  /// - [userEmail]: Email del usuario a eliminar de Auth
  ///
  /// Lanza:
  /// - [DatabaseException] si falla la eliminación
  Future<void> deleteUserFromAuth(String userEmail) async {
    try {
      debugPrint('🔐 Intentando eliminar usuario de Auth: $userEmail');
      debugPrint('🔐 Llamando a Edge Function: super-action');

      // Añadir timeout de 30 segundos para evitar que se quede colgado
      final response = await _supabase.functions
          .invoke(
            'super-action',
            body: {'action': 'delete_user', 'user_email': userEmail},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw DatabaseException(
                'edge_function_timeout',
                technicalMessage:
                    'La Edge Function tardó demasiado en responder. El usuario puede no haberse eliminado de Auth. Por favor, verifica que la Edge Function "super-action" esté desplegada correctamente en Supabase.',
              );
            },
          );

      debugPrint(
        '✅ Respuesta de Edge Function recibida: status=${response.status}',
      );
      debugPrint('✅ Datos de respuesta: ${response.data}');

      // Verificar el estado de la respuesta
      if (response.status != 200) {
        final errorMessage =
            response.data?['error'] ??
            response.data?['message'] ??
            'Error desconocido al eliminar usuario de Auth';
        throw DatabaseException(
          'edge_function_error',
          technicalMessage:
              'Error en Edge Function: $errorMessage. El usuario puede no haberse eliminado de Auth. Verifica que la Edge Function "super-action" esté desplegada correctamente.',
          originalError: response.data,
        );
      }

      // Verificar que la respuesta indica éxito
      if (response.data == null || response.data['success'] != true) {
        final errorMessage =
            response.data?['error'] ?? 'La Edge Function no retornó éxito';
        throw DatabaseException(
          'edge_function_error',
          technicalMessage:
              'Error en Edge Function: $errorMessage. El usuario puede no haberse eliminado de Auth. Verifica los logs de la Edge Function en Supabase Dashboard.',
          originalError: response.data,
        );
      }

      debugPrint('✅ Usuario eliminado exitosamente de Supabase Auth');
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      // Re-lanzar excepciones de tipo AppException
      if (e is AppException) {
        rethrow;
      }

      throw DatabaseException(
        'auth_deletion_failed',
        technicalMessage: 'Error eliminando usuario de Auth: $e',
        originalError: e,
      );
    }
  }

  /// Elimina un tutor por ID. Si tiene alumnos asignados, lanzar error salvo que se fuerce.
  Future<void> deleteTutor({required int tutorId, bool force = false}) async {
    try {
      // Verificar alumnos asignados
      final assigned = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'student')
          .eq('tutor_id', tutorId);

      if (!force && assigned.isNotEmpty) {
        throw DatabaseException(
          'tutor_has_students',
          technicalMessage:
              'Tutor has assigned students; reassign before delete',
        );
      }

      if (force && assigned.isNotEmpty) {
        // Desasignar alumnos
        await _supabase
            .from('users')
            .update({'tutor_id': null})
            .eq('role', 'student')
            .eq('tutor_id', tutorId);
      }

      await _supabase
          .from('users')
          .delete()
          .eq('id', tutorId)
          .eq('role', 'tutor');
    } catch (e) {
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error deleting tutor: $e',
        originalError: e,
      );
    }
  }

  /// Reasigna un alumno a un tutor distinto.
  Future<User> reassignStudent({
    required int studentId,
    required int newTutorId,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .update({'tutor_id': newTutorId})
          .eq('id', studentId)
          .eq('role', 'student')
          .select()
          .single();
      return User.fromJson(response);
    } catch (e) {
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error reassigning student: $e',
        originalError: e,
      );
    }
  }

  /// Lista usuarios con filtros opcionales por rol y año académico.
  Future<List<User>> getUsers({String? role, String? academicYear}) async {
    try {
      final base = _supabase.from('users').select('*');
      final withRole = role != null ? base.eq('role', role) : base;
      final withYear = academicYear != null
          ? withRole.eq('academic_year', academicYear)
          : withRole;
      final response = await withYear.order('created_at', ascending: false);
      return (response as List<dynamic>)
          .map<User>((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error listing users: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene la lista de años académicos disponibles (distinct).
  Future<List<String>> getAcademicYears() async {
    try {
      final response = await _supabase
          .from('users')
          .select('academic_year')
          .not('academic_year', 'is', null);
      final years = <String>{};
      for (final row in (response as List)) {
        final y = row['academic_year'] as String?;
        if (y != null && y.trim().isNotEmpty) years.add(y);
      }
      final list = years.toList()..sort();
      return list;
    } catch (e) {
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error listing academic years: $e',
        originalError: e,
      );
    }
  }

  /// Actualiza un usuario con los campos especificados.
  ///
  /// Parámetros:
  /// - [userId]: ID del usuario a actualizar
  /// - [updates]: Mapa con los campos a actualizar
  ///
  /// Retorna:
  /// - [User] actualizado
  ///
  /// Lanza:
  /// - [DatabaseException] si falla la actualización
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in UserManagementService: $e',
        originalError: e,
      );
    }
  }

  /// Desactiva un usuario cambiando su estado a 'inactive'.
  ///
  /// Parámetros:
  /// - [userId]: ID del usuario a desactivar
  ///
  /// Lanza:
  /// - [DatabaseException] si falla la actualización
  Future<void> deactivateUser(int userId) async {
    try {
      await _supabase
          .from('users')
          .update({'status': 'inactive'})
          .eq('id', userId);
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in UserManagementService: $e',
        originalError: e,
      );
    }
  }

  /// Activa un usuario cambiando su estado a 'active'.
  ///
  /// Parámetros:
  /// - [userId]: ID del usuario a activar
  ///
  /// Lanza:
  /// - [DatabaseException] si falla la actualización
  Future<void> activateUser(int userId) async {
    try {
      await _supabase
          .from('users')
          .update({'status': 'active'})
          .eq('id', userId);
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in UserManagementService: $e',
        originalError: e,
      );
    }
  }

  /// Resetea la contraseña de un estudiante.
  /// Solo puede ser usado por administradores o tutores del estudiante.
  ///
  /// Parámetros:
  /// - [studentEmail]: Email del estudiante cuya contraseña se va a resetear
  /// - [newPassword]: Nueva contraseña para el estudiante
  /// - [sendNotification]: Si es true, envía una notificación al estudiante (default: true)
  ///
  /// Lanza:
  /// - [AuthenticationException] si falla la actualización de la contraseña
  /// - [DatabaseException] si falla la consulta
  Future<void> resetStudentPassword({
    required String studentEmail,
    required String newPassword,
    bool sendNotification = true,
  }) async {
    try {
      // Obtener información del estudiante
      final studentResponse = await _supabase
          .from('users')
          .select('id, full_name, email')
          .eq('email', studentEmail)
          .eq('role', 'student')
          .single();

      final studentId = studentResponse['id'] as int;

      // Obtener el usuario actual para verificar permisos
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'Usuario no autenticado',
        );
      }

      // Verificar que el usuario actual es admin o tutor del estudiante
      final currentUserResponse = await _supabase
          .from('users')
          .select('role, id')
          .eq('email', currentUser.email!)
          .single();

      final currentUserRole = currentUserResponse['role'] as String;
      final currentUserId = currentUserResponse['id'] as int;

      if (currentUserRole != 'admin') {
        // Si no es admin, verificar que es tutor del estudiante
        final studentData = await _supabase
            .from('users')
            .select('tutor_id')
            .eq('id', studentId)
            .single();

        final tutorId = studentData['tutor_id'] as int?;
        if (tutorId != currentUserId) {
          throw AuthenticationException(
            'permission_denied',
            technicalMessage:
                'No tienes permisos para resetear la contraseña de este estudiante',
          );
        }
      }

      // Obtener información del estudiante y del usuario actual para las notificaciones
      final studentName = studentResponse['full_name'] as String;
      final currentUserNameResponse = await _supabase
          .from('users')
          .select('full_name')
          .eq('id', currentUserId)
          .single();
      final currentUserName = currentUserNameResponse['full_name'] as String;

      // Actualizar la contraseña usando Edge Function en Supabase
      // La Edge Function debe tener permisos de service_role para actualizar auth.users
      // Ver: docs/desarrollo/solucion_simple_reset_password.md
      debugPrint('🔐 Intentando resetear contraseña para: $studentEmail');
      debugPrint('🔐 Llamando a Edge Function: super-action');

      // Añadir timeout de 30 segundos para evitar que se quede colgado
      final response = await _supabase.functions
          .invoke(
            'super-action',
            body: {
              'action': 'reset_password',
              'user_email': studentEmail,
              'new_password': newPassword,
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw DatabaseException(
                'edge_function_timeout',
                technicalMessage:
                    'La Edge Function tardó demasiado en responder. La contraseña NO se actualizó. Por favor, verifica que la Edge Function "super-action" esté desplegada correctamente en Supabase.',
              );
            },
          );

      debugPrint(
        '✅ Respuesta de Edge Function recibida: status=${response.status}',
      );
      debugPrint('✅ Datos de respuesta: ${response.data}');

      // Verificar el estado de la respuesta
      if (response.status != 200) {
        final errorMessage =
            response.data?['error'] ??
            response.data?['message'] ??
            'Error desconocido al resetear contraseña';
        throw DatabaseException(
          'edge_function_error',
          technicalMessage:
              'Error en Edge Function: $errorMessage. La contraseña NO se actualizó. Verifica que la Edge Function "super-action" esté desplegada correctamente.',
          originalError: response.data,
        );
      }

      // Verificar que la respuesta indica éxito
      if (response.data == null || response.data['success'] != true) {
        final errorMessage =
            response.data?['error'] ?? 'La Edge Function no retornó éxito';
        throw DatabaseException(
          'edge_function_error',
          technicalMessage:
              'Error en Edge Function: $errorMessage. La contraseña NO se actualizó. Verifica los logs de la Edge Function en Supabase Dashboard.',
          originalError: response.data,
        );
      }

      debugPrint('✅ Contraseña actualizada exitosamente en Supabase Auth');

      // SOLO enviar notificación si la contraseña se actualizó correctamente
      if (sendNotification) {
        try {
          // Insertar notificación directamente en la tabla (funciona para admin y tutor)
          await _supabase.from('notifications').insert({
            'user_id': studentId,
            'type': 'system_notification',
            'title': 'Contraseña restablecida',
            'message':
                'Tu contraseña ha sido restablecida por $currentUserName (${currentUserRole == 'admin' ? 'Administrador' : 'Tutor'}). Tu nueva contraseña es: **$newPassword**\n\nPor favor, inicia sesión con esta contraseña. Si tienes problemas, contacta a tu tutor o administrador.',
            'action_url': '/login',
            'metadata': {
              'password_reset': true,
              'reset_by': currentUserRole,
              'reset_by_name': currentUserName,
              'password_updated': true,
            },
          });
          debugPrint('✅ Notificación interna enviada al estudiante');

          // Intentar enviar email al estudiante usando Supabase Auth (no crítico)
          try {
            debugPrint('📧 Enviando email de reset usando Supabase Auth...');

            final emailResponse = await _supabase.functions
                .invoke(
                  'super-action',
                  body: {
                    'action': 'send_password_reset_email',
                    'user_email': studentEmail,
                    'new_password': newPassword,
                    'user_data': {
                      'student_name': studentName,
                      'student_email': studentEmail,
                      'reset_by': currentUserRole == 'admin'
                          ? 'Administrador'
                          : 'Tutor',
                      'reset_by_name': currentUserName,
                    },
                  },
                )
                .timeout(
                  const Duration(seconds: 15),
                  onTimeout: () {
                    debugPrint('⚠️ Timeout enviando email de reset (ignorado)');
                    throw TimeoutException(
                      'Timeout enviando email',
                      const Duration(seconds: 15),
                    );
                  },
                );

            if (emailResponse.status == 200 &&
                emailResponse.data?['success'] == true) {
              debugPrint(
                '✅ Email de reset de contraseña enviado vía Supabase Auth',
              );
            } else {
              debugPrint(
                '⚠️ Error en respuesta de email: ${emailResponse.data}',
              );
            }
          } on TimeoutException {
            debugPrint('⚠️ Timeout enviando email (ignorado)');
          } catch (e) {
            // No fallar si el email no se puede enviar
            debugPrint('⚠️ Error enviando email de reset de contraseña: $e');
          }
        } catch (e) {
          // Si falla la notificación, lanzar error porque es crítico
          debugPrint(
            '❌ Error crítico enviando notificación de reset de contraseña: $e',
          );
          throw DatabaseException(
            'notification_failed',
            technicalMessage:
                'Error enviando notificación al estudiante: $e. La contraseña se actualizó correctamente, pero el estudiante no fue notificado.',
            originalError: e,
          );
        }
      }
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      // Re-lanzar excepciones de tipo AppException
      if (e is AppException) {
        rethrow;
      }

      throw DatabaseException(
        'password_reset_failed',
        technicalMessage: 'Error reseteando contraseña: $e',
        originalError: e,
      );
    }
  }
}

/// Excepción específica para errores en la gestión de usuarios.
class UserManagementException implements Exception {
  final String message;
  const UserManagementException(this.message);

  @override
  String toString() => 'UserManagementException: $message';
}
