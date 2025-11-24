import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../router/app_router.dart';
import '../common/language_selector.dart';
import '../notifications/notifications_bell.dart';
import 'messages_button.dart';

/// Widget reutilizable que proporciona las acciones estándar del AppBar
/// incluyendo idioma, notificaciones, mensajes y logout.
/// 
/// Úsalo en cualquier pantalla que necesite estas acciones:
/// ```dart
/// AppBar(
///   title: Text('Mi Pantalla'),
///   actions: AppBarActions.build(context, user),
/// )
/// ```
class AppBarActions {
  /// Construye la lista de acciones estándar para el AppBar
  static List<Widget> build(
    BuildContext context,
    User user, {
    bool showLanguageSelector = true,
    bool showNotifications = true,
    bool showMessages = true,
    bool showLogout = true,
    List<Widget>? additionalActions,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return [
      // Acciones adicionales al inicio (si las hay)
      if (additionalActions != null) ...additionalActions,
      
      // Selector de idioma
      if (showLanguageSelector) const LanguageSelectorAppBar(),
      
      // Campana de notificaciones
      if (showNotifications) NotificationsBell(user: user),
      
      // Botón de mensajes
      if (showMessages) MessagesButton(user: user),
      
      // Botón de logout
      if (showLogout)
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: l10n.logoutTooltip,
          onPressed: () => AppRouter.logout(context),
        ),
    ];
  }

  /// Versión simplificada sin opciones (todo habilitado)
  static List<Widget> standard(BuildContext context, User user) {
    return build(context, user);
  }

  /// Versión sin notificaciones (para pantallas de formularios)
  static List<Widget> withoutNotifications(BuildContext context, User user) {
    return build(context, user, showNotifications: false);
  }

  /// Versión sin mensajes (para pantallas públicas o de admin)
  static List<Widget> withoutMessages(BuildContext context, User user) {
    return build(context, user, showMessages: false);
  }

  /// Versión mínima (solo logout)
  static List<Widget> minimal(BuildContext context, User user) {
    return build(
      context,
      user,
      showLanguageSelector: false,
      showNotifications: false,
      showMessages: false,
    );
  }
}

