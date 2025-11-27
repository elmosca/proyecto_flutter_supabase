import 'package:flutter/material.dart';
import '../../models/anteproject.dart';
import '../../models/project.dart';
import '../../screens/anteprojects/anteproject_messages_screen.dart';
import '../../screens/projects/project_messages_screen.dart';

/// Botón flotante para chat con el tutor
/// 
/// Puede usarse con anteproyectos o proyectos aprobados.
/// Muestra un badge con el número de mensajes no leídos.
class FloatingChatButton extends StatelessWidget {
  final Anteproject? anteproject;
  final Project? project;
  final int? unreadCount;
  final VoidCallback? onPressed;

  const FloatingChatButton({
    super.key,
    this.anteproject,
    this.project,
    this.unreadCount,
    this.onPressed,
  }) : assert(
          anteproject != null || project != null,
          'Debe proporcionar un anteproyecto o un proyecto',
        );

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed ?? () => _openChat(context),
      backgroundColor: _getBackgroundColor(),
      foregroundColor: Colors.white,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.chat_bubble, size: 24),
          if (unreadCount != null && unreadCount! > 0)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    unreadCount! > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      label: const Text(
        'Contactar Tutor',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      tooltip: 'Enviar mensaje al tutor',
    );
  }

  Color _getBackgroundColor() {
    if (project != null) {
      return Colors.green; // Verde para proyectos aprobados
    }
    return Colors.blue; // Azul para anteproyectos
  }

  void _openChat(BuildContext context) {
    if (anteproject != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AnteprojectMessagesScreen(
            anteproject: anteproject!,
          ),
        ),
      );
    } else if (project != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProjectMessagesScreen(
            project: project!,
          ),
        ),
      );
    }
  }
}

/// Versión compacta del botón flotante (solo ícono)
class FloatingChatButtonCompact extends StatelessWidget {
  final Anteproject? anteproject;
  final Project? project;
  final int? unreadCount;
  final VoidCallback? onPressed;

  const FloatingChatButtonCompact({
    super.key,
    this.anteproject,
    this.project,
    this.unreadCount,
    this.onPressed,
  }) : assert(
          anteproject != null || project != null,
          'Debe proporcionar un anteproyecto o un proyecto',
        );

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () => _openChat(context),
      backgroundColor: _getBackgroundColor(),
      foregroundColor: Colors.white,
      tooltip: 'Contactar Tutor',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.chat_bubble),
          if (unreadCount != null && unreadCount! > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    unreadCount! > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (project != null) {
      return Colors.green;
    }
    return Colors.blue;
  }

  void _openChat(BuildContext context) {
    if (anteproject != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AnteprojectMessagesScreen(
            anteproject: anteproject!,
          ),
        ),
      );
    } else if (project != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProjectMessagesScreen(
            project: project!,
          ),
        ),
      );
    }
  }
}

