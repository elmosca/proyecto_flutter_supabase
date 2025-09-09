import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../screens/dashboard/student_dashboard.dart';
import '../../screens/dashboard/tutor_dashboard.dart';
import '../../screens/dashboard/admin_dashboard.dart';
import '../../models/user.dart' as app_user;

class LoginScreenBloc extends StatefulWidget {
  const LoginScreenBloc({super.key});

  @override
  State<LoginScreenBloc> createState() => _LoginScreenBlocState();
}

class _LoginScreenBlocState extends State<LoginScreenBloc> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showServerInfo = false;

  @override
  void initState() {
    super.initState();
    // Usar credenciales de prueba por defecto
    _emailController.text = AppConfig.testCredentials['student']!;
    _passwordController.text = AppConfig.testCredentials['student_password']!;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              // Aquí implementaríamos el cambio de idioma
              if (kDebugMode) {
                debugPrint('Cambiar idioma a: $value');
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
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.loginSuccessTitle}: ${state.user.email}'),
                backgroundColor: Colors.green,
              ),
            );
            // Navegar al dashboard correspondiente
            _navigateToDashboard(state.user);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Información de la aplicación
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school,
                        size: 48,
                        color: Color(AppConfig.platformColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistema TFG',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'CIFP Carlos III - DAM',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Información de plataforma
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        AppConfig.platformIcon,
                        style: const TextStyle(fontSize: 24),
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
                          AppConfig.supabaseUrl,
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

              const SizedBox(height: 32),
              
              // Formulario de login
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
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
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppConfig.platformColor),
                        foregroundColor: Colors.white,
                      ),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(l10n.login),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Información adicional
              Text(
                '${l10n.testCredentials}: ${l10n.studentEmail}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
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

  void _handleLogin() {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          context: context,
        ),
      );
    }
  }

  void _navigateToDashboard(app_user.User user) {
    final role = user.role;

    switch (role) {
      case app_user.UserRole.student:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => StudentDashboard(user: user)),
        );
        break;
      case app_user.UserRole.tutor:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TutorDashboard(user: user)),
        );
        break;
      case app_user.UserRole.admin:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminDashboard(user: user)),
        );
        break;
    }
  }
}
