import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart' as app_user;
import '../../services/user_service.dart';
import '../../services/settings_service.dart';
import '../forms/edit_student_form.dart';
import '../../widgets/dialogs/reset_password_dialog.dart';
import '../../widgets/dialogs/add_students_dialog.dart';

class StudentListScreen extends StatefulWidget {
  final int tutorId;

  const StudentListScreen({
    super.key,
    required this.tutorId,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<app_user.User> _students = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Filtro de año académico
  final SettingsService _settingsService = SettingsService();
  String _selectedAcademicYear = 'all';
  List<String> _academicYears = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    try {
      final userService = UserService();
      final students = await userService.getStudentsByTutor(widget.tutorId);
      
      // Extraer años académicos disponibles
      final years = <String>{};
      for (final student in students) {
        if (student.academicYear != null && student.academicYear!.isNotEmpty) {
          years.add(student.academicYear!);
        }
      }
      
      // Ordenar años (más reciente primero)
      final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));

      if (mounted) {
        setState(() {
          _students = students;
          _academicYears = sortedYears;
          
          // Si _selectedAcademicYear es 'all', intentar establecer el año actual del sistema por defecto
          // solo si no se ha seleccionado uno explícitamente antes (aunque aquí se resetea al cargar, 
          // podríamos querer persistir la selección, pero por ahora reseteamos o mantenemos 'all')
          if (_selectedAcademicYear == 'all' && _academicYears.isNotEmpty) {
             _loadDefaultYear();
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorDeletingStudent(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadDefaultYear() async {
    try {
      final systemYear = await _settingsService.getStringSetting('academic_year');
      if (systemYear != null && 
          systemYear.isNotEmpty && 
          _academicYears.contains(systemYear) &&
          mounted) {
        setState(() {
          _selectedAcademicYear = systemYear;
        });
      }
    } catch (e) {
      debugPrint('Error loading system academic year: $e');
    }
  }

  List<app_user.User> get _filteredStudents {
    var filtered = _students;

    // Filtrar por año académico
    if (_selectedAcademicYear != 'all') {
      filtered = filtered.where((student) => 
        student.academicYear == _selectedAcademicYear
      ).toList();
    }

    if (_searchQuery.isEmpty) return filtered;

    return filtered.where((student) {
      return student.fullName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          student.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (student.nre?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Retornar solo el contenido sin Scaffold
    // El PersistentScaffold en el router maneja el AppBar y drawer
    return Column(
        children: [
          // Barra de acciones
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _addStudent,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addStudent),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loadStudents,
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.refresh,
                ),
              ],
            ),
          ),
          
          // Barra de búsqueda y filtro
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: l10n.searchStudents,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Dropdown de Año Académico
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAcademicYear,
                          icon: const Icon(Icons.filter_list),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedAcademicYear = newValue;
                              });
                            }
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: 'all',
                              child: Text(l10n.all),
                            ),
                            ..._academicYears.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de estudiantes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      return _buildStudentCard(student);
                    },
                  ),
          ),
        ],
      );
  }

  Widget _buildEmptyState() {
    final isFiltering = _searchQuery.isNotEmpty || _selectedAcademicYear != 'all';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            !isFiltering
                ? AppLocalizations.of(context)!.noStudentsAssigned
                : AppLocalizations.of(context)!.noStudentsFound,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          if (!isFiltering) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.useDashboardButtons,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentCard(app_user.User student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            student.fullName.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          student.fullName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.email),
            if (student.nre != null && student.nre!.isNotEmpty)
              Text(
                '${AppLocalizations.of(context)!.nre}: ${student.nre}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            if (student.specialty != null && student.specialty!.isNotEmpty)
              Text(
                student.specialty!,
                style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                _viewStudentDetails(student);
                break;
              case 'edit':
                _editStudent(student);
                break;
              case 'reset_password':
                _resetStudentPassword(student);
                break;
              case 'delete':
                _deleteStudent(student);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  const Icon(Icons.visibility),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.viewDetails),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.editStudent),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'reset_password',
              child: Row(
                children: [
                  const Icon(Icons.lock_reset, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.resetPassword,
                    style: const TextStyle(color: Colors.teal),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.deleteStudent,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _viewStudentDetails(student),
      ),
    );
  }

  void _viewStudentDetails(app_user.User student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.fullName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                AppLocalizations.of(context)!.email,
                student.email,
              ),
              if (student.nre != null && student.nre!.isNotEmpty)
                _buildDetailRow(
                  AppLocalizations.of(context)!.nre,
                  student.nre!,
                ),
              if (student.phone != null && student.phone!.isNotEmpty)
                _buildDetailRow(
                  AppLocalizations.of(context)!.phone,
                  student.phone!,
                ),
              if (student.specialty != null && student.specialty!.isNotEmpty)
                _buildDetailRow(
                  AppLocalizations.of(context)!.specialty,
                  student.specialty!,
                ),
              if (student.academicYear != null &&
                  student.academicYear!.isNotEmpty)
                _buildDetailRow(
                  AppLocalizations.of(context)!.academicYear,
                  student.academicYear!,
                ),
              if (student.biography != null && student.biography!.isNotEmpty)
                _buildDetailRow(
                  AppLocalizations.of(context)!.biography,
                  student.biography!,
                ),
              _buildDetailRow(
                AppLocalizations.of(context)!.status,
                student.status.displayName,
              ),
              _buildDetailRow(
                AppLocalizations.of(context)!.creationDate,
                student.createdAt.toString().split(' ')[0],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _addStudent() {
    // Mostrar diálogo para elegir entre añadir individualmente o importar CSV
    showDialog(
      context: context,
      builder: (context) => AddStudentsDialog(
        tutorId: widget.tutorId,
        onStudentAdded: () {
          // Recargar la lista cuando se añade un estudiante
          _loadStudents();
        },
        onImportCompleted: () {
          // Recargar la lista cuando se completa la importación
          _loadStudents();
        },
      ),
    );
  }

  void _editStudent(app_user.User student) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EditStudentForm(student: student),
          ),
        )
        .then((updatedStudent) {
          if (updatedStudent != null) {
            // Recargar la lista para mostrar los cambios
            _loadStudents();
          }
        });
  }

  Future<void> _resetStudentPassword(app_user.User student) async {
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ResetPasswordDialog(
        studentEmail: student.email,
        studentName: student.fullName,
      ),
    );
    // Recargar lista si se reseteó la contraseña
    if (result == true && mounted) {
      _loadStudents();
    }
  }

  void _deleteStudent(app_user.User student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDeletion),
        content: Text(
          AppLocalizations.of(context)!.confirmDeleteStudent(student.fullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performDelete(student);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.deleteStudent),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(app_user.User student) async {
    try {
      final userService = UserService();
      await userService.deleteUser(student.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.studentDeletedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        _loadStudents(); // Recargar la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorDeletingStudent(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
