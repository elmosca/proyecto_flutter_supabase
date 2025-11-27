import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../models/user.dart';
import '../../services/anteprojects_service.dart';
import '../../services/projects_service.dart';
import '../anteprojects/anteproject_detail_screen.dart';

class StudentProjectsList extends StatefulWidget {
  final User? user;

  const StudentProjectsList({super.key, this.user});

  @override
  State<StudentProjectsList> createState() => _StudentProjectsListState();
}

class _StudentProjectsListState extends State<StudentProjectsList> {
  late ProjectsService _projectsService;
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsService = ProjectsService();
    debugPrint(
      '🎯 StudentProjectsList: initState - Iniciando carga de proyectos',
    );
    _loadProjects();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar cada vez que volvemos a esta pantalla
    debugPrint(
      '🎯 StudentProjectsList: didChangeDependencies - Recargando datos',
    );
    _loadProjects();
  }

  void _loadProjects() {
    debugPrint('🎯 StudentProjectsList: Cargando proyectos del estudiante');
    setState(() {
      _projectsFuture = _projectsService.getStudentProjects();
    });
  }

  void _navigateToProjectDetails(BuildContext context, Project project) {
    if (project.anteprojectId == null) {
      debugPrint(
        '❌ StudentProjectsList: El proyecto no tiene anteproyecto asociado',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se encontró el anteproyecto asociado'),
        ),
      );
      return;
    }

    final anteprojectsService = AnteprojectsService();
    anteprojectsService
        .getAnteproject(project.anteprojectId!)
        .then((anteproject) {
          if (anteproject != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AnteprojectDetailScreen(
                  anteproject: anteproject,
                  project: project,
                ),
              ),
            );
          } else {
            debugPrint('❌ StudentProjectsList: No se encontró el anteproyecto');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: No se pudo cargar el anteproyecto'),
              ),
            );
          }
        })
        .catchError((error) {
          debugPrint(
            '❌ StudentProjectsList: Error al cargar anteproyecto: $error',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar anteproyecto: $error')),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Project>>(
      future: _projectsFuture,
      builder: (context, snapshot) {
        debugPrint(
          '🎯 StudentProjectsList: FutureBuilder estado: ${snapshot.connectionState}',
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('🎯 StudentProjectsList: Cargando...');
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('❌ StudentProjectsList: Error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadProjects,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          debugPrint('🎯 StudentProjectsList: Sin proyectos');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text('No tienes proyectos aprobados'),
                const SizedBox(height: 8),
                Text(
                  'Cuando tus anteproyectos sean aprobados, aparecerán aquí',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        final projects = snapshot.data!;
        debugPrint(
          '🎯 StudentProjectsList: Mostrando ${projects.length} proyectos',
        );
        for (final p in projects) {
          debugPrint('🎯 StudentProjectsList: - ${p.title} (ID: ${p.id})');
        }

        return RefreshIndicator(
          onRefresh: () async {
            debugPrint(
              '🎯 StudentProjectsList: Refrescando por pull-to-refresh',
            );
            _loadProjects();
            // Esperar a que se cargue
            await _projectsFuture;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.folder, color: Colors.blue),
                  title: Text(project.title),
                  subtitle: Text(project.status.toString().split('.').last),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    _navigateToProjectDetails(context, project);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
