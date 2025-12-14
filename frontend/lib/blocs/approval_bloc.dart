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
  final String? academicYear;

  const LoadPendingApprovals({this.tutorId, this.academicYear});

  @override
  List<Object?> get props => [tutorId, academicYear];
}

class LoadReviewedAnteprojects extends ApprovalEvent {
  final String? academicYear;

  const LoadReviewedAnteprojects({this.academicYear});

  @override
  List<Object?> get props => [academicYear];
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
  final String? selectedAcademicYear;

  const ApprovalLoaded({
    required this.pendingApprovals,
    required this.reviewedAnteprojects,
    this.selectedTutorId,
    this.selectedAcademicYear,
  });

  @override
  List<Object?> get props => [
    pendingApprovals,
    reviewedAnteprojects,
    selectedTutorId,
    selectedAcademicYear,
  ];

  ApprovalLoaded copyWith({
    List<Map<String, dynamic>>? pendingApprovals,
    List<Map<String, dynamic>>? reviewedAnteprojects,
    int? selectedTutorId,
    String? selectedAcademicYear,
  }) {
    return ApprovalLoaded(
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      reviewedAnteprojects: reviewedAnteprojects ?? this.reviewedAnteprojects,
      selectedTutorId: selectedTutorId ?? this.selectedTutorId,
      selectedAcademicYear: selectedAcademicYear ?? this.selectedAcademicYear,
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
        academicYear: event.academicYear,
      );
      final reviewedAnteprojects = await _approvalService
          .getReviewedAnteprojects(
        tutorId: event.tutorId,
        academicYear: event.academicYear,
      );

      emit(
        ApprovalLoaded(
          pendingApprovals: pendingApprovals,
          reviewedAnteprojects: reviewedAnteprojects,
          selectedTutorId: event.tutorId,
          selectedAcademicYear: event.academicYear,
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
            .getReviewedAnteprojects(
          tutorId: currentState.selectedTutorId,
          academicYear: event.academicYear,
        );

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
            selectedAcademicYear: event.academicYear,
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
      String? academicYear;
      if (state is ApprovalLoaded) {
        final currentState = state as ApprovalLoaded;
        tutorId = currentState.selectedTutorId;
        academicYear = currentState.selectedAcademicYear;
      }

      final pendingApprovals = await _approvalService.getPendingApprovals(
        tutorId: tutorId,
        academicYear: academicYear,
      );
      final reviewedAnteprojects = await _approvalService
          .getReviewedAnteprojects(
        tutorId: tutorId,
        academicYear: academicYear,
      );

      emit(
        ApprovalLoaded(
          pendingApprovals: pendingApprovals,
          reviewedAnteprojects: reviewedAnteprojects,
          selectedTutorId: tutorId,
          selectedAcademicYear: academicYear,
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
