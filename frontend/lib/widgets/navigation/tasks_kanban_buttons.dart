import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';
import '../../services/projects_service.dart';
import '../../l10n/app_localizations.dart';

/// Botones de navegación rápida para Tareas y Kanban que se muestran:
/// - Para estudiantes: Solo si tienen al menos un proyecto aprobado
/// - Para tutores y admins: No se muestran (funcionalidad exclusiva de estudiantes)
class TasksKanbanButtons extends StatefulWidget {
  final User user;

  const TasksKanbanButtons({super.key, required this.user});

  @override
  State<TasksKanbanButtons> createState() => _TasksKanbanButtonsState();
}

class _TasksKanbanButtonsState extends State<TasksKanbanButtons> {
  bool _shouldShow = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfShouldShow();
  }

  Future<void> _checkIfShouldShow() async {
    // Solo mostrar para estudiantes
    if (widget.user.role != UserRole.student) {
      setState(() {
        _shouldShow = false;
        _isLoading = false;
      });
      return;
    }

    // Para estudiantes, verificar si tienen proyectos aprobados
    try {
      final projectsService = ProjectsService();
      final projects = await projectsService.getStudentProjects();

      if (mounted) {
        setState(() {
          // Solo mostrar si tienen al menos un proyecto (que indica que tienen un anteproyecto aprobado)
          _shouldShow = projects.isNotEmpty;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al verificar proyectos para Tareas/Kanban: $e');
      if (mounted) {
        setState(() {
          _shouldShow = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // No mostrar nada si está cargando o no debe mostrarse
    if (_isLoading || !_shouldShow) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.task_alt),
          tooltip: l10n.tasks,
          onPressed: () {
            context.go('/tasks', extra: widget.user);
          },
        ),
        IconButton(
          icon: const Icon(Icons.view_kanban),
          tooltip: l10n.kanbanBoard,
          onPressed: () {
            context.go('/kanban', extra: widget.user);
          },
        ),
      ],
    );
  }
}

