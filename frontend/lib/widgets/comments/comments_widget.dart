import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../blocs/comments_bloc.dart';
import '../../models/comment.dart';
import '../../models/user.dart';
import '../../services/comments_service.dart';
import 'comment_card.dart';
import 'add_comment_form.dart';

class CommentsWidget extends StatefulWidget {
  final int taskId;
  final User currentUser;

  const CommentsWidget({
    super.key,
    required this.taskId,
    required this.currentUser,
  });

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  @override
  void initState() {
    super.initState();
    // Cargar comentarios al inicializar
    context.read<CommentsBloc>().add(CommentsLoadRequested(widget.taskId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider<CommentsBloc>(
      create: (context) => CommentsBloc(
        commentsService: CommentsService(),
        currentUser: widget.currentUser,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.comment, size: 24),
                const SizedBox(width: 8),
                Text(
                  l10n.commentsTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Formulario para añadir comentario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AddCommentForm(
              taskId: widget.taskId,
              currentUser: widget.currentUser,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de comentarios
          Expanded(
            child: BlocBuilder<CommentsBloc, CommentsState>(
              builder: (context, state) {
                if (state is CommentsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (state is CommentsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.commentsError,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CommentsBloc>().add(
                              CommentsLoadRequested(widget.taskId),
                            );
                          },
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is CommentsLoaded) {
                  if (state.comments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.commentsNoComments,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.commentsAddFirst,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.comments.length,
                    itemBuilder: (context, index) {
                      final comment = state.comments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CommentCard(
                          comment: comment,
                          currentUser: state.currentUser,
                          onEdit: (content) {
                            context.read<CommentsBloc>().add(
                              CommentUpdateRequested(
                                commentId: comment.id,
                                content: content,
                              ),
                            );
                          },
                          onDelete: () {
                            _showDeleteConfirmation(context, comment);
                          },
                        ),
                      );
                    },
                  );
                }
                
                // Estados de operaciones (adding, updating, deleting)
                if (state is CommentAdding ||
                    state is CommentUpdating ||
                    state is CommentDeleting) {
                  final currentState = state as dynamic;
                  return Stack(
                    children: [
                      // Mostrar comentarios existentes
                      if (currentState.comments.isNotEmpty)
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: currentState.comments.length,
                          itemBuilder: (context, index) {
                            final comment = currentState.comments[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CommentCard(
                                comment: comment,
                                currentUser: currentState.currentUser,
                                onEdit: (content) {
                                  context.read<CommentsBloc>().add(
                                    CommentUpdateRequested(
                                      commentId: comment.id,
                                      content: content,
                                    ),
                                  );
                                },
                                onDelete: () {
                                  _showDeleteConfirmation(context, comment);
                                },
                              ),
                            );
                          },
                        ),
                      
                      // Overlay de carga
                      Container(
                        color: Colors.black.withValues(alpha: 0.1),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Comment comment) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.commentsDelete),
          content: Text(l10n.commentsDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commentsCancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<CommentsBloc>().add(
                  CommentDeleteRequested(comment.id),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.commentsDelete),
            ),
          ],
        );
      },
    );
  }
}
