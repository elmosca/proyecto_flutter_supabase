import 'package:flutter/foundation.dart';
import 'dart:html' as html;

/// Configuración simplificada de la aplicación
///
/// Usa siempre Supabase en la nube para evitar problemas de detección de entorno
class AppConfig {
  // Configuración única (siempre cloud)
  static const String _supabaseUrl = 'https://zkririyknhlwoxhsoqih.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDkxNjUsImV4cCI6MjA3MTk4NTE2NX0.N9egQFLIqsYdbpjOeSELNiHy5G5RWqa0JY5luZWNBJg';
  static const String _environment = 'cloud';
  static const bool _debugMode = kDebugMode; // Usar el valor real de kDebugMode
  static const String _platformName = 'Flutter Web';

  // Detectar el entorno de acceso
  static bool get isInternalNetwork {
    if (kIsWeb) {
      try {
        final hostname = html.window.location.hostname;
        if (hostname == null) return false;

        // Detectar si es acceso interno (localhost, IP local, o dominio interno)
        return hostname == 'localhost' ||
            hostname == '127.0.0.1' ||
            hostname.startsWith('192.168.') ||
            hostname.startsWith('10.') ||
            hostname.startsWith('172.') ||
            hostname.contains('.local');
      } catch (e) {
        return false;
      }
    }
    return true; // En otras plataformas, asumir red interna
  }

  static bool get isExternalDomain {
    if (kIsWeb) {
      try {
        final hostname = html.window.location.hostname;
        if (hostname == null) return false;

        // Detectar si es acceso externo por dominio
        return hostname == 'fct.jualas.es' ||
            hostname.contains('jualas.es') ||
            (!isInternalNetwork && hostname != 'localhost');
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // Getters principales
  static String get supabaseUrl {
    if (kDebugMode) {
      debugPrint('🔧 Debug - Supabase URL: $_supabaseUrl');
    }
    return _supabaseUrl;
  }

  static String get supabaseAnonKey {
    if (kDebugMode) {
      debugPrint(
        '🔧 Debug - Supabase Anon Key: ${_supabaseAnonKey.substring(0, 20)}...',
      );
    }
    return _supabaseAnonKey;
  }

  static String get environment {
    if (kDebugMode) {
      debugPrint('🔧 Debug - Environment: $_environment');
    }
    return _environment;
  }

  static bool get debugMode {
    if (kDebugMode) {
      debugPrint('🔧 Debug - Debug Mode: $_debugMode');
    }
    return _debugMode;
  }

  static String get platformName {
    if (kDebugMode) {
      debugPrint('🔧 Debug - Platform Name: $_platformName');
    }
    return _platformName;
  }

  // URLs de servicios externos
  static String get supabaseStudioUrl =>
      'https://supabase.com/dashboard/project/zkririyknhlwoxhsoqih';
  static String get inbucketUrl => 'https://resend.com/emails';
  static String get storageUrl => '$_supabaseUrl/storage/v1/s3';

  // Información de la aplicación
  static const String appName = 'TFG Sistema Multiplataforma';
  static const String appVersion = '1.0.0';

  // Credenciales de prueba
  static const Map<String, String> testCredentials = {
    'student': 'student.test@alumno.cifpcarlos3.es',
    'tutor': 'tutor.test@cifpcarlos3.es',
    'admin': 'admin@jualas.es',
    'student_password': 'password123',
    'tutor_password': 'password123',
    'admin_password': 'password123',
  };

  // Métodos de compatibilidad (simplificados)
  static bool get isDevelopment =>
      true; // Siempre en modo desarrollo para mostrar credenciales
  static bool get isProduction => false;
  static String get debugInfo =>
      'Environment: $_environment, Debug Mode: $_debugMode';
  static int get platformColor => 0xFF2196F3; // Azul por defecto

  static void printConfig() {
    if (kDebugMode) {
      debugPrint('🔧 Configuración simplificada:');
      debugPrint('   Supabase URL: $_supabaseUrl');
      debugPrint('   Environment: $_environment');
      debugPrint('   Debug Mode: $_debugMode');
      debugPrint('   Platform: $_platformName');
      debugPrint('   Red Interna: $isInternalNetwork');
      debugPrint('   Dominio Externo: $isExternalDomain');
      debugPrint('   Supabase Studio: $supabaseStudioUrl');
      debugPrint('   Resend Dashboard: $inbucketUrl');
    }
  }
}
