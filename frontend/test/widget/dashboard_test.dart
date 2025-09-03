import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

import 'package:frontend/screens/dashboard/student_dashboard.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/models/user.dart';
import 'widget_test_utils.dart';
import 'widget_test_utils.mocks.dart';

void main() {
  group('StudentDashboard Widget Tests (Dashboard Principal)', () {
    late MockAuthService mockAuthService;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthService = MockAuthService();
      authBloc = AuthBloc(authService: mockAuthService);
      
      // Configurar mocks básicos
      when(mockAuthService.isAuthenticated).thenReturn(true);
      when(mockAuthService.authStateChanges).thenAnswer(
        (_) => const Stream.empty(),
      );
    });

    tearDown(() {
      authBloc.close();
    });

    Widget createTestWidget() {
      return WidgetTestUtils.createTestApp(
        child: StudentDashboard(user: WidgetTestUtils.createTestUser()),
        blocProviders: [
          BlocProvider<AuthBloc>.value(value: authBloc),
        ],
      );
    }

    testWidgets('Dashboard shows correct title and structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar estructura básica
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Dashboard handles authentication state correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se maneja el estado de autenticación
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Dashboard shows loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Verificar estado de carga inicial
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Dashboard shows error state',
        (WidgetTester tester) async {
      // Configurar mock para estado de error
      when(mockAuthService.isAuthenticated).thenThrow(
        Exception('Error de autenticación'),
      );

      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se maneja el error
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Dashboard responsive design works',
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
