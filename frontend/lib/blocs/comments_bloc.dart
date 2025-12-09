import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../services/comments_service.dart';
import '../utils/app_exception.dart';
import '../utils/error_translator.dart';

// Events
abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

class CommentsLoadRequested extends CommentsEvent {
  final int taskId;

  const CommentsLoadRequested(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class CommentAddRequested extends CommentsEvent {
  final int taskId;
  final String content;
  final int authorId;
  final bool isInternal;

  const CommentAddRequested({
    required this.taskId,
    required this.content,
    required this.authorId,
    this.isInternal = false,
  });

  @override
  List<Object> get props => [taskId, content, authorId, isInternal];
}

class CommentUpdateRequested extends CommentsEvent {
  final int commentId;
  final String content;

  const CommentUpdateRequested({
    required this.commentId,
    required this.content,
  });

  @override
  List<Object> get props => [commentId, content];
}

class CommentDeleteRequested extends CommentsEvent {
  final int commentId;

  const CommentDeleteRequested(this.commentId);

  @override
  List<Object> get props => [commentId];
}

class CommentsRefreshRequested extends CommentsEvent {
  const CommentsRefreshRequested();
}

// States
abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

/// Estado base para todos los estados que contienen comentarios y usuario actual
abstract class CommentsStateWithData extends CommentsState {
  final List<Comment> comments;
  final User currentUser;

  const CommentsStateWithData({
    required this.comments,
    required this.currentUser,
  });

  @override
  List<Object> get props => [comments, currentUser];
}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsStateWithData {
  const CommentsLoaded({
    required super.comments,
    required super.currentUser,
  });
}

class CommentsError extends CommentsState {
  final String message;

  const CommentsError(this.message);

  @override
  List<Object> get props => [message];
}

class CommentAdding extends CommentsStateWithData {
  const CommentAdding({
    required super.comments,
    required super.currentUser,
  });
}

class CommentAdded extends CommentsStateWithData {
  const CommentAdded({
    required super.comments,
    required super.currentUser,
  });
}

class CommentUpdating extends CommentsStateWithData {
  const CommentUpdating({
    required super.comments,
    required super.currentUser,
  });
}

class CommentUpdated extends CommentsStateWithData {
  const CommentUpdated({
    required super.comments,
    required super.currentUser,
  });
}

class CommentDeleting extends CommentsStateWithData {
  const CommentDeleting({
    required super.comments,
    required super.currentUser,
  });
}

class CommentDeleted extends CommentsStateWithData {
  const CommentDeleted({
    required super.comments,
    required super.currentUser,
  });
}

// BLoC
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final CommentsService _commentsService;
  final User _currentUser;

  CommentsBloc({
    required CommentsService commentsService,
    required User currentUser,
  }) : _commentsService = commentsService,
       _currentUser = currentUser,
       super(CommentsInitial()) {
    on<CommentsLoadRequested>(_onCommentsLoadRequested);
    on<CommentAddRequested>(_onCommentAddRequested);
    on<CommentUpdateRequested>(_onCommentUpdateRequested);
    on<CommentDeleteRequested>(_onCommentDeleteRequested);
    on<CommentsRefreshRequested>(_onCommentsRefreshRequested);
  }

  Future<void> _onCommentsLoadRequested(
    CommentsLoadRequested event,
    Emitter<CommentsState> emit,
  ) async {
    emit(CommentsLoading());

    try {
      final comments = await _commentsService.getCommentsByTaskId(event.taskId);
      emit(CommentsLoaded(comments: comments, currentUser: _currentUser));
    } catch (e) {
      // Manejar errores usando el nuevo sistema
      if (e is AppException) {
        final fallbackMessage = ErrorTranslator.getFallbackMessage(e);
        emit(CommentsError(fallbackMessage));
      } else {
        emit(CommentsError('Error inesperado: ${e.toString()}'));
      }
    }
  }

  Future<void> _onCommentAddRequested(
    CommentAddRequested event,
    Emitter<CommentsState> emit,
  ) async {
    final currentState = _getStateWithComments();
    if (currentState != null) {
      emit(
        CommentAdding(
          comments: currentState.comments,
          currentUser: currentState.currentUser,
        ),
      );

      try {
        final newComment = await _commentsService.addComment(
          taskId: event.taskId,
          content: event.content,
          authorId: event.authorId,
          isInternal: event.isInternal,
        );

        final updatedComments = List<Comment>.from(currentState.comments)
          ..add(newComment);

        emit(
          CommentAdded(
            comments: updatedComments,
            currentUser: currentState.currentUser,
          ),
        );
      } catch (e) {
        emit(CommentsError(e.toString()));
      }
    }
  }

  Future<void> _onCommentUpdateRequested(
    CommentUpdateRequested event,
    Emitter<CommentsState> emit,
  ) async {
    final currentState = _getStateWithComments();
    if (currentState != null) {
      emit(
        CommentUpdating(
          comments: currentState.comments,
          currentUser: currentState.currentUser,
        ),
      );

      try {
        final updatedComment = await _commentsService.updateComment(
          commentId: event.commentId,
          content: event.content,
        );

        final updatedComments = currentState.comments.map((comment) {
          return comment.id == event.commentId ? updatedComment : comment;
        }).toList();

        emit(
          CommentUpdated(
            comments: updatedComments,
            currentUser: currentState.currentUser,
          ),
        );
      } catch (e) {
        emit(CommentsError(e.toString()));
      }
    }
  }

  Future<void> _onCommentDeleteRequested(
    CommentDeleteRequested event,
    Emitter<CommentsState> emit,
  ) async {
    final currentState = _getStateWithComments();
    if (currentState != null) {
      emit(
        CommentDeleting(
          comments: currentState.comments,
          currentUser: currentState.currentUser,
        ),
      );

      try {
        await _commentsService.deleteComment(event.commentId);

        final updatedComments = currentState.comments
            .where((comment) => comment.id != event.commentId)
            .toList();

        emit(
          CommentDeleted(
            comments: updatedComments,
            currentUser: currentState.currentUser,
          ),
        );
      } catch (e) {
        emit(CommentsError(e.toString()));
      }
    }
  }

  Future<void> _onCommentsRefreshRequested(
    CommentsRefreshRequested event,
    Emitter<CommentsState> emit,
  ) async {
    final currentState = _getStateWithComments();
    if (currentState != null) {
      // Buscar el taskId del primer comentario o usar un valor por defecto
      final taskId = currentState.comments.isNotEmpty
          ? currentState.comments.first.taskId
          : 1;

      add(CommentsLoadRequested(taskId));
    }
  }

  /// Obtiene el estado actual si contiene comentarios, independientemente del tipo de estado
  CommentsStateWithData? _getStateWithComments() {
    if (state is CommentsStateWithData) {
      return state as CommentsStateWithData;
    }
    return null;
  }
}
