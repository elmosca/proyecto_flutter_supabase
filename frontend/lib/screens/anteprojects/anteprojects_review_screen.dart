import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../models/anteproject.dart';
import '../../models/user.dart';
import '../../services/anteprojects_service.dart';
import '../../services/academic_permissions_service.dart';
import '../../widgets/navigation/app_bar_actions.dart';
import 'anteproject_detail_screen.dart';
import 'anteproject_comments_screen.dart';

class AnteprojectsReviewScreen extends StatefulWidget {
  final String? initialFilter;

  /// Si es true, usa Scaffold propio (para Navigator.push desde dashboard)
  /// Si es false, solo retorna el contenido (para usar con PersistentScaffold en router)
  final bool useOwnScaffold;

  const AnteprojectsReviewScreen({
    super.key,
    this.initialFilter,
    this.useOwnScaffold = false,
  });

  @override
  State<AnteprojectsReviewScreen> createState() =>
      _AnteprojectsReviewScreenState();
}

class _AnteprojectsReviewScreenState extends State<AnteprojectsReviewScreen> {
  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  final AcademicPermissionsService _academicPermissionsService = AcademicPermissionsService();
  List<Map<String, dynamic>> _anteprojects = [];
  List<Map<String, dynamic>> _filteredAnteprojects = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  String _selectedAcademicYear = 'all';
  List<String> _academicYears = [];
  String? _activeAcademicYear;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  User? _currentUser;

  Map<String, String> _statusFilters = {};
  
  /// Verifica si el año seleccionado es el activo (permite acciones de escritura)
  bool get _isSelectedYearActive {
    if (_selectedAcademicYear == 'all') return true;
    if (_activeAcademicYear == null) return true;
    return _selectedAcademicYear == _activeAcademicYear;
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    if (widget.initialFilter != null) {
      _selectedStatus = widget.initialFilter!;
      debugPrint('🔍 AnteprojectsReviewScreen: Filtro inicial establecido: ${widget.initialFilter}');
    }
    _loadAnteprojects();
  }

  void _initializeStatusFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _statusFilters = {
      'all': l10n.all,
      'active': l10n.activeAnteprojects,
      'pending': l10n.pending,
      'reviewed': l10n.reviewedPlural,
      'submitted': l10n.statusSubmitted,
      'under_review': l10n.underReview,
      'approved': l10n.approved,
      'rejected': l10n.rejected,
    };
  }

  void _loadCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _currentUser = authState.user;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnteprojects() async {
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

      setState(() {
        _isLoading = true;
      });

      final anteprojects = await _anteprojectsService.getTutorAnteprojects();

      // Verificar que el widget sigue montado después de la operación asíncrona
      if (!mounted) return;

      // Debug: verificar qué datos tenemos después de cargar
      if (anteprojects.isNotEmpty) {
        debugPrint(
          '🔍 Load - Primer anteproyecto claves: ${anteprojects[0].keys.toList()}',
        );
        debugPrint(
          '🔍 Load - Tiene anteproject_students: ${anteprojects[0].containsKey('anteproject_students')}',
        );
        if (anteprojects[0].containsKey('anteproject_students')) {
          debugPrint(
            '🔍 Load - anteproject_students valor: ${anteprojects[0]['anteproject_students']}',
          );
        }
      }

      // Obtener el año académico activo
      final activeYear = await _academicPermissionsService.getActiveAcademicYear();

      if (mounted) {
        setState(() {
          _anteprojects = anteprojects;
          _activeAcademicYear = activeYear;
          _isLoading = false;
        });
        _extractAcademicYears();
        // Aplicar filtros después de cargar los datos
        _filterAnteprojects();
      }
    } catch (e) {
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
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.errorLoadingAnteprojects(e.toString()),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _extractAcademicYears() {
    final years = <String>{};
    for (final anteprojectData in _anteprojects) {
      if (anteprojectData.containsKey('academic_year')) {
        final year = anteprojectData['academic_year']?.toString();
        if (year != null && year.isNotEmpty) {
          years.add(year);
        }
      }
    }

    setState(() {
      _academicYears = years.toList()..sort((a, b) => b.compareTo(a));
      // Si el año seleccionado no está en la lista (y no es 'all'), resetear a 'all'
      if (_selectedAcademicYear != 'all' &&
          !_academicYears.contains(_selectedAcademicYear)) {
        _selectedAcademicYear = 'all';
      }
    });
  }

  void _filterAnteprojects() {
    setState(() {
      // Función auxiliar para convertir objetos minificados de Supabase
      Map<String, dynamic> safeConvertMap(dynamic data) {
        if (data is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data);
        } else if (data is Map) {
          final result = <String, dynamic>{};
          for (final key in data.keys) {
            final value = data[key];
            // Preservar objetos anidados como anteproject_students
            if (value is List) {
              result[key.toString()] = value.map((item) {
                if (item is Map) {
                  final itemResult = <String, dynamic>{};
                  for (final itemKey in item.keys) {
                    itemResult[itemKey.toString()] = item[itemKey];
                  }
                  return itemResult;
                }
                return item;
              }).toList();
            } else if (value is Map) {
              final valueResult = <String, dynamic>{};
              for (final valueKey in value.keys) {
                valueResult[valueKey.toString()] = value[valueKey];
              }
              result[key.toString()] = valueResult;
            } else {
              result[key.toString()] = value;
            }
          }
          return result;
        } else {
          return <String, dynamic>{};
        }
      }

      // Función auxiliar para obtener información del estudiante
      Map<String, dynamic>? getStudentInfo(
        Map<String, dynamic> anteprojectData,
      ) {
        final anteprojectStudents =
            anteprojectData['anteproject_students'] as List<dynamic>?;

        if (anteprojectStudents != null && anteprojectStudents.isNotEmpty) {
          try {
            final firstStudent = anteprojectStudents[0];
            final firstStudentMap = safeConvertMap(firstStudent);

            if (firstStudentMap.containsKey('users')) {
              final usersData = firstStudentMap['users'];
              if (usersData != null) {
                return safeConvertMap(usersData);
              }
            }
          } catch (e) {
            debugPrint('⚠️ Error procesando información del estudiante: $e');
          }
        }
        return null;
      }

      _filteredAnteprojects = _anteprojects
          .where((anteprojectData) {
            try {
              // Crear una copia del mapa para parsear sin modificar el original
              final anteprojectMapForParsing = safeConvertMap(anteprojectData);
              final anteprojectMapCopy = Map<String, dynamic>.from(
                anteprojectMapForParsing,
              );
              anteprojectMapCopy.remove('anteproject_students');

              if (anteprojectMapCopy.isEmpty) {
                return false;
              }

              final anteproject = Anteproject.fromJson(anteprojectMapCopy);

              // Obtener información del estudiante para búsqueda
              final studentInfo = getStudentInfo(anteprojectData);
              final studentName = studentInfo?['full_name'] ?? '';
              final studentEmail = studentInfo?['email'] ?? '';

              // Filtro por año académico
              if (_selectedAcademicYear != 'all' &&
                  anteproject.academicYear != _selectedAcademicYear) {
                return false;
              }

              // Filtro por estado
              // IMPORTANTE: Los borradores (draft) NO deben aparecer en la revisión del tutor
              // excepto cuando se filtra por "active" que incluye todos los estados activos
              bool excludeDraft = true;
              if (_selectedStatus == 'active') {
                excludeDraft = false; // Incluir borradores cuando se filtra por activos
              }
              
              if (excludeDraft && anteproject.status == AnteprojectStatus.draft) {
                return false; // Excluir borradores en otros filtros
              }

              bool statusMatch;
              if (_selectedStatus == 'all') {
                // "Todos" excluye borradores (ya filtrados arriba)
                statusMatch = true;
              } else if (_selectedStatus == 'active') {
                // Incluir todos los estados activos: draft, submitted, underReview
                statusMatch =
                    anteproject.status == AnteprojectStatus.draft ||
                    anteproject.status == AnteprojectStatus.submitted ||
                    anteproject.status == AnteprojectStatus.underReview;
              } else if (_selectedStatus == 'pending') {
                statusMatch =
                    anteproject.status == AnteprojectStatus.submitted ||
                    anteproject.status == AnteprojectStatus.underReview;
              } else if (_selectedStatus == 'reviewed') {
                statusMatch =
                    anteproject.status == AnteprojectStatus.approved ||
                    anteproject.status == AnteprojectStatus.rejected;
              } else {
                statusMatch = anteproject.status.name == _selectedStatus;
              }

              // Filtro por búsqueda
              final searchMatch =
                  _searchQuery.isEmpty ||
                  anteproject.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  anteproject.description.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  studentName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  studentEmail.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );

              return statusMatch && searchMatch;
            } catch (e) {
              debugPrint('⚠️ Error filtrando anteproyecto: $e');
              return false;
            }
          })
          .map((anteprojectData) {
            // Crear una copia completa y profunda del mapa original
            // para preservar todas las relaciones incluyendo anteproject_students
            return safeConvertMap(anteprojectData);
          })
          .toList();
    });
  }

  void _onAcademicYearChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedAcademicYear = value;
      });
      _filterAnteprojects();
    }
  }

  void _onStatusFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedStatus = value;
      });
      _filterAnteprojects();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _filterAnteprojects();
  }

  Color _getStatusColor(AnteprojectStatus status) {
    switch (status) {
      case AnteprojectStatus.draft:
        return Colors.grey;
      case AnteprojectStatus.submitted:
        return Colors.orange;
      case AnteprojectStatus.underReview:
        return Colors.blue;
      case AnteprojectStatus.approved:
        return Colors.green;
      case AnteprojectStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(AnteprojectStatus status) {
    switch (status) {
      case AnteprojectStatus.draft:
        return Icons.edit;
      case AnteprojectStatus.submitted:
        return Icons.send;
      case AnteprojectStatus.underReview:
        return Icons.visibility;
      case AnteprojectStatus.approved:
        return Icons.check_circle;
      case AnteprojectStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getScreenTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_selectedStatus) {
      case 'active':
        return l10n.activeAnteprojects;
      case 'pending':
        return l10n.pendingAnteprojectsTitle;
      case 'reviewed':
        return l10n.reviewedAnteprojectsTitle;
      case 'submitted':
        return l10n.submittedAnteprojects;
      case 'under_review':
        return l10n.underReviewAnteprojects;
      case 'approved':
        return l10n.approvedAnteprojects;
      case 'rejected':
        return l10n.rejectedAnteprojects;
      default:
        return l10n.anteprojectsReview;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _initializeStatusFilters(context);

    // Si necesita Scaffold propio (acceso desde dashboard con Navigator.push)
    if (widget.useOwnScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_getScreenTitle(context)),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: _currentUser != null
              ? AppBarActions.build(
                  context,
                  _currentUser!,
                  additionalActions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadAnteprojects,
                      tooltip: l10n.refresh,
                    ),
                  ],
                )
              : [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadAnteprojects,
                    tooltip: l10n.refresh,
                  ),
                ],
        ),
        body: _buildContent(context),
      );
    }

    // Si usa PersistentScaffold (acceso desde router/drawer)
    // Retornar solo el contenido sin Scaffold
    return _buildContent(context);
  }

  /// Construye el contenido principal de la pantalla
  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Filtros y búsqueda
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Column(
            children: [
              // Barra de búsqueda
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchAnteprojects,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 12),
              // Filtro por año académico
              Row(
                children: [
                  Text(l10n.year),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedAcademicYear,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String>(
                          value: 'all',
                          child: Text(l10n.all),
                        ),
                        ..._academicYears.map((year) {
                          final isActive = year == _activeAcademicYear;
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(year),
                                if (isActive) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Activo',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: _onAcademicYearChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Filtro por estado
              Row(
                children: [
                  Text(l10n.filterByStatus),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      items: _statusFilters.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: _onStatusFilterChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Banner de solo lectura si el año seleccionado no es el activo
        if (!_isSelectedYearActive)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.visibility, size: 20, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Modo consulta: Visualizando anteproyectos del año $_selectedAcademicYear. '
                    'Las acciones de aprobación/rechazo están deshabilitadas.',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 13,
                    ),
                  ),
              ),
            ],
          ),
        ),

        // Lista de anteproyectos
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredAnteprojects.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredAnteprojects.length,
                  itemBuilder: (context, index) {
                    final anteprojectData = _filteredAnteprojects[index];
                    // Debug: verificar qué datos tenemos en el item filtrado
                    debugPrint(
                      '🔍 ListView - Item $index - Claves: ${anteprojectData.keys.toList()}',
                    );
                    debugPrint(
                      '🔍 ListView - Item $index - Tiene anteproject_students: ${anteprojectData.containsKey('anteproject_students')}',
                    );
                    return _buildAnteprojectCard(anteprojectData);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String message;
    Widget? additionalInfo;
    
    if (_searchQuery.isNotEmpty) {
      message = l10n.noAnteprojectsFound(_searchQuery);
    } else if (_selectedStatus == 'active') {
      // Cuando no hay anteproyectos activos, verificar si hay aprobados
      final approvedCount = _anteprojects.where((anteprojectData) {
        try {
          Map<String, dynamic> safeConvertMap(dynamic data) {
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

          final anteprojectMap = safeConvertMap(anteprojectData);
          anteprojectMap.remove('anteproject_students');
          if (anteprojectMap.isEmpty) {
            return false;
          }

          final anteproject = Anteproject.fromJson(anteprojectMap);
          return anteproject.status == AnteprojectStatus.approved;
        } catch (e) {
          return false;
        }
      }).length;

      if (approvedCount > 0) {
        message = l10n.noActiveAnteprojects;
        final plural = approvedCount == 1 ? '' : 's';
        additionalInfo = Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            l10n.noActiveButApproved(approvedCount, plural),
            style: TextStyle(
              fontSize: 16,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        );
      } else {
        message = l10n.noActiveAnteprojects;
      }
    } else if (_selectedStatus != 'all') {
      message = l10n.noAnteprojectsWithStatus(
        _statusFilters[_selectedStatus] ?? '',
      );
    } else {
      message = l10n.noAssignedAnteprojects;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (additionalInfo != null) additionalInfo,
          if (_searchQuery.isNotEmpty || _selectedStatus != 'all' || _selectedAcademicYear != 'all') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedStatus = 'all';
                  _selectedAcademicYear = 'all';
                });
                _filterAnteprojects();
              },
              child: Text(l10n.clearFilters),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnteprojectCard(Map<String, dynamic> anteprojectData) {
    // Debug: verificar qué datos tenemos antes de parsear
    debugPrint(
      '🔍 Build Card - anteprojectData claves: ${anteprojectData.keys.toList()}',
    );
    debugPrint(
      '🔍 Build Card - Tiene anteproject_students: ${anteprojectData.containsKey('anteproject_students')}',
    );
    if (anteprojectData.containsKey('anteproject_students')) {
      debugPrint(
        '🔍 Build Card - anteproject_students valor: ${anteprojectData['anteproject_students']}',
      );
    }

    // Crear una copia del mapa para parsear Anteproject sin modificar el original
    final anteprojectMapForParsing = Map<String, dynamic>.from(anteprojectData);
    anteprojectMapForParsing.remove('anteproject_students');

    final anteproject = Anteproject.fromJson(anteprojectMapForParsing);
    final statusColor = _getStatusColor(anteproject.status);
    final statusIcon = _getStatusIcon(anteproject.status);

    // Obtener información del estudiante desde la tabla de relación (usar el original)
    final anteprojectStudents =
        anteprojectData['anteproject_students'] as List<dynamic>?;

    // Debug: verificar qué datos tenemos
    debugPrint('🔍 Review Screen - Anteproyecto ID: ${anteproject.id}');
    debugPrint(
      '🔍 Review Screen - anteproject_students tipo: ${anteprojectStudents.runtimeType}',
    );
    debugPrint(
      '🔍 Review Screen - anteproject_students valor: $anteprojectStudents',
    );

    // Función auxiliar para convertir de forma segura objetos minificados de Supabase
    Map<String, dynamic> safeConvert(dynamic data) {
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is Map) {
        final result = <String, dynamic>{};
        for (final key in data.keys) {
          result[key.toString()] = data[key];
        }
        return result;
      } else {
        return <String, dynamic>{};
      }
    }

    // Convertir de forma segura a Map
    Map<String, dynamic>? studentInfo;
    if (anteprojectStudents != null && anteprojectStudents.isNotEmpty) {
      try {
        final firstStudent = anteprojectStudents[0];
        debugPrint(
          '🔍 Review Screen - Primer estudiante tipo: ${firstStudent.runtimeType}',
        );
        debugPrint('🔍 Review Screen - Primer estudiante valor: $firstStudent');

        final firstStudentMap = safeConvert(firstStudent);
        debugPrint(
          '🔍 Review Screen - Estudiante convertido: $firstStudentMap',
        );

        if (firstStudentMap.containsKey('users')) {
          final usersData = firstStudentMap['users'];
          debugPrint('🔍 Review Screen - users tipo: ${usersData.runtimeType}');
          debugPrint('🔍 Review Screen - users valor: $usersData');

          if (usersData != null) {
            studentInfo = safeConvert(usersData);
            debugPrint('🔍 Review Screen - studentInfo final: $studentInfo');
          }
        } else {
          debugPrint(
            '⚠️ Review Screen - No se encontró campo "users" en estudiante',
          );
        }
      } catch (e, stackTrace) {
        debugPrint(
          '⚠️ Error procesando información del estudiante en card: $e',
        );
        debugPrint('⚠️ Stack trace: $stackTrace');
        studentInfo = null;
      }
    } else {
      debugPrint(
        '⚠️ Review Screen - No hay estudiantes asociados al anteproyecto ${anteproject.id}',
      );
    }

    final studentName = studentInfo?['full_name'] ?? 'Estudiante desconocido';
    final studentEmail = studentInfo?['email'] ?? '';
    final studentNre = studentInfo?['nre'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewAnteprojectDetails(anteproject),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y estado
              Row(
                children: [
                  Expanded(
                    child: Text(
                      anteproject.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          anteproject.status.displayName,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Información del estudiante
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          if (studentEmail.isNotEmpty)
                            Text(
                              studentEmail,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          if (studentNre.isNotEmpty)
                            Text(
                              'NRE: $studentNre',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Descripción
              Text(
                anteproject.description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Información adicional
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${AppLocalizations.of(context)!.year} ${anteproject.academicYear}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    anteproject.projectType.displayName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fechas
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${AppLocalizations.of(context)!.created} ${_formatDate(anteproject.createdAt)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  if (anteproject.submittedAt != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.send, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${AppLocalizations.of(context)!.submittedLabel} ${_formatDate(anteproject.submittedAt!)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),

              // Acciones para anteproyectos
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón de comentarios (siempre visible)
                  TextButton.icon(
                    onPressed: () => _viewComments(anteproject),
                    icon: const Icon(Icons.chat, color: Colors.blue),
                    label: Text(
                      AppLocalizations.of(context)!.comments,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Botones de aprobación/rechazo (solo para enviados/en revisión y año activo)
                  if (_isSelectedYearActive &&
                      (anteproject.status == AnteprojectStatus.submitted ||
                       anteproject.status == AnteprojectStatus.underReview)) ...[
                    TextButton.icon(
                      onPressed: () => _rejectAnteproject(anteproject),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: Text(
                        AppLocalizations.of(context)!.rejectAnteproject,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _approveAnteproject(anteproject),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: Text(
                        AppLocalizations.of(context)!.approveAnteproject,
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewAnteprojectDetails(Anteproject anteproject) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                AnteprojectDetailScreen(anteproject: anteproject),
          ),
        )
        .then((_) => _loadAnteprojects()); // Recargar al volver
  }

  void _viewComments(Anteproject anteproject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AnteprojectCommentsScreen(anteproject: anteproject),
      ),
    );
  }

  void _approveAnteproject(Anteproject anteproject) {
    showDialog(
      context: context,
      builder: (context) => _ApprovalDialog(
        anteproject: anteproject,
        isApproval: true,
        onConfirm: (comments, timeline) async {
          // Capturar el context antes de la operación async
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final l10n = AppLocalizations.of(context)!;

          try {
            await _anteprojectsService.approveAnteproject(
              anteproject.id,
              comments,
              timeline: timeline,
            );
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.anteprojectApprovedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
              _loadAnteprojects();
            }
          } catch (e) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.errorApprovingAnteproject(e.toString())),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _rejectAnteproject(Anteproject anteproject) {
    showDialog(
      context: context,
      builder: (context) => _ApprovalDialog(
        anteproject: anteproject,
        isApproval: false,
        onConfirm: (comments, timeline) async {
          // Capturar el context antes de la operación async
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final l10n = AppLocalizations.of(context)!;

          try {
            await _anteprojectsService.rejectAnteproject(
              anteproject.id,
              comments,
            );
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.anteprojectRejectedSuccess),
                  backgroundColor: Colors.orange,
                ),
              );
              _loadAnteprojects();
            }
          } catch (e) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.errorRejectingAnteproject(e.toString())),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class _ApprovalDialog extends StatefulWidget {
  final Anteproject anteproject;
  final bool isApproval;
  final Function(String, Map<String, dynamic>?) onConfirm;

  const _ApprovalDialog({
    required this.anteproject,
    required this.isApproval,
    required this.onConfirm,
  });

  @override
  State<_ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<_ApprovalDialog> {
  final TextEditingController _commentsController = TextEditingController();
  final List<MapEntry<DateTime, String>> _timelineDates = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _addTimelineDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null) return;

    final descriptionController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.dateDescription),
        content: TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'Ej: Inicio, Revisión final, Presentación...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );

    if (confirmed == true && descriptionController.text.trim().isNotEmpty) {
      setState(() {
        _timelineDates.add(MapEntry(date, descriptionController.text.trim()));
        // Ordenar por fecha
        _timelineDates.sort((a, b) => a.key.compareTo(b.key));
      });
    }
  }

  void _removeTimelineDate(int index) {
    setState(() {
      _timelineDates.removeAt(index);
    });
  }

  Map<String, dynamic> _buildTimelineMap() {
    if (_timelineDates.isEmpty) return {};

    final timeline = <String, String>{};
    for (final entry in _timelineDates) {
      final dateStr =
          '${entry.key.day.toString().padLeft(2, '0')}/'
          '${entry.key.month.toString().padLeft(2, '0')}/'
          '${entry.key.year}';
      timeline[dateStr] = entry.value;
    }
    return {'fechas': timeline};
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        widget.isApproval
            ? l10n.approveAnteprojectTitle
            : l10n.rejectAnteprojectTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.anteprojectTitle(widget.anteproject.title)),
            const SizedBox(height: 16),
            Text(
              widget.isApproval
                  ? l10n.confirmApproveAnteproject
                  : l10n.confirmRejectAnteproject,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentsController,
              decoration: InputDecoration(
                labelText: l10n.approvalCommentsOptional,
                hintText: widget.isApproval
                    ? l10n.approvalCommentsHint
                    : l10n.rejectionCommentsHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            // Selector de temporalización (solo para aprobación)
            if (widget.isApproval) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Temporalización',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: Colors.blue,
                    onPressed: _addTimelineDate,
                    tooltip: 'Añadir fecha',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_timelineDates.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Añade fechas importantes del proyecto usando el botón +',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...List.generate(_timelineDates.length, (index) {
                  final entry = _timelineDates[index];
                  final dateStr =
                      '${entry.key.day.toString().padLeft(2, '0')}/'
                      '${entry.key.month.toString().padLeft(2, '0')}/'
                      '${entry.key.year}';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, size: 20),
                      title: Text(
                        '● $dateStr: ${entry.value}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.red,
                        onPressed: () => _removeTimelineDate(index),
                      ),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });

                  final timeline = widget.isApproval
                      ? _buildTimelineMap()
                      : null;
                  widget.onConfirm(_commentsController.text.trim(), timeline);
                  Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isApproval ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.isApproval
                      ? l10n.approveAnteproject
                      : l10n.rejectAnteproject,
                ),
        ),
      ],
    );
  }
}
