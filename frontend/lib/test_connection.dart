import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/config.dart';

/// Script de prueba para verificar la conexión con Supabase
/// Este archivo se puede ejecutar independientemente para probar la conexión
void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  final supabase = Supabase.instance.client;

  // ignore: avoid_print
  print('🔧 Probando conexión con Supabase...');
  // ignore: avoid_print
  print('URL: ${AppConfig.supabaseUrl}');
  // ignore: avoid_print
  print('Anon Key: ${AppConfig.supabaseAnonKey.substring(0, 20)}...');

  try {
    // Probar conexión básica
    // ignore: avoid_print
    print('\n📊 Probando conexión básica...');
    final response = await supabase.from('users').select('count').single();
    // ignore: avoid_print
    print('✅ Conexión exitosa: ${response['count']} usuarios en la tabla');

    // Intentar crear un usuario de prueba
    // ignore: avoid_print
    print('\n👤 Intentando crear usuario de prueba...');
    
    final signUpResponse = await supabase.auth.signUp(
      email: 'test@example.com',
      password: 'password123',
      data: {
        'name': 'Usuario de Prueba',
        'role': 'student',
      },
    );

    if (signUpResponse.user != null) {
      // ignore: avoid_print
      print('✅ Usuario creado exitosamente: ${signUpResponse.user!.email}');
      
      // Intentar hacer login
      // ignore: avoid_print
      print('\n🔐 Probando login...');
      final signInResponse = await supabase.auth.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      );
      
      if (signInResponse.user != null) {
        // ignore: avoid_print
        print('✅ Login exitoso: ${signInResponse.user!.email}');
        // ignore: avoid_print
        print('Rol: ${signInResponse.user!.userMetadata?['role'] ?? 'No especificado'}');
        
        // Obtener sesión actual
        final session = supabase.auth.currentSession;
        // ignore: avoid_print
        print('Token: ${session?.accessToken?.substring(0, 50)}...');
      }
    } else {
      // ignore: avoid_print
      print('❌ Error al crear usuario: ${signUpResponse.user}');
    }

  } catch (e) {
    // ignore: avoid_print
    print('❌ Error de conexión: $e');
    
    // Intentar obtener más información del error
    if (e is AuthException) {
      // ignore: avoid_print
      print('Código: ${e.statusCode}');
      // ignore: avoid_print
      print('Mensaje: ${e.message}');
    }
  }

  // ignore: avoid_print
  print('\n🏁 Prueba completada');
}
