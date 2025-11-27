/// Utilidades de validación para formularios
class Validators {
  /// Valida que un campo sea requerido
  static String? required(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  /// Valida que un email sea válido y pertenezca al dominio autorizado
  ///
  /// Valida:
  /// - Que no esté vacío
  /// - Que contenga un @
  /// - Que tenga una estructura básica válida
  /// - Que pertenezca al dominio autorizado: jualas.es
  ///
  /// Retorna un mensaje de error descriptivo si el email no es válido
  static String? email(String? value, [String? errorMessage]) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'El email es obligatorio';
    }

    final trimmedValue = value.trim().toLowerCase();

    // Validación 1: Debe contener exactamente un @
    final atCount = '@'.allMatches(trimmedValue).length;
    if (atCount == 0) {
      return 'El email debe contener el símbolo @';
    }
    if (atCount > 1) {
      return 'El email solo puede contener un símbolo @';
    }

    // Validación 2: No puede contener espacios
    if (trimmedValue.contains(' ')) {
      return 'El email no puede contener espacios';
    }

    // Validación 3: Debe tener contenido antes del @
    final parts = trimmedValue.split('@');
    if (parts.length != 2) {
      return 'El email tiene un formato inválido';
    }

    final localPart = parts[0]; // Parte antes del @
    final domainPart = parts[1]; // Parte después del @

    if (localPart.isEmpty) {
      return 'El email debe tener contenido antes del símbolo @';
    }

    // Validación 4: La parte local no puede empezar o terminar con punto
    if (localPart.startsWith('.') || localPart.endsWith('.')) {
      return 'El email no puede empezar o terminar con punto antes del @';
    }

    // Validación 5: Longitud máxima razonable
    if (trimmedValue.length > 254) {
      return 'El email es demasiado largo (máximo 254 caracteres)';
    }

    // Validación 6: La parte local no puede exceder 64 caracteres
    if (localPart.length > 64) {
      return 'La parte antes del @ es demasiado larga (máximo 64 caracteres)';
    }

    // Validación 7: Regex para estructura general
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?@[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'El formato del email no es válido. Use: usuario@dominio.extensión';
    }

    // Validación 8: DOMINIO AUTORIZADO - Solo jualas.es
    const allowedDomain = 'jualas.es';
    if (domainPart != allowedDomain) {
      return 'El email debe pertenecer al dominio autorizado: $allowedDomain. Ejemplo: usuario@$allowedDomain';
    }

    return null; // Email válido
  }

  /// Valida que una contraseña tenga al menos 6 caracteres
  static String? password(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  /// Valida que un número sea positivo
  static String? positiveNumber(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }

    final number = int.tryParse(value);
    if (number == null || number <= 0) {
      return 'Debe ser un número positivo';
    }

    return null;
  }

  /// Valida que un texto tenga una longitud mínima
  static String? minLength(String? value, int minLength, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }

    if (value.trim().length < minLength) {
      return 'Debe tener al menos $minLength caracteres';
    }

    return null;
  }

  /// Valida que un texto tenga una longitud máxima
  static String? maxLength(String? value, int maxLength, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return null; // No es requerido, solo valida longitud si tiene contenido
    }

    if (value.trim().length > maxLength) {
      return 'No puede tener más de $maxLength caracteres';
    }

    return null;
  }

  /// Valida el contenido de un comentario
  static String? validateCommentContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El contenido del comentario es obligatorio';
    }

    if (value.trim().length < 3) {
      return 'El comentario debe tener al menos 3 caracteres';
    }

    if (value.length > 1000) {
      return 'El comentario no puede exceder 1000 caracteres';
    }

    return null;
  }
}
