import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/tasks_bloc.dart';
import 'package:frontend/models/task.dart';
import 'package:frontend/screens/forms/task_form.dart';
import 'package:frontend/screens/lists/tasks_list.dart';
import 'package:frontend/screens/kanban/kanban_board.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/test/mocks/auth_service_mock.dart';
import 'package:frontend/test/mocks/supabase_mock.dart';
import 'package:frontend/test/widget/widget_test_utils.dart';

void main() {
  group('Task Flow Integration Tests', () {
    late MockAuthServiceForTests mockAuthService;
    late MockSupabaseClient mockSupabaseClient;

    setUp(() {
      mockAuthService = AuthServiceMockHelper.createMockAuthService();
      mockSupabaseClient = SupabaseMock.createMockSupabaseClient();
      SupabaseMock.initializeMocks();
    });

    tearDown(() {
      resetMockitoState();
    });

    testWidgets('Complete task creation flow works correctly',
        (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      // Crear un TasksBloc mock
      final tasksBloc = TasksBloc(
        tasksService: MockTasksService(),
        authService: mockAuthService,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<TasksBloc>(
            create: (context) => tasksBloc,
            child: const TaskForm(projectId: 1),
          ),
        ),
      );

      // Verificar que el formulario se renderiza correctamente
      expect(find.byType(TaskForm), findsOneWidget);
      expect(find.text('Formulario de Tarea'), findsOneWidget);

      // Llenar el formulario
      await WidgetTestUtils.enterText(tester, find.byKey(const Key('title_field')), 'Tarea de prueba');
      await WidgetTestUtils.enterText(tester, find.byKey(const Key('description_field')), 'Descripción de la tarea de prueba');

      // Verificar que los campos se llenaron
      expect(find.text('Tarea de prueba'), findsOneWidget);
      expect(find.text('Descripción de la tarea de prueba'), findsOneWidget);

      // Simular envío del formulario
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('submit_button')));
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestra mensaje de éxito
      expect(find.text('Tarea creada exitosamente'), findsOneWidget);
    });

    testWidgets('Task list displays tasks correctly', (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      final tasksBloc = TasksBloc(
        tasksService: MockTasksService(),
        authService: mockAuthService,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<TasksBloc>(
            create: (context) => tasksBloc,
            child: const TasksList(projectId: 1),
          ),
        ),
      );

      // Verificar que la lista se renderiza
      expect(find.byType(TasksList), findsOneWidget);
      expect(find.text('Lista de Tareas'), findsOneWidget);

      // Verificar botón de crear tarea
      expect(find.byKey(const Key('create_task_button')), findsOneWidget);
    });

    testWidgets('Kanban board displays columns correctly', (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      final tasksBloc = TasksBloc(
        tasksService: MockTasksService(),
        authService: mockAuthService,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<TasksBloc>(
            create: (context) => tasksBloc,
            child: const KanbanBoard(projectId: 1),
          ),
        ),
      );

      // Verificar que el tablero Kanban se renderiza
      expect(find.byType(KanbanBoard), findsOneWidget);
      expect(find.text('Tablero Kanban'), findsOneWidget);

      // Verificar que las columnas están presentes
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.text('En Progreso'), findsOneWidget);
      expect(find.text('En Revisión'), findsOneWidget);
      expect(find.text('Completada'), findsOneWidget);
    });

    testWidgets('Navigation between task screens works', (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      final tasksBloc = TasksBloc(
        tasksService: MockTasksService(),
        authService: mockAuthService,
      );

      // Comenzar con TasksList
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<TasksBloc>(
            create: (context) => tasksBloc,
            child: const TasksList(projectId: 1),
          ),
        ),
      );

      expect(find.byType(TasksList), findsOneWidget);

      // Navegar a KanbanBoard
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('kanban_view_button')));
      await WidgetTestUtils.waitForAnimation(tester);

      expect(find.byType(KanbanBoard), findsOneWidget);

      // Navegar de vuelta a TasksList
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('list_view_button')));
      await WidgetTestUtils.waitForAnimation(tester);

      expect(find.byType(TasksList), findsOneWidget);
    });

    testWidgets('Task form validation works correctly', (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      final tasksBloc = TasksBloc(
        tasksService: MockTasksService(),
        authService: mockAuthService,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<TasksBloc>(
            create: (context) => tasksBloc,
            child: const TaskForm(projectId: 1),
          ),
        ),
      );

      // Intentar enviar formulario vacío
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('submit_button')));
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestran mensajes de validación
      expect(find.text('Este campo es obligatorio'), findsWidgets);
    });

    testWidgets('Task status changes work correctly', (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      final tasksBloc = TasksBloc(
        tasksService: MockTasksService(),
        authService: mockAuthService,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<TasksBloc>(
            create: (context) => tasksBloc,
            child: const KanbanBoard(projectId: 1),
          ),
        ),
      );

      // Verificar que el dropdown de estado está presente
      expect(find.byKey(const Key('status_dropdown')), findsOneWidget);

      // Cambiar estado
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('status_dropdown')));
      await WidgetTestUtils.waitForAnimation(tester);

      // Seleccionar nuevo estado
      await WidgetTestUtils.tapWidget(tester, find.text('En Progreso'));
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que el estado cambió
      expect(find.text('En Progreso'), findsOneWidget);
    });
  });
}

// Mock TasksService para los tests
class MockTasksService {
  Future<List<Task>> getTasks({required int projectId}) async {
    return [
      Task(
        id: 1,
        projectId: projectId,
        title: 'Tarea de prueba',
        description: 'Descripción de prueba',
        status: TaskStatus.pending,
        complexity: TaskComplexity.medium,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        kanbanPosition: 0,
        estimatedHours: 8,
        tags: ['test', 'integration'],
        isAutoGenerated: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<Task?> createTask(Task task) async {
    return task.copyWith(id: 1);
  }

  Future<Task?> updateTask(Task task) async {
    return task;
  }

  Future<bool> deleteTask(int taskId) async {
    return true;
  }
}
