import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../models/project.dart';
import '../../models/anteproject.dart';
import '../../blocs/auth_bloc.dart';
import '../../services/projects_service.dart';
import '../../services/anteprojects_service.dart';
import '../../services/conversation_threads_service.dart';
import '../../widgets/navigation/persistent_scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'conversation_threads_screen.dart';

/// Pantalla para que el tutor seleccione un estudiante y proyecto
/// para ver o responder mensajes
class TutorMessagesSelectorScreen extends StatefulWidget {
  final bool useOwnScaffold;

  const TutorMessagesSelectorScreen({super.key, this.useOwnScaffold = true});

  @override
  State<TutorMessagesSelectorScreen> createState() =>
      _TutorMessagesSelectorScreenState();
}

class _TutorMessagesSelectorScreenState
    extends State<TutorMessagesSelectorScreen> {
  final ProjectsService _projectsService = ProjectsService();
  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  final ConversationThreadsService _threadsService =
      ConversationThreadsService();

  List<_StudentWithProjects> _studentsWithProjects = [];
  bool _isLoading = true;
  String? _errorMessage;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser().then((_) {
      // Solo cargar datos después de verificar que el usuario está autenticado
      if (_currentUser != null) {
        _loadData();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Usuario no autenticado';
        });
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _currentUser = authState.user;
      });
    }
  }

  /// Convierte campos de snake_case a camelCase en un mapa
  void _convertSnakeCaseToCamelCase(Map<String, dynamic> data) {
    final conversions = {
      'tutor_id': 'tutorId',
      'anteproject_id': 'anteprojectId',
      'start_date': 'startDate',
      'estimated_end_date': 'estimatedEndDate',
      'actual_end_date': 'actualEndDate',
      'github_repository_url': 'githubRepositoryUrl',
      'github_main_branch': 'githubMainBranch',
      'last_activity_at': 'lastActivityAt',
      'created_at': 'createdAt',
      'updated_at': 'updatedAt',
    };

    for (final entry in conversions.entries) {
      if (data.containsKey(entry.key) && !data.containsKey(entry.value)) {
        data[entry.value] = data[entry.key];
        data.remove(entry.key);
      }
    }
  }

  /// Normaliza valores numéricos en un mapa
  void _normalizeNumericFields(
    Map<String, dynamic> data,
    List<String> numericFields,
  ) {
    for (final field in numericFields) {
      if (data.containsKey(field) && data[field] != null) {
        try {
          final value = data[field];
          int? finalValue;

          if (value is int) {
            finalValue = value;
          } else if (value is num) {
            finalValue = value.toInt();
          } else {
            // Para tipos especiales de Supabase (minified:As, etc.), convertir a string primero
            final stringValue = value.toString();
            final parsed = int.tryParse(stringValue);
            if (parsed != null) {
              finalValue = parsed;
            }
          }

          if (finalValue != null) {
            data[field] = finalValue;
          }
        } catch (e) {
          // Continuar con el siguiente campo en lugar de fallar completamente
        }
      }
    }
  }

  /// Procesa estudiantes y los agrega al mapa de estudiantes
  void _processStudents(
    List<dynamic> studentsData,
    Map<int, _StudentWithProjects> studentMap,
    Project? project,
    Anteproject? anteproject,
  ) {
    for (final studentData in studentsData) {
      try {
        final userDataRaw = studentData['users'];
        if (userDataRaw == null) continue;

        final userData = _normalizeUserData(userDataRaw);
        final student = User.fromJson(userData);

        if (!studentMap.containsKey(student.id)) {
          studentMap[student.id] = _StudentWithProjects(
            student: student,
            projects: [],
            anteprojects: [],
          );
        }

        if (project != null) {
          studentMap[student.id]!.projects.add(project);
        } else if (anteproject != null) {
          studentMap[student.id]!.anteprojects.add(anteproject);
        }
      } catch (e) {
        debugPrint('❌ Error procesando estudiante: $e');
        continue;
      }
    }
  }

  // Función auxiliar para normalizar IDs en objetos users
  Map<String, dynamic> _normalizeUserData(dynamic userDataRaw) {
    if (userDataRaw == null) {
      throw ArgumentError('userDataRaw no puede ser null');
    }

    // Convertir a Map<String, dynamic> de forma segura
    Map<String, dynamic> userData;
    if (userDataRaw is Map<String, dynamic>) {
      userData = Map<String, dynamic>.from(userDataRaw);
    } else if (userDataRaw is Map) {
      userData = <String, dynamic>{};
      for (final key in userDataRaw.keys) {
        final value = userDataRaw[key];
        userData[key.toString()] = value;
      }
    } else {
      throw ArgumentError(
        'userDataRaw debe ser un Map, pero es: ${userDataRaw.runtimeType}',
      );
    }

    // Normalizar el ID de forma robusta
    if (userData.containsKey('id') && userData['id'] != null) {
      final idValue = userData['id'];
      if (idValue is int) {
        userData['id'] = idValue;
      } else if (idValue is num) {
        userData['id'] = idValue.toInt();
      } else {
        final parsedId = int.tryParse(idValue.toString());
        if (parsedId != null) {
          userData['id'] = parsedId;
        } else {
          debugPrint(
            '⚠️ No se pudo convertir ID: $idValue (tipo: ${idValue.runtimeType})',
          );
          throw ArgumentError('No se pudo convertir ID a int: $idValue');
        }
      }
    } else {
      throw ArgumentError('El objeto userData no contiene un campo "id"');
    }

    // Normalizar tutor_id si existe
    if (userData.containsKey('tutor_id') && userData['tutor_id'] != null) {
      final tutorIdValue = userData['tutor_id'];
      if (tutorIdValue is int) {
        userData['tutor_id'] = tutorIdValue;
      } else if (tutorIdValue is num) {
        userData['tutor_id'] = tutorIdValue.toInt();
      } else {
        final parsedTutorId = int.tryParse(tutorIdValue.toString());
        userData['tutor_id'] = parsedTutorId;
      }
    }

    return userData;
  }

  Future<void> _loadData() async {
    // Verificar que el usuario esté autenticado antes de cargar datos
    if (_currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Usuario no autenticado';
        });
      }
      return;
    }

    // Verificar que el widget sigue montado antes de continuar
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verificar nuevamente que el usuario esté autenticado antes de hacer las llamadas
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Sesión expirada. Por favor, inicia sesión nuevamente.';
          });
        }
        return;
      }

      // Obtener todos los proyectos y anteproyectos del tutor
      final projects = await _projectsService.getTutorProjects();

      // Verificar que el widget sigue montado después de cada operación asíncrona
      if (!mounted) return;

      final anteprojects = await _anteprojectsService.getTutorAnteprojects();

      // Verificar que el widget sigue montado después de cada operación asíncrona
      if (!mounted) return;

      // Obtener los IDs de proyectos y anteproyectos que tienen hilos de conversación
      final projectsWithThreads = await _threadsService
          .getProjectsWithThreads();

      // Verificar que el widget sigue montado después de cada operación asíncrona
      if (!mounted) return;

      final anteprojectsWithThreads = await _threadsService
          .getAnteprojectsWithThreads();

      // Verificar que el widget sigue montado después de cada operación asíncrona
      if (!mounted) return;

      // Agrupar por estudiante
      final Map<int, _StudentWithProjects> studentMap = {};

      // Procesar proyectos aprobados (ahora incluyen información del estudiante directamente desde project_students)
      for (final projectData in projects) {
        try {
          // Crear una copia del mapa para parsear el proyecto
          final projectMap = Map<String, dynamic>.from(projectData);

          // Convertir nombres de campos de snake_case a camelCase
          _convertSnakeCaseToCamelCase(projectMap);

          // Normalizar campos numéricos antes de parsear (ahora en camelCase)
          _normalizeNumericFields(projectMap, [
            'id',
            'tutorId',
            'anteprojectId',
          ]);

          // Extraer información de estudiantes directamente desde project_students
          final projectStudents =
              projectMap['project_students'] as List<dynamic>?;

          // Remover relaciones anidadas para parsear el proyecto
          projectMap.remove('project_students');
          projectMap.remove('anteprojects');

          final project = Project.fromJson(projectMap);

          // Procesar proyectos que tienen hilos directamente O cuyo anteproyecto asociado tiene hilos
          final hasDirectThreads = projectsWithThreads.contains(project.id);
          final hasAnteprojectThreads =
              project.anteprojectId != null &&
              anteprojectsWithThreads.contains(project.anteprojectId);

          if (!hasDirectThreads && !hasAnteprojectThreads) {
            continue;
          }

          // Procesar estudiantes del proyecto directamente desde project_students
          if (projectStudents != null && projectStudents.isNotEmpty) {
            _processStudents(projectStudents, studentMap, project, null);
          } else {
            // Si no hay estudiantes en project_students, intentar obtenerlos del anteproyecto como fallback
            final anteprojects =
                projectData['anteprojects'] as Map<String, dynamic>?;
            final anteprojectStudents =
                anteprojects?['anteproject_students'] as List<dynamic>?;

            if (anteprojectStudents != null && anteprojectStudents.isNotEmpty) {
              _processStudents(anteprojectStudents, studentMap, project, null);
            }
          }
        } catch (e) {
          debugPrint('❌ Error procesando proyecto: $e');
          continue;
        }
      }

      // Procesar anteproyectos (ahora incluyen información del estudiante)
      // Filtrar anteproyectos aprobados - solo mostrar los que no están aprobados
      for (final anteprojectData in anteprojects) {
        try {
          // Crear una copia del mapa sin las relaciones anidadas para parsear
          final anteprojectMap = Map<String, dynamic>.from(anteprojectData);

          // Verificar el estado antes de procesar
          final status = anteprojectMap['status'] as String?;
          if (status == 'approved') {
            // Saltar anteproyectos aprobados - ya aparecen como proyectos
            continue;
          }

          // Normalizar campos numéricos antes de parsear
          _normalizeNumericFields(anteprojectMap, [
            'id',
            'tutor_id',
            'project_id',
          ]);

          // Extraer información del estudiante antes de removerla
          final anteprojectStudents =
              anteprojectMap['anteproject_students'] as List<dynamic>?;
          // Remover relaciones anidadas para parsear el anteproyecto
          anteprojectMap.remove('anteproject_students');

          final anteproject = Anteproject.fromJson(anteprojectMap);

          // Solo procesar anteproyectos que tienen hilos de conversación
          if (!anteprojectsWithThreads.contains(anteproject.id)) {
            continue;
          }

          if (anteprojectStudents != null && anteprojectStudents.isNotEmpty) {
            _processStudents(
              anteprojectStudents,
              studentMap,
              null,
              anteproject,
            );
          }
        } catch (e) {
          debugPrint('❌ Error procesando anteproyecto: $e');
          continue;
        }
      }

      if (mounted) {
        setState(() {
          _studentsWithProjects = studentMap.values.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar estudiantes y proyectos: $e');

      // Si el widget ya no está montado (por ejemplo, el usuario se desconectó), no hacer nada
      if (!mounted) return;

      // Verificar si el error es de autenticación
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        // Si el usuario se desconectó, no mostrar error, simplemente salir
        return;
      }

      // Para otros errores, mostrar mensaje
      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
  }

  void _openProjectChat(Project project) {
    if (_currentUser == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return PersistentScaffold(
            title: l10n.conversations,
            titleKey: 'conversations',
            user: _currentUser!,
            body: ConversationThreadsScreen(
              project: project,
              useOwnScaffold: false,
            ),
          );
        },
      ),
    );
  }

  void _openAnteprojectChat(Anteproject anteproject) {
    if (_currentUser == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return PersistentScaffold(
            title: l10n.conversations,
            titleKey: 'conversations',
            user: _currentUser!,
            body: ConversationThreadsScreen(
              anteproject: anteproject,
              useOwnScaffold: false,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
        ? _buildErrorState()
        : _studentsWithProjects.isEmpty
        ? _buildEmptyState()
        : _buildStudentsList();

    final l10n = AppLocalizations.of(context)!;

    if (widget.useOwnScaffold) {
      return PersistentScaffold(
        title: l10n.tutorMessages,
        titleKey: 'tutorMessages',
        user: _currentUser!,
        body: body,
      );
    }

    return body;
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: Text(l10n.retry)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            l10n.noStudentsAssigned,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.waitForStudentsAssignment,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado informativo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.selectProjectOrAnteprojectMessage,
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Lista de estudiantes
          ..._studentsWithProjects.map(
            (studentData) => _buildStudentCard(studentData),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(_StudentWithProjects studentData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.person, color: Colors.green.shade700),
        ),
        title: Text(
          studentData.student.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          studentData.student.email,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        children: [
          const Divider(),

          // Proyectos aprobados
          if (studentData.projects.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Proyectos Aprobados',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            ...studentData.projects.map(
              (project) => ListTile(
                dense: true,
                leading: const SizedBox(width: 24),
                title: Text(
                  project.title,
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chat_bubble, color: Colors.green),
                  onPressed: () => _openProjectChat(project),
                  tooltip: 'Ver mensajes',
                ),
              ),
            ),
          ],

          // Anteproyectos
          if (studentData.anteprojects.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Anteproyectos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            ...studentData.anteprojects.map(
              (anteproject) => ListTile(
                dense: true,
                leading: const SizedBox(width: 24),
                title: Text(
                  anteproject.title,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  'Estado: ${anteproject.status.displayName}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chat_bubble, color: Colors.green),
                  onPressed: () => _openAnteprojectChat(anteproject),
                  tooltip: 'Ver mensajes',
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Clase auxiliar para agrupar estudiantes con sus proyectos
class _StudentWithProjects {
  final User student;
  final List<Project> projects;
  final List<Anteproject> anteprojects;

  _StudentWithProjects({
    required this.student,
    required this.projects,
    required this.anteprojects,
  });
}
