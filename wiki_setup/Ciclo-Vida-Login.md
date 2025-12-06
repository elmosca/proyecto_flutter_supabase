# 🔐 Ciclo de Vida del Login - Documentación Técnica

> **Nota:** Este documento forma parte de la sección [Ciclos de Vida](Home#-ciclos-de-vida) de la documentación técnica del proyecto. Para una visión general del sistema, consulta [Arquitectura del Sistema](01-Arquitectura).

Este documento explica detalladamente el funcionamiento completo del ciclo de vida del login en la aplicación, basado en el código fuente real del proyecto. El login es el punto de entrada principal al sistema y establece la base para toda la funcionalidad posterior, incluyendo la autenticación con Supabase, la obtención del perfil del usuario y la navegación al dashboard correspondiente según el rol.

---

## 📋 Tabla de Contenidos

1. [Inicialización de la Aplicación](#1-inicialización-de-la-aplicación)
2. [Verificación de Sesión al Iniciar](#2-verificación-de-sesión-al-iniciar)
3. [Pantalla de Login](#3-pantalla-de-login)
4. [Proceso de Autenticación](#4-proceso-de-autenticación)
5. [Obtención del Perfil del Usuario](#5-obtención-del-perfil-del-usuario)
6. [Navegación al Dashboard](#6-navegación-al-dashboard)
7. [Protección de Rutas](#7-protección-de-rutas)
8. [Gestión de Sesión](#8-gestión-de-sesión)
9. [Logout](#9-logout)
10. [Recuperación de Sesión](#10-recuperación-de-sesión)
11. [Manejo de Multisesiones](#11-manejo-de-multisesiones)

---

## 1. Inicialización de la Aplicación

### 1.1. Punto de Entrada (`main.dart`)

El ciclo de vida comienza en la función `main()` del archivo `frontend/lib/main.dart`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Usar path-based URL strategy en lugar de hash-based
  usePathUrlStrategy();

  // Inicializar Supabase ANTES de construir la app
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}
```

**Referencia de código:**
- Archivo: `frontend/lib/main.dart`
- Líneas: 20-44

### 1.2. Configuración de Supabase

Las credenciales de Supabase se obtienen desde `AppConfig`:

```dart
static String get supabaseUrl {
  // Primero intentar variables de entorno (para CI/CD)
  const envUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  if (envUrl.isNotEmpty) return envUrl;

  // Usar configuración local
  return local.AppConfigLocal.supabaseUrl;
}
```

**Referencia de código:**
- Archivo: `frontend/lib/config/app_config.dart`
- Líneas: 21-40

### 1.3. Construcción de la Aplicación

En `MyApp`, se inicializan los servicios y BLoCs necesarios:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(authService: AuthService()),
    ),
    // ... otros BLoCs
  ],
  child: MaterialApp.router(
    routerConfig: AppRouter.router,
    // ...
  ),
)
```

**Referencia de código:**
- Archivo: `frontend/lib/main.dart`
- Líneas: 112-125

---

## 2. Verificación de Sesión al Iniciar

### 2.1. Verificación Automática

Después de construir la aplicación, se ejecuta una verificación de sesión:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  try {
    final currentPath = Uri.base.path;

    // NO verificar autenticación si estamos en reset-password
    if (currentPath.contains('/reset-password')) {
      return;
    }

    final authBloc = context.read<AuthBloc>();
    authBloc.add(AuthCheckRequested());
  } catch (e) {
    debugPrint('Auth check skipped: $e');
  }
});
```

**Referencia de código:**
- Archivo: `frontend/lib/main.dart`
- Líneas: 129-150

### 2.2. Manejo del Evento `AuthCheckRequested`

El `AuthBloc` procesa la verificación de sesión:

```dart
Future<void> _onAuthCheckRequested(
  AuthCheckRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  try {
    // Verificar si hay una sesión activa en Supabase
    final currentUser = await _authService.getCurrentUserFromSupabase();
    if (currentUser != null) {
      ThemeService.instance.setUser(currentUser);
      emit(AuthAuthenticated(currentUser));
    } else {
      emit(AuthUnauthenticated());
    }
  } catch (e) {
    // Manejar errores
    emit(AuthFailure('Error inesperado: ${e.toString()}'));
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/blocs/auth_bloc.dart`
- Líneas: 207-234

### 2.3. Obtención del Usuario desde Supabase

El servicio `AuthService` verifica la sesión:

```dart
Future<User?> getCurrentUserFromSupabase() async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    // Consultar la tabla users por email
    final response = await _supabase
        .from('users')
        .select()
        .eq('email', user.email!)
        .single();

    // Crear objeto User desde el perfil de la base de datos
    return User(
      id: response['id'] as int,
      email: email,
      fullName: response['full_name'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.name == roleName,
        orElse: () => UserRole.student,
      ),
      // ... otros campos
    );
  } catch (e) {
    return null;
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/auth_service.dart`
- Líneas: 144-192

---

## 3. Pantalla de Login

### 3.1. Componentes de la Pantalla

La pantalla de login se encuentra en `LoginScreenBloc`:

```dart
class LoginScreenBloc extends StatefulWidget {
  const LoginScreenBloc({super.key});

  @override
  State<LoginScreenBloc> createState() => _LoginScreenBlocState();
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/auth/login_screen_bloc.dart`
- Líneas: 17-22

### 3.2. Formulario de Login

El formulario incluye campos para email y contraseña:

```dart
TextField(
  controller: _emailController,
  focusNode: _emailFocus,
  decoration: InputDecoration(
    labelText: l10n.email,
    prefixIcon: const Icon(Icons.email),
  ),
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  onSubmitted: (_) => _passwordFocus.requestFocus(),
),

TextField(
  controller: _passwordController,
  focusNode: _passwordFocus,
  decoration: InputDecoration(
    labelText: l10n.password,
    prefixIcon: const Icon(Icons.lock),
    suffixIcon: IconButton(
      onPressed: () => setState(() {
        _obscurePassword = !_obscurePassword;
      }),
      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
    ),
  ),
  obscureText: _obscurePassword,
  textInputAction: TextInputAction.done,
  onSubmitted: (_) => _handleLogin(),
),
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/auth/login_screen_bloc.dart`
- Líneas: 218-254

### 3.3. Manejo del Login

Cuando el usuario presiona el botón de login o presiona Enter:

```dart
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
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/auth/login_screen_bloc.dart`
- Líneas: 370-381

### 3.4. Listener de Estados

La pantalla escucha los cambios de estado del `AuthBloc`:

```dart
BlocListener<AuthBloc, AuthState>(
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
  // ...
)
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/auth/login_screen_bloc.dart`
- Líneas: 163-181

---

## 4. Proceso de Autenticación

### 4.1. Evento `AuthLoginRequested`

El `AuthBloc` recibe el evento y procesa el login:

```dart
Future<void> _onAuthLoginRequested(
  AuthLoginRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  try {
    final response = await _authService.signIn(
      email: event.email,
      password: event.password,
    );

    if (response['success'] == true && response['user'] != null) {
      final userProfile = _authService.createUserFromLoginResponse(response);
      if (userProfile != null) {
        ThemeService.instance.setUser(userProfile);
        emit(AuthAuthenticated(userProfile));
        if (event.context.mounted) {
          AppRouter.goToDashboard(event.context, userProfile);
        }
      } else {
        emit(const AuthFailure('No se pudo crear el perfil del usuario'));
      }
    } else {
      emit(const AuthFailure('Credenciales inválidas'));
    }
  } catch (e) {
    if (e is AppException) {
      final fallbackMessage = ErrorTranslator.getFallbackMessage(e);
      emit(AuthFailure(fallbackMessage));
    } else {
      emit(AuthFailure('Error inesperado: ${e.toString()}'));
    }
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/blocs/auth_bloc.dart`
- Líneas: 144-183

### 4.2. Autenticación con Supabase Auth

El servicio `AuthService` realiza la autenticación:

```dart
Future<Map<String, dynamic>> signIn({
  required String email,
  required String password,
}) async {
  try {
    print('🔐 Intentando login con Supabase Auth para: $email');

    // Autenticar con Supabase Auth
    final authResponse = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw AuthenticationException(
        'invalid_credentials',
        technicalMessage: 'Authentication failed: user is null',
      );
    }

    print('✅ Login exitoso con Supabase Auth');

    // Obtener el perfil completo del usuario desde la tabla users
    final userProfile = await getCurrentUserProfile();

    if (userProfile == null) {
      throw AuthenticationException(
        'profile_not_found',
        technicalMessage: 'User profile not found after successful authentication',
      );
    }

    // Crear respuesta en el formato esperado
    return {
      'success': true,
      'user': {
        'id': userProfile.id,
        'email': userProfile.email,
        'full_name': userProfile.fullName,
        'role': userProfile.role.name,
        'status': userProfile.status.name,
        'created_at': userProfile.createdAt.toIso8601String(),
        'updated_at': userProfile.updatedAt.toIso8601String(),
      },
    };
  } catch (e) {
    // Interceptar errores de Supabase
    if (SupabaseErrorInterceptor.isSupabaseError(e)) {
      throw SupabaseErrorInterceptor.handleError(e);
    }

    // Interceptar errores de red
    if (NetworkErrorDetector.isNetworkError(e)) {
      throw NetworkErrorDetector.detectNetworkError(e);
    }

    // Error genérico de autenticación
    throw AuthenticationException(
      'authentication_generic',
      technicalMessage: 'Authentication error: $e',
      originalError: e,
    );
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/auth_service.dart`
- Líneas: 68-133

### 4.3. Manejo de Errores

Los errores se interceptan y se traducen:

- **Errores de Supabase**: Se interceptan mediante `SupabaseErrorInterceptor`
- **Errores de red**: Se detectan mediante `NetworkErrorDetector`
- **Errores genéricos**: Se convierten en `AuthenticationException`

---

## 5. Obtención del Perfil del Usuario

### 5.1. Consulta a la Tabla `users`

Después de la autenticación exitosa, se consulta la tabla `users`:

```dart
Future<User?> getCurrentUserProfile() async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    // Buscar el usuario en la tabla users por email
    final response = await _supabase
        .from('users')
        .select('*')
        .eq('email', user.email!);

    if (response.isNotEmpty && response.length == 1) {
      final userData = response.first;
      final userDataMap = {
        'id': userData['id'] is String
            ? int.parse(userData['id'])
            : userData['id'],
        'full_name': userData['full_name'],
        'email': userData['email'],
        'nre': userData['nre'],
        'role': (userData['email'] as String).toLowerCase() == 'admin@jualas.es'
            ? 'admin'
            : userData['role'],
        'phone': userData['phone'],
        'biography': userData['biography'],
        'status': userData['status'],
        'specialty': userData['specialty'],
        'tutor_id': userData['tutor_id'],
        'academic_year': userData['academic_year'],
        'created_at': userData['created_at'],
        'updated_at': userData['updated_at'],
      };

      return User.fromJson(userDataMap);
    }

    // Si no se encuentra en la tabla users, crear un usuario temporal
    return User(
      id: int.tryParse(user.id) ?? 0,
      fullName: user.userMetadata?['full_name'] ?? 'Usuario',
      email: user.email ?? '',
      // ... otros campos por defecto
    );
  } catch (e) {
    print('❌ Error al obtener perfil: $e');
    return null;
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/auth_service.dart`
- Líneas: 220-287

### 5.2. Creación del Objeto User

El objeto `User` se crea desde la respuesta del login:

```dart
User? createUserFromLoginResponse(Map<String, dynamic> loginResponse) {
  try {
    if (loginResponse['success'] == true && loginResponse['user'] != null) {
      final userData = Map<String, dynamic>.from(loginResponse['user']);

      // Asegurar que el ID sea int
      if (userData['id'] is String) {
        userData['id'] = int.parse(userData['id']);
      }

      // Usar los nombres de la base de datos directamente (snake_case)
      final convertedData = <String, dynamic>{
        'id': userData['id'],
        'full_name': userData['full_name'] ?? 'Usuario',
        'email': userData['email'] ?? '',
        'nre': userData['nre'] ?? '',
        'role': userData['role'] ?? 'student',
        // ... otros campos
      };

      // Forzar rol admin para el correo admin@jualas.es
      if ((convertedData['email'] as String).toLowerCase() == 'admin@jualas.es') {
        convertedData['role'] = 'admin';
      }

      return User.fromJson(convertedData);
    }
    return null;
  } catch (e) {
    throw ValidationException(
      'invalid_json',
      technicalMessage: 'Error creating user from login response: $e',
      originalError: e,
    );
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/auth_service.dart`
- Líneas: 292-345

---

## 6. Navegación al Dashboard

### 6.1. Método `goToDashboard`

El router navega al dashboard según el rol del usuario:

```dart
static void goToDashboard(BuildContext context, User user) {
  final route = _getDashboardRoute(user.role);
  debugPrint('🚀 Router: Navegando a dashboard para usuario: ${user.fullName}');
  debugPrint('🚀 Router: Ruta seleccionada: $route');
  debugPrint('🚀 Router: Rol del usuario: ${user.role}');
  context.go(route, extra: user);
}

static String _getDashboardRoute(UserRole role) {
  switch (role) {
    case UserRole.student:
      return '/dashboard/student';
    case UserRole.tutor:
      return '/dashboard/tutor';
    case UserRole.admin:
      return '/dashboard/admin';
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 449-469

### 6.2. Rutas de Dashboard

Las rutas están definidas en el router:

```dart
GoRoute(
  path: '/dashboard/student',
  name: 'student-dashboard',
  builder: (context, state) {
    final user = state.extra as User?;
    if (user == null) {
      return const LoginScreenBloc();
    }
    return StudentDashboardScreen(user: user);
  },
),
GoRoute(
  path: '/dashboard/tutor',
  name: 'tutor-dashboard',
  builder: (context, state) {
    final user = state.extra as User?;
    if (user == null) {
      return const LoginScreenBloc();
    }
    return TutorDashboard(user: user);
  },
),
GoRoute(
  path: '/dashboard/admin',
  name: 'admin-dashboard',
  builder: (context, state) {
    final user = state.extra as User?;
    if (user == null) {
      return const LoginScreenBloc();
    }
    return AdminDashboard(user: user);
  },
),
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 95-137

---

## 7. Protección de Rutas

### 7.1. Redirect en el Router

El router verifica la autenticación antes de permitir el acceso:

```dart
redirect: (context, state) {
  // Redirigir la ruta raíz al login
  if (state.uri.path == '/') {
    return '/login';
  }

  // Excluir /reset-password del redirect
  if (state.uri.path == '/reset-password') {
    return null;
  }

  // Solo redirigir si no estamos en login
  if (state.uri.path != '/login') {
    try {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;

      // Si no estamos autenticados, redirigir a login
      if (authState is! AuthAuthenticated) {
        return '/login';
      }
    } catch (e) {
      // Si hay error leyendo el AuthBloc, ir a login
      return '/login';
    }
  }

  return null; // No redirigir
},
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 35-63

### 7.2. Verificación en Rutas Específicas

Cada ruta también verifica el usuario:

```dart
GoRoute(
  path: '/admin/users',
  name: 'admin-users',
  builder: (context, state) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const LoginScreenBloc();
    }
    final user = authState.user;
    if (user.role != UserRole.admin) {
      return PersistentScaffold(
        title: 'Acceso denegado',
        body: const Center(child: Text('Se requiere rol administrador')),
      );
    }
    return UsersManagementScreen(user: user);
  },
),
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 401-422

---

## 8. Gestión de Sesión

### 8.1. Stream de Cambios de Autenticación

El `AuthBloc` escucha los cambios de estado de Supabase:

```dart
_authService.authStateChanges.listen((supabase.AuthState supabaseAuthState) {
  debugPrint('🔄 Cambio de estado de autenticación: ${supabaseAuthState.event}');

  if (supabaseAuthState.event == supabase.AuthChangeEvent.signedOut) {
    debugPrint('🚪 Usuario deslogueado');
    add(const AuthUserChanged(user: null));
  } else if (supabaseAuthState.event == supabase.AuthChangeEvent.signedIn) {
    debugPrint('🔑 Usuario logueado');
    _authService.getCurrentUserFromSupabase().then((user) {
      if (user != null) {
        ThemeService.instance.setUser(user);
      }
      add(AuthUserChanged(user: user));
    });
  } else if (supabaseAuthState.event == supabase.AuthChangeEvent.tokenRefreshed) {
    debugPrint('🔄 Token refrescado');
    _authService.getCurrentUserFromSupabase().then((user) {
      if (user != null) {
        ThemeService.instance.setUser(user);
      }
      add(AuthUserChanged(user: user));
    });
  }
});
```

**Referencia de código:**
- Archivo: `frontend/lib/blocs/auth_bloc.dart`
- Líneas: 103-142

### 8.2. Propiedades del AuthService

El servicio expone propiedades para acceder al estado de autenticación:

```dart
/// Obtiene el usuario actual autenticado
supabase.User? get currentUser => _supabase.auth.currentUser;

/// Stream de cambios en el estado de autenticación
Stream<supabase.AuthState> get authStateChanges =>
    _supabase.auth.onAuthStateChange;

/// Verifica si el usuario está autenticado
bool get isAuthenticated => currentUser != null;

/// Obtiene el ID del usuario actual
String? get currentUserId => currentUser?.id;

/// Obtiene el email del usuario actual
String? get currentUserEmail => currentUser?.email;
```

**Referencia de código:**
- Archivo: `frontend/lib/services/auth_service.dart`
- Líneas: 48-53, 400-407

---

## 9. Logout

### 9.1. Solicitud de Logout

El logout se solicita mediante un evento:

```dart
Future<void> _onAuthLogoutRequested(
  AuthLogoutRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  try {
    await _authService.signOut();
    // Resetear el tema al logout
    ThemeService.instance.reset();
    emit(AuthUnauthenticated());
  } catch (e) {
    if (e is AppException) {
      final fallbackMessage = ErrorTranslator.getFallbackMessage(e);
      emit(AuthFailure(fallbackMessage));
    } else {
      emit(AuthFailure('Error inesperado: ${e.toString()}'));
    }
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/blocs/auth_bloc.dart`
- Líneas: 185-205

### 9.2. Cierre de Sesión en Supabase

El servicio cierra la sesión:

```dart
Future<void> signOut() async {
  try {
    await _supabase.auth.signOut();
  } catch (e) {
    // Interceptar errores de Supabase
    if (SupabaseErrorInterceptor.isSupabaseError(e)) {
      throw SupabaseErrorInterceptor.handleError(e);
    }

    // Interceptar errores de red
    if (NetworkErrorDetector.isNetworkError(e)) {
      throw NetworkErrorDetector.detectNetworkError(e);
    }

    throw AuthenticationException(
      'session_expired',
      technicalMessage: 'Error during sign out: $e',
      originalError: e,
    );
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/auth_service.dart`
- Líneas: 198-218

### 9.3. Navegación al Login

El router proporciona un método helper para logout:

```dart
static void logout(BuildContext context) {
  try {
    // Primero hacer logout en el AuthBloc
    context.read<AuthBloc>().add(AuthLogoutRequested());

    // Luego navegar a login
    context.go('/login');
  } catch (e) {
    // Si hay error, intentar navegar directamente
    try {
      context.go('/login');
    } catch (e2) {
      // Si todo falla, usar Navigator como fallback
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreenBloc()),
        (route) => false,
      );
    }
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 472-491

---

## 10. Recuperación de Sesión

### 10.1. Persistencia en SharedPreferences

El servicio puede guardar y recuperar la sesión localmente:

```dart
/// Guarda la sesión del usuario en SharedPreferences
Future<void> saveUserSession(User user) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode({
      'id': user.id,
      'email': user.email,
      'full_name': user.fullName,
      'role': user.role.name,
      'status': user.status,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
    });
    await prefs.setString(_sessionKey, userJson);
    print('✅ Sesión guardada en SharedPreferences');
  } catch (e) {
    print('❌ Error guardando sesión: $e');
  }
}

/// Recupera la sesión del usuario desde SharedPreferences
Future<User?> getSavedUserSession() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_sessionKey);

    if (userJson == null) {
      return null;
    }

    final userData = jsonDecode(userJson) as Map<String, dynamic>;
    return User(
      id: (userData['id'] as String).hashCode,
      email: userData['email'] as String,
      fullName: userData['full_name'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.name == userData['role'],
        orElse: () => UserRole.student,
      ),
      // ... otros campos
    );
  } catch (e) {
    print('❌ Error recuperando sesión: $e');
    return null;
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/auth_service.dart`
- Líneas: 444-498

### 10.2. Limpieza de Sesión

```dart
/// Elimina la sesión guardada
Future<void> clearSavedSession() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    print('✅ Sesión eliminada de SharedPreferences');
  } catch (e) {
    print('❌ Error eliminando sesión: $e');
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/auth_service.dart`
- Líneas: 500-509

---

## 11. Manejo de Multisesiones

### 11.1. Concepto de Multisesiones

La aplicación está diseñada para soportar **múltiples usuarios trabajando simultáneamente** en sus proyectos y anteproyectos. Cada usuario tiene su propia sesión independiente y no hay restricciones que impidan el acceso concurrente.

### 11.2. Aislamiento de Sesiones

#### 11.2.1. Tokens JWT Independientes

Cada usuario autenticado recibe su propio token JWT de Supabase Auth:

```dart
// Cada instancia de AuthService obtiene el usuario actual de su sesión
supabase.User? get currentUser => _supabase.auth.currentUser;
```

**Referencia de código:**
- Archivo: `frontend/lib/services/auth_service.dart`
- Líneas: 48-49

#### 11.2.2. Estado Independiente por Usuario

Cada usuario tiene su propia instancia de `AuthBloc` que mantiene su estado de autenticación:

```dart
// El AuthBloc se crea una vez en la aplicación
BlocProvider<AuthBloc>(
  create: (context) => AuthBloc(authService: AuthService()),
),
```

**Referencia de código:**
- Archivo: `frontend/lib/main.dart`
- Líneas: 114-116

### 11.3. Filtrado de Datos por Usuario

#### 11.3.1. Obtención del User ID

Cada servicio obtiene el ID del usuario autenticado antes de realizar consultas:

```dart
// Ejemplo de AnteprojectsService
final user = _supabase.auth.currentUser;
if (user == null) {
  throw AuthenticationException('not_authenticated', ...);
}

// Obtener el ID del usuario desde la tabla users
final userResponse = await _supabase
    .from('users')
    .select('id')
    .eq('email', user.email!)
    .single();

final userId = userResponse['id'] as int;
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 822-829

#### 11.3.2. Filtrado en Consultas

Las consultas se filtran explícitamente por el ID del usuario:

```dart
// Obtener anteproyectos del tutor
final response = await _supabase
    .from('anteprojects')
    .select('*')
    .eq('tutor_id', tutorId)  // Filtro por tutor_id
    .order('created_at', ascending: false);
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 834-851

### 11.4. Row Level Security (RLS)

#### 11.4.1. Políticas RLS en la Base de Datos

Las políticas RLS aseguran que cada usuario solo vea sus propios datos a nivel de base de datos, incluso si el código de la aplicación no filtra correctamente:

```sql
-- Política para anteproyectos
CREATE POLICY "Users can view their own anteprojects" ON anteprojects
    FOR SELECT USING (
        public.user_id() = tutor_id OR 
        EXISTS (
            SELECT 1 FROM anteproject_students 
            WHERE anteproject_id = anteprojects.id 
            AND student_id = public.user_id()
        )
    );
```

**Referencia de código:**
- Archivo: `docs/base_datos/migraciones/20240815000004_configure_rls_fixed.sql`
- Líneas: 141-145

#### 11.4.2. Función `user_id()`

La base de datos obtiene el ID del usuario desde el token JWT:

```sql
CREATE OR REPLACE FUNCTION public.user_id()
RETURNS INT AS $$
BEGIN
    RETURN (current_setting('request.jwt.claims', true)::json->>'user_id')::INT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Referencia de código:**
- Archivo: `docs/base_datos/migraciones/20240815000004_configure_rls_fixed.sql`
- Líneas: 36-41

### 11.5. Ejemplos de Aislamiento por Rol

#### 11.5.1. Estudiantes

Los estudiantes solo ven sus propios anteproyectos y proyectos:

```dart
// Obtener anteproyectos del estudiante
final response = await _supabase
    .from('anteproject_students')
    .select('anteproject_id, anteprojects!inner(*)')
    .eq('student_id', userId);  // Solo anteproyectos del estudiante
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 1093-1099

#### 11.5.2. Tutores

Los tutores ven los anteproyectos y proyectos de sus estudiantes asignados:

```dart
// Obtener anteproyectos del tutor
final response = await _supabase
    .from('anteprojects')
    .select('*')
    .eq('tutor_id', tutorId)  // Solo anteproyectos asignados al tutor
    .order('created_at', ascending: false);
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 834-851

#### 11.5.3. Administradores

Los administradores pueden ver todos los datos según las políticas RLS:

```sql
CREATE POLICY "Admins can view all anteprojects" ON anteprojects
    FOR SELECT USING (public.is_admin());
```

**Referencia de código:**
- Archivo: `docs/base_datos/migraciones/20240815000004_configure_rls_fixed.sql`
- Líneas: 147-148

### 11.6. Sin Bloqueos de Sesión

**Importante**: La aplicación **NO implementa ningún mecanismo de bloqueo** que impida que múltiples usuarios trabajen simultáneamente. Esto significa que:

- ✅ Dos estudiantes pueden trabajar en sus proyectos al mismo tiempo
- ✅ Un tutor puede revisar anteproyectos mientras los estudiantes los editan
- ✅ Múltiples tutores pueden trabajar simultáneamente
- ✅ No hay colas de espera ni locks de sesión

### 11.7. Concurrencia en Operaciones

#### 11.7.1. Escrituras Simultáneas

Cuando múltiples usuarios modifican datos simultáneamente:

1. **Supabase maneja la concurrencia** a nivel de base de datos mediante transacciones
2. **RLS asegura** que cada usuario solo puede modificar sus propios datos o los datos que tiene permiso de modificar
3. **No hay conflictos** porque cada usuario trabaja con su propio conjunto de datos

#### 11.7.2. Ejemplo: Dos Estudiantes Editando

```
Estudiante A (ID: 1)              Estudiante B (ID: 2)
─────────────────                 ─────────────────
1. Login → Token JWT A            1. Login → Token JWT B
2. Consulta anteproyectos         2. Consulta anteproyectos
   → RLS filtra: solo ID 1           → RLS filtra: solo ID 2
3. Edita anteproyecto ID 10       3. Edita anteproyecto ID 20
   → RLS verifica: es suyo            → RLS verifica: es suyo
4. Guarda cambios                4. Guarda cambios
   → Éxito (no hay conflicto)        → Éxito (no hay conflicto)
```

### 11.8. Verificación de Aislamiento

#### 11.8.1. Tests de RLS

Existen tests de integración que verifican que las políticas RLS funcionan correctamente:

```dart
test('RLS policies prevent unauthorized data access', () async {
  // Este test verifica que las políticas RLS están activas
  // y que cada usuario solo ve sus propios datos
});
```

**Referencia de código:**
- Archivo: `frontend/test/integration/rls_integration_test.dart`
- Líneas: 341-383

### 11.9. Resumen de Multisesiones

| Aspecto | Implementación |
|---------|----------------|
| **Sesiones simultáneas** | ✅ Soportadas - Cada usuario tiene su propio token JWT |
| **Aislamiento de datos** | ✅ RLS a nivel de base de datos + filtrado en código |
| **Bloqueos de sesión** | ❌ No implementados - No hay restricciones |
| **Concurrencia** | ✅ Soportada - Supabase maneja transacciones |
| **Identificación de usuario** | Token JWT → `user_id()` en base de datos |
| **Filtrado de consultas** | Por `user_id`, `tutor_id`, `student_id` según rol |

---

## 📊 Diagrama de Flujo

```
┌─────────────────┐
│   main()        │
│  Inicializa     │
│   Supabase      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   MyApp         │
│  Construye      │
│   AuthBloc      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ AuthCheck       │
│ Requested       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────┐
│ ¿Hay sesión?    │ NO   │ LoginScreen  │
└────────┬────────┘─────▶│              │
    SÍ   │                └──────┬───────┘
         │                      │
         ▼                      │
┌─────────────────┐            │
│ AuthAuthenticated│            │
│  Navega a        │            │
│   Dashboard      │            │
└─────────────────┘            │
                                │
                                ▼
                        ┌──────────────┐
                        │ Usuario       │
                        │ ingresa       │
                        │ credenciales  │
                        └──────┬───────┘
                               │
                               ▼
                        ┌──────────────┐
                        │ AuthLogin    │
                        │ Requested    │
                        └──────┬───────┘
                               │
                               ▼
                        ┌──────────────┐
                        │ AuthService  │
                        │ signIn()     │
                        └──────┬───────┘
                               │
                               ▼
                        ┌──────────────┐
                        │ Supabase Auth │
                        │ signInWith   │
                        │ Password     │
                        └──────┬───────┘
                               │
                               ▼
                        ┌──────────────┐
                        │ ¿Autenticado?│ NO
                        └──────┬───────┘
                          SÍ   │
                               │
                               ▼
                        ┌──────────────┐
                        │ getCurrent   │
                        │ UserProfile  │
                        └──────┬───────┘
                               │
                               ▼
                        ┌──────────────┐
                        │ Consulta     │
                        │ tabla users  │
                        └──────┬───────┘
                               │
                               ▼
                        ┌──────────────┐
                        │ Auth         │
                        │ Authenticated│
                        └──────┬───────┘
                               │
                               ▼
                        ┌──────────────┐
                        │ Navega a     │
                        │ Dashboard    │
                        └──────────────┘
```

---

## 📁 Resumen de Archivos Clave

| Archivo | Responsabilidad |
|---------|----------------|
| `frontend/lib/main.dart` | Inicialización de Supabase y construcción de la app |
| `frontend/lib/config/app_config.dart` | Configuración de credenciales de Supabase |
| `frontend/lib/services/auth_service.dart` | Lógica de autenticación con Supabase |
| `frontend/lib/blocs/auth_bloc.dart` | Gestión de estado de autenticación (BLoC) |
| `frontend/lib/screens/auth/login_screen_bloc.dart` | Interfaz de usuario del login |
| `frontend/lib/router/app_router.dart` | Navegación y protección de rutas |
| `frontend/lib/models/user.dart` | Modelo de datos del usuario |

---

## ⚠️ Notas Importantes

1. **Supabase Auth vs Tabla `users`**: La autenticación se realiza con Supabase Auth, pero el perfil completo se obtiene de la tabla `users` en la base de datos.

2. **Manejo de Errores**: Todos los errores se interceptan y se traducen mediante `SupabaseErrorInterceptor` y `NetworkErrorDetector`.

3. **Protección de Rutas**: El router verifica la autenticación en cada navegación mediante el `redirect` y verificaciones en cada ruta.

4. **Persistencia de Sesión**: Supabase maneja automáticamente la persistencia de la sesión. El código también incluye métodos para guardar en `SharedPreferences`, aunque actualmente no se utilizan en el flujo principal.

5. **Stream de Cambios**: El `AuthBloc` escucha los cambios de estado de Supabase mediante `authStateChanges`, lo que permite reaccionar automáticamente a cambios externos (como logout desde otro dispositivo).

6. **Multisesiones**: La aplicación soporta múltiples usuarios trabajando simultáneamente. Cada usuario tiene su propio token JWT y las políticas RLS aseguran el aislamiento de datos. No hay bloqueos de sesión ni restricciones de concurrencia.

---

## 🔗 Enlaces Relacionados

- [Ciclo de Vida del Rol Administrador](Ciclo-Vida-Administrador) (próximamente)
- [Ciclo de Vida del Rol Tutor](Ciclo-Vida-Tutor) (próximamente)
- [Ciclo de Vida del Rol Estudiante](Ciclo-Vida-Estudiante) (próximamente)
- [Arquitectura del Sistema](01-Arquitectura)
- [Base de Datos](02-Base-de-Datos)

---

**📅 Última actualización**: Diciembre 2025  
**📦 Versión**: 1.0  
**✍️ Autor**: Equipo de Desarrollo

