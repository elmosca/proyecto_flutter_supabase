import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import '../test_app_wrapper.dart';
import '../supabase_test_helper.dart';

void main() {
  group('MyApp Mocking Tests', () {
    setUpAll(() async {
      await TestAppSetup.initializeForMyApp();
    });

    tearDownAll(() async {
      await TestAppSetup.cleanup();
    });

    testWidgets('MyApp can be created with mocked Supabase', (WidgetTester tester) async {
      // Verificar que Supabase está mockeado
      expect(SupabaseTestHelper.isAvailable(), isTrue);
      
      // Crear MyApp con mocking
      await tester.pumpWidget(TestAppSetup.createTestApp(child: const MyApp()));
      
      // Verificar que la app se crea sin errores
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('MyApp shows login screen with mocked Supabase', (WidgetTester tester) async {
      // Configurar usuario no autenticado
      SupabaseTestHelper.setUnauthenticatedUser();
      
      // Crear MyApp
      await tester.pumpWidget(TestAppSetup.createTestApp(child: const MyApp()));
      await tester.pumpAndSettle();
      
      // Verificar que se muestra la pantalla de login
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email y Password
      expect(find.byType(ElevatedButton), findsOneWidget); // Login button
    });

    testWidgets('MyApp handles authentication state changes', (WidgetTester tester) async {
      // Configurar usuario autenticado
      SupabaseTestHelper.setAuthenticatedUser(
        id: 'test-user-id',
        email: 'test@example.com',
        role: 'student',
      );
      
      // Crear MyApp
      await tester.pumpWidget(TestAppSetup.createTestApp(child: const MyApp()));
      await tester.pumpAndSettle();
      
      // Verificar que la app maneja el estado de autenticación
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MyApp can be rebuilt multiple times', (WidgetTester tester) async {
      // Crear MyApp
      await tester.pumpWidget(TestAppSetup.createTestApp(child: const MyApp()));
      await tester.pumpAndSettle();
      
      // Verificar primera creación
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Rebuild
      await tester.pumpWidget(TestAppSetup.createTestApp(child: const MyApp()));
      await tester.pumpAndSettle();
      
      // Verificar que sigue funcionando
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MyApp handles different user roles', (WidgetTester tester) async {
      // Test con rol de estudiante
      SupabaseTestHelper.setAuthenticatedUser(role: 'student');
      await tester.pumpWidget(TestAppSetup.createTestApp(child: const MyApp()));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Test con rol de tutor
      SupabaseTestHelper.setAuthenticatedUser(role: 'tutor');
      await tester.pumpWidget(TestAppSetup.createTestApp(child: const MyApp()));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Test con rol de admin
      SupabaseTestHelper.setAuthenticatedUser(role: 'admin');
      await tester.pumpWidget(TestAppSetup.createTestApp(child: const MyApp()));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('SupabaseTestHelper status is correct', () {
      final status = SupabaseTestHelper.getStatus();
      
      expect(status['initialized'], isTrue);
      expect(status['mocked'], isTrue);
      expect(status['available'], isTrue);
      expect(status['inTestEnvironment'], isTrue);
    });
  });
}
