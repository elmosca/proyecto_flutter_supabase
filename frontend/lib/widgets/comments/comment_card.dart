import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/comment.dart';
import '../../models/user.dart';
import '../../services/comments_service.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final User currentUser;
  final Function(String) onEdit;
  final VoidCallback onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    required this.currentUser,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _isEditing = false;
  final _editController = TextEditingController();
  final _editFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _editController.text = widget.comment.content;
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsService = CommentsService();
    
    // Verificar permisos
    final canEdit = commentsService.canEditComment(widget.comment, widget.currentUser);
    final canDelete = commentsService.canDeleteComment(widget.comment, widget.currentUser);
    final canViewInternal = commentsService.canViewInternalComments(widget.currentUser);

    // Si es un comentario interno y el usuario no puede verlo, no mostrar
    if (widget.comment.isInternal && !canViewInternal) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del comentario
            Row(
              children: [
                // Avatar del autor
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getAuthorColor(),
                  child: Text(
                    (widget.comment.author?.fullName ?? '').isNotEmpty ? widget.comment.author!.fullName.substring(0, 1).toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Información del autor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.comment.author?.fullName ?? AppLocalizations.of(context)!.unknownUser,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(widget.comment.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Indicador de comentario interno
                if (widget.comment.isInternal)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.commentsInternal,
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                // Menú de acciones
                if (canEdit || canDelete)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          setState(() {
                            _isEditing = true;
                          });
                          break;
                        case 'delete':
                          widget.onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (canEdit)
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 16),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.commentsEdit),
                            ],
                          ),
                        ),
                      if (canDelete)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 16, color: Colors.red),
                              const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.commentsDelete,
                          style: const TextStyle(color: Colors.red),
                        ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Contenido del comentario
            if (_isEditing) ...[
              // Modo edición
              Form(
                key: _editFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _editController,
                      maxLines: 3,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.commentsContentRequired;
                        }
                        if (value.trim().length < 3) {
                          return AppLocalizations.of(context)!.commentsContentMinLength;
                        }
                        if (value.length > 1000) {
                          return AppLocalizations.of(context)!.commentsContentMaxLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              _editController.text = widget.comment.content;
                            });
                          },
                          child: Text(AppLocalizations.of(context)!.commentsCancel),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _saveEdit,
                          child: Text(AppLocalizations.of(context)!.commentsSave),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Modo visualización
              Text(
                widget.comment.content,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getAuthorColor() {
    final role = widget.comment.author?.role;
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.tutor:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return AppLocalizations.of(context)!.justNow;
    }
  }

  void _saveEdit() {
    if (_editFormKey.currentState!.validate()) {
      widget.onEdit(_editController.text.trim());
      setState(() {
        _isEditing = false;
      });
    }
  }
}
