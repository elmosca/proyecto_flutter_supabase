import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_management_service.dart';
import '../../services/settings_service.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/validators.dart';

class StudentCreationForm extends StatefulWidget {
  final Function(User) onStudentCreated;

  const StudentCreationForm({super.key, required this.onStudentCreated});

  @override
  State<StudentCreationForm> createState() => _StudentCreationFormState();
}

class _StudentCreationFormState extends State<StudentCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _userManagementService = UserManagementService();
  final _settingsService = SettingsService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _phoneController = TextEditingController();

  User? _selectedTutor;
  List<User> _tutors = [];
  bool _loadingTutors = false;
  bool _isCreating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTutors();
    _loadDefaultAcademicYear();
  }

  Future<void> _loadDefaultAcademicYear() async {
    try {
      final year = await _settingsService.getStringSetting('academic_year');
      if (year != null && year.isNotEmpty && mounted) {
        setState(() {
          _academicYearController.text = year;
        });
      }
    } catch (e) {
      debugPrint('Error cargando año académico por defecto: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _academicYearController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadTutors() async {
    setState(() => _loadingTutors = true);
    try {
      final tutors = await _userManagementService.getTutors();
      if (mounted) {
        setState(() {
          _tutors = tutors;
          _loadingTutors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingTutors = false;
          _errorMessage = 'Error cargando tutores: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Crear Nuevo Alumno',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'usuario@jualas.es',
                  border: OutlineInputBorder(),
                  helperText: 'Debe ser del dominio: jualas.es',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    Validators.email(value, 'El email es obligatorio'),
              ),

              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Nombre completo
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  hintText: 'Juan Pérez García',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre completo es obligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Año académico
              TextFormField(
                controller: _academicYearController,
                decoration: const InputDecoration(
                  labelText: 'Año Académico (opcional)',
                  hintText: '2024-2025',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Selector de tutor
              DropdownButtonFormField<User>(
                value: _selectedTutor,
                decoration: const InputDecoration(
                  labelText: 'Tutor (opcional)',
                  border: OutlineInputBorder(),
                ),
                hint: _loadingTutors
                    ? const Text('Cargando tutores...')
                    : const Text('Seleccionar tutor'),
                items: _tutors.map((tutor) {
                  return DropdownMenuItem<User>(
                    value: tutor,
                    child: Text('${tutor.fullName} (${tutor.email})'),
                  );
                }).toList(),
                onChanged: _loadingTutors
                    ? null
                    : (User? tutor) {
                        setState(() => _selectedTutor = tutor);
                      },
              ),

              const SizedBox(height: 16),

              // Teléfono
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  hintText: '+34 123 456 789',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Botón crear
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isCreating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Creando...'),
                          ],
                        )
                      : const Text('Crear Alumno'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      final student = await _userManagementService.createStudent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        academicYear: _academicYearController.text.trim().isEmpty
            ? null
            : _academicYearController.text.trim(),
        tutorId: _selectedTutor?.id,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      widget.onStudentCreated(student);

      // Limpiar el formulario
      _formKey.currentState!.reset();
      setState(() {
        _selectedTutor = null;
        _isCreating = false;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.studentCreatedSuccess ?? 'Alumno creado exitosamente',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.studentCreatedWithPassword ??
                      'El estudiante ha sido creado con la contraseña establecida. Puede iniciar sesión inmediatamente.',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 8),
          ),
        );
        Navigator.of(context).pop(); // Cerrar diálogo si se abre como diálogo
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isCreating = false;
      });
    }
  }
}
