import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../services/user_management_service.dart';
import '../../services/theme_service.dart';
import '../../utils/app_exception.dart';
import '../../utils/validators.dart';

class AddStudentForm extends StatefulWidget {
  final int tutorId;

  const AddStudentForm({super.key, required this.tutorId});

  @override
  State<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _userManagementService = UserManagementService();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nreController = TextEditingController();
  final _phoneController = TextEditingController();
  final _biographyController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedSpecialty = 'DAM';
  String _selectedAcademicYear = '2024-2025';

  bool _isLoading = false;
  bool _generatePasswordAuto = true;
  bool _obscurePassword = true;

  final List<String> _specialties = [
    'DAM',
    'Desarrollo de Aplicaciones Multiplataforma',
    'ASIR',
    'Administración de Sistemas Informáticos en Red',
    'DAW',
    'Desarrollo de Aplicaciones Web',
  ];

  final List<String> _academicYears = ['2024-2025', '2025-2026', '2026-2027'];

  @override
  void initState() {
    super.initState();
    // Generar contraseña inicial si está en modo automático
    if (_generatePasswordAuto) {
      _generateAndSetPassword();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _nreController.dispose();
    _phoneController.dispose();
    _biographyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _generateAndSetPassword() {
    final generatedPassword = _generateTempPassword();
    setState(() {
      _passwordController.text = generatedPassword;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener la contraseña: la del formulario o generar una automática
      final password = _generatePasswordAuto
          ? _passwordController.text.trim()
          : (_passwordController.text.trim().isEmpty
                ? _generateTempPassword()
                : _passwordController.text.trim());

      // Usar UserManagementService.createStudent que crea el usuario en Auth
      // y envía el email de verificación automáticamente
      await _userManagementService.createStudent(
        email: _emailController.text.trim(),
        password: password,
        fullName: _fullNameController.text.trim(),
        academicYear: _selectedAcademicYear,
        tutorId: widget.tutorId,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        nre: _nreController.text.trim().isEmpty
            ? null
            : _nreController.text.trim(),
        specialty: _selectedSpecialty,
        biography: _biographyController.text.trim().isEmpty
            ? null
            : _biographyController.text.trim(),
      );

      if (mounted) {
        // Mostrar diálogo con la contraseña para que el tutor la vea
        await _showPasswordDialog(password);
        Navigator.of(context).pop(true); // Retornar true para indicar éxito
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        String errorMessage;

        // Si es una AppException con código específico, usar el traductor
        if (e is AppException) {
          final errorCode = e.code;
          // Detectar rate limiting específicamente
          if (errorCode == 'rate_limit_exceeded') {
            errorMessage =
                l10n?.errorRateLimitExceeded ??
                'Demasiadas solicitudes. Por favor, espera un momento e inténtalo de nuevo.';
          } else if (errorCode == 'email_already_registered' ||
              errorCode == 'resource_already_exists') {
            // Email ya registrado (posible reutilización reciente)
            errorMessage =
                l10n?.errorEmailAlreadyRegistered ??
                'Este correo electrónico ya está registrado. Si acabas de eliminar un usuario con este correo, por favor espera unos minutos antes de intentar crear otro usuario con el mismo email.';
          } else {
            // Para otros errores, usar el mensaje técnico con formato
            errorMessage =
                l10n?.errorCreatingStudent(
                  e.technicalMessage ?? e.toString(),
                ) ??
                'Error al crear estudiante: ${e.technicalMessage ?? e.toString()}';
          }
        } else {
          // Para errores no categorizados, usar el formato estándar
          final errorString = e.toString();
          // Detectar rate limiting en el mensaje de error
          if (errorString.contains('only request this after') ||
              errorString.contains('rate limit') ||
              errorString.contains('too many requests')) {
            errorMessage =
                l10n?.errorRateLimitExceeded ??
                'Demasiadas solicitudes. Por favor, espera un momento e inténtalo de nuevo.';
          } else if (errorString.contains('already registered') ||
              errorString.contains('already been registered') ||
              (errorString.contains('email') &&
                  (errorString.contains('already') ||
                      errorString.contains('exists')))) {
            // Email ya registrado (posible reutilización reciente)
            errorMessage =
                l10n?.errorEmailAlreadyRegistered ??
                'Este correo electrónico ya está registrado. Si acabas de eliminar un usuario con este correo, por favor espera unos minutos antes de intentar crear otro usuario con el mismo email.';
          } else {
            errorMessage =
                l10n?.errorCreatingStudent(errorString) ??
                'Error al crear estudiante: $errorString';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(
              seconds: 6,
            ), // Mostrar más tiempo para rate limiting
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Genera una contraseña temporal segura.
  /// El usuario cambiará esta contraseña después de verificar su email.
  String _generateTempPassword() {
    // Generar una contraseña temporal aleatoria de 16 caracteres
    // que cumpla con los requisitos mínimos de Supabase (mínimo 6 caracteres)
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    final password = StringBuffer();
    for (int i = 0; i < 16; i++) {
      password.write(chars[random.nextInt(chars.length)]);
    }
    return password.toString();
  }

  /// Muestra un diálogo con la contraseña del estudiante creado
  Future<void> _showPasswordDialog(String password) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            l10n?.studentCreatedSuccess ?? 'Alumno creado exitosamente',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.studentCreatedWithPassword ??
                      'El estudiante ha sido creado con la contraseña establecida. Puede iniciar sesión inmediatamente.',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contraseña del estudiante:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          password,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copiar contraseña',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: password));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Contraseña copiada al portapapeles',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Guarda esta contraseña de forma segura. El estudiante la necesitará para iniciar sesión.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n?.close ?? 'Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addStudent),
        backgroundColor: ThemeService.instance.currentPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormField(
                controller: _fullNameController,
                label: AppLocalizations.of(context)!.fullName,
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.nameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _emailController,
                label: AppLocalizations.of(context)!.email,
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                helperText: 'Debe ser del dominio: jualas.es',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => Validators.email(
                  value,
                  AppLocalizations.of(context)!.emailRequired,
                ),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _nreController,
                label: AppLocalizations.of(context)!.nreLabel,
                icon: Icons.badge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.nreRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo de contraseña con opción de generar automáticamente
              Row(
                children: [
                  Checkbox(
                    value: _generatePasswordAuto,
                    onChanged: (value) {
                      setState(() {
                        _generatePasswordAuto = value ?? true;
                        if (_generatePasswordAuto) {
                          _generateAndSetPassword();
                        } else {
                          _passwordController.clear();
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.generatePasswordAutomatically,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_generatePasswordAuto)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: AppLocalizations.of(context)!.regeneratePassword,
                      onPressed: _generateAndSetPassword,
                    ),
                ],
              ),
              if (!_generatePasswordAuto) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
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
                      ],
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppLocalizations.of(context)!.passwordTooShort;
                    }
                    return null;
                  },
                ),
              ],
              if (_generatePasswordAuto) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contraseña generada:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              _passwordController.text,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copiar contraseña',
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _passwordController.text),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Contraseña copiada al portapapeles',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildFormField(
                controller: _phoneController,
                label: AppLocalizations.of(context)!.phoneOptional,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: AppLocalizations.of(context)!.specialty,
                value: _selectedSpecialty,
                items: _specialties,
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialty = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: AppLocalizations.of(context)!.academicYear,
                value: _selectedAcademicYear,
                items: _academicYears,
                onChanged: (value) {
                  setState(() {
                    _selectedAcademicYear = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _biographyController,
                label: AppLocalizations.of(context)!.biographyOptional,
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeService.instance.currentPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(AppLocalizations.of(context)!.createStudent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? helperText,
    AutovalidateMode? autovalidateMode,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
        helperText: helperText,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.school),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
