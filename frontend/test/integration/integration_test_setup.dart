import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración para tests de integración
class IntegrationTestSetup {
  static bool _isInitialized = false;

  /// Inicializar Supabase para testing
  ///
  /// Usa variables de entorno si están disponibles:
  /// - SUPABASE_URL: URL del proyecto de Supabase
  /// - SUPABASE_ANON_KEY: Anon key del proyecto
  ///
  /// Si no están disponibles, usa valores por defecto para localhost (Supabase local)
  static Future<void> initializeSupabase() async {
    if (_isInitialized) return;

    try {
      // Intentar obtener desde variables de entorno (para CI/CD o tests con Supabase real)
      const envUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      const envAnonKey = String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      );

      // Usar variables de entorno si están disponibles, sino usar valores por defecto (localhost)
      final supabaseUrl = envUrl.isNotEmpty
          ? envUrl
          : 'http://localhost:54321'; // Supabase local por defecto

      final supabaseAnonKey = envAnonKey.isNotEmpty
          ? envAnonKey
          : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'; // Key de demo por defecto

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      _isInitialized = true;
      debugPrint('✅ Supabase inicializado para testing');
      debugPrint(
        '   URL: ${envUrl.isNotEmpty ? "Desde variable de entorno" : "Localhost (por defecto)"}',
      );
    } catch (e) {
      debugPrint('❌ Error inicializando Supabase: $e');
      rethrow;
    }
  }

  /// Limpiar datos de testing
  static Future<void> cleanupTestData() async {
    try {
      // Limpiar datos de testing (opcional)
      // await Supabase.instance.client.from('tasks').delete().eq('is_test_data', true);
      // await Supabase.instance.client.from('anteprojects').delete().eq('is_test_data', true);

      debugPrint('✅ Datos de testing limpiados');
    } catch (e) {
      debugPrint('⚠️ Error limpiando datos de testing: $e');
    }
  }

  /// Crear usuario de testing
  static Future<AuthResponse> createTestUser() async {
    try {
      // Crear usuario temporal para testing
      final response = await Supabase.instance.client.auth.signUp(
        email: 'test_${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'testpassword123',
      );

      debugPrint('✅ Usuario de testing creado: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('❌ Error creando usuario de testing: $e');
      rethrow;
    }
  }

  /// Eliminar usuario de testing
  static Future<void> deleteTestUser(String userId) async {
    try {
      await Supabase.instance.client.auth.admin.deleteUser(userId);
      debugPrint('✅ Usuario de testing eliminado');
    } catch (e) {
      debugPrint('⚠️ Error eliminando usuario de testing: $e');
    }
  }

  /// Verificar conexión con backend
  static Future<bool> testBackendConnection() async {
    try {
      // Intentar una consulta simple
      await Supabase.instance.client.from('users').select('count').limit(1);

      debugPrint('✅ Conexión con backend verificada');
      return true;
    } catch (e) {
      debugPrint('❌ Error de conexión con backend: $e');
      return false;
    }
  }
}

/// Mixin para tests de integración
mixin IntegrationTestMixin {
  /// Setup común para tests de integración
  Future<void> setUpIntegrationTest() async {
    await IntegrationTestSetup.initializeSupabase();
    await IntegrationTestSetup.cleanupTestData();
  }

  /// Teardown común para tests de integración
  Future<void> tearDownIntegrationTest() async {
    await IntegrationTestSetup.cleanupTestData();
  }
}
