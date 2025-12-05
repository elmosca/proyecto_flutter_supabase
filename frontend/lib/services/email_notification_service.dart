import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para envío de notificaciones por email mediante Edge Functions.
///
/// Proporciona métodos estáticos para enviar diferentes tipos de notificaciones:
/// - Notificaciones de comentarios nuevos
/// - Notificaciones de cambio de estado de anteproyectos
/// - Notificaciones de bienvenida para nuevos usuarios
/// - Notificaciones de tareas asignadas
/// - Notificaciones de recordatorios
///
/// ## Funcionalidades principales:
/// - Envío de emails mediante Edge Function 'send-email'
/// - Plantillas predefinidas para diferentes tipos de notificación
/// - Manejo de errores sin interrumpir el flujo principal
/// - Logging de resultados de envío
///
/// ## Seguridad:
/// - Requiere autenticación: Sí (implícita en Edge Function)
/// - Roles permitidos: Todos (con restricciones en Edge Function)
/// - Políticas RLS aplicadas: Validación en Edge Function
///
/// ## Ejemplo de uso:
/// ```dart
/// await EmailNotificationService.sendCommentNotification(
///   studentEmail: 'estudiante@example.com',
///   studentName: 'Juan Pérez',
///   tutorName: 'Dr. García',
///   anteprojectTitle: 'Mi TFG',
///   commentContent: 'Excelente trabajo',
///   section: 'Objetivos',
///   anteprojectUrl: 'https://app.example.com/anteproject/123'
/// );
/// ```
class EmailNotificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Envía notificación por email cuando se añade un comentario nuevo.
  ///
  /// Parámetros:
  /// - [studentEmail]: Email del estudiante que recibirá la notificación
  /// - [studentName]: Nombre del estudiante
  /// - [tutorName]: Nombre del tutor que comentó
  /// - [anteprojectTitle]: Título del anteproyecto
  /// - [commentContent]: Contenido del comentario
  /// - [section]: Sección del anteproyecto comentada
  /// - [anteprojectUrl]: URL del anteproyecto
  ///
  /// No lanza excepciones para no interrumpir el flujo principal.
  static Future<void> sendCommentNotification({
    required String studentEmail,
    required String studentName,
    required String tutorName,
    required String anteprojectTitle,
    required String commentContent,
    required String section,
    required String anteprojectUrl,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-email',
        body: {
          'type': 'comment_notification',
          'data': {
            'studentEmail': studentEmail,
            'studentName': studentName,
            'tutorName': tutorName,
            'anteprojectTitle': anteprojectTitle,
            'commentContent': commentContent,
            'section': section,
            'anteprojectUrl': anteprojectUrl,
          },
        },
      );

      if (response.status == 200) {
        debugPrint('✅ Email de comentario enviado exitosamente');
      } else {
        debugPrint('❌ Error enviando email de comentario: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ Error en sendCommentNotification: $e');
      // No lanzar excepción para no interrumpir el flujo principal
    }
  }

  /// Envía notificación por email cuando cambia el estado de un anteproyecto.
  ///
  /// Parámetros:
  /// - [studentEmail]: Email del estudiante que recibirá la notificación
  /// - [studentName]: Nombre del estudiante
  /// - [tutorName]: Nombre del tutor que cambió el estado
  /// - [anteprojectTitle]: Título del anteproyecto
  /// - [newStatus]: Nuevo estado del anteproyecto
  /// - [tutorComments]: Comentarios del tutor (opcional)
  /// - [anteprojectUrl]: URL del anteproyecto
  ///
  /// No lanza excepciones para no interrumpir el flujo principal.
  static Future<void> sendStatusChangeNotification({
    required String studentEmail,
    required String studentName,
    required String tutorName,
    required String anteprojectTitle,
    required String newStatus,
    String? tutorComments,
    required String anteprojectUrl,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-email',
        body: {
          'type': 'status_change',
          'data': {
            'studentEmail': studentEmail,
            'studentName': studentName,
            'tutorName': tutorName,
            'anteprojectTitle': anteprojectTitle,
            'newStatus': newStatus,
            'tutorComments': tutorComments,
            'anteprojectUrl': anteprojectUrl,
          },
        },
      );

      if (response.status == 200) {
        debugPrint('✅ Email de cambio de estado enviado exitosamente');
      } else {
        debugPrint(
          '❌ Error enviando email de cambio de estado: ${response.data}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error en sendStatusChangeNotification: $e');
      // No lanzar excepción para no interrumpir el flujo principal
    }
  }

  /// Envía notificación de bienvenida a un nuevo usuario.
  ///
  /// Parámetros:
  /// - [userEmail]: Email del usuario
  /// - [userName]: Nombre del usuario
  /// - [userRole]: Rol del usuario (admin, tutor, student)
  ///
  /// No lanza excepciones para no interrumpir el flujo principal.
  static Future<void> sendWelcomeNotification({
    required String userEmail,
    required String userName,
    required String userRole,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-email',
        body: {
          'type': 'welcome',
          'data': {
            'userEmail': userEmail,
            'userName': userName,
            'userRole': userRole,
          },
        },
      );

      if (response.status == 200) {
        debugPrint('✅ Email de bienvenida enviado exitosamente');
      } else {
        debugPrint('❌ Error enviando email de bienvenida: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ Error en sendWelcomeNotification: $e');
    }
  }

  /// Enviar notificación de recordatorio
  static Future<void> sendReminderNotification({
    required String userEmail,
    required String userName,
    required String anteprojectTitle,
    required String reminderType,
    required String message,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-email',
        body: {
          'type': 'reminder',
          'data': {
            'userEmail': userEmail,
            'userName': userName,
            'anteprojectTitle': anteprojectTitle,
            'reminderType': reminderType,
            'message': message,
          },
        },
      );

      if (response.status == 200) {
        debugPrint('✅ Email de recordatorio enviado exitosamente');
      } else {
        debugPrint('❌ Error enviando email de recordatorio: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ Error en sendReminderNotification: $e');
    }
  }

  /// El envío de email de password reset se hace ahora directamente
  /// desde la Edge Function 'super-action' usando Resend API.
  ///
  /// Ver: docs/desarrollo/super-action_edge_function_completo.ts
  ///
  /// Envía email de notificación cuando se resetea una contraseña de estudiante.
  ///
  /// Parámetros:
  /// - [studentEmail]: Email del estudiante
  /// - [studentName]: Nombre del estudiante
  /// - [newPassword]: Nueva contraseña establecida
  /// - [resetBy]: Quién reseteó la contraseña ('administrador' o 'tutor')
  /// - [resetByName]: Nombre de quien reseteó la contraseña
  ///
  /// No lanza excepciones para no interrumpir el flujo principal.
  @Deprecated(
    'Use Edge Function super-action con action: send_password_reset_email',
  )
  static Future<void> sendPasswordResetNotification({
    required String studentEmail,
    required String studentName,
    required String newPassword,
    required String resetBy, // 'administrador' o 'tutor'
    required String resetByName,
  }) async {
    try {
      // Añadir timeout de 20 segundos para evitar que se quede colgado
      try {
        final response = await _supabase.functions
            .invoke(
              'send-email',
              body: {
                'type': 'password_reset',
                'data': {
                  'studentEmail': studentEmail,
                  'studentName': studentName,
                  'newPassword': newPassword,
                  'resetBy': resetBy,
                  'resetByName': resetByName,
                },
              },
            )
            .timeout(
              const Duration(seconds: 20),
              onTimeout: () {
                debugPrint('⚠️ Timeout enviando email de reset de contraseña');
                // Lanzar TimeoutException para que se capture en el catch externo
                throw TimeoutException(
                  'Timeout enviando email de reset de contraseña',
                  const Duration(seconds: 20),
                );
              },
            );

        if (response.status == 200) {
          debugPrint('✅ Email de reset de contraseña enviado exitosamente');
        } else {
          debugPrint('❌ Error enviando email de reset: ${response.data}');
        }
      } on TimeoutException {
        debugPrint(
          '⚠️ Timeout enviando email de reset de contraseña (ignorado)',
        );
        // No lanzar excepción para no interrumpir el flujo principal
      }
    } catch (e) {
      debugPrint('❌ Error en sendPasswordResetNotification: $e');
      // No lanzar excepción para no interrumpir el flujo principal
    }
  }

  /// Enviar notificación al tutor
  static Future<void> sendTutorNotification({
    required String tutorEmail,
    required String tutorName,
    required String studentName,
    required String anteprojectTitle,
    required String notificationType,
    required String message,
    required String anteprojectUrl,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-email',
        body: {
          'type': 'tutor_notification',
          'data': {
            'tutorEmail': tutorEmail,
            'tutorName': tutorName,
            'studentName': studentName,
            'anteprojectTitle': anteprojectTitle,
            'notificationType': notificationType,
            'message': message,
            'anteprojectUrl': anteprojectUrl,
          },
        },
      );

      if (response.status == 200) {
        debugPrint('✅ Email de notificación al tutor enviado exitosamente');
      } else {
        debugPrint('❌ Error enviando email al tutor: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ Error en sendTutorNotification: $e');
    }
  }

  /// Envía email al tutor notificando solicitud de reset de contraseña de estudiante
  ///
  /// Parámetros:
  /// - [tutorEmail]: Email del tutor
  /// - [tutorName]: Nombre del tutor
  /// - [studentEmail]: Email del estudiante
  /// - [studentName]: Nombre del estudiante
  ///
  /// No lanza excepciones para no interrumpir el flujo principal.
  static Future<void> sendPasswordResetRequestToTutor({
    required String tutorEmail,
    required String tutorName,
    required String studentEmail,
    required String studentName,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-email',
        body: {
          'type': 'password_reset_request_to_tutor',
          'data': {
            'tutorEmail': tutorEmail,
            'tutorName': tutorName,
            'studentEmail': studentEmail,
            'studentName': studentName,
          },
        },
      );

      if (response.status == 200) {
        debugPrint(
          '✅ Email de solicitud de reset de contraseña enviado al tutor',
        );
      } else {
        debugPrint(
          '❌ Error enviando email de solicitud al tutor: ${response.data}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error en sendPasswordResetRequestToTutor: $e');
    }
  }

  /// Envía email de bienvenida cuando se crea un nuevo estudiante.
  ///
  /// Parámetros:
  /// - [studentEmail]: Email del estudiante
  /// - [studentName]: Nombre del estudiante
  /// - [password]: Contraseña del estudiante
  /// - [academicYear]: Año académico del estudiante
  /// - [studentPhone]: Teléfono del estudiante (opcional)
  /// - [studentNre]: NRE del estudiante (opcional)
  /// - [studentSpecialty]: Especialidad del estudiante (opcional)
  /// - [tutorName]: Nombre del tutor asignado (opcional)
  /// - [tutorEmail]: Email del tutor asignado (opcional)
  /// - [tutorPhone]: Teléfono del tutor (opcional)
  /// - [createdBy]: Quién creó el estudiante ('administrador' o 'tutor')
  /// - [createdByName]: Nombre de quien creó el estudiante
  ///
  /// No lanza excepciones para no interrumpir el flujo principal.
  static Future<void> sendStudentWelcomeEmail({
    required String studentEmail,
    required String studentName,
    required String password,
    String? academicYear,
    String? studentPhone,
    String? studentNre,
    String? studentSpecialty,
    String? tutorName,
    String? tutorEmail,
    String? tutorPhone,
    required String createdBy, // 'administrador' o 'tutor'
    required String createdByName,
    bool failSilently = true,
  }) async {
    Future<void> _maybeRethrow(Object error, StackTrace stackTrace) async {
      if (!failSilently) {
        Error.throwWithStackTrace(error, stackTrace);
      }
    }

    try {
      final response = await _supabase.functions
          .invoke(
            'send-email',
            body: {
              'type': 'student_welcome',
              'data': {
                'studentEmail': studentEmail,
                'studentName': studentName,
                'password': password,
                'academicYear': academicYear,
                'studentPhone': studentPhone,
                'studentNre': studentNre,
                'studentSpecialty': studentSpecialty,
                'tutorName': tutorName,
                'tutorEmail': tutorEmail,
                'tutorPhone': tutorPhone,
                'createdBy': createdBy,
                'createdByName': createdByName,
              },
            },
          )
          .timeout(const Duration(seconds: 20));

      debugPrint(
        '📧 Respuesta de Edge Function send-email: status=${response.status}',
      );
      debugPrint('📧 Datos de respuesta: ${response.data}');

      if (response.status == 200) {
        final success = response.data?['success'] ?? false;
        if (success) {
          debugPrint(
            '✅ Email de bienvenida al estudiante enviado exitosamente',
          );
          return;
        }

        final error = response.data?['error'] ?? 'Error desconocido';
        debugPrint('❌ Error enviando email de bienvenida: $error');
        debugPrint('❌ Respuesta completa: ${response.data}');
        await _maybeRethrow(
          StateError('Edge Function no retornó éxito: $error'),
          StackTrace.current,
        );
      } else {
        final error =
            response.data?['error'] ??
            response.data?.toString() ??
            'Error desconocido';
        debugPrint(
          '❌ Error enviando email de bienvenida (status ${response.status}): $error',
        );
        debugPrint('❌ Respuesta completa: ${response.data}');
        await _maybeRethrow(
          StateError(
            'Edge Function respondió con estado ${response.status}: $error',
          ),
          StackTrace.current,
        );
      }
    } on TimeoutException catch (e, stackTrace) {
      debugPrint(
        '⚠️ Timeout enviando email de bienvenida al estudiante (ignorado)',
      );
      await _maybeRethrow(e, stackTrace);
    } catch (e, stackTrace) {
      debugPrint('❌ Error en sendStudentWelcomeEmail: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      // Si el error es "Body already consumed" pero el email podría haberse enviado,
      // verificar si hay alguna indicación de éxito en el error
      final errorString = e.toString();
      if (errorString.contains('Body already consumed')) {
        debugPrint(
          '⚠️ Error "Body already consumed" detectado. '
          'Esto puede ocurrir si el email se envió correctamente pero hubo un problema '
          'al procesar la respuesta. Verifica manualmente si el email llegó.',
        );
        // Si failSilently es false, aún lanzamos el error para que el test pueda verificar
        // pero con un mensaje más descriptivo
        if (!failSilently) {
          await _maybeRethrow(
            StateError(
              'Error procesando respuesta de Edge Function (Body already consumed). '
              'El email puede haberse enviado correctamente. Verifica manualmente.',
            ),
            stackTrace,
          );
        }
        return;
      }
      
      await _maybeRethrow(e, stackTrace);
    }
  }

  /// Envía notificación por email al tutor cuando un estudiante envía un mensaje.
  ///
  /// Parámetros:
  /// - [tutorEmail]: Email del tutor
  /// - [tutorName]: Nombre del tutor
  /// - [studentName]: Nombre del estudiante que envió el mensaje
  /// - [studentEmail]: Email del estudiante
  /// - [anteprojectTitle]: Título del anteproyecto
  /// - [messageContent]: Contenido del mensaje
  ///
  /// No lanza excepciones para no interrumpir el flujo principal.
  static Future<void> sendMessageToTutor({
    required String tutorEmail,
    required String tutorName,
    required String studentName,
    required String studentEmail,
    required String anteprojectTitle,
    required String messageContent,
  }) async {
    try {
      final response = await _supabase.functions
          .invoke(
            'send-email',
            body: {
              'type': 'message_to_tutor',
              'data': {
                'tutorEmail': tutorEmail,
                'tutorName': tutorName,
                'studentName': studentName,
                'studentEmail': studentEmail,
                'anteprojectTitle': anteprojectTitle,
                'messageContent': messageContent,
              },
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Timeout enviando email', const Duration(seconds: 10));
            },
          );

      if (response.status == 200) {
        debugPrint('✅ Email de mensaje enviado al tutor');
      } else {
        debugPrint('⚠️ Error enviando email al tutor (status ${response.status})');
      }
    } on TimeoutException {
      debugPrint('⚠️ Timeout enviando email al tutor (ignorado)');
    } catch (e) {
      // Silenciar errores de CORS/red para no molestar al usuario
      // El mensaje ya se creó correctamente
      if (e.toString().contains('CORS') || 
          e.toString().contains('Failed to fetch') ||
          e.toString().contains('NetworkError')) {
        debugPrint('⚠️ Error de red/CORS enviando email (ignorado)');
      } else {
        debugPrint('⚠️ Error enviando email al tutor: $e');
      }
    }
  }

  /// Envía notificación por email al estudiante cuando el tutor envía un mensaje.
  ///
  /// Parámetros:
  /// - [studentEmail]: Email del estudiante
  /// - [studentName]: Nombre del estudiante
  /// - [tutorName]: Nombre del tutor que envió el mensaje
  /// - [anteprojectTitle]: Título del anteproyecto
  /// - [messageContent]: Contenido del mensaje
  ///
  /// No lanza excepciones para no interrumpir el flujo principal.
  static Future<void> sendMessageToStudent({
    required String studentEmail,
    required String studentName,
    required String tutorName,
    required String anteprojectTitle,
    required String messageContent,
  }) async {
    try {
      final response = await _supabase.functions
          .invoke(
            'send-email',
            body: {
              'type': 'message_to_student',
              'data': {
                'studentEmail': studentEmail,
                'studentName': studentName,
                'tutorName': tutorName,
                'anteprojectTitle': anteprojectTitle,
                'messageContent': messageContent,
              },
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Timeout enviando email', const Duration(seconds: 10));
            },
          );

      if (response.status == 200) {
        debugPrint('✅ Email de mensaje enviado al estudiante');
      } else {
        debugPrint('⚠️ Error enviando email al estudiante (status ${response.status})');
      }
    } on TimeoutException {
      debugPrint('⚠️ Timeout enviando email al estudiante (ignorado)');
    } catch (e) {
      // Silenciar errores de CORS/red para no molestar al usuario
      // El mensaje ya se creó correctamente
      if (e.toString().contains('CORS') || 
          e.toString().contains('Failed to fetch') ||
          e.toString().contains('NetworkError')) {
        debugPrint('⚠️ Error de red/CORS enviando email (ignorado)');
      } else {
        debugPrint('⚠️ Error enviando email al estudiante: $e');
      }
    }
  }
}
