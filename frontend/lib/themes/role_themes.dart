import 'package:flutter/material.dart';
import '../models/user.dart';

/// Sistema de temas específicos por rol de usuario
class RoleThemes {
  /// Obtiene el tema específico para un rol
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

  /// Tema para estudiantes (Azul)
  static ThemeData get _studentTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2196F3),
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2196F3),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  /// Tema para tutores (Verde)
  static ThemeData get _tutorTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4CAF50),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  /// Tema para administradores (Púrpura)
  static ThemeData get _adminTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9C27B0),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF9C27B0),
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF9C27B0),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
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

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showEmoji) ...[
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              role.displayName,
              style: TextStyle(
                fontSize: 14,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
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
            style: TextStyle(
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
