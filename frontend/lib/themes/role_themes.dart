import 'package:flutter/material.dart';
import '../models/user.dart';

/// Sistema de temas específicos por rol de usuario
class RoleThemes {
  /// Obtiene el tema específico para un rol (modo claro)
  static ThemeData getThemeForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return _studentTheme;
      case UserRole.tutor:
        return _tutorTheme;
      case UserRole.admin:
        return _adminTheme;
    }
  }

  /// Obtiene el tema específico para un rol (modo oscuro)
  static ThemeData getDarkThemeForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return _studentDarkTheme;
      case UserRole.tutor:
        return _tutorDarkTheme;
      case UserRole.admin:
        return _adminDarkTheme;
    }
  }

  /// Obtiene el color primario para un rol
  static Color getPrimaryColorForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return const Color(0xFF2196F3); // Azul para estudiantes
      case UserRole.tutor:
        return const Color(0xFF4CAF50); // Verde para tutores
      case UserRole.admin:
        return const Color(0xFF9C27B0); // Púrpura para administradores
    }
  }

  /// Obtiene el color de acento para un rol
  static Color getAccentColorForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return const Color(0xFF1976D2); // Azul más oscuro
      case UserRole.tutor:
        return const Color(0xFF388E3C); // Verde más oscuro
      case UserRole.admin:
        return const Color(0xFF7B1FA2); // Púrpura más oscuro
    }
  }

  /// Obtiene el icono específico para un rol
  static IconData getIconForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school; // Icono de estudiante
      case UserRole.tutor:
        return Icons.person; // Icono de tutor
      case UserRole.admin:
        return Icons.admin_panel_settings; // Icono de admin
    }
  }

  /// Obtiene el emoji específico para un rol
  static String getEmojiForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return '🎓'; // Emoji de estudiante
      case UserRole.tutor:
        return '👨‍🏫'; // Emoji de tutor
      case UserRole.admin:
        return '⚙️'; // Emoji de admin
    }
  }

  /// Obtiene el gradiente específico para un rol
  static LinearGradient getGradientForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UserRole.tutor:
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UserRole.admin:
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// Construye un tema completo basado en un color semilla y brillo
  static ThemeData _buildThemeForRole(Color seedColor, {Brightness brightness = Brightness.light}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary, // Usar color primario del esquema
        foregroundColor: colorScheme.onPrimary, // Color de texto/iconos sobre primario
        elevation: 2,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      // Añadir más configuraciones de tema comunes aquí si es necesario
    );
  }

  /// Construye la escala tipográfica Material 3
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
    );
  }

  /// Temas Claros
  static ThemeData get _studentTheme => _buildThemeForRole(const Color(0xFF2196F3));
  static ThemeData get _tutorTheme => _buildThemeForRole(const Color(0xFF4CAF50));
  static ThemeData get _adminTheme => _buildThemeForRole(const Color(0xFF9C27B0));

  /// Temas Oscuros
  static ThemeData get _studentDarkTheme => _buildThemeForRole(const Color(0xFF2196F3), brightness: Brightness.dark);
  static ThemeData get _tutorDarkTheme => _buildThemeForRole(const Color(0xFF4CAF50), brightness: Brightness.dark);
  static ThemeData get _adminDarkTheme => _buildThemeForRole(const Color(0xFF9C27B0), brightness: Brightness.dark);
}

/// Widget para mostrar información del rol con estilo
class RoleInfoWidget extends StatelessWidget {
  final UserRole role;
  final String userName;
  final bool showEmoji;
  final bool showGradient;

  const RoleInfoWidget({
    super.key,
    required this.role,
    required this.userName,
    this.showEmoji = true,
    this.showGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleThemes.getPrimaryColorForRole(role);
    final emoji = RoleThemes.getEmojiForRole(role);
    final gradient = RoleThemes.getGradientForRole(role);
    final textTheme = Theme.of(context).textTheme;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showEmoji) ...[
          Text(emoji, style: textTheme.headlineSmall?.copyWith(fontSize: 20)),
          const SizedBox(width: 8),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userName,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              role.displayName,
              style: textTheme.bodyMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );

    if (showGradient) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: content,
      );
    }

    return content;
  }
}

/// Widget para mostrar un badge del rol
class RoleBadge extends StatelessWidget {
  final UserRole role;
  final bool showIcon;

  const RoleBadge({
    super.key,
    required this.role,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleThemes.getPrimaryColorForRole(role);
    final icon = RoleThemes.getIconForRole(role);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 16, color: primaryColor),
            const SizedBox(width: 4),
          ],
          Text(
            role.displayName,
            style: textTheme.labelSmall?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
