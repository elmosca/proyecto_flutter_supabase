import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/models.dart';

class ProjectsService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  /// Obtiene el proyecto del usuario actual
  Future<Project?> getUserProject() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const ProjectsException('Usuario no autenticado');
      }

      // Obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;
      debugPrint('🔍 Buscando proyectos para usuario ID: $userId');

      // Obtener el proyecto del estudiante usando una consulta más simple
      final response = await _supabase
          .from('project_students')
          .select('project_id')
          .eq('student_id', userId);

      debugPrint('🔍 Respuesta de project_students: $response');

      if (response.isNotEmpty) {
        final projectId = response[0]['project_id'] as int;
        debugPrint('🔍 Project ID encontrado: $projectId');

        // Obtener los datos del proyecto
        final projectResponse = await _supabase
            .from('projects')
            .select('*')
            .eq('id', projectId)
            .single();

        debugPrint('🔍 Datos del proyecto: $projectResponse');

        // Mapear campos de snake_case a camelCase, manejando valores null
        final mappedData = {
          'id': projectResponse['id'],
          'title': projectResponse['title'],
          'description': projectResponse['description'],
          'status': projectResponse['status'],
          'startDate': projectResponse['start_date'],
          'estimatedEndDate': projectResponse['estimated_end_date'],
          'actualEndDate': projectResponse['actual_end_date'],
          'tutorId': projectResponse['tutor_id'],
          'anteprojectId': projectResponse['anteproject_id'],
          'githubRepositoryUrl': projectResponse['github_repository_url'],
          'githubMainBranch': projectResponse['github_main_branch'] ?? 'main',
          'lastActivityAt': projectResponse['last_activity_at'],
          'createdAt': projectResponse['created_at'],
          'updatedAt': projectResponse['updated_at'],
        };

        debugPrint('🔍 Datos mapeados: $mappedData');

        try {
          final project = Project.fromJson(mappedData);
          debugPrint('🔍 Proyecto creado exitosamente: ${project.title}');
          return project;
        } catch (e) {
          debugPrint('❌ Error al crear Project.fromJson: $e');
          debugPrint('❌ Datos que causaron el error: $mappedData');
          return null;
        }
      }

      debugPrint('🔍 No se encontraron proyectos para el usuario');
      return null;
    } catch (e) {
      // Si no se encuentra proyecto, retornar null
      return null;
    }
  }

  /// Obtiene el ID del proyecto del usuario actual
  Future<int?> getUserProjectId() async {
    try {
      final project = await getUserProject();
      return project?.id;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene todos los proyectos
  Future<List<Project>> getProjects() async {
    try {
      // Solución temporal: usar datos hardcodeados mientras investigamos el problema de autenticación
      debugPrint('🔍 Intentando obtener proyectos desde Supabase...');

      final response = await _supabase
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      debugPrint('🔍 Respuesta de Supabase: $response');

      // Mapear cada proyecto de snake_case a camelCase
      final mappedProjects = response.map((projectData) {
        return {
          'id': projectData['id'],
          'title': projectData['title'],
          'description': projectData['description'],
          'status': projectData['status'],
          'startDate': projectData['start_date'],
          'estimatedEndDate': projectData['estimated_end_date'],
          'actualEndDate': projectData['actual_end_date'],
          'tutorId': projectData['tutor_id'],
          'anteprojectId': projectData['anteproject_id'],
          'githubRepositoryUrl': projectData['github_repository_url'],
          'githubMainBranch': projectData['github_main_branch'] ?? 'main',
          'lastActivityAt': projectData['last_activity_at'],
          'createdAt': projectData['created_at'],
          'updatedAt': projectData['updated_at'],
        };
      }).toList();

      debugPrint('🔍 Proyectos mapeados: $mappedProjects');
      return mappedProjects.map<Project>(Project.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo proyectos desde Supabase: $e');
      throw ProjectsException('Error al obtener proyectos: $e');
    }
  }

  /// Obtiene un proyecto específico por ID
  Future<Project?> getProject(int id) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('id', id)
          .single();

      return Project.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el anteproyecto asociado a un proyecto
  Future<Anteproject?> getAnteprojectFromProject(int projectId) async {
    try {
      final projectResponse = await _supabase
          .from('projects')
          .select('anteproject_id')
          .eq('id', projectId)
          .single();

      final anteprojectId = projectResponse['anteproject_id'] as int?;
      if (anteprojectId == null) return null;

      final anteprojectResponse = await _supabase
          .from('anteprojects')
          .select('*')
          .eq('id', anteprojectId)
          .single();

      return Anteproject.fromJson(anteprojectResponse);
    } catch (e) {
      debugPrint('Error al obtener anteproyecto del proyecto: $e');
      return null;
    }
  }
}

class ProjectsException implements Exception {
  final String message;
  const ProjectsException(this.message);

  @override
  String toString() => 'ProjectsException: $message';
}
