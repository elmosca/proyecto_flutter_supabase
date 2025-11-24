#!/usr/bin/env python3
"""
Script para refactorizar todas las excepciones TasksException en el archivo tasks_service.dart
"""

import re

def refactor_tasks_service():
    # Leer el archivo
    with open('lib/services/tasks_service.dart', 'r', encoding='utf-8') as f:
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
        (r"throw const TasksException\('Usuario no autenticado'\);", 
         "throw AuthenticationException(\n          'not_authenticated',\n          technicalMessage: 'User not authenticated',\n        );"),
        
        # Reemplazar excepciones de validación específicas
        (r"throw const TasksException\('missingTaskContext'\);", 
         "throw ValidationException(\n          'missing_task_context',\n          technicalMessage: 'Task context is missing',\n        );"),
        
        (r"throw const TasksException\('invalidProjectRelation'\);", 
         "throw ValidationException(\n          'invalid_project_relation',\n          technicalMessage: 'Invalid project relation',\n        );"),
        
        (r"throw const TasksException\('taskNotFound'\);", 
         "throw ValidationException(\n          'resource_not_found',\n          technicalMessage: 'Task not found',\n        );"),
        
        (r"throw const TasksException\('No se puede eliminar una tarea completada'\);", 
         "throw BusinessLogicException(\n          'cannot_delete_completed_task',\n          technicalMessage: 'Cannot delete a completed task',\n        );"),
        
        # Reemplazar excepciones genéricas con interceptores
        (r"throw TasksException\('Error al obtener tareas: \$e'\);", 
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
        technicalMessage: 'Error getting tasks: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de creación
        (r"throw TasksException\('Error al crear tarea: \$e'\);", 
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
        technicalMessage: 'Error creating task: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de actualización
        (r"throw TasksException\('Error al actualizar tarea: \$e'\);", 
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
        technicalMessage: 'Error updating task: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de eliminación
        (r"throw TasksException\('Error al eliminar tarea: \$e'\);", 
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
        technicalMessage: 'Error deleting task: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de comentarios
        (r"throw TasksException\('Error al añadir comentario: \$e'\);", 
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
        technicalMessage: 'Error adding comment: $e',
        originalError: e,
      );"""),
        
        (r"throw TasksException\('Error al obtener comentarios: \$e'\);", 
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
        technicalMessage: 'Error getting comments: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de Kanban
        (r"throw TasksException\('Error al actualizar posición Kanban: \$error'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(error)) {
        throw SupabaseErrorInterceptor.handleError(error);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(error)) {
        throw NetworkErrorDetector.detectNetworkError(error);
      }
      
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error updating Kanban position: $error',
        originalError: error,
      );"""),
        
        (r"throw TasksException\('Error al mover la tarea: \$error'\);", 
         """// Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(error)) {
        throw SupabaseErrorInterceptor.handleError(error);
      }
      
      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(error)) {
        throw NetworkErrorDetector.detectNetworkError(error);
      }
      
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error moving task: $error',
        originalError: error,
      );"""),
        
        # Reemplazar excepciones de asignación
        (r"throw TasksException\('Error al asignar usuario a tarea: \$e'\);", 
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
        technicalMessage: 'Error assigning user to task: $e',
        originalError: e,
      );"""),
        
        (r"throw TasksException\('Error al quitar usuario de tarea: \$e'\);", 
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
        technicalMessage: 'Error removing user from task: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de estado
        (r"throw TasksException\('Error al actualizar estado de tarea: \$e'\);", 
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
        technicalMessage: 'Error updating task status: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de consultas específicas
        (r"throw TasksException\('Error al obtener tareas del estudiante: \$e'\);", 
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
        technicalMessage: 'Error getting student tasks: $e',
        originalError: e,
      );"""),
        
        (r"throw TasksException\('Error al obtener tareas del proyecto: \$e'\);", 
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
        technicalMessage: 'Error getting project tasks: $e',
        originalError: e,
      );"""),
        
        (r"throw TasksException\('Error al obtener tarea: \$e'\);", 
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
        technicalMessage: 'Error getting task: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de recálculo
        (r"throw TasksException\('Error al recalcular posiciones Kanban: \$e'\);", 
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
        technicalMessage: 'Error recalculating Kanban positions: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones de consultas por estado/complejidad
        (r"throw TasksException\('Error al obtener tareas por estado: \$e'\);", 
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
        technicalMessage: 'Error getting tasks by status: $e',
        originalError: e,
      );"""),
        
        (r"throw TasksException\('Error al obtener tareas por complejidad: \$e'\);", 
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
        technicalMessage: 'Error getting tasks by complexity: $e',
        originalError: e,
      );"""),
        
        # Reemplazar excepciones complejas
        (r"throw TasksException\(\s*'Error al obtener tareas: \$e',\s*\);", 
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
        technicalMessage: 'Error getting tasks: $e',
        originalError: e,
      );"""),
        
        (r"throw TasksException\(\s*'Error al obtener tareas del estudiante: \$e',\s*\);", 
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
        technicalMessage: 'Error getting student tasks: $e',
        originalError: e,
      );"""),
        
        (r"throw TasksException\(\s*'Error al obtener tareas del proyecto: \$e',\s*\);", 
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
        technicalMessage: 'Error getting project tasks: $e',
        originalError: e,
      );"""),
        
        (r"throw TasksException\(\s*'Error al obtener tareas por estado: \$e',\s*\);", 
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
        technicalMessage: 'Error getting tasks by status: $e',
        originalError: e,
      );"""),
        
        (r"throw TasksException\(\s*'Error al obtener tareas por complejidad: \$e',\s*\);", 
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
        technicalMessage: 'Error getting tasks by complexity: $e',
        originalError: e,
      );"""),
    ]
    
    # Aplicar reemplazos
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    
    # Escribir el archivo modificado
    with open('lib/services/tasks_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Refactorización del TasksService completada")

if __name__ == "__main__":
    refactor_tasks_service()
