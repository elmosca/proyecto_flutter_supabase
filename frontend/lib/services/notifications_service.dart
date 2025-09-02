import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class NotificationsService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  /// Obtiene todas las notificaciones del usuario actual
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw NotificationsException('Error al obtener notificaciones: $e');
    }
  }

  /// Obtiene notificaciones no leídas del usuario actual
  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      // Filtrar notificaciones no leídas manualmente
      final allNotifications = List<Map<String, dynamic>>.from(response);
      return allNotifications.where((notification) => 
        notification['read_at'] == null
      ).toList();
    } catch (e) {
      throw NotificationsException('Error al obtener notificaciones no leídas: $e');
    }
  }

  /// Obtiene notificaciones por tipo
  Future<List<Map<String, dynamic>>> getNotificationsByType(String type) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', user.id)
          .eq('type', type)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw NotificationsException('Error al obtener notificaciones por tipo: $e');
    }
  }

  /// Obtiene una notificación específica por ID
  Future<Map<String, dynamic>?> getNotification(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('id', id)
          .eq('user_id', user.id)
          .single();

      return response;
    } catch (e) {
      throw NotificationsException('Error al obtener notificación: $e');
    }
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      await _supabase
          .from('notifications')
          .update({
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      throw NotificationsException('Error al marcar notificación como leída: $e');
    }
  }

  /// Marca todas las notificaciones del usuario como leídas
  Future<void> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      // Obtener todas las notificaciones no leídas
      final unreadNotifications = await getUnreadNotifications();
      
      // Marcar cada una como leída
      for (final notification in unreadNotifications) {
        await markAsRead(notification['id']);
      }
    } catch (e) {
      throw NotificationsException('Error al marcar todas las notificaciones como leídas: $e');
    }
  }

  /// Elimina una notificación
  Future<void> deleteNotification(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      await _supabase
          .from('notifications')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      throw NotificationsException('Error al eliminar notificación: $e');
    }
  }

  /// Elimina todas las notificaciones leídas del usuario
  Future<void> deleteReadNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      // Obtener todas las notificaciones
      final allNotifications = await getNotifications();
      
      // Eliminar las leídas
      for (final notification in allNotifications) {
        if (notification['read_at'] != null) {
          await deleteNotification(notification['id']);
        }
      }
    } catch (e) {
      throw NotificationsException('Error al eliminar notificaciones leídas: $e');
    }
  }

  /// Elimina todas las notificaciones del usuario
  Future<void> deleteAllNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', user.id);
    } catch (e) {
      throw NotificationsException('Error al eliminar todas las notificaciones: $e');
    }
  }

  /// Obtiene el conteo de notificaciones no leídas
  Future<int> getUnreadCount() async {
    try {
      final unreadNotifications = await getUnreadNotifications();
      return unreadNotifications.length;
    } catch (e) {
      throw NotificationsException('Error al obtener conteo de notificaciones: $e');
    }
  }

  /// Crea una nueva notificación
  Future<Map<String, dynamic>> createNotification({
    required int userId,
    required String type,
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      final notificationData = {
        'user_id': userId,
        'type': type,
        'title': title,
        'message': message,
        'action_url': actionUrl,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('notifications')
          .insert(notificationData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw NotificationsException('Error al crear notificación: $e');
    }
  }

  /// Crea notificación de sistema (para administradores)
  Future<Map<String, dynamic>> createSystemNotification({
    required String type,
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      // Verificar que el usuario es administrador
      final userProfile = await _supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      if (userProfile['role'] != 'admin') {
        throw const NotificationsException('Solo los administradores pueden crear notificaciones del sistema');
      }

      // Crear notificación para todos los usuarios activos
      final activeUsers = await _supabase
          .from('users')
          .select('id')
          .eq('status', 'active');

      final notifications = <Map<String, dynamic>>[];
      for (final userData in activeUsers) {
        notifications.add({
          'user_id': userData['id'],
          'type': type,
          'title': title,
          'message': message,
          'action_url': actionUrl,
          'metadata': metadata,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (notifications.isNotEmpty) {
        await _supabase
            .from('notifications')
            .insert(notifications);
      }

      return {'created_count': notifications.length};
    } catch (e) {
      throw NotificationsException('Error al crear notificación del sistema: $e');
    }
  }

  /// Obtiene notificaciones con paginación básica
  Future<Map<String, dynamic>> getNotificationsPaginated({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      List<Map<String, dynamic>> notifications;
      if (unreadOnly) {
        notifications = await getUnreadNotifications();
      } else {
        notifications = await getNotifications();
      }

      final totalCount = notifications.length;
      final totalPages = (totalCount / limit).ceil();
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      
      final paginatedNotifications = notifications.sublist(
        startIndex < totalCount ? startIndex : totalCount,
        endIndex < totalCount ? endIndex : totalCount,
      );

      return {
        'notifications': paginatedNotifications,
        'pagination': {
          'current_page': page,
          'total_pages': totalPages,
          'total_count': totalCount,
          'limit': limit,
          'has_next': page < totalPages,
          'has_previous': page > 1,
        },
      };
    } catch (e) {
      throw NotificationsException('Error al obtener notificaciones paginadas: $e');
    }
  }

  /// Busca notificaciones por texto
  Future<List<Map<String, dynamic>>> searchNotifications(String query) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final allNotifications = List<Map<String, dynamic>>.from(response);
      
      // Filtrar por texto manualmente
      return allNotifications.where((notification) {
        final title = notification['title']?.toString().toLowerCase() ?? '';
        final message = notification['message']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery) || message.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw NotificationsException('Error al buscar notificaciones: $e');
    }
  }

  /// Obtiene estadísticas de notificaciones del usuario
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      final allNotifications = await getNotifications();
      final unreadNotifications = await getUnreadNotifications();

      // Conteo por tipo
      final typeCounts = <String, int>{};
      for (final notification in allNotifications) {
        final type = notification['type'] as String? ?? 'unknown';
        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      }

      return {
        'total': allNotifications.length,
        'unread': unreadNotifications.length,
        'read': allNotifications.length - unreadNotifications.length,
        'by_type': typeCounts,
      };
    } catch (e) {
      throw NotificationsException('Error al obtener estadísticas de notificaciones: $e');
    }
  }

  /// Suscribe a cambios en tiempo real de notificaciones
  Stream<List<Map<String, dynamic>>> subscribeToNotifications() {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      return _supabase
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .order('created_at')
          .map(List<Map<String, dynamic>>.from);
    } catch (e) {
      throw NotificationsException('Error al suscribirse a notificaciones: $e');
    }
  }

  /// Suscribe a cambios en tiempo real del conteo de notificaciones no leídas
  Stream<int> subscribeToUnreadCount() {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotificationsException('Usuario no autenticado');
      }

      return _supabase
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .map((response) => response.length);
    } catch (e) {
      throw NotificationsException('Error al suscribirse al conteo de notificaciones: $e');
    }
  }


}

/// Excepción personalizada para errores de notificaciones
class NotificationsException implements Exception {
  final String message;
  
  const NotificationsException(this.message);
  
  @override
  String toString() => 'NotificationsException: $message';
}
