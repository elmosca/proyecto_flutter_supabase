/// Configuración de la aplicación por entornos
/// 
/// Este archivo maneja las diferentes configuraciones para:
/// - Desarrollo local (localhost)
/// - Desarrollo remoto (ngrok)
/// - Producción (servidor propio)
class AppConfig {
  // Configuraciones por entorno
  static const Map<String, BackendConfig> _configs = {
    'local': BackendConfig(
      supabaseUrl: 'http://localhost:54321',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
      supabaseServiceKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU',
      environment: 'local',
      debugMode: true,
    ),
    'network': BackendConfig(
      supabaseUrl: 'http://192.168.1.9:54321',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
      supabaseServiceKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU',
      environment: 'network',
      debugMode: true,
    ),
    'cloudflare': BackendConfig(
      supabaseUrl: 'https://api.fct.jualas.es',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
      environment: 'cloudflare',
      debugMode: true,
    ),
    'ngrok': BackendConfig(
      supabaseUrl: 'https://tu-proyecto-tfg.ngrok.io',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
      environment: 'ngrok',
      debugMode: true,
    ),
    'external': BackendConfig(
      supabaseUrl: 'http://152.89.182.29:54321',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
      supabaseServiceKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU',
      environment: 'external',
      debugMode: true,
    ),
    'cloud': BackendConfig(
      supabaseUrl: 'https://zkririyknhlwoxhsoqih.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDkxNjUsImV4cCI6MjA3MTk4NTE2NX0.N9egQFLIqsYdbpjOeSELNiHy5G5RWqa0JY5luZWNBJg',
      supabaseServiceKey: null, // No necesitamos service key para la app
      environment: 'cloud',
      debugMode: true,
    ),
    'production': BackendConfig(
      supabaseUrl: 'https://tu-dominio.com:54321',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
      environment: 'production',
      debugMode: false,
    ),
  };
  
  /// Obtiene la configuración actual basada en la variable de entorno
  static BackendConfig get current {
    const String env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'cloud');
    return _configs[env] ?? _configs['network']!;
  }
  
  // Getters para fácil acceso
  static String get supabaseUrl => current.supabaseUrl;
  static String get supabaseAnonKey => current.supabaseAnonKey;
  static String? get supabaseServiceKey => current.supabaseServiceKey;
  static String get environment => current.environment;
  static bool get debugMode => current.debugMode;
  
  /// Verifica si estamos en modo de desarrollo
  static bool get isDevelopment => environment == 'local' || environment == 'network' || environment == 'ngrok' || environment == 'external';
  
  /// Verifica si estamos en modo de producción
  static bool get isProduction => environment == 'production';
  
  /// Obtiene información de debug para logging
  static String get debugInfo => '''
Environment: $environment
Supabase URL: $supabaseUrl
Debug Mode: $debugMode
Is Development: $isDevelopment
Is Production: $isProduction
''';

  /// Información de debug (solo en desarrollo)
  static void printConfig() {
    if (isDevelopment) {
      // ignore: avoid_print
      print('🔧 Configuración de la aplicación:');
      // ignore: avoid_print
      print('   Plataforma: ${_getPlatformName()}');
      // ignore: avoid_print
      print('   Backend URL: $supabaseUrl');
      // ignore: avoid_print
      print('   Clave anónima: ${supabaseAnonKey.substring(0, 20)}...');
      // ignore: avoid_print
      print('   Storage URL: $supabaseUrl/storage/v1/s3');
      // ignore: avoid_print
      print('   Supabase Studio: ${_getStudioUrl()}');
      // ignore: avoid_print
      print('   Inbucket (Email): ${_getInbucketUrl()}');
    }
  }

  /// Obtiene el nombre de la plataforma
  static String _getPlatformName() {
    // Detectar plataforma basada en el entorno
    if (environment == 'network') return 'Windows (Network)';
    if (environment == 'local') return 'Windows (Local)';
    if (environment == 'ngrok') return 'Windows (Ngrok)';
    if (environment == 'external') return 'Windows (External Router)';
    return 'Windows';
  }

  /// Obtiene la URL de Supabase Studio
  static String _getStudioUrl() {
    if (environment == 'cloudflare') return 'https://studio.fct.jualas.es';
    if (environment == 'network') return 'http://192.168.1.9:54323';
    if (environment == 'external') return 'http://152.89.182.29:54323';
    if (environment == 'local') return 'http://127.0.0.1:54323';
    return 'http://127.0.0.1:54323';
  }

  /// Obtiene la URL de Inbucket
  static String _getInbucketUrl() {
    if (environment == 'cloudflare') return 'https://email.fct.jualas.es';
    if (environment == 'network') return 'http://192.168.1.9:54324';
    if (environment == 'external') return 'http://152.89.182.29:54324';
    if (environment == 'local') return 'http://127.0.0.1:54324';
    return 'http://127.0.0.1:54324';
  }

  /// Obtiene el color de la plataforma
  static int get platformColor {
    if (environment == 'network') return 0xFF4CAF50; // Green for network
    if (environment == 'local') return 0xFF2196F3; // Blue for local
    if (environment == 'ngrok') return 0xFFFF9800; // Orange for ngrok
    if (environment == 'external') return 0xFF9C27B0; // Purple for external router
    return 0xFF2196F3; // Default blue
  }

  /// Nombre de la aplicación
  static const String appName = 'TFG Sistema Multiplataforma';

  /// Versión de la aplicación
  static const String appVersion = '1.0.0';

  /// Obtiene el nombre de la plataforma
  static String get platformName => _getPlatformName();

  /// Obtiene el icono de la plataforma
  static String get platformIcon {
    if (environment == 'network') return '🌐';
    if (environment == 'local') return '🖥️';
    if (environment == 'ngrok') return '🔗';
    if (environment == 'external') return '📡';
    return '🖥️';
  }

  /// Obtiene la URL de Storage
  static String get storageUrl => '$supabaseUrl/storage/v1/s3';

  /// Obtiene la URL de Supabase Studio
  static String get supabaseStudioUrl => _getStudioUrl();

  /// Obtiene la URL de Inbucket
  static String get inbucketUrl => _getInbucketUrl();

  /// Información del servidor (para compatibilidad)
  static const Map<String, String> serverInfo = {
    'ip': 'api.fct.jualas.es',
    'port': '443',
    'storage_port': '443',
    'studio_port': '443',
    'email_port': '443',
  };

  /// Credenciales de prueba (para compatibilidad)
  static const Map<String, String> testCredentials = {
    'student': 'student.test@alumno.cifpcarlos3.es',
    'tutor': 'tutor.test@cifpcarlos3.es',
    'admin': 'admin.test@cifpcarlos3.es',
    'student_password': 'password123',
    'tutor_password': 'password123',
    'admin_password': 'password123',
    'old_student': 'test.student@alumno.cifpcarlos3.es',
    'old_password': 'test123',
  };
}

/// Configuración del backend para un entorno específico
class BackendConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String? supabaseServiceKey;
  final String environment;
  final bool debugMode;
  
  const BackendConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.supabaseServiceKey,
    required this.environment,
    required this.debugMode,
  });
  
  @override
  String toString() {
    return 'BackendConfig(environment: $environment, supabaseUrl: $supabaseUrl, debugMode: $debugMode)';
  }
}
