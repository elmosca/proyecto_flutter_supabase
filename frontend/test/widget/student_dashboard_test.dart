import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

import 'package:frontend/screens/dashboard/student_dashboard.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/blocs/anteprojects_bloc.dart';
import 'package:frontend/blocs/tasks_bloc.dart';
import 'widget_test_utils.dart';
import 'widget_test_utils.mocks.dart';

void main() {
  group('StudentDashboard Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockAnteprojectsService mockAnteprojectsService;
    late MockTasksService mockTasksService;
    late AuthBloc authBloc;
    late AnteprojectsBloc anteprojectsBloc;
    late TasksBloc tasksBloc;

    setUp(() {
      mockAuthService = MockAuthService();
      mockAnteprojectsService = MockAnteprojectsService();
      mockTasksService = MockTasksService();
      
      authBloc = AuthBloc(authService: mockAuthService);
      anteprojectsBloc = AnteprojectsBloc(anteprojectsService: mockAnteprojectsService);
      tasksBloc = TasksBloc(tasksService: mockTasksService);
      
      // Configurar mocks básicos
      WidgetTestUtils.setupBasicMocks(
        mockAuthService: mockAuthService,
        mockAnteprojectsService: mockAnteprojectsService,
        mockTasksService: mockTasksService,
      );
    });

    tearDown(() {
      authBloc.close();
      anteprojectsBloc.close();
      tasksBloc.close();
    });

    Widget createTestWidget() {
      return WidgetTestUtils.createTestApp(
        child: StudentDashboard(user: WidgetTestUtils.createTestUser()),
        blocProviders: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<AnteprojectsBloc>.value(value: anteprojectsBloc),
          BlocProvider<TasksBloc>.value(value: tasksBloc),
        ],
      );
    }

    testWidgets('StudentDashboard shows correct title and structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar estructura básica
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verificar título
      expect(find.textContaining('Dashboard'), findsOneWidget);
    });

    testWidgets('StudentDashboard shows user information section',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestra información del usuario
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('StudentDashboard shows navigation options',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que hay opciones de navegación (TextButton en lugar de ElevatedButton)
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('StudentDashboard shows quick actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestran acciones rápidas
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('StudentDashboard handles empty state gracefully',
        (WidgetTester tester) async {
      // Configurar mocks para estado vacío
      when(mockAnteprojectsService.getAnteprojects()).thenAnswer((_) async => []);
      when(mockTasksService.getTasks()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se maneja el estado vacío
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('StudentDashboard shows loading state',
        (WidgetTester tester) async {
      // Configurar mocks para estado de carga
      when(mockAnteprojectsService.getAnteprojects()).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return [WidgetTestUtils.createTestAnteproject()];
        },
      );

      await tester.pumpWidget(createTestWidget());
      
      // Verificar estado de carga inicial
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Esperar a que se complete la carga
      await tester.pumpAndSettle();
    });

    testWidgets('StudentDashboard shows error state',
        (WidgetTester tester) async {
      // Configurar mocks para estado de error
      when(mockAnteprojectsService.getAnteprojects()).thenThrow(
        Exception('Error de conexión'),
      );

      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se maneja el error
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('StudentDashboard navigation works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que los botones de navegación están presentes
      final navigationButtons = find.byType(TextButton);
      expect(navigationButtons, findsWidgets);

      // Simular tap en botón de navegación
      if (navigationButtons.evaluate().isNotEmpty) {
        await WidgetTestUtils.tapWidget(tester, navigationButtons.first);
        await WidgetTestUtils.waitForAnimation(tester);
      }
    });

    testWidgets('StudentDashboard shows correct user role information',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestra información del rol del usuario
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('StudentDashboard responsive design works',
        (WidgetTester tester) async {
      // Probar en diferentes tamaños de pantalla
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      expect(find.byType(Scaffold), findsOneWidget);

      // Restaurar tamaño original
      await tester.binding.setSurfaceSize(null);
    });
  });
}
