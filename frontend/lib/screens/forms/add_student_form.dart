import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart' as app_user;
import '../../services/user_service.dart';

class AddStudentForm extends StatefulWidget {
  final int tutorId;

  const AddStudentForm({super.key, required this.tutorId});

  @override
  State<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nreController = TextEditingController();
  final _phoneController = TextEditingController();
  final _biographyController = TextEditingController();
  
  String _selectedSpecialty = 'DAM';
  String _selectedAcademicYear = '2024-2025';
  
  bool _isLoading = false;

  final List<String> _specialties = [
    'DAM',
    'Desarrollo de Aplicaciones Multiplataforma',
    'ASIR',
    'Administración de Sistemas Informáticos en Red',
    'DAW',
    'Desarrollo de Aplicaciones Web',
  ];

  final List<String> _academicYears = [
    '2024-2025',
    '2025-2026',
    '2026-2027',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _nreController.dispose();
    _phoneController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = UserService();
      
      final newUser = app_user.User(
        id: 0, // Se asignará automáticamente
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        nre: _nreController.text.trim(),
        role: app_user.UserRole.student,
        phone: _phoneController.text.trim(),
        biography: _biographyController.text.trim(),
        status: app_user.UserStatus.active,
        specialty: _selectedSpecialty,
        academicYear: _selectedAcademicYear,
        tutorId: widget.tutorId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userService.createUser(newUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.studentCreatedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorCreatingStudent(e.toString())),
            backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addStudent),
        backgroundColor: Colors.blue,
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.emailRequired;
                  }
                  if (!value.contains('@')) {
                    return AppLocalizations.of(context)!.emailInvalid;
                  }
                  return null;
                },
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
                    backgroundColor: Colors.blue,
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
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
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
