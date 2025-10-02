import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../models/user.dart' as app_user;

class LoginScreenBloc extends StatefulWidget {
  const LoginScreenBloc({super.key});

  @override
  State<LoginScreenBloc> createState() => _LoginScreenBlocState();
}

class _LoginScreenBlocState extends State<LoginScreenBloc> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // ✅ _showServerInfo variable removed (no longer used)

  @override
  void initState() {
    super.initState();
    // Email and password fields will be empty for user to complete
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Si las localizaciones no están disponibles, usar valores por defecto
    if (l10n == null) {
      return const Scaffold(
        body: Center(child: Text('Cargando aplicación...')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login), // ✅ Only "Login" in production
        backgroundColor: const Color(AppConfig.platformColor),
        foregroundColor: Colors.white,
        actions: [
          // Language change button
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: l10n.language,
            onSelected: (String value) {
              // Here we would implement language change
              if (AppConfig.debugMode) {
                debugPrint('Change language to: $value');
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
          // ✅ Server info button removed for production
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
            // Navigate to corresponding dashboard
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
                // Application information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
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

                // ✅ Server information section removed for production
                const SizedBox(height: 32),

                // Login form
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

                // Login button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppConfig.platformColor),
                          foregroundColor: Colors.white,
                        ),
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(l10n.login),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Credenciales de prueba para evaluadores
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.security, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Credenciales de Prueba para Evaluadores - V2',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Administrador
                        _buildCredentialRow(
                          context,
                          '👨‍💼 Administrador',
                          'admin@jualas.es',
                          'password123',
                          Colors.purple,
                        ),
                        const SizedBox(height: 12),

                        // Tutor
                        _buildCredentialRow(
                          context,
                          '👨‍🏫 Tutor',
                          'jualas@jualas.es',
                          'password123',
                          Colors.green,
                        ),
                        const SizedBox(height: 12),

                        // Estudiante
                        _buildCredentialRow(
                          context,
                          '👨‍🎓 Estudiante',
                          '3850437@alu.murciaeduca.es',
                          'student123',
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),

                        // Estudiante de prueba
                        _buildCredentialRow(
                          context,
                          '👨‍🎓 Estudiante de Prueba',
                          'student.test@alumno.cifpcarlos3.es',
                          'student123',
                          Colors.blue.shade300,
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ Development links removed for production
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ _buildServerInfoRow method removed (no longer used)

  // ✅ _openUrl method removed (no longer used in production)

  void _handleLogin() {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
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
        context.go('/dashboard/student', extra: user);
        break;
      case app_user.UserRole.tutor:
        context.go('/dashboard/tutor', extra: user);
        break;
      case app_user.UserRole.admin:
        context.go('/dashboard/admin', extra: user);
        break;
    }
  }

  Widget _buildCredentialRow(
    BuildContext context,
    String title,
    String email,
    String password,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          // Email
          Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text(
                  'Email:',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _copyToClipboard(context, email),
                icon: const Icon(Icons.copy, size: 16),
                tooltip: 'Copiar email',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Password
          Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text(
                  'Pass:',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    password,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _copyToClipboard(context, password),
                icon: const Icon(Icons.copy, size: 16),
                tooltip: 'Copiar contraseña',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiado: $text'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
