import 'package:flutter/material.dart';
import '../../services/user_management_service.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/validators.dart';

class TutorCreationForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onTutorCreated;

  const TutorCreationForm({super.key, required this.onTutorCreated});

  @override
  State<TutorCreationForm> createState() => _TutorCreationFormState();
}

class _TutorCreationFormState extends State<TutorCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _userManagementService = UserManagementService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isCreating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _specialtyController.dispose();
    _phoneController.dispose();
    super.dispose();
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
            children: [
              Text(
                'Crear Nuevo Tutor',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'tutor@jualas.es',
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

              // Especialidad
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Especialidad',
                  hintText: 'DAM, ASIR, DAW, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La especialidad es obligatoria';
                  }
                  return null;
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
                  onPressed: _isCreating ? null : _createTutor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
                      : const Text('Crear Tutor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTutor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      final result = await _userManagementService.createTutor(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        specialty: _specialtyController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      widget.onTutorCreated(result);

      // Limpiar el formulario
      _formKey.currentState!.reset();

      setState(() {
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
                  l10n?.tutorCreatedSuccess ?? 'Tutor creado exitosamente',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.userCreatedInstructions ??
                      'El usuario recibirá un email de verificación. Después de verificar, deberá usar "¿Olvidaste tu contraseña?" para establecer su contraseña.',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isCreating = false;
      });
    }
  }
}
