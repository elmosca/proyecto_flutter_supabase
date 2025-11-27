import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../utils/app_exception.dart';
import '../../utils/error_translator.dart';

/// Diálogo para solicitar recuperación de contraseña
class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;
  bool _sentToTutor = false;
  String? _tutorName;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _authService.resetPasswordForEmail(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _emailSent = true;
          _sentToTutor = result['sentToTutor'] as bool;
          _tutorName = result['tutorName'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final message = e is AppException
            ? ErrorTranslator.getFallbackMessage(e)
            : 'Error al enviar el enlace de recuperación: $e';
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock_reset, color: Colors.blue),
          const SizedBox(width: 8),
          Text(l10n.resetPassword),
        ],
      ),
      content: _emailSent
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _sentToTutor
                      ? Icons.notifications_active
                      : Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _sentToTutor
                      ? l10n.resetPasswordRequestSent
                      : l10n.resetLinkSent,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_sentToTutor && _tutorName != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.resetPasswordRequestSentDescription(_tutorName!),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.resetPasswordInstructions,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _sendResetLink(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '${l10n.email} ${l10n.errorFieldRequired}';
                        }
                        if (!value.contains('@')) {
                          return l10n.errorInvalidEmail;
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
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
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
      actions: _emailSent
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.login),
              ),
            ]
          : [
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendResetLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
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
                    : Text(l10n.sendResetLink),
              ),
            ],
    );
  }
}
