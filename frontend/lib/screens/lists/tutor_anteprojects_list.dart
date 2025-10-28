import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/anteprojects_bloc.dart';
import '../../models/anteproject.dart';
import '../../services/anteprojects_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/error_handler_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../anteprojects/anteproject_detail_screen.dart';

class TutorAnteprojectsList extends StatefulWidget {
  const TutorAnteprojectsList({super.key});

  @override
  State<TutorAnteprojectsList> createState() => _TutorAnteprojectsListState();
}

class _TutorAnteprojectsListState extends State<TutorAnteprojectsList> {
  late AnteprojectsService _anteprojectsService;
  late Future<List<Map<String, dynamic>>> _anteprojectsFuture;
  String _searchQuery = '';
  AnteprojectStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _anteprojectsService = AnteprojectsService();
    _loadAnteprojects();
  }

  void _loadAnteprojects() {
    setState(() {
      _anteprojectsFuture = _anteprojectsService
          .getAnteprojectsWithStudentInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          _buildSearchAndFilters(l10n),
          // Lista de anteproyectos
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _anteprojectsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }

                if (snapshot.hasError) {
                  return ErrorHandlerWidget(
                    error: snapshot.error.toString(),
                    customTitle: 'Error al cargar anteproyectos',
                    onRetry: _loadAnteprojects,
                  );
                }

                final anteproyectos = snapshot.data ?? [];
                final filteredAnteproyectos = _filterAnteprojects(
                  anteproyectos,
                );

                if (filteredAnteproyectos.isEmpty) {
                  return _buildEmptyState(l10n);
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadAnteprojects(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAnteproyectos.length,
                    itemBuilder: (context, index) {
                      final anteprojectData = filteredAnteproyectos[index];
                      return _buildAnteprojectCard(context, anteprojectData);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar anteproyectos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Filtro por estado
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20),
              const SizedBox(width: 8),
              Text(
                'Filtrar por estado:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<AnteprojectStatus?>(
                  value: _selectedStatus,
                  hint: const Text('Todos los estados'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<AnteprojectStatus?>(
                      value: null,
                      child: Text('Todos los estados'),
                    ),
                    ...AnteprojectStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
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
            'No hay anteproyectos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron anteproyectos con los filtros aplicados',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnteprojectCard(
    BuildContext context,
    Map<String, dynamic> anteprojectData,
  ) {
    final anteproject = Anteproject.fromJson(anteprojectData);

    // Obtener información del estudiante desde la tabla de relación
    final anteprojectStudents =
        anteprojectData['anteproject_students'] as List<dynamic>?;
    final studentInfo = anteprojectStudents?.isNotEmpty == true
        ? anteprojectStudents![0]['users'] as Map<String, dynamic>?
        : null;

    final studentName = studentInfo?['full_name'] ?? 'Estudiante desconocido';
    final studentEmail = studentInfo?['email'] ?? '';
    final studentNre = studentInfo?['nre'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(anteproject),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y estado
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
                  _buildStatusChip(anteproject.status),
                ],
              ),
              const SizedBox(height: 8),

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
              const SizedBox(height: 8),

              // Tipo de proyecto
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    anteproject.projectType.shortName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Descripción (truncada)
              Text(
                anteproject.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
              const SizedBox(height: 12),

              // Información adicional y acciones
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    anteproject.academicYear,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const Spacer(),
                  Icon(Icons.visibility, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Ver detalles',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(AnteprojectStatus status) {
    Color backgroundColor;
    const Color textColor = Colors.white;

    switch (status) {
      case AnteprojectStatus.draft:
        backgroundColor = Colors.grey;
        break;
      case AnteprojectStatus.submitted:
        backgroundColor = Colors.blue;
        break;
      case AnteprojectStatus.underReview:
        backgroundColor = Colors.orange;
        break;
      case AnteprojectStatus.approved:
        backgroundColor = Colors.green;
        break;
      case AnteprojectStatus.rejected:
        backgroundColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: const TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterAnteprojects(
    List<Map<String, dynamic>> anteproyectos,
  ) {
    return anteproyectos.where((anteprojectData) {
      final anteproject = Anteproject.fromJson(anteprojectData);

      // Obtener información del estudiante desde la tabla de relación
      final anteprojectStudents =
          anteprojectData['anteproject_students'] as List<dynamic>?;
      final studentInfo = anteprojectStudents?.isNotEmpty == true
          ? anteprojectStudents![0]['users'] as Map<String, dynamic>?
          : null;

      final studentName = studentInfo?['full_name'] ?? '';
      final studentEmail = studentInfo?['email'] ?? '';

      // Filtro por búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!anteproject.title.toLowerCase().contains(query) &&
            !anteproject.description.toLowerCase().contains(query) &&
            !studentName.toLowerCase().contains(query) &&
            !studentEmail.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtro por estado
      if (_selectedStatus != null && anteproject.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  void _navigateToDetail(Anteproject anteproject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnteprojectDetailScreen(anteproject: anteproject),
      ),
    );
  }
}
