import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../screens/auth/login_screen_bloc.dart';
import '../screens/dashboard/student_dashboard_screen.dart';
import '../screens/dashboard/tutor_dashboard.dart';
import '../screens/dashboard/admin_dashboard.dart';
import '../screens/admin/users_management_screen.dart';
import '../screens/admin/tutor_selector_for_approval_screen.dart';
import '../screens/admin/settings_screen.dart';
import '../models/user.dart';
import '../screens/lists/tasks_list.dart';
import '../screens/lists/student_projects_list.dart';
import '../screens/lists/my_anteprojects_list.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/anteprojects/anteprojects_review_screen.dart';
import '../widgets/navigation/persistent_scaffold.dart';
import '../screens/kanban/kanban_board.dart';
import '../screens/approval/approval_screen.dart';
import '../blocs/approval_bloc.dart';
import '../screens/student/student_list_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/help/help_screen.dart';
import '../screens/forms/task_form.dart';
import '../blocs/tasks_bloc.dart';
import '../l10n/app_localizations.dart';
import '../screens/messages/tutor_messages_selector_screen.dart';
import '../screens/messages/message_project_selector_screen.dart';
import '../screens/anteprojects/anteproject_detail_screen.dart';
import '../screens/details/task_detail_screen.dart';
import '../services/anteprojects_service.dart';
import '../services/projects_service.dart';
import '../services/tasks_service.dart';
import '../models/anteproject.dart';
import '../models/project.dart';
import '../models/task.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Redirigir la ruta raíz al login
      if (state.uri.path == '/') {
        return '/login';
      }

      // Excluir /reset-password del redirect - necesita acceso sin autenticación
      if (state.uri.path == '/reset-password') {
        return null; // No redirigir - permitir acceso a reset password
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
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          // Extraer type de query parameters (puede venir de la URL o del hash fragment)
          final type = state.uri.queryParameters['type']; // 'setup' o 'reset'

          // Extraer parámetros de error si existen
          final error = state.uri.queryParameters['error'];
          final errorCode = state.uri.queryParameters['error_code'];
          final errorDescription =
              state.uri.queryParameters['error_description'];

          // Extraer code si existe (puede venir como query parameter)
          final code = state.uri.queryParameters['code'];

          return ResetPasswordScreen(
            type: type,
            code: code,
            error: error,
            errorCode: errorCode,
            errorDescription: errorDescription,
          );
        },
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
            debugPrint('❌ Router: Usuario nulo en /dashboard/admin');
            return const LoginScreenBloc();
          }
          debugPrint(
            '✅ Router: Navegando a AdminDashboard para usuario: ${user.fullName}',
          );
          return AdminDashboard(user: user);
        },
      ),
      // Rutas adicionales para el menú lateral
      GoRoute(
        path: '/anteprojects',
        name: 'anteprojects',
        builder: (context, state) {
          // Intentar obtener el usuario del extra primero, si no, del AuthBloc
          User? user = state.extra as User?;
          if (user == null) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
user = authState.user;
            }
          }

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
            // Para tutores y admin - usar AnteprojectsReviewScreen sin Scaffold
            body = const AnteprojectsReviewScreen();
          }

          return PersistentScaffold(
            title: 'Anteproyectos',
            titleKey: 'anteprojects',
            user: user,
            body: body,
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            name: 'anteproject-detail',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                debugPrint('❌ Router: ID de anteproyecto inválido');
                return const Scaffold(
                  body: Center(child: Text('ID de anteproyecto inválido')),
                );
              }

              // Obtener usuario
              User? user = state.extra as User?;
              if (user == null) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  user = authState.user;
                }
              }

              if (user == null) {
                return const LoginScreenBloc();
              }

              return FutureBuilder<Anteproject?>(
                future: AnteprojectsService().getAnteproject(id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return PersistentScaffold(
                      title: 'Anteproyecto',
                      titleKey: 'anteprojects',
                      user: user!,
                      body: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return PersistentScaffold(
                      title: 'Anteproyecto',
                      titleKey: 'anteprojects',
                      user: user!,
                      body: Center(
                        child: Text('Error al cargar anteproyecto: ${snapshot.error}'),
                      ),
                    );
                  }

                  final anteproject = snapshot.data!;
                  
                  // Intentar cargar el proyecto asociado si existe
                  return FutureBuilder<Project?>(
                    future: anteproject.projectId != null
                        ? ProjectsService().getProject(anteproject.projectId!)
                        : Future.value(null),
                    builder: (context, projectSnapshot) {
                      final project = projectSnapshot.data;
                      return AnteprojectDetailScreen(
                        anteproject: anteproject,
                        project: project,
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
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
          return _TasksScreenWrapper(user: user);
        },
        routes: [
          GoRoute(
            path: ':id',
            name: 'task-detail',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                debugPrint('❌ Router: ID de tarea inválido');
                return const Scaffold(
                  body: Center(child: Text('ID de tarea inválido')),
                );
              }

              // Obtener usuario
              User? user = state.extra as User?;
              if (user == null) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  user = authState.user;
                }
              }

              if (user == null) {
                return const LoginScreenBloc();
              }

              return FutureBuilder<Task?>(
                future: TasksService().getTask(id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return PersistentScaffold(
                      title: 'Tarea',
                      titleKey: 'tasks',
                      user: user!,
                      body: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return PersistentScaffold(
                      title: 'Tarea',
                      titleKey: 'tasks',
                      user: user!,
                      body: Center(
                        child: Text('Error al cargar tarea: ${snapshot.error}'),
                      ),
                    );
                  }

                  final task = snapshot.data!;
                  return TaskDetailScreen(task: task);
                },
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          if (authState is! AuthAuthenticated) {
            return const LoginScreenBloc();
          }
          final user = authState.user;
          debugPrint('✅ Router: Navegando a NotificationsScreen');

          return NotificationsScreen(user: user);
        },
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            final authState = context.read<AuthBloc>().state;
            if (authState is! AuthAuthenticated) {
              return const LoginScreenBloc();
            }
            final authenticatedUser = authState.user;
            debugPrint(
              '✅ Router: Navegando a HelpScreen para usuario: ${authenticatedUser.fullName}',
            );
            return HelpScreen(user: authenticatedUser);
          }
          debugPrint(
            '✅ Router: Navegando a HelpScreen para usuario: ${user.fullName}',
          );
          return HelpScreen(user: user);
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
        routes: [
          GoRoute(
            path: ':id',
            name: 'project-detail',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                debugPrint('❌ Router: ID de proyecto inválido');
                return const Scaffold(
                  body: Center(child: Text('ID de proyecto inválido')),
                );
              }

              // Obtener usuario
              User? user = state.extra as User?;
              if (user == null) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  user = authState.user;
                }
              }

              if (user == null) {
                return const LoginScreenBloc();
              }

              return FutureBuilder<Project?>(
                future: ProjectsService().getProject(id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return PersistentScaffold(
                      title: 'Proyecto',
                      titleKey: 'projects',
                      user: user!,
                      body: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return PersistentScaffold(
                      title: 'Proyecto',
                      titleKey: 'projects',
                      user: user!,
                      body: Center(
                        child: Text('Error al cargar proyecto: ${snapshot.error}'),
                      ),
                    );
                  }

                  final project = snapshot.data!;
                  
                  // Cargar el anteproyecto asociado si existe
                  return FutureBuilder<Anteproject?>(
                    future: project.anteprojectId != null
                        ? AnteprojectsService().getAnteproject(project.anteprojectId!)
                        : Future.value(null),
                    builder: (context, anteprojectSnapshot) {
                      final anteproject = anteprojectSnapshot.data;
                      // Si no hay anteproyecto, crear uno temporal con datos del proyecto
                      final finalAnteproject = anteproject ?? Anteproject(
                        id: 0,
                        title: project.title,
                        projectType: ProjectType.execution,
                        description: project.description,
                        academicYear: project.createdAt.year.toString() + 
                                     '-' + 
                                     (project.createdAt.year + 1).toString(),
                        expectedResults: {},
                        timeline: {},
                        status: AnteprojectStatus.approved,
                        tutorId: project.tutorId,
                        createdAt: project.createdAt,
                        updatedAt: project.updatedAt,
                      );
                      return AnteprojectDetailScreen(
                        anteproject: finalAnteproject,
                        project: project,
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
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
          return _KanbanScreenWrapper(user: user);
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
        path: '/student/messages',
        name: 'student-messages',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              final authUser = authState.user;
              if (authUser.role != UserRole.student) {
                return const LoginScreenBloc();
              }
              final l10n = AppLocalizations.of(context)!;
              return PersistentScaffold(
                title: l10n.studentMessages,
                titleKey: 'studentMessages',
                user: authUser,
                body: const MessageProjectSelectorScreen(),
              );
            }
            return const LoginScreenBloc();
          }
          if (user.role != UserRole.student) {
            return const LoginScreenBloc();
          }
          debugPrint(
            '✅ Router: Navegando a Mensajes para estudiante: ${user.fullName}',
          );
          final l10n = AppLocalizations.of(context)!;
          return PersistentScaffold(
            title: l10n.studentMessages,
            titleKey: 'studentMessages',
            user: user,
            body: const MessageProjectSelectorScreen(),
          );
        },
      ),
      GoRoute(
        path: '/tutor/messages',
        name: 'tutor-messages',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              final authUser = authState.user;
              if (authUser.role != UserRole.tutor) {
                return const LoginScreenBloc();
              }
              final l10n = AppLocalizations.of(context)!;
              return PersistentScaffold(
                title: l10n.tutorMessages,
                titleKey: 'tutorMessages',
                user: authUser,
                body: const TutorMessagesSelectorScreen(useOwnScaffold: false),
              );
            }
            return const LoginScreenBloc();
          }
          if (user.role != UserRole.tutor) {
            return const LoginScreenBloc();
          }
          debugPrint(
            '✅ Router: Navegando a Mensajes para tutor: ${user.fullName}',
          );
          final l10n = AppLocalizations.of(context)!;
          return PersistentScaffold(
            title: l10n.tutorMessages,
            titleKey: 'tutorMessages',
            user: user,
            body: const TutorMessagesSelectorScreen(useOwnScaffold: false),
          );
        },
      ),
      GoRoute(
        path: '/admin/approval-workflow',
        name: 'admin-approval-workflow',
        builder: (context, state) {
          final user = state.extra as User?;
          if (user == null) {
            debugPrint('❌ Router: Usuario nulo en /admin/approval-workflow');
            return const LoginScreenBloc();
          }
          if (user.role != UserRole.admin) {
            return PersistentScaffold(
              title: 'Acceso denegado',
              titleKey: 'dashboard',
              user: user,
              body: const Center(child: Text('Se requiere rol administrador')),
            );
          }
          debugPrint(
            '✅ Router: Navegando a Seleccionar Tutor para Flujo de Aprobación',
          );
          return TutorSelectorForApprovalScreen(adminUser: user);
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
          return BlocProvider<ApprovalBloc>(
            create: (_) => ApprovalBloc()..add(const LoadPendingApprovals()),
            child: _ApprovalScreenWithScaffold(user: user),
          );
        },
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        builder: (context, state) {
          debugPrint('✅ Router: Navegando a Gestión de Usuarios');
          final authState = context.read<AuthBloc>().state;
          if (authState is! AuthAuthenticated) {
            return const LoginScreenBloc();
          }
          final user = authState.user;
          if (user.role != UserRole.admin) {
            // No autorizado: volver a su dashboard
            return PersistentScaffold(
              title: 'Acceso denegado',
              titleKey: 'dashboard',
              user: user,
              body: const Center(child: Text('Se requiere rol administrador')),
            );
          }
          return UsersManagementScreen(user: user);
        },
      ),
      GoRoute(
        path: '/admin/settings',
        name: 'admin-settings',
        builder: (context, state) {
          debugPrint('✅ Router: Navegando a Configuración del Sistema');
          final authState = context.read<AuthBloc>().state;
          if (authState is! AuthAuthenticated) {
            return const LoginScreenBloc();
          }
          final user = authState.user;
          if (user.role != UserRole.admin) {
            return PersistentScaffold(
              title: 'Acceso denegado',
              titleKey: 'dashboard',
              user: user,
              body: const Center(child: Text('Se requiere rol administrador')),
            );
          }
          return SettingsScreen(user: user);
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

  // Método helper para navegar al login
  static void goToLogin(BuildContext context) {
    try {
      context.go('/login');
    } catch (e) {
      // Si hay error, usar Navigator como fallback
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreenBloc()),
        (route) => false,
      );
    }
  }
}

/// Widget wrapper para ApprovalScreen con PersistentScaffold y acceso al ApprovalBloc
class _ApprovalScreenWithScaffold extends StatelessWidget {
  final User user;

  const _ApprovalScreenWithScaffold({required this.user});

  @override
  Widget build(BuildContext context) {
    return PersistentScaffold(
      title: 'Flujo de Aprobación',
      titleKey: 'approvalWorkflow',
      user: user,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<ApprovalBloc>().add(const RefreshApprovals());
          },
          tooltip: 'Actualizar',
        ),
      ],
      body: const ApprovalScreen(
        useOwnScaffold: false, // Usa PersistentScaffold
      ),
    );
  }
}

/// Widget wrapper para el Kanban que proporciona acciones y FloatingActionButton
/// cuando se usa dentro de PersistentScaffold
class _KanbanScreenWrapper extends StatefulWidget {
  final User user;

  const _KanbanScreenWrapper({required this.user});

  @override
  State<_KanbanScreenWrapper> createState() => _KanbanScreenWrapperState();
}

class _KanbanScreenWrapperState extends State<_KanbanScreenWrapper> {
  Future<void> _createTask() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: const TaskForm(projectId: null),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PersistentScaffold(
      title: 'Kanban',
      titleKey: 'kanban',
      user: widget.user,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<TasksBloc>().add(
              const TasksLoadRequested(projectId: null),
            );
          },
          tooltip: l10n.tasksListRefresh,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        child: const Icon(Icons.add),
      ),
      body: const KanbanBoard(projectId: null, isEmbedded: true),
    );
  }
}

/// Widget wrapper para la lista de Tareas que proporciona acciones y FloatingActionButton
/// cuando se usa dentro de PersistentScaffold
class _TasksScreenWrapper extends StatefulWidget {
  final User user;

  const _TasksScreenWrapper({required this.user});

  @override
  State<_TasksScreenWrapper> createState() => _TasksScreenWrapperState();
}

class _TasksScreenWrapperState extends State<_TasksScreenWrapper> {
  Future<void> _createTask() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: const TaskForm(projectId: null),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PersistentScaffold(
      title: 'Tareas',
      titleKey: 'tasks',
      user: widget.user,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<TasksBloc>().add(
              const TasksLoadRequested(projectId: null),
            );
          },
          tooltip: l10n.tasksListRefresh,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        child: const Icon(Icons.add),
      ),
      body: const TasksList(projectId: null, isEmbedded: true),
    );
  }
}
