import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/anteprojects/anteproject_detail_screen.dart';
import 'approval_actions_widget.dart';

class AnteprojectApprovalCard extends StatelessWidget {
  final Map<String, dynamic> anteprojectData;
  final bool showActions;

  const AnteprojectApprovalCard({
    super.key,
    required this.anteprojectData,
    this.showActions = true,
  });

  // Constructor legacy para compatibilidad (deprecated)
  @Deprecated('Use AnteprojectApprovalCard.withData instead')
  AnteprojectApprovalCard.fromAnteproject({
    super.key,
    required Anteproject anteproject,
    this.showActions = true,
  }) : anteprojectData = anteproject.toJson();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final anteproject = Anteproject.fromJson(anteprojectData);

    // Obtener información del estudiante desde la tabla de relación
    final anteprojectStudents =
        anteprojectData['anteproject_students'] as List<dynamic>?;
    
    // Debug: verificar qué datos tenemos
    debugPrint('🔍 Approval Card - Anteproyecto ID: ${anteproject.id}');
    debugPrint('🔍 Approval Card - anteproject_students tipo: ${anteprojectStudents.runtimeType}');
    debugPrint('🔍 Approval Card - anteproject_students valor: $anteprojectStudents');
    
    // Convertir de forma segura a Map
    Map<String, dynamic>? studentInfo;
    if (anteprojectStudents != null && anteprojectStudents.isNotEmpty) {
      try {
        final firstStudent = anteprojectStudents[0];
        debugPrint('🔍 Approval Card - Primer estudiante tipo: ${firstStudent.runtimeType}');
        debugPrint('🔍 Approval Card - Primer estudiante valor: $firstStudent');
        
        // Función auxiliar para convertir de forma segura
        Map<String, dynamic> safeConvert(dynamic data) {
          if (data is Map<String, dynamic>) {
            return data;
          } else if (data is Map) {
            final result = <String, dynamic>{};
            for (final key in data.keys) {
              result[key.toString()] = data[key];
            }
            return result;
          } else {
            return <String, dynamic>{};
          }
        }
        
        final firstStudentMap = safeConvert(firstStudent);
        debugPrint('🔍 Approval Card - Estudiante convertido: $firstStudentMap');
        
        if (firstStudentMap.containsKey('users')) {
          final usersData = firstStudentMap['users'];
          debugPrint('🔍 Approval Card - users tipo: ${usersData.runtimeType}');
          debugPrint('🔍 Approval Card - users valor: $usersData');
          
          if (usersData != null) {
            studentInfo = safeConvert(usersData);
            debugPrint('🔍 Approval Card - studentInfo final: $studentInfo');
          }
        } else {
          debugPrint('⚠️ Approval Card - No se encontró campo "users" en estudiante');
        }
      } catch (e, stackTrace) {
        debugPrint('⚠️ Error procesando información del estudiante en approval card: $e');
        debugPrint('⚠️ Stack trace: $stackTrace');
        studentInfo = null;
      }
    } else {
      debugPrint('⚠️ Approval Card - No hay estudiantes asociados al anteproyecto ${anteproject.id}');
    }

    final studentName = studentInfo?['full_name'] ?? 'Estudiante desconocido';
    final studentEmail = studentInfo?['email'] ?? '';
    final studentNre = studentInfo?['nre'] ?? '';

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anteproject.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        anteproject.projectType.shortName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusChip(context, anteproject.status),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Información del estudiante
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        if (studentEmail.isNotEmpty)
                          Text(
                            studentEmail,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        if (studentNre.isNotEmpty)
                          Text(
                            'NRE: $studentNre',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Descripción (truncada)
            Text(
              anteproject.description,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Información de fechas y tutor
            _buildInfoSection(context, anteproject),
            
            // Comentarios del tutor (si existen)
            if (anteproject.tutorComments != null && anteproject.tutorComments!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildTutorComments(context, anteproject.tutorComments!),
            ],
            
            // Acciones (solo si showActions es true)
            if (showActions) ...[
              const SizedBox(height: 16),
              ApprovalActionsWidget(anteproject: anteproject),
            ],
            
            // Botón de ver detalles
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AnteprojectDetailScreen(anteproject: anteproject),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: Text(l10n.viewDetails),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, AnteprojectStatus status) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (status) {
      case AnteprojectStatus.submitted:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.send;
        break;
      case AnteprojectStatus.underReview:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.rate_review;
        break;
      case AnteprojectStatus.approved:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case AnteprojectStatus.rejected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.edit_note;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, Anteproject anteproject) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (anteproject.submittedAt != null)
            _buildInfoRow(
              context,
              Icons.send,
              l10n.submittedOn,
              dateFormat.format(anteproject.submittedAt!),
            ),
          
          if (anteproject.reviewedAt != null) ...[
            if (anteproject.submittedAt != null) const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.rate_review,
              l10n.reviewedOn,
              dateFormat.format(anteproject.reviewedAt!),
            ),
          ],
          
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Icons.school,
            l10n.academicYear,
            anteproject.academicYear,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildTutorComments(BuildContext context, String comments) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.tutorComments,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comments,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
