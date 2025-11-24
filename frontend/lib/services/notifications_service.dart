import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';
import '../utils/app_exception.dart';
import '../utils/network_error_detector.dart';
import 'supabase_interceptor.dart';

/// Servicio para gestión de notificaciones en la aplicación.
///
/// Proporciona operaciones para consultar y gestionar notificaciones:
/// - Obtener notificaciones no leídas del usuario
/// - Obtener todas las notificaciones del usuario
/// - Marcar notificaciones como leídas
/// - Marcar todas las notificaciones como leídas
/// - Contar notificaciones pendientes
///
/// ## Funcionalidades principales:
/// - Consulta de notificaciones por estado (leídas/no leídas)
/// - Marcado de notificaciones como leídas
/// - Conteo de notificaciones pendientes
/// - Ordenamiento por fecha de creación
///
/// ## Seguridad:
/// - Requiere autenticación: Sí
/// - Roles permitidos: Todos
/// - Políticas RLS aplicadas: Los usuarios solo ven sus notificaciones
///
/// ## Ejemplo de uso:
/// ```dart
/// final service = NotificationsService.maybeCreate();
/// if (service != null) {
///   final notifications = await service.getUnreadNotifications();
/// }
/// ```
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

  /// Obtiene las notificaciones no leídas del usuario actual.
  ///
  /// Retorna:
  /// - Lista de notificaciones no leídas ordenadas por fecha de creación
  ///
  /// Lanza:
  /// - [Exception] si no hay usuario autenticado o falla la consulta
  Future<List<Notification>> getUnreadNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id, role')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;
      final userRole = userResponse['role'] as String;

      // Construir la query según el rol
      dynamic query;
      if (userRole == 'admin') {
        // Para admin: solo sus notificaciones personales y del sistema (no privadas)
        query = _supabase
            .from('notifications')
            .select('*')
            .or(
              'user_id.eq.$userId,type.in.(user_created,user_deleted,system_error,security_alert,backup_completed,settings_changed,bulk_operation,system_maintenance,announcement,system_notification)',
            )
            .isFilter('read_at', null)
            .order('created_at', ascending: false);
      } else {
        // Para otros roles: solo sus propias notificaciones
        query = _supabase
            .from('notifications')
            .select('*')
            .eq('user_id', userId)
            .isFilter('read_at', null)
            .order('created_at', ascending: false);
      }

      final response = await query;

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((json) => Notification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error obteniendo notificaciones no leídas: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene todas las notificaciones del usuario actual.
  ///
  /// Retorna:
  /// - Lista completa de notificaciones ordenadas por fecha de creación
  ///
  /// Lanza:
  /// - [Exception] si no hay usuario autenticado o falla la consulta
  Future<List<Notification>> getAllNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id, role')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;
      final userRole = userResponse['role'] as String;

      // Construir la query según el rol
      dynamic query;
      if (userRole == 'admin') {
        // Para admin: solo sus notificaciones personales y del sistema (no privadas)
        query = _supabase
            .from('notifications')
            .select('*')
            .or(
              'user_id.eq.$userId,type.in.(user_created,user_deleted,system_error,security_alert,backup_completed,settings_changed,bulk_operation,system_maintenance,announcement,system_notification)',
            )
            .order('created_at', ascending: false);
      } else {
        // Para otros roles: solo sus propias notificaciones
        query = _supabase
            .from('notifications')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', ascending: false);
      }

      final response = await query;

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((json) => Notification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error obteniendo notificaciones: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene notificaciones del sistema (solo para administradores)
  /// Excluye comunicaciones privadas entre usuarios
  Future<List<Notification>> getSystemNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      final userResponse = await _supabase
          .from('users')
          .select('role')
          .eq('email', user.email!)
          .single();

      final userRole = userResponse['role'] as String;

      if (userRole != 'admin') {
        throw Exception(
          'Solo los administradores pueden ver notificaciones del sistema',
        );
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .inFilter('type', [
            'user_created',
            'user_deleted',
            'system_error',
            'security_alert',
            'backup_completed',
            'settings_changed',
            'bulk_operation',
            'system_maintenance',
            'announcement',
            'system_notification',
          ])
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((json) => Notification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error obteniendo notificaciones del sistema: $e',
        originalError: e,
      );
    }
  }

  /// Crea una notificación administrativa para otro usuario (solo admin)
  Future<void> createAdminNotification({
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
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Verificar que el usuario es admin
      final userResponse = await _supabase
          .from('users')
          .select('role')
          .eq('email', user.email!)
          .single();

      if (userResponse['role'] != 'admin') {
        throw Exception('Solo los administradores pueden crear notificaciones');
      }

      // Verificar que el tipo es permitido para admin
      const allowedTypes = [
        'announcement',
        'system_maintenance',
        'system_notification',
        'deadline_reminder',
        'welcome',
      ];

      if (!allowedTypes.contains(type)) {
        throw Exception(
          'Tipo de notificación no permitido para administradores: $type',
        );
      }

      await _supabase.from('notifications').insert({
        'user_id': userId,
        'type': type,
        'title': title,
        'message': message,
        'action_url': actionUrl,
        'metadata': metadata,
      });
    } catch (e) {
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_insert_failed',
        technicalMessage: 'Error creando notificación: $e',
        originalError: e,
      );
    }
  }

  /// Marca una notificación específica como leída.
  ///
  /// Parámetros:
  /// - [notificationId]: ID de la notificación a marcar como leída
  ///
  /// Lanza:
  /// - [Exception] si falla la actualización
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

  /// Marca todas las notificaciones del usuario como leídas.
  ///
  /// Lanza:
  /// - [Exception] si no hay usuario autenticado o falla la actualización
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

  /// Obtiene estadísticas agregadas de notificaciones (solo para admin)
  /// Retorna contadores sin contenido privado
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      final userResponse = await _supabase
          .from('users')
          .select('role')
          .eq('email', user.email!)
          .single();

      if (userResponse['role'] != 'admin') {
        throw Exception('Solo los administradores pueden ver estadísticas');
      }

      // Obtener contadores por tipo (solo tipos del sistema)
      final response = await _supabase
          .from('notifications')
          .select('type, read_at')
          .inFilter('type', [
            'user_created',
            'user_deleted',
            'system_error',
            'security_alert',
            'backup_completed',
            'settings_changed',
            'bulk_operation',
            'system_maintenance',
            'announcement',
            'system_notification',
          ]);

      final notifications = (response as List<dynamic>)
          .cast<Map<String, dynamic>>();

      final total = notifications.length;
      final unread = notifications.where((n) => n['read_at'] == null).length;

      final byType = <String, int>{};
      for (final notif in notifications) {
        final type = notif['type'] as String;
        byType[type] = (byType[type] ?? 0) + 1;
      }

      return {
        'total': total,
        'unread': unread,
        'read': total - unread,
        'by_type': byType,
      };
    } catch (e) {
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error obteniendo estadísticas: $e',
        originalError: e,
      );
    }
  }
}
