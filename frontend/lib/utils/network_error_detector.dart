import 'dart:io';
import 'dart:async';
import 'app_exception.dart';

/// Detector de errores de red que clasifica errores de conectividad
/// y los convierte a [AppException] apropiadas.
///
/// Proporciona detección inteligente de errores de red analizando:
/// - Excepciones específicas de Dart (SocketException, HttpException, etc.)
/// - Códigos de error del sistema operativo
/// - Patrones en mensajes de error
/// - Timeouts y problemas de conectividad
///
/// ## Funcionalidades principales:
/// - Detección automática de tipos de error de red
/// - Clasificación por códigos de error del SO
/// - Análisis de patrones en mensajes de error
/// - Conversión a excepciones tipadas de la aplicación
///
/// ## Ejemplo de uso:
/// ```dart
/// try {
///   await httpClient.get(url);
/// } catch (e) {
///   if (NetworkErrorDetector.isNetworkError(e)) {
///     final networkException = NetworkErrorDetector.detectNetworkError(e);
///     // Manejar error de red
///   }
/// }
/// ```
///
/// Ver también: [NetworkException], [AppException]
class NetworkErrorDetector {
  /// Detecta y clasifica errores de red.
  ///
  /// Parámetros:
  /// - [error]: Error a analizar y clasificar
  ///
  /// Retorna:
  /// - [AppException] tipada según el tipo de error de red detectado
  static AppException detectNetworkError(dynamic error) {
    if (error is SocketException) {
      return _handleSocketException(error);
    }
    if (error is HttpException) {
      return _handleHttpException(error);
    }
    if (error is HandshakeException) {
      return _handleHandshakeException(error);
    }
    if (error is TimeoutException) {
      return _handleTimeoutException(error);
    }
    if (error is FormatException) {
      return _handleFormatException(error);
    }

    // Analizar el mensaje de error para patrones comunes
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('timeout') ||
        errorMessage.contains('timed out')) {
      return NetworkException(
        'network_timeout',
        technicalMessage: 'Connection timed out',
        originalError: error,
      );
    }

    if (errorMessage.contains('no internet') ||
        errorMessage.contains('network is unreachable') ||
        errorMessage.contains('host is unreachable')) {
      return NetworkException(
        'network_no_internet',
        technicalMessage: 'No internet connection available',
        originalError: error,
      );
    }

    if (errorMessage.contains('server') &&
        errorMessage.contains('unavailable')) {
      return NetworkException(
        'network_server_unavailable',
        technicalMessage: 'Server is not available',
        originalError: error,
      );
    }

    if (errorMessage.contains('dns') ||
        errorMessage.contains('name resolution')) {
      return NetworkException(
        'network_dns_error',
        technicalMessage: 'DNS resolution failed',
        originalError: error,
      );
    }

    if (errorMessage.contains('connection') && errorMessage.contains('lost')) {
      return NetworkException(
        'network_connection_lost',
        technicalMessage: 'Connection was lost',
        originalError: error,
      );
    }

    if (errorMessage.contains('refused') || errorMessage.contains('reset')) {
      return NetworkException(
        'network_request_failed',
        technicalMessage: 'Connection was refused or reset',
        originalError: error,
      );
    }

    // Error de red genérico
    return NetworkException(
      'network_generic',
      technicalMessage: 'Network error: ${error.toString()}',
      originalError: error,
    );
  }

  /// Maneja errores de Socket
  static NetworkException _handleSocketException(SocketException error) {
    String appCode;
    String? technicalMessage;

    switch (error.osError?.errorCode) {
      case 7: // No address associated with hostname
        appCode = 'network_dns_error';
        technicalMessage = 'Cannot resolve hostname: ${error.message}';
        break;
      case 61: // Connection refused
        appCode = 'network_server_unavailable';
        technicalMessage = 'Connection refused: ${error.message}';
        break;
      case 64: // Host is down
        appCode = 'network_server_unavailable';
        technicalMessage = 'Host is down: ${error.message}';
        break;
      case 65: // No route to host
        appCode = 'network_no_internet';
        technicalMessage = 'No route to host: ${error.message}';
        break;
      case 110: // Connection timed out
        appCode = 'network_timeout';
        technicalMessage = 'Connection timed out: ${error.message}';
        break;
      case 111: // Connection refused
        appCode = 'network_server_unavailable';
        technicalMessage = 'Connection refused: ${error.message}';
        break;
      case 113: // No route to host
        appCode = 'network_no_internet';
        technicalMessage = 'No route to host: ${error.message}';
        break;
      default:
        appCode = 'network_generic';
        technicalMessage =
            'Socket error (${error.osError?.errorCode}): ${error.message}';
    }

    return NetworkException(
      appCode,
      technicalMessage: technicalMessage,
      originalError: error,
      context: {
        'os_error_code': error.osError?.errorCode,
        'os_error_message': error.osError?.message,
        'address': error.address?.toString(),
        'port': error.port,
      },
    );
  }

  /// Maneja errores HTTP
  static NetworkException _handleHttpException(HttpException error) {
    return NetworkException(
      'network_request_failed',
      technicalMessage: 'HTTP error: ${error.message}',
      originalError: error,
      context: {'http_message': error.message},
    );
  }

  /// Maneja errores de handshake SSL/TLS
  static NetworkException _handleHandshakeException(HandshakeException error) {
    return NetworkException(
      'network_request_failed',
      technicalMessage: 'SSL/TLS handshake failed: ${error.message}',
      originalError: error,
      context: {'handshake_message': error.message},
    );
  }

  /// Maneja errores de timeout
  static NetworkException _handleTimeoutException(TimeoutException error) {
    return NetworkException(
      'network_timeout',
      technicalMessage: 'Operation timed out: ${error.message}',
      originalError: error,
      context: {
        'timeout_message': error.message,
        'duration': error.duration?.toString(),
      },
    );
  }

  /// Maneja errores de formato
  static ValidationException _handleFormatException(FormatException error) {
    return ValidationException(
      'invalid_json',
      technicalMessage: 'Data format error: ${error.message}',
      originalError: error,
      context: {
        'format_message': error.message,
        'source': error.source,
        'offset': error.offset,
      },
    );
  }

  /// Verifica si un error es de red
  static bool isNetworkError(dynamic error) {
    return error is SocketException ||
        error is HttpException ||
        error is HandshakeException ||
        error is TimeoutException ||
        _isNetworkErrorByMessage(error);
  }

  /// Verifica si un error es de red basándose en el mensaje
  static bool _isNetworkErrorByMessage(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    return errorMessage.contains('timeout') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('network') ||
        errorMessage.contains('socket') ||
        errorMessage.contains('dns') ||
        errorMessage.contains('unreachable') ||
        errorMessage.contains('refused') ||
        errorMessage.contains('reset');
  }

  /// Obtiene información detallada del error de red
  static Map<String, dynamic> getNetworkErrorDetails(dynamic error) {
    if (error is SocketException) {
      return {
        'type': 'SocketException',
        'message': error.message,
        'os_error_code': error.osError?.errorCode,
        'os_error_message': error.osError?.message,
        'address': error.address?.toString(),
        'port': error.port,
      };
    } else if (error is HttpException) {
      return {'type': 'HttpException', 'message': error.message};
    } else if (error is HandshakeException) {
      return {'type': 'HandshakeException', 'message': error.message};
    } else if (error is TimeoutException) {
      return {
        'type': 'TimeoutException',
        'message': error.message,
        'duration': error.duration?.toString(),
      };
    } else if (error is FormatException) {
      return {
        'type': 'FormatException',
        'message': error.message,
        'source': error.source,
        'offset': error.offset,
      };
    }

    return {'type': 'Unknown', 'message': error.toString()};
  }

  /// Verifica la conectividad de red (simplificado)
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el tipo de conexión de red (simplificado)
  static Future<String?> getConnectionType() async {
    try {
      // En una implementación real, esto usaría connectivity_plus
      // Por ahora, solo verificamos si hay conexión
      final hasConnection = await hasInternetConnection();
      return hasConnection ? 'connected' : 'disconnected';
    } catch (e) {
      return 'unknown';
    }
  }
}
