import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_message.dart';
import '../models/user.dart' as app_user;
import 'email_notification_service.dart';
import 'academic_permissions_service.dart';
import '../utils/app_exception.dart';

/// Servicio para gestionar mensajes bidireccionales en proyectos aprobados
class ProjectMessagesService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AcademicPermissionsService _academicPermissionsService = AcademicPermissionsService();

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

  /// Obtener todos los mensajes de un proyecto
  /// Si se proporciona threadId, solo devuelve mensajes de ese hilo
  Future<List<ProjectMessage>> getProjectMessages(
    int projectId, {
    int? threadId,
  }) async {
    try {
      // Consulta con JOIN para obtener información del remitente
      var query = _supabase
          .from('project_messages')
          .select('''
            *,
            sender:users!project_messages_sender_id_fkey (
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
          .eq('project_id', projectId);

      // Filtrar por hilo si se proporciona
      if (threadId != null) {
        query = query.eq('thread_id', threadId);
      }

      final response = await query.order('created_at', ascending: true);

      final messages = <ProjectMessage>[];
      
      for (final item in response) {
        try {
          messages.add(ProjectMessage.fromJson(item));
        } catch (e) {
          debugPrint('❌ Error al parsear mensaje: $e');
          debugPrint('❌ Datos problemáticos: $item');
        }
      }

      debugPrint('✅ ${messages.length} mensajes cargados para proyecto $projectId');
      return messages;
    } catch (e) {
      debugPrint('❌ Error al obtener mensajes: $e');
      rethrow;
    }
  }

  /// Crear un nuevo mensaje
  Future<ProjectMessage> createMessage({
    required int projectId,
    required String content,
    int? threadId,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el ID del usuario actual
      final userResponseRaw = await _supabase
          .from('users')
          .select('id, full_name, email, role, academic_year')
          .eq('email', currentUser.email!)
          .single();

      final userResponse = _safeConvertMap(userResponseRaw);
      final authorId = userResponse['id'] as int;
      final authorName = userResponse['full_name'] as String;
      final authorEmail = userResponse['email'] as String;
      final authorRole = app_user.UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == userResponse['role'],
        orElse: () => app_user.UserRole.student,
      );
      final studentAcademicYear = userResponse['academic_year'] as String?;

      // Verificar permisos de escritura para estudiantes
      if (authorRole == app_user.UserRole.student) {
        final canWrite = await _academicPermissionsService.canWriteByAcademicYear(studentAcademicYear);
        if (!canWrite) {
          throw ValidationException(
            'read_only_mode',
            technicalMessage:
                'No puedes enviar mensajes porque tu año académico ya no está activo.',
          );
        }
      }

      // Insertar el mensaje
      final insertData = {
        'project_id': projectId,
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

      final responseRaw = await _supabase
          .from('project_messages')
          .insert(insertData)
          .select()
          .single();

      // Convertir respuesta minificada
      final response = _safeConvertMap(responseRaw);

      // Obtener información del proyecto y del tutor/estudiante destinatario
      final projectResponseRaw = await _supabase
          .from('projects')
          .select('''
            id,
            title,
            tutor_id,
            tutor:users!projects_tutor_id_fkey (
              id,
              full_name,
              email
            ),
            project_students (
              student_id,
              student:users!project_students_student_id_fkey (
                id,
                full_name,
                email
              )
            )
          ''')
          .eq('id', projectId)
          .single();

      final projectResponse = _safeConvertMap(projectResponseRaw);
      final projectTitle = projectResponse['title'] as String;
      
      // Enviar notificación por email según quién envió el mensaje
      try {
        if (authorRole == app_user.UserRole.student) {
          // El estudiante envió mensaje al tutor
          final tutorData = _safeConvertMap(projectResponse['tutor']);
          final tutorEmail = tutorData['email'] as String;
          final tutorName = tutorData['full_name'] as String;

          await EmailNotificationService.sendMessageToTutor(
            tutorEmail: tutorEmail,
            tutorName: tutorName,
            studentName: authorName,
            studentEmail: authorEmail,
            anteprojectTitle: projectTitle,
            messageContent: content,
          );
        } else if (authorRole == app_user.UserRole.tutor) {
          // El tutor envió mensaje a los estudiantes
          final projectStudents = projectResponse['project_students'] as List;
          
          for (final studentDataRaw in projectStudents) {
            final studentData = _safeConvertMap(studentDataRaw);
            final student = _safeConvertMap(studentData['student']);
            final studentEmail = student['email'] as String;
            final studentName = student['full_name'] as String;

            await EmailNotificationService.sendMessageToStudent(
              studentEmail: studentEmail,
              studentName: studentName,
              tutorName: authorName,
              anteprojectTitle: projectTitle,
              messageContent: content,
            );
          }
        }
      } catch (emailError) {
        debugPrint('⚠️ Error enviando email de notificación: $emailError');
        // No lanzar error, el mensaje ya fue creado
      }

      // Construir el mensaje con la información del autor
      final message = ProjectMessage(
        id: response['id'] as int,
        projectId: response['project_id'] as int,
        senderId: response['sender_id'] as int,
        content: response['content'] as String,
        isRead: response['is_read'] as bool,
        readAt: response['read_at'] != null
            ? DateTime.parse(response['read_at'] as String)
            : null,
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: DateTime.parse(response['updated_at'] as String),
        sender: app_user.User.fromJson(userResponse),
      );

      // Crear notificación en la base de datos
      try {
        await _createMessageNotification(projectId, message, projectResponse);
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

  /// Marcar un mensaje como leído
  Future<void> markAsRead(int messageId) async {
    try {
      await _supabase
          .from('project_messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);

      debugPrint('✅ Mensaje $messageId marcado como leído');
    } catch (e) {
      debugPrint('❌ Error al marcar mensaje como leído: $e');
      rethrow;
    }
  }

  /// Obtener cantidad de mensajes no leídos de un proyecto para el usuario actual
  Future<int> getUnreadCount(int projectId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return 0;
      }

      // Obtener el ID del usuario actual
      final userResponseRaw = await _supabase
          .from('users')
          .select('id')
          .eq('email', currentUser.email!)
          .single();

      final userResponse = _safeConvertMap(userResponseRaw);
      final userId = userResponse['id'] as int;

      // Contar mensajes no leídos que NO fueron enviados por el usuario actual
      final response = await _supabase
          .from('project_messages')
          .select()
          .eq('project_id', projectId)
          .eq('is_read', false)
          .neq('sender_id', userId);

      return response.length;
    } catch (e) {
      debugPrint('❌ Error al obtener conteo de no leídos: $e');
      return 0;
    }
  }

  /// Eliminar un mensaje (solo el autor puede hacerlo)
  Future<void> deleteMessage(int messageId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar que el usuario actual es el autor
      final userResponseRaw = await _supabase
          .from('users')
          .select('id')
          .eq('email', currentUser.email!)
          .single();

      final userResponse = _safeConvertMap(userResponseRaw);
      final userId = userResponse['id'] as int;

      final messageResponseRaw = await _supabase
          .from('project_messages')
          .select('sender_id')
          .eq('id', messageId)
          .single();

      final messageResponse = _safeConvertMap(messageResponseRaw);
      if (messageResponse['sender_id'] != userId) {
        throw Exception('No tienes permiso para eliminar este mensaje');
      }

      await _supabase
          .from('project_messages')
          .delete()
          .eq('id', messageId);

      debugPrint('✅ Mensaje $messageId eliminado');
    } catch (e) {
      debugPrint('❌ Error al eliminar mensaje: $e');
      rethrow;
    }
  }

  /// Crear notificación en la base de datos para el destinatario
  Future<void> _createMessageNotification(
    int projectId,
    ProjectMessage message,
    Map<String, dynamic> projectResponse,
  ) async {
    try {
      final senderRole = message.sender?.role;
      final projectTitle = projectResponse['title'] as String;
      final senderName = message.sender?.fullName ?? 'Usuario';
      final messagePreview = message.content.length > 100
          ? '${message.content.substring(0, 100)}...'
          : message.content;

      // Si el remitente es un estudiante, crear notificación para el tutor
      if (senderRole == app_user.UserRole.student) {
        final tutorData = _safeConvertMap(projectResponse['tutor']);
        final tutorId = tutorData['id'] as int;

        await _supabase.from('notifications').insert({
          'user_id': tutorId,
          'type': 'project_message',
          'title': 'Nuevo mensaje en proyecto',
          'message':
              '$senderName te ha enviado un mensaje sobre "$projectTitle": "${message.content.length > 50 ? '${message.content.substring(0, 50)}...' : message.content}"',
          'action_url': '/projects/$projectId',
          'metadata': {
            'project_id': projectId,
            'sender_id': message.senderId,
            'message_preview': messagePreview,
          },
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      // Si el remitente es un tutor, crear notificaciones para todos los estudiantes
      if (senderRole == app_user.UserRole.tutor) {
        final projectStudents = projectResponse['project_students'] as List;
        
        for (final studentDataRaw in projectStudents) {
          final studentData = _safeConvertMap(studentDataRaw);
          final student = _safeConvertMap(studentData['student']);
          final studentId = student['id'] as int;

          await _supabase.from('notifications').insert({
            'user_id': studentId,
            'type': 'project_message',
            'title': 'Nuevo mensaje de tu tutor',
            'message':
                '$senderName te ha enviado un mensaje sobre "$projectTitle": "${message.content.length > 50 ? '${message.content.substring(0, 50)}...' : message.content}"',
            'action_url': '/projects/$projectId',
            'metadata': {
              'project_id': projectId,
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

  /// Suscribirse a cambios en tiempo real de mensajes de un proyecto
  Stream<List<ProjectMessage>> subscribeToProjectMessages(int projectId) {
    return _supabase
        .from('project_messages')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('created_at')
        .asyncMap((data) async {
          final messages = <ProjectMessage>[];
          
          for (final item in data) {
            try {
              // Obtener información del remitente
              final senderResponseRaw = await _supabase
                  .from('users')
                  .select()
                  .eq('id', item['sender_id'])
                  .single();
              
              final senderResponse = _safeConvertMap(senderResponseRaw);
              item['sender'] = senderResponse;
              messages.add(ProjectMessage.fromJson(item));
            } catch (e) {
              debugPrint('❌ Error al parsear mensaje en stream: $e');
            }
          }
          
          return messages;
        });
  }
}

