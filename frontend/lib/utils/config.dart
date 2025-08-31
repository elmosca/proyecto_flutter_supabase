import 'package:flutter/foundation.dart';
import 'dart:io';

/// Configuración del proyecto TFG
class AppConfig {
  // Configuración de Supabase - Local Development
  static const String _localUrl = 'http://127.0.0.1:54321';
  static const String _androidEmulatorUrl = 'http://10.0.2.2:54321'; // Para emulador Android
  
  // Claves de Supabase
  static const String _localAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
  
  // Configuración de Storage S3
  static const String _storageUrl = 'http://127.0.0.1:54321/storage/v1/s3';
  static const String _androidStorageUrl = 'http://10.0.2.2:54321/storage/v1/s3';
  static const String _storageAccessKey = '625729a08b95bf1b7ff351a663f3a23c';
  static const String _storageSecretKey = '850181e4652dd023b7a98c58ae0d2d34bd487ee0cc3254aed6eda37307425907';
  static const String _storageRegion = 'local';
  
  // URLs de herramientas de desarrollo
  static const String _supabaseStudioUrl = 'http://127.0.0.1:54323';
  static const String _androidStudioUrl = 'http://10.0.2.2:54323';
  static const String _inbucketUrl = 'http://127.0.0.1:54324';
  static const String _androidInbucketUrl = 'http://10.0.2.2:54324';
  
  /// Obtiene la URL de Supabase según el entorno
  static String get supabaseUrl {
    // Para emulador de Android, usar 10.0.2.2
    if (Platform.isAndroid) {
      return _androidEmulatorUrl;
    }
    // Para desarrollo, usar localhost
    return _localUrl;
  }
  
  /// Obtiene la clave anónima de Supabase
  static String get supabaseAnonKey {
    return _localAnonKey;
  }
  
  /// Obtiene la URL de Storage S3
  static String get storageUrl {
    if (Platform.isAndroid) {
      return _androidStorageUrl;
    }
    return _storageUrl;
  }
  
  /// Obtiene la clave de acceso de Storage
  static String get storageAccessKey => _storageAccessKey;
  
  /// Obtiene la clave secreta de Storage
  static String get storageSecretKey => _storageSecretKey;
  
  /// Obtiene la región de Storage
  static String get storageRegion => _storageRegion;
  
  /// Obtiene la URL de Supabase Studio
  static String get supabaseStudioUrl {
    if (Platform.isAndroid) {
      return _androidStudioUrl;
    }
    return _supabaseStudioUrl;
  }
  
  /// Obtiene la URL de Inbucket (Email Testing)
  static String get inbucketUrl {
    if (Platform.isAndroid) {
      return _androidInbucketUrl;
    }
    return _inbucketUrl;
  }
  
  /// Obtiene información de la plataforma actual
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Desconocida';
  }
  
  /// Obtiene el color de la plataforma
  static int get platformColor {
    if (kIsWeb) return 0xFF2196F3; // Blue
    if (Platform.isWindows) return 0xFF2196F3; // Blue
    if (Platform.isAndroid) return 0xFF4CAF50; // Green
    if (Platform.isIOS) return 0xFF000000; // Black
    if (Platform.isMacOS) return 0xFF9E9E9E; // Grey
    if (Platform.isLinux) return 0xFFFF9800; // Orange
    return 0xFF9E9E9E; // Grey
  }
  
  /// Obtiene el icono de la plataforma
  static String get platformIcon {
    if (kIsWeb) return '🌐';
    if (Platform.isWindows) return '🖥️';
    if (Platform.isAndroid) return '📱';
    if (Platform.isIOS) return '🍎';
    if (Platform.isMacOS) return '🍎';
    if (Platform.isLinux) return '🐧';
    return '❓';
  }
  
  /// Información de debug (solo en desarrollo)
  static void printConfig() {
    if (isDevelopment) {
      debugPrint('🔧 Configuración de la aplicación:');
      debugPrint('   Plataforma: $platformName');
      debugPrint('   Backend URL: $supabaseUrl');
      debugPrint('   Clave anónima: ${supabaseAnonKey.substring(0, 20)}...');
      debugPrint('   Storage URL: $storageUrl');
      debugPrint('   Supabase Studio: $supabaseStudioUrl');
      debugPrint('   Inbucket (Email): $inbucketUrl');
    }
  }
  
  /// Configuración para desarrollo
  static const bool isDevelopment = true;
  
  /// Configuración para testing
  static const bool enableLogging = true;
  
  /// Configuración de la aplicación
  static const String appName = 'TFG Sistema Multiplataforma';
  static const String appVersion = '1.0.0';
  
  /// Credenciales de prueba
  static const Map<String, String> testCredentials = {
    'student': 'carlos.lopez@alumno.cifpcarlos3.es',
    'tutor': 'maria.garcia@cifpcarlos3.es',
    'admin': 'admin@cifpcarlos3.es',
    'password': 'password123',
  };
  
  /// Información del servidor
  static const Map<String, String> serverInfo = {
    'ip': '127.0.0.1',
    'port': '54321',
    'storage_port': '54321',
    'studio_port': '54323',
    'email_port': '54324',
  };
}
