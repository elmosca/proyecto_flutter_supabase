import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';
import '../services/auth_service.dart';
import '../router/app_router.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final BuildContext context;

  const AuthLoginRequested({
    required this.email,
    required this.password,
    required this.context,
  });

  @override
  List<Object> get props => [email, password, context];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged({this.user});

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
    
    // Escuchar cambios en el estado de autenticación de Supabase
    _authService.authStateChanges.listen((supabase.AuthState supabaseAuthState) {
      if (supabaseAuthState.event == supabase.AuthChangeEvent.signedOut) {
        add(const AuthUserChanged(user: null));
      } else if (supabaseAuthState.event == supabase.AuthChangeEvent.signedIn) {
        // Obtener el perfil del usuario
        _authService.getCurrentUserProfile().then((user) {
          add(AuthUserChanged(user: user));
        });
      }
    });
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
      
      if (response['success'] == true && response['user'] != null) {
        // Crear el usuario directamente desde la respuesta de login
        final userProfile = _authService.createUserFromLoginResponse(response);
        if (userProfile != null) {
          emit(AuthAuthenticated(userProfile));
          // Navegar al dashboard correcto usando el router
          if (event.context.mounted) {
            AppRouter.goToDashboard(event.context, userProfile);
          }
        } else {
          emit(const AuthFailure('No se pudo crear el perfil del usuario'));
        }
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
      // Como no usamos Supabase Auth, siempre emitimos no autenticado
      // El usuario tendrá que hacer login manualmente
      emit(AuthUnauthenticated());
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
