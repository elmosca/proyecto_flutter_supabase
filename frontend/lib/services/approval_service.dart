import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../utils/app_exception.dart';
import '../utils/network_error_detector.dart';
import 'supabase_interceptor.dart';
import 'email_notification_service.dart';
import 'anteprojects_service.dart';

/// Servicio para gestión del flujo de aprobación de anteproyectos.
///
/// Proporciona operaciones para aprobar, rechazar y solicitar cambios en anteproyectos:
/// - Aprobación de anteproyectos con comentarios opcionales
/// - Rechazo con comentarios obligatorios
/// - Solicitud de cambios con feedback detallado
/// - Notificaciones automáticas por email
/// - Consulta de anteproyectos pendientes de revisión
///
/// ## Funcionalidades principales:
/// - Aprobar anteproyectos (cambia estado a 'approved')
/// - Rechazar anteproyectos (cambia estado a 'rejected')
/// - Solicitar cambios (cambia estado a 'changes_requested')
/// - Obtener anteproyectos pendientes de revisión
/// - Envío automático de notificaciones por email
///
/// ## Seguridad:
/// - Requiere autenticación: Sí
/// - Roles permitidos: tutor, admin
/// - Políticas RLS aplicadas: Solo tutores pueden aprobar anteproyectos de sus estudiantes
///
/// ## Ejemplo de uso:
/// ```dart
/// final service = ApprovalService();
/// final result = await service.approveAnteproject(123, comments: 'Excelente trabajo');
/// ```
///
/// Ver también: [AnteprojectsService], [ApprovalResult]
class ApprovalService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AnteprojectsService _anteprojectsService = AnteprojectsService();

  /// Aprueba un anteproyecto mediante Edge Function de Supabase.
  ///
  /// Parámetros:
  /// - [anteprojectId]: ID del anteproyecto a aprobar
  /// - [comments]: Comentarios opcionales del tutor
  ///
  /// Retorna:
  /// - [ApprovalResult] con el resultado de la operación
  ///
  /// Lanza:
  /// - [AuthenticationException] si no hay usuario autenticado
  /// - [ApprovalException] si falla la aprobación
  /// - [DatabaseException] si hay error en la base de datos
  Future<ApprovalResult> approveAnteproject(
    int anteprojectId, {
    String? comments,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Usar AnteprojectsService directamente en lugar de Edge Function
      await _anteprojectsService.approveAnteproject(
        anteprojectId,
        comments ?? '',
      );

      // Crear resultado de aprobación
      final result = ApprovalResult(
        success: true,
        message: 'Anteproyecto aprobado exitosamente',
        anteprojectId: anteprojectId,
      );

      // Enviar email de notificación al estudiante
      await _sendStatusChangeEmail(anteprojectId, 'approved', comments);

      return result;
    } catch (e) {
      if (e is ApprovalException) rethrow;
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
        technicalMessage: 'Error in ApprovalService: $e',
        originalError: e,
      );
    }
  }

  /// Rechaza un anteproyecto mediante Edge Function de Supabase.
  ///
  /// Parámetros:
  /// - [anteprojectId]: ID del anteproyecto a rechazar
  /// - [comments]: Comentarios obligatorios explicando el rechazo
  ///
  /// Retorna:
  /// - [ApprovalResult] con el resultado de la operación
  ///
  /// Lanza:
  /// - [AuthenticationException] si no hay usuario autenticado
  /// - [ApprovalException] si los comentarios están vacíos o falla el rechazo
  /// - [DatabaseException] si hay error en la base de datos
  Future<ApprovalResult> rejectAnteproject(
    int anteprojectId,
    String comments,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      if (comments.trim().isEmpty) {
        throw const ApprovalException(
          'Los comentarios son obligatorios para rechazar un anteproyecto',
        );
      }

      // Usar AnteprojectsService directamente en lugar de Edge Function
      await _anteprojectsService.rejectAnteproject(
        anteprojectId,
        comments,
      );

      // Crear resultado de rechazo
      final result = ApprovalResult(
        success: true,
        message: 'Anteproyecto rechazado',
        anteprojectId: anteprojectId,
      );

      // Enviar email de notificación al estudiante
      await _sendStatusChangeEmail(anteprojectId, 'rejected', comments);

      return result;
    } catch (e) {
      if (e is ApprovalException) rethrow;
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
        technicalMessage: 'Error in ApprovalService: $e',
        originalError: e,
      );
    }
  }

  /// Solicita cambios en un anteproyecto
  /// Cambia el estado del anteproyecto a 'under_review' con comentarios del tutor
  Future<ApprovalResult> requestChanges(
    int anteprojectId,
    String comments,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      if (comments.trim().isEmpty) {
        throw const ApprovalException(
          'Los comentarios son obligatorios para solicitar cambios',
        );
      }

      // Actualizar el anteproyecto directamente en la base de datos
      await _supabase
          .from('anteprojects')
          .update({
            'status': 'under_review',
            'tutor_comments': comments,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', anteprojectId);

      // Crear resultado de solicitud de cambios
      final result = ApprovalResult(
        success: true,
        message: 'Cambios solicitados al estudiante',
        anteprojectId: anteprojectId,
      );

      // Enviar email de notificación al estudiante
      await _sendStatusChangeEmail(anteprojectId, 'changes_requested', comments);

      return result;
    } catch (e) {
      if (e is ApprovalException) rethrow;
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
        technicalMessage: 'Error in ApprovalService: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene anteproyectos pendientes de aprobación para el tutor actual con información de estudiantes
  /// Retorna una lista de mapas que incluyen el anteproyecto y la información del estudiante
  Future<List<Map<String, dynamic>>> getPendingApprovals({int? tutorId}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Si se proporciona un tutorId (para admin), usarlo; si no, usar el ID del usuario actual
      int userIdToFilter;
      if (tutorId != null) {
        userIdToFilter = tutorId;
      } else {
        // Primero obtener el ID del usuario desde la tabla users
        final userResponse = await _supabase
            .from('users')
            .select('id')
            .eq('email', user.email!)
            .single();

        userIdToFilter = userResponse['id'] as int;
      }

      debugPrint('🔍 ApprovalService: Obteniendo anteproyectos pendientes para tutor ID: $userIdToFilter');
      debugPrint('🔍 ApprovalService: Buscando estados: submitted, under_review');
      
      // Obtener anteproyectos con información de estudiantes
      // Usamos relaciones opcionales para no excluir anteproyectos sin estudiantes
      final response = await _supabase
          .from('anteprojects')
          .select('''
            *,
            anteproject_students(
              student_id,
              is_lead_author,
              users(
                id,
                full_name,
                email,
                nre,
                tutor_id
              )
            )
          ''')
          .inFilter('status', ['submitted', 'under_review'])
          .eq('tutor_id', userIdToFilter)
          .order('submitted_at', ascending: true);
      
      debugPrint('🔍 ApprovalService: Respuesta recibida - ${response.length} anteproyectos encontrados');

      // Función auxiliar para convertir objetos minificados de Supabase
      Map<String, dynamic> safeConvertMap(dynamic data) {
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map) {
          // Iterar sobre las claves manualmente para evitar problemas con objetos minificados
          final result = <String, dynamic>{};
          for (final key in data.keys) {
            final value = data[key];
            result[key.toString()] = value;
          }
          return result;
        } else {
          // Último recurso: intentar casting
          try {
            final map = data as Map;
            final result = <String, dynamic>{};
            for (final key in map.keys) {
              result[key.toString()] = map[key];
            }
            return result;
          } catch (e) {
            debugPrint('⚠️ No se pudo convertir objeto: ${data.runtimeType}');
            return <String, dynamic>{};
          }
        }
      }
      
      // Convertir cada item a Map<String, dynamic> para evitar problemas de tipos
      final result = <Map<String, dynamic>>[];
      for (final item in response) {
        try {
          // Convertir el item principal usando la función segura
          final itemMap = safeConvertMap(item);
          
          // Si el mapa está vacío, saltar este item
          if (itemMap.isEmpty) {
            debugPrint('⚠️ Item vacío después de conversión, saltando...');
            continue;
          }
          
          // Verificar que los datos anidados también sean Maps válidos
          if (itemMap.containsKey('anteproject_students')) {
            final students = itemMap['anteproject_students'];
            if (students != null && students is List) {
              // Convertir cada estudiante a Map si es necesario
              final studentsList = students.map((s) {
                try {
                  final studentMap = safeConvertMap(s);
                  
                  // Convertir el campo 'users' si existe
                  if (studentMap.containsKey('users') && studentMap['users'] != null) {
                    final usersData = studentMap['users'];
                    studentMap['users'] = safeConvertMap(usersData);
                  }
                  
                  return studentMap;
                } catch (e) {
                  debugPrint('⚠️ Error convirtiendo estudiante en getPendingApprovals: $e');
                  return <String, dynamic>{};
                }
              }).where((s) => s.isNotEmpty).toList();
              itemMap['anteproject_students'] = studentsList;
            }
          }
          
          result.add(itemMap);
        } catch (e) {
          debugPrint('❌ Error procesando anteproyecto pendiente: $e');
          debugPrint('   Tipo del item: ${item.runtimeType}');
          // Continuar con el siguiente item en lugar de fallar completamente
        }
      }

      debugPrint('✅ ${result.length} anteproyectos pendientes procesados correctamente');
      return result;
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
        technicalMessage: 'Error in ApprovalService: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene anteproyectos ya revisados por el tutor actual con información de estudiantes
  /// Retorna una lista de mapas que incluyen el anteproyecto y la información del estudiante
  Future<List<Map<String, dynamic>>> getReviewedAnteprojects({int? tutorId}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Si se proporciona un tutorId (para admin), usarlo; si no, usar el ID del usuario actual
      int userIdToFilter;
      if (tutorId != null) {
        userIdToFilter = tutorId;
      } else {
        // Primero obtener el ID del usuario desde la tabla users
        final userResponse = await _supabase
            .from('users')
            .select('id')
            .eq('email', user.email!)
            .single();

        userIdToFilter = userResponse['id'] as int;
      }

      // Obtener anteproyectos con información de estudiantes
      // Usamos relaciones opcionales para no excluir anteproyectos sin estudiantes
      final response = await _supabase
          .from('anteprojects')
          .select('''
            *,
            anteproject_students(
              student_id,
              is_lead_author,
              users(
                id,
                full_name,
                email,
                nre,
                tutor_id
              )
            )
          ''')
          .inFilter('status', ['approved', 'rejected'])
          .eq('tutor_id', userIdToFilter)
          .order('reviewed_at', ascending: false);

      // Función auxiliar para convertir objetos minificados de Supabase
      Map<String, dynamic> safeConvertMap(dynamic data) {
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map) {
          // Iterar sobre las claves manualmente para evitar problemas con objetos minificados
          final result = <String, dynamic>{};
          for (final key in data.keys) {
            final value = data[key];
            result[key.toString()] = value;
          }
          return result;
        } else {
          // Último recurso: intentar casting
          try {
            final map = data as Map;
            final result = <String, dynamic>{};
            for (final key in map.keys) {
              result[key.toString()] = map[key];
            }
            return result;
          } catch (e) {
            debugPrint('⚠️ No se pudo convertir objeto: ${data.runtimeType}');
            return <String, dynamic>{};
          }
        }
      }
      
      // Convertir cada item a Map<String, dynamic> para evitar problemas de tipos
      final result = <Map<String, dynamic>>[];
      for (final item in response) {
        try {
          // Convertir el item principal usando la función segura
          final itemMap = safeConvertMap(item);
          
          // Si el mapa está vacío, saltar este item
          if (itemMap.isEmpty) {
            debugPrint('⚠️ Item vacío después de conversión, saltando...');
            continue;
          }
          
          // Verificar que los datos anidados también sean Maps válidos
          if (itemMap.containsKey('anteproject_students')) {
            final students = itemMap['anteproject_students'];
            if (students != null && students is List) {
              // Convertir cada estudiante a Map si es necesario
              final studentsList = students.map((s) {
                try {
                  final studentMap = safeConvertMap(s);
                  
                  // Convertir el campo 'users' si existe
                  if (studentMap.containsKey('users') && studentMap['users'] != null) {
                    final usersData = studentMap['users'];
                    studentMap['users'] = safeConvertMap(usersData);
                  }
                  
                  return studentMap;
                } catch (e) {
                  debugPrint('⚠️ Error convirtiendo estudiante en getReviewedAnteprojects: $e');
                  return <String, dynamic>{};
                }
              }).where((s) => s.isNotEmpty).toList();
              itemMap['anteproject_students'] = studentsList;
            }
          }
          
          result.add(itemMap);
        } catch (e) {
          debugPrint('❌ Error procesando anteproyecto revisado: $e');
          debugPrint('   Tipo del item: ${item.runtimeType}');
          // Continuar con el siguiente item en lugar de fallar completamente
        }
      }

      debugPrint('✅ ${result.length} anteproyectos revisados procesados correctamente');
      return result;
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
        technicalMessage: 'Error in ApprovalService: $e',
        originalError: e,
      );
    }
  }

  /// Verifica si el usuario actual puede aprobar/rechazar anteproyectos
  Future<bool> canApproveAnteprojects() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Verificar el rol del usuario en la base de datos
      final response = await _supabase
          .from('users')
          .select('role')
          .eq('email', user.email!)
          .single();

      final role = response['role'] as String?;
      return role == 'tutor' || role == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// Envía email de notificación de cambio de estado
  Future<void> _sendStatusChangeEmail(
    int anteprojectId,
    String status,
    String? comments,
  ) async {
    try {
      // Obtener información del anteproyecto y estudiantes
      final anteprojectResponse = await _supabase
          .from('anteprojects')
          .select('title, tutor_id')
          .eq('id', anteprojectId)
          .single();

      final anteprojectTitle = anteprojectResponse['title'] as String;
      final tutorId = anteprojectResponse['tutor_id'] as int;

      // Obtener información del tutor
      final tutorResponse = await _supabase
          .from('users')
          .select('full_name')
          .eq('id', tutorId)
          .single();

      final tutorName = tutorResponse['full_name'] as String;

      // Obtener estudiantes del anteproyecto
      final studentsResponse = await _supabase
          .from('anteproject_students')
          .select('''
            student_id,
            students:users!anteproject_students_student_id_fkey (
              id, full_name, email
            )
          ''')
          .eq('anteproject_id', anteprojectId);

      // Enviar email a cada estudiante
      for (final student in studentsResponse) {
        final studentData = student['students'] as Map<String, dynamic>;
        final studentName = studentData['full_name'] as String;
        final studentEmail = studentData['email'] as String;

        await EmailNotificationService.sendStatusChangeNotification(
          studentEmail: studentEmail,
          studentName: studentName,
          tutorName: tutorName,
          anteprojectTitle: anteprojectTitle,
          newStatus: status,
          tutorComments: comments,
          anteprojectUrl:
              'https://app.cifpcarlos3.es/anteprojects/$anteprojectId',
        );
      }
    } catch (e) {
      // No fallar si no se puede enviar el email
      debugPrint('Error al enviar email de cambio de estado: $e');
    }
  }
}

/// Modelo para el resultado de una operación de aprobación
class ApprovalResult {
  final bool success;
  final int anteprojectId;
  final int? projectId;
  final String message;

  const ApprovalResult({
    required this.success,
    required this.anteprojectId,
    this.projectId,
    required this.message,
  });

  factory ApprovalResult.fromJson(Map<String, dynamic> json) {
    return ApprovalResult(
      success: json['success'] ?? false,
      anteprojectId: json['anteproject_id'] ?? 0,
      projectId: json['project_id'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'anteproject_id': anteprojectId,
      'project_id': projectId,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'ApprovalResult(success: $success, anteprojectId: $anteprojectId, projectId: $projectId, message: $message)';
  }
}

/// Excepción personalizada para errores de aprobación
class ApprovalException implements Exception {
  final String message;

  const ApprovalException(this.message);

  @override
  String toString() => 'ApprovalException: $message';
}
