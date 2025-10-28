import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth_bloc.dart';
import '../../models/anteproject.dart';
import '../../models/project.dart';
import '../../models/user.dart';
import '../../services/anteprojects_service.dart';
import '../../services/projects_service.dart';
import '../../l10n/app_localizations.dart';
import '../anteprojects/anteproject_detail_screen.dart';

class MyAnteprojectsList extends StatefulWidget {
  final User? user;

  const MyAnteprojectsList({super.key, this.user});

  @override
  State<MyAnteprojectsList> createState() => _MyAnteprojectsListState();
}

class _MyAnteprojectsListState extends State<MyAnteprojectsList> {
  late AnteprojectsService _anteprojectsService;
  late Future<List<Anteproject>> _anteprojectsFuture;

  @override
  void initState() {
    super.initState();
    _anteprojectsService = AnteprojectsService();
    debugPrint(
      '🎯 MyAnteprojectsList: initState - Iniciando carga de anteproyectos',
    );
    _loadAnteprojects();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar cada vez que volvemos a esta pantalla
    debugPrint(
      '🎯 MyAnteprojectsList: didChangeDependencies - Recargando datos',
    );
    _loadAnteprojects();
  }

  void _loadAnteprojects() {
    if (widget.user != null) {
      debugPrint(
        '🎯 MyAnteprojectsList: Usuario pasado como parámetro: ${widget.user!.email}',
      );
      setState(() {
        _anteprojectsFuture = _anteprojectsService.getStudentAnteprojects();
      });
    } else {
      // Fallback al AuthBloc si no se pasa usuario
      final authState = context.read<AuthBloc>().state;
      debugPrint('🎯 MyAnteprojectsList: AuthState actual: $authState');

      if (authState is AuthAuthenticated) {
        debugPrint(
          '🎯 MyAnteprojectsList: Usuario autenticado: ${authState.user.email}',
        );
        debugPrint(
          '🎯 MyAnteprojectsList: ID del usuario: ${authState.user.id}',
        );
        setState(() {
          _anteprojectsFuture = _anteprojectsService.getStudentAnteprojects();
        });
      } else {
        debugPrint(
          '❌ MyAnteprojectsList: Usuario NO autenticado, authState: ${authState.runtimeType}',
        );
        setState(() {
          _anteprojectsFuture = Future.error('Usuario no autenticado');
        });
      }
    }
  }

  void _loadAndNavigateToProject(
    BuildContext context,
    Anteproject anteproject,
  ) {
    final projectsService = ProjectsService();
    projectsService
        .getProject(anteproject.projectId!)
        .then((project) {
          if (project != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AnteprojectDetailScreen(
                  anteproject: anteproject,
                  project: project,
                ),
              ),
            );
          } else {
            debugPrint('❌ MyAnteprojectsList: Proyecto no encontrado');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se encontró el proyecto')),
            );
          }
        })
        .catchError((error) {
          debugPrint(
            '❌ MyAnteprojectsList: Error al cargar el proyecto: $error',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar el proyecto: $error')),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Anteproject>>(
      future: _anteprojectsFuture,
      builder: (context, snapshot) {
        debugPrint(
          '🎯 MyAnteprojectsList: FutureBuilder estado: ${snapshot.connectionState}',
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('🎯 MyAnteprojectsList: Cargando...');
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('❌ MyAnteprojectsList: Error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadAnteprojects,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          debugPrint('🎯 MyAnteprojectsList: Sin anteproyectos');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No tienes anteproyectos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Cuando crees un anteproyecto, aparecerá aquí',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        final anteprojects = snapshot.data!;
        debugPrint(
          '🎯 MyAnteprojectsList: Mostrando ${anteprojects.length} anteproyectos',
        );
        for (final ap in anteprojects) {
          debugPrint('🎯 MyAnteprojectsList: - ${ap.title} (ID: ${ap.id})');
        }

        return RefreshIndicator(
          onRefresh: () async {
            debugPrint(
              '🎯 MyAnteprojectsList: Refrescando por pull-to-refresh',
            );
            _loadAnteprojects();
            // Esperar a que se cargue
            await _anteprojectsFuture;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: anteprojects.length,
            itemBuilder: (context, index) {
              final anteproject = anteprojects[index];
              final isApproved = anteproject.status.isApproved;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.description,
                    color: isApproved ? Colors.green : Colors.blue,
                  ),
                  title: Text(anteproject.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(anteproject.status.displayName),
                      if (isApproved && anteproject.projectId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Proyecto: #${anteproject.projectId}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: isApproved
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.arrow_forward),
                  onTap: () {
                    if (isApproved) {
                      debugPrint(
                        '🎯 Anteproyecto aprobado, cargando proyecto ${anteproject.projectId}',
                      );
                      _loadAndNavigateToProject(context, anteproject);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AnteprojectDetailScreen(anteproject: anteproject),
                        ),
                      );
                    }
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
