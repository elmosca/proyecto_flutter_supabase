import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/services/email_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    try {
      SharedPreferences.setMockInitialValues({});
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: AppConfig.testCredentials['admin']!,
        password: AppConfig.testCredentials['admin_password']!,
      );
      if (response.session == null) {
        throw StateError('No se pudo iniciar sesión para ejecutar la prueba.');
      }
    } on StateError {
      // Supabase ya se encontraba inicializado.
    }
  });

  tearDownAll(() async {
    await Supabase.instance.client.auth.signOut();
  });

  group('EmailNotificationService', () {
    test('envía un email de bienvenida real', () async {
      const defaultRecipient = 'jualas@gmail.com';
      const recipient = String.fromEnvironment(
        'TEST_EMAIL_RECIPIENT',
        defaultValue: defaultRecipient,
      );

      final generatedPassword =
          'Test-${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}!';

      await EmailNotificationService.sendStudentWelcomeEmail(
        studentEmail: recipient,
        studentName: 'Prueba Automática de Emails',
        password: generatedPassword,
        academicYear: '2025-2026',
        tutorName: 'Tutor de Prueba',
        tutorEmail: 'tutor.test@fct.jualas.es',
        createdBy: 'administrador',
        createdByName: 'Suite de Pruebas',
        failSilently: false,
      );

      expect(true, isTrue);
    });
  });
}
