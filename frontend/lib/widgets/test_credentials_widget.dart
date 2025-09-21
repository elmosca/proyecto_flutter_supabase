import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestCredentialsWidget extends StatelessWidget {
  const TestCredentialsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Credenciales de Prueba',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Credenciales específicas del proyecto
            const Text(
              'Credenciales del Proyecto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 12),
            
            // Tutor específico
            _buildCredentialCard(
              context,
              title: 'Tutor - Jualas',
              email: 'jualas@jualas.es',
              password: 'tutor123',
              color: Colors.green,
              icon: Icons.person,
            ),
            
            const SizedBox(height: 12),
            
            // Estudiante específico
            _buildCredentialCard(
              context,
              title: 'Estudiante - Juan Antonio Francés Pérez',
              email: '3850437@alu.murciaeduca.es',
              password: 'student123',
              color: Colors.blue,
              icon: Icons.school,
            ),
            
            const SizedBox(height: 16),
            
            // Credenciales de prueba genéricas
            const Text(
              'Credenciales de Prueba Genéricas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            
            // Credenciales de Estudiante genérico
            _buildCredentialCard(
              context,
              title: 'Estudiante Genérico',
              email: 'student.test@alumno.cifpcarlos3.es',
              password: 'student123',
              color: Colors.blue.shade300,
              icon: Icons.school,
            ),
            
            const SizedBox(height: 12),
            
            // Credenciales de Tutor genérico
            _buildCredentialCard(
              context,
              title: 'Tutor Genérico',
              email: 'tutor.test@cifpcarlos3.es',
              password: 'tutor123',
              color: Colors.green.shade300,
              icon: Icons.person,
            ),
            
            const SizedBox(height: 12),
            
            // Credenciales de Admin
            _buildCredentialCard(
              context,
              title: 'Administrador',
              email: 'admin.test@cifpcarlos3.es',
              password: 'admin123',
              color: Colors.purple,
              icon: Icons.admin_panel_settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialCard(
    BuildContext context, {
    required String title,
    required String email,
    required String password,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Email
          _buildCredentialField(
            context,
            label: 'Email',
            value: email,
            onCopy: () => _copyToClipboard(context, email),
          ),
          
          const SizedBox(height: 4),
          
          // Password
          _buildCredentialField(
            context,
            label: 'Contraseña',
            value: password,
            onCopy: () => _copyToClipboard(context, password),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialField(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onCopy,
          icon: const Icon(Icons.copy, size: 16),
          tooltip: 'Copiar $label',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiado: $text'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
