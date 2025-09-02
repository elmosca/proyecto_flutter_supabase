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

      final data = anteproject.toJson();
      // Remover campos que se generan automáticamente
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      data.remove('submitted_at');
      data.remove('reviewed_at');

      final response = await _supabase
          .from('anteprojects')
          .insert(data)
          .select()
          .single();

      return Anteproject.fromJson(response);
    } catch (e) {
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

      final response = await _supabase
          .from('anteprojects')
          .select()
          .eq('tutor_id', user.id)
          .order('created_at', ascending: false);

      return response.map<Anteproject>(Anteproject.fromJson).toList();
    } catch (e) {
      throw AnteprojectsException('Error al obtener anteproyectos del tutor: $e');
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
