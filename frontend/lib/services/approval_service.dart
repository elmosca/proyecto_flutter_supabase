import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/models.dart';

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

      return ApprovalResult.fromJson(response.data);
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

      return ApprovalResult.fromJson(response.data);
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

      final response = await _supabase
          .from('anteprojects')
          .select()
          .inFilter('status', ['submitted', 'under_review'])
          .eq('tutor_id', user.id)
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

      final response = await _supabase
          .from('anteprojects')
          .select()
          .inFilter('status', ['approved', 'rejected'])
          .eq('tutor_id', user.id)
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
          .eq('id', user.id)
          .single();

      final role = response['role'] as String?;
      return role == 'tutor' || role == 'admin';
    } catch (e) {
      return false;
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
