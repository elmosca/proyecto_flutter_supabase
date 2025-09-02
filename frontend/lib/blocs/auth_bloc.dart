import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final response = await _authService.signIn(
        email: event.email,
        password: event.password,
      );
      
      if (response.user != null) {
        // Convertir supabase.User a nuestro modelo User
        final user = User(
          id: int.tryParse(response.user!.id) ?? 0,
          email: response.user!.email ?? '',
          fullName: response.user!.userMetadata?['full_name'] ?? '',
          role: response.user!.userMetadata?['role'] ?? 'student',
          nre: response.user!.userMetadata?['nre'],
          phone: response.user!.userMetadata?['phone'],
          biography: response.user!.userMetadata?['biography'],
          status: UserStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthFailure('Credenciales inválidas'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final currentUser = supabase.Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        // Convertir supabase.User a nuestro modelo User
        final user = User(
          id: int.tryParse(currentUser.id) ?? 0,
          email: currentUser.email ?? '',
          fullName: currentUser.userMetadata?['full_name'] ?? '',
          role: currentUser.userMetadata?['role'] ?? 'student',
          nre: currentUser.userMetadata?['nre'],
          phone: currentUser.userMetadata?['phone'],
          biography: currentUser.userMetadata?['biography'],
          status: UserStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
