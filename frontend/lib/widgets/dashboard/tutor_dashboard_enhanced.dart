import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_management_service.dart';
import '../calendar/academic_calendar_widget.dart';
import '../forms/csv_import_widget.dart';
import '../demo/imported_students_demo.dart';

class TutorDashboardEnhanced extends StatefulWidget {
  final User currentUser;
  
  const TutorDashboardEnhanced({
    super.key,
    required this.currentUser,
  });

  @override
  State<TutorDashboardEnhanced> createState() => _TutorDashboardEnhancedState();
}

class _TutorDashboardEnhancedState extends State<TutorDashboardEnhanced> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserManagementService _userManagementService = UserManagementService();
  
  List<User> _students = [];
  String? _selectedAcademicYear;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final students = await _userManagementService.getStudentsByTutor(
        widget.currentUser.id
      );
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar estudiantes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onYearSelected(String year) {
    setState(() {
      _selectedAcademicYear = year;
    });
  }

  void _onImportComplete(Map<String, dynamic> result) {
    _loadStudents(); // Recargar estudiantes después de la importación
    
    if (mounted) {
      final summary = result['summary'];
      final successCount = summary['success_count'] ?? 0;
      final errorCount = summary['error_count'] ?? 0;
      final duplicateCount = summary['duplicate_count'] ?? 0;
      
      String message = 'Importación completada: ';
      if (successCount > 0) message += '$successCount creados, ';
      if (duplicateCount > 0) message += '$duplicateCount duplicados, ';
      if (errorCount > 0) message += '$errorCount errores';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: successCount > 0 ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  List<User> _getFilteredStudents() {
    if (_selectedAcademicYear == null) return _students;
    return _students.where((s) => s.academicYear == _selectedAcademicYear).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - ${widget.currentUser.fullName}'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Estudiantes'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendario'),
            Tab(icon: Icon(Icons.upload), text: 'Importar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Lista de estudiantes
          _buildStudentsTab(),
          
          // Tab 2: Calendario académico
          _buildCalendarTab(),
          
          // Tab 3: Importación CSV
          _buildImportTab(),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredStudents = _getFilteredStudents();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtro por año académico
          if (_students.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Filtrar por año:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedAcademicYear,
                    hint: const Text('Todos los años'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todos los años'),
                      ),
                      ..._students
                          .map((s) => s.academicYear)
                          .where((year) => year != null)
                          .cast<String>()
                          .toSet()
                          .map((year) => DropdownMenuItem<String>(
                                value: year,
                                child: Text(year),
                              )),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAcademicYear = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Lista de estudiantes
          Expanded(
            child: filteredStudents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay estudiantes',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Usa la pestaña "Importar" para agregar estudiantes',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ImportedStudentsDemo(students: filteredStudents),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AcademicCalendarWidget(
        students: _students,
        onYearSelected: _onYearSelected,
        selectedYear: _selectedAcademicYear,
      ),
    );
  }

  Widget _buildImportTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CsvImportWidget(
        onImportComplete: _onImportComplete,
      ),
    );
  }
}
