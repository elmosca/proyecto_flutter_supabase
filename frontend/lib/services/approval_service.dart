import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/models.dart';
import 'email_notification_service.dart';

class ApprovalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Aprueba un anteproyecto usando la API del backend
  Future<ApprovalResult> approveAnteproject(int anteprojectId, {String? comments}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const ApprovalException('Usuario no autenticado');
      }

      final response = await _supabase.functions.invoke(
        'approval-api',
        queryParameters: {'action': 'approve'},
        body: {
          'anteproject_id': anteprojectId,
          'comments': comments,
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Error desconocido';
        throw ApprovalException('Error al aprobar anteproyecto: $error');
      }

      final result = ApprovalResult.fromJson(response.data);

      // Enviar email de notificación al estudiante
      await _sendStatusChangeEmail(anteprojectId, 'approved', comments);

      return result;
    } catch (e) {
      if (e is ApprovalException) rethrow;
      throw ApprovalException('Error al aprobar anteproyecto: $e');
    }
  }

  /// Rechaza un anteproyecto usando la API del backend
  Future<ApprovalResult> rejectAnteproject(int anteprojectId, String comments) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const ApprovalException('Usuario no autenticado');
      }

      if (comments.trim().isEmpty) {
        throw const ApprovalException('Los comentarios son obligatorios para rechazar un anteproyecto');
      }

      final response = await _supabase.functions.invoke(
        'approval-api',
        queryParameters: {'action': 'reject'},
        body: {
          'anteproject_id': anteprojectId,
          'comments': comments,
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Error desconocido';
        throw ApprovalException('Error al rechazar anteproyecto: $error');
      }

      final result = ApprovalResult.fromJson(response.data);

      // Enviar email de notificación al estudiante
      await _sendStatusChangeEmail(anteprojectId, 'rejected', comments);

      return result;
    } catch (e) {
      if (e is ApprovalException) rethrow;
      throw ApprovalException('Error al rechazar anteproyecto: $e');
    }
  }

  /// Solicita cambios en un anteproyecto usando la API del backend
  Future<ApprovalResult> requestChanges(int anteprojectId, String comments) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const ApprovalException('Usuario no autenticado');
      }

      if (comments.trim().isEmpty) {
        throw const ApprovalException('Los comentarios son obligatorios para solicitar cambios');
      }

      final response = await _supabase.functions.invoke(
        'approval-api',
        queryParameters: {'action': 'request-changes'},
        body: {
          'anteproject_id': anteprojectId,
          'comments': comments,
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Error desconocido';
        throw ApprovalException('Error al solicitar cambios: $error');
      }

      return ApprovalResult.fromJson(response.data);
    } catch (e) {
      if (e is ApprovalException) rethrow;
      throw ApprovalException('Error al solicitar cambios: $e');
    }
  }

  /// Obtiene anteproyectos pendientes de aprobación para el tutor actual
  Future<List<Anteproject>> getPendingApprovals() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const ApprovalException('Usuario no autenticado');
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
          .inFilter('status', ['submitted', 'under_review'])
          .eq('tutor_id', userId)
          .order('submitted_at', ascending: true);

      return response.map<Anteproject>(Anteproject.fromJson).toList();
    } catch (e) {
      throw ApprovalException('Error al obtener anteproyectos pendientes: $e');
    }
  }

  /// Obtiene anteproyectos ya revisados por el tutor actual
  Future<List<Anteproject>> getReviewedAnteprojects() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const ApprovalException('Usuario no autenticado');
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
          .inFilter('status', ['approved', 'rejected'])
          .eq('tutor_id', userId)
          .order('reviewed_at', ascending: false);

      return response.map<Anteproject>(Anteproject.fromJson).toList();
    } catch (e) {
      throw ApprovalException('Error al obtener anteproyectos revisados: $e');
    }
  }

  /// Verifica si el usuario actual puede aprobar/rechazar anteproyectos
  Future<bool> canApproveAnteprojects() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Verificar el rol del usuario en la base de datos
      final response = await _supabase
          .from('users')
          .select('role')
          .eq('email', user.email!)
          .single();

      final role = response['role'] as String?;
      return role == 'tutor' || role == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// Envía email de notificación de cambio de estado
  Future<void> _sendStatusChangeEmail(int anteprojectId, String status, String? comments) async {
    try {
      // Obtener información del anteproyecto y estudiantes
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
          .select('full_name')
          .eq('id', tutorId)
          .single();

      final tutorName = tutorResponse['full_name'] as String;

      // Obtener estudiantes del anteproyecto
      final studentsResponse = await _supabase
          .from('anteproject_students')
          .select('''
            student_id,
            students:users!anteproject_students_student_id_fkey (
              id, full_name, email
            )
          ''')
          .eq('anteproject_id', anteprojectId);

      // Enviar email a cada estudiante
      for (final student in studentsResponse) {
        final studentData = student['students'] as Map<String, dynamic>;
        final studentName = studentData['full_name'] as String;
        final studentEmail = studentData['email'] as String;

        await EmailNotificationService.sendStatusChangeNotification(
          studentEmail: studentEmail,
          studentName: studentName,
          tutorName: tutorName,
          anteprojectTitle: anteprojectTitle,
          newStatus: status,
          tutorComments: comments,
          anteprojectUrl: 'https://app.cifpcarlos3.es/anteprojects/$anteprojectId',
        );
      }
    } catch (e) {
      // No fallar si no se puede enviar el email
      debugPrint('Error al enviar email de cambio de estado: $e');
    }
  }
}

/// Modelo para el resultado de una operación de aprobación
class ApprovalResult {
  final bool success;
  final int anteprojectId;
  final int? projectId;
  final String message;

  const ApprovalResult({
    required this.success,
    required this.anteprojectId,
    this.projectId,
    required this.message,
  });

  factory ApprovalResult.fromJson(Map<String, dynamic> json) {
    return ApprovalResult(
      success: json['success'] ?? false,
      anteprojectId: json['anteproject_id'] ?? 0,
      projectId: json['project_id'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'anteproject_id': anteprojectId,
      'project_id': projectId,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'ApprovalResult(success: $success, anteprojectId: $anteprojectId, projectId: $projectId, message: $message)';
  }
}

/// Excepción personalizada para errores de aprobación
class ApprovalException implements Exception {
  final String message;
  
  const ApprovalException(this.message);
  
  @override
  String toString() => 'ApprovalException: $message';
}
