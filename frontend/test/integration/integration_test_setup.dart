import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración para tests de integración
class IntegrationTestSetup {
  static bool _isInitialized = false;
  
  /// Inicializar Supabase para testing
  static Future<void> initializeSupabase() async {
    if (_isInitialized) return;
    
    try {
      await Supabase.initialize(
        url: 'http://localhost:54321',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
      );
      _isInitialized = true;
      debugPrint('✅ Supabase inicializado para testing');
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
