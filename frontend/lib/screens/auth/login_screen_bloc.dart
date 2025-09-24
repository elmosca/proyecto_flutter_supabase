import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../models/user.dart' as app_user;
import '../../widgets/test_credentials_widget.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login), // ✅ Only "Login" in production
        backgroundColor: Color(AppConfig.platformColor),
        foregroundColor: Colors.white,
        actions: [
          // Language change button
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: l10n.language,
            onSelected: (String value) {
              // Here we would implement language change
              if (kDebugMode) {
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
                content: Text('${AppLocalizations.of(context)!.loginSuccessTitle}: ${state.user.email}'),
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

              // Credenciales de prueba para testing
              const TestCredentialsWidget(),

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
}
