import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'l10n/app_localizations.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'services/anteprojects_service.dart';
import 'services/tasks_service.dart';
import 'services/deep_link_service.dart';
import 'blocs/blocs.dart';
import 'config/app_config.dart';
import 'router/app_router.dart';
import 'widgets/error_boundary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Usar path-based URL strategy en lugar de hash-based
  // Esto previene que aparezcan URLs como /#/login
  // y permite URLs limpias como /reset-password
  usePathUrlStrategy();

  // Inicializar Supabase ANTES de construir la app
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    if (kDebugMode) {
      debugPrint('✅ Supabase inicializado correctamente');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Error inicializando Supabase: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LanguageService _languageService = LanguageService.instance;
  final ThemeService _themeService = ThemeService.instance;
  final DeepLinkService _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _initLanguage();
    _initDeepLinks();
  }

  Future<void> _initLanguage() async {
    await _languageService.initialize();
  }

  Future<void> _initDeepLinks() async {
    // Solo en desktop/mobile, no en web
    if (!kIsWeb) {
      await _deepLinkService.initialize();
      
      // Manejar deep links entrantes
      _deepLinkService.onLinkReceived = (Uri uri) {
        debugPrint('🔗 Deep link recibido en App: $uri');
        _handleDeepLink(uri);
      };
    }
  }

  void _handleDeepLink(Uri uri) {
    // Navegar según el path del deep link
    if (uri.host == 'reset-password' || uri.path.contains('reset-password')) {
      final code = uri.queryParameters['code'];
      final type = uri.queryParameters['type'];
      
      debugPrint('🔐 Navegando a reset-password con code: $code, type: $type');
      
      // Usar el router para navegar
      AppRouter.router.go(
        '/reset-password',
        extra: {
          'code': code,
          'type': type,
        },
      );
    }
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([_languageService, _themeService]),
    builder: (context, child) {
      // Forzar reconstrucción cuando cambia el idioma o tema
      return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authService: AuthService()),
          ),
          BlocProvider<AnteprojectsBloc>(
            create: (context) =>
                AnteprojectsBloc(anteprojectsService: AnteprojectsService()),
          ),
          BlocProvider<TasksBloc>(
            create: (context) => TasksBloc(tasksService: TasksService()),
          ),
        ],
        child: Builder(
          builder: (context) {
            // Verificar sesión después de que el MultiBlocProvider esté construido
            // EXCEPTO si estamos en /reset-password (sesión temporal)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                // Obtener la ruta actual
                final currentPath = Uri.base.path;

                // NO verificar autenticación si estamos en reset-password
                // porque puede tener una sesión temporal que no debe redirigir al dashboard
                if (currentPath.contains('/reset-password')) {
                  if (kDebugMode) {
                    debugPrint('⏭️ Auth check omitido - en reset-password');
                  }
                  return;
                }

                final authBloc = context.read<AuthBloc>();
                authBloc.add(AuthCheckRequested());
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('Auth check skipped: $e');
                }
              }
            });

            return MaterialApp.router(
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

              theme: _themeService.currentTheme,
              routerConfig: AppRouter.router,

              // Configuración adicional para internacionalización
              debugShowCheckedModeBanner: false,

              // Manejo de errores global
              builder: (context, child) {
                return ErrorBoundary(child: child ?? const SizedBox.shrink());
              },
            );
          },
        ),
      );
    },
  );
}
