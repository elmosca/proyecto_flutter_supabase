import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/models.dart';
import 'email_notification_service.dart';
import '../utils/app_exception.dart';
import '../utils/network_error_detector.dart';
import 'supabase_interceptor.dart';

/// Servicio para gestión de anteproyectos de TFG.
///
/// Proporciona operaciones CRUD y consultas especializadas sobre anteproyectos:
/// - Creación, edición y eliminación de anteproyectos
/// - Consultas por rol (estudiante, tutor, admin)
/// - Gestión de archivos adjuntos
/// - Envío de notificaciones por email
/// - Filtrado y búsqueda avanzada
///
/// ## Funcionalidades principales:
/// - CRUD completo de anteproyectos
/// - Consultas específicas por tutor con información de estudiantes
/// - Gestión de archivos adjuntos
/// - Búsqueda y filtrado por estado, tipo, año académico
/// - Notificaciones automáticas por email
///
/// ## Seguridad:
/// - Requiere autenticación: Sí
/// - Roles permitidos: Todos (con restricciones por RLS)
/// - Políticas RLS aplicadas: Los usuarios solo ven sus anteproyectos o los de sus estudiantes
///
/// ## Ejemplo de uso:
/// ```dart
/// final service = AnteprojectsService();
/// final anteprojects = await service.getAnteprojects();
/// ```
///
/// Ver también: [ApprovalService], [Anteproject]
class AnteprojectsService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  /// Obtiene todos los anteproyectos del usuario actual.
  ///
  /// Retorna:
  /// - Lista de [Anteproject] ordenados por fecha de creación (más recientes primero)
  ///
  /// Lanza:
  /// - [AuthenticationException] si no hay usuario autenticado
  /// - [DatabaseException] si falla la consulta
  Future<List<Anteproject>> getAnteprojects() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage:
              'User not authenticated when trying to get anteprojects',
        );
      }

      // Obtener anteproyectos según el rol del usuario
      final response = await _supabase
          .from('anteprojects')
          .select()
          .order('created_at', ascending: false);

      return response.map<Anteproject>(Anteproject.fromJson).toList();
    } catch (e) {
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
        technicalMessage: 'Error getting anteprojects: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene anteproyectos con información de estudiantes (solo para tutores).
  ///
  /// Retorna:
  /// - Lista de mapas con anteproyectos y datos de estudiantes asignados al tutor
  ///
  /// Lanza:
  /// - [AuthenticationException] si no hay usuario autenticado
  /// - [DatabaseException] si falla la consulta
  Future<List<Map<String, dynamic>>> getAnteprojectsWithStudentInfo() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage:
              'User not authenticated when trying to get anteprojects with student info',
        );
      }

      debugPrint(
        '🔍 AnteprojectsService: Obteniendo anteproyectos con info de estudiantes para tutor: ${user.email}',
      );

      // Primero obtener el ID del tutor desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final tutorId = userResponse['id'] as int;
      debugPrint('🔍 AnteprojectsService: ID del tutor: $tutorId');

      // Obtener anteproyectos asignados a este tutor
      // Filtramos por tutor_id directamente en anteprojects
      // Usamos relaciones opcionales para no excluir anteproyectos sin estudiantes
      final response = await _supabase
          .from('anteprojects')
          .select('''
            *,
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
          ''')
          .eq('tutor_id', tutorId)
          .order('created_at', ascending: false);

      debugPrint(
        '🔍 AnteprojectsService: Respuesta de anteproyectos: ${response.length} encontrados',
      );

      // Función auxiliar para convertir objetos minificados de Supabase
      Map<String, dynamic> safeConvertMap(dynamic data) {
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map) {
          // Iterar sobre las claves manualmente para evitar problemas con objetos minificados
          final result = <String, dynamic>{};
          for (final key in data.keys) {
            final value = data[key];
            result[key.toString()] = value;
          }
          return result;
        } else {
          // Último recurso: intentar casting
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

      // Convertir cada item a Map<String, dynamic> para evitar problemas de tipos
      final result = <Map<String, dynamic>>[];
      for (final item in response) {
        try {
          // Convertir el item principal usando la función segura
          final itemMap = safeConvertMap(item);

          // Si el mapa está vacío, saltar este item
          if (itemMap.isEmpty) {
            debugPrint('⚠️ Item vacío después de conversión, saltando...');
            continue;
          }

          // Debug: verificar estructura de datos
          debugPrint('🔍 Procesando anteproyecto ID: ${itemMap['id']}');
          debugPrint(
            '🔍 Tiene anteproject_students: ${itemMap.containsKey('anteproject_students')}',
          );

          // Verificar que los datos anidados también sean Maps válidos
          if (itemMap.containsKey('anteproject_students')) {
            final students = itemMap['anteproject_students'];
            debugPrint(
              '🔍 Tipo de anteproject_students: ${students.runtimeType}',
            );
            debugPrint('🔍 Valor de anteproject_students: $students');

            if (students != null && students is List) {
              // Convertir cada estudiante a Map si es necesario
              final studentsList = students
                  .map((s) {
                    try {
                      final studentMap = safeConvertMap(s);

                      // Debug: verificar estructura del estudiante
                      debugPrint('🔍 Estudiante procesado: $studentMap');

                      // Convertir el campo 'users' si existe
                      if (studentMap.containsKey('users') &&
                          studentMap['users'] != null) {
                        final usersData = studentMap['users'];
                        debugPrint(
                          '🔍 Tipo de users: ${usersData.runtimeType}',
                        );
                        debugPrint('🔍 Valor de users: $usersData');
                        studentMap['users'] = safeConvertMap(usersData);
                        debugPrint(
                          '🔍 Users convertido: ${studentMap['users']}',
                        );
                      }

                      return studentMap;
                    } catch (e) {
                      debugPrint(
                        '⚠️ Error convirtiendo estudiante en getAnteprojectsWithStudentInfo: $e',
                      );
                      return <String, dynamic>{};
                    }
                  })
                  .where((s) => s.isNotEmpty)
                  .toList();

              itemMap['anteproject_students'] = studentsList;
              debugPrint(
                '🔍 Lista final de estudiantes: ${studentsList.length} estudiantes',
              );
            } else if (students == null) {
              debugPrint(
                '⚠️ anteproject_students es null para anteproyecto ${itemMap['id']}',
              );
            }
          } else {
            debugPrint(
              '⚠️ No se encontró anteproject_students en anteproyecto ${itemMap['id']}',
            );
          }

          result.add(itemMap);
        } catch (e) {
          debugPrint(
            '❌ Error procesando anteproyecto en getAnteprojectsWithStudentInfo: $e',
          );
          debugPrint('   Tipo del item: ${item.runtimeType}');
          debugPrint('   Item: $item');
          // Continuar con el siguiente item en lugar de fallar completamente
        }
      }

      debugPrint(
        '✅ ${result.length} anteproyectos procesados correctamente con info de estudiantes',
      );
      return result;
    } catch (e) {
      debugPrint('❌ AnteprojectsService: Error al obtener anteproyectos: $e');

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
        technicalMessage: 'Error getting anteprojects with student info: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene un anteproyecto específico por ID
  Future<Anteproject?> getAnteproject(int id) async {
    try {
      debugPrint('🔍 Obteniendo anteproyecto ID: $id');

      final response = await _supabase
          .from('anteprojects')
          .select()
          .eq('id', id)
          .single();

      debugPrint('🔍 Respuesta recibida, tipo: ${response.runtimeType}');

      // Conversión robusta a Map<String, dynamic>
      // Crear un nuevo mapa iterando sobre las claves para evitar problemas de tipo
      Map<String, dynamic> anteprojectData = <String, dynamic>{};
      try {
        final responseMap = response as Map;
        for (final key in responseMap.keys) {
          anteprojectData[key.toString()] = responseMap[key];
        }
      } catch (e) {
        debugPrint('⚠️ Error en conversión, intentando método alternativo: $e');
        // Método alternativo: usar Map.from con conversión explícita
        anteprojectData = Map<String, dynamic>.from(
          Map<dynamic, dynamic>.from(response as Map),
        );
      }

      debugPrint('🔍 Datos convertidos a Map, parseando...');
      debugPrint(
        '🔍 project_type en datos: ${anteprojectData['project_type']}',
      );

      // Normalizar expected_results si existe (puede venir como objeto minificado)
      if (anteprojectData.containsKey('expected_results')) {
        final expectedResultsRaw = anteprojectData['expected_results'];
        debugPrint(
          '🔍 expected_results tipo: ${expectedResultsRaw.runtimeType}',
        );
        debugPrint('🔍 expected_results valor: $expectedResultsRaw');

        if (expectedResultsRaw != null) {
          if (expectedResultsRaw is Map<String, dynamic>) {
            // Ya está en el formato correcto
            anteprojectData['expected_results'] = expectedResultsRaw;
          } else if (expectedResultsRaw is Map) {
            // Convertir objeto minificado a Map<String, dynamic>
            final normalizedExpectedResults = <String, dynamic>{};
            for (final key in expectedResultsRaw.keys) {
              final value = expectedResultsRaw[key];
              if (value is Map) {
                // Normalizar valores anidados (hitos con title y description)
                final normalizedValue = <String, dynamic>{};
                for (final innerKey in value.keys) {
                  normalizedValue[innerKey.toString()] = value[innerKey];
                }
                normalizedExpectedResults[key.toString()] = normalizedValue;
              } else {
                normalizedExpectedResults[key.toString()] = value;
              }
            }
            anteprojectData['expected_results'] = normalizedExpectedResults;
            debugPrint(
              '🔍 expected_results normalizado: $normalizedExpectedResults',
            );
          } else {
            debugPrint(
              '⚠️ expected_results no es un Map, tipo: ${expectedResultsRaw.runtimeType}',
            );
            anteprojectData['expected_results'] = <String, dynamic>{};
          }
        } else {
          anteprojectData['expected_results'] = <String, dynamic>{};
        }
      } else {
        debugPrint('⚠️ No se encontró expected_results en los datos');
        anteprojectData['expected_results'] = <String, dynamic>{};
      }

      // Normalizar timeline de la misma manera
      if (anteprojectData.containsKey('timeline')) {
        final timelineRaw = anteprojectData['timeline'];
        if (timelineRaw is Map) {
          final normalizedTimeline = <String, dynamic>{};
          for (final key in timelineRaw.keys) {
            normalizedTimeline[key.toString()] = timelineRaw[key];
          }
          anteprojectData['timeline'] = normalizedTimeline;
        } else if (timelineRaw == null) {
          anteprojectData['timeline'] = <String, dynamic>{};
        }
      } else {
        anteprojectData['timeline'] = <String, dynamic>{};
      }

      // Asegurar que github_repository_url existe (por si la migración no se ha ejecutado aún)
      if (!anteprojectData.containsKey('github_repository_url')) {
        anteprojectData['github_repository_url'] = null;
        debugPrint('⚠️ Campo github_repository_url no encontrado en BD, usando null por defecto');
      }

      // Usar directamente los datos convertidos, ya que Anteproject.fromJson espera snake_case
      // El modelo tiene @JsonKey para mapear automáticamente
      final anteproject = Anteproject.fromJson(anteprojectData);
      debugPrint('✅ Anteproyecto parseado correctamente: ${anteproject.title}');
      debugPrint(
        '🔍 expectedResults después del parseo: ${anteproject.expectedResults}',
      );
      debugPrint(
        '🔍 expectedResults cantidad: ${anteproject.expectedResults.length}',
      );

      return anteproject;
    } catch (e) {
      debugPrint('❌ Error al obtener anteproyecto ID $id: $e');
      debugPrint('   Tipo del error: ${e.runtimeType}');
      debugPrint('   Stack trace: ${StackTrace.current}');

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
        technicalMessage: 'Error getting anteproject: $e',
        originalError: e,
      );
    }
  }

  /// Crea un nuevo anteproyecto
  Future<Anteproject> createAnteproject(Anteproject anteproject) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // ignore: avoid_print
      print('🔍 Debug - Creando anteproyecto: ${anteproject.title}');

      // Obtener información del usuario actual desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id, role, tutor_id')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;
      final userRole = userResponse['role'] as String;
      final tutorId = userResponse['tutor_id'] as int?;

      // Verificar si el estudiante ya tiene un anteproyecto aprobado
      if (userRole == 'student') {
        final hasApproved = await hasApprovedAnteproject();
        if (hasApproved) {
          throw ValidationException(
            'cannot_create_anteproject_with_approved',
            technicalMessage:
                'No puedes crear un nuevo anteproyecto porque ya tienes uno aprobado. Debes desarrollar el proyecto asociado.',
          );
        }
      }

      // ignore: avoid_print
      print('🔍 Debug - Usuario: ID=$userId, Role=$userRole, TutorID=$tutorId');

      final data = anteproject.toJson();
      // ignore: avoid_print
      print('🔍 Debug - Datos originales: $data');

      // Remover campos que se generan automáticamente
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      data.remove('submitted_at');
      data.remove('reviewed_at');

      // Asegurar que objectives se incluya si existe
      if (anteproject.objectives != null) {
        data['objectives'] = anteproject.objectives;
      }

      // Asignar tutor automáticamente
      if (userRole == 'student' && tutorId != null) {
        data['tutor_id'] = tutorId;
        // ignore: avoid_print
        print('🔍 Debug - Tutor asignado automáticamente: $tutorId');
      } else if (userRole == 'tutor') {
        data['tutor_id'] = userId;
        // ignore: avoid_print
        print('🔍 Debug - Tutor es el usuario actual: $userId');
      }

      // ignore: avoid_print
      print('🔍 Debug - Datos para insertar: $data');

      final response = await _supabase
          .from('anteprojects')
          .insert(data)
          .select()
          .single();

      final createdAnteproject = Anteproject.fromJson(response);
      final anteprojectId = createdAnteproject.id;

      // ignore: avoid_print
      print('✅ Debug - Anteproyecto creado exitosamente: $anteprojectId');

      // Si es un estudiante, crear la relación en anteproject_students
      if (userRole == 'student') {
        try {
          await _supabase.from('anteproject_students').insert({
            'anteproject_id': anteprojectId,
            'student_id': userId,
            'is_lead_author': true,
            'created_at': DateTime.now().toIso8601String(),
          });
          // ignore: avoid_print
          print('✅ Debug - Relación estudiante-anteproyecto creada');
        } catch (e) {
          // ignore: avoid_print
          print(
            '⚠️ Debug - Error al crear relación estudiante-anteproyecto: $e',
          );
          // No fallar si no se puede crear la relación
        }
      }

      return createdAnteproject;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Debug - Error al crear anteproyecto: $e');
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
        technicalMessage: 'Error creating anteproject: $e',
        originalError: e,
      );
    }
  }

  /// Actualiza un anteproyecto existente
  Future<Anteproject> updateAnteproject(int id, Anteproject anteproject) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Obtener el rol del usuario
      final userResponse = await _supabase
          .from('users')
          .select('role')
          .eq('email', user.email!)
          .single();
      final userRole = userResponse['role'] as String;

      // Verificar si el estudiante ya tiene un anteproyecto aprobado
      if (userRole == 'student') {
        final hasApproved = await hasApprovedAnteproject();
        if (hasApproved) {
          throw ValidationException(
            'cannot_edit_anteproject_with_approved',
            technicalMessage:
                'No puedes editar anteproyectos porque ya tienes uno aprobado. Debes desarrollar el proyecto asociado.',
          );
        }
      }

      final data = anteproject.toJson();
      // Remover campos que no se pueden actualizar
      data.remove('id');
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();

      // Asegurar que objectives se incluya si existe
      if (anteproject.objectives != null) {
        data['objectives'] = anteproject.objectives;
      }

      // Manejar github_repository_url: si es null y la columna no existe, no incluirlo
      // Esto evita errores si la migración no se ha ejecutado aún
      if (data.containsKey('github_repository_url') && 
          data['github_repository_url'] == null) {
        // Mantener el campo null si la columna existe, pero no fallará si no existe
        // La migración debe ejecutarse para que funcione correctamente
      }

      // Asegurar que expected_results se incluya correctamente
      debugPrint(
        '🔍 Actualizando anteproyecto - expectedResults: ${anteproject.expectedResults}',
      );
      debugPrint(
        '🔍 Actualizando anteproyecto - expectedResults tipo: ${anteproject.expectedResults.runtimeType}',
      );
      debugPrint(
        '🔍 Actualizando anteproyecto - expectedResults cantidad: ${anteproject.expectedResults.length}',
      );
      if (anteproject.expectedResults.isNotEmpty) {
        data['expected_results'] = anteproject.expectedResults;
      } else {
        data['expected_results'] = <String, dynamic>{};
      }

      // Asegurar que timeline se incluya correctamente
      if (anteproject.timeline.isNotEmpty) {
        data['timeline'] = anteproject.timeline;
      } else {
        data['timeline'] = <String, dynamic>{};
      }

      debugPrint('🔍 Datos a actualizar: ${data.keys.toList()}');
      debugPrint('🔍 expected_results en data: ${data['expected_results']}');

      final response = await _supabase
          .from('anteprojects')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      debugPrint(
        '🔍 Respuesta después de actualizar: ${response['expected_results']}',
      );

      // Normalizar la respuesta antes de parsearla
      final Map<String, dynamic> responseData = <String, dynamic>{};
      for (final key in (response as Map).keys) {
        responseData[key.toString()] = response[key];
      }

      // Normalizar expected_results en la respuesta
      if (responseData.containsKey('expected_results')) {
        final expectedResultsRaw = responseData['expected_results'];
        if (expectedResultsRaw is Map) {
          final normalizedExpectedResults = <String, dynamic>{};
          for (final key in expectedResultsRaw.keys) {
            final value = expectedResultsRaw[key];
            if (value is Map) {
              final normalizedValue = <String, dynamic>{};
              for (final innerKey in value.keys) {
                normalizedValue[innerKey.toString()] = value[innerKey];
              }
              normalizedExpectedResults[key.toString()] = normalizedValue;
            } else {
              normalizedExpectedResults[key.toString()] = value;
            }
          }
          responseData['expected_results'] = normalizedExpectedResults;
        } else if (expectedResultsRaw == null) {
          responseData['expected_results'] = <String, dynamic>{};
        }
      }

      return Anteproject.fromJson(responseData);
    } catch (e) {
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
        technicalMessage: 'Error updating anteproject: $e',
        originalError: e,
      );
    }
  }

  /// Envía un anteproyecto para revisión
  Future<void> submitAnteproject(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Obtener información del usuario actual desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id, role')
          .eq('email', user.email!)
          .single();

      final userRole = userResponse['role'] as String;

      // Verificar si el estudiante ya tiene un anteproyecto aprobado
      if (userRole == 'student') {
        final hasApproved = await hasApprovedAnteproject();
        if (hasApproved) {
          throw ValidationException(
            'cannot_submit_anteproject_with_approved',
            technicalMessage:
                'No puedes enviar este anteproyecto porque ya tienes uno aprobado. Debes desarrollar el proyecto asociado.',
          );
        }
      }

      await _supabase
          .from('anteprojects')
          .update({
            'status': 'submitted',
            'submitted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      // Enviar notificación al tutor
      await _notifyTutorOnSubmission(id);
    } catch (e) {
      // Interceptar errores de Supabase
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
      );
    }
  }

  /// Alias para submitAnteproject (para compatibilidad con el frontend)
  Future<void> submitAnteprojectForApproval(int id) async {
    return submitAnteproject(id);
  }

  /// Aprueba un anteproyecto (solo tutores)
  Future<void> approveAnteproject(
    int id,
    String comments, {
    Map<String, dynamic>? timeline,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Obtener información del anteproyecto antes de aprobarlo
      final anteprojectResponse = await _supabase
          .from('anteprojects')
          .select('title, description, tutor_id')
          .eq('id', id)
          .single();

      final anteprojectTitle = anteprojectResponse['title'] as String;
      final anteprojectDescription =
          anteprojectResponse['description'] as String?;
      final tutorId = anteprojectResponse['tutor_id'] as int;

      // Preparar datos de actualización
      final updateData = <String, dynamic>{
        'status': 'approved',
        'reviewed_at': DateTime.now().toIso8601String(),
        'tutor_comments': comments,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Si se proporciona un timeline, agregarlo
      if (timeline != null && timeline.isNotEmpty) {
        updateData['timeline'] = timeline;
      }

      // Aprobar el anteproyecto
      await _supabase.from('anteprojects').update(updateData).eq('id', id);

      // Crear proyecto automáticamente basado en el anteproyecto aprobado
      await _createProjectFromAnteproject(
        anteprojectId: id,
        title: anteprojectTitle,
        description: anteprojectDescription ?? '',
        tutorId: tutorId,
      );
    } catch (e) {
      // Interceptar errores de Supabase
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
      );
    }
  }

  /// Rechaza un anteproyecto (solo tutores)
  Future<void> rejectAnteproject(int id, String comments) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      await _supabase
          .from('anteprojects')
          .update({
            'status': 'rejected',
            'reviewed_at': DateTime.now().toIso8601String(),
            'tutor_comments': comments,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      // Interceptar errores de Supabase
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
      );
    }
  }

  /// Obtiene anteproyectos por estado
  Future<List<Anteproject>> getAnteprojectsByStatus(
    AnteprojectStatus status,
  ) async {
    try {
      final response = await _supabase
          .from('anteprojects')
          .select()
          .eq('status', status.name)
          .order('created_at', ascending: false);

      return response.map<Anteproject>(Anteproject.fromJson).toList();
    } catch (e) {
      throw AnteprojectsException(
        'Error al obtener anteproyectos por estado: $e',
      );
    }
  }

  /// Obtiene anteproyectos del tutor actual
  /// Obtiene anteproyectos del tutor con información de estudiantes
  /// Retorna una lista de mapas que incluyen el anteproyecto y la información del estudiante
  Future<List<Map<String, dynamic>>> getTutorAnteprojects() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Primero obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final tutorId = userResponse['id'] as int;
      debugPrint('🔍 Obteniendo anteproyectos para tutor ID: $tutorId');

      // Obtener anteproyectos con información de estudiantes
      // Usamos relación opcional (sin !inner) para no excluir anteproyectos sin estudiantes
      final response = await _supabase
          .from('anteprojects')
          .select('''
            *,
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
          ''')
          .eq('tutor_id', tutorId)
          .order('created_at', ascending: false);

      debugPrint(
        '🔍 Respuesta de anteproyectos del tutor: ${response.length} encontrados',
      );

      // Debug: imprimir la respuesta cruda de Supabase
      if (response.isNotEmpty) {
        final firstItem = response[0];
        debugPrint('🔍 DEBUG RAW - Primer anteproyecto crudo: $firstItem');
        debugPrint(
          '🔍 DEBUG RAW - Tipo del primer item: ${firstItem.runtimeType}',
        );
        final firstMap = firstItem as Map;
        debugPrint(
          '🔍 DEBUG RAW - Claves del primer item: ${firstMap.keys.toList()}',
        );
        if (firstMap.containsKey('anteproject_students')) {
          debugPrint(
            '🔍 DEBUG RAW - anteproject_students existe: ${firstMap['anteproject_students']}',
          );
          debugPrint(
            '🔍 DEBUG RAW - Tipo de anteproject_students: ${firstMap['anteproject_students'].runtimeType}',
          );
        } else {
          debugPrint(
            '⚠️ DEBUG RAW - NO se encontró anteproject_students en la respuesta cruda',
          );
        }
      }

      // Convertir cada item a Map<String, dynamic> para evitar problemas de tipos
      // Mantener las relaciones anidadas para que el frontend pueda usarlas
      final result = <Map<String, dynamic>>[];
      for (final item in response) {
        try {
          // Función auxiliar para convertir objetos minificados de Supabase
          Map<String, dynamic> safeConvertMap(dynamic data) {
            if (data is Map<String, dynamic>) {
              return data;
            } else if (data is Map) {
              // Iterar sobre las claves manualmente para evitar problemas con objetos minificados
              final result = <String, dynamic>{};
              for (final key in data.keys) {
                final value = data[key];
                result[key.toString()] = value;
              }
              return result;
            } else {
              // Último recurso: intentar casting
              try {
                final map = data as Map;
                final result = <String, dynamic>{};
                for (final key in map.keys) {
                  result[key.toString()] = map[key];
                }
                return result;
              } catch (e) {
                debugPrint(
                  '⚠️ No se pudo convertir objeto: ${data.runtimeType}',
                );
                return <String, dynamic>{};
              }
            }
          }

          // Convertir el item principal usando la función segura
          final itemMap = safeConvertMap(item);

          // Si el mapa está vacío, saltar este item
          if (itemMap.isEmpty) {
            debugPrint('⚠️ Item vacío después de conversión, saltando...');
            continue;
          }

          // Debug: verificar estructura de datos
          debugPrint(
            '🔍 getTutorAnteprojects - Procesando anteproyecto ID: ${itemMap['id']}',
          );
          debugPrint(
            '🔍 getTutorAnteprojects - Tiene anteproject_students: ${itemMap.containsKey('anteproject_students')}',
          );

          // Verificar que los datos anidados también sean Maps válidos
          if (itemMap.containsKey('anteproject_students')) {
            final students = itemMap['anteproject_students'];
            debugPrint(
              '🔍 getTutorAnteprojects - Tipo de anteproject_students: ${students.runtimeType}',
            );
            debugPrint(
              '🔍 getTutorAnteprojects - Valor de anteproject_students: $students',
            );

            if (students != null && students is List) {
              debugPrint(
                '🔍 getTutorAnteprojects - Lista tiene ${students.length} estudiantes',
              );

              // Convertir cada estudiante a Map si es necesario
              final studentsList = students
                  .map((s) {
                    try {
                      final studentMap = safeConvertMap(s);
                      debugPrint(
                        '🔍 getTutorAnteprojects - Estudiante procesado: $studentMap',
                      );

                      // Convertir el campo 'users' si existe
                      if (studentMap.containsKey('users') &&
                          studentMap['users'] != null) {
                        final usersData = studentMap['users'];
                        debugPrint(
                          '🔍 getTutorAnteprojects - Tipo de users: ${usersData.runtimeType}',
                        );
                        debugPrint(
                          '🔍 getTutorAnteprojects - Valor de users: $usersData',
                        );
                        final usersMap = safeConvertMap(usersData);

                        // Normalizar el ID a número de forma robusta
                        if (usersMap.containsKey('id') &&
                            usersMap['id'] != null) {
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
                              debugPrint(
                                '⚠️ No se pudo convertir ID: $idValue (tipo: ${idValue.runtimeType})',
                              );
                            }
                          }
                        }

                        // Normalizar tutor_id si existe
                        if (usersMap.containsKey('tutor_id') &&
                            usersMap['tutor_id'] != null) {
                          final tutorIdValue = usersMap['tutor_id'];
                          if (tutorIdValue is int) {
                            usersMap['tutor_id'] = tutorIdValue;
                          } else if (tutorIdValue is num) {
                            usersMap['tutor_id'] = tutorIdValue.toInt();
                          } else {
                            final parsedTutorId = int.tryParse(
                              tutorIdValue.toString(),
                            );
                            if (parsedTutorId != null) {
                              usersMap['tutor_id'] = parsedTutorId;
                            } else {
                              usersMap['tutor_id'] = null;
                            }
                          }
                        }

                        studentMap['users'] = usersMap;
                        debugPrint(
                          '🔍 getTutorAnteprojects - Users convertido: ${studentMap['users']}',
                        );
                      } else {
                        debugPrint(
                          '⚠️ getTutorAnteprojects - No se encontró campo "users" en estudiante',
                        );
                      }

                      return studentMap;
                    } catch (e) {
                      debugPrint('⚠️ Error convirtiendo estudiante: $e');
                      return <String, dynamic>{};
                    }
                  })
                  .where((s) => s.isNotEmpty)
                  .toList();

              itemMap['anteproject_students'] = studentsList;
              debugPrint(
                '🔍 getTutorAnteprojects - Lista final de estudiantes: ${studentsList.length} estudiantes',
              );
            } else if (students == null) {
              debugPrint(
                '⚠️ getTutorAnteprojects - anteproject_students es null para anteproyecto ${itemMap['id']}',
              );
            } else {
              debugPrint(
                '⚠️ getTutorAnteprojects - anteproject_students no es una lista: ${students.runtimeType}',
              );
            }
          } else {
            debugPrint(
              '⚠️ getTutorAnteprojects - No se encontró anteproject_students en anteproyecto ${itemMap['id']}',
            );
          }

          result.add(itemMap);
        } catch (e) {
          debugPrint('❌ Error procesando anteproyecto del tutor: $e');
          debugPrint('   Tipo del item: ${item.runtimeType}');
          debugPrint('   Item: $item');
          // Continuar con el siguiente item en lugar de fallar completamente
        }
      }

      debugPrint(
        '✅ ${result.length} anteproyectos procesados correctamente para el tutor',
      );
      return result;
    } catch (e) {
      debugPrint('❌ Error al obtener anteproyectos del tutor: $e');
      throw AnteprojectsException(
        'Error al obtener anteproyectos del tutor: $e',
      );
    }
  }

  /// Obtiene anteproyectos del estudiante actual
  Future<List<Anteproject>> getStudentAnteprojects() async {
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

      debugPrint('🔍 Obteniendo anteproyectos para estudiante ID: $userId');

      // CAMBIO: Usar relación anidada en lugar de dos consultas
      // Esta es la misma estrategia que usa getStudentProjects() que funciona correctamente
      final response = await _supabase
          .from('anteproject_students')
          .select('''
            anteproject_id,
            anteprojects!inner(*)
          ''')
          .eq('student_id', userId);

      debugPrint('🔍 Respuesta de anteproject_students: ${response.length} encontrados');

      // Convertir la respuesta a List<Anteproject>
      final anteprojects = <Anteproject>[];
      for (final item in response) {
        try {
          if (item['anteprojects'] != null) {
            // Asegurar que el item sea un Map<String, dynamic>
            final itemMap = Map<String, dynamic>.from(item);
            final anteprojectData = itemMap['anteprojects'];
            
            // Convertir a Map<String, dynamic> si es necesario
            Map<String, dynamic> anteprojectMap;
            if (anteprojectData is Map<String, dynamic>) {
              anteprojectMap = anteprojectData;
            } else if (anteprojectData is Map) {
              // Convertir objeto minificado a Map<String, dynamic>
              anteprojectMap = <String, dynamic>{};
              for (final key in anteprojectData.keys) {
                anteprojectMap[key.toString()] = anteprojectData[key];
              }
            } else {
              debugPrint('⚠️ anteprojectData no es un Map: ${anteprojectData.runtimeType}');
              continue;
            }
            
            // Normalizar campos JSON anidados si es necesario
            if (anteprojectMap.containsKey('expected_results') && 
                anteprojectMap['expected_results'] is Map) {
              final expectedResultsRaw = anteprojectMap['expected_results'] as Map;
              final normalizedExpectedResults = <String, dynamic>{};
              for (final key in expectedResultsRaw.keys) {
                final value = expectedResultsRaw[key];
                if (value is Map) {
                  final normalizedValue = <String, dynamic>{};
                  for (final innerKey in value.keys) {
                    normalizedValue[innerKey.toString()] = value[innerKey];
                  }
                  normalizedExpectedResults[key.toString()] = normalizedValue;
                } else {
                  normalizedExpectedResults[key.toString()] = value;
                }
              }
              anteprojectMap['expected_results'] = normalizedExpectedResults;
            }
            
            if (anteprojectMap.containsKey('timeline') && 
                anteprojectMap['timeline'] is Map) {
              final timelineRaw = anteprojectMap['timeline'] as Map;
              final normalizedTimeline = <String, dynamic>{};
              for (final key in timelineRaw.keys) {
                normalizedTimeline[key.toString()] = timelineRaw[key];
              }
              anteprojectMap['timeline'] = normalizedTimeline;
            }
            
            debugPrint('🔍 Parseando anteproyecto: ${anteprojectMap['title']}');
            debugPrint('🔍 github_repository_url: ${anteprojectMap['github_repository_url']}');
            
            final anteproject = Anteproject.fromJson(anteprojectMap);
            anteprojects.add(anteproject);
          }
        } catch (e, stackTrace) {
          debugPrint('❌ Error procesando anteproyecto: $e');
          debugPrint('   Stack trace: $stackTrace');
          debugPrint('   Tipo del item: ${item.runtimeType}');
          debugPrint('   Datos: $item');
          // Continuar con el siguiente anteproyecto
        }
      }

      // Ordenar por fecha de creación
      anteprojects.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint(
        '✅ ${anteprojects.length} anteproyectos procesados correctamente',
      );
      return anteprojects;
    } catch (e) {
      debugPrint('❌ Error al obtener anteproyectos del estudiante: $e');
      throw AnteprojectsException(
        'Error al obtener anteproyectos del estudiante: $e',
      );
    }
  }

  /// Verifica si el estudiante actual tiene un anteproyecto aprobado
  ///
  /// Retorna `true` si el estudiante tiene al menos un anteproyecto con estado 'approved'.
  /// Retorna `false` si no tiene ningún anteproyecto aprobado o si el usuario no es estudiante.
  ///
  /// Lanza:
  /// - [AuthenticationException] si no hay usuario autenticado
  /// - [DatabaseException] si falla la consulta
  Future<bool> hasApprovedAnteproject() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Obtener información del usuario actual desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id, role')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;
      final userRole = userResponse['role'] as String;

      // Solo verificar para estudiantes
      if (userRole != 'student') {
        return false;
      }

      debugPrint('🔍 Verificando si estudiante ID: $userId tiene anteproyecto aprobado');

      // Consultar anteproject_students unido con anteprojects
      // Filtrar por student_id del usuario actual y status = 'approved'
      final response = await _supabase
          .from('anteproject_students')
          .select('''
            anteproject_id,
            anteprojects!inner(
              id,
              status
            )
          ''')
          .eq('student_id', userId)
          .eq('anteprojects.status', 'approved');

      final hasApproved = response.isNotEmpty;
      debugPrint(
        '🔍 Estudiante ${hasApproved ? "SÍ" : "NO"} tiene anteproyecto aprobado',
      );

      return hasApproved;
    } catch (e) {
      debugPrint('❌ Error al verificar anteproyecto aprobado: $e');
      
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      // Si es AuthenticationException, relanzarla
      if (e is AuthenticationException) {
        rethrow;
      }

      throw DatabaseException(
        'database_query_failed',
        technicalMessage: 'Error checking approved anteproject: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene el estudiante autor de un anteproyecto
  Future<User?> getAnteprojectStudent(int anteprojectId) async {
    try {
      final response = await _supabase
          .from('anteproject_students')
          .select('''
            student_id,
            students:users!anteproject_students_student_id_fkey (
              id,
              full_name,
              email,
              role,
              nre,
              phone,
              biography,
              status,
              specialty,
              tutor_id,
              academic_year,
              created_at,
              updated_at
            )
          ''')
          .eq('anteproject_id', anteprojectId)
          .eq('is_lead_author', true)
          .single();

      if (response['students'] != null) {
        return User.fromJson(response['students']);
      }
      return null;
    } catch (e) {
      // Si no se encuentra el estudiante, retornar null
      return null;
    }
  }

  /// Notifica al tutor cuando un estudiante envía un anteproyecto
  Future<void> _notifyTutorOnSubmission(int anteprojectId) async {
    try {
      // Obtener información del anteproyecto
      final anteprojectResponse = await _supabase
          .from('anteprojects')
          .select('title, tutor_id')
          .eq('id', anteprojectId)
          .single();

      final anteprojectTitle = anteprojectResponse['title'] as String;
      final tutorId = anteprojectResponse['tutor_id'] as int;

      // Obtener información del tutor
      final tutorResponse = await _supabase
          .from('users')
          .select('full_name, email')
          .eq('id', tutorId)
          .single();

      final tutorName = tutorResponse['full_name'] as String;
      final tutorEmail = tutorResponse['email'] as String;

      // Obtener información del estudiante
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final studentResponse = await _supabase
            .from('users')
            .select('full_name')
            .eq('email', user.email!)
            .single();

        final studentName = studentResponse['full_name'] as String;

        // Enviar email de notificación al tutor
        await EmailNotificationService.sendTutorNotification(
          tutorEmail: tutorEmail,
          tutorName: tutorName,
          studentName: studentName,
          anteprojectTitle: anteprojectTitle,
          notificationType: 'submission',
          message:
              '$studentName ha enviado el anteproyecto "$anteprojectTitle" para revisión.',
          anteprojectUrl:
              'https://app.cifpcarlos3.es/anteprojects/$anteprojectId',
        );
      }
    } catch (e) {
      // No fallar si no se puede enviar la notificación
      debugPrint('Error al notificar al tutor: $e');
    }
  }

  /// Elimina un anteproyecto (solo estudiantes, solo en estado draft)
  Future<void> deleteAnteproject(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Obtener información del usuario actual
      final userResponse = await _supabase
          .from('users')
          .select('id, role')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;
      final userRole = userResponse['role'] as String;

      // Solo estudiantes pueden eliminar anteproyectos
      if (userRole != 'student') {
        throw const AnteprojectsException(
          'Solo los estudiantes pueden eliminar anteproyectos',
        );
      }

      // Verificar si el estudiante ya tiene un anteproyecto aprobado
      final hasApproved = await hasApprovedAnteproject();
      if (hasApproved) {
        throw ValidationException(
          'cannot_delete_anteproject_with_approved',
          technicalMessage:
              'No puedes eliminar anteproyectos porque ya tienes uno aprobado. Debes desarrollar el proyecto asociado.',
        );
      }

      // Verificar que el anteproyecto existe y está en estado draft
      final anteprojectResponse = await _supabase
          .from('anteprojects')
          .select('status')
          .eq('id', id)
          .single();

      final status = anteprojectResponse['status'] as String;
      if (status != 'draft') {
        throw const AnteprojectsException(
          'Solo se pueden eliminar anteproyectos en estado borrador',
        );
      }

      // Verificar que el estudiante es el autor del anteproyecto
      try {
        await _supabase
            .from('anteproject_students')
            .select('student_id')
            .eq('anteproject_id', id)
            .eq('student_id', userId)
            .single();
      } catch (e) {
        throw PermissionException(
          'access_denied',
          technicalMessage:
              'User does not have permission to delete this anteproject',
        );
      }

      // Eliminar relaciones primero
      await _supabase
          .from('anteproject_students')
          .delete()
          .eq('anteproject_id', id);

      // Eliminar comentarios
      await _supabase
          .from('anteproject_comments')
          .delete()
          .eq('anteproject_id', id);

      // Eliminar el anteproyecto
      await _supabase.from('anteprojects').delete().eq('id', id);

      // ignore: avoid_print
      print('✅ Debug - Anteproyecto eliminado exitosamente: $id');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Debug - Error al eliminar anteproyecto: $e');
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
        technicalMessage: 'Error deleting anteproject: $e',
        originalError: e,
      );
    }
  }

  /// Crea un proyecto automáticamente basado en un anteproyecto aprobado
  Future<void> _createProjectFromAnteproject({
    required int anteprojectId,
    required String title,
    required String description,
    required int tutorId,
  }) async {
    try {
      // Verificar si ya existe un proyecto para este anteproyecto
      final existingProject = await _supabase
          .from('projects')
          .select('id')
          .eq('anteproject_id', anteprojectId)
          .maybeSingle();

      if (existingProject != null) {
        debugPrint(
          '⚠️ Ya existe un proyecto (ID: ${existingProject['id']}) para el anteproyecto: $anteprojectId',
        );
        // Actualizar el project_id en el anteproyecto si no está actualizado
        await _supabase
            .from('anteprojects')
            .update({'project_id': existingProject['id']})
            .eq('id', anteprojectId);
        return;
      }

      // Obtener el estudiante autor del anteproyecto
      final studentResponse = await _supabase
          .from('anteproject_students')
          .select('student_id')
          .eq('anteproject_id', anteprojectId)
          .eq('is_lead_author', true)
          .maybeSingle();

      if (studentResponse == null) {
        debugPrint(
          '⚠️ No se encontró estudiante autor para el anteproyecto: $anteprojectId',
        );
        // Crear proyecto sin estudiante asignado (el tutor puede asignarlo después)
      }

      final studentId = studentResponse?['student_id'] as int?;

      // Crear el proyecto con la referencia al anteproyecto
      final projectData = {
        'title': title,
        'description': description,
        'tutor_id': tutorId,
        'anteproject_id': anteprojectId, // Vincular con el anteproyecto
        'status': 'planning', // Estado inicial: planning
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final projectResponse = await _supabase
          .from('projects')
          .insert(projectData)
          .select()
          .single();

      final projectId = projectResponse['id'] as int;

      // Actualizar el project_id en el anteproyecto para vincularlos
      await _supabase
          .from('anteprojects')
          .update({
            'project_id': projectId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', anteprojectId);

      // Crear la relación estudiante-proyecto si existe estudiante
      if (studentId != null) {
        try {
          await _supabase.from('project_students').insert({
            'project_id': projectId,
            'student_id': studentId,
            'is_lead': true, // Usar is_lead en lugar de is_lead_student
            'joined_at': DateTime.now().toIso8601String(),
          });
          debugPrint(
            '✅ Relación estudiante-proyecto creada: estudiante $studentId -> proyecto $projectId',
          );
        } catch (e) {
          debugPrint('⚠️ Error al crear relación estudiante-proyecto: $e');
          // No fallar si no se puede crear la relación
        }
      }

      debugPrint(
        '✅ Proyecto creado automáticamente: $projectId para anteproyecto: $anteprojectId',
      );
    } catch (e) {
      debugPrint('❌ Error al crear proyecto desde anteproyecto: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
      // No fallar la aprobación si no se puede crear el proyecto
      // El tutor puede crear el proyecto manualmente después
    }
  }

  /// Obtiene los estudiantes asignados a un anteproyecto específico
  Future<List<User>> getAnteprojectStudents(int anteprojectId) async {
    try {
      debugPrint(
        '🔍 Obteniendo estudiantes del anteproyecto ID: $anteprojectId',
      );

      final response = await _supabase
          .from('anteproject_students')
          .select('''
            student_id,
            users!inner(*)
          ''')
          .eq('anteproject_id', anteprojectId);

      debugPrint('🔍 Respuesta de anteproject_students: $response');

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
      debugPrint('❌ Error obteniendo estudiantes del anteproyecto: $e');
      throw AnteprojectsException('Error al obtener estudiantes: $e');
    }
  }
}

/// Excepción personalizada para errores de anteproyectos
class AnteprojectsException implements Exception {
  final String message;

  const AnteprojectsException(this.message);

  @override
  String toString() => 'AnteprojectsException: $message';
}
