import 'dart:math';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/user_management_service.dart';
import '../../utils/app_exception.dart';

/// Diálogo para resetear la contraseña de un estudiante.
///
/// Permite al tutor o administrador:
/// - Generar una contraseña automáticamente
/// - Establecer una contraseña manualmente
/// - Enviar notificación al estudiante
class ResetPasswordDialog extends StatefulWidget {
  final String studentEmail;
  final String studentName;

  const ResetPasswordDialog({
    super.key,
    required this.studentEmail,
    required this.studentName,
  });

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _userManagementService = UserManagementService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _generatePassword = true;
  String? _errorMessage;
  String? _generatedPassword;

  @override
  void initState() {
    super.initState();
    _generateNewPassword();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _generateNewPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    final password = StringBuffer();
    for (int i = 0; i < 12; i++) {
      password.write(chars[random.nextInt(chars.length)]);
    }
    setState(() {
      _generatedPassword = password.toString();
      _passwordController.text = _generatedPassword!;
    });
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final password = _passwordController.text.trim();

      await _userManagementService.resetStudentPassword(
        studentEmail: widget.studentEmail,
        newPassword: password,
        sendNotification: true,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.passwordResetSuccess,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.passwordResetNotificationSent,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        String errorMessage;

        if (e is AppException) {
          errorMessage = e.technicalMessage ?? e.toString();
        } else {
          errorMessage = l10n.passwordResetError(e.toString());
        }

        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.resetPassword),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.resetPasswordForStudent(widget.studentName),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _generatePassword,
                    onChanged: (value) {
                      setState(() {
                        _generatePassword = value ?? true;
                        if (_generatePassword) {
                          _generateNewPassword();
                        } else {
                          _passwordController.clear();
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      l10n.generatePasswordAutomatically,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_generatePassword)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: l10n.regeneratePassword,
                      onPressed: _generateNewPassword,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: l10n.newPassword,
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
                enabled: !_generatePassword,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.passwordRequired;
                  }
                  if (value.length < 6) {
                    return l10n.passwordTooShort;
                  }
                  return null;
                },
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _resetPassword,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.resetPassword),
        ),
      ],
    );
  }
}
