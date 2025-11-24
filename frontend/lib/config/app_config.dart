import 'package:flutter/foundation.dart';

/// Configuración simplificada de la aplicación
class AppConfig {
  // Configuración de Supabase
  static const String supabaseUrl = 'https://zkririyknhlwoxhsoqih.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDkxNjUsImV4cCI6MjA3MTk4NTE2NX0.N9egQFLIqsYdbpjOeSELNiHy5G5RWqa0JY5luZWNBJg';

  // Información de la aplicación
  static const String appName = 'TFG Sistema Multiplataforma';
  static const String appVersion = '1.0.0';
  static const String environment = 'cloud';
  static const String platformName = 'Flutter Web';

  // URLs de servicios externos
  static const String supabaseStudioUrl =
      'https://supabase.com/dashboard/project/zkririyknhlwoxhsoqih';
  static const String inbucketUrl = 'https://resend.com/emails';
  static const String storageUrl =
      'https://zkririyknhlwoxhsoqih.supabase.co/storage/v1/s3';
  
  // URLs de guías de usuario en GitHub (raw content)
  // Las guías se cargan dinámicamente desde el repositorio de GitHub
  static const String githubGuidesBaseUrl =
      'https://raw.githubusercontent.com/elmosca/proyecto_flutter_supabase/main/docs/guias_usuario';

  // Credenciales de prueba - Solo del dominio jualas.es
  static const Map<String, String> testCredentials = {
    'student': 'laura.sanchez@jualas.es',
    'tutor': 'jualas@jualas.es',
    'admin': 'admin@jualas.es',
    'student_password': 'EzmvfdQmijMa', // Contraseña temporal de Laura Sánchez
    'tutor_password': 'password123',
    'admin_password': 'password123',
  };

  // Configuración de UI
  static const int platformColor = 0xFF2196F3; // Azul por defecto

  // Debug mode (compatibilidad)
  static bool get debugMode => kDebugMode;
  static bool get isDevelopment => true; // Siempre true para proyecto educativo
}
