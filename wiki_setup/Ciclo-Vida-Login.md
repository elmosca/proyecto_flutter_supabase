# Cómo Funciona el Login

Aquí voy a explicar cómo funciona el proceso de login de la app, desde que el usuario abre la aplicación hasta que entra en su dashboard. Es una parte clave, porque se encarga de la autenticación con Supabase y de cargar el perfil correcto para cada tipo de usuario (admin, tutor o estudiante).

> Si necesitas una visión más general de la arquitectura, puedes consultar la página de [Arquitectura del Sistema](01-Arquitectura).

## Índice

1.  Arranque de la app
2.  Verificación de sesión
3.  Pantalla de login
4.  Proceso de autenticación
5.  Obtención del perfil de usuario
6.  Navegación al dashboard
7.  Protección de rutas
8.  Gestión de sesión
9.  Logout

---

## 1. Arranque de la App

### 1.1. Punto de entrada: `main.dart`

Todo empieza, como siempre, en la función `main()` que está en `frontend/lib/main.dart`.

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

Lo primero que hacemos aquí es inicializar Flutter y luego Supabase. Es importante hacerlo en este orden, porque si no, la app intentaría usar Supabase antes de que esté listo y daría un error.

### 1.2. Configuración de Supabase

Las credenciales de Supabase se cargan desde `AppConfig`. Este archivo está preparado para funcionar tanto en local como en producción (CI/CD), ya que primero intenta leer las variables de entorno y, si no las encuentra, usa las locales.

```dart
static String get supabaseUrl {
  // Primero intentar variables de entorno (para CI/CD)
  const envUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  if (envUrl.isNotEmpty) return envUrl;

  // Usar configuración local
  return local.AppConfigLocal.supabaseUrl;
}
```

### 1.3. Construcción de la Aplicación

En `MyApp`, inicializamos los BLoCs que vamos a necesitar en toda la app. El más importante para el login es el `AuthBloc`.

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

---

## 2. Verificación de Sesión

### 2.1. Verificación automática al arrancar

Justo después de que la app se construye, comprobamos si ya hay una sesión activa. Esto lo hacemos con `addPostFrameCallback` para asegurarnos de que el `context` está disponible.

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  try {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(AuthCheckRequested());
  } catch (e) {
    debugPrint('Auth check skipped: $e');
  }
});
```

### 2.2. Manejo del evento `AuthCheckRequested`

El `AuthBloc` recibe este evento y se encarga de verificar la sesión. Si hay un usuario en Supabase, lo recupera y emite un estado `AuthAuthenticated`. Si no, emite `AuthUnauthenticated`.

```dart
Future<void> _onAuthCheckRequested(
  AuthCheckRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  try {
    final currentUser = await _authService.getCurrentUserFromSupabase();
    if (currentUser != null) {
      emit(AuthAuthenticated(currentUser));
    } else {
      emit(AuthUnauthenticated());
    }
  } catch (e) {
    emit(AuthFailure('Error inesperado: ${e.toString()}'));
  }
}
```

### 2.3. Obtención del usuario desde Supabase

El `AuthService` es el que habla con Supabase. El método `getCurrentUserFromSupabase()` no solo recupera el usuario de `_supabase.auth.currentUser`, sino que también hace una consulta a nuestra tabla `users` para traer el perfil completo (rol, nombre, etc.).

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
    return User.fromJson(response);
  } catch (e) {
    return null;
  }
}
```

---

## 3. Pantalla de Login

### 3.1. Formulario de login

La pantalla de login (`LoginScreenBloc`) es bastante estándar. Tiene dos `TextField` para el email y la contraseña, y un botón para iniciar sesión.

Cuando el usuario pulsa el botón, se llama a la función `_handleLogin()`:

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

### 3.2. Listener de estados

La pantalla escucha los cambios de estado del `AuthBloc`. Si el estado es `AuthFailure`, muestra un `SnackBar` con el error. Si es `AuthAuthenticated`, muestra un mensaje de éxito y navega al dashboard.

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
      _navigateToDashboard(state.user);
    }
  },
  // ...
)
```

---

## 4. Proceso de Autenticación

### 4.1. Evento `AuthLoginRequested`

El `AuthBloc` recibe el evento y llama al método `signIn()` del `AuthService`.

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
    // ... manejo de errores
  }
}
```

### 4.2. Autenticación con Supabase Auth

El `AuthService` es el que finalmente llama a Supabase para autenticar al usuario.

```dart
Future<Map<String, dynamic>> signIn({
  required String email,
  required String password,
}) async {
  try {
    // Autenticar con Supabase Auth
    final authResponse = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw AuthenticationException('invalid_credentials');
    }

    // ... obtener perfil de la tabla users

    return {
      'success': true,
      'user': userProfile,
    };
  } catch (e) {
    // ... manejo de errores
  }
}
```

---

## 5. Obtención del Perfil de Usuario

Una vez que Supabase confirma que el email y la contraseña son correctos, necesitamos obtener el perfil completo del usuario desde nuestra tabla `users`. Esto es importante porque ahí es donde guardamos el rol (`admin`, `tutor` o `student`).

El método `_getUserProfile()` del `AuthService` se encarga de esto:

```dart
Future<Map<String, dynamic>?> _getUserProfile(String email) async {
  try {
    final response = await _supabase
        .from('users')
        .select()
        .eq('email', email)
        .single();
    return response;
  } catch (e) {
    return null;
  }
}
```

---

## 6. Navegación al Dashboard

Una vez que tenemos el perfil del usuario, el `AppRouter` se encarga de redirigirlo al dashboard correcto según su rol.

```dart
static void goToDashboard(BuildContext context, User user) {
  final route = _getDashboardRoute(user.role);
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

---

## 7. Protección de Rutas

Para evitar que un usuario no autenticado acceda a rutas protegidas, el `AppRouter` tiene un `redirect` que comprueba el estado de autenticación. Si el usuario no está autenticado, lo redirige a `/login`.

```dart
redirect: (context, state) {
  // ...
  if (state.uri.path != '/login') {
    try {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;

      if (authState is! AuthAuthenticated) {
        return '/login';
      }
    } catch (e) {
      return '/login';
    }
  }
  return null;
},
```

Además, cada ruta específica también comprueba el rol del usuario para evitar que, por ejemplo, un estudiante acceda al dashboard de administrador.

---

## 8. Gestión de Sesión

El `AuthBloc` escucha los cambios de estado de autenticación de Supabase. Esto es útil para manejar casos como el refresco de token o si la sesión se cierra desde otro dispositivo.

```dart
_authService.authStateChanges.listen((supabase.AuthState supabaseAuthState) {
  if (supabaseAuthState.event == supabase.AuthChangeEvent.signedOut) {
    add(const AuthUserChanged(user: null));
  } else if (supabaseAuthState.event == supabase.AuthChangeEvent.signedIn) {
    // ...
  }
});
```

---

## 9. Logout

El proceso de logout es sencillo:

1.  Se envía un evento `AuthLogoutRequested` al `AuthBloc`.
2.  El `AuthBloc` llama al método `signOut()` del `AuthService`.
3.  El `AuthService` llama a `_supabase.auth.signOut()`.
4.  El `AuthBloc` emite un estado `AuthUnauthenticated`.
5.  El router redirige al usuario a la pantalla de login.

```dart
static void logout(BuildContext context) {
  try {
    context.read<AuthBloc>().add(AuthLogoutRequested());
    context.go('/login');
  } catch (e) {
    // ...
  }
}
```
