import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'app_top_bar.dart';
import 'app_side_drawer.dart';

/// Widget que proporciona un Scaffold consistente con drawer persistente
/// para todas las pantallas de la aplicación
class PersistentScaffold extends StatelessWidget {
  final String title;
  final String titleKey;
  final User user;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final FloatingActionButton? floatingActionButton;
  final Color? backgroundColor;

  const PersistentScaffold({
    super.key,
    required this.title,
    required this.titleKey,
    required this.user,
    required this.body,
    this.actions,
    this.bottom,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        user: user,
        titleKey: titleKey,
        actions: actions,
        bottom: bottom,
      ),
      drawer: AppSideDrawer(user: user),
      body: body,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
    );
  }
}
