import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../services/user_management_service.dart';
import '../../services/theme_service.dart';
import '../../services/settings_service.dart';
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
  final _settingsService = SettingsService();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nreController = TextEditingController();
  final _phoneController = TextEditingController();
  final _biographyController = TextEditingController();
  final _academicYearController = TextEditingController();

  String _selectedSpecialty = 'DAM';

  bool _isLoading = false;
  bool _isLoadingYear = true;

  final List<String> _specialties = [
    'DAM',
    'Desarrollo de Aplicaciones Multiplataforma',
    'ASIR',
    'Administración de Sistemas Informáticos en Red',
    'DAW',
    'Desarrollo de Aplicaciones Web',
  ];

  @override
  void initState() {
    super.initState();
    _loadAcademicYear();
  }

  Future<void> _loadAcademicYear() async {
    try {
      final year = await _settingsService.getStringSetting('academic_year');
      if (year != null && year.isNotEmpty && mounted) {
        setState(() {
          _academicYearController.text = year;
          _isLoadingYear = false;
        });
      } else {
        _setFallbackYear();
      }
    } catch (e) {
      debugPrint('Error loading academic year: $e');
      _setFallbackYear();
    }
  }

  void _setFallbackYear() {
    if (!mounted) return;
    final now = DateTime.now();
    final currentYear = now.year;
    // Si estamos después de agosto (mes > 8), el curso empieza este año.
    // Si estamos antes de septiembre (mes <= 8), el curso empezó el año anterior.
    // Aunque la lógica del usuario era "tome como primera cifra el año actual", asumo que se refiere al inicio de curso.
    // Simplificación para cumplir "1 de septiembre y tome el año actual":
    // Si es septiembre o después, inicio = año actual.
    // Si es antes, inicio = año anterior.
    // Pero la instrucción decía "tome como primera cifra el año actual del sistema".
    // Seguiré la lógica simple: año actual + año siguiente.
    final year = '$currentYear-${currentYear + 1}';
    setState(() {
      _academicYearController.text = year;
      _isLoadingYear = false;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _nreController.dispose();
    _phoneController.dispose();
    _biographyController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Generar una contraseña temporal segura internamente
      final password = _generateTempPassword();

      // Usar UserManagementService.createStudent que crea el usuario en Auth
      // y envía el email de verificación automáticamente
      await _userManagementService.createStudent(
        email: _emailController.text.trim(),
        password: password,
        fullName: _fullNameController.text.trim(),
        academicYear: _academicYearController.text, // Usar valor automatizado
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.studentCreatedSuccess ?? 'Estudiante creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
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
              // Campo de año académico automatizado (solo lectura)
              TextFormField(
                controller: _academicYearController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.academicYear,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade200, // Visualmente deshabilitado
                  suffixIcon: _isLoadingYear 
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
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
