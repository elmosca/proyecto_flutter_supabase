import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/anteproject_comment.dart';

class AnteprojectCommentsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtener todos los comentarios de un anteproyecto
  Future<List<AnteprojectComment>> getAnteprojectComments(int anteprojectId) async {
    try {
      // Usar una sola consulta con JOIN para evitar problemas de casting
      final response = await _supabase
          .from('anteproject_comments')
          .select('''
            *,
            author:users!anteproject_comments_author_id_fkey (
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
          .eq('anteproject_id', anteprojectId)
          .order('created_at', ascending: true);

      final comments = <AnteprojectComment>[];
      
      for (final commentData in response) {
        try {
          // Convertir a Map<String, dynamic> y validar datos
          final commentMap = Map<String, dynamic>.from(commentData);
          
          // Validar que los campos requeridos no sean null
          if (commentMap['id'] == null || 
              commentMap['anteproject_id'] == null || 
              commentMap['author_id'] == null || 
              commentMap['content'] == null) {
            debugPrint('❌ Error: Campos requeridos son null en comentario: $commentMap');
            continue;
          }
          
          comments.add(AnteprojectComment.fromJson(commentMap));
        } catch (e) {
          debugPrint('❌ Error procesando comentario individual: $e');
          debugPrint('❌ Datos del comentario: $commentData');
          continue; // Continuar con el siguiente comentario
        }
      }

      return comments;
    } catch (e) {
      debugPrint('❌ Error en getAnteprojectComments: $e');
      throw Exception('Error al obtener comentarios: $e');
    }
  }

  /// Crear un nuevo comentario
  Future<AnteprojectComment> createComment({
    required int anteprojectId,
    required String content,
    required bool isInternal,
    String section = 'general',
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final authorId = userResponse['id'] as int?;
      if (authorId == null) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      final response = await _supabase
          .from('anteproject_comments')
          .insert({
            'anteproject_id': anteprojectId,
            'author_id': authorId,
            'content': content,
            'is_internal': isInternal,
            'section': section,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      debugPrint('🔍 Debug - Respuesta de creación de comentario: $response');
      debugPrint('🔍 Debug - Tipo de response: ${response.runtimeType}');
      
      // Obtener información del autor por separado
      final authorResponse = await _supabase
          .from('users')
          .select('id, full_name, email, role')
          .eq('id', authorId)
          .single();

      debugPrint('🔍 Debug - Respuesta del autor: $authorResponse');
      
      // Construir el comentario con la información del autor
      final commentData = Map<String, dynamic>.from(response);
      commentData['author'] = authorResponse;
      
      final comment = AnteprojectComment.fromJson(commentData);

      // Crear notificación para el estudiante si el comentario no es interno
      if (!isInternal) {
        try {
          // Buscar estudiantes asociados al anteproyecto
          final studentsResponse = await _supabase
              .from('anteproject_students')
              .select('student_id')
              .eq('anteproject_id', anteprojectId);

          // Solo crear notificaciones si hay estudiantes asignados
          if (studentsResponse.isNotEmpty) {
            // Crear notificaciones para cada estudiante
            for (final student in studentsResponse) {
              final studentId = student['student_id'] as int;
              await createCommentNotification(
                anteprojectId: anteprojectId,
                studentId: studentId,
                commentContent: content,
              );
            }
          } else {
            debugPrint('No hay estudiantes asignados al anteproyecto $anteprojectId');
          }
        } catch (e) {
          // No fallar si no se puede crear la notificación
          debugPrint('Error al crear notificación: $e');
        }
      }

      return comment;
    } catch (e) {
      throw Exception('Error al crear comentario: $e');
    }
  }

  /// Actualizar un comentario existente
  Future<AnteprojectComment> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      final response = await _supabase
          .from('anteproject_comments')
          .update({
            'content': content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId)
          .select('''
            *,
            author:users!anteproject_comments_author_id_fkey(
              id,
              full_name,
              email,
              role
            )
          ''')
          .single();

      return AnteprojectComment.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar comentario: $e');
    }
  }

  /// Eliminar un comentario
  Future<void> deleteComment(int commentId) async {
    try {
      await _supabase
          .from('anteproject_comments')
          .delete()
          .eq('id', commentId);
    } catch (e) {
      throw Exception('Error al eliminar comentario: $e');
    }
  }

  /// Crear notificación para el estudiante sobre nuevo comentario
  Future<void> createCommentNotification({
    required int anteprojectId,
    required int studentId,
    required String commentContent,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el ID del tutor desde la tabla users
      final tutorResponse = await _supabase
          .from('users')
          .select('id, full_name')
          .eq('email', user.email!)
          .single();

      final tutorId = tutorResponse['id'] as int;
      final tutorName = tutorResponse['full_name'] as String;

      // Crear notificación
      await _supabase
          .from('notifications')
          .insert({
            'user_id': studentId,
            'type': 'anteproject_comment',
            'title': 'Nuevo comentario en tu anteproyecto',
            'message': '$tutorName ha comentado tu anteproyecto: "${commentContent.length > 50 ? '${commentContent.substring(0, 50)}...' : commentContent}"',
            'action_url': '/anteprojects/$anteprojectId',
            'metadata': {
              'anteproject_id': anteprojectId,
              'tutor_id': tutorId,
              'comment_preview': commentContent.length > 100 ? '${commentContent.substring(0, 100)}...' : commentContent,
            },
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Error al crear notificación: $e');
    }
  }

  /// Obtener notificaciones no leídas de un usuario
  Future<List<Map<String, dynamic>>> getUnreadNotifications(int userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .isFilter('read_at', null)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error al obtener notificaciones: $e');
    }
  }

  /// Marcar notificación como leída
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Error al marcar notificación como leída: $e');
    }
  }
}
