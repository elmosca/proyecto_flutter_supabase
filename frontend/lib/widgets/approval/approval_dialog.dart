import 'package:flutter/material.dart';
import '../../blocs/approval_bloc.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/validators.dart';

class ApprovalDialog extends StatefulWidget {
  final Anteproject anteproject;
  final ApprovalAction action;
  final void Function(String? comments) onConfirm;

  const ApprovalDialog({
    super.key,
    required this.anteproject,
    required this.action,
    required this.onConfirm,
  });

  @override
  State<ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<ApprovalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          _getActionIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_getTitle(l10n)),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del anteproyecto
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.anteproject.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.anteproject.projectType.shortName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Mensaje de confirmación
              Text(
                _getConfirmMessage(l10n),
                style: theme.textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 16),
              
              // Campo de comentarios
              TextFormField(
                controller: _commentsController,
                decoration: InputDecoration(
                  labelText: _getCommentsLabel(l10n),
                  hintText: _getCommentsHint(l10n),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.comment),
                ),
                maxLines: 4,
                validator: _isCommentsRequired() 
                    ? Validators.validateCommentContent
                    : null,
                enabled: !_isLoading,
              ),
              
              if (_isCommentsRequired()) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.commentsRequired,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getActionColor(),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(_getActionText(l10n)),
        ),
      ],
    );
  }

  Widget _getActionIcon() {
    switch (widget.action) {
      case ApprovalAction.approve:
        return const Icon(Icons.check_circle, color: Colors.green);
      case ApprovalAction.reject:
        return const Icon(Icons.cancel, color: Colors.red);
      case ApprovalAction.requestChanges:
        return const Icon(Icons.edit, color: Colors.orange);
    }
  }

  String _getTitle(AppLocalizations l10n) {
    switch (widget.action) {
      case ApprovalAction.approve:
        return l10n.confirmApproval;
      case ApprovalAction.reject:
        return l10n.confirmRejection;
      case ApprovalAction.requestChanges:
        return l10n.confirmChanges;
    }
  }

  String _getConfirmMessage(AppLocalizations l10n) {
    switch (widget.action) {
      case ApprovalAction.approve:
        return l10n.approvalConfirmMessage;
      case ApprovalAction.reject:
        return l10n.rejectionConfirmMessage;
      case ApprovalAction.requestChanges:
        return l10n.changesConfirmMessage;
    }
  }

  String _getCommentsLabel(AppLocalizations l10n) {
    switch (widget.action) {
      case ApprovalAction.approve:
        return l10n.approvalComments;
      case ApprovalAction.reject:
        return l10n.rejectionComments;
      case ApprovalAction.requestChanges:
        return l10n.changesComments;
    }
  }

  String _getCommentsHint(AppLocalizations l10n) {
    switch (widget.action) {
      case ApprovalAction.approve:
        return l10n.approvalCommentsHint;
      case ApprovalAction.reject:
        return l10n.rejectionCommentsHint;
      case ApprovalAction.requestChanges:
        return l10n.changesCommentsHint;
    }
  }

  String _getActionText(AppLocalizations l10n) {
    switch (widget.action) {
      case ApprovalAction.approve:
        return l10n.approve;
      case ApprovalAction.reject:
        return l10n.reject;
      case ApprovalAction.requestChanges:
        return l10n.requestChanges;
    }
  }

  Color _getActionColor() {
    switch (widget.action) {
      case ApprovalAction.approve:
        return Colors.green;
      case ApprovalAction.reject:
        return Colors.red;
      case ApprovalAction.requestChanges:
        return Colors.orange;
    }
  }

  bool _isCommentsRequired() {
    return widget.action == ApprovalAction.reject || 
           widget.action == ApprovalAction.requestChanges;
  }

  void _handleConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final comments = _commentsController.text.trim();
      widget.onConfirm(comments.isEmpty ? null : comments);
      
      Navigator.of(context).pop();
    }
  }
}
