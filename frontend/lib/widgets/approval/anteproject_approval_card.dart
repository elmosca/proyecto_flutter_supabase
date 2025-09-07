import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/details/anteproject_detail_screen.dart';
import 'approval_actions_widget.dart';

class AnteprojectApprovalCard extends StatelessWidget {
  final Anteproject anteproject;
  final bool showActions;

  const AnteprojectApprovalCard({
    super.key,
    required this.anteproject,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
