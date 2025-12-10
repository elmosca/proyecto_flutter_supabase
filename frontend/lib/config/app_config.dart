import 'package:flutter/foundation.dart';
// Importar configuración local (puede tener valores reales o placeholders)
// En GitHub: valores placeholder
// Localmente: el desarrollador puede sobrescribir con valores reales
import 'app_config_local.dart' as local;

/// Configuración simplificada de la aplicación
///
/// Las credenciales de Supabase se cargan desde app_config_local.dart si existe.
/// Si no existe (en GitHub), se usan valores placeholder seguros.
///
/// Para desarrollo local:
/// 1. Copia app_config_template.dart a app_config_local.dart
/// 2. Completa con tus credenciales reales de Supabase
class AppConfig {
  // Configuración de Supabase
  // Prioridad: 1) Variables de entorno, 2) app_config_local.dart
  //
  // NOTA: app_config_local.dart existe en GitHub con valores placeholder.
  // Para desarrollo local, modifica ese archivo con tus credenciales reales.
  static String get supabaseUrl {
    // Primero intentar variables de entorno (para CI/CD)
    const envUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    // Usar configuración local (puede tener valores reales o placeholder)
    return local.AppConfigLocal.supabaseUrl;
  }

  static String get supabaseAnonKey {
    // Primero intentar variables de entorno (para CI/CD)
    const envKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
    if (envKey.isNotEmpty) return envKey;

    // Usar configuración local (puede tener valores reales o placeholder)
    return local.AppConfigLocal.supabaseAnonKey;
  }

  // Información de la aplicación
  static const String appName = 'TFG Sistema Multiplataforma';
  static const String appVersion = '1.0.0';
  static const String environment = 'cloud';
  static const String platformName = 'Flutter Web';

  // URLs de servicios externos
  static String get supabaseStudioUrl => local.AppConfigLocal.supabaseStudioUrl;

  static const String inbucketUrl = 'https://resend.com/emails';

  static String get storageUrl => local.AppConfigLocal.storageUrl;

  // URLs de guías de usuario en GitHub (raw content)
  // Las guías se cargan dinámicamente desde el repositorio de GitHub
  // Nota: Si las guías están en la rama 'develop', cambiar 'main' por 'develop'
  static const String githubGuidesBaseUrl =
      'https://raw.githubusercontent.com/elmosca/proyecto_flutter_supabase/develop/docs/guias_usuario';

  // URL base de la wiki de GitHub (para abrir en navegador)
  static const String githubWikiBaseUrl =
      'https://github.com/elmosca/proyecto_flutter_supabase/wiki';

  // URL base para contenido raw de la wiki (para embeber en la app)
  static const String githubWikiRawBaseUrl =
      'https://raw.githubusercontent.com/wiki/elmosca/proyecto_flutter_supabase';

  // URLs específicas de las guías en la wiki de GitHub (para abrir en navegador)
  static String get githubWikiStudentGuide =>
      '$githubWikiBaseUrl/Guia-Estudiantes';
  static String get githubWikiTutorGuide =>
      '$githubWikiBaseUrl/Guia-Tutores';
  static String get githubWikiAdminGuide =>
      '$githubWikiBaseUrl/Guia-Administradores';

  // URLs raw de las guías en la wiki (para embeber en la app)
  static String get githubWikiRawStudentGuide =>
      '$githubWikiRawBaseUrl/Guia-Estudiantes.md';
  static String get githubWikiRawTutorGuide =>
      '$githubWikiRawBaseUrl/Guia-Tutores.md';
  static String get githubWikiRawAdminGuide =>
      '$githubWikiRawBaseUrl/Guia-Administradores.md';

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
