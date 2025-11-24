import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/anteproject_message.dart';
import 'email_notification_service.dart';

class AnteprojectMessagesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Convierte objetos minificados de Supabase a Map<String, dynamic>
  Map<String, dynamic> _safeConvertMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      final result = <String, dynamic>{};
      for (final key in data.keys) {
        final value = data[key];
        result[key.toString()] = value;
      }
      return result;
    } else {
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

  /// Obtener todos los mensajes de un anteproyecto
  /// Si se proporciona threadId, solo devuelve mensajes de ese hilo
  Future<List<AnteprojectMessage>> getAnteprojectMessages(
    int anteprojectId, {
    int? threadId,
  }) async {
    try {
      // Usar una sola consulta con JOIN para evitar problemas de casting
      var query = _supabase
          .from('anteproject_messages')
          .select('''
            *,
            sender:users!anteproject_messages_sender_id_fkey (
              id,
              full_name,
              email,
              role,
              nre,
              phone,
              biography,
              status,
              specialty,
              tutor_id,
              academic_year,
              created_at,
              updated_at
            )
          ''')
          .eq('anteproject_id', anteprojectId);

      // Filtrar por hilo si se proporciona
      if (threadId != null) {
        query = query.eq('thread_id', threadId);
      }

      final response = await query.order('created_at', ascending: true);

      final messages = <AnteprojectMessage>[];
      
      for (final item in response) {
        try {
          // Convertir el item completo a Map<String, dynamic>
          final messageData = _safeConvertMap(item);
          
          // Convertir el campo sender si existe
          if (messageData.containsKey('sender') && messageData['sender'] != null) {
            messageData['sender'] = _safeConvertMap(messageData['sender']);
          }
          
          messages.add(AnteprojectMessage.fromJson(messageData));
        } catch (e) {
          debugPrint('❌ Error al parsear mensaje: $e');
          debugPrint('❌ Datos problemáticos: $item');
        }
      }

      debugPrint('✅ ${messages.length} mensajes cargados para anteproyecto $anteprojectId');
      return messages;
    } catch (e) {
      debugPrint('❌ Error al obtener mensajes: $e');
      rethrow;
    }
  }

  /// Crear un nuevo mensaje
  Future<AnteprojectMessage> createMessage({
    required int anteprojectId,
    required String content,
    int? threadId,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el ID del usuario actual
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', currentUser.email!)
          .single();

      final authorId = userResponse['id'] as int;

      final insertData = {
        'anteproject_id': anteprojectId,
        'sender_id': authorId,
        'content': content,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Agregar thread_id si se proporciona
      if (threadId != null) {
        insertData['thread_id'] = threadId;
      }

      final response = await _supabase
          .from('anteproject_messages')
          .insert(insertData)
          .select()
          .single();

      // Obtener información del autor por separado
      final authorResponse = await _supabase
          .from('users')
          .select('id, full_name, email, role')
          .eq('id', authorId)
          .single();

      // Convertir objetos minificados de Supabase a Map<String, dynamic>
      final messageData = _safeConvertMap(response);
      messageData['sender'] = _safeConvertMap(authorResponse);
      
      final message = AnteprojectMessage.fromJson(messageData);

      // Enviar notificación por email al destinatario
      try {
        await _sendEmailNotification(anteprojectId, message);
      } catch (emailError) {
        debugPrint('⚠️ Error enviando email de notificación: $emailError');
        // No lanzar error, el mensaje ya fue creado
      }

      // Crear notificación en la base de datos
      try {
        await _createMessageNotification(anteprojectId, message);
      } catch (notificationError) {
        debugPrint('⚠️ Error creando notificación: $notificationError');
        // No lanzar error, el mensaje ya fue creado
      }

      return message;
    } catch (e) {
      debugPrint('❌ Error al crear mensaje: $e');
      rethrow;
    }
  }

  /// Marcar mensaje como leído
  Future<void> markAsRead(int messageId) async {
    try {
      await _supabase
          .from('anteproject_messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);

      debugPrint('✅ Mensaje $messageId marcado como leído');
    } catch (e) {
      debugPrint('❌ Error al marcar mensaje como leído: $e');
      rethrow;
    }
  }

  /// Obtener cantidad de mensajes no leídos para un anteproyecto
  Future<int> getUnreadMessageCount(int anteprojectId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return 0;
      }

      // Obtener el ID del usuario actual
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', currentUser.email!)
          .single();

      final userId = userResponse['id'] as int;

      final response = await _supabase
          .from('anteproject_messages')
          .select('id')
          .eq('anteproject_id', anteprojectId)
          .eq('is_read', false)
          .neq('sender_id', userId); // Excluir mensajes propios

      return response.length;
    } catch (e) {
      debugPrint('❌ Error al obtener mensajes no leídos: $e');
      return 0;
    }
  }

  /// Enviar notificación por email al destinatario
  Future<void> _sendEmailNotification(
    int anteprojectId,
    AnteprojectMessage message,
  ) async {
    try {
      // Obtener información del anteproyecto y participantes
      final anteprojectResponse = await _supabase
          .from('anteprojects')
          .select('''
            id,
            title,
            tutor_id,
            tutor:users!anteprojects_tutor_id_fkey (
              id, full_name, email
            )
          ''')
          .eq('id', anteprojectId)
          .single();

      // Obtener información de los estudiantes
      final studentsResponse = await _supabase
          .from('anteproject_students')
          .select('''
            student_id,
            students:users!anteproject_students_student_id_fkey (
              id, full_name, email
            )
          ''')
          .eq('anteproject_id', anteprojectId);

      final senderRole = message.sender?.role;
      final anteprojectTitle = anteprojectResponse['title'] as String;

      // Si el remitente es un estudiante, notificar al tutor
      if (senderRole?.name == 'student') {
        final tutorInfo = _safeConvertMap(anteprojectResponse['tutor']);
        final tutorEmail = tutorInfo['email'] as String;
        final tutorName = tutorInfo['full_name'] as String;
        final studentName = message.sender?.fullName ?? 'Estudiante';
        final studentEmail = message.sender?.email ?? '';

        await EmailNotificationService.sendMessageToTutor(
          tutorEmail: tutorEmail,
          tutorName: tutorName,
          studentName: studentName,
          studentEmail: studentEmail,
          anteprojectTitle: anteprojectTitle,
          messageContent: message.content,
        );
      }
      // Si el remitente es un tutor, notificar a todos los estudiantes
      else if (senderRole?.name == 'tutor' || senderRole?.name == 'admin') {
        final tutorName = message.sender?.fullName ?? 'Tutor';

        for (final studentData in studentsResponse) {
          final studentInfo = _safeConvertMap(studentData['students']);
          final studentEmail = studentInfo['email'] as String;
          final studentName = studentInfo['full_name'] as String;

          await EmailNotificationService.sendMessageToStudent(
            studentEmail: studentEmail,
            studentName: studentName,
            tutorName: tutorName,
            anteprojectTitle: anteprojectTitle,
            messageContent: message.content,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error enviando notificación por email: $e');
      rethrow;
    }
  }

  /// Crear notificación en la base de datos para el destinatario
  Future<void> _createMessageNotification(
    int anteprojectId,
    AnteprojectMessage message,
  ) async {
    try {
      // Obtener información del anteproyecto y participantes
      final anteprojectResponse = await _supabase
          .from('anteprojects')
          .select('''
            id,
            title,
            tutor_id,
            tutor:users!anteprojects_tutor_id_fkey (
              id, full_name, email
            )
          ''')
          .eq('id', anteprojectId)
          .single();

      // Obtener información de los estudiantes
      final studentsResponse = await _supabase
          .from('anteproject_students')
          .select('''
            student_id,
            students:users!anteproject_students_student_id_fkey (
              id, full_name, email
            )
          ''')
          .eq('anteproject_id', anteprojectId);

      final senderRole = message.sender?.role;
      final anteprojectTitle = anteprojectResponse['title'] as String;
      final senderName = message.sender?.fullName ?? 'Usuario';
      final messagePreview = message.content.length > 100
          ? '${message.content.substring(0, 100)}...'
          : message.content;

      // Si el remitente es un estudiante, crear notificación para el tutor
      if (senderRole?.name == 'student') {
        final tutorInfo = _safeConvertMap(anteprojectResponse['tutor']);
        final tutorId = tutorInfo['id'] as int;

        await _supabase.from('notifications').insert({
          'user_id': tutorId,
          'type': 'anteproject_message',
          'title': 'Nuevo mensaje en anteproyecto',
          'message':
              '$senderName te ha enviado un mensaje sobre "$anteprojectTitle": "${message.content.length > 50 ? '${message.content.substring(0, 50)}...' : message.content}"',
          'action_url': '/anteprojects/$anteprojectId',
          'metadata': {
            'anteproject_id': anteprojectId,
            'sender_id': message.senderId,
            'message_preview': messagePreview,
          },
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      // Si el remitente es un tutor, crear notificaciones para todos los estudiantes
      if (senderRole?.name == 'tutor' || senderRole?.name == 'admin') {
        for (final studentData in studentsResponse) {
          final studentInfo = _safeConvertMap(studentData['students']);
          final studentId = studentInfo['id'] as int;

          await _supabase.from('notifications').insert({
            'user_id': studentId,
            'type': 'anteproject_message',
            'title': 'Nuevo mensaje de tu tutor',
            'message':
                '$senderName te ha enviado un mensaje sobre "$anteprojectTitle": "${message.content.length > 50 ? '${message.content.substring(0, 50)}...' : message.content}"',
            'action_url': '/anteprojects/$anteprojectId',
            'metadata': {
              'anteproject_id': anteprojectId,
              'sender_id': message.senderId,
              'message_preview': messagePreview,
            },
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error creando notificación de mensaje: $e');
      rethrow;
    }
  }

  /// Eliminar un mensaje (solo el autor o admin)
  Future<void> deleteMessage(int messageId) async {
    try {
      await _supabase
          .from('anteproject_messages')
          .delete()
          .eq('id', messageId);

      debugPrint('✅ Mensaje $messageId eliminado');
    } catch (e) {
      debugPrint('❌ Error al eliminar mensaje: $e');
      rethrow;
    }
  }
}

