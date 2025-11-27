/// Clase base abstracta para todas las excepciones de la aplicación.
///
/// Proporciona una estructura consistente para el manejo de errores con:
/// - Códigos únicos para identificación de tipos de error
/// - Mensajes técnicos para debugging
/// - Contexto adicional para análisis
/// - Timestamps para auditoría
/// - Error original para trazabilidad
///
/// ## Propiedades principales:
/// - [code]: Código único que identifica el tipo de error
/// - [technicalMessage]: Mensaje técnico opcional para debugging
/// - [originalError]: Error original que causó esta excepción
/// - [timestamp]: Timestamp cuando ocurrió el error
/// - [context]: Contexto adicional para debugging
///
/// ## Ejemplo de uso:
/// ```dart
/// throw ValidationException(
///   'field_required',
///   technicalMessage: 'El campo email es obligatorio',
///   context: {'field': 'email', 'form': 'login'}
/// );
/// ```
///
/// Ver también: [NetworkException], [AuthenticationException], [ValidationException]
abstract class AppException implements Exception {
  /// Código único que identifica el tipo de error
  final String code;

  /// Mensaje técnico opcional para debugging
  final String? technicalMessage;

  /// Error original que causó esta excepción
  final dynamic originalError;

  /// Timestamp cuando ocurrió el error
  final DateTime timestamp;

  /// Contexto adicional para debugging
  final Map<String, dynamic>? context;

  AppException(
    this.code, {
    this.technicalMessage,
    this.originalError,
    DateTime? timestamp,
    this.context,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Obtiene el tipo de excepción para categorización
  String get type => runtimeType.toString();

  /// Obtiene el mensaje técnico o el código como fallback
  String get debugMessage => technicalMessage ?? code;

  @override
  String toString() =>
      '$type: $code${technicalMessage != null ? ' - $technicalMessage' : ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppException &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Excepción para errores de red y conectividad.
///
/// Se lanza cuando hay problemas de comunicación con servicios externos,
/// timeouts, problemas de DNS, o pérdida de conexión.
class NetworkException extends AppException {
  NetworkException(
    super.code, {
    super.technicalMessage,
    super.originalError,
    super.timestamp,
    super.context,
  });
}

/// Excepción para errores de autenticación y autorización.
///
/// Se lanza cuando hay problemas con credenciales, sesiones expiradas,
/// perfiles no encontrados, o permisos insuficientes.
class AuthenticationException extends AppException {
  AuthenticationException(
    super.code, {
    super.technicalMessage,
    super.originalError,
    super.timestamp,
    super.context,
  });
}

/// Excepción para errores de validación de datos.
///
/// Se lanza cuando los datos de entrada no cumplen con las reglas de validación,
/// campos requeridos están vacíos, o formatos son incorrectos.
class ValidationException extends AppException {
  ValidationException(
    super.code, {
    super.technicalMessage,
    super.originalError,
    super.timestamp,
    super.context,
  });
}

/// Excepción para errores de permisos y acceso.
///
/// Se lanza cuando el usuario no tiene permisos para realizar una operación
/// o acceder a un recurso específico.
class PermissionException extends AppException {
  PermissionException(
    super.code, {
    super.technicalMessage,
    super.originalError,
    super.timestamp,
    super.context,
  });
}

/// Excepción para errores de base de datos.
///
/// Se lanza cuando hay problemas con operaciones de base de datos,
/// violaciones de restricciones, timeouts, o errores de conexión.
class DatabaseException extends AppException {
  DatabaseException(
    super.code, {
    super.technicalMessage,
    super.originalError,
    super.timestamp,
    super.context,
  });
}

/// Excepción para errores de archivos
class FileException extends AppException {
  FileException(
    super.code, {
    super.technicalMessage,
    super.originalError,
    super.timestamp,
    super.context,
  });
}

/// Excepción para errores de lógica de negocio
class BusinessLogicException extends AppException {
  BusinessLogicException(
    super.code, {
    super.technicalMessage,
    super.originalError,
    super.timestamp,
    super.context,
  });
}

/// Excepción para errores de configuración
class ConfigurationException extends AppException {
  ConfigurationException(
    super.code, {
    super.technicalMessage,
    super.originalError,
    super.timestamp,
    super.context,
  });
}

/// Excepción para errores de servicios externos
class ExternalServiceException extends AppException {
  ExternalServiceException(
    super.code, {
    super.technicalMessage,
    super.originalError,
    super.timestamp,
    super.context,
  });
}

/// Excepción genérica para errores no categorizados
class UnknownException extends AppException {
  UnknownException(
    super.code, {
    super.technicalMessage,
    super.originalError,
    super.timestamp,
    super.context,
  });
}

/// Factory para crear excepciones de manera consistente
class AppExceptionFactory {
  /// Crea una excepción de red
  static NetworkException network(
    String code, {
    String? technicalMessage,
    dynamic originalError,
    Map<String, dynamic>? context,
  }) {
    return NetworkException(
      code,
      technicalMessage: technicalMessage,
      originalError: originalError,
      context: context,
    );
  }

  /// Crea una excepción de autenticación
  static AuthenticationException authentication(
    String code, {
    String? technicalMessage,
    dynamic originalError,
    Map<String, dynamic>? context,
  }) {
    return AuthenticationException(
      code,
      technicalMessage: technicalMessage,
      originalError: originalError,
      context: context,
    );
  }

  /// Crea una excepción de validación
  static ValidationException validation(
    String code, {
    String? technicalMessage,
    dynamic originalError,
    Map<String, dynamic>? context,
  }) {
    return ValidationException(
      code,
      technicalMessage: technicalMessage,
      originalError: originalError,
      context: context,
    );
  }

  /// Crea una excepción de permisos
  static PermissionException permission(
    String code, {
    String? technicalMessage,
    dynamic originalError,
    Map<String, dynamic>? context,
  }) {
    return PermissionException(
      code,
      technicalMessage: technicalMessage,
      originalError: originalError,
      context: context,
    );
  }

  /// Crea una excepción de base de datos
  static DatabaseException database(
    String code, {
    String? technicalMessage,
    dynamic originalError,
    Map<String, dynamic>? context,
  }) {
    return DatabaseException(
      code,
      technicalMessage: technicalMessage,
      originalError: originalError,
      context: context,
    );
  }

  /// Crea una excepción de archivos
  static FileException file(
    String code, {
    String? technicalMessage,
    dynamic originalError,
    Map<String, dynamic>? context,
  }) {
    return FileException(
      code,
      technicalMessage: technicalMessage,
      originalError: originalError,
      context: context,
    );
  }

  /// Crea una excepción de lógica de negocio
  static BusinessLogicException businessLogic(
    String code, {
    String? technicalMessage,
    dynamic originalError,
    Map<String, dynamic>? context,
  }) {
    return BusinessLogicException(
      code,
      technicalMessage: technicalMessage,
      originalError: originalError,
      context: context,
    );
  }

  /// Crea una excepción de configuración
  static ConfigurationException configuration(
    String code, {
    String? technicalMessage,
    dynamic originalError,
    Map<String, dynamic>? context,
  }) {
    return ConfigurationException(
      code,
      technicalMessage: technicalMessage,
      originalError: originalError,
      context: context,
    );
  }

  /// Crea una excepción de servicio externo
  static ExternalServiceException externalService(
    String code, {
    String? technicalMessage,
    dynamic originalError,
    Map<String, dynamic>? context,
  }) {
    return ExternalServiceException(
      code,
      technicalMessage: technicalMessage,
      originalError: originalError,
      context: context,
    );
  }

  /// Crea una excepción desconocida
  static UnknownException unknown(
    String code, {
    String? technicalMessage,
    dynamic originalError,
    Map<String, dynamic>? context,
  }) {
    return UnknownException(
      code,
      technicalMessage: technicalMessage,
      originalError: originalError,
      context: context,
    );
  }
}
