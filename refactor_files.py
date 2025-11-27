#!/usr/bin/env python3
"""
Script para refactorizar todas las excepciones FilesException en el archivo files_service.dart
"""

import re

def refactor_files_service():
    # Leer el archivo
    with open('lib/services/files_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Añadir imports necesarios
    if 'import \'../utils/app_exception.dart\';' not in content:
        content = content.replace(
            "import '../models/models.dart';",
            "import '../models/models.dart';\nimport '../utils/app_exception.dart';\nimport '../utils/network_error_detector.dart';\nimport 'supabase_interceptor.dart';"
        )
    
    # Patrones de reemplazo
    replacements = [
        # Reemplazar excepciones de autenticación
        (r"throw const FilesException\('Usuario no autenticado'\);", 
         "throw AuthenticationException(\n          'not_authenticated',\n          technicalMessage: 'User not authenticated',\n        );"),
        
        # Reemplazar excepciones de validación específicas
        (r"throw const FilesException\('Error al subir el archivo'\);", 
         "throw FileException(\n          'file_upload_failed',\n          technicalMessage: 'File upload failed',\n        );"),
        
        (r"throw const FilesException\(\s*'Tipo de archivo no permitido',\s*\);", 
         "throw FileException(\n          'file_type_not_allowed',\n          technicalMessage: 'File type not allowed',\n        );"),
        
        # Reemplazar excepciones genéricas con interceptores
        (r"throw FilesException\('Error al subir archivo: \$e'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      throw FileException(
        'file_upload_failed',
        technicalMessage: 'Error uploading file: $e',
        originalError: e,
      );"""),
        
        (r"throw FilesException\('Error al obtener archivos: \$e'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      throw FileException(
        'file_download_failed',
        technicalMessage: 'Error getting files: $e',
        originalError: e,
      );"""),
        
        (r"throw FilesException\('Error al eliminar archivo: \$e'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      throw FileException(
        'file_delete_failed',
        technicalMessage: 'Error deleting file: $e',
        originalError: e,
      );"""),
        
        (r"throw FilesException\('Error al descargar archivo: \$e'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      throw FileException(
        'file_download_failed',
        technicalMessage: 'Error downloading file: $e',
        originalError: e,
      );"""),
    ]
    
    # Aplicar reemplazos
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    
    # Escribir el archivo modificado
    with open('lib/services/files_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Refactorización del FilesService completada")

if __name__ == "__main__":
    refactor_files_service()
