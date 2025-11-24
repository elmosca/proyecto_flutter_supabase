import 'package:flutter/material.dart';
import '../../models/user.dart';

/// Diálogo para visualizar información detallada de un usuario (tutor o alumno).
class UserDetailDialog extends StatelessWidget {
  final User user;

  const UserDetailDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getRoleColor(user.role),
                    child: Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.role.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            color: _getRoleColor(user.role),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow(Icons.email, 'Email', user.email),
              if (user.nre != null && user.nre!.isNotEmpty)
                _buildInfoRow(Icons.badge, 'NRE', user.nre!),
              if (user.phone != null && user.phone!.isNotEmpty)
                _buildInfoRow(Icons.phone, 'Teléfono', user.phone!),
              if (user.specialty != null && user.specialty!.isNotEmpty)
                _buildInfoRow(Icons.school, 'Especialidad', user.specialty!),
              if (user.academicYear != null && user.academicYear!.isNotEmpty)
                _buildInfoRow(
                  Icons.calendar_today,
                  'Año Académico',
                  user.academicYear!,
                ),
              if (user.role == UserRole.student && user.tutorId != null)
                _buildInfoRow(
                  Icons.person_pin,
                  'ID Tutor',
                  user.tutorId.toString(),
                ),
              if (user.biography != null && user.biography!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Biografía',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(user.biography!),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.info,
                'Estado',
                _getStatusText(user.status),
                statusColor: user.status == UserStatus.active
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.access_time,
                'Creado',
                _formatDate(user.createdAt),
              ),
              _buildInfoRow(
                Icons.update,
                'Actualizado',
                _formatDate(user.updatedAt),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Editar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor ?? Colors.black87,
                    fontWeight: statusColor != null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.tutor:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
    }
  }

  String _getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'Activo';
      case UserStatus.inactive:
        return 'Inactivo';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
