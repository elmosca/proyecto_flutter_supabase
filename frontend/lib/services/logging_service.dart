import 'package:flutter/foundation.dart';

/// Servicio de logging simple para la aplicación
class LoggingService {
  static const String _tag = '[TFG]';
  
  /// Log de información
  static void info(String message, [String? context]) {
    if (kDebugMode) {
      final contextStr = context != null ? ' [$context]' : '';
      print('$_tag INFO$contextStr: $message');
    }
  }
  
  /// Log de advertencia
  static void warning(String message, [String? context]) {
    if (kDebugMode) {
      final contextStr = context != null ? ' [$context]' : '';
      print('$_tag WARNING$contextStr: $message');
    }
  }
  
  /// Log de error
  static void error(String message, [Object? error, String? context]) {
    if (kDebugMode) {
      final contextStr = context != null ? ' [$context]' : '';
      final errorStr = error != null ? '\nError: $error' : '';
      print('$_tag ERROR$contextStr: $message$errorStr');
    }
  }
  
  /// Log de debug
  static void debug(String message, [String? context]) {
    if (kDebugMode) {
      final contextStr = context != null ? ' [$context]' : '';
      print('$_tag DEBUG$contextStr: $message');
    }
  }
}
