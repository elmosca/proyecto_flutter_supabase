import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/models.dart';

class AnteprojectsService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  /// Obtiene todos los anteproyectos del usuario actual
  Future<List<Anteproject>> getAnteprojects() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AnteprojectsException('Usuario no autenticado');
      }

      // Obtener anteproyectos según el rol del usuario
      final response = await _supabase
          .from('anteprojects')
          .select()
          .order('created_at', ascending: false);

      return response.map<Anteproject>(Anteproject.fromJson).toList();
    } catch (e) {
      throw AnteprojectsException('Error al obtener anteproyectos: $e');
    }
  }

  /// Obtiene un anteproyecto específico por ID
  Future<Anteproject?> getAnteproject(int id) async {
    try {
      final response = await _supabase
          .from('anteprojects')
          .select()
          .eq('id', id)
          .single();

      return Anteproject.fromJson(response);
    } catch (e) {
      throw AnteprojectsException('Error al obtener anteproyecto: $e');
    }
  }

  /// Crea un nuevo anteproyecto
  Future<Anteproject> createAnteproject(Anteproject anteproject) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AnteprojectsException('Usuario no autenticado');
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
          await _supabase
              .from('anteproject_students')
              .insert({
                'anteproject_id': anteprojectId,
                'student_id': userId,
                'is_lead_author': true,
                'created_at': DateTime.now().toIso8601String(),
              });
          // ignore: avoid_print
          print('✅ Debug - Relación estudiante-anteproyecto creada');
        } catch (e) {
          // ignore: avoid_print
          print('⚠️ Debug - Error al crear relación estudiante-anteproyecto: $e');
          // No fallar si no se puede crear la relación
        }
      }

      return createdAnteproject;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Debug - Error al crear anteproyecto: $e');
      throw AnteprojectsException('Error al crear anteproyecto: $e');
    }
  }

  /// Actualiza un anteproyecto existente
  Future<Anteproject> updateAnteproject(int id, Anteproject anteproject) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AnteprojectsException('Usuario no autenticado');
      }

      final data = anteproject.toJson();
      // Remover campos que no se pueden actualizar
      data.remove('id');
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('anteprojects')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Anteproject.fromJson(response);
    } catch (e) {
      throw AnteprojectsException('Error al actualizar anteproyecto: $e');
    }
  }

  /// Envía un anteproyecto para revisión
  Future<void> submitAnteproject(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AnteprojectsException('Usuario no autenticado');
      }

      await _supabase
          .from('anteprojects')
          .update({
            'status': 'submitted',
            'submitted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw AnteprojectsException('Error al enviar anteproyecto: $e');
    }
  }

  /// Alias para submitAnteproject (para compatibilidad con el frontend)
  Future<void> submitAnteprojectForApproval(int id) async {
    return submitAnteproject(id);
  }

  /// Aprueba un anteproyecto (solo tutores)
  Future<void> approveAnteproject(int id, String comments) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AnteprojectsException('Usuario no autenticado');
      }

      await _supabase
          .from('anteprojects')
          .update({
            'status': 'approved',
            'reviewed_at': DateTime.now().toIso8601String(),
            'tutor_comments': comments,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw AnteprojectsException('Error al aprobar anteproyecto: $e');
    }
  }

  /// Rechaza un anteproyecto (solo tutores)
  Future<void> rejectAnteproject(int id, String comments) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AnteprojectsException('Usuario no autenticado');
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
      throw AnteprojectsException('Error al rechazar anteproyecto: $e');
    }
  }

  /// Obtiene anteproyectos por estado
  Future<List<Anteproject>> getAnteprojectsByStatus(AnteprojectStatus status) async {
    try {
      final response = await _supabase
          .from('anteprojects')
          .select()
          .eq('status', status.name)
          .order('created_at', ascending: false);

      return response.map<Anteproject>(Anteproject.fromJson).toList();
    } catch (e) {
      throw AnteprojectsException('Error al obtener anteproyectos por estado: $e');
    }
  }

  /// Obtiene anteproyectos del tutor actual
  Future<List<Anteproject>> getTutorAnteprojects() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AnteprojectsException('Usuario no autenticado');
      }

      // Primero obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;

      final response = await _supabase
          .from('anteprojects')
          .select()
          .eq('tutor_id', userId)
          .order('created_at', ascending: false);

      return response.map<Anteproject>(Anteproject.fromJson).toList();
    } catch (e) {
      throw AnteprojectsException('Error al obtener anteproyectos del tutor: $e');
    }
  }

  /// Obtiene anteproyectos del estudiante actual
  Future<List<Anteproject>> getStudentAnteprojects() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AnteprojectsException('Usuario no autenticado');
      }

      // Primero obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;

      // Obtener anteproyectos donde el estudiante es autor
      final response = await _supabase
          .from('anteproject_students')
          .select('''
            anteproject_id,
            anteprojects!inner(*)
          ''')
          .eq('student_id', userId);

      // Extraer los anteproyectos de la respuesta
      final anteprojects = <Anteproject>[];
      for (final item in response) {
        if (item['anteprojects'] != null) {
          anteprojects.add(Anteproject.fromJson(item['anteprojects']));
        }
      }

      // Ordenar por fecha de creación
      anteprojects.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return anteprojects;
    } catch (e) {
      throw AnteprojectsException('Error al obtener anteproyectos del estudiante: $e');
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

  /// Elimina un anteproyecto (solo estudiantes, solo en estado draft)
  Future<void> deleteAnteproject(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AnteprojectsException('Usuario no autenticado');
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
        throw const AnteprojectsException('Solo los estudiantes pueden eliminar anteproyectos');
      }

      // Verificar que el anteproyecto existe y está en estado draft
      final anteprojectResponse = await _supabase
          .from('anteprojects')
          .select('status')
          .eq('id', id)
          .single();

      final status = anteprojectResponse['status'] as String;
      if (status != 'draft') {
        throw const AnteprojectsException('Solo se pueden eliminar anteproyectos en estado borrador');
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
        throw const AnteprojectsException('No tienes permisos para eliminar este anteproyecto');
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
      await _supabase
          .from('anteprojects')
          .delete()
          .eq('id', id);

      // ignore: avoid_print
      print('✅ Debug - Anteproyecto eliminado exitosamente: $id');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Debug - Error al eliminar anteproyecto: $e');
      throw AnteprojectsException('Error al eliminar anteproyecto: $e');
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
