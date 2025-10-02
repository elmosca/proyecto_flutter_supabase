import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'services/anteprojects_service.dart';
import 'services/tasks_service.dart';
import 'blocs/blocs.dart';
import 'config/app_config.dart';
import 'router/app_router.dart';
import 'widgets/error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar SharedPreferences para Flutter Web
  if (kIsWeb) {
    try {
      // Pre-inicializar SharedPreferences para evitar errores
      await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('SharedPreferences initialization warning: $e');
    }
  }

  // Pequeño delay para asegurar que SharedPreferences esté listo
  await Future.delayed(const Duration(milliseconds: 100));

  // Debug de plataforma (solo en desarrollo)
  if (kDebugMode) {
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

  // Inicializar Supabase
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

  @override
  void initState() {
    super.initState();
    // Inicializar el servicio de idioma
    _languageService.initialize();
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
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
