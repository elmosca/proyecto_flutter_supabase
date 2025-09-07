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
      environment: 'local',
      debugMode: true,
    ),
    'ngrok': BackendConfig(
      supabaseUrl: 'https://tu-proyecto-tfg.ngrok.io',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
      environment: 'ngrok',
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
    const String env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'local');
    return _configs[env] ?? _configs['local']!;
  }
  
  // Getters para fácil acceso
  static String get supabaseUrl => current.supabaseUrl;
  static String get supabaseAnonKey => current.supabaseAnonKey;
  static String get environment => current.environment;
  static bool get debugMode => current.debugMode;
  
  /// Verifica si estamos en modo de desarrollo
  static bool get isDevelopment => environment == 'local' || environment == 'ngrok';
  
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
}

/// Configuración del backend para un entorno específico
class BackendConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String environment;
  final bool debugMode;
  
  const BackendConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.environment,
    required this.debugMode,
  });
  
  @override
  String toString() {
    return 'BackendConfig(environment: $environment, supabaseUrl: $supabaseUrl, debugMode: $debugMode)';
  }
}
