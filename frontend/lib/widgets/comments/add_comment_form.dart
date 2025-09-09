import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../blocs/comments_bloc.dart';
import '../../models/user.dart';
import '../../utils/validators.dart';

class AddCommentForm extends StatefulWidget {
  final int taskId;
  final User currentUser;

  const AddCommentForm({
    super.key,
    required this.taskId,
    required this.currentUser,
  });

  @override
  State<AddCommentForm> createState() => _AddCommentFormState();
}

class _AddCommentFormState extends State<AddCommentForm> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  bool _isInternal = false;
  bool _isExpanded = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botón para expandir/contraer
              if (!_isExpanded)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isExpanded = true;
                      });
                    },
                    icon: const Icon(Icons.add_comment),
                    label: Text(l10n.commentsAddComment),
                  ),
                ),
              
              if (_isExpanded) ...[
                // Campo de contenido
                TextFormField(
                  controller: _contentController,
                  maxLines: 4,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    labelText: l10n.commentsContent,
                    hintText: l10n.commentsWriteComment,
                    border: const OutlineInputBorder(),
                    counterText: '',
                  ),
                  validator: Validators.validateCommentContent,
                ),
                
                const SizedBox(height: 16),
                
                // Checkbox para comentario interno (solo para tutores y admins)
                if (widget.currentUser.role == UserRole.tutor || widget.currentUser.role == UserRole.admin)
                  CheckboxListTile(
                    title: Text(l10n.commentsInternal),
                    subtitle: Text(
                      widget.currentUser.role == UserRole.tutor 
                          ? 'Solo visible para tutores y administradores'
                          : 'Solo visible para administradores',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _isInternal,
                    onChanged: (value) {
                      setState(() {
                        _isInternal = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                
                const SizedBox(height: 16),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _cancel,
                      child: Text(l10n.commentsCancel),
                    ),
                    const SizedBox(width: 8),
                    BlocListener<CommentsBloc, CommentsState>(
                      listener: (context, state) {
                        if (state is CommentAdded) {
                          _contentController.clear();
                          setState(() {
                            _isExpanded = false;
                            _isInternal = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.commentsSuccess),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (state is CommentsError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.commentsErrorAdd),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: ElevatedButton(
                        onPressed: _submitComment,
                        child: Text(l10n.commentsSend),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _cancel() {
    setState(() {
      _isExpanded = false;
      _contentController.clear();
      _isInternal = false;
    });
  }

  void _submitComment() {
    if (_formKey.currentState!.validate()) {
      context.read<CommentsBloc>().add(
        CommentAddRequested(
          taskId: widget.taskId,
          content: _contentController.text.trim(),
          authorId: int.tryParse(widget.currentUser.id) ?? 0,
          isInternal: _isInternal,
        ),
      );
    }
  }
}
