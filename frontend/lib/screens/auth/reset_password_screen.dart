import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../utils/app_exception.dart';
import '../../utils/error_translator.dart';
import '../../utils/url_helper.dart' as url_helper;
import '../../router/app_router.dart';

/// Pantalla para cambiar la contraseña después de recibir el link de reset.
///
/// Puede usarse en dos contextos:
/// - [type] = 'setup': Primera vez estableciendo contraseña (usuario nuevo)
/// - [type] = 'reset': Recuperación de contraseña (usuario existente)
class ResetPasswordScreen extends StatefulWidget {
  final String? type; // 'setup' o 'reset'
  final String? code; // Código de reset de Supabase (query parameter)
  final String? error;
  final String? errorCode;
  final String? errorDescription;

  const ResetPasswordScreen({
    super.key,
    this.type,
    this.code,
    this.error,
    this.errorCode,
    this.errorDescription,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _passwordChanged = false;
  bool _processingToken = true;
  bool _tokenValid = false;

  @override
  void initState() {
    super.initState();

    // Limpiar INMEDIATAMENTE cualquier hash que pueda interferir
    _cleanUrlHash();

    // Pequeño delay para asegurar que la URL se limpió antes de procesar
    Future.microtask(() {
      if (mounted) {
        _processSupabaseToken();
      }
    });
  }

  /// Limpia el hash de la URL que puede interferir con el procesamiento
  void _cleanUrlHash() {
    // Solo ejecutar en web
    if (!kIsWeb) return;
    
    try {
      final currentHash = url_helper.getHash();
      if (currentHash.isNotEmpty &&
          (currentHash == '#/login' ||
              currentHash.contains('#/login') ||
              currentHash.contains('#/'))) {
        final pathname = url_helper.getPathname();
        final search = url_helper.getSearch();

        // debugPrint('🧹 Limpiando hash problemático: $currentHash');
        // debugPrint('🔗 URL actual: ${url_helper.getCurrentUrl()}');
        // debugPrint('🔗 Pathname: $pathname');
        // debugPrint('🔗 Search: $search');

        url_helper.replaceHistoryState(pathname + search);

        // debugPrint('✅ URL limpiada a: ${pathname}${search}');
      }
    } catch (e) {
      // debugPrint('⚠️ Error al limpiar hash: $e');
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Procesa el token de Supabase desde el hash fragment o query parameter de la URL
  Future<void> _processSupabaseToken() async {
    // debugPrint('🔍 Iniciando procesamiento de token...');

    // Limpiar el hash una vez más por si acaso
    _cleanUrlHash();

    // Verificar si hay errores en la URL
    if (widget.error != null || widget.errorCode != null) {
      // debugPrint('❌ Error detectado en URL: ${widget.errorCode}');
      setState(() {
        _processingToken = false;
        _tokenValid = false;

        String errorMsg =
            'Error al procesar el enlace de restablecimiento de contraseña.';

        if (widget.errorCode == 'otp_expired') {
          errorMsg =
              'El enlace ha expirado. Por favor, solicita un nuevo enlace de restablecimiento de contraseña.';
        } else if (widget.errorDescription != null) {
          errorMsg = Uri.decodeComponent(widget.errorDescription!);
        }

        _errorMessage = errorMsg;
      });
      return;
    }

    try {
      final supabaseClient = supabase.Supabase.instance.client;

      // Obtener el code del query parameter
      final code = widget.code;

      // debugPrint('🔗 URL actual: ${url_helper.getCurrentUrl()}');
      // debugPrint(
      //   '🔑 Token/Code recibido: ${code != null ? "✅ Presente" : "❌ Ausente"}',
      // );

      if (code == null || code.isEmpty) {
        // debugPrint('❌ No se encontró el código de reset en la URL');
        setState(() {
          _processingToken = false;
          _tokenValid = false;
          _errorMessage =
              'No se encontró el código de verificación en el enlace. Por favor, solicita un nuevo enlace.';
        });
        return;
      }

      // debugPrint('🔐 Token de recovery recibido');
      // debugPrint('🔍 Code (primeros 10 chars): ${code.substring(0, 10)}...');

      // Construir la URL completa con el formato que Supabase espera
      // Supabase espera: #access_token=xxx&expires_in=3600&refresh_token=xxx&token_type=bearer&type=recovery
      
      // Solo intentar getSessionFromUrl en web
      if (kIsWeb) {
        final currentUrl = url_helper.getCurrentUrl();
        // debugPrint('🔗 URL actual: $currentUrl');

        // Intentar procesar la URL con getSessionFromUrl
        // Si falla por falta de code_verifier, simplemente mostraremos el formulario
        try {
          // debugPrint('🔐 Intentando getSessionFromUrl...');
          await supabaseClient.auth.getSessionFromUrl(Uri.parse(currentUrl));

          // final session = supabaseClient.auth.currentSession;
          // debugPrint(
          //   '📊 Sesión desde URL: ${session != null ? "✅ Presente" : "❌ No presente"}',
          // );
        } catch (urlError) {
          // debugPrint('⚠️ getSessionFromUrl falló: $urlError');
          // debugPrint('ℹ️ Esto es esperado si el enlace no tiene el formato completo');
        }
      }

      // Verificar si hay sesión activa (puede haber sido creada por getSessionFromUrl)
      final session = supabaseClient.auth.currentSession;
      // debugPrint(
      //   '📊 Sesión final: ${session != null ? "✅ Presente" : "❌ No presente"}',
      // );

      // Mostrar el formulario independientemente de si hay sesión o no
      // La sesión será necesaria cuando se intente cambiar la contraseña
      if (session != null && session.user.email != null) {
        // debugPrint('✅ Sesión encontrada - usuario: ${session.user.email}');
      } else {
        // debugPrint('⚠️ No hay sesión activa');
        // debugPrint(
        //   'ℹ️ El usuario verá el formulario pero necesitará seguir el enlace correctamente',
        // );
      }

      // Siempre mostrar el formulario si hay un code válido
      setState(() {
        _processingToken = false;
        _tokenValid = true; // Mostrar formulario
        _errorMessage = null;
      });

      // Limpiar la URL eliminando query parameters y hash fragments (solo en web)
      if (kIsWeb) {
        final pathname = url_helper.getPathname();
        final cleanUrl =
            '$pathname${widget.type != null ? '?type=${widget.type}' : ''}';
        url_helper.replaceHistoryState(cleanUrl);

        // debugPrint('🔗 URL final limpia: $cleanUrl');
      }
      
      // debugPrint('✅ Formulario de cambio de contraseña listo');
    } catch (e) {
      // debugPrint('❌ Error al procesar token: $e');

      // Mensajes de error más específicos
      String errorMessage = 'Error al procesar el enlace';

      if (e.toString().contains('expired') ||
          e.toString().contains('invalid')) {
        errorMessage =
            'El enlace ha expirado o es inválido. Por favor, solicita un nuevo enlace de recuperación.';
      } else if (e.toString().contains('Code verifier')) {
        errorMessage =
            'Error de verificación. Por favor, solicita un nuevo enlace de recuperación.';
      } else {
        errorMessage = 'Error al procesar el enlace: ${e.toString()}';
      }

      setState(() {
        _processingToken = false;
        _tokenValid = false;
        _errorMessage = errorMessage;
      });
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.passwordsDoNotMatch;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.updatePassword(_passwordController.text);

      if (mounted) {
        setState(() {
          _passwordChanged = true;
          _isLoading = false;
        });

        // Esperar un momento y luego redirigir al login
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          AppRouter.goToLogin(context);
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e is AppException
            ? ErrorTranslator.getFallbackMessage(e)
            : 'Error al cambiar la contraseña: $e';
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
      }
    }
  }

  bool get _isFirstTimeSetup => widget.type == 'setup';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFirstTime = _isFirstTimeSetup;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFirstTime ? l10n.setupPassword : l10n.resetPassword),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _processingToken
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Procesando enlace de restablecimiento...'),
                            ],
                          ),
                        ),
                      )
                    : !_tokenValid
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Error en el enlace',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              AppRouter.goToLogin(context);
                            },
                            child: const Text('Volver al inicio de sesión'),
                          ),
                        ],
                      )
                    : _passwordChanged
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.passwordChanged,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Redirigiendo al login...',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              isFirstTime ? Icons.lock_open : Icons.lock_reset,
                              size: 48,
                              color: const Color(0xFF2196F3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isFirstTime
                                  ? l10n.setupPassword
                                  : l10n.resetPassword,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isFirstTime
                                  ? l10n.setupPasswordInstructions
                                  : l10n.resetPasswordInstructions,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: l10n.newPassword,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.passwordRequired;
                                }
                                if (value.length < 6) {
                                  return l10n.passwordTooShort;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: l10n.confirmNewPassword,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _changePassword(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.passwordRequired;
                                }
                                if (value != _passwordController.text) {
                                  return l10n.passwordsDoNotMatch;
                                }
                                return null;
                              },
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(l10n.changePassword),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
