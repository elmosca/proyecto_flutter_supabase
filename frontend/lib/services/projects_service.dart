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

      // Obtener el proyecto del estudiante
      final response = await _supabase
          .from('project_students')
          .select('''
            project_id,
            projects!inner(*)
          ''')
          .eq('student_id', userId)
          .single();

      if (response['projects'] != null) {
        return Project.fromJson(response['projects']);
      }

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
      final response = await _supabase
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      return response.map<Project>(Project.fromJson).toList();
    } catch (e) {
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
}

class ProjectsException implements Exception {
  final String message;
  const ProjectsException(this.message);

  @override
  String toString() => 'ProjectsException: $message';
}
