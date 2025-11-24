import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/approval_service.dart';
import '../utils/app_exception.dart';
import '../utils/error_translator.dart';

// Events
abstract class ApprovalEvent extends Equatable {
  const ApprovalEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingApprovals extends ApprovalEvent {
  final int? tutorId;

  const LoadPendingApprovals({this.tutorId});

  @override
  List<Object?> get props => [tutorId];
}

class LoadReviewedAnteprojects extends ApprovalEvent {
  const LoadReviewedAnteprojects();
}

class ApproveAnteproject extends ApprovalEvent {
  final int anteprojectId;
  final String? comments;

  const ApproveAnteproject({required this.anteprojectId, this.comments});

  @override
  List<Object?> get props => [anteprojectId, comments];
}

class RejectAnteproject extends ApprovalEvent {
  final int anteprojectId;
  final String comments;

  const RejectAnteproject({
    required this.anteprojectId,
    required this.comments,
  });

  @override
  List<Object?> get props => [anteprojectId, comments];
}

class RequestChanges extends ApprovalEvent {
  final int anteprojectId;
  final String comments;

  const RequestChanges({required this.anteprojectId, required this.comments});

  @override
  List<Object?> get props => [anteprojectId, comments];
}

class RefreshApprovals extends ApprovalEvent {
  const RefreshApprovals();
}

// States
abstract class ApprovalState extends Equatable {
  const ApprovalState();

  @override
  List<Object?> get props => [];
}

class ApprovalInitial extends ApprovalState {
  const ApprovalInitial();
}

class ApprovalLoading extends ApprovalState {
  const ApprovalLoading();
}

class ApprovalLoaded extends ApprovalState {
  final List<Map<String, dynamic>> pendingApprovals;
  final List<Map<String, dynamic>> reviewedAnteprojects;
  final int? selectedTutorId;

  const ApprovalLoaded({
    required this.pendingApprovals,
    required this.reviewedAnteprojects,
    this.selectedTutorId,
  });

  @override
  List<Object?> get props => [
    pendingApprovals,
    reviewedAnteprojects,
    selectedTutorId,
  ];

  ApprovalLoaded copyWith({
    List<Map<String, dynamic>>? pendingApprovals,
    List<Map<String, dynamic>>? reviewedAnteprojects,
    int? selectedTutorId,
  }) {
    return ApprovalLoaded(
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      reviewedAnteprojects: reviewedAnteprojects ?? this.reviewedAnteprojects,
      selectedTutorId: selectedTutorId ?? this.selectedTutorId,
    );
  }
}

class ApprovalProcessing extends ApprovalState {
  final int anteprojectId;
  final ApprovalAction action;

  const ApprovalProcessing({required this.anteprojectId, required this.action});

  @override
  List<Object?> get props => [anteprojectId, action];
}

class ApprovalSuccess extends ApprovalState {
  final ApprovalResult result;
  final ApprovalAction action;

  const ApprovalSuccess({required this.result, required this.action});

  @override
  List<Object?> get props => [result, action];
}

class ApprovalError extends ApprovalState {
  final String message;
  final ApprovalAction? action;

  const ApprovalError({required this.message, this.action});

  @override
  List<Object?> get props => [message, action];
}

// Enum para las acciones de aprobación
enum ApprovalAction { approve, reject, requestChanges }

// BLoC
class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  final ApprovalService _approvalService;

  ApprovalBloc({ApprovalService? approvalService})
    : _approvalService = approvalService ?? ApprovalService(),
      super(const ApprovalInitial()) {
    on<LoadPendingApprovals>(_onLoadPendingApprovals);
    on<LoadReviewedAnteprojects>(_onLoadReviewedAnteprojects);
    on<ApproveAnteproject>(_onApproveAnteproject);
    on<RejectAnteproject>(_onRejectAnteproject);
    on<RequestChanges>(_onRequestChanges);
    on<RefreshApprovals>(_onRefreshApprovals);
  }

  Future<void> _onLoadPendingApprovals(
    LoadPendingApprovals event,
    Emitter<ApprovalState> emit,
  ) async {
    try {
      emit(const ApprovalLoading());

      final pendingApprovals = await _approvalService.getPendingApprovals(
        tutorId: event.tutorId,
      );
      final reviewedAnteprojects = await _approvalService
          .getReviewedAnteprojects(tutorId: event.tutorId);

      emit(
        ApprovalLoaded(
          pendingApprovals: pendingApprovals,
          reviewedAnteprojects: reviewedAnteprojects,
          selectedTutorId: event.tutorId,
        ),
      );
    } catch (e) {
      // Manejar errores usando el nuevo sistema
      if (e is AppException) {
        final fallbackMessage = ErrorTranslator.getFallbackMessage(e);
        emit(ApprovalError(message: fallbackMessage));
      } else {
        emit(ApprovalError(message: 'Error inesperado: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadReviewedAnteprojects(
    LoadReviewedAnteprojects event,
    Emitter<ApprovalState> emit,
  ) async {
    try {
      if (state is ApprovalLoaded) {
        final currentState = state as ApprovalLoaded;
        final reviewedAnteprojects = await _approvalService
            .getReviewedAnteprojects(tutorId: currentState.selectedTutorId);

        emit(currentState.copyWith(reviewedAnteprojects: reviewedAnteprojects));
      } else {
        emit(const ApprovalLoading());

        final pendingApprovals = await _approvalService.getPendingApprovals();
        final reviewedAnteprojects = await _approvalService
            .getReviewedAnteprojects();

        emit(
          ApprovalLoaded(
            pendingApprovals: pendingApprovals,
            reviewedAnteprojects: reviewedAnteprojects,
            selectedTutorId: null,
          ),
        );
      }
    } catch (e) {
      // Manejar errores usando el nuevo sistema
      if (e is AppException) {
        final fallbackMessage = ErrorTranslator.getFallbackMessage(e);
        emit(ApprovalError(message: fallbackMessage));
      } else {
        emit(ApprovalError(message: 'Error inesperado: ${e.toString()}'));
      }
    }
  }

  Future<void> _onApproveAnteproject(
    ApproveAnteproject event,
    Emitter<ApprovalState> emit,
  ) async {
    try {
      emit(
        ApprovalProcessing(
          anteprojectId: event.anteprojectId,
          action: ApprovalAction.approve,
        ),
      );

      final result = await _approvalService.approveAnteproject(
        event.anteprojectId,
        comments: event.comments,
      );

      emit(ApprovalSuccess(result: result, action: ApprovalAction.approve));

      // Recargar la lista de anteproyectos
      add(const RefreshApprovals());
    } catch (e) {
      emit(
        ApprovalError(message: e.toString(), action: ApprovalAction.approve),
      );
    }
  }

  Future<void> _onRejectAnteproject(
    RejectAnteproject event,
    Emitter<ApprovalState> emit,
  ) async {
    try {
      emit(
        ApprovalProcessing(
          anteprojectId: event.anteprojectId,
          action: ApprovalAction.reject,
        ),
      );

      final result = await _approvalService.rejectAnteproject(
        event.anteprojectId,
        event.comments,
      );

      emit(ApprovalSuccess(result: result, action: ApprovalAction.reject));

      // Recargar la lista de anteproyectos
      add(const RefreshApprovals());
    } catch (e) {
      emit(ApprovalError(message: e.toString(), action: ApprovalAction.reject));
    }
  }

  Future<void> _onRequestChanges(
    RequestChanges event,
    Emitter<ApprovalState> emit,
  ) async {
    try {
      emit(
        ApprovalProcessing(
          anteprojectId: event.anteprojectId,
          action: ApprovalAction.requestChanges,
        ),
      );

      final result = await _approvalService.requestChanges(
        event.anteprojectId,
        event.comments,
      );

      emit(
        ApprovalSuccess(result: result, action: ApprovalAction.requestChanges),
      );

      // Recargar la lista de anteproyectos
      add(const RefreshApprovals());
    } catch (e) {
      emit(
        ApprovalError(
          message: e.toString(),
          action: ApprovalAction.requestChanges,
        ),
      );
    }
  }

  Future<void> _onRefreshApprovals(
    RefreshApprovals event,
    Emitter<ApprovalState> emit,
  ) async {
    try {
      int? tutorId;
      if (state is ApprovalLoaded) {
        tutorId = (state as ApprovalLoaded).selectedTutorId;
      }

      final pendingApprovals = await _approvalService.getPendingApprovals(
        tutorId: tutorId,
      );
      final reviewedAnteprojects = await _approvalService
          .getReviewedAnteprojects(tutorId: tutorId);

      emit(
        ApprovalLoaded(
          pendingApprovals: pendingApprovals,
          reviewedAnteprojects: reviewedAnteprojects,
          selectedTutorId: tutorId,
        ),
      );
    } catch (e) {
      // Manejar errores usando el nuevo sistema
      if (e is AppException) {
        final fallbackMessage = ErrorTranslator.getFallbackMessage(e);
        emit(ApprovalError(message: fallbackMessage));
      } else {
        emit(ApprovalError(message: 'Error inesperado: ${e.toString()}'));
      }
    }
  }
}
