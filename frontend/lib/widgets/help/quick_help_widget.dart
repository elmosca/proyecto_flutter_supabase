import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';

/// Widget de ayuda rápida que se muestra en el dashboard
/// Proporciona acceso rápido a funciones principales y guía de uso
class QuickHelpWidget extends StatelessWidget {
  final User user;

  const QuickHelpWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildContentForRole(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.lightbulb_outline,
            color: Colors.blue[700],
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💡 Guía Rápida',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
              ),
              Text(
                _getSubtitleForRole(),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
          onPressed: () {
            // Aquí podrías implementar lógica para ocultar permanentemente
            // Por ahora solo muestra un snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Puedes acceder a la guía completa desde el menú'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          tooltip: 'Cerrar',
        ),
      ],
    );
  }

  String _getSubtitleForRole() {
    switch (user.role) {
      case UserRole.student:
        return 'Empieza aquí tu camino en el proyecto';
      case UserRole.tutor:
        return 'Gestiona eficientemente a tus estudiantes';
      case UserRole.admin:
        return 'Administra el sistema correctamente';
    }
  }

  Widget _buildContentForRole(BuildContext context) {
    switch (user.role) {
      case UserRole.student:
        return _buildStudentQuickHelp(context);
      case UserRole.tutor:
        return _buildTutorQuickHelp(context);
      case UserRole.admin:
        return _buildAdminQuickHelp(context);
    }
  }

  // ===== AYUDA RÁPIDA PARA ESTUDIANTES =====

  Widget _buildStudentQuickHelp(BuildContext context) {
    return Column(
      children: [
        _buildQuickStep(
          '1',
          'Crea tu Anteproyecto',
          'Propón tu idea de proyecto',
          Icons.description,
          Colors.blue,
          () => context.go('/anteprojects', extra: user),
        ),
        const SizedBox(height: 8),
        _buildQuickStep(
          '2',
          'Revisa tus Tareas',
          'Ve qué debes hacer esta semana',
          Icons.task_alt,
          Colors.purple,
          () => context.go('/tasks', extra: user),
        ),
        const SizedBox(height: 8),
        _buildQuickStep(
          '3',
          'Usa el Kanban',
          'Organiza tu trabajo visualmente',
          Icons.view_kanban,
          Colors.green,
          () => context.go('/kanban', extra: user),
        ),
        const SizedBox(height: 16),
        _buildViewFullGuideButton(context),
      ],
    );
  }

  // ===== AYUDA RÁPIDA PARA TUTORES =====

  Widget _buildTutorQuickHelp(BuildContext context) {
    return Column(
      children: [
        _buildQuickLink(
          'Revisar Anteproyectos Pendientes',
          Icons.assignment,
          Colors.orange,
          () => context.go('/anteprojects', extra: user),
        ),
        const SizedBox(height: 8),
        _buildQuickLink(
          'Ver Mis Estudiantes',
          Icons.people,
          Colors.blue,
          () => context.go('/students', extra: user),
        ),
        const SizedBox(height: 8),
        _buildQuickLink(
          'Flujo de Aprobación',
          Icons.gavel,
          Colors.green,
          () => context.go('/approval-workflow', extra: user),
        ),
        const SizedBox(height: 16),
        _buildViewFullGuideButton(context),
      ],
    );
  }

  // ===== AYUDA RÁPIDA PARA ADMINISTRADORES =====

  Widget _buildAdminQuickHelp(BuildContext context) {
    return Column(
      children: [
        _buildQuickLink(
          'Gestionar Usuarios',
          Icons.people_alt,
          Colors.red,
          () => context.go('/admin/users'),
        ),
        const SizedBox(height: 8),
        _buildQuickLink(
          'Ver Configuración',
          Icons.settings,
          Colors.blue,
          () => context.go('/admin/settings'),
        ),
        const SizedBox(height: 8),
        _buildQuickLink(
          'Revisar Flujo de Aprobación',
          Icons.gavel,
          Colors.green,
          () => context.go('/admin/approval-workflow', extra: user),
        ),
        const SizedBox(height: 16),
        _buildViewFullGuideButton(context),
      ],
    );
  }

  // ===== WIDGETS AUXILIARES =====

  Widget _buildQuickStep(
    String number,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLink(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildViewFullGuideButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.go('/help', extra: user),
        icon: const Icon(Icons.menu_book),
        label: const Text('Ver Guía Completa'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue[700],
          side: BorderSide(color: Colors.blue[300]!),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

