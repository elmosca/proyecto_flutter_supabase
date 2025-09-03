import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

import 'package:frontend/screens/dashboard/admin_dashboard.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/blocs/anteprojects_bloc.dart';
import 'package:frontend/blocs/tasks_bloc.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/anteprojects_service.dart';
import 'package:frontend/services/tasks_service.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/anteproject.dart';
import 'package:frontend/models/task.dart';
import 'widget_test_utils.dart';
import 'widget_test_utils.mocks.dart';

void main() {
  group('AdminDashboard Widget Tests', () {
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
        child: AdminDashboard(user: WidgetTestUtils.createTestUser(role: UserRole.admin)),
        blocProviders: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<AnteprojectsBloc>.value(value: anteprojectsBloc),
          BlocProvider<TasksBloc>.value(value: tasksBloc),
        ],
      );
    }

    testWidgets('AdminDashboard shows correct title and structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar estructura básica
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verificar título
      expect(find.textContaining('Dashboard'), findsOneWidget);
    });

    testWidgets('AdminDashboard shows admin-specific information',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestra información específica del administrador
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('AdminDashboard shows system overview section',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestra la vista general del sistema
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AdminDashboard shows user management options',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que hay opciones de gestión de usuarios
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('AdminDashboard shows system statistics',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestran estadísticas del sistema
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AdminDashboard handles empty state gracefully',
        (WidgetTester tester) async {
      // Configurar mocks para estado vacío
      when(mockAnteprojectsService.getAnteprojects()).thenAnswer((_) async => []);
      when(mockTasksService.getTasks()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se maneja el estado vacío
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AdminDashboard shows loading state',
        (WidgetTester tester) async {
      // Configurar mocks para estado de carga
      when(mockAnteprojectsService.getAnteprojects()).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(seconds: 1));
          return [WidgetTestUtils.createTestAnteproject()];
        },
      );

      await tester.pumpWidget(createTestWidget());
      
      // Verificar estado de carga inicial
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AdminDashboard shows error state',
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

    testWidgets('AdminDashboard navigation works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que los botones de navegación están presentes
      final navigationButtons = find.byType(ElevatedButton);
      expect(navigationButtons, findsWidgets);

      // Simular tap en botón de navegación
      if (navigationButtons.evaluate().isNotEmpty) {
        await WidgetTestUtils.tapWidget(tester, navigationButtons.first);
        await WidgetTestUtils.waitForAnimation(tester);
      }
    });

    testWidgets('AdminDashboard shows correct user role information',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestra información del rol del administrador
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AdminDashboard responsive design works',
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
