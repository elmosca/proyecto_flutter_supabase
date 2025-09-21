import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailNotificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Enviar notificación de comentario nuevo
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

  /// Enviar notificación de cambio de estado
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
        debugPrint('❌ Error enviando email de cambio de estado: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ Error en sendStatusChangeNotification: $e');
      // No lanzar excepción para no interrumpir el flujo principal
    }
  }

  /// Enviar notificación de bienvenida
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
}
