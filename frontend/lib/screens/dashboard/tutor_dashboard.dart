import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../blocs/auth_bloc.dart';
import '../../services/theme_service.dart';
import '../../services/user_service.dart';
import '../../services/anteprojects_service.dart';
import '../../services/settings_service.dart';
import '../../models/anteproject.dart';
import '../../widgets/dialogs/add_students_dialog.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/navigation/app_side_drawer.dart';

class TutorDashboard extends StatefulWidget {
  final User user;
  final bool useOwnScaffold;

  const TutorDashboard({
    super.key,
    required this.user,
    this.useOwnScaffold = true,
  });

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  bool _isLoading = true;
  Timer? _loadingTimer;
  List<User> _students = [];
  List<Map<String, dynamic>> _anteprojectsData = [];
  String _selectedAcademicYear = ''; // Se cargará dinámicamente
  final UserService _userService = UserService();
  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Verificar que el widget sigue montado antes de continuar
    if (!mounted) return;

    try {
      // Verificar que el usuario esté autenticado antes de hacer las llamadas
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        // Si el usuario se desconectó, no hacer nada
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Intentar cargar el año académico del sistema primero si no está establecido
      if (_selectedAcademicYear.isEmpty) {
        try {
          final systemYear = await _settingsService.getStringSetting('academic_year');
          if (systemYear != null && systemYear.isNotEmpty) {
            _selectedAcademicYear = systemYear;
          } else {
            // Fallback
            final now = DateTime.now();
            _selectedAcademicYear = '${now.year}-${now.year + 1}';
          }
        } catch (e) {
          debugPrint('Error loading system academic year: $e');
          // Fallback silencioso
          final now = DateTime.now();
          _selectedAcademicYear = '${now.year}-${now.year + 1}';
        }
      }

      // Cargar estudiantes y anteproyectos del tutor en paralelo
      final futures = await Future.wait([
        _userService.getStudentsByTutor(widget.user.id),
        _anteprojectsService.getTutorAnteprojects(),
      ]);

      // Verificar que el widget sigue montado después de las operaciones asíncronas
      if (!mounted) return;

      final students = futures[0] as List<User>;
      final anteprojectsData = futures[1] as List<Map<String, dynamic>>;

      if (mounted) {
        setState(() {
          _students = students;
          _anteprojectsData = anteprojectsData;

          // Inicializar el año académico seleccionado si no está disponible
          final availableYears = <String>{};
          for (final student in students) {
            if (student.academicYear != null &&
                student.academicYear!.isNotEmpty) {
              availableYears.add(student.academicYear!);
            }
          }
          for (final anteprojectData in anteprojectsData) {
            try {
              // Función auxiliar para convertir de forma segura objetos minificados de Supabase
              Map<String, dynamic> safeConvert(dynamic data) {
                if (data is Map<String, dynamic>) {
                  return data;
                } else if (data is Map) {
                  // Convertir Map genérico a Map<String, dynamic>
                  final result = <String, dynamic>{};
                  data.forEach((key, value) {
                    result[key.toString()] = value;
                  });
                  return result;
                } else {
                  // Para objetos minificados, intentar casting directo
                  try {
                    final map = data as Map;
                    final result = <String, dynamic>{};
                    for (final key in map.keys) {
                      result[key.toString()] = map[key];
                    }
                    return result;
                  } catch (e) {
                    return <String, dynamic>{};
                  }
                }
              }

              // Convertir de forma segura
              final anteprojectMap = safeConvert(anteprojectData);
              // Remover relaciones anidadas que no están en el modelo Anteproject
              anteprojectMap.remove('anteproject_students');

              // Si el mapa está vacío, saltar este anteproyecto
              if (anteprojectMap.isEmpty) {
                continue;
              }

              final anteproject = Anteproject.fromJson(anteprojectMap);
              availableYears.add(anteproject.academicYear);
            } catch (e) {
              debugPrint('Error parseando anteproyecto en _loadData: $e');
              debugPrint('   Tipo del dato: ${anteprojectData.runtimeType}');
              // Continuar con el siguiente anteproyecto
            }
          }

          // Solo cambiar el año si no hay datos para el año actual
          if (availableYears.isNotEmpty &&
              !availableYears.contains(_selectedAcademicYear)) {
            // Buscar el año más reciente que tenga datos
            final sortedYears = availableYears.toList()
              ..sort((a, b) => b.compareTo(a));
            _selectedAcademicYear = sortedYears.first;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar datos: $e');

      // Si el widget ya no está montado (por ejemplo, el usuario se desconectó), no hacer nada
      if (!mounted) return;

      // Verificar si el error es de autenticación
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        // Si el usuario se desconectó, no mostrar error, simplemente salir
        return;
      }

      // Para otros errores, actualizar el estado
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<User> get _filteredStudents {
    return _students.where((student) {
      return student.academicYear == _selectedAcademicYear;
    }).toList();
  }

  List<Map<String, dynamic>> get _pendingAnteprojects {
    return _anteprojectsData.where((anteprojectData) {
      try {
        // Función auxiliar para convertir de forma segura objetos minificados de Supabase
        Map<String, dynamic> safeConvert(dynamic data) {
          if (data is Map<String, dynamic>) {
            return data;
          } else if (data is Map) {
            final result = <String, dynamic>{};
            data.forEach((key, value) {
              result[key.toString()] = value;
            });
            return result;
          } else {
            try {
              final map = data as Map;
              final result = <String, dynamic>{};
              map.forEach((key, value) {
                result[key.toString()] = value;
              });
              return result;
            } catch (e) {
              return <String, dynamic>{};
            }
          }
        }

        // Convertir de forma segura
        final anteprojectMap = safeConvert(anteprojectData);
        anteprojectMap.remove('anteproject_students');

        // Si el mapa está vacío, excluir este anteproyecto
        if (anteprojectMap.isEmpty) {
          return false;
        }

        final anteproject = Anteproject.fromJson(anteprojectMap);
        return anteproject.status == AnteprojectStatus.submitted ||
            anteproject.status == AnteprojectStatus.underReview;
      } catch (e) {
        debugPrint('Error parseando anteproyecto en _pendingAnteprojects: $e');
        debugPrint('   Tipo del dato: ${anteprojectData.runtimeType}');
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> get _reviewedAnteprojects {
    return _anteprojectsData.where((anteprojectData) {
      try {
        // Función auxiliar para convertir de forma segura objetos minificados de Supabase
        Map<String, dynamic> safeConvert(dynamic data) {
          if (data is Map<String, dynamic>) {
            return data;
          } else if (data is Map) {
            final result = <String, dynamic>{};
            data.forEach((key, value) {
              result[key.toString()] = value;
            });
            return result;
          } else {
            try {
              final map = data as Map;
              final result = <String, dynamic>{};
              map.forEach((key, value) {
                result[key.toString()] = value;
              });
              return result;
            } catch (e) {
              return <String, dynamic>{};
            }
          }
        }

        // Convertir de forma segura
        final anteprojectMap = safeConvert(anteprojectData);
        anteprojectMap.remove('anteproject_students');

        // Si el mapa está vacío, excluir este anteproyecto
        if (anteprojectMap.isEmpty) {
          return false;
        }

        final anteproject = Anteproject.fromJson(anteprojectMap);
        return anteproject.status == AnteprojectStatus.approved ||
            anteproject.status == AnteprojectStatus.rejected;
      } catch (e) {
        debugPrint('Error parseando anteproyecto en _reviewedAnteprojects: $e');
        debugPrint('   Tipo del dato: ${anteprojectData.runtimeType}');
        return false;
      }
    }).toList();
  }

  List<String> get _availableAcademicYears {
    final years = <String>{};

    // Añadir años de estudiantes
    for (final student in _students) {
      if (student.academicYear != null && student.academicYear!.isNotEmpty) {
        years.add(student.academicYear!);
      }
    }

    // Añadir años de anteproyectos
    for (final anteprojectData in _anteprojectsData) {
      try {
        // Función auxiliar para convertir de forma segura objetos minificados de Supabase
        Map<String, dynamic> safeConvert(dynamic data) {
          if (data is Map<String, dynamic>) {
            return data;
          } else if (data is Map) {
            final result = <String, dynamic>{};
            data.forEach((key, value) {
              result[key.toString()] = value;
            });
            return result;
          } else {
            try {
              final map = data as Map;
              final result = <String, dynamic>{};
              map.forEach((key, value) {
                result[key.toString()] = value;
              });
              return result;
            } catch (e) {
              return <String, dynamic>{};
            }
          }
        }

        // Convertir de forma segura
        final anteprojectMap = safeConvert(anteprojectData);
        anteprojectMap.remove('anteproject_students');

        // Si el mapa está vacío, saltar este anteproyecto
        if (anteprojectMap.isEmpty) {
          continue;
        }

        final anteproject = Anteproject.fromJson(anteprojectMap);
        years.add(anteproject.academicYear);
      } catch (e) {
        debugPrint(
          'Error parseando anteproyecto en _availableAcademicYears: $e',
        );
        debugPrint('   Tipo del dato: ${anteprojectData.runtimeType}');
        // Continuar con el siguiente anteproyecto
      }
    }

    // Si no hay años, usar el año actual por defecto
    if (years.isEmpty) {
      final currentYear = DateTime.now().year;
      years.add('$currentYear-${currentYear + 1}');
    }

    // Ordenar años de más reciente a más antiguo
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    return sortedYears;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _buildDashboardContent();

    if (!widget.useOwnScaffold) {
      return body;
    }

    return Scaffold(
      appBar: AppTopBar(user: widget.user, titleKey: 'dashboardTutor'),
      drawer: AppSideDrawer(user: widget.user),
      body: body,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _navigateToApprovalWorkflow,
            backgroundColor: ThemeService.instance.currentPrimaryColor,
            tooltip: l10n.approvalWorkflow,
            heroTag: 'approval',
            child: const Icon(Icons.gavel, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _reviewAnteprojects,
            backgroundColor: ThemeService.instance.currentAccentColor,
            tooltip: l10n.dashboardTutorMyAnteprojects,
            heroTag: 'review',
            child: const Icon(Icons.assignment, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfo(),
        const SizedBox(height: 24),
        _buildStatistics(),
        const SizedBox(height: 24),
        _buildStudentsSection(),
      ],
    ),
  );

  Widget _buildUserInfo() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(AppConfig.platformColor),
              child: Text(
                widget.user.email.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ID: ${widget.user.id}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(AppConfig.platformColor).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(AppConfig.platformColor).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          l10n.tutor,
                          style: const TextStyle(
                            color: Color(AppConfig.platformColor),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (widget.user.academicYear != null &&
                          widget.user.academicYear!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            'Curso ${widget.user.academicYear}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: l10n.pendingAnteprojects,
            value: _pendingAnteprojects.length.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
            onTap: _reviewAnteprojects,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: l10n.assignedStudents,
            value: _students.length.toString(),
            icon: Icons.people,
            color: Colors.blue,
            onTap: _viewAllStudents,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: l10n.reviewed,
            value: _reviewedAnteprojects.length.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: _viewAllAnteprojects,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.assignedStudents,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                // Filtro por año académico dinámico
                DropdownButton<String>(
                  value: _availableAcademicYears.contains(_selectedAcademicYear)
                      ? _selectedAcademicYear
                      : (_availableAcademicYears.isNotEmpty
                            ? _availableAcademicYears.first
                            : null),
                  items: _availableAcademicYears.map((year) {
                    return DropdownMenuItem(value: year, child: Text(year));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAcademicYear = value;
                      });
                      // Recargar datos cuando cambie el año académico
                      _loadData();
                    }
                  },
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _viewAllStudents,
                  child: Text(AppLocalizations.of(context)!.viewAll),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Botón principal para añadir estudiantes
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showAddStudentsDialog,
            icon: const Icon(Icons.person_add),
            label: Text(AppLocalizations.of(context)!.addStudents),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Información de estudiantes actuales
        if (_filteredStudents.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.studentsAssignedInfo(
                      _filteredStudents.length,
                      _filteredStudents.length == 1 ? '' : 's',
                      _selectedAcademicYear,
                    ),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showAddStudentsDialog() {
    showDialog(
      context: context,
      builder: (context) => AddStudentsDialog(tutorId: widget.user.id),
    ).then((_) => _loadData()); // Recargar datos al cerrar el diálogo
  }

  // Logout ahora gestionado por AppTopBar

  void _navigateToApprovalWorkflow() {
    // Usar la ruta del router para navegación consistente
    context.go('/approval-workflow', extra: widget.user);
  }

  void _reviewAnteprojects() {
    // Navegar a la pantalla de anteproyectos (se abrirá con todos los filtros disponibles)
    context.go('/anteprojects', extra: widget.user);
  }

  void _viewAllAnteprojects() {
    // Navegar a la pantalla de anteproyectos (se abrirá con todos los filtros disponibles)
    context.go('/anteprojects', extra: widget.user);
  }

  void _viewAllStudents() {
    // Navegar a la pantalla de mis estudiantes
    context.go('/students', extra: widget.user);
  }
}
