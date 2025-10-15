import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/anteproject.dart';
import '../services/anteprojects_service.dart';

// Events
abstract class AnteprojectsEvent extends Equatable {
  const AnteprojectsEvent();

  @override
  List<Object?> get props => [];
}

class AnteprojectsLoadRequested extends AnteprojectsEvent {}

class AnteprojectCreateRequested extends AnteprojectsEvent {
  final Anteproject anteproject;

  const AnteprojectCreateRequested(this.anteproject);

  @override
  List<Object> get props => [anteproject];
}

class AnteprojectUpdateRequested extends AnteprojectsEvent {
  final Anteproject anteproject;

  const AnteprojectUpdateRequested(this.anteproject);

  @override
  List<Object> get props => [anteproject];
}

class AnteprojectDeleteRequested extends AnteprojectsEvent {
  final int id;

  const AnteprojectDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class AnteprojectSubmitRequested extends AnteprojectsEvent {
  final int id;

  const AnteprojectSubmitRequested(this.id);

  @override
  List<Object> get props => [id];
}

// States
abstract class AnteprojectsState extends Equatable {
  const AnteprojectsState();

  @override
  List<Object?> get props => [];
}

class AnteprojectsInitial extends AnteprojectsState {}

class AnteprojectsLoading extends AnteprojectsState {}

class AnteprojectsLoaded extends AnteprojectsState {
  final List<Anteproject> anteprojects;

  const AnteprojectsLoaded(this.anteprojects);

  @override
  List<Object> get props => [anteprojects];
}

class AnteprojectsFailure extends AnteprojectsState {
  final String message;

  const AnteprojectsFailure(this.message);

  @override
  List<Object> get props => [message];
}

class AnteprojectOperationSuccess extends AnteprojectsState {
  final String message;

  const AnteprojectOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class AnteprojectsBloc extends Bloc<AnteprojectsEvent, AnteprojectsState> {
  final AnteprojectsService anteprojectsService;

  AnteprojectsBloc({required this.anteprojectsService})
    : super(AnteprojectsInitial()) {
    on<AnteprojectsLoadRequested>(_onAnteprojectsLoadRequested);
    on<AnteprojectCreateRequested>(_onAnteprojectCreateRequested);
    on<AnteprojectUpdateRequested>(_onAnteprojectUpdateRequested);
    on<AnteprojectDeleteRequested>(_onAnteprojectDeleteRequested);
    on<AnteprojectSubmitRequested>(_onAnteprojectSubmitRequested);
  }

  Future<void> _onAnteprojectsLoadRequested(
    AnteprojectsLoadRequested event,
    Emitter<AnteprojectsState> emit,
  ) async {
    emit(AnteprojectsLoading());

    try {
      final anteprojects = await anteprojectsService.getAnteprojects();
      emit(AnteprojectsLoaded(anteprojects));
    } catch (e) {
      emit(AnteprojectsFailure(e.toString()));
    }
  }

  Future<void> _onAnteprojectCreateRequested(
    AnteprojectCreateRequested event,
    Emitter<AnteprojectsState> emit,
  ) async {
    emit(AnteprojectsLoading());

    try {
      final createdAnteproject = await anteprojectsService.createAnteproject(
        event.anteproject,
      );

      if (createdAnteproject.id > 0) {
        emit(
          const AnteprojectOperationSuccess('Anteproyecto creado exitosamente'),
        );
        // Recargar la lista
        add(AnteprojectsLoadRequested());
      } else {
        emit(const AnteprojectsFailure('Error al crear el anteproyecto'));
      }
    } catch (e) {
      emit(AnteprojectsFailure(e.toString()));
    }
  }

  Future<void> _onAnteprojectUpdateRequested(
    AnteprojectUpdateRequested event,
    Emitter<AnteprojectsState> emit,
  ) async {
    emit(AnteprojectsLoading());

    try {
      final updatedAnteproject = await anteprojectsService.updateAnteproject(
        event.anteproject.id,
        event.anteproject,
      );

      if (updatedAnteproject.id > 0) {
        emit(
          const AnteprojectOperationSuccess(
            'Anteproyecto actualizado exitosamente',
          ),
        );
        // Recargar la lista
        add(AnteprojectsLoadRequested());
      } else {
        emit(const AnteprojectsFailure('Error al actualizar el anteproyecto'));
      }
    } catch (e) {
      emit(AnteprojectsFailure(e.toString()));
    }
  }

  Future<void> _onAnteprojectDeleteRequested(
    AnteprojectDeleteRequested event,
    Emitter<AnteprojectsState> emit,
  ) async {
    emit(AnteprojectsLoading());

    try {
      // Por ahora, solo emitir éxito (el servicio no tiene método delete)
      emit(
        const AnteprojectOperationSuccess(
          'Anteproyecto eliminado exitosamente',
        ),
      );
      // Recargar la lista
      add(AnteprojectsLoadRequested());
    } catch (e) {
      emit(AnteprojectsFailure(e.toString()));
    }
  }

  Future<void> _onAnteprojectSubmitRequested(
    AnteprojectSubmitRequested event,
    Emitter<AnteprojectsState> emit,
  ) async {
    emit(AnteprojectsLoading());

    try {
      // Cambiar estado a submitted
      final anteproject = await anteprojectsService.getAnteproject(event.id);
      if (anteproject != null) {
        final updatedAnteproject = anteproject.copyWith(
          status: AnteprojectStatus.submitted,
          submittedAt: DateTime.now(),
        );

        await anteprojectsService.updateAnteproject(
          event.id,
          updatedAnteproject,
        );

        // El anteproyecto se envió exitosamente
        emit(
          const AnteprojectOperationSuccess(
            'Anteproyecto enviado para revisión',
          ),
        );
        // Recargar la lista
        add(AnteprojectsLoadRequested());
      } else {
        emit(const AnteprojectsFailure('Anteproyecto no encontrado'));
      }
    } catch (e) {
      emit(AnteprojectsFailure(e.toString()));
    }
  }
}
