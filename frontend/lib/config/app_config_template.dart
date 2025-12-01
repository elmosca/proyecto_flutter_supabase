// =====================================================
// PLANTILLA: Configuración Local de Supabase
// =====================================================
// 
// INSTRUCCIONES:
// 1. Copia este archivo a: app_config_local.dart
// 2. Obtén tus credenciales en: https://app.supabase.com/project/_/settings/api
// 3. Completa los valores con tus credenciales reales
// 4. El archivo app_config_local.dart NO se sube a GitHub (está en .gitignore)
//
// =====================================================

/// Configuración local con credenciales reales de Supabase
/// Este archivo contiene las credenciales reales y NO se sube a GitHub
class AppConfigLocal {
  // URL de tu proyecto de Supabase
  // Formato: https://TU_PROYECTO_ID.supabase.co
  static const String supabaseUrl = 'https://TU_PROYECTO.supabase.co';

  // Anon Key (clave pública) de Supabase
  // Obténla en: Settings → API → Project API keys → anon public
  static const String supabaseAnonKey = 'TU_ANON_KEY_AQUI';

  // URL del dashboard de Supabase (opcional, para referencia)
  static const String supabaseStudioUrl =
      'https://supabase.com/dashboard/project/TU_PROYECTO_ID';

  // URL de storage de Supabase (opcional, para referencia)
  static const String storageUrl =
      'https://TU_PROYECTO.supabase.co/storage/v1/s3';
}

