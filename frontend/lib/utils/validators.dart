/// Utilidades de validación para formularios
class Validators {
  /// Valida que un campo sea requerido
  static String? required(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  /// Valida que un email sea válido
  static String? email(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, introduce un email válido';
    }
    
    return null;
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
}
