import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation_thread.dart';

/// Servicio para gestionar hilos/temas de conversación
class ConversationThreadsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene todos los hilos de un proyecto
  Future<List<ConversationThread>> getProjectThreads(int projectId) async {
    try {
      debugPrint('🔍 Obteniendo hilos del proyecto $projectId');

      final response = await _supabase
          .from('conversation_threads')
          .select('''
            *,
            creator:users!conversation_threads_created_by_fkey(*)
          ''')
          .eq('project_id', projectId)
          .eq('is_archived', false)
          .order('last_message_at', ascending: false);

      final threads = <ConversationThread>[];
      for (final item in response) {
        // Obtener conteo de no leídos para este hilo
        final unreadCount = await _getUnreadCountForThread(item['id'] as int, isProject: true);
        
        final threadData = Map<String, dynamic>.from(item);
        threadData['unread_count'] = unreadCount;
        
        threads.add(ConversationThread.fromJson(threadData));
      }

      debugPrint('✅ ${threads.length} hilos encontrados para proyecto $projectId');
      return threads;
    } catch (e) {
      debugPrint('❌ Error al obtener hilos del proyecto: $e');
      rethrow;
    }
  }

  /// Obtiene todos los hilos de un anteproyecto
  Future<List<ConversationThread>> getAnteprojectThreads(int anteprojectId) async {
    try {
      debugPrint('🔍 Obteniendo hilos del anteproyecto $anteprojectId');

      final response = await _supabase
          .from('conversation_threads')
          .select('''
            *,
            creator:users!conversation_threads_created_by_fkey(*)
          ''')
          .eq('anteproject_id', anteprojectId)
          .eq('is_archived', false)
          .order('last_message_at', ascending: false);

      final threads = <ConversationThread>[];
      for (final item in response) {
        // Obtener conteo de no leídos para este hilo
        final unreadCount = await _getUnreadCountForThread(item['id'] as int, isProject: false);
        
        final threadData = Map<String, dynamic>.from(item);
        threadData['unread_count'] = unreadCount;
        
        threads.add(ConversationThread.fromJson(threadData));
      }

      debugPrint('✅ ${threads.length} hilos encontrados para anteproyecto $anteprojectId');
      return threads;
    } catch (e) {
      debugPrint('❌ Error al obtener hilos del anteproyecto: $e');
      rethrow;
    }
  }

  /// Crea un nuevo hilo de conversación
  Future<ConversationThread> createThread({
    int? projectId,
    int? anteprojectId,
    required String title,
  }) async {
    try {
      if (projectId == null && anteprojectId == null) {
        throw Exception('Debe proporcionar un projectId o anteprojectId');
      }

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

      final userId = userResponse['id'] as int;

      debugPrint('🔍 Creando nuevo hilo: $title');

      final response = await _supabase
          .from('conversation_threads')
          .insert({
            'project_id': projectId,
            'anteproject_id': anteprojectId,
            'title': title,
            'created_by': userId,
            'is_archived': false,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'last_message_at': DateTime.now().toIso8601String(),
          })
          .select('''
            *,
            creator:users!conversation_threads_created_by_fkey(*)
          ''')
          .single();

      final thread = ConversationThread.fromJson(response);
      debugPrint('✅ Hilo creado: ${thread.id}');
      
      return thread;
    } catch (e) {
      debugPrint('❌ Error al crear hilo: $e');
      rethrow;
    }
  }

  /// Obtiene un hilo específico por ID
  Future<ConversationThread?> getThread(int threadId) async {
    try {
      final response = await _supabase
          .from('conversation_threads')
          .select('''
            *,
            creator:users!conversation_threads_created_by_fkey(*)
          ''')
          .eq('id', threadId)
          .single();

      return ConversationThread.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error al obtener hilo: $e');
      return null;
    }
  }

  /// Archiva un hilo (lo oculta sin eliminarlo)
  Future<void> archiveThread(int threadId) async {
    try {
      await _supabase
          .from('conversation_threads')
          .update({'is_archived': true})
          .eq('id', threadId);

      debugPrint('✅ Hilo $threadId archivado');
    } catch (e) {
      debugPrint('❌ Error al archivar hilo: $e');
      rethrow;
    }
  }

  /// Elimina un hilo (solo el creador puede hacerlo)
  Future<void> deleteThread(int threadId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar que el usuario actual es el creador
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', currentUser.email!)
          .single();

      final userId = userResponse['id'] as int;

      final threadResponse = await _supabase
          .from('conversation_threads')
          .select('created_by')
          .eq('id', threadId)
          .single();

      if (threadResponse['created_by'] != userId) {
        throw Exception('Solo el creador puede eliminar este hilo');
      }

      await _supabase
          .from('conversation_threads')
          .delete()
          .eq('id', threadId);

      debugPrint('✅ Hilo $threadId eliminado');
    } catch (e) {
      debugPrint('❌ Error al eliminar hilo: $e');
      rethrow;
    }
  }

  /// Cuenta los mensajes no leídos en un hilo específico para el usuario actual
  Future<int> _getUnreadCountForThread(int threadId, {required bool isProject}) async {
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

      // Contar mensajes no leídos que NO fueron enviados por el usuario actual
      final tableName = isProject ? 'project_messages' : 'anteproject_messages';
      
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('thread_id', threadId)
          .eq('is_read', false)
          .neq('sender_id', userId);

      return response.length;
    } catch (e) {
      debugPrint('❌ Error al contar no leídos: $e');
      return 0;
    }
  }

  /// Cuenta el total de mensajes no leídos de todos los hilos de un proyecto
  Future<int> getTotalUnreadForProject(int projectId) async {
    try {
      final threads = await getProjectThreads(projectId);
      int total = 0;
      for (final thread in threads) {
        total += thread.unreadCount ?? 0;
      }
      return total;
    } catch (e) {
      debugPrint('❌ Error al contar total de no leídos: $e');
      return 0;
    }
  }

  /// Cuenta el total de mensajes no leídos de todos los hilos de un anteproyecto
  Future<int> getTotalUnreadForAnteproject(int anteprojectId) async {
    try {
      final threads = await getAnteprojectThreads(anteprojectId);
      int total = 0;
      for (final thread in threads) {
        total += thread.unreadCount ?? 0;
      }
      return total;
    } catch (e) {
      debugPrint('❌ Error al contar total de no leídos: $e');
      return 0;
    }
  }

  /// Obtiene los IDs de proyectos que tienen hilos de conversación (no archivados)
  Future<Set<int>> getProjectsWithThreads() async {
    try {
      final response = await _supabase
          .from('conversation_threads')
          .select('project_id')
          .not('project_id', 'is', null)
          .eq('is_archived', false);

      final projectIds = <int>{};
      for (final item in response) {
        final projectId = item['project_id'];
        if (projectId != null) {
          int? finalId;
          if (projectId is int) {
            finalId = projectId;
          } else if (projectId is num) {
            finalId = projectId.toInt();
          } else {
            final parsed = int.tryParse(projectId.toString());
            if (parsed != null) {
              finalId = parsed;
            }
          }
          if (finalId != null) {
            projectIds.add(finalId);
          }
        }
      }

      return projectIds;
    } catch (e) {
      debugPrint('❌ Error al obtener proyectos con hilos: $e');
      return <int>{};
    }
  }

  /// Obtiene los IDs de anteproyectos que tienen hilos de conversación (no archivados)
  Future<Set<int>> getAnteprojectsWithThreads() async {
    try {
      final response = await _supabase
          .from('conversation_threads')
          .select('anteproject_id')
          .not('anteproject_id', 'is', null)
          .eq('is_archived', false);

      final anteprojectIds = <int>{};
      for (final item in response) {
        final anteprojectId = item['anteproject_id'];
        if (anteprojectId != null) {
          int? finalId;
          if (anteprojectId is int) {
            finalId = anteprojectId;
          } else if (anteprojectId is num) {
            finalId = anteprojectId.toInt();
          } else {
            final parsed = int.tryParse(anteprojectId.toString());
            if (parsed != null) {
              finalId = parsed;
            }
          }
          if (finalId != null) {
            anteprojectIds.add(finalId);
          }
        }
      }

      return anteprojectIds;
    } catch (e) {
      debugPrint('❌ Error al obtener anteproyectos con hilos: $e');
      return <int>{};
    }
  }
}

