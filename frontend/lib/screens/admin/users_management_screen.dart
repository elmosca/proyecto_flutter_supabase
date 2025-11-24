import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../widgets/navigation/persistent_scaffold.dart';
import '../../services/user_management_service.dart';
import '../../widgets/forms/tutor_creation_form.dart';
import '../../widgets/forms/student_creation_form.dart';
import '../../widgets/forms/tutor_selector_dialog.dart';
import '../../widgets/dialogs/user_detail_dialog.dart';
import '../../widgets/dialogs/reset_password_dialog.dart';
import '../../widgets/forms/user_edit_form.dart';
import '../../screens/forms/import_students_csv_screen.dart';

class UsersManagementScreen extends StatefulWidget {
  final User user;
  const UsersManagementScreen({super.key, required this.user});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final UserManagementService _service = UserManagementService();
  String? _selectedYear;
  String _selectedRole = 'all'; // all | tutor | student
  bool _loading = true;
  List<String> _years = [];
  List<User> _tutors = [];
  List<User> _students = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final years = await _service.getAcademicYears();
      await _loadLists();
      if (mounted) {
        setState(() {
          _years = years;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando datos: $e')));
      }
    }
  }

  Future<void> _loadLists() async {
    final tutors = await _service.getUsers(
      role: 'tutor',
      academicYear: _selectedYear,
    );
    final students = await _service.getUsers(
      role: 'student',
      academicYear: _selectedYear,
    );
    if (mounted) {
      setState(() {
        _tutors = tutors;
        _students = students;
      });
    }
  }

  Future<void> _createTutor() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: TutorCreationForm(
            onTutorCreated: (result) async {
              await _loadLists();
              if (mounted && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _importStudentsFromCSV() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImportStudentsCSVScreen(tutorId: null),
      ),
    );
    // Recargar listas después de importar
    if (mounted) {
      await _loadLists();
    }
  }

  Future<void> _createStudent() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: StudentCreationForm(
            onStudentCreated: (student) async {
              await _loadLists();
              if (mounted && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTutor(User tutor) async {
    // Confirmar eliminación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Está seguro de eliminar al tutor ${tutor.fullName} (${tutor.email})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.deleteTutor(tutorId: tutor.id, force: false);
      await _loadLists();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tutor eliminado: ${tutor.email}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Si el tutor tiene alumnos, preguntar si forzar eliminación
      final errorMsg = e.toString();
      if (errorMsg.contains('tutor_has_students') ||
          errorMsg.contains('assigned students')) {
        if (!mounted) return;
        final forceDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Tutor tiene alumnos asignados'),
            content: const Text(
              'Este tutor tiene alumnos asignados. ¿Desea desasignarlos y eliminar el tutor?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Forzar eliminación'),
              ),
            ],
          ),
        );

        if (forceDelete == true) {
          try {
            await _service.deleteTutor(tutorId: tutor.id, force: true);
            await _loadLists();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tutor eliminado (alumnos desasignados): ${tutor.email}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e2) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error eliminando tutor: $e2'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo eliminar tutor: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _reassignStudent(User student) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => TutorSelectorDialog(
        currentTutorId: student.tutorId,
        onTutorSelected: (tutor) async {
          try {
            await _service.reassignStudent(
              studentId: student.id,
              newTutorId: tutor.id,
            );
            await _loadLists();
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Alumno ${student.email} reasignado a ${tutor.fullName}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error reasignando alumno: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _resetStudentPassword(User student) async {
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ResetPasswordDialog(
        studentEmail: student.email,
        studentName: student.fullName,
      ),
    );
    // Recargar listas si se reseteó la contraseña
    if (result == true && mounted) {
      await _loadLists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PersistentScaffold(
      title: 'Gestión de Usuarios',
      titleKey: 'dashboardAdminUsersManagement',
      user: widget.user,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              DropdownButton<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Todos')),
                  DropdownMenuItem(value: 'tutor', child: Text('Tutores')),
                  DropdownMenuItem(value: 'student', child: Text('Alumnos')),
                ],
                onChanged: (v) {
                  setState(() => _selectedRole = v ?? 'all');
                },
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedYear,
                hint: const Text('Año académico'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Todos'),
                  ),
                  ..._years.map(
                    (y) => DropdownMenuItem(value: y, child: Text(y)),
                  ),
                ],
                onChanged: (v) async {
                  setState(() => _selectedYear = v);
                  await _loadLists();
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _createTutor,
                icon: const Icon(Icons.person_add),
                label: const Text('Añadir Tutor'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _createStudent,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Añadir Alumno'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _importStudentsFromCSV,
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              if (_selectedRole == 'all' || _selectedRole == 'tutor')
                Expanded(child: _buildTutors()),
              if (_selectedRole == 'all' || _selectedRole == 'student')
                Expanded(child: _buildStudents()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTutors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Tutores', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _tutors.length,
            itemBuilder: (context, index) {
              final t = _tutors[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.school, color: Colors.blue),
                  title: Text(t.fullName),
                  subtitle: Text('${t.email} • ID: ${t.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'Ver detalles',
                        onPressed: () => _viewTutor(t),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Editar',
                        onPressed: () => _editTutor(t),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        tooltip: 'Eliminar',
                        onPressed: () => _deleteTutor(t),
                      ),
                    ],
                  ),
                  onTap: () => _viewTutor(t),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Alumnos', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final s = _students[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.green),
                  title: Text(s.fullName),
                  subtitle: Text(
                    '${s.email} • ID: ${s.id}  •  TutorID: ${s.tutorId ?? '-'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'Ver detalles',
                        onPressed: () => _viewStudent(s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Editar',
                        onPressed: () => _editStudent(s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.lock_reset, color: Colors.teal),
                        tooltip: 'Restablecer contraseña',
                        onPressed: () => _resetStudentPassword(s),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.swap_horiz,
                          color: Colors.purple,
                        ),
                        tooltip: 'Reasignar tutor',
                        onPressed: () => _reassignStudent(s),
                      ),
                    ],
                  ),
                  onTap: () => _viewStudent(s),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _viewTutor(User tutor) async {
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => UserDetailDialog(user: tutor),
    );

    // Si el usuario presionó "Editar", abrir el formulario de edición
    if (result == true && mounted) {
      await _editTutor(tutor);
    }
  }

  Future<void> _viewStudent(User student) async {
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => UserDetailDialog(user: student),
    );

    // Si el usuario presionó "Editar", abrir el formulario de edición
    if (result == true && mounted) {
      await _editStudent(student);
    }
  }

  Future<void> _editTutor(User tutor) async {
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => UserEditForm(
        user: tutor,
        onUserUpdated: (updatedUser) async {
          await _loadLists();
          if (mounted && context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
      ),
    );

    if (result == true && mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutor actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _editStudent(User student) async {
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => UserEditForm(
        user: student,
        onUserUpdated: (updatedUser) async {
          await _loadLists();
          if (mounted && context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
      ),
    );

    if (result == true && mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alumno actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
