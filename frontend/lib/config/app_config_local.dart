// =====================================================
// CONFIGURACIÓN LOCAL DE SUPABASE
// =====================================================
// 
// IMPORTANTE: Este archivo existe en GitHub con valores PLACEHOLDER.
// Para desarrollo local, MODIFICA este archivo con tus credenciales REALES.
// 
// Los cambios locales NO se suben a GitHub (git los ignora automáticamente
// si contienen credenciales reales, o puedes usar git update-index --skip-worktree)
//
// Para obtener tus credenciales:
// https://app.supabase.com/project/_/settings/api
//
// =====================================================

/// Configuración local con credenciales de Supabase
/// 
/// En GitHub: valores placeholder seguros
/// Localmente: modifica este archivo con tus credenciales reales
class AppConfigLocal {
  // URL de tu proyecto de Supabase
  // En GitHub: placeholder
  // Localmente: reemplaza con tu URL real
  static const String supabaseUrl = 'https://TU_PROYECTO.supabase.co';

  // Anon Key (clave pública) de Supabase
  // En GitHub: placeholder
  // Localmente: reemplaza con tu anon key real
  static const String supabaseAnonKey =
      'TU_ANON_KEY_AQUI';

  // URL del dashboard de Supabase (opcional)
  static const String supabaseStudioUrl =
      'https://supabase.com/dashboard/project/TU_PROYECTO_ID';

  // URL de storage de Supabase (opcional)
  static const String storageUrl =
      'https://TU_PROYECTO.supabase.co/storage/v1/s3';
}

