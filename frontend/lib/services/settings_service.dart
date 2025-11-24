import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/system_setting.dart';
import '../utils/app_exception.dart';
import '../utils/network_error_detector.dart';
import 'supabase_interceptor.dart';

/// Servicio para gestión de configuraciones del sistema
///
/// Proporciona operaciones CRUD para las configuraciones:
/// - Obtener todas las configuraciones
/// - Obtener una configuración específica por clave
/// - Actualizar configuraciones
/// - Obtener configuraciones por tipo
class SettingsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene todas las configuraciones del sistema
  Future<List<SystemSetting>> getSettings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      final response = await _supabase
          .from('system_settings')
          .select()
          .order('setting_key');

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map<SystemSetting>(
            (json) => SystemSetting.fromJson(json as Map<String, dynamic>),
          )
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
        technicalMessage: 'Error obteniendo configuraciones: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene una configuración específica por su clave
  Future<SystemSetting?> getSetting(String key) async {
    try {
      final response = await _supabase
          .from('system_settings')
          .select()
          .eq('setting_key', key)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return SystemSetting.fromJson(response);
    } catch (e) {
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error obteniendo configuración $key: $e',
        originalError: e,
      );
    }
  }

  /// Actualiza una configuración específica
  Future<void> updateSetting(String key, dynamic value, {int? userId}) async {
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
          .select('id')
          .eq('email', user.email!)
          .single();

      final currentUserId = userResponse['id'] as int;
      final userIdToUse = userId ?? currentUserId;

      // Convertir el valor a String según el tipo
      String stringValue;
      if (value is bool) {
        stringValue = value.toString();
      } else if (value is Map || value is List) {
        stringValue = value.toString().replaceAll("'", '"');
      } else {
        stringValue = value.toString();
      }

      await _supabase
          .from('system_settings')
          .update({
            'setting_value': stringValue,
            'updated_by': userIdToUse,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('setting_key', key);

      // Lanzar error si no se actualizó ningún registro
      // (esto es una verificación manual ya que Supabase no lo hace automáticamente)
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      if (e is DatabaseException) rethrow;

      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_update_failed',
        technicalMessage: 'Error actualizando configuración $key: $e',
        originalError: e,
      );
    }
  }

  /// Actualiza múltiples configuraciones a la vez
  Future<void> updateSettings(
    Map<String, dynamic> settings, {
    int? userId,
  }) async {
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
          .select('id')
          .eq('email', user.email!)
          .single();

      final currentUserId = userResponse['id'] as int;
      final userIdToUse = userId ?? currentUserId;

      // Actualizar cada configuración
      for (final entry in settings.entries) {
        final key = entry.key;
        final value = entry.value;

        // Convertir el valor a String
        String stringValue;
        if (value is bool) {
          stringValue = value.toString();
        } else if (value is Map || value is List) {
          stringValue = value.toString().replaceAll("'", '"');
        } else {
          stringValue = value.toString();
        }

        await _supabase
            .from('system_settings')
            .update({
              'setting_value': stringValue,
              'updated_by': userIdToUse,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('setting_key', key);
      }
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      if (e is DatabaseException) rethrow;

      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_update_failed',
        technicalMessage: 'Error actualizando configuraciones: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene una configuración como String
  Future<String?> getStringSetting(String key) async {
    final setting = await getSetting(key);
    return setting?.stringValue;
  }

  /// Obtiene una configuración como int
  Future<int?> getIntSetting(String key) async {
    final setting = await getSetting(key);
    return setting?.intValue;
  }

  /// Obtiene una configuración como bool
  Future<bool?> getBoolSetting(String key) async {
    final setting = await getSetting(key);
    return setting?.boolValue;
  }

  /// Obtiene una configuración como JSON (Map)
  Future<Map<String, dynamic>?> getJsonSetting(String key) async {
    final setting = await getSetting(key);
    return setting?.jsonValue;
  }

  /// Obtiene configuraciones agrupadas por categoría
  Future<Map<String, List<SystemSetting>>> getSettingsByCategory() async {
    final settings = await getSettings();
    final Map<String, List<SystemSetting>> categorized = {};

    for (final setting in settings) {
      String category = 'general';

      // Determinar categoría según la clave
      if (setting.key.contains('institution') ||
          setting.key.contains('academic_year')) {
        category = 'general';
      } else if (setting.key.contains('file') ||
          setting.key.contains('size') ||
          setting.key.contains('allowed')) {
        category = 'files';
      } else if (setting.key.contains('project') ||
          setting.key.contains('duration')) {
        category = 'projects';
      } else if (setting.key.contains('enable') ||
          setting.key.contains('integration') ||
          setting.key.contains('notification')) {
        category = 'features';
      }

      categorized.putIfAbsent(category, () => []).add(setting);
    }

    return categorized;
  }
}
