import 'package:flutter/material.dart';
import '../models/user.dart';
import '../themes/role_themes.dart';

/// Servicio para gestionar temas dinámicos por rol
class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();
  
  static ThemeService get instance => _instance;

  UserRole? _currentRole;
  ThemeData _currentTheme = ThemeData.light();

  /// Obtiene el rol actual
  UserRole? get currentRole => _currentRole;

  /// Obtiene el tema actual
  ThemeData get currentTheme => _currentTheme;

  /// Obtiene el color primario actual
  Color get currentPrimaryColor {
    if (_currentRole != null) {
      return RoleThemes.getPrimaryColorForRole(_currentRole!);
    }
    return Colors.blue;
  }

  /// Obtiene el color de acento actual
  Color get currentAccentColor {
    if (_currentRole != null) {
      return RoleThemes.getAccentColorForRole(_currentRole!);
    }
    return Colors.blue.shade700;
  }

  /// Obtiene el icono actual
  IconData get currentIcon {
    if (_currentRole != null) {
      return RoleThemes.getIconForRole(_currentRole!);
    }
    return Icons.person;
  }

  /// Obtiene el emoji actual
  String get currentEmoji {
    if (_currentRole != null) {
      return RoleThemes.getEmojiForRole(_currentRole!);
    }
    return '👤';
  }

  /// Obtiene el gradiente actual
  LinearGradient get currentGradient {
    if (_currentRole != null) {
      return RoleThemes.getGradientForRole(_currentRole!);
    }
    return const LinearGradient(
      colors: [Colors.blue, Colors.blueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Cambia el tema según el rol del usuario
  void setRole(UserRole role) {
    if (_currentRole == role) return;

    _currentRole = role;
    _currentTheme = RoleThemes.getThemeForRole(role);
    notifyListeners();
  }

  /// Cambia el tema según el usuario
  void setUser(User user) {
    setRole(user.role);
  }

  /// Resetea el tema al tema por defecto
  void reset() {
    _currentRole = null;
    _currentTheme = ThemeData.light();
    notifyListeners();
  }

  /// Obtiene información del tema actual
  Map<String, dynamic> getThemeInfo() {
    return {
      'role': _currentRole?.displayName ?? 'Sin rol',
      'primaryColor': currentPrimaryColor.toARGB32().toRadixString(16),
      'accentColor': currentAccentColor.toARGB32().toRadixString(16),
      'icon': currentIcon.codePoint,
      'emoji': currentEmoji,
    };
  }
}
