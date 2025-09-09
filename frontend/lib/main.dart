import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'l10n/app_localizations.dart';
import 'services/language_service.dart';
import 'services/auth_service.dart';
import 'services/anteprojects_service.dart';
import 'services/tasks_service.dart';
import 'blocs/blocs.dart';
import 'config/app_config.dart';
import 'router/app_router.dart';

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

  // Solo inicializar Supabase si no estamos en modo test
  if (!kIsWeb || !const bool.fromEnvironment('dart.vm.product')) {
    try {
      // Configuración de Supabase para servidor de red
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
    } catch (e) {
      // En caso de error, continuar sin Supabase (útil para tests)
      if (kDebugMode) {
        debugPrint('⚠️ Supabase initialization failed: $e');
      }
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
  late LanguageService _languageService;

  @override
  void initState() {
    super.initState();
    _languageService = LanguageService();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _languageService,
    builder: (context, child) => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: AuthService(),
          ),
        ),
        BlocProvider<AnteprojectsBloc>(
          create: (context) => AnteprojectsBloc(
            anteprojectsService: AnteprojectsService(),
          ),
        ),
        BlocProvider<TasksBloc>(
          create: (context) => TasksBloc(
            tasksService: TasksService(),
          ),
        ),
      ],
      child: MaterialApp.router(
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
        routerConfig: AppRouter.router,
      ),
    ),
  );
}
