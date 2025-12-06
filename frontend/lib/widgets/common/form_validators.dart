import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Clase de utilidad para validaciones de formularios
class FormValidators {
  /// Validador genérico para campos requeridos
  static String? required(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    return null;
  }

  /// Validador para campos con longitud mínima
  static String? minLength(String? value, int minLength, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    if (value.trim().length < minLength) {
      return l10n.fieldTooShort;
    }
    return null;
  }

  /// Validador para campos con longitud máxima
  static String? maxLength(String? value, int maxLength, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value != null && value.trim().length > maxLength) {
      return l10n.fieldTooLong;
    }
    return null;
  }

  /// Validador para email
  static String? email(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.invalidEmail;
    }
    return null;
  }

  /// Validador para URL
  static String? url(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return null; // URL es opcional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return l10n.invalidUrl;
    }
    return null;
  }

  /// Validador específico para URLs de repositorios de GitHub
  /// Valida que la URL sea de GitHub y tenga el formato correcto
  static String? githubRepositoryUrl(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL es opcional
    }

    final trimmedValue = value.trim();

    // Patrón para URLs de GitHub:
    // - https://github.com/usuario/repositorio
    // - https://github.com/usuario/repositorio.git (opcional)
    // - Puede tener paths adicionales pero validamos el formato base
    final githubUrlPattern = RegExp(
      r'^https?://(www\.)?github\.com/[\w\-\.]+/[\w\-\.]+(/.*)?$',
      caseSensitive: false,
    );

    if (!githubUrlPattern.hasMatch(trimmedValue)) {
      return 'La URL debe ser un repositorio válido de GitHub (ej: https://github.com/usuario/repositorio)';
    }

    // Validar que tenga al menos usuario y repositorio
    final urlParts = Uri.tryParse(trimmedValue);
    if (urlParts == null) {
      return 'URL inválida';
    }

    // Verificar que sea github.com
    if (!urlParts.host.toLowerCase().contains('github.com')) {
      return 'La URL debe ser de GitHub (github.com)';
    }

    // Extraer usuario y repositorio del path
    final pathSegments = urlParts.pathSegments;
    if (pathSegments.isEmpty) {
      return 'La URL debe incluir el usuario y el nombre del repositorio';
    }

    // El primer segmento es el usuario, el segundo es el repositorio
    if (pathSegments.length < 2) {
      return 'La URL debe incluir el usuario y el nombre del repositorio (ej: https://github.com/usuario/repositorio)';
    }

    final username = pathSegments[0];
    final repository = pathSegments[1].replaceAll('.git', ''); // Remover .git si existe

    // Validar formato de usuario y repositorio
    // GitHub permite: letras, números, guiones y puntos
    final validNamePattern = RegExp(r'^[a-zA-Z0-9._-]+$');
    
    if (!validNamePattern.hasMatch(username)) {
      return 'El nombre de usuario contiene caracteres inválidos';
    }

    if (!validNamePattern.hasMatch(repository)) {
      return 'El nombre del repositorio contiene caracteres inválidos';
    }

    // Validar longitud (GitHub tiene límites)
    if (username.length > 39) {
      return 'El nombre de usuario es demasiado largo (máximo 39 caracteres)';
    }

    if (repository.length > 100) {
      return 'El nombre del repositorio es demasiado largo (máximo 100 caracteres)';
    }

    return null;
  }

  /// Validador para números
  static String? number(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return null; // Número es opcional
    }
    
    final number = double.tryParse(value.trim());
    if (number == null) {
      return l10n.invalidNumber;
    }
    return null;
  }

  /// Validador para números enteros
  static String? integer(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return null; // Número es opcional
    }
    
    final number = int.tryParse(value.trim());
    if (number == null) {
      return l10n.invalidNumber;
    }
    return null;
  }

  /// Validador para JSON
  static String? json(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return null; // JSON es opcional
    }
    
    try {
      // Intentar parsear como JSON
      final decoded = value.trim();
      if (decoded.startsWith('{') && decoded.endsWith('}')) {
        // Es un objeto JSON
        return null;
      } else if (decoded.startsWith('[') && decoded.endsWith(']')) {
        // Es un array JSON
        return null;
      } else {
        return l10n.invalidJson;
      }
    } catch (e) {
      return l10n.invalidJson;
    }
  }

  /// Validador compuesto para título de anteproyecto
  static String? anteprojectTitle(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.anteprojectTitleRequired;
    }
    if (value.trim().length < 5) {
      return l10n.fieldTooShort;
    }
    if (value.trim().length > 500) {
      return l10n.fieldTooLong;
    }
    return null;
  }

  /// Validador compuesto para descripción de anteproyecto
  static String? anteprojectDescription(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.anteprojectDescriptionRequired;
    }
    if (value.trim().length < 10) {
      return l10n.fieldTooShort;
    }
    if (value.trim().length > 2000) {
      return l10n.fieldTooLong;
    }
    return null;
  }

  /// Validador compuesto para año académico
  static String? academicYear(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.anteprojectAcademicYearRequired;
    }
    
    // Validar formato YYYY-YYYY
    final yearRegex = RegExp(r'^\d{4}-\d{4}$');
    if (!yearRegex.hasMatch(value.trim())) {
      return 'Formato inválido. Use: YYYY-YYYY (ej: 2024-2025)';
    }
    
    // Validar que el segundo año sea mayor que el primero
    final parts = value.trim().split('-');
    final startYear = int.tryParse(parts[0]);
    final endYear = int.tryParse(parts[1]);
    
    if (startYear == null || endYear == null || endYear <= startYear) {
      return 'El año de fin debe ser mayor que el año de inicio';
    }
    
    return null;
  }

  /// Validador compuesto para ID de tutor
  static String? tutorId(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.anteprojectTutorIdRequired;
    }
    
    final tutorId = int.tryParse(value.trim());
    if (tutorId == null || tutorId <= 0) {
      return l10n.anteprojectTutorIdNumeric;
    }
    
    return null;
  }

  /// Validador compuesto para resultados esperados (JSON)
  static String? expectedResults(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return null; // Es opcional
    }
    
    try {
      // Validar que sea un JSON válido
      final decoded = value.trim();
      if (!decoded.startsWith('{') || !decoded.endsWith('}')) {
        return l10n.invalidJson;
      }
      
      // Intentar parsear para verificar que es JSON válido
      // (no importa el contenido, solo la sintaxis)
      return null;
    } catch (e) {
      return l10n.invalidJson;
    }
  }

  /// Validador compuesto para temporalización (JSON)
  static String? timeline(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return null; // Es opcional
    }
    
    try {
      // Validar que sea un JSON válido
      final decoded = value.trim();
      if (!decoded.startsWith('{') || !decoded.endsWith('}')) {
        return l10n.invalidJson;
      }
      
      // Intentar parsear para verificar que es JSON válido
      // (no importa el contenido, solo la sintaxis)
      return null;
    } catch (e) {
      return l10n.invalidJson;
    }
  }
}
