import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/anteprojects_bloc.dart';
import 'package:frontend/models/anteproject.dart';
import 'package:frontend/screens/forms/anteproject_form.dart';
import 'package:frontend/screens/forms/anteproject_edit_form.dart';
import 'package:frontend/screens/lists/anteprojects_list.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/test/mocks/auth_service_mock.dart';
import 'package:frontend/test/mocks/supabase_mock.dart';
import 'package:frontend/test/widget/widget_test_utils.dart';

void main() {
  group('Anteproject Flow Integration Tests', () {
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

    testWidgets('Complete anteproject creation flow works correctly',
        (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      final anteprojectsBloc = AnteprojectsBloc(
        anteprojectsService: MockAnteprojectsService(),
        authService: mockAuthService,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AnteprojectsBloc>(
            create: (context) => anteprojectsBloc,
            child: const AnteprojectForm(),
          ),
        ),
      );

      // Verificar que el formulario se renderiza correctamente
      expect(find.byType(AnteprojectForm), findsOneWidget);
      expect(find.text('Formulario de Anteproyecto'), findsOneWidget);

      // Llenar el formulario
      await WidgetTestUtils.enterText(tester, find.byKey(const Key('title_field')), 'Anteproyecto de prueba');
      await WidgetTestUtils.enterText(tester, find.byKey(const Key('description_field')), 'Descripción del anteproyecto de prueba');

      // Seleccionar tipo de proyecto
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('project_type_dropdown')));
      await WidgetTestUtils.waitForAnimation(tester);
      await WidgetTestUtils.tapWidget(tester, find.text('Ejecución'));
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que los campos se llenaron
      expect(find.text('Anteproyecto de prueba'), findsOneWidget);
      expect(find.text('Descripción del anteproyecto de prueba'), findsOneWidget);
      expect(find.text('Ejecución'), findsOneWidget);

      // Simular envío del formulario
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('submit_button')));
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestra mensaje de éxito
      expect(find.text('Anteproyecto creado exitosamente'), findsOneWidget);
    });

    testWidgets('Anteproject list displays anteprojects correctly', (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      final anteprojectsBloc = AnteprojectsBloc(
        anteprojectsService: MockAnteprojectsService(),
        authService: mockAuthService,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AnteprojectsBloc>(
            create: (context) => anteprojectsBloc,
            child: const AnteprojectsList(),
          ),
        ),
      );

      // Verificar que la lista se renderiza
      expect(find.byType(AnteprojectsList), findsOneWidget);
      expect(find.text('Lista de Anteproyectos'), findsOneWidget);

      // Verificar botón de crear anteproyecto
      expect(find.byKey(const Key('create_anteproject_button')), findsOneWidget);

      // Verificar que se muestran anteproyectos de prueba
      expect(find.text('Anteproyecto de prueba'), findsOneWidget);
    });

    testWidgets('Anteproject edit form works correctly', (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      final anteprojectsBloc = AnteprojectsBloc(
        anteprojectsService: MockAnteprojectsService(),
        authService: mockAuthService,
      );

      final testAnteproject = Anteproject(
        id: 1,
        title: 'Anteproyecto existente',
        projectType: ProjectType.execution,
        description: 'Descripción existente',
        academicYear: '2024-2025',
        institution: 'CIFP Carlos III de Cartagena',
        modality: 'modalidad distancia',
        location: 'Cartagena',
        expectedResults: ['Resultado 1', 'Resultado 2'],
        timeline: {'fase1': '2024-09-01', 'fase2': '2024-10-01'},
        status: AnteprojectStatus.draft,
        tutorId: 1,
        submittedAt: null,
        reviewedAt: null,
        projectId: null,
        tutorComments: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AnteprojectsBloc>(
            create: (context) => anteprojectsBloc,
            child: AnteprojectEditForm(anteproject: testAnteproject),
          ),
        ),
      );

      // Verificar que el formulario se renderiza con datos existentes
      expect(find.byType(AnteprojectEditForm), findsOneWidget);
      expect(find.text('Editar Anteproyecto'), findsOneWidget);

      // Verificar que los campos están prellenados
      expect(find.text('Anteproyecto existente'), findsOneWidget);
      expect(find.text('Descripción existente'), findsOneWidget);

      // Modificar el título
      await WidgetTestUtils.enterText(tester, find.byKey(const Key('title_field')), 'Anteproyecto modificado');
      await WidgetTestUtils.waitForAnimation(tester);

      // Simular envío del formulario
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('submit_button')));
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestra mensaje de éxito
      expect(find.text('Anteproyecto actualizado exitosamente'), findsOneWidget);
    });

    testWidgets('Anteproject form validation works correctly', (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      final anteprojectsBloc = AnteprojectsBloc(
        anteprojectsService: MockAnteprojectsService(),
        authService: mockAuthService,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AnteprojectsBloc>(
            create: (context) => anteprojectsBloc,
            child: const AnteprojectForm(),
          ),
        ),
      );

      // Intentar enviar formulario vacío
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('submit_button')));
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que se muestran mensajes de validación
      expect(find.text('Este campo es obligatorio'), findsWidgets);
    });

    testWidgets('Navigation between anteproject screens works', (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      final anteprojectsBloc = AnteprojectsBloc(
        anteprojectsService: MockAnteprojectsService(),
        authService: mockAuthService,
      );

      // Comenzar con AnteprojectsList
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AnteprojectsBloc>(
            create: (context) => anteprojectsBloc,
            child: const AnteprojectsList(),
          ),
        ),
      );

      expect(find.byType(AnteprojectsList), findsOneWidget);

      // Navegar a AnteprojectForm
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('create_anteproject_button')));
      await WidgetTestUtils.waitForAnimation(tester);

      expect(find.byType(AnteprojectForm), findsOneWidget);

      // Navegar de vuelta (simular botón de cancelar)
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('cancel_button')));
      await WidgetTestUtils.waitForAnimation(tester);

      expect(find.byType(AnteprojectsList), findsOneWidget);
    });

    testWidgets('Anteproject status changes work correctly', (WidgetTester tester) async {
      TestSetup.setMobileSize(tester);

      final anteprojectsBloc = AnteprojectsBloc(
        anteprojectsService: MockAnteprojectsService(),
        authService: mockAuthService,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AnteprojectsBloc>(
            create: (context) => anteprojectsBloc,
            child: const AnteprojectsList(),
          ),
        ),
      );

      // Verificar que se muestran los anteproyectos con sus estados
      expect(find.text('Borrador'), findsOneWidget);

      // Simular cambio de estado (botón de enviar)
      await WidgetTestUtils.tapWidget(tester, find.byKey(const Key('submit_anteproject_button')));
      await WidgetTestUtils.waitForAnimation(tester);

      // Verificar que el estado cambió
      expect(find.text('Enviado'), findsOneWidget);
    });
  });
}

// Mock AnteprojectsService para los tests
class MockAnteprojectsService {
  Future<List<Anteproject>> getAnteprojects() async {
    return [
      Anteproject(
        id: 1,
        title: 'Anteproyecto de prueba',
        projectType: ProjectType.execution,
        description: 'Descripción de prueba',
        academicYear: '2024-2025',
        institution: 'CIFP Carlos III de Cartagena',
        modality: 'modalidad distancia',
        location: 'Cartagena',
        expectedResults: ['Resultado 1', 'Resultado 2'],
        timeline: {'fase1': '2024-09-01', 'fase2': '2024-10-01'},
        status: AnteprojectStatus.draft,
        tutorId: 1,
        submittedAt: null,
        reviewedAt: null,
        projectId: null,
        tutorComments: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<Anteproject?> createAnteproject(Anteproject anteproject) async {
    return anteproject.copyWith(id: 1);
  }

  Future<Anteproject?> updateAnteproject(Anteproject anteproject) async {
    return anteproject;
  }

  Future<bool> deleteAnteproject(int anteprojectId) async {
    return true;
  }

  Future<bool> submitAnteproject(int anteprojectId) async {
    return true;
  }
}
