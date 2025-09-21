import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../screens/auth/login_screen_bloc.dart';
import '../screens/dashboard/student_dashboard.dart';
import '../screens/dashboard/tutor_dashboard.dart';
import '../screens/dashboard/admin_dashboard.dart';
import '../models/user.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Redirigir la ruta raíz al login
      if (state.uri.path == '/') {
        return '/login';
      }
      
      // Solo redirigir si no estamos en login
      if (state.uri.path != '/login') {
        try {
          final authBloc = context.read<AuthBloc>();
          final authState = authBloc.state;
          
          // Si no estamos autenticados, redirigir a login
          if (authState is! AuthAuthenticated) {
            return '/login';
          }
        } catch (e) {
          // Si hay error leyendo el AuthBloc, ir a login
          return '/login';
        }
      }
      
      return null; // No redirigir
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreenBloc(),
      ),
      GoRoute(
        path: '/dashboard/student',
        name: 'student-dashboard',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            return const LoginScreenBloc();
          }
          return StudentDashboard(user: user);
        },
      ),
      GoRoute(
        path: '/dashboard/tutor',
        name: 'tutor-dashboard',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            return const LoginScreenBloc();
          }
          return TutorDashboard(user: user);
        },
      ),
      GoRoute(
        path: '/dashboard/admin',
        name: 'admin-dashboard',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            return const LoginScreenBloc();
          }
          return AdminDashboard(user: user);
        },
      ),
    ],
  );

  static GoRouter get router => _router;

  static String _getDashboardRoute(UserRole role) {
    switch (role) {
      case UserRole.student:
        return '/dashboard/student';
      case UserRole.tutor:
        return '/dashboard/tutor';
      case UserRole.admin:
        return '/dashboard/admin';
    }
  }

  // Método helper para navegar al dashboard correcto
  static void goToDashboard(BuildContext context, User user) {
    final route = _getDashboardRoute(user.role);
    context.go(route, extra: user);
  }

  // Método helper para logout
  static void logout(BuildContext context) {
    try {
      // Primero hacer logout en el AuthBloc
      context.read<AuthBloc>().add(AuthLogoutRequested());
      
      // Luego navegar a login
      context.go('/login');
    } catch (e) {
      // Si hay error, intentar navegar directamente
      try {
        context.go('/login');
      } catch (e2) {
        // Si todo falla, usar Navigator como fallback
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreenBloc()),
          (route) => false,
        );
      }
    }
  }
}
