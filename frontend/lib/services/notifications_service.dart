import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsService {
  final SupabaseClient _supabase;

  NotificationsService._(this._supabase);

  static NotificationsService? maybeCreate() {
    try {
      final client = Supabase.instance.client;
      return NotificationsService._(client);
    } catch (_) {
      return null;
    }
  }

  /// Obtener notificaciones no leídas del usuario actual
  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
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

      final userId = userResponse['id'] as int;

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

  /// Obtener todas las notificaciones del usuario actual
  Future<List<Map<String, dynamic>>> getAllNotifications() async {
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

      final userId = userResponse['id'] as int;

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error al obtener notificaciones: $e');
    }
  }

  /// Marcar notificación como leída
  Future<void> markAsRead(int notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Error al marcar notificación como leída: $e');
    }
  }

  /// Marcar todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
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

      final userId = userResponse['id'] as int;

      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .isFilter('read_at', null);
    } catch (e) {
      throw Exception(
        'Error al marcar todas las notificaciones como leídas: $e',
      );
    }
  }

  /// Eliminar notificación
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      throw Exception('Error al eliminar notificación: $e');
    }
  }

  /// Obtener contador de notificaciones no leídas
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getUnreadNotifications();
      return notifications.length;
    } catch (e) {
      return 0;
    }
  }
}
