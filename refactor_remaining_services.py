#!/usr/bin/env python3
"""
Script para refactorizar excepciones en los servicios restantes
"""

import re
import os

def refactor_service_file(file_path, service_name):
    """Refactoriza un archivo de servicio específico"""
    if not os.path.exists(file_path):
        print(f"⚠️ Archivo no encontrado: {file_path}")
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Añadir imports necesarios si no existen
    if 'import \'../utils/app_exception.dart\';' not in content:
        # Buscar la línea de import de models y añadir después
        if "import '../models/models.dart';" in content:
            content = content.replace(
                "import '../models/models.dart';",
                "import '../models/models.dart';\nimport '../utils/app_exception.dart';\nimport '../utils/network_error_detector.dart';\nimport 'supabase_interceptor.dart';"
            )
        else:
            # Buscar cualquier import y añadir al principio
            import_pattern = r"(import '[^']+';)"
            match = re.search(import_pattern, content)
            if match:
                content = content.replace(
                    match.group(1),
                    f"{match.group(1)}\nimport '../utils/app_exception.dart';\nimport '../utils/network_error_detector.dart';\nimport 'supabase_interceptor.dart';"
                )
    
    # Patrones de reemplazo genéricos
    replacements = [
        # Reemplazar excepciones de autenticación
        (r"throw const \w+Exception\('Usuario no autenticado'\);", 
         "throw AuthenticationException(\n          'not_authenticated',\n          technicalMessage: 'User not authenticated',\n        );"),
        
        # Reemplazar excepciones genéricas con interceptores
        (r"throw \w+Exception\('Error al [^:]+: \$e'\);", 
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
        technicalMessage: 'Error in $service_name: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de permisos
        (r"throw const \w+Exception\('No tienes permisos[^']*'\);", 
         "throw PermissionException(\n          'access_denied',\n          technicalMessage: 'User does not have permission',\n        );"),
        
        # Reemplazar excepciones de validación
        (r"throw const \w+Exception\('Campo requerido[^']*'\);", 
         "throw ValidationException(\n          'field_required',\n          technicalMessage: 'Required field is missing',\n        );"),
    ]
    
    # Aplicar reemplazos
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    
    # Escribir el archivo modificado
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Refactorización de {service_name} completada")
    return True

def main():
    services = [
        ('lib/services/projects_service.dart', 'ProjectsService'),
        ('lib/services/comments_service.dart', 'CommentsService'),
        ('lib/services/notifications_service.dart', 'NotificationsService'),
        ('lib/services/user_service.dart', 'UserService'),
        ('lib/services/user_management_service.dart', 'UserManagementService'),
        ('lib/services/schedule_service.dart', 'ScheduleService'),
        ('lib/services/approval_service.dart', 'ApprovalService'),
    ]
    
    for file_path, service_name in services:
        refactor_service_file(file_path, service_name)

if __name__ == "__main__":
    main()
