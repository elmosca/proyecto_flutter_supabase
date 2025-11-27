import 'package:flutter/foundation.dart';
import 'app_exception.dart';

/// Traductor centralizado de errores que convierte códigos de error
/// a claves de internacionalización para mostrar mensajes amigables al usuario.
///
/// Proporciona un mapeo centralizado entre códigos de error técnicos
/// y claves de traducción para mostrar mensajes localizados al usuario.
///
/// ## Funcionalidades principales:
/// - Mapeo de códigos de error a claves de traducción
/// - Soporte para múltiples categorías de errores
/// - Fallback a mensajes genéricos cuando no hay traducción específica
/// - Categorización de errores por tipo (red, autenticación, validación, etc.)
///
/// ## Ejemplo de uso:
/// ```dart
/// try {
///   await someOperation();
/// } catch (e) {
///   final exception = e as AppException;
///   final messageKey = ErrorTranslator.getMessageKey(exception);
///   final message = AppLocalizations.of(context).translate(messageKey);
///   showErrorDialog(message);
/// }
/// ```
///
/// Ver también: [AppException], [AppLocalizations]
class ErrorTranslator {
  /// Mapeo de códigos de error a claves de traducción
  static const Map<String, String> _errorCodeToKeyMap = {
    // Errores de red
    'network_timeout': 'errorNetworkTimeout',
    'network_no_internet': 'errorNetworkNoInternet',
    'network_server_unavailable': 'errorNetworkServerUnavailable',
    'network_dns_error': 'errorNetworkDnsError',
    'network_connection_lost': 'errorNetworkConnectionLost',
    'network_request_failed': 'errorNetworkRequestFailed',

    // Errores de autenticación
    'not_authenticated': 'errorNotAuthenticated',
    'invalid_credentials': 'errorInvalidCredentials',
    'session_expired': 'errorSessionExpired',
    'profile_not_found': 'errorProfileNotFound',
    'account_disabled': 'errorAccountDisabled',
    'email_not_verified': 'errorEmailNotVerified',
    'password_too_weak': 'errorPasswordTooWeak',
    'login_attempts_exceeded': 'errorLoginAttemptsExceeded',
    'rate_limit_exceeded': 'errorRateLimitExceeded',
    'email_already_registered': 'errorEmailAlreadyRegistered',
    'user_not_found': 'userNotFound',

    // Errores de validación
    'field_required': 'errorFieldRequired',
    'field_too_short': 'errorFieldTooShort',
    'field_too_long': 'errorFieldTooLong',
    'invalid_email': 'errorInvalidEmail',
    'invalid_url': 'errorInvalidUrl',
    'invalid_number': 'errorInvalidNumber',
    'invalid_json': 'errorInvalidJson',
    'invalid_date': 'errorInvalidDate',
    'invalid_file_type': 'errorInvalidFileType',
    'invalid_file_size': 'errorInvalidFileSize',
    'missing_task_context': 'errorMissingTaskContext',
    'invalid_project_relation': 'errorInvalidProjectRelation',

    // Errores de permisos
    'access_denied': 'errorAccessDenied',
    'insufficient_permissions': 'errorInsufficientPermissions',
    'operation_not_allowed': 'errorOperationNotAllowed',
    'resource_not_found': 'errorResourceNotFound',
    'cannot_delete_completed_task': 'errorCannotDeleteCompletedTask',
    'cannot_edit_approved_anteproject': 'errorCannotEditApprovedAnteproject',

    // Errores de base de datos
    'database_connection_failed': 'errorDatabaseConnectionFailed',
    'database_query_failed': 'errorDatabaseQueryFailed',
    'database_constraint_violation': 'errorDatabaseConstraintViolation',
    'database_duplicate_entry': 'errorDatabaseDuplicateEntry',
    'database_foreign_key_violation': 'errorDatabaseForeignKeyViolation',
    'database_unknown_error': 'errorDatabaseUnknownError',
    'database_timeout': 'errorDatabaseTimeout',

    // Errores de archivos
    'file_upload_failed': 'errorFileUploadFailed',
    'file_download_failed': 'errorFileDownloadFailed',
    'file_delete_failed': 'errorFileDeleteFailed',
    'file_not_found': 'errorFileNotFound',
    'file_size_exceeded': 'errorFileSizeExceeded',
    'file_type_not_allowed': 'errorFileTypeNotAllowed',
    'file_corrupted': 'errorFileCorrupted',
    'file_permission_denied': 'errorFilePermissionDenied',

    // Errores de lógica de negocio
    'invalid_state': 'errorInvalidState',
    'operation_not_supported': 'errorOperationNotSupported',
    'resource_already_exists': 'errorResourceAlreadyExists',
    'resource_in_use': 'errorResourceInUse',
    'workflow_violation': 'errorWorkflowViolation',
    'business_rule_violation': 'errorBusinessRuleViolation',
    'quota_exceeded': 'errorQuotaExceeded',
    'deadline_exceeded': 'errorDeadlineExceeded',

    // Errores de configuración
    'configuration_missing': 'errorConfigurationMissing',
    'configuration_invalid': 'errorConfigurationInvalid',
    'service_unavailable': 'errorServiceUnavailable',
    'maintenance_mode': 'errorMaintenanceMode',

    // Errores de servicios externos
    'external_service_timeout': 'errorExternalServiceTimeout',
    'external_service_error': 'errorExternalServiceError',
    'email_service_unavailable': 'errorEmailServiceUnavailable',
    'notification_service_unavailable': 'errorNotificationServiceUnavailable',

    // Errores genéricos
    'unknown_error': 'errorUnknown',
    'unexpected_error': 'errorUnexpected',
    'internal_error': 'errorInternal',
  };

  /// Obtiene la clave de traducción para un código de error.
  ///
  /// Parámetros:
  /// - [exception]: Excepción con el código de error a traducir
  ///
  /// Retorna:
  /// - Clave de traducción correspondiente o 'errorUnknown' como fallback
  static String getMessageKey(AppException exception) {
    final key = _errorCodeToKeyMap[exception.code];
    if (key != null) {
      return key;
    }

    // Si no hay mapeo específico, usar el tipo de excepción
    return _getGenericKeyForType(exception);
  }

  /// Obtiene una clave genérica basada en el tipo de excepción
  static String _getGenericKeyForType(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return 'errorNetworkGeneric';
      case AuthenticationException:
        return 'errorAuthenticationGeneric';
      case ValidationException:
        return 'errorValidationGeneric';
      case PermissionException:
        return 'errorPermissionGeneric';
      case DatabaseException:
        return 'errorDatabaseGeneric';
      case FileException:
        return 'errorFileGeneric';
      case BusinessLogicException:
        return 'errorBusinessLogicGeneric';
      case ConfigurationException:
        return 'errorConfigurationGeneric';
      case ExternalServiceException:
        return 'errorExternalServiceGeneric';
      case UnknownException:
      default:
        return 'errorUnknown';
    }
  }

  /// Obtiene el mensaje de fallback si no hay traducción disponible
  static String getFallbackMessage(AppException exception) {
    // En modo debug, mostrar información técnica
    if (kDebugMode) {
      return 'Error: ${exception.code}${exception.technicalMessage != null ? ' - ${exception.technicalMessage}' : ''}';
    }

    // En producción, usar mensaje genérico
    return exception.technicalMessage ??
        'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.';
  }

  /// Obtiene el título del error basado en el tipo de excepción
  static String getErrorTitle(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return 'errorTitleNetwork';
      case AuthenticationException:
        return 'errorTitleAuthentication';
      case ValidationException:
        return 'errorTitleValidation';
      case PermissionException:
        return 'errorTitlePermission';
      case DatabaseException:
        return 'errorTitleDatabase';
      case FileException:
        return 'errorTitleFile';
      case BusinessLogicException:
        return 'errorTitleBusinessLogic';
      case ConfigurationException:
        return 'errorTitleConfiguration';
      case ExternalServiceException:
        return 'errorTitleExternalService';
      case UnknownException:
      default:
        return 'errorTitleUnknown';
    }
  }

  /// Obtiene el icono recomendado para el tipo de error
  static String getErrorIcon(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return 'wifi_off';
      case AuthenticationException:
        return 'lock';
      case ValidationException:
        return 'warning';
      case PermissionException:
        return 'block';
      case DatabaseException:
        return 'storage';
      case FileException:
        return 'file_upload';
      case BusinessLogicException:
        return 'error_outline';
      case ConfigurationException:
        return 'settings';
      case ExternalServiceException:
        return 'cloud_off';
      case UnknownException:
      default:
        return 'error';
    }
  }

  /// Obtiene la acción recomendada para el tipo de error
  static String getRecommendedAction(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return 'errorActionNetwork';
      case AuthenticationException:
        return 'errorActionAuthentication';
      case ValidationException:
        return 'errorActionValidation';
      case PermissionException:
        return 'errorActionPermission';
      case DatabaseException:
        return 'errorActionDatabase';
      case FileException:
        return 'errorActionFile';
      case BusinessLogicException:
        return 'errorActionBusinessLogic';
      case ConfigurationException:
        return 'errorActionConfiguration';
      case ExternalServiceException:
        return 'errorActionExternalService';
      case UnknownException:
      default:
        return 'errorActionUnknown';
    }
  }

  /// Verifica si un código de error tiene traducción específica
  static bool hasSpecificTranslation(String errorCode) {
    return _errorCodeToKeyMap.containsKey(errorCode);
  }

  /// Obtiene todos los códigos de error soportados
  static List<String> getSupportedErrorCodes() {
    return _errorCodeToKeyMap.keys.toList();
  }

  /// Obtiene información completa del error para debugging
  static Map<String, dynamic> getErrorInfo(AppException exception) {
    return {
      'code': exception.code,
      'type': exception.type,
      'messageKey': getMessageKey(exception),
      'titleKey': getErrorTitle(exception),
      'icon': getErrorIcon(exception),
      'actionKey': getRecommendedAction(exception),
      'hasSpecificTranslation': hasSpecificTranslation(exception.code),
      'technicalMessage': exception.technicalMessage,
      'timestamp': exception.timestamp.toIso8601String(),
      'context': exception.context,
      'originalError': exception.originalError?.toString(),
    };
  }
}
