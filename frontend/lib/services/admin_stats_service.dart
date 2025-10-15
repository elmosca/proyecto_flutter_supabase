// ignore_for_file: avoid_print
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';
import '../models/anteproject.dart';

abstract class AdminStatsRepository {
  Future<AdminStats> getSystemStats();
  Future<List<User>> getRecentUsers();
}

class AdminStatsService implements AdminStatsRepository {
  final supabase.SupabaseClient _supabase;

  AdminStatsService({supabase.SupabaseClient? client})
    : _supabase = client ?? supabase.Supabase.instance.client;

  /// Obtiene estadísticas generales del sistema
  @override
  Future<AdminStats> getSystemStats() async {
    try {
      print('🔍 AdminStatsService - Iniciando obtención de estadísticas...');
      print(
        '🔍 AdminStatsService - Usuario actual: ${_supabase.auth.currentUser?.email}',
      );

      // Obtener estadísticas en paralelo
      return AdminStats(
        totalUsers: await _getTotalUsers(),
        totalStudents: await _getTotalStudents(),
        totalTutors: await _getTotalTutors(),
        totalAnteprojects: await _getTotalAnteprojects(),
        activeAnteprojects: await _getActiveAnteprojects(),
        approvedAnteprojects: await _getApprovedAnteprojects(),
        pendingAnteprojects: await _getPendingAnteprojects(),
      );
    } catch (e) {
      print('❌ AdminStatsService - Error general: $e');
      throw AdminStatsException('Error al obtener estadísticas: $e');
    }
  }

  /// Obtiene el total de usuarios
  Future<int> _getTotalUsers() async {
    try {
      print('🔍 AdminStatsService - Obteniendo total de usuarios...');
      final response = await _supabase.from('users').select('id');
      print('🔍 AdminStatsService - Respuesta usuarios: ${response.length}');
      print('🔍 AdminStatsService - Datos usuarios: $response');
      return response.length;
    } catch (e) {
      print('❌ AdminStatsService - Error obteniendo usuarios: $e');
      print('❌ AdminStatsService - Stack trace: ${StackTrace.current}');
      return 0;
    }
  }

  /// Obtiene el total de estudiantes
  Future<int> _getTotalStudents() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'student');

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Obtiene el total de tutores
  Future<int> _getTotalTutors() async {
    try {
      print('🔍 AdminStatsService - Obteniendo total de tutores...');
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'tutor');
      print('🔍 AdminStatsService - Respuesta tutores: ${response.length}');
      return response.length;
    } catch (e) {
      print('❌ AdminStatsService - Error obteniendo tutores: $e');
      return 0;
    }
  }

  /// Obtiene el total de anteproyectos
  Future<int> _getTotalAnteprojects() async {
    try {
      print('🔍 AdminStatsService - Obteniendo total de anteproyectos...');
      final response = await _supabase.from('anteprojects').select('id');
      print(
        '🔍 AdminStatsService - Respuesta anteproyectos: ${response.length}',
      );
      return response.length;
    } catch (e) {
      print('❌ AdminStatsService - Error obteniendo anteproyectos: $e');
      return 0;
    }
  }

  /// Obtiene anteproyectos activos (en desarrollo)
  Future<int> _getActiveAnteprojects() async {
    try {
      final response = await _supabase
          .from('anteprojects')
          .select('id')
          .eq('status', 'approved');

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Obtiene anteproyectos aprobados
  Future<int> _getApprovedAnteprojects() async {
    try {
      final response = await _supabase
          .from('anteprojects')
          .select('id')
          .eq('status', 'approved');

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Obtiene anteproyectos pendientes
  Future<int> _getPendingAnteprojects() async {
    try {
      final response = await _supabase
          .from('anteprojects')
          .select('id')
          .inFilter('status', ['submitted', 'under_review']);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  /// Obtiene usuarios recientes (últimos 10)
  @override
  Future<List<User>> getRecentUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .order('created_at', ascending: false)
          .limit(10);

      return response.map<User>(User.fromJson).toList();
    } catch (e) {
      throw AdminStatsException('Error al obtener usuarios recientes: $e');
    }
  }

  /// Obtiene anteproyectos recientes (últimos 10)
  Future<List<Anteproject>> getRecentAnteprojects() async {
    try {
      final response = await _supabase
          .from('anteprojects')
          .select('*')
          .order('created_at', ascending: false)
          .limit(10);

      return response.map<Anteproject>(Anteproject.fromJson).toList();
    } catch (e) {
      throw AdminStatsException('Error al obtener anteproyectos recientes: $e');
    }
  }
}

/// Modelo para las estadísticas del administrador
class AdminStats {
  final int totalUsers;
  final int totalStudents;
  final int totalTutors;
  final int totalAnteprojects;
  final int activeAnteprojects;
  final int approvedAnteprojects;
  final int pendingAnteprojects;

  const AdminStats({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalTutors,
    required this.totalAnteprojects,
    required this.activeAnteprojects,
    required this.approvedAnteprojects,
    required this.pendingAnteprojects,
  });

  /// Obtiene el total de administradores
  int get totalAdmins => totalUsers - totalStudents - totalTutors;
}

class AdminStatsException implements Exception {
  final String message;
  const AdminStatsException(this.message);

  @override
  String toString() => 'AdminStatsException: $message';
}
