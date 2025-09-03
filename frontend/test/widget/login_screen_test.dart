import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

import 'package:frontend/screens/auth/login_screen_bloc.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/services/auth_service.dart';

// Mock del AuthService
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('LoginScreenBloc Widget Tests', () {
    late MockAuthService mockAuthService;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthService = MockAuthService();
      authBloc = AuthBloc(authService: mockAuthService);
    });

    tearDown(() {
      authBloc.close();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>(
          create: (context) => authBloc,
          child: const LoginScreenBloc(),
        ),
      );
    }

    testWidgets('LoginScreenBloc shows login form with all required elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verificar que la pantalla se renderiza correctamente
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Verificar que los campos del formulario están presentes
      expect(find.byType(TextField), findsNWidgets(2)); // Email y Password
      expect(find.byType(ElevatedButton), findsOneWidget); // Botón de login

      // Verificar que el título está presente
      expect(find.textContaining('Login'), findsOneWidget);
    });

    testWidgets('LoginScreenBloc shows email and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verificar que los campos tienen las etiquetas correctas
      expect(find.textContaining('Email'), findsOneWidget);
      expect(find.textContaining('Password'), findsOneWidget);
    });

    testWidgets('LoginScreenBloc shows login button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verificar que el botón de login está presente
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.textContaining('Login'), findsOneWidget);
    });

    testWidgets('LoginScreenBloc shows language selector',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verificar que el selector de idioma está presente
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('LoginScreenBloc shows server info section',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verificar que la información del servidor está presente
      expect(find.textContaining('Server'), findsOneWidget);
      expect(find.textContaining('Test Credentials'), findsOneWidget);
    });
  });
}
