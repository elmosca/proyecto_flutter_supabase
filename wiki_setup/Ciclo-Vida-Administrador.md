# Ciclo de Vida del Administrador

Aquí explico cómo funciona el panel de administración y qué puede hacer un usuario con rol de administrador en la aplicación.

> Si necesitas una visión más general de la arquitectura, puedes consultar la página de [Arquitectura del Sistema](01-Arquitectura).

## Índice

1.  Dashboard del administrador
2.  Gestión de usuarios
3.  Supervisión del sistema
4.  Flujo de aprobación
5.  Configuración del sistema
6.  Permisos y seguridad

---

## 1. Dashboard del Administrador

### 1.1. Acceso al dashboard

Cuando un administrador hace login, el `AppRouter` lo redirige a `/dashboard/admin`.

```dart
static void goToDashboard(BuildContext context, User user) {
  final route = _getDashboardRoute(user.role);
  // Para admin: '/dashboard/admin'
  context.go(route, extra: user);
}
```

### 1.2. Carga de datos iniciales

El `AdminDashboard` carga varias estadísticas del sistema en paralelo para que sea más rápido:

- Estadísticas generales (total de usuarios, proyectos, etc.)
- Lista de usuarios recientes

```dart
Future<void> _loadData() async {
  try {
    final futures = await Future.wait([
      widget.statsService.getSystemStats(),
      widget.statsService.getRecentUsers(),
    ]);

    if (mounted) {
      setState(() {
        _stats = futures[0] as AdminStats;
        _recentUsers = futures[1] as List<User>;
      });
    }
  } catch (e) {
    // ...
  }
}
```

### 1.3. Estadísticas del sistema

El dashboard muestra tarjetas con las métricas más importantes:

- **Total de usuarios:** Cuántos usuarios hay en total.
- **Proyectos activos:** Cuántos proyectos están en desarrollo.
- **Total de tutores:** Cuántos tutores hay registrados.

---

## 2. Gestión de Usuarios

### 2.1. Acceso a la gestión de usuarios

Desde el dashboard, el administrador puede ir a la pantalla de gestión de usuarios (`/admin/users`).

### 2.2. Carga de usuarios

La pantalla `UsersManagementScreen` carga las listas de tutores y estudiantes por separado, y permite filtrar por año académico.

```dart
Future<void> _loadLists() async {
  final tutors = await _service.getUsers(role: 'tutor', academicYear: _selectedYear);
  final students = await _service.getUsers(role: 'student', academicYear: _selectedYear);
  // ...
}
```

### 2.3. Creación de tutores

El administrador puede crear nuevos tutores desde un formulario. Esto llama a una función RPC de Supabase (`create_tutor`) que se encarga de crear el usuario en `auth.users` y el perfil en nuestra tabla `users`.

```dart
Future<Map<String, dynamic>> createTutor({
  required String email,
  required String password,
  required String fullName,
}) async {
  final response = await _supabase.rpc(
    'create_tutor',
    params: {
      'tutor_email': email,
      'tutor_password': password,
      'tutor_full_name': fullName,
    },
  );
  return response;
}
```

### 2.4. Importación masiva de estudiantes

Para facilitar la creación de muchos usuarios, el administrador puede subir un archivo CSV con los datos de los estudiantes. Esto llama a una Edge Function de Supabase (`super-action`) que procesa el archivo y crea los usuarios en lote.

```dart
Future<Map<String, dynamic>> bulkCreateStudents({
  required List<Map<String, dynamic>> students,
}) async {
  final response = await _supabase.functions.invoke(
    'super-action',
    body: {
      'action': 'bulk_create_students',
      'students': students,
    },
  );
  // ...
}
```

### 2.5. Edición y eliminación de usuarios

El administrador puede editar los datos de cualquier usuario o eliminarlo. Al eliminar, siempre se muestra un diálogo de confirmación para evitar accidentes.

---

## 3. Supervisión del Sistema

### 3.1. Estado del sistema

El dashboard muestra el estado de los servicios de Supabase (base de datos, API, autenticación, etc.). Por ahora, es una simulación, pero la idea es que en el futuro haga una llamada real para comprobar el estado.

### 3.2. Acceso a Supabase Studio

Hay un botón que abre Supabase Studio en una nueva pestaña para que el administrador pueda hacer gestiones más avanzadas directamente en la base de datos.

---

## 4. Flujo de Aprobación

El administrador puede ver los anteproyectos pendientes de revisión de cualquier tutor. Esto es útil si un tutor está ausente o si hay un atasco en las revisiones.

---

## 5. Configuración del Sistema

Hay una sección de configuración (`/admin/settings`) donde el administrador puede ajustar parámetros globales de la aplicación.

### 5.1. Automatización del Año Académico

El sistema ahora gestiona la creación de años académicos de forma automática directamente desde la base de datos.
- Se ha implementado un trigger en la base de datos que detecta cambios de fecha y asegura que el año académico actual exista.
- Esto elimina la necesidad de crear manualmente los años académicos al inicio de cada curso.
- El sistema utiliza el formato `YYYY-YYYY` (ej. `2025-2026`) para los años académicos.

---

## 6. Permisos y Seguridad

### 6.1. Verificación de rol

Todas las acciones y rutas del administrador están protegidas. Antes de ejecutar cualquier acción, el código comprueba que el rol del usuario sea `admin`.

```dart
if (user.role != UserRole.admin) {
  return PersistentScaffold(
    title: 'Acceso denegado',
    body: const Center(child: Text('Se requiere rol administrador')),
  );
}
```

### 6.2. Row Level Security (RLS)

Además de la verificación en el código, la base de datos tiene políticas de RLS que aseguran que solo los administradores puedan acceder a ciertos datos o realizar ciertas acciones. Por ejemplo, solo un administrador puede ver todos los usuarios.

```sql
-- Política para que solo admins puedan ver todos los usuarios
CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (public.is_admin());
```

### 6.3. Funciones RPC protegidas

Las funciones RPC que realizan acciones críticas (como crear un tutor) también comprueban el rol del usuario antes de ejecutarse.

```sql
CREATE OR REPLACE FUNCTION create_tutor(...) RETURNS JSON AS $$
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

