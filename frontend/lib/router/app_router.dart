import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../screens/auth/login_screen_bloc.dart';
import '../screens/dashboard/student_dashboard_screen.dart';
import '../screens/dashboard/tutor_dashboard.dart';
import '../models/user.dart';
import '../screens/lists/tasks_list.dart';
import '../screens/lists/student_projects_list.dart';
import '../screens/lists/my_anteprojects_list.dart';
import '../screens/lists/anteprojects_list.dart';
import '../screens/lists/tutor_anteprojects_list.dart';
import '../screens/notifications/notifications_screen.dart';
import '../widgets/navigation/persistent_scaffold.dart';
import '../screens/kanban/kanban_board.dart';
import '../screens/approval/approval_screen.dart';
import '../blocs/approval_bloc.dart';
import '../screens/student/student_list_screen.dart';

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
            debugPrint(
              '❌ Router: Usuario nulo en /dashboard/student, redirigiendo a login',
            );
            return const LoginScreenBloc();
          }
          debugPrint(
            '✅ Router: Navegando a StudentDashboardScreen para usuario: ${user.fullName}',
          );
          return StudentDashboardScreen(user: user);
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
          return TutorDashboard(user: user);
        },
      ),
      // Rutas adicionales para el menú lateral
      GoRoute(
        path: '/anteprojects',
        name: 'anteprojects',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            debugPrint('❌ Router: Usuario nulo en /anteprojects');
            return const LoginScreenBloc();
          }
          debugPrint(
            '✅ Router: Navegando a AnteprojectsList para usuario: ${user.fullName}',
          );

          // Usar pantalla diferente según el rol
          Widget body;
          if (user.role == UserRole.student) {
            body = MyAnteprojectsList(user: user);
          } else {
            // Para tutores y admin
            body = const TutorAnteprojectsList();
          }

          return PersistentScaffold(
            title: 'Anteproyectos',
            titleKey: 'anteprojects',
            user: user,
            body: body,
          );
        },
      ),
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            debugPrint('❌ Router: Usuario nulo en /tasks');
            return const LoginScreenBloc();
          }
          debugPrint(
            '✅ Router: Navegando a TasksList para usuario: ${user.fullName}',
          );
          return PersistentScaffold(
            title: 'Tareas',
            titleKey: 'tasks',
            user: user,
            body: const TasksList(projectId: null),
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) {
          // Para notificaciones, intentamos obtener el usuario del estado anterior
          // Si no está disponible, usamos un usuario vacío temporal
          final user = state.extra as User?;
          debugPrint('✅ Router: Navegando a NotificationsScreen');

          if (user != null) {
            return PersistentScaffold(
              title: 'Notificaciones',
              titleKey: 'notifications',
              user: user,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay notificaciones',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Te notificaremos cuando haya novedades',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          // Fallback si no hay usuario
          return const NotificationsScreen();
        },
      ),
      // Rutas adicionales para estudiantes
      GoRoute(
        path: '/projects',
        name: 'projects',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            debugPrint('❌ Router: Usuario nulo en /projects');
            return const LoginScreenBloc();
          }
          debugPrint(
            '✅ Router: Navegando a Proyectos para usuario: ${user.fullName}',
          );
          return PersistentScaffold(
            title: 'Proyectos Aprobados',
            titleKey: 'projects',
            user: user,
            body: StudentProjectsList(user: user),
          );
        },
      ),
      GoRoute(
        path: '/kanban',
        name: 'kanban',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            debugPrint('❌ Router: Usuario nulo en /kanban');
            return const LoginScreenBloc();
          }
          debugPrint(
            '✅ Router: Navegando a Kanban para usuario: ${user.fullName}',
          );
          return PersistentScaffold(
            title: 'Kanban',
            titleKey: 'kanban',
            user: user,
            body: const KanbanBoard(projectId: null),
          );
        },
      ),
      // Rutas adicionales para tutores y admin
      GoRoute(
        path: '/students',
        name: 'students',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            debugPrint('❌ Router: Usuario nulo en /students');
            return const LoginScreenBloc();
          }
          debugPrint(
            '✅ Router: Navegando a Estudiantes para tutor: ${user.fullName}',
          );
          return PersistentScaffold(
            title: 'Estudiantes',
            titleKey: 'myStudents',
            user: user,
            body: StudentListScreen(tutorId: user.id),
          );
        },
      ),
      GoRoute(
        path: '/approval-workflow',
        name: 'approval-workflow',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            debugPrint('❌ Router: Usuario nulo en /approval-workflow');
            return const LoginScreenBloc();
          }
          debugPrint(
            '✅ Router: Navegando a Flujo de Aprobación para: ${user.fullName}',
          );
          return PersistentScaffold(
            title: 'Flujo de Aprobación',
            titleKey: 'approvalWorkflow',
            user: user,
            body: BlocProvider<ApprovalBloc>(
              create: (_) => ApprovalBloc()..add(const LoadPendingApprovals()),
              child: const ApprovalScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        builder: (context, state) {
          debugPrint('✅ Router: Navegando a Gestión de Usuarios');
          return const Placeholder(
            child: Center(child: Text('Gestionar Usuarios')),
          );
        },
      ),
      GoRoute(
        path: '/admin/settings',
        name: 'admin-settings',
        builder: (context, state) {
          debugPrint('✅ Router: Navegando a Configuración del Sistema');
          return const Placeholder(
            child: Center(child: Text('Configuración del Sistema')),
          );
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
    debugPrint(
      '🚀 Router: Navegando a dashboard para usuario: ${user.fullName}',
    );
    debugPrint('🚀 Router: Ruta seleccionada: $route');
    debugPrint('🚀 Router: Rol del usuario: ${user.role}');
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
