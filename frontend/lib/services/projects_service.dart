import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/models.dart';
import '../utils/app_exception.dart';
import '../utils/network_error_detector.dart';
import 'supabase_interceptor.dart';

class ProjectsService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  /// Obtiene el proyecto del usuario actual
  Future<Project?> getUserProject() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in ProjectsService: $e',
        originalError: e,
      );
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

      // Asegurar que la respuesta sea un Map<String, dynamic>
      final projectData = Map<String, dynamic>.from(response);
      
      return Project.fromJson(projectData);
    } catch (e) {
      debugPrint('Error al obtener proyecto ID $id: $e');
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

      // Conversión robusta a Map<String, dynamic> para objetos minificados
      Map<String, dynamic> anteprojectData = <String, dynamic>{};
      try {
        final responseMap = anteprojectResponse as Map;
        for (final key in responseMap.keys) {
          anteprojectData[key.toString()] = responseMap[key];
        }
      } catch (e) {
        debugPrint('⚠️ Error en conversión, intentando método alternativo: $e');
        anteprojectData = Map<String, dynamic>.from(
          Map<dynamic, dynamic>.from(anteprojectResponse as Map),
        );
      }
      
      // Usar directamente los datos convertidos, el modelo maneja la conversión
      return Anteproject.fromJson(anteprojectData);
    } catch (e) {
      debugPrint('Error al obtener anteproyecto del proyecto: $e');
      return null;
    }
  }

  /// Obtiene todos los proyectos aprobados del estudiante actual
  Future<List<Project>> getStudentProjects() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;
      debugPrint('🔍 Obteniendo proyectos para estudiante ID: $userId');

      // Obtener todos los proyectos del estudiante
      final response = await _supabase
          .from('project_students')
          .select('''
            project_id,
            projects!inner(*)
          ''')
          .eq('student_id', userId);

      debugPrint('🔍 Respuesta de project_students: $response');

      // Extraer y mapear los proyectos
      final projects = <Project>[];
      for (final item in response) {
        try {
          if (item['projects'] != null) {
            // Asegurar que el item sea un Map<String, dynamic>
            final itemMap = Map<String, dynamic>.from(item);
            final projectsData = itemMap['projects'];
            
            // Convertir a Map<String, dynamic> si es necesario
            final projectData = projectsData is Map<String, dynamic>
                ? projectsData
                : Map<String, dynamic>.from(projectsData);

            // Mapear campos de snake_case a camelCase
            final mappedData = {
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

            final project = Project.fromJson(mappedData);
            projects.add(project);
            debugPrint('✅ Proyecto agregado: ${project.title}');
          }
        } catch (e) {
          debugPrint('❌ Error al procesar proyecto: $e');
          debugPrint('   Item: $item');
          // Continuar con el siguiente proyecto
        }
      }

      debugPrint(
        '✅ Se obtuvieron ${projects.length} proyectos para el estudiante',
      );
      return projects;
    } catch (e) {
      debugPrint('❌ Error al obtener proyectos del estudiante: $e');
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in ProjectsService: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene todos los proyectos asignados al tutor actual con información de estudiantes
  /// Retorna una lista de mapas que incluyen el proyecto y la información del estudiante
  Future<List<Map<String, dynamic>>> getTutorProjects() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Obtener el ID del tutor desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final tutorId = userResponse['id'] as int;
      debugPrint('🔍 Obteniendo proyectos para tutor ID: $tutorId');

      // Obtener proyectos con información de estudiantes directamente desde project_students
      // También incluimos el anteproyecto asociado por si acaso
      final response = await _supabase
          .from('projects')
          .select('''
            *,
            project_students(
              student_id,
              users(
                id,
                full_name,
                email,
                nre,
                tutor_id
              )
            ),
            anteprojects!projects_anteproject_id_fkey(
              id,
              title,
              anteproject_students(
                student_id,
                is_lead_author,
                users(
                  id,
                  full_name,
                  email,
                  nre,
                  tutor_id
                )
              )
            )
          ''')
          .eq('tutor_id', tutorId)
          .order('created_at', ascending: false);

      debugPrint('🔍 Encontrados ${response.length} proyectos para el tutor');

      // Función auxiliar para convertir objetos minificados de Supabase
      Map<String, dynamic> safeConvertMap(dynamic data) {
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map) {
          final result = <String, dynamic>{};
          for (final key in data.keys) {
            final value = data[key];
            result[key.toString()] = value;
          }
          return result;
        } else {
          try {
            final map = data as Map;
            final result = <String, dynamic>{};
            for (final key in map.keys) {
              result[key.toString()] = map[key];
            }
            return result;
          } catch (e) {
            debugPrint('⚠️ No se pudo convertir objeto: ${data.runtimeType}');
            return <String, dynamic>{};
          }
        }
      }
      
      // Función para normalizar IDs en objetos users
      void normalizeUserIds(Map<String, dynamic> usersMap) {
        // Normalizar el ID a número de forma robusta
        if (usersMap.containsKey('id') && usersMap['id'] != null) {
          final idValue = usersMap['id'];
          if (idValue is int) {
            usersMap['id'] = idValue;
          } else if (idValue is num) {
            usersMap['id'] = idValue.toInt();
          } else {
            final parsedId = int.tryParse(idValue.toString());
            if (parsedId != null) {
              usersMap['id'] = parsedId;
            } else {
              debugPrint('⚠️ No se pudo convertir ID: $idValue (tipo: ${idValue.runtimeType})');
            }
          }
        }
        
        // Normalizar tutor_id si existe
        if (usersMap.containsKey('tutor_id') && usersMap['tutor_id'] != null) {
          final tutorIdValue = usersMap['tutor_id'];
          if (tutorIdValue is int) {
            usersMap['tutor_id'] = tutorIdValue;
          } else if (tutorIdValue is num) {
            usersMap['tutor_id'] = tutorIdValue.toInt();
          } else {
            final parsedTutorId = int.tryParse(tutorIdValue.toString());
            if (parsedTutorId != null) {
              usersMap['tutor_id'] = parsedTutorId;
            } else {
              usersMap['tutor_id'] = null;
            }
          }
        }
      }

      // Convertir cada item a Map<String, dynamic> para evitar problemas de tipos
      final result = <Map<String, dynamic>>[];
      for (final item in response) {
        try {
          final itemMap = safeConvertMap(item);
          
          // Normalizar IDs en los objetos users anidados dentro de project_students
          if (itemMap.containsKey('project_students') && itemMap['project_students'] != null) {
            final projectStudents = itemMap['project_students'];
            if (projectStudents is List) {
              final studentsList = projectStudents.map((s) {
                final studentMap = safeConvertMap(s);
                if (studentMap.containsKey('users') && studentMap['users'] != null) {
                  final usersMap = safeConvertMap(studentMap['users']);
                  normalizeUserIds(usersMap);
                  studentMap['users'] = usersMap;
                }
                return studentMap;
              }).toList();
              itemMap['project_students'] = studentsList;
            }
          }
          
          // Normalizar IDs en los objetos users anidados dentro de anteprojects (fallback)
          if (itemMap.containsKey('anteprojects') && itemMap['anteprojects'] != null) {
            final anteprojectsData = itemMap['anteprojects'];
            if (anteprojectsData is Map) {
              final anteprojectMap = safeConvertMap(anteprojectsData);
              
              if (anteprojectMap.containsKey('anteproject_students') && 
                  anteprojectMap['anteproject_students'] != null) {
                final students = anteprojectMap['anteproject_students'];
                if (students is List) {
                  final studentsList = students.map((s) {
                    final studentMap = safeConvertMap(s);
                    if (studentMap.containsKey('users') && studentMap['users'] != null) {
                      final usersMap = safeConvertMap(studentMap['users']);
                      normalizeUserIds(usersMap);
                      studentMap['users'] = usersMap;
                    }
                    return studentMap;
                  }).toList();
                  anteprojectMap['anteproject_students'] = studentsList;
                }
              }
              
              itemMap['anteprojects'] = anteprojectMap;
            }
          }
          
          result.add(itemMap);
        } catch (e) {
          debugPrint('❌ Error procesando proyecto del tutor: $e');
          debugPrint('   Tipo del item: ${item.runtimeType}');
        }
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error obteniendo proyectos del tutor: $e');
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in getTutorProjects: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene los estudiantes asignados a un proyecto específico
  Future<List<User>> getProjectStudents(int projectId) async {
    try {
      debugPrint('🔍 Obteniendo estudiantes del proyecto ID: $projectId');

      final response = await _supabase
          .from('project_students')
          .select('''
            student_id,
            users!inner(*)
          ''')
          .eq('project_id', projectId);

      debugPrint('🔍 Respuesta de project_students: $response');

      // Extraer usuarios
      final students = <User>[];
      for (final item in response) {
        if (item['users'] != null) {
          final userData = item['users'] as Map<String, dynamic>;
          students.add(User.fromJson(userData));
        }
      }

      debugPrint('✅ ${students.length} estudiantes encontrados');
      return students;
    } catch (e) {
      debugPrint('❌ Error obteniendo estudiantes del proyecto: $e');
      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error in getProjectStudents: $e',
        originalError: e,
      );
    }
  }
}

class ProjectsException implements Exception {
  final String message;
  const ProjectsException(this.message);

  @override
  String toString() => 'ProjectsException: $message';
}
