import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/config.dart';
import '../../l10n/app_localizations.dart';

/// Widget para mostrar las credenciales de prueba con soporte de internacionalización
class TestCredentialsWidget extends StatelessWidget {
  const TestCredentialsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  l10n.testCredentials,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCredentialRow(
              context,
              l10n.studentEmail,
              AppConfig.testCredentials['student']!,
              l10n,
            ),
            _buildCredentialRow(
              context,
              l10n.tutorEmail,
              AppConfig.testCredentials['tutor']!,
              l10n,
            ),
            _buildCredentialRow(
              context,
              l10n.adminEmail,
              AppConfig.testCredentials['admin']!,
              l10n,
            ),
            _buildCredentialRow(
              context,
              l10n.testPassword,
              AppConfig.testCredentials['password']!,
              l10n,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialRow(
    BuildContext context,
    String label,
    String value,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.copied),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: l10n.copyToClipboard,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
