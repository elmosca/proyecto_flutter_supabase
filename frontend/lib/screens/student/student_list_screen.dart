import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart' as app_user;
import '../../services/user_service.dart';
import '../forms/edit_student_form.dart';

class StudentListScreen extends StatefulWidget {
  final int tutorId;

  const StudentListScreen({super.key, required this.tutorId});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<app_user.User> _students = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
      
      if (mounted) {
        setState(() {
          _students = students;
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
            content: Text(AppLocalizations.of(context)!.errorDeletingStudent(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<app_user.User> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    
    return _students.where((student) {
      return student.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             student.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (student.nre?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myStudents),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchStudents,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            _searchQuery.isEmpty
                ? AppLocalizations.of(context)!.noStudentsAssigned
                : AppLocalizations.of(context)!.noStudentsFound,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.useDashboardButtons,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
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
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            if (student.specialty != null && student.specialty!.isNotEmpty)
              Text(
                student.specialty!,
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 12,
                ),
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
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.deleteStudent, style: const TextStyle(color: Colors.red)),
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
              _buildDetailRow(AppLocalizations.of(context)!.email, student.email),
              if (student.nre != null && student.nre!.isNotEmpty)
                _buildDetailRow(AppLocalizations.of(context)!.nre, student.nre!),
              if (student.phone != null && student.phone!.isNotEmpty)
                _buildDetailRow(AppLocalizations.of(context)!.phone, student.phone!),
              if (student.specialty != null && student.specialty!.isNotEmpty)
                _buildDetailRow(AppLocalizations.of(context)!.specialty, student.specialty!),
              if (student.academicYear != null && student.academicYear!.isNotEmpty)
                _buildDetailRow(AppLocalizations.of(context)!.academicYear, student.academicYear!),
              if (student.biography != null && student.biography!.isNotEmpty)
                _buildDetailRow(AppLocalizations.of(context)!.biography, student.biography!),
              _buildDetailRow(AppLocalizations.of(context)!.status, student.status.displayName),
              _buildDetailRow(AppLocalizations.of(context)!.creationDate, 
                student.createdAt.toString().split(' ')[0]),
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _editStudent(app_user.User student) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditStudentForm(student: student),
      ),
    ).then((updatedStudent) {
      if (updatedStudent != null) {
        // Recargar la lista para mostrar los cambios
        _loadStudents();
      }
    });
  }

  void _deleteStudent(app_user.User student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDeletion),
        content: Text(AppLocalizations.of(context)!.confirmDeleteStudent(student.fullName)),
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
            content: Text(AppLocalizations.of(context)!.errorDeletingStudent(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
