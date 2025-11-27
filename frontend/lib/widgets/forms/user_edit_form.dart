import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_management_service.dart';
import '../../utils/validators.dart';

/// Formulario reutilizable para editar usuarios (tutores y alumnos).
class UserEditForm extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdated;

  const UserEditForm({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<UserEditForm> createState() => _UserEditFormState();
}

class _UserEditFormState extends State<UserEditForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nreController = TextEditingController();
  final _phoneController = TextEditingController();
  final _biographyController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedStatus;
  int? _selectedTutorId;
  List<User> _availableTutors = [];
  bool _loadingTutors = false;
  bool _isSaving = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    if (widget.user.role == UserRole.student) {
      _loadTutors();
    }
  }

  void _initializeForm() {
    _fullNameController.text = widget.user.fullName;
    _emailController.text = widget.user.email;
    _nreController.text = widget.user.nre ?? '';
    _phoneController.text = widget.user.phone ?? '';
    _biographyController.text = widget.user.biography ?? '';
    _specialtyController.text = widget.user.specialty ?? '';
    _academicYearController.text = widget.user.academicYear ?? '';
    _selectedStatus = widget.user.status.name;
    _selectedTutorId = widget.user.tutorId;
  }

  Future<void> _loadTutors() async {
    setState(() => _loadingTutors = true);
    try {
      final service = UserManagementService();
      final tutors = await service.getTutors();
      if (mounted) {
        setState(() {
          _availableTutors = tutors;
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
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _nreController.dispose();
    _phoneController.dispose();
    _biographyController.dispose();
    _specialtyController.dispose();
    _academicYearController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final service = UserManagementService();
      final updates = <String, dynamic>{
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        if (_nreController.text.trim().isNotEmpty)
          'nre': _nreController.text.trim(),
        if (_phoneController.text.trim().isNotEmpty)
          'phone': _phoneController.text.trim(),
        if (_biographyController.text.trim().isNotEmpty)
          'biography': _biographyController.text.trim(),
        if (_specialtyController.text.trim().isNotEmpty)
          'specialty': _specialtyController.text.trim(),
        if (_academicYearController.text.trim().isNotEmpty)
          'academic_year': _academicYearController.text.trim(),
        'status': _selectedStatus,
      };

      // Si es estudiante y se cambió el tutor
      if (widget.user.role == UserRole.student &&
          _selectedTutorId != widget.user.tutorId) {
        updates['tutor_id'] = _selectedTutorId;
      }

      final updatedUser = await service.updateUser(widget.user.id, updates);

      // Si se marcó cambiar contraseña y se proporcionó una nueva
      if (_changePassword && _passwordController.text.trim().isNotEmpty) {
        try {
          await service.updateStudentPassword(
            studentEmail: updatedUser.email,
            newPassword: _passwordController.text.trim(),
          );
        } catch (e) {
          // Si falla la actualización de contraseña, mostrar error pero no fallar todo
          setState(() {
            _errorMessage =
                'Usuario actualizado, pero error al cambiar contraseña: $e';
            _isSaving = false;
          });
          return;
        }
      }

      widget.onUserUpdated(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar ${widget.user.role.displayName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Nombre completo
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre Completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    helperText: 'Debe ser del dominio: jualas.es',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      Validators.email(value, 'El email es obligatorio'),
                ),
                const SizedBox(height: 16),

                // NRE (solo para estudiantes)
                if (widget.user.role == UserRole.student)
                  TextFormField(
                    controller: _nreController,
                    decoration: const InputDecoration(
                      labelText: 'NRE (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                if (widget.user.role == UserRole.student)
                  const SizedBox(height: 16),

                // Teléfono
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Especialidad
                TextFormField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(
                    labelText: 'Especialidad (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                ),
                const SizedBox(height: 16),

                // Año académico
                TextFormField(
                  controller: _academicYearController,
                  decoration: const InputDecoration(
                    labelText: 'Año Académico (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de tutor (solo para estudiantes)
                if (widget.user.role == UserRole.student) ...[
                  DropdownButtonFormField<int>(
                    value: _selectedTutorId,
                    decoration: const InputDecoration(
                      labelText: 'Tutor',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_pin),
                    ),
                    hint: _loadingTutors
                        ? const Text('Cargando tutores...')
                        : const Text('Sin tutor asignado'),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Sin tutor asignado'),
                      ),
                      ..._availableTutors.map((tutor) {
                        return DropdownMenuItem<int>(
                          value: tutor.id,
                          child: Text('${tutor.fullName} (${tutor.email})'),
                        );
                      }),
                    ],
                    onChanged: _loadingTutors
                        ? null
                        : (int? tutorId) {
                            setState(() => _selectedTutorId = tutorId);
                          },
                  ),
                  const SizedBox(height: 16),
                ],

                // Biografía
                TextFormField(
                  controller: _biographyController,
                  decoration: const InputDecoration(
                    labelText: 'Biografía (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Estado
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info),
                  ),
                  items: UserStatus.values.map((status) {
                    return DropdownMenuItem<String>(
                      value: status.name,
                      child: Row(
                        children: [
                          Icon(
                            status == UserStatus.active
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: status == UserStatus.active
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(status.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
                const SizedBox(height: 16),

                // Cambiar contraseña (solo para estudiantes)
                if (widget.user.role == UserRole.student) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: _changePassword,
                        onChanged: (value) {
                          setState(() {
                            _changePassword = value ?? false;
                            if (!_changePassword) {
                              _passwordController.clear();
                            }
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Cambiar contraseña',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  if (_changePassword) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (_changePassword &&
                            (value == null || value.trim().isEmpty)) {
                          return 'La contraseña es obligatoria si marcaste cambiar contraseña';
                        }
                        if (_changePassword &&
                            value != null &&
                            value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ],

                if (_errorMessage != null) ...[
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
                  const SizedBox(height: 16),
                ],

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
