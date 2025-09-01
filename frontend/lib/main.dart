import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n/app_localizations.dart';
import 'screens/dashboard/student_dashboard.dart';
import 'screens/dashboard/tutor_dashboard.dart';
import 'screens/dashboard/admin_dashboard.dart';
import 'services/language_service.dart';
import 'utils/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mostrar información de configuración
  // Configuración específica por plataforma (solo en desarrollo)
  if (kDebugMode) {
    AppConfig.printConfig();

    if (kIsWeb) {
      debugPrint('🌐 Ejecutando en Web');
    } else if (Platform.isWindows) {
      debugPrint('🖥️ Ejecutando en Windows');
    } else if (Platform.isAndroid) {
      debugPrint('📱 Ejecutando en Android');
    } else if (Platform.isIOS) {
      debugPrint('🍎 Ejecutando en iOS');
    } else if (Platform.isMacOS) {
      debugPrint('🍎 Ejecutando en macOS');
    } else if (Platform.isLinux) {
      debugPrint('🐧 Ejecutando en Linux');
    }
  }

  // Configuración de Supabase para servidor de red
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late LanguageService _languageService;

  @override
  void initState() {
    super.initState();
    _languageService = LanguageService();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _languageService,
    builder: (context, child) => MaterialApp(
      title: AppConfig.appName,

      // Configuración de internacionalización
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageService.supportedLocales,
      locale: _languageService.currentLocale,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(AppConfig.platformColor),
        ),
        useMaterial3: true,
      ),
      home: LoginScreen(languageService: _languageService),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  final LanguageService languageService;

  const LoginScreen({super.key, required this.languageService});

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.login} TFG - ${AppConfig.platformName}'),
        backgroundColor: Color(AppConfig.platformColor),
        foregroundColor: Colors.white,
        actions: [
          // Botón de cambio de idioma
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: l10n.language,
            onSelected: (String value) {
              if (value == 'es') {
                widget.languageService.changeToSpanish();
              } else if (value == 'en') {
                widget.languageService.changeToEnglish();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'es',
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(l10n.spanish),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'en',
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(l10n.english),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(_showServerInfo ? Icons.info : Icons.info_outline),
            onPressed: () {
              setState(() {
                _showServerInfo = !_showServerInfo;
              });
            },
            tooltip: l10n.serverInfo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Información de plataforma
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      AppConfig.platformIcon,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.platformLabel(AppConfig.platformName)),
                    Text(l10n.versionLabel(AppConfig.appVersion)),
                    const SizedBox(height: 8),
                    Text(
                      l10n.backendLabel(AppConfig.supabaseUrl),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.dns, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            l10n.serverInfo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildServerInfoRow(
                        l10n.serverUrl,
                        AppConfig.serverInfo['ip']!,
                      ),
                      _buildServerInfoRow(
                        l10n.version,
                        AppConfig.serverInfo['port']!,
                      ),
                      _buildServerInfoRow('Storage S3', AppConfig.storageUrl),
                      _buildServerInfoRow(
                        'Supabase Studio',
                        AppConfig.supabaseStudioUrl,
                      ),
                      _buildServerInfoRow(
                        'Email Testing',
                        AppConfig.inbucketUrl,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Formulario de login
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.password,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
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
                    : Text(l10n.login),
              ),
            ),

            const SizedBox(height: 16),

            // Información adicional
            Text(
              '${l10n.testCredentials}: ${l10n.studentEmail}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // Enlaces útiles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _openUrl(AppConfig.supabaseStudioUrl),
                  icon: const Icon(Icons.dashboard, size: 16),
                  label: Text(l10n.studio),
                ),
                TextButton.icon(
                  onPressed: () => _openUrl(AppConfig.inbucketUrl),
                  icon: const Icon(Icons.email, size: 16),
                  label: Text(l10n.emailLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
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

  void _openUrl(String url) {
    // En una aplicación real, usaríamos url_launcher
    if (kDebugMode) {
      debugPrint('Abrir URL: $url');
    }
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.loading} $url'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;

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
              content: Text(l10n.loginSuccess(AppConfig.platformName)),
              backgroundColor: Colors.green,
            ),
          );

          // Aquí navegaríamos al dashboard según el rol
          if (kDebugMode) {
            debugPrint('Usuario logueado: ${response.user!.email}');
            debugPrint(
              'Rol: ${response.user!.userMetadata?['role'] ?? 'No especificado'}',
            );
          }

          // Mostrar información adicional del usuario
          _showUserInfo(response.user!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.loginError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (kDebugMode) {
        debugPrint('Error de login: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUserInfo(User user) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.loginSuccessTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.emailInfo(user.email ?? '')),
            Text(l10n.idInfo(user.id)),
            Text(
              l10n.roleInfo(
                user.userMetadata?['role'] ?? l10n.roleNotSpecified,
              ),
            ),
            Text(l10n.createdInfo(user.createdAt.toString())),
            const SizedBox(height: 16),
            Text(l10n.nextSteps),
            Text(l10n.navigationRoles),
            Text(l10n.personalDashboard),
            Text(l10n.anteprojectsManagement),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToDashboard(user);
            },
            child: Text(l10n.continueButton),
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
          MaterialPageRoute(builder: (context) => StudentDashboard(user: user)),
        );
        break;
      case 'tutor':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TutorDashboard(user: user)),
        );
        break;
      case 'admin':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminDashboard(user: user)),
        );
        break;
      default:
        // Por defecto, ir al dashboard de estudiante
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => StudentDashboard(user: user)),
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
