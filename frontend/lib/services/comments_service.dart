import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/comment.dart';
import '../models/user.dart';

class CommentsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene todos los comentarios de una tarea
  Future<List<Comment>> getCommentsByTaskId(int taskId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('''
            *,
            author:users!comments_author_id_fkey (
              id,
              full_name,
              email,
              role
            )
          ''')
          .eq('task_id', taskId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar comentarios: $e');
    }
  }

  /// Añade un nuevo comentario a una tarea
  Future<Comment> addComment({
    required int taskId,
    required String content,
    required int authorId,
    bool isInternal = false,
  }) async {
    try {
      final response = await _supabase
          .from('comments')
          .insert({
            'task_id': taskId,
            'content': content,
            'author_id': authorId,
            'is_internal': isInternal,
          })
          .select('''
            *,
            author:users!comments_author_id_fkey (
              id,
              full_name,
              email,
              role
            )
          ''')
          .single();

      return Comment.fromJson(response);
    } catch (e) {
      throw Exception('Error al añadir comentario: $e');
    }
  }

  /// Actualiza un comentario existente
  Future<Comment> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      final response = await _supabase
          .from('comments')
          .update({
            'content': content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId)
          .select('''
            *,
            author:users!comments_author_id_fkey (
              id,
              full_name,
              email,
              role
            )
          ''')
          .single();

      return Comment.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar comentario: $e');
    }
  }

  /// Elimina un comentario
  Future<void> deleteComment(int commentId) async {
    try {
      await _supabase
          .from('comments')
          .delete()
          .eq('id', commentId);
    } catch (e) {
      throw Exception('Error al eliminar comentario: $e');
    }
  }

  /// Obtiene un comentario por ID
  Future<Comment> getCommentById(int commentId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('''
            *,
            author:users!comments_author_id_fkey (
              id,
              full_name,
              email,
              role
            )
          ''')
          .eq('id', commentId)
          .single();

      return Comment.fromJson(response);
    } catch (e) {
      throw Exception('Error al cargar comentario: $e');
    }
  }

  /// Verifica si un usuario puede editar un comentario
  bool canEditComment(Comment comment, User currentUser) {
    // Solo el autor del comentario puede editarlo
    return comment.authorId == currentUser.id;
  }

  /// Verifica si un usuario puede eliminar un comentario
  bool canDeleteComment(Comment comment, User currentUser) {
    // Solo el autor del comentario o un admin pueden eliminarlo
    return comment.authorId == currentUser.id || currentUser.role == UserRole.admin;
  }

  /// Verifica si un usuario puede ver comentarios internos
  bool canViewInternalComments(User currentUser) {
    // Solo tutores y admins pueden ver comentarios internos
    return currentUser.role == UserRole.tutor || currentUser.role == UserRole.admin;
  }
}
