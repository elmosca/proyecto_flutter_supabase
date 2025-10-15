import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../services/projects_service.dart';

class TaskContextSelection {
  final int? projectId;
  final int? anteprojectId;

  const TaskContextSelection({this.projectId, this.anteprojectId})
    : assert(projectId != null || anteprojectId != null);
}

Future<TaskContextSelection?> showProjectContextDialog(
  BuildContext context, {
  required ProjectsService projectsService,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final navigator = Navigator.of(context);

  List<Project> projects = [];

  try {
    // Para tutores, obtener todos los proyectos
    // Para estudiantes, obtener su proyecto asignado
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      debugPrint('🔍 Usuario autenticado: ${user.email}');

      // Verificar si es tutor o estudiante
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('email', user.email!)
          .single();

      final userRole = userResponse['role'] as String;
      debugPrint('🔍 Rol del usuario: $userRole');

      if (userRole == 'tutor') {
        // Los tutores pueden ver todos los proyectos
        projects = await projectsService.getProjects();
        debugPrint('🔍 Proyectos para tutor: ${projects.length}');
      } else {
        // Los estudiantes solo ven su proyecto asignado
        final project = await projectsService.getUserProject();
        debugPrint(
          '🔍 Proyecto del estudiante: ${project?.id} - ${project?.title}',
        );
        if (project != null) {
          projects = [project];
        }
      }
    }
  } catch (e) {
    debugPrint('❌ Error en showProjectContextDialog: $e');
  }

  if (projects.isEmpty) {
    if (!context.mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.noProjectAssigned),
        backgroundColor: Colors.orange,
      ),
    );
    return null;
  }

  if (!context.mounted) return null;

  return showDialog<TaskContextSelection>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.selectProjectForTasks),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ContextSection<Project>(
                title: l10n.projects,
                items: projects,
                itemBuilder: (project) => ListTile(
                  title: Text(project.title),
                  subtitle: Text(project.status.displayName),
                  onTap: () => navigator.pop(
                    TaskContextSelection(projectId: project.id),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: navigator.pop, child: Text(l10n.cancel)),
        ],
      );
    },
  );
}

class _ContextSection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Widget Function(T) itemBuilder;

  const _ContextSection({
    required this.title,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        for (final item in items) itemBuilder(item),
      ],
    );
  }
}
