import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../utils/app_exception.dart';

/// Interceptor para convertir errores de Supabase a AppException
/// Proporciona una capa de abstracción para manejar errores de manera consistente
class SupabaseErrorInterceptor {
  /// Convierte cualquier error de Supabase a AppException
  static AppException handleError(dynamic error) {
    if (error is supabase.PostgrestException) {
      return _handlePostgrestException(error);
    }
    if (error is supabase.AuthException) {
      return _handleAuthException(error);
    }
    if (error is supabase.StorageException) {
      return _handleStorageException(error);
    }
    // Nota: FunctionsException y RealtimeException pueden no estar disponibles en todas las versiones
    // if (error is supabase.FunctionsException) {
    //   return _handleFunctionsException(error);
    // }
    // if (error is supabase.RealtimeException) {
    //   return _handleRealtimeException(error);
    // }

    // Error genérico de Supabase
    return DatabaseException(
      'database_unknown_error',
      technicalMessage: error.toString(),
      originalError: error,
    );
  }

  /// Maneja errores de PostgREST (consultas a la base de datos)
  static DatabaseException _handlePostgrestException(
    supabase.PostgrestException error,
  ) {
    final code = error.code;
    final message = error.message;
    final details = error.details;
    final hint = error.hint;

    // Mapear códigos de error de PostgreSQL a códigos de aplicación
    String appCode;
    String? technicalMessage;

    switch (code) {
      case '23505': // unique_violation
        appCode = 'database_duplicate_entry';
        technicalMessage = 'Unique constraint violation: $message';
        break;
      case '23503': // foreign_key_violation
        appCode = 'database_foreign_key_violation';
        technicalMessage = 'Foreign key constraint violation: $message';
        break;
      case '23502': // not_null_violation
        appCode = 'database_constraint_violation';
        technicalMessage = 'Not null constraint violation: $message';
        break;
      case '23514': // check_violation
        appCode = 'database_constraint_violation';
        technicalMessage = 'Check constraint violation: $message';
        break;
      case '42P01': // undefined_table
        appCode = 'database_query_failed';
        technicalMessage = 'Table does not exist: $message';
        break;
      case '42703': // undefined_column
        appCode = 'database_query_failed';
        technicalMessage = 'Column does not exist: $message';
        break;
      case '42601': // syntax_error
        appCode = 'database_query_failed';
        technicalMessage = 'SQL syntax error: $message';
        break;
      case 'PGRST116': // JWT expired
        appCode = 'session_expired';
        technicalMessage = 'JWT token expired: $message';
        break;
      case 'PGRST301': // JWT invalid
        appCode = 'invalid_credentials';
        technicalMessage = 'JWT token invalid: $message';
        break;
      case 'PGRST204': // No rows returned
        appCode = 'resource_not_found';
        technicalMessage = 'No rows returned: $message';
        break;
      case 'PGRST302': // RLS policy violation
        appCode = 'access_denied';
        technicalMessage = 'Row Level Security policy violation: $message';
        break;
      default:
        appCode = 'database_unknown_error';
        technicalMessage = 'PostgreSQL error ($code): $message';
    }

    return DatabaseException(
      appCode,
      technicalMessage: technicalMessage,
      originalError: error,
      context: {
        'postgres_code': code,
        'message': message,
        'details': details,
        'hint': hint,
      },
    );
  }

  /// Maneja errores de autenticación de Supabase
  static AuthenticationException _handleAuthException(
    supabase.AuthException error,
  ) {
    final message = error.message;
    String appCode;
    String? technicalMessage;

    // Mapear mensajes de error de autenticación
    if (message.contains('Invalid login credentials')) {
      appCode = 'invalid_credentials';
      technicalMessage = 'Invalid email or password';
    } else if (message.contains('Email not confirmed')) {
      appCode = 'email_not_verified';
      technicalMessage = 'Email address not verified';
    } else if (message.contains('User not found')) {
      appCode = 'profile_not_found';
      technicalMessage = 'User account not found';
    } else if (message.contains('Invalid token')) {
      appCode = 'session_expired';
      technicalMessage = 'Authentication token is invalid or expired';
    } else if (message.contains('Too many requests') ||
        message.contains('only request this after')) {
      // Rate limiting: demasiadas solicitudes en poco tiempo
      appCode = 'rate_limit_exceeded';
      // Extraer el tiempo de espera si está disponible
      final secondsMatch = RegExp(r'after (\d+) seconds?').firstMatch(message);
      if (secondsMatch != null) {
        final seconds = secondsMatch.group(1);
        technicalMessage =
            'Rate limit exceeded. Please wait $seconds seconds before trying again.';
      } else {
        technicalMessage =
            'Too many requests. Please wait a moment before trying again.';
      }
    } else if (message.contains('User already registered') ||
        message.contains('already been registered')) {
      appCode = 'resource_already_exists';
      technicalMessage = 'User account already exists';
    } else if (message.contains('email') &&
        (message.contains('already') || message.contains('exists'))) {
      // Email ya registrado (puede ser por reutilización reciente)
      appCode = 'email_already_registered';
      technicalMessage =
          'This email is already registered. If you recently deleted a user with this email, please wait a few minutes before trying again.';
    } else if (message.contains('Password should be at least')) {
      appCode = 'password_too_weak';
      technicalMessage = 'Password does not meet requirements';
    } else if (message.contains('Signup is disabled')) {
      appCode = 'operation_not_allowed';
      technicalMessage = 'User registration is disabled';
    } else {
      appCode = 'authentication_generic';
      technicalMessage = message;
    }

    return AuthenticationException(
      appCode,
      technicalMessage: technicalMessage,
      originalError: error,
      context: {'auth_message': message},
    );
  }

  /// Maneja errores de Storage de Supabase
  static FileException _handleStorageException(
    supabase.StorageException error,
  ) {
    final message = error.message.toLowerCase();
    String appCode;
    String? technicalMessage;

    if (message.contains('file not found') || message.contains('not found')) {
      appCode = 'file_not_found';
      technicalMessage = 'File does not exist in storage';
    } else if (message.contains('file size exceeds') ||
        message.contains('exceeded the maximum allowed size') ||
        message.contains('entity too large') ||
        message.contains('object exceeded') ||
        message.contains('size limit') ||
        message.contains('too large')) {
      appCode = 'file_size_exceeded';
      technicalMessage = 'El archivo excede el tamaño máximo permitido de 10MB';
    } else if (message.contains('invalid file type') ||
        message.contains('file type not allowed') ||
        message.contains('mime type')) {
      appCode = 'file_type_not_allowed';
      technicalMessage = 'File type is not allowed';
    } else if (message.contains('permission denied') ||
        message.contains('access denied') ||
        message.contains('unauthorized')) {
      appCode = 'file_permission_denied';
      technicalMessage = 'Permission denied for file operation';
    } else if (message.contains('upload failed') ||
        message.contains('failed to upload')) {
      appCode = 'file_upload_failed';
      technicalMessage = 'File upload operation failed';
    } else if (message.contains('download failed') ||
        message.contains('failed to download')) {
      appCode = 'file_download_failed';
      technicalMessage = 'File download operation failed';
    } else {
      appCode = 'file_generic';
      technicalMessage = message;
    }

    return FileException(
      appCode,
      technicalMessage: technicalMessage,
      originalError: error,
      context: {'storage_message': error.message},
    );
  }

  // Nota: Estos métodos están comentados porque FunctionsException y RealtimeException
  // pueden no estar disponibles en todas las versiones de Supabase Flutter
  /*
  /// Maneja errores de Edge Functions de Supabase
  static ExternalServiceException _handleFunctionsException(supabase.FunctionsException error) {
    final message = error.message;
    String appCode;
    String? technicalMessage;

    if (message.contains('Function not found')) {
      appCode = 'external_service_error';
      technicalMessage = 'Edge function not found';
    } else if (message.contains('Function timeout')) {
      appCode = 'external_service_timeout';
      technicalMessage = 'Edge function execution timeout';
    } else if (message.contains('Function error')) {
      appCode = 'external_service_error';
      technicalMessage = 'Edge function execution error';
    } else {
      appCode = 'external_service_error';
      technicalMessage = message;
    }

    return ExternalServiceException(
      appCode,
      technicalMessage: technicalMessage,
      originalError: error,
      context: {
        'function_message': message,
      },
    );
  }

  /// Maneja errores de Realtime de Supabase
  static NetworkException _handleRealtimeException(supabase.RealtimeException error) {
    final message = error.message;
    String appCode;
    String? technicalMessage;

    if (message.contains('Connection timeout')) {
      appCode = 'network_timeout';
      technicalMessage = 'Realtime connection timeout';
    } else if (message.contains('Connection lost')) {
      appCode = 'network_connection_lost';
      technicalMessage = 'Realtime connection lost';
    } else if (message.contains('Server unavailable')) {
      appCode = 'network_server_unavailable';
      technicalMessage = 'Realtime server unavailable';
    } else {
      appCode = 'network_generic';
      technicalMessage = message;
    }

    return NetworkException(
      appCode,
      technicalMessage: technicalMessage,
      originalError: error,
      context: {
        'realtime_message': message,
      },
    );
  }
  */

  /// Verifica si un error es de Supabase
  static bool isSupabaseError(dynamic error) {
    return error is supabase.PostgrestException ||
        error is supabase.AuthException ||
        error is supabase.StorageException;
    // Nota: FunctionsException y RealtimeException pueden no estar disponibles
    // error is supabase.FunctionsException ||
    // error is supabase.RealtimeException;
  }

  /// Obtiene información detallada del error para debugging
  static Map<String, dynamic> getErrorDetails(dynamic error) {
    if (error is supabase.PostgrestException) {
      return {
        'type': 'PostgrestException',
        'code': error.code,
        'message': error.message,
        'details': error.details,
        'hint': error.hint,
      };
    } else if (error is supabase.AuthException) {
      return {'type': 'AuthException', 'message': error.message};
    } else if (error is supabase.StorageException) {
      return {'type': 'StorageException', 'message': error.message};
    }

    // Nota: FunctionsException y RealtimeException pueden no estar disponibles
    // } else if (error is supabase.FunctionsException) {
    //   return {
    //     'type': 'FunctionsException',
    //     'message': error.message,
    //   };
    // } else if (error is supabase.RealtimeException) {
    //   return {
    //     'type': 'RealtimeException',
    //     'message': error.message,
    //   };
    // }

    return {'type': 'Unknown', 'message': error.toString()};
  }
}
