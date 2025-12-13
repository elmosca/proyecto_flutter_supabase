import 'dart:math';
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
  // _passwordController eliminado ya que se genera automáticamente
  final _fullNameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _nreController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _phoneController = TextEditingController();
  final _biographyController = TextEditingController();

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

  /// Genera una contraseña temporal segura
  String _generateTempPassword() {
    // Generar una contraseña temporal aleatoria de 16 caracteres
    // que cumpla con los requisitos mínimos de Supabase (mínimo 6 caracteres)
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure(); // Requiere import 'dart:math';
    final password = StringBuffer();
    for (int i = 0; i < 16; i++) {
      password.write(chars[random.nextInt(chars.length)]);
    }
    return password.toString();
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
    // _passwordController.dispose();
    _fullNameController.dispose();
    _specialtyController.dispose();
    _nreController.dispose();
    _academicYearController.dispose();
    _phoneController.dispose();
    _biographyController.dispose();
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

              // Especialidad
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Especialidad (opcional)',
                  hintText: 'DAM, ASIR, DAW, etc.',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // NRE (Número de Registro de Estudiante)
              TextFormField(
                controller: _nreController,
                decoration: const InputDecoration(
                  labelText: 'NRE (opcional)',
                  hintText: 'Número de Registro de Estudiante',
                  border: OutlineInputBorder(),
                  helperText: 'Número único de registro del estudiante',
                ),
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

              const SizedBox(height: 16),

              // Biografía
              TextFormField(
                controller: _biographyController,
                decoration: const InputDecoration(
                  labelText: 'Biografía (opcional)',
                  hintText: 'Información adicional sobre el estudiante',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
      // Generar contraseña temporal automáticamente
      // No se muestra al administrador ya que se envía por email
      final password = _generateTempPassword();

      final student = await _userManagementService.createStudent(
        email: _emailController.text.trim(),
        password: password,
        fullName: _fullNameController.text.trim(),
        specialty: _specialtyController.text.trim().isEmpty
            ? null
            : _specialtyController.text.trim(),
        nre: _nreController.text.trim().isEmpty
            ? null
            : _nreController.text.trim(),
        academicYear: _academicYearController.text.trim().isEmpty
            ? null
            : _academicYearController.text.trim(),
        tutorId: _selectedTutor?.id,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        biography: _biographyController.text.trim().isEmpty
            ? null
            : _biographyController.text.trim(),
      );

      widget.onStudentCreated(student);

      // Limpiar el formulario
      _formKey.currentState!.reset();
      setState(() {
        _selectedTutor = null;
        _isCreating = false;
        // Recargar año académico por defecto después de limpiar
        _loadDefaultAcademicYear();
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.studentCreatedSuccess ?? 'Alumno creado exitosamente',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
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

