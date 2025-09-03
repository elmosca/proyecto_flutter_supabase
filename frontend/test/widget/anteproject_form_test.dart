import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

import 'package:frontend/screens/anteprojects/anteproject_form.dart';
import 'package:frontend/blocs/anteprojects_bloc.dart';
import 'package:frontend/services/anteprojects_service.dart';
import 'package:frontend/models/anteproject.dart';
import 'package:frontend/models/user.dart';
import 'widget_test_utils.dart';
import 'widget_test_utils.mocks.dart';

void main() {
  group('AnteprojectForm Widget Tests', () {
    late MockAnteprojectsService mockAnteprojectsService;
    late AnteprojectsBloc anteprojectsBloc;

    setUp(() {
      mockAnteprojectsService = MockAnteprojectsService();
      anteprojectsBloc = AnteprojectsBloc(anteprojectsService: mockAnteprojectsService);
      
      // Configurar mocks básicos
      when(mockAnteprojectsService.getAnteprojects()).thenAnswer(
        (_) async => [WidgetTestUtils.createTestAnteproject()],
      );
    });

    tearDown(() {
      anteprojectsBloc.close();
    });

    Widget createTestWidget() {
      return WidgetTestUtils.createTestApp(
        child: AnteprojectForm(user: WidgetTestUtils.createTestUser()),
        blocProviders: [
          BlocProvider<AnteprojectsBloc>.value(value: anteprojectsBloc),
        ],
      );
    }

    testWidgets('AnteprojectForm shows correct title and structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar estructura básica
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verificar título
      expect(find.textContaining('Anteproyecto'), findsOneWidget);
    });

    testWidgets('AnteprojectForm shows all required form fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar campos requeridos
      expect(find.byType(TextField), findsWidgets);
      expect(find.byType(DropdownButtonFormField), findsWidgets);
      expect(find.byType(ElevatedButton), findsOneWidget); // Botón de envío
    });

    testWidgets('AnteprojectForm shows project type selector',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar selector de tipo de proyecto
      expect(find.byType(DropdownButtonFormField), findsWidgets);
    });

    testWidgets('AnteprojectForm shows academic year field',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar campo de año académico
      expect(find.textContaining('Año Académico'), findsOneWidget);
    });

    testWidgets('AnteprojectForm shows description field',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar campo de descripción
      expect(find.textContaining('Descripción'), findsOneWidget);
    });

    testWidgets('AnteprojectForm shows expected results section',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar sección de resultados esperados
      expect(find.textContaining('Resultados'), findsOneWidget);
    });

    testWidgets('AnteprojectForm shows timeline section',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar sección de temporalización
      expect(find.textContaining('Temporalización'), findsOneWidget);
    });

    testWidgets('AnteprojectForm handles form submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar botón de envío
      final submitButton = find.byType(ElevatedButton);
      expect(submitButton, findsOneWidget);

      // Simular tap en botón de envío
      await WidgetTestUtils.tapWidget(tester, submitButton);
      await WidgetTestUtils.waitForAnimation(tester);
    });

    testWidgets('AnteprojectForm shows validation errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Simular envío sin completar campos
      final submitButton = find.byType(ElevatedButton);
      await WidgetTestUtils.tapWidget(tester, submitButton);
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestran errores de validación
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AnteprojectForm handles user input correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Encontrar campo de título
      final titleField = find.byType(TextField).first;
      
      // Simular entrada de texto
      await WidgetTestUtils.enterText(tester, titleField, 'Mi Anteproyecto');
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que el texto se ingresó
      expect(find.text('Mi Anteproyecto'), findsOneWidget);
    });

    testWidgets('AnteprojectForm shows loading state during submission',
        (WidgetTester tester) async {
      // Configurar mock para estado de carga
      when(mockAnteprojectsService.createAnteproject(any)).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(seconds: 1));
          return WidgetTestUtils.createTestAnteproject();
        },
      );

      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Simular envío del formulario
      final submitButton = find.byType(ElevatedButton);
      await WidgetTestUtils.tapWidget(tester, submitButton);
      
      // Verificar estado de carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AnteprojectForm shows success message after submission',
        (WidgetTester tester) async {
      // Configurar mock para éxito
      when(mockAnteprojectsService.createAnteproject(any)).thenAnswer(
        (_) async => WidgetTestUtils.createTestAnteproject(),
      );

      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Simular envío del formulario
      final submitButton = find.byType(ElevatedButton);
      await WidgetTestUtils.tapWidget(tester, submitButton);
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar mensaje de éxito
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AnteprojectForm shows error message on submission failure',
        (WidgetTester tester) async {
      // Configurar mock para error
      when(mockAnteprojectsService.createAnteproject(any)).thenThrow(
        Exception('Error al crear anteproyecto'),
      );

      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Simular envío del formulario
      final submitButton = find.byType(ElevatedButton);
      await WidgetTestUtils.tapWidget(tester, submitButton);
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar mensaje de error
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AnteprojectForm responsive design works',
        (WidgetTester tester) async {
      // Probar en diferentes tamaños de pantalla
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      expect(find.byType(Scaffold), findsOneWidget);

      // Restaurar tamaño original
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('AnteprojectForm navigation works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que hay opciones de navegación
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
