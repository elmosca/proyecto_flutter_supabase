import 'package:supabase/supabase.dart';

const _supabaseUrl = 'https://zkririyknhlwoxhsoqih.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDkxNjUsImV4cCI6MjA3MTk4NTE2NX0.N9egQFLIqsYdbpjOeSELNiHy5G5RWqa0JY5luZWNBJg';

const _adminEmail = 'admin@jualas.es';
const _adminPassword = 'password123';
const _defaultRecipient = 'jualas@gmail.com';
const _tutorEmail = 'tutor.test@fct.jualas.es';

Future<void> main(List<String> args) async {
  final client = SupabaseClient(_supabaseUrl, _supabaseAnonKey);

  final authResponse = await client.auth.signInWithPassword(
    email: _adminEmail,
    password: _adminPassword,
  );

  if (authResponse.session == null) {
    throw StateError('No se pudo iniciar sesión con el usuario administrador.');
  }

  final recipient = args.isNotEmpty ? args.first : _defaultRecipient;

  final generatedPassword =
      'Test-${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}!';

  final response = await client.functions.invoke(
    'send-email',
    body: {
      'type': 'student_welcome',
      'data': {
        'studentEmail': recipient,
        'studentName': 'Prueba Automática de Emails',
        'password': generatedPassword,
        'academicYear': '2025-2026',
        'studentPhone': null,
        'studentNre': null,
        'studentSpecialty': null,
        'tutorName': 'Tutor de Prueba',
        'tutorEmail': _tutorEmail,
        'tutorPhone': null,
        'createdBy': 'administrador',
        'createdByName': 'Script de Pruebas',
      },
    },
  );

  if (response.status != 200) {
    throw StateError(
      'Edge Function retornó estado ${response.status}: ${response.data}',
    );
  }

  final success = response.data?['success'] == true;
  if (!success) {
    throw StateError('Edge Function no confirmó el envío: ${response.data}');
  }

  await client.auth.signOut();
  client.dispose();

  // ignore: avoid_print
  print('✅ Email enviado a $recipient con contraseña $generatedPassword');
}
