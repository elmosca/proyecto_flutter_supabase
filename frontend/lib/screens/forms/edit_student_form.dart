import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart' as app_user;
import '../../services/user_service.dart';

class EditStudentForm extends StatefulWidget {
  final app_user.User student;

  const EditStudentForm({super.key, required this.student});

  @override
  State<EditStudentForm> createState() => _EditStudentFormState();
}

class _EditStudentFormState extends State<EditStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nreController = TextEditingController();
  final _phoneController = TextEditingController();
  final _biographyController = TextEditingController();
  
  String _selectedSpecialty = 'DAM';
  String _selectedAcademicYear = '2024-2025';
  app_user.UserStatus _selectedStatus = app_user.UserStatus.active;
  
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
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _fullNameController.text = widget.student.fullName;
    _emailController.text = widget.student.email;
    _nreController.text = widget.student.nre ?? '';
    _phoneController.text = widget.student.phone ?? '';
    _biographyController.text = widget.student.biography ?? '';
    _selectedSpecialty = widget.student.specialty ?? 'Desarrollo de Aplicaciones Multiplataforma';
    _selectedAcademicYear = widget.student.academicYear ?? '2024-2025';
    _selectedStatus = widget.student.status;
  }

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
      
      final updatedUser = app_user.User(
        id: widget.student.id,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        nre: _nreController.text.trim(),
        role: widget.student.role,
        phone: _phoneController.text.trim(),
        biography: _biographyController.text.trim(),
        status: _selectedStatus,
        specialty: _selectedSpecialty,
        academicYear: _selectedAcademicYear,
        tutorId: widget.student.tutorId,
        createdAt: widget.student.createdAt,
        updatedAt: DateTime.now(),
      );

      await userService.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.studentUpdatedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(updatedUser); // Retornar el usuario actualizado
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorUpdatingStudent(e.toString())),
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
        title: Text(AppLocalizations.of(context)!.editStudent),
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
              _buildStatusDropdown(),
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
                      : Text(AppLocalizations.of(context)!.updateStudent),
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

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<app_user.UserStatus>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.status,
        prefixIcon: const Icon(Icons.person_pin),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: app_user.UserStatus.values.map((app_user.UserStatus status) {
        return DropdownMenuItem<app_user.UserStatus>(
          value: status,
          child: Row(
            children: [
              Icon(
                status == app_user.UserStatus.active 
                    ? Icons.check_circle 
                    : Icons.cancel,
                color: status == app_user.UserStatus.active 
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
      onChanged: (value) {
        setState(() {
          _selectedStatus = value!;
        });
      },
    );
  }
}
