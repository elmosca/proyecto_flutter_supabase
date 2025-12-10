# Ciclo de Vida del Rol Administrador - Documentación Técnica

Este documento explica detalladamente el funcionamiento completo del ciclo de vida del rol **Administrador** en la aplicación, basado en el código fuente real del proyecto.

## Tabla de Contenidos

1. [Acceso al Dashboard](#1-acceso-al-dashboard)
2. [Inicialización del Dashboard](#2-inicialización-del-dashboard)
3. [Gestión de Usuarios](#3-gestión-de-usuarios)
4. [Supervisión del Sistema](#4-supervisión-del-sistema)
5. [Flujo de Aprobación](#5-flujo-de-aprobación)
6. [Configuración del Sistema](#6-configuración-del-sistema)
7. [Navegación y Rutas](#7-navegación-y-rutas)
8. [Permisos y Seguridad](#8-permisos-y-seguridad)

---

## 1. Acceso al Dashboard

### 1.1. Navegación Post-Login

Después de un login exitoso, el sistema redirige al administrador a su dashboard específico:

```dart
static void goToDashboard(BuildContext context, User user) {
  final route = _getDashboardRoute(user.role);
  // Para admin: '/dashboard/admin'
  context.go(route, extra: user);
}

static String _getDashboardRoute(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/dashboard/admin';
    // ...
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 449-469

### 1.2. Construcción del Dashboard

El dashboard del administrador se construye con el usuario autenticado:

```dart
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
- Líneas: 123-137

---

## 2. Inicialización del Dashboard

### 2.1. Componente Principal

El dashboard del administrador es un `StatefulWidget` que carga datos al inicializarse:

```dart
class AdminDashboard extends StatefulWidget {
  final User user;
  final AdminStatsRepository statsService;

  AdminDashboard({
    super.key,
    required this.user,
    AdminStatsRepository? statsService,
  }) : statsService = statsService ?? AdminStatsService();
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/admin_dashboard.dart`
- Líneas: 14-26

### 2.2. Carga de Datos Iniciales

Al montar el widget, se cargan las estadísticas del sistema y los usuarios recientes:

```dart
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  try {
    setState(() {
      _isLoading = true;
    });

    // Cargar datos en paralelo
    final futures = await Future.wait([
      widget.statsService.getSystemStats(),
      widget.statsService.getRecentUsers(),
    ]);

    if (mounted) {
      setState(() {
        _stats = futures[0] as AdminStats;
        _recentUsers = futures[1] as List<User>;
        _isLoading = false;
      });
    }
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/admin_dashboard.dart`
- Líneas: 36-70

### 2.3. Estadísticas del Sistema

El dashboard muestra métricas clave del sistema:

- **Total de usuarios**: Número total de usuarios registrados
- **Proyectos activos**: Número de anteproyectos activos
- **Total de tutores**: Número de tutores en el sistema

```dart
Widget _buildStatistics() {
  return Row(
    children: [
      Expanded(
        child: _buildStatCard(
          l10n.totalUsers,
          _stats?.totalUsers.toString() ?? '0',
          Icons.people,
          Colors.blue,
          onTap: _viewAllUsers,
        ),
      ),
      // ... más tarjetas de estadísticas
    ],
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/admin_dashboard.dart`
- Líneas: 169-205

---

## 3. Gestión de Usuarios

### 3.1. Acceso a la Gestión de Usuarios

El administrador puede acceder a la gestión de usuarios desde el dashboard:

```dart
void _manageUsers() {
  context.go('/admin/users', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/admin_dashboard.dart`
- Líneas: 534-536

### 3.2. Pantalla de Gestión de Usuarios

La pantalla `UsersManagementScreen` permite gestionar todos los usuarios del sistema:

```dart
class UsersManagementScreen extends StatefulWidget {
  final User user;
  const UsersManagementScreen({super.key, required this.user});
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/admin/users_management_screen.dart`
- Líneas: 13-19

### 3.3. Carga de Usuarios

La pantalla carga tutores y estudiantes por separado:

```dart
Future<void> _loadLists() async {
  final tutors = await _service.getUsers(
    role: 'tutor',
    academicYear: _selectedYear,
  );
  final students = await _service.getUsers(
    role: 'student',
    academicYear: _selectedYear,
  );
  if (mounted) {
    setState(() {
      _tutors = tutors;
      _students = students;
    });
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/admin/users_management_screen.dart`
- Líneas: 57-72

### 3.4. Creación de Tutores

El administrador puede crear tutores mediante un formulario:

```dart
Future<void> _createTutor() async {
  if (!mounted) return;
  await showDialog(
    context: context,
    builder: (context) => Dialog(
      child: SingleChildScrollView(
        child: TutorCreationForm(
          onTutorCreated: (result) async {
            await _loadLists();
            if (mounted && context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    ),
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/admin/users_management_screen.dart`
- Líneas: 74-91

El servicio `UserManagementService` crea el tutor mediante una función RPC:

```dart
Future<Map<String, dynamic>> createTutor({
  required String email,
  required String password,
  required String fullName,
  String? specialty,
  String? phone,
}) async {
  final response = await _supabase.rpc(
    'create_tutor',
    params: {
      'tutor_email': email,
      'tutor_password': password,
      'tutor_full_name': fullName,
      'tutor_specialty': specialty,
      'tutor_phone': phone,
    },
  );
  return response;
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/user_management_service.dart`
- Líneas: 60-100

### 3.5. Importación Masiva de Estudiantes

El administrador puede importar estudiantes desde un archivo CSV:

```dart
Future<void> _importStudentsFromCSV() async {
  if (!mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const ImportStudentsCSVScreen(tutorId: null),
    ),
  );
  // Recargar listas después de importar
  if (mounted) {
    await _loadLists();
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/admin/users_management_screen.dart`
- Líneas: 93-104

La importación masiva utiliza una Edge Function de Supabase para crear usuarios en lote:

```dart
Future<Map<String, dynamic>> bulkCreateStudents({
  required List<Map<String, dynamic>> students,
  int? tutorId,
}) async {
  final response = await _supabase.functions
      .invoke(
        'super-action',
        body: {
          'action': 'bulk_create_students',
          'students': students,
          'tutor_id': tutorId,
        },
      )
      .timeout(const Duration(minutes: 5));
  // ...
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/user_management_service.dart`
- Líneas: 131-200 (aproximadamente)

### 3.6. Edición de Usuarios

El administrador puede editar cualquier usuario del sistema:

```dart
Future<void> _editUser(User user) async {
  if (!mounted) return;
  await showDialog(
    context: context,
    builder: (context) => Dialog(
      child: SingleChildScrollView(
        child: UserEditForm(
          user: user,
          onUserUpdated: (updatedUser) async {
            await _loadLists();
            if (mounted && context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    ),
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/admin/users_management_screen.dart`
- Líneas: 200-220 (aproximadamente)

### 3.7. Eliminación de Usuarios

El administrador puede eliminar usuarios con confirmación:

```dart
Future<void> _deleteTutor(User tutor) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar eliminación'),
      content: Text(
        '¿Está seguro de eliminar al tutor ${tutor.fullName} (${tutor.email})?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    // Eliminar usuario
    await _service.deleteUser(tutor.id);
    await _loadLists();
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/admin/users_management_screen.dart`
- Líneas: 125-180 (aproximadamente)

---

## 4. Supervisión del Sistema

### 4.1. Estado del Sistema

El dashboard muestra el estado de los servicios principales:

```dart
Widget _buildSystemSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Estado del Sistema',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatusRow('Base de datos', 'Operativo', Colors.green),
              _buildStatusRow('API REST', 'Operativo', Colors.green),
              _buildStatusRow('Autenticación', 'Operativo', Colors.green),
              _buildStatusRow('Almacenamiento', 'Operativo', Colors.green),
            ],
          ),
        ),
      ),
    ],
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/admin_dashboard.dart`
- Líneas: 321-354

### 4.2. Acceso a Supabase Studio

El administrador puede acceder directamente a Supabase Studio para gestión avanzada:

```dart
Future<void> _openSupabaseStudio() async {
  final Uri url = Uri.parse(AppConfig.supabaseStudioUrl);
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/admin_dashboard.dart`
- Líneas: 613-649

---

## 5. Flujo de Aprobación

### 5.1. Acceso al Flujo de Aprobación

El administrador puede acceder al flujo de aprobación de anteproyectos:

```dart
void _navigateToApprovalWorkflow() {
  context.go('/admin/approval-workflow', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/admin_dashboard.dart`
- Líneas: 538-540

### 5.2. Selección de Tutor

El administrador puede revisar anteproyectos de cualquier tutor:

```dart
GoRoute(
  path: '/admin/approval-workflow',
  name: 'admin-approval-workflow',
  builder: (context, state) {
    final user = state.extra as User?;
    if (user == null) {
      return const LoginScreenBloc();
    }
    return TutorSelectorForApprovalScreen(user: user);
  },
),
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 380-390 (aproximadamente)

---

## 6. Configuración del Sistema

### 6.1. Acceso a Configuración

El administrador puede acceder a la configuración del sistema:

```dart
void _navigateToSettings() {
  context.go('/admin/settings', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/admin_dashboard.dart`
- Líneas: 542-544

### 6.2. Pantalla de Configuración

La pantalla de configuración permite ajustar parámetros globales del sistema:

```dart
GoRoute(
  path: '/admin/settings',
  name: 'admin-settings',
  builder: (context, state) {
    final user = state.extra as User?;
    if (user == null) {
      return const LoginScreenBloc();
    }
    return SettingsScreen(user: user);
  },
),
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 392-402 (aproximadamente)

---

## 7. Navegación y Rutas

### 7.1. Menú Hamburguesa Persistente

La aplicación utiliza un **menú hamburguesa persistente** (`PersistentScaffold`) que mantiene el AppBar y el drawer consistentes en todas las rutas. Esto proporciona una experiencia de navegación uniforme y accesible.

**Opciones del menú para administradores:**
- **Panel Principal**: Dashboard con estadísticas globales
- **Notificaciones**: Alertas y notificaciones del sistema
- **Gestionar Usuarios**: Administración de usuarios y roles
- **Flujo de Aprobación**: Gestión del flujo de aprobación
- **Configuración del Sistema**: Configuración global
- **Ayuda**: Guía de uso del sistema

```dart
// PersistentScaffold mantiene el menú en todas las pantallas
return PersistentScaffold(
  title: 'Gestionar Usuarios',
  titleKey: 'admin-users',
  user: user,
  body: body,
);
```

**Referencia de código:**
- Archivo: `frontend/lib/widgets/navigation/persistent_scaffold.dart`
- Archivo: `frontend/lib/widgets/navigation/app_side_drawer.dart`
- Líneas: 157-177 (menú específico para administradores)

### 7.2. Rutas Específicas del Administrador

El router define rutas específicas para el administrador:

```dart
// Gestión de usuarios
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

### 7.3. Protección de Rutas

Las rutas administrativas verifican el rol del usuario:

```dart
if (user.role != UserRole.admin) {
  return PersistentScaffold(
    title: 'Acceso denegado',
    body: const Center(child: Text('Se requiere rol administrador')),
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 410-414

---

## 8. Permisos y Seguridad

### 8.1. Verificación de Rol

El sistema verifica el rol del usuario antes de permitir acciones administrativas:

```dart
// En el servicio de gestión de usuarios
Future<List<User>> getUsers({
  String? role,
  String? academicYear,
}) async {
  final user = _supabase.auth.currentUser;
  if (user == null) {
    throw AuthenticationException('not_authenticated', ...);
  }

  // Verificar que el usuario es admin
  final userResponse = await _supabase
      .from('users')
      .select('role')
      .eq('email', user.email!)
      .single();

  if (userResponse['role'] != 'admin') {
    throw AuthenticationException('insufficient_permissions', ...);
  }

  // Continuar con la consulta
  // ...
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/user_management_service.dart`
- Líneas: 250-300 (aproximadamente)

### 8.2. Row Level Security (RLS)

Las políticas RLS en la base de datos aseguran que solo los administradores puedan realizar ciertas operaciones:

```sql
-- Política para que solo admins puedan ver todos los usuarios
CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (public.is_admin());
```

**Referencia de código:**
- Archivo: `docs/base_datos/migraciones/schema_completo.sql` (sección RLS)
- Líneas: 200-250 (aproximadamente)

### 8.3. Funciones RPC Protegidas

Las funciones RPC en Supabase verifican el rol del usuario:

```sql
CREATE OR REPLACE FUNCTION create_tutor(
  tutor_email TEXT,
  tutor_password TEXT,
  tutor_full_name TEXT,
  tutor_specialty TEXT DEFAULT NULL,
  tutor_phone TEXT DEFAULT NULL
) RETURNS JSON AS $$
BEGIN
  -- Verificar que el usuario es admin
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Solo administradores pueden crear tutores';
  END IF;

  -- Crear tutor
  -- ...
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Referencia de código:**
- Archivo: `docs/base_datos/migraciones/schema_completo.sql` (funciones RPC)
- Función: `create_tutor`

---

## Resumen del Flujo del Administrador

### Flujo Principal

```
1. Login exitoso
   ↓
2. Redirección a /dashboard/admin
   ↓
3. Carga de estadísticas del sistema
   ↓
4. Dashboard muestra:
   - Estadísticas globales
   - Accesos rápidos
   - Estado del sistema
   - Usuarios recientes
   ↓
5. Acciones disponibles:
   - Gestión de usuarios (crear, editar, eliminar)
   - Importación masiva de estudiantes
   - Supervisión del sistema
   - Flujo de aprobación
   - Configuración del sistema
```

### Puntos Clave

- **Acceso completo**: El administrador tiene acceso a todos los datos del sistema
- **Gestión de usuarios**: Puede crear, editar y eliminar usuarios de cualquier rol
- **Supervisión**: Puede monitorear el estado del sistema y las métricas clave
- **Seguridad**: Las políticas RLS y verificaciones de rol aseguran que solo los administradores puedan realizar acciones administrativas

---

**Última actualización**: Diciembre 2025  
**Versión del documento**: 1.0

