import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'utils/config.dart';
import 'screens/dashboard/student_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mostrar información de configuración
  AppConfig.printConfig();
  
  // Configuración específica por plataforma
  if (kIsWeb) {
    print('🌐 Ejecutando en Web');
  } else if (Platform.isWindows) {
    print('🖥️ Ejecutando en Windows');
  } else if (Platform.isAndroid) {
    print('📱 Ejecutando en Android');
  } else if (Platform.isIOS) {
    print('🍎 Ejecutando en iOS');
  } else if (Platform.isMacOS) {
    print('🍎 Ejecutando en macOS');
  } else if (Platform.isLinux) {
    print('🐧 Ejecutando en Linux');
  }
  
  // Configuración de Supabase para servidor de red
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(AppConfig.platformColor)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showServerInfo = false;
  
  @override
  void initState() {
    super.initState();
    // Usar credenciales de prueba por defecto
    _emailController.text = AppConfig.testCredentials['student']!;
    _passwordController.text = AppConfig.testCredentials['password']!;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login TFG - ${AppConfig.platformName}'),
        backgroundColor: Color(AppConfig.platformColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showServerInfo ? Icons.info : Icons.info_outline),
            onPressed: () {
              setState(() {
                _showServerInfo = !_showServerInfo;
              });
            },
            tooltip: 'Información del servidor',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Información de plataforma
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(AppConfig.platformIcon, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text('Plataforma: ${AppConfig.platformName}'),
                    Text('Versión: ${AppConfig.appVersion}'),
                    const SizedBox(height: 8),
                    Text('Backend: ${AppConfig.supabaseUrl}', 
                         style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            
            // Información del servidor (expandible)
            if (_showServerInfo) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                              Row(
                          children: [
                            Icon(Icons.dns, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text('Información del Servidor', 
                                 style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                          ],
                        ),
                      const SizedBox(height: 12),
                      _buildServerInfoRow('IP del Servidor', AppConfig.serverInfo['ip']!),
                      _buildServerInfoRow('Puerto API', AppConfig.serverInfo['port']!),
                      _buildServerInfoRow('Storage S3', AppConfig.storageUrl),
                      _buildServerInfoRow('Supabase Studio', AppConfig.supabaseStudioUrl),
                      _buildServerInfoRow('Email Testing', AppConfig.inbucketUrl),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Formulario de login
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            
            // Botón de login
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(AppConfig.platformColor),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Iniciar Sesión'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Información adicional
            const Text(
              'Usando credenciales de prueba por defecto',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            
            const SizedBox(height: 16),
            
            // Enlaces útiles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _openUrl(AppConfig.supabaseStudioUrl),
                  icon: const Icon(Icons.dashboard, size: 16),
                  label: const Text('Studio'),
                ),
                TextButton.icon(
                  onPressed: () => _openUrl(AppConfig.inbucketUrl),
                  icon: const Icon(Icons.email, size: 16),
                  label: const Text('Email'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildServerInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
  
  void _openUrl(String url) {
    // En una aplicación real, usaríamos url_launcher
    print('Abrir URL: $url');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrir: $url'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (response.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Login exitoso en ${AppConfig.platformName}!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Aquí navegaríamos al dashboard según el rol
          print('Usuario logueado: ${response.user!.email}');
          print('Rol: ${response.user!.userMetadata?['role'] ?? 'No especificado'}');
          
          // Mostrar información adicional del usuario
          _showUserInfo(response.user!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error de login: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showUserInfo(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Login Exitoso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('ID: ${user.id}'),
            Text('Rol: ${user.userMetadata?['role'] ?? 'No especificado'}'),
            Text('Creado: ${user.createdAt}'),
            const SizedBox(height: 16),
            const Text('Próximos pasos:'),
            const Text('• Navegación por roles'),
            const Text('• Dashboard personalizado'),
            const Text('• Gestión de anteproyectos'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToDashboard(user);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard(User user) {
    final role = user.userMetadata?['role'] ?? 'student';
    
    switch (role) {
      case 'student':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => StudentDashboard(user: user),
          ),
        );
        break;
      case 'tutor':
        // TODO: Implementar TutorDashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dashboard de tutor en desarrollo')),
        );
        break;
      case 'admin':
        // TODO: Implementar AdminDashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dashboard de admin en desarrollo')),
        );
        break;
      default:
        // Por defecto, ir al dashboard de estudiante
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => StudentDashboard(user: user),
          ),
        );
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
