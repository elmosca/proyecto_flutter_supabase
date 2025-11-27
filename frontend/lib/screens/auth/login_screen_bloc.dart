import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../models/user.dart' as app_user;
import '../../router/app_router.dart';
import '../../widgets/dialogs/forgot_password_dialog.dart';

/// Pantalla de login basada en BLoC.
///
/// Muestra un formulario de acceso con email y contraseña, reacciona a los
/// estados de `AuthBloc` y navega al dashboard correspondiente cuando el
/// usuario se autentica. Gestiona accesibilidad (focus), alterna visibilidad
/// de contraseña y presenta mensajes de error/success mediante SnackBars.
class LoginScreenBloc extends StatefulWidget {
  const LoginScreenBloc({super.key});

  @override
  State<LoginScreenBloc> createState() => _LoginScreenBlocState();
}

class _LoginScreenBlocState extends State<LoginScreenBloc> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  // ✅ _showServerInfo variable removed (no longer used)

  // Usuarios de prueba - Solo del dominio jualas.es
  static const List<TestUser> _testUsers = [
    TestUser(
      email: 'admin@jualas.es',
      password: 'password123',
      name: 'Administrador',
      role: 'Admin',
      color: Colors.red,
      icon: Icons.admin_panel_settings,
    ),
    TestUser(
      email: 'jualas@jualas.es',
      password: 'password123',
      name: 'Tutor Jualas',
      role: 'Tutor',
      color: Colors.green,
      icon: Icons.person,
    ),
    TestUser(
      email: 'laura.sanchez@jualas.es',
      password: 'EzmvfdQmijMa',
      name: 'Laura Sánchez Pérez',
      role: 'Estudiante',
      color: Colors.blue,
      icon: Icons.school,
    ),
    TestUser(
      email: 'miguel.torres@jualas.es',
      password: 'dmAzgm2dJlNV',
      name: 'Miguel Torres García',
      role: 'Estudiante',
      color: Colors.blue,
      icon: Icons.school,
    ),
    TestUser(
      email: 'sofia.ramirez@jualas.es',
      password: '0lDs9o5n3U&m',
      name: 'Sofía Ramírez López',
      role: 'Estudiante',
      color: Colors.blue,
      icon: Icons.school,
    ),
    TestUser(
      email: 'diego.fernandez@jualas.es',
      password: 'Tn2ZCbt3L3W9',
      name: 'Diego Fernández Martínez',
      role: 'Estudiante',
      color: Colors.blue,
      icon: Icons.school,
    ),
    TestUser(
      email: 'elena.moreno@jualas.es',
      password: r'Iia*IX%$zAl3',
      name: 'Elena Moreno Ruiz',
      role: 'Estudiante',
      color: Colors.blue,
      icon: Icons.school,
    ),
    TestUser(
      email: 'pablo.jimenez@jualas.es',
      password: 'knCOcimmcPWR',
      name: 'Pablo Jiménez Sánchez',
      role: 'Estudiante',
      color: Colors.blue,
      icon: Icons.school,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Scaffold(
        body: Center(child: Text('Cargando aplicación...')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
        backgroundColor: const Color(AppConfig.platformColor),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: l10n.language,
            onSelected: (String value) {
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
                const SizedBox(height: 32),

                // Email
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 16),

                // Password con toggle y Enter
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() {
                        _obscurePassword = !_obscurePassword;
                      }),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 8),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ForgotPasswordDialog(),
                      );
                    },
                    child: Text(l10n.forgotPassword),
                  ),
                ),

                const SizedBox(height: 16),

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

                // Sección de usuarios de prueba
                Card(
                  color: Colors.grey.shade100,
                  child: ExpansionTile(
                    leading: const Icon(Icons.people_outline),
                    title: const Text(
                      'Usuarios de Prueba',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Haz clic para rellenar o mantener para copiar',
                      style: TextStyle(fontSize: 12),
                    ),
                    initiallyExpanded: false,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: _testUsers.map((user) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: _TestUserButton(
                                user: user,
                                onTap: () {
                                  _emailController.text = user.email;
                                  _passwordController.text = user.password;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Credenciales de ${user.name} cargadas',
                                      ),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: user.color,
                                    ),
                                  );
                                },
                                onLongPress: () async {
                                  await Clipboard.setData(
                                    ClipboardData(
                                      text:
                                          'Email: ${user.email}\nContraseña: ${user.password}',
                                    ),
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Credenciales de ${user.name} copiadas al portapapeles',
                                        ),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: user.color,
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    debugPrint(
      '🚀 Login: Navegando a dashboard para usuario: ${user.fullName}',
    );
    debugPrint('🚀 Login: Rol del usuario: ${user.role}');
    AppRouter.goToDashboard(context, user);
  }
}

/// Modelo para usuarios de prueba
class TestUser {
  final String email;
  final String password;
  final String name;
  final String role;
  final Color color;
  final IconData icon;

  const TestUser({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    required this.color,
    required this.icon,
  });
}

/// Widget para botón de usuario de prueba
class _TestUserButton extends StatelessWidget {
  final TestUser user;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TestUserButton({
    required this.user,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: user.color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(user.icon, color: user.color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role,
                style: TextStyle(
                  fontSize: 10,
                  color: user.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
