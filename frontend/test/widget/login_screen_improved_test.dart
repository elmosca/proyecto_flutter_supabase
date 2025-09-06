import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/screens/auth/login_screen_bloc.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/services/auth_service.dart';
import '../test_setup.dart';
import '../mocks/supabase_mock.dart';

void main() {
  group('LoginScreen Improved Tests', () {
    late AuthBloc authBloc;
    late AuthService authService;

    setUpAll(() async {
      await TestSetup.initializeSupabase();
    });

    setUp(() {
      // Configurar mocks
      SupabaseMock.setAuthenticatedUser(
        id: 'test-user-id',
        email: 'test@example.com',
        role: 'student',
      );
      
      authService = AuthService();
      authBloc = AuthBloc(authService: authService);
    });

    tearDown(() {
      authBloc.close();
    });

    tearDownAll(() async {
      await TestSetup.cleanup();
    });

    testWidgets('LoginScreen shows login form with proper structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup.createTestApp(
          child: BlocProvider<AuthBloc>(
            create: (context) => authBloc,
            child: const LoginScreenBloc(),
          ),
        ),
      );

      // Verificar que se muestra el formulario de login
      expect(find.byType(LoginScreenBloc), findsOneWidget);
      
      // Verificar que se muestran los campos de email y contraseña
      expect(find.byType(TextFormField), findsNWidgets(2));
      
      // Verificar que se muestra el botón de login
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('LoginScreen shows localized text', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup.createTestApp(
          child: BlocProvider<AuthBloc>(
            create: (context) => authBloc,
            child: const LoginScreenBloc(),
          ),
        ),
      );

      // Verificar que se muestran textos localizados
      final l10n = AppLocalizations.of(tester.element(find.byType(LoginScreenBloc)))!;
      
      expect(find.text(l10n.login), findsOneWidget);
      expect(find.text(l10n.email), findsOneWidget);
      expect(find.text(l10n.password), findsOneWidget);
    });

    testWidgets('LoginScreen handles form validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup.createTestApp(
          child: BlocProvider<AuthBloc>(
            create: (context) => authBloc,
            child: const LoginScreenBloc(),
          ),
        ),
      );

      // Intentar hacer login sin llenar campos
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verificar que se muestran mensajes de validación
      final l10n = AppLocalizations.of(tester.element(find.byType(LoginScreenBloc)))!;
      expect(find.text(l10n.fieldRequired), findsAtLeastNWidgets(1));
    });

    testWidgets('LoginScreen handles successful login', (WidgetTester tester) async {
      // Configurar mock para login exitoso
      when(SupabaseMock.auth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer(
        (_) async => AuthResponse(session: MockSupabase.session, user: MockSupabase.user),
      );

      await tester.pumpWidget(
        TestSetup.createTestApp(
          child: BlocProvider<AuthBloc>(
            create: (context) => authBloc,
            child: const LoginScreenBloc(),
          ),
        ),
      );

      // Llenar campos de login
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Hacer login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verificar que no hay errores de validación
      final l10n = AppLocalizations.of(tester.element(find.byType(LoginScreenBloc)))!;
      expect(find.text(l10n.fieldRequired), findsNothing);
    });

    testWidgets('LoginScreen handles login error', (WidgetTester tester) async {
      // Configurar mock para login fallido
      when(SupabaseMock.auth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(
        Exception('Invalid credentials'),
      );

      await tester.pumpWidget(
        TestSetup.createTestApp(
          child: BlocProvider<AuthBloc>(
            create: (context) => authBloc,
            child: const LoginScreenBloc(),
          ),
        ),
      );

      // Llenar campos de login
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');

      // Hacer login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verificar que se muestra mensaje de error
      final l10n = AppLocalizations.of(tester.element(find.byType(LoginScreenBloc)))!;
      expect(find.text(l10n.loginError), findsOneWidget);
    });

    testWidgets('LoginScreen is responsive', (WidgetTester tester) async {
      // Configurar tamaño de pantalla móvil
      TestSetup.setMobileSize(tester);

      await tester.pumpWidget(
        TestSetup.createTestApp(
          child: BlocProvider<AuthBloc>(
            create: (context) => authBloc,
            child: const LoginScreenBloc(),
          ),
          responsive: true,
        ),
      );

      // Verificar que el formulario se adapta al tamaño de pantalla
      expect(find.byType(LoginScreenBloc), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Resetear tamaño de pantalla
      TestSetup.setMobileSize(tester);
    });
  });
}
