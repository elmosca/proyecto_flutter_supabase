#!/usr/bin/env python3
"""
Script para refactorizar todas las excepciones AnteprojectsException en el archivo anteprojects_service.dart
"""

import re

def refactor_anteprojects_service():
    # Leer el archivo
    with open('lib/services/anteprojects_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Patrones de reemplazo
    replacements = [
        # Reemplazar excepciones de autenticación
        (r"throw const AnteprojectsException\('Usuario no autenticado'\);", 
         "throw AuthenticationException(\n          'not_authenticated',\n          technicalMessage: 'User not authenticated',\n        );"),
        
        # Reemplazar excepciones genéricas con interceptores
        (r"throw AnteprojectsException\('Error al obtener anteproyecto: \$e'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error getting anteproject: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de creación
        (r"throw AnteprojectsException\('Error al crear anteproyecto: \$e'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error creating anteproject: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de actualización
        (r"throw AnteprojectsException\('Error al actualizar anteproyecto: \$e'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error updating anteproject: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de envío
        (r"throw AnteprojectsException\('Error al enviar anteproyecto: \$e'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      throw BusinessLogicException(
        'workflow_violation',
        technicalMessage: 'Error sending anteproject: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de aprobación
        (r"throw AnteprojectsException\('Error al aprobar anteproyecto: \$e'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      throw BusinessLogicException(
        'workflow_violation',
        technicalMessage: 'Error approving anteproject: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de rechazo
        (r"throw AnteprojectsException\('Error al rechazar anteproyecto: \$e'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      throw BusinessLogicException(
        'workflow_violation',
        technicalMessage: 'Error rejecting anteproject: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de eliminación
        (r"throw AnteprojectsException\('Error al eliminar anteproyecto: \$e'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }
      
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error deleting anteproject: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de permisos
        (r"throw const AnteprojectsException\(\s*'No tienes permisos para eliminar este anteproyecto',\s*\);", 
         "throw PermissionException(\n          'access_denied',\n          technicalMessage: 'User does not have permission to delete this anteproject',\n        );"),
    ]
    
    # Aplicar reemplazos
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    
    # Escribir el archivo modificado
    with open('lib/services/anteprojects_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Refactorización completada")

if __name__ == "__main__":
    refactor_anteprojects_service()
