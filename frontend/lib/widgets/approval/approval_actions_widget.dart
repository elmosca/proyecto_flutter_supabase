import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/approval_bloc.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import 'approval_dialog.dart';

class ApprovalActionsWidget extends StatelessWidget {
  final Anteproject anteproject;

  const ApprovalActionsWidget({
    super.key,
    required this.anteproject,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<ApprovalBloc, ApprovalState>(
      builder: (context, state) {
        final isProcessing = state is ApprovalProcessing && 
                           state.anteprojectId == anteproject.id;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.gavel,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.approvalWorkflow,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (isProcessing) ...[
                // Mostrar estado de procesamiento
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.processing,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Mostrar botones de acción
                Row(
                  children: [
                    // Botón Aprobar
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showApprovalDialog(
                          context,
                          ApprovalAction.approve,
                        ),
                        icon: const Icon(Icons.check_circle),
                        label: Text(l10n.approve),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Botón Solicitar Cambios
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showApprovalDialog(
                          context,
                          ApprovalAction.requestChanges,
                        ),
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.requestChanges),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Botón Rechazar (ancho completo)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showApprovalDialog(
                      context,
                      ApprovalAction.reject,
                    ),
                    icon: const Icon(Icons.cancel),
                    label: Text(l10n.reject),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showApprovalDialog(BuildContext context, ApprovalAction action) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ApprovalDialog(
        anteproject: anteproject,
        action: action,
        onConfirm: (comments) {
          // Usar el contexto original del widget, no el del diálogo
          switch (action) {
            case ApprovalAction.approve:
              context.read<ApprovalBloc>().add(
                ApproveAnteproject(
                  anteprojectId: anteproject.id,
                  comments: comments,
                ),
              );
              break;
            case ApprovalAction.reject:
              context.read<ApprovalBloc>().add(
                RejectAnteproject(
                  anteprojectId: anteproject.id,
                  comments: comments ?? '',
                ),
              );
              break;
            case ApprovalAction.requestChanges:
              context.read<ApprovalBloc>().add(
                RequestChanges(
                  anteprojectId: anteproject.id,
                  comments: comments ?? '',
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
