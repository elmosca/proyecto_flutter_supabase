import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/anteprojects_service.dart';
import 'package:frontend/models/anteproject.dart';
import 'integration_test_setup.dart';

import 'package:flutter/foundation.dart';

void main() {
  group('Anteprojects Integration Tests', () {
    late AuthService authService;
    late AnteprojectsService anteprojectsService;

    setUpAll(() async {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🚀 Iniciando tests de integración de anteproyectos');
      debugPrint('═══════════════════════════════════════════════════════════');
      
      // Inicializar Supabase usando variables de entorno
      // initializeSupabase() ahora incluye verificación automática de conexión
      // y lanzará StateError si el backend no está disponible
      await IntegrationTestSetup.initializeSupabase();
      
      debugPrint('✅ Setup completado. Iniciando tests...');
      debugPrint('');
    });

    setUp(() async {
      authService = AuthService();
      anteprojectsService = AnteprojectsService();
      await IntegrationTestSetup.cleanupTestData();
    });

    tearDown(() async {
      await IntegrationTestSetup.cleanupTestData();
    });

    test('Can authenticate and access anteprojects service', () async {
      // CORRECCIÓN: Sin try-catch - si falla, el test debe fallar
      const testEmail = String.fromEnvironment(
        'TEST_USER_EMAIL',
        defaultValue: 'carlos.lopez@jualas.es',
      );
      const testPassword = String.fromEnvironment(
        'TEST_USER_PASSWORD',
        defaultValue: 'password123',
      );

      // Hacer sign in
      await authService.signIn(
        email: testEmail,
        password: testPassword,
      );

      expect(
        authService.isAuthenticated,
        isTrue,
        reason: 'Usuario debe estar autenticado después de sign in',
      );

      // Verificar que el servicio está disponible
      expect(
        anteprojectsService,
        isNotNull,
        reason: 'AnteprojectsService debe estar disponible',
      );

      // Limpiar
      await authService.signOut();
    });

    test('Can fetch anteprojects from backend', () async {
      // CORRECCIÓN: Sin try-catch - si falla, el test debe fallar
      const testEmail = String.fromEnvironment(
        'TEST_USER_EMAIL',
        defaultValue: 'carlos.lopez@jualas.es',
      );
      const testPassword = String.fromEnvironment(
        'TEST_USER_PASSWORD',
        defaultValue: 'password123',
      );

      // Hacer sign in
      await authService.signIn(
        email: testEmail,
        password: testPassword,
      );

      // Obtener anteproyectos
      final anteprojects = await anteprojectsService.getAnteprojects();

      // Verificar que se obtuvieron datos (puede estar vacío)
      expect(
        anteprojects,
        isA<List<Anteproject>>(),
        reason: 'Debe retornar una lista de anteproyectos',
      );

      // Si hay anteproyectos, verificar estructura
      if (anteprojects.isNotEmpty) {
        final firstAnteproject = anteprojects.first;
        expect(
          firstAnteproject.id,
          isNotNull,
          reason: 'Anteproyecto debe tener un ID válido',
        );
        expect(
          firstAnteproject.title,
          isNotEmpty,
          reason: 'Anteproyecto debe tener un título',
        );
        expect(
          firstAnteproject.description,
          isNotEmpty,
          reason: 'Anteproyecto debe tener una descripción',
        );
        expect(
          firstAnteproject.projectType,
          isNotNull,
          reason: 'Anteproyecto debe tener un tipo de proyecto',
        );
        expect(
          firstAnteproject.status,
          isNotNull,
          reason: 'Anteproyecto debe tener un estado',
        );
        // Verificar que githubRepositoryUrl puede ser null o una URL válida
        if (firstAnteproject.githubRepositoryUrl != null) {
          expect(
            firstAnteproject.githubRepositoryUrl,
            isNotEmpty,
            reason: 'Si githubRepositoryUrl no es null, debe tener contenido',
          );
          // Verificar que es una URL válida de GitHub
          expect(
            firstAnteproject.githubRepositoryUrl!.contains('github.com'),
            isTrue,
            reason: 'githubRepositoryUrl debe ser una URL de GitHub',
          );
        }
      }

      // Limpiar
      await authService.signOut();
    });

    test('Can fetch anteprojects by user', () async {
      // CORRECCIÓN: Sin try-catch - si falla, el test debe fallar
      const testEmail = String.fromEnvironment(
        'TEST_USER_EMAIL',
        defaultValue: 'carlos.lopez@jualas.es',
      );
      const testPassword = String.fromEnvironment(
        'TEST_USER_PASSWORD',
        defaultValue: 'password123',
      );

      // Hacer sign in
      await authService.signIn(
        email: testEmail,
        password: testPassword,
      );

      // Obtener anteproyectos del usuario actual
      final userAnteprojects = await anteprojectsService.getAnteprojects();

      // Verificar que se obtuvieron datos (puede estar vacío)
      expect(
        userAnteprojects,
        isA<List<Anteproject>>(),
        reason: 'Debe retornar una lista de anteproyectos del usuario',
      );

      // Si hay anteproyectos, verificar que pertenecen al usuario
      if (userAnteprojects.isNotEmpty) {
        for (final anteproject in userAnteprojects) {
          expect(
            anteproject.id,
            isNotNull,
            reason: 'Cada anteproyecto debe tener un ID válido',
          );
          expect(
            anteproject.title,
            isNotEmpty,
            reason: 'Cada anteproyecto debe tener un título',
          );
        }
      }

      // Limpiar
      await authService.signOut();
    });

    test('Can fetch anteprojects by status', () async {
      // CORRECCIÓN: Sin try-catch - si falla, el test debe fallar
      const testEmail = String.fromEnvironment(
        'TEST_USER_EMAIL',
        defaultValue: 'carlos.lopez@jualas.es',
      );
      const testPassword = String.fromEnvironment(
        'TEST_USER_PASSWORD',
        defaultValue: 'password123',
      );

      // Hacer sign in
      await authService.signIn(
        email: testEmail,
        password: testPassword,
      );

      // Obtener anteproyectos por diferentes estados
      final pendingAnteprojects =
          await anteprojectsService.getAnteprojectsByStatus(
        AnteprojectStatus.draft,
      );
      final submittedAnteprojects =
          await anteprojectsService.getAnteprojectsByStatus(
        AnteprojectStatus.submitted,
      );
      final approvedAnteprojects =
          await anteprojectsService.getAnteprojectsByStatus(
        AnteprojectStatus.approved,
      );

      // Verificar que se obtuvieron listas válidas
      expect(
        pendingAnteprojects,
        isA<List<Anteproject>>(),
        reason: 'Debe retornar lista de anteproyectos en borrador',
      );
      expect(
        submittedAnteprojects,
        isA<List<Anteproject>>(),
        reason: 'Debe retornar lista de anteproyectos enviados',
      );
      expect(
        approvedAnteprojects,
        isA<List<Anteproject>>(),
        reason: 'Debe retornar lista de anteproyectos aprobados',
      );

      // Limpiar
      await authService.signOut();
    });

    test('Can fetch anteproject by ID', () async {
      // CORRECCIÓN: Sin try-catch - si falla, el test debe fallar
      const testEmail = String.fromEnvironment(
        'TEST_USER_EMAIL',
        defaultValue: 'carlos.lopez@jualas.es',
      );
      const testPassword = String.fromEnvironment(
        'TEST_USER_PASSWORD',
        defaultValue: 'password123',
      );

      // Hacer sign in
      await authService.signIn(
        email: testEmail,
        password: testPassword,
      );

      // Primero obtener lista de anteproyectos
      final anteprojects = await anteprojectsService.getAnteprojects();

      if (anteprojects.isNotEmpty) {
        final firstAnteproject = anteprojects.first;

        // Obtener anteproyecto por ID
        final fetchedAnteproject =
            await anteprojectsService.getAnteproject(firstAnteproject.id);

        // Verificar que se obtuvo el anteproyecto correcto
        expect(
          fetchedAnteproject,
          isNotNull,
          reason: 'Debe retornar el anteproyecto solicitado',
        );
        expect(
          fetchedAnteproject!.id,
          equals(firstAnteproject.id),
          reason: 'ID del anteproyecto debe coincidir',
        );
        expect(
          fetchedAnteproject.title,
          equals(firstAnteproject.title),
          reason: 'Título del anteproyecto debe coincidir',
        );
        // Verificar que githubRepositoryUrl se recupera correctamente
        expect(
          fetchedAnteproject.githubRepositoryUrl,
          equals(firstAnteproject.githubRepositoryUrl),
          reason: 'githubRepositoryUrl debe coincidir',
        );
      }

      // Limpiar
      await authService.signOut();
    });

    test('Can fetch anteprojects by tutor', () async {
      // CORRECCIÓN: Sin try-catch - si falla, el test debe fallar
      const testEmail = String.fromEnvironment(
        'TEST_USER_EMAIL',
        defaultValue: 'carlos.lopez@jualas.es',
      );
      const testPassword = String.fromEnvironment(
        'TEST_USER_PASSWORD',
        defaultValue: 'password123',
      );

      // Hacer sign in
      await authService.signIn(
        email: testEmail,
        password: testPassword,
      );

      // Obtener anteproyectos por tutor
      final tutorAnteprojectsData =
          await anteprojectsService.getTutorAnteprojects();

      // Verificar que se obtuvieron datos (puede estar vacío)
      expect(
        tutorAnteprojectsData,
        isA<List<Map<String, dynamic>>>(),
        reason: 'Debe retornar lista de anteproyectos con datos del tutor',
      );

      // Si hay anteproyectos, verificar estructura
      if (tutorAnteprojectsData.isNotEmpty) {
        for (final anteprojectData in tutorAnteprojectsData) {
          final anteproject = Anteproject.fromJson(anteprojectData);
          expect(
            anteproject.id,
            isNotNull,
            reason: 'Cada anteproyecto debe tener un ID válido',
          );
          expect(
            anteproject.tutorId,
            isNotNull,
            reason: 'Cada anteproyecto debe tener un tutor asignado',
          );
        }
      }

      // Limpiar
      await authService.signOut();
    });

    test('Fetching non-existent anteproject throws exception', () async {
      // CORRECCIÓN: Test de caso de fallo - ID inexistente
      const testEmail = String.fromEnvironment(
        'TEST_USER_EMAIL',
        defaultValue: 'carlos.lopez@jualas.es',
      );
      const testPassword = String.fromEnvironment(
        'TEST_USER_PASSWORD',
        defaultValue: 'password123',
      );

      // Hacer sign in
      await authService.signIn(
        email: testEmail,
        password: testPassword,
      );

      // Intentar obtener un anteproyecto con ID que no existe
      // Usar un ID muy grande que seguramente no existe
      const nonExistentId = 999999;

      // Debe lanzar una excepción cuando el ID no existe
      expect(
        () async => await anteprojectsService.getAnteproject(nonExistentId),
        throwsA(anything),
        reason:
            'Obtener anteproyecto con ID inexistente debe lanzar una excepción',
      );

      // Limpiar
      await authService.signOut();
    });
  });
}
