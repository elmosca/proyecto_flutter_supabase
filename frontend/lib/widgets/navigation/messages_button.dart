import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';
import '../../services/anteprojects_service.dart';
import '../../services/projects_service.dart';
import '../../l10n/app_localizations.dart';

/// Botón de mensajes que se muestra:
/// - Para estudiantes: Si tienen al menos un anteproyecto o proyecto
/// - Para tutores: Siempre (para ver mensajes de sus estudiantes)
/// - Para admins: No se muestra
class MessagesButton extends StatefulWidget {
  final User user;

  const MessagesButton({super.key, required this.user});

  @override
  State<MessagesButton> createState() => _MessagesButtonState();
}

class _MessagesButtonState extends State<MessagesButton> {
  bool _shouldShow = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfShouldShow();
  }

  Future<void> _checkIfShouldShow() async {
    // Para tutores, siempre mostrar
    if (widget.user.role == UserRole.tutor) {
      setState(() {
        _shouldShow = true;
        _isLoading = false;
      });
      return;
    }

    // Para admins, no mostrar
    if (widget.user.role == UserRole.admin) {
      setState(() {
        _shouldShow = false;
        _isLoading = false;
      });
      return;
    }

    // Para estudiantes, verificar si tienen proyectos
    if (widget.user.role == UserRole.student) {
      try {
        final anteprojectsService = AnteprojectsService();
        final projectsService = ProjectsService();

        final anteprojects = await anteprojectsService.getStudentAnteprojects();
        final projects = await projectsService.getStudentProjects();

        if (mounted) {
          setState(() {
            _shouldShow = anteprojects.isNotEmpty || projects.isNotEmpty;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('❌ Error al verificar proyectos: $e');
        if (mounted) {
          setState(() {
            _shouldShow = false;
            _isLoading = false;
          });
        }
      }
    }
  }

  void _openMessagesSelector() {
    final targetRoute = widget.user.role == UserRole.student
        ? '/student/messages'
        : '/tutor/messages';
    
    // Verificar si hay pantallas en el stack de navegación que podemos cerrar
    // para volver a la pantalla principal de mensajes
    if (Navigator.of(context).canPop()) {
      // Pop todas las pantallas superpuestas hasta llegar a la raíz
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    
    // Navegar a la pantalla de mensajes (siempre, para asegurar que llegamos)
    Future.microtask(() {
      if (mounted) {
        context.go(targetRoute, extra: widget.user);
    }
    });
  }

  String _getTooltip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.user.role == UserRole.tutor) {
      return l10n.tutorMessages;
    }
    return l10n.studentMessages;
  }

  @override
  Widget build(BuildContext context) {
    // No mostrar nada si está cargando o no debe mostrarse
    if (_isLoading || !_shouldShow) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: const Icon(Icons.chat_bubble),
      tooltip: _getTooltip(context),
      onPressed: _openMessagesSelector,
    );
  }
}

