import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'settings_service.dart';
import '../utils/app_exception.dart';

/// Servicio para gestionar permisos basados en el año académico.
///
/// Los estudiantes que pertenecen al año académico activo tienen permisos
/// de lectura y escritura completos. Los estudiantes de años anteriores
/// solo tienen permisos de lectura sobre sus datos históricos.
class AcademicPermissionsService {
  static final AcademicPermissionsService _instance =
      AcademicPermissionsService._internal();
  factory AcademicPermissionsService() => _instance;
  AcademicPermissionsService._internal();

  static AcademicPermissionsService get instance => _instance;

  final SettingsService _settingsService = SettingsService();

  // Cache del año académico activo para evitar consultas repetidas
  String? _cachedActiveYear;
  DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Obtiene el año académico activo del sistema.
  /// Utiliza cache para evitar consultas repetidas.
  Future<String?> getActiveAcademicYear() async {
    // Verificar si el cache es válido
    if (_cachedActiveYear != null &&
        _cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) < _cacheDuration) {
      return _cachedActiveYear;
    }

    try {
      final activeYear =
          await _settingsService.getStringSetting('academic_year');
      _cachedActiveYear = activeYear;
      _cacheTimestamp = DateTime.now();
      return activeYear;
    } catch (e) {
      debugPrint('Error obteniendo año académico activo: $e');
      return null;
    }
  }

  /// Limpia el cache del año académico.
  void clearCache() {
    _cachedActiveYear = null;
    _cacheTimestamp = null;
  }

  /// Verifica si un usuario (estudiante) puede escribir.
  /// Retorna true si el usuario está en el año académico activo.
  /// Los tutores y administradores siempre pueden escribir.
  Future<bool> canWrite(User user) async {
    // Solo aplicar restricción a estudiantes
    if (user.role != UserRole.student) {
      return true;
    }

    return await canWriteByAcademicYear(user.academicYear);
  }

  /// Verifica si el estudiante puede escribir basándose en su año académico.
  /// Esta versión acepta directamente el año académico como String.
  Future<bool> canWriteByAcademicYear(String? studentAcademicYear) async {
    final activeYear = await getActiveAcademicYear();

    // Si no hay año activo configurado en el sistema, permitir (configuración incompleta)
    if (activeYear == null || activeYear.isEmpty) {
      debugPrint('⚠️ No hay año académico activo configurado en el sistema');
      return true;
    }

    // Si el estudiante no tiene año académico asignado, DENEGAR escritura (modo seguro)
    // Esto evita que sesiones antiguas sin el campo tengan permisos de escritura
    if (studentAcademicYear == null || studentAcademicYear.isEmpty) {
      debugPrint(
          '🔐 Estudiante sin año académico asignado -> SOLO LECTURA (por seguridad)');
      return false;
    }

    final canWrite = studentAcademicYear == activeYear;
    debugPrint(
        '🔐 Verificación de permisos: Estudiante($studentAcademicYear) vs Activo($activeYear) = ${canWrite ? "ESCRITURA" : "SOLO LECTURA"}');

    return canWrite;
  }

  /// Verifica si el usuario está en modo solo lectura.
  /// Es lo opuesto a canWrite.
  Future<bool> isReadOnly(User user) async {
    debugPrint('🔐 isReadOnly: Verificando usuario ${user.fullName}, rol=${user.role}, academicYear=${user.academicYear}');
    final canWriteResult = await canWrite(user);
    debugPrint('🔐 isReadOnly: canWrite=$canWriteResult, isReadOnly=${!canWriteResult}');
    return !canWriteResult;
  }

  /// Verifica si es solo lectura basándose en el año académico.
  Future<bool> isReadOnlyByAcademicYear(String? studentAcademicYear) async {
    return !(await canWriteByAcademicYear(studentAcademicYear));
  }

  /// Lanza una excepción si el usuario no tiene permisos de escritura.
  /// Usar en servicios antes de operaciones de modificación.
  Future<void> requireWritePermission(User user) async {
    if (await isReadOnly(user)) {
      throw ValidationException(
        'read_only_mode',
        technicalMessage:
            'No puedes realizar esta acción porque tu año académico (${user.academicYear}) ya no está activo.',
      );
  }
}

  /// Lanza una excepción si el año académico no tiene permisos de escritura.
  Future<void> requireWritePermissionByAcademicYear(
      String? studentAcademicYear) async {
    if (await isReadOnlyByAcademicYear(studentAcademicYear)) {
      throw ValidationException(
        'read_only_mode',
        technicalMessage:
            'No puedes realizar esta acción porque tu año académico ya no está activo.',
      );
    }
  }
}
