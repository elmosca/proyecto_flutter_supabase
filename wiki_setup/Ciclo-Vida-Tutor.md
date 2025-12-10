# Ciclo de Vida del Rol Tutor - Documentación Técnica

Este documento explica detalladamente el funcionamiento completo del ciclo de vida del rol **Tutor** en la aplicación, basado en el código fuente real del proyecto.

## Tabla de Contenidos

1. [Acceso al Dashboard](#1-acceso-al-dashboard)
2. [Inicialización del Dashboard](#2-inicialización-del-dashboard)
3. [Gestión de Estudiantes](#3-gestión-de-estudiantes)
4. [Revisión de Anteproyectos](#4-revisión-de-anteproyectos)
5. [Flujo de Aprobación](#5-flujo-de-aprobación)
6. [Comunicación con Estudiantes](#6-comunicación-con-estudiantes)
7. [Navegación y Rutas](#7-navegación-y-rutas)
8. [Permisos y Seguridad](#8-permisos-y-seguridad)

---

## 1. Acceso al Dashboard

### 1.1. Navegación Post-Login

Después de un login exitoso, el sistema redirige al tutor a su dashboard específico:

```dart
static void goToDashboard(BuildContext context, User user) {
  final route = _getDashboardRoute(user.role);
  // Para tutor: '/dashboard/tutor'
  context.go(route, extra: user);
}

static String _getDashboardRoute(UserRole role) {
  switch (role) {
    case UserRole.tutor:
      return '/dashboard/tutor';
    // ...
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 449-469

### 1.2. Construcción del Dashboard

El dashboard del tutor se construye con el usuario autenticado:

```dart
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
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 112-122

---

## 2. Inicialización del Dashboard

### 2.1. Componente Principal

El dashboard del tutor es un `StatefulWidget` que carga datos al inicializarse:

```dart
class TutorDashboard extends StatefulWidget {
  final User user;

  const TutorDashboard({super.key, required this.user});
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/tutor_dashboard.dart`
- Líneas: 19-26

### 2.2. Carga de Datos Iniciales

Al montar el widget, se cargan los estudiantes asignados y los anteproyectos del tutor:

```dart
Future<void> _loadData() async {
  if (!mounted) return;

  try {
    // Verificar autenticación
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // Cargar estudiantes y anteproyectos en paralelo
    final futures = await Future.wait([
      _userService.getStudentsByTutor(widget.user.id),
      _anteprojectsService.getTutorAnteprojects(),
    ]);

    if (!mounted) return;

    final students = futures[0] as List<User>;
    final anteprojectsData = futures[1] as List<Map<String, dynamic>>;

    if (mounted) {
      setState(() {
        _students = students;
        _anteprojectsData = anteprojectsData;
        _isLoading = false;
      });
    }
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/tutor_dashboard.dart`
- Líneas: 49-168

### 2.3. Estadísticas del Dashboard

El dashboard muestra métricas clave:

- **Anteproyectos Pendientes**: Anteproyectos que requieren revisión
- **Estudiantes Asignados**: Número de estudiantes bajo su tutela
- **Revisados**: Anteproyectos ya revisados

```dart
Widget _buildStatistics() {
  return Row(
    children: [
      Expanded(
        child: _buildStatCard(
          title: l10n.pendingAnteprojects,
          value: _pendingAnteprojects.length.toString(),
          icon: Icons.pending_actions,
          color: Colors.orange,
          onTap: _reviewAnteprojects,
        ),
      ),
      Expanded(
        child: _buildStatCard(
          title: l10n.assignedStudents,
          value: _students.length.toString(),
          icon: Icons.people,
          color: Colors.blue,
          onTap: _viewAllStudents,
        ),
      ),
      Expanded(
        child: _buildStatCard(
          title: l10n.reviewed,
          value: _reviewedAnteprojects.length.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
          onTap: _viewAllAnteprojects,
        ),
      ),
    ],
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/tutor_dashboard.dart`
- Líneas: 433-469

---

## 3. Gestión de Estudiantes

### 3.1. Acceso a la Lista de Estudiantes

El tutor puede acceder a la lista de sus estudiantes asignados:

```dart
void _viewAllStudents() {
  context.go('/students', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/tutor_dashboard.dart`
- Líneas: 629-632

### 3.2. Pantalla de Lista de Estudiantes

La pantalla `StudentListScreen` muestra todos los estudiantes asignados al tutor:

```dart
class StudentListScreen extends StatefulWidget {
  final int tutorId;

  const StudentListScreen({
    super.key,
    required this.tutorId,
  });
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/student/student_list_screen.dart`
- Líneas: 9-19

### 3.3. Carga de Estudiantes

La pantalla carga los estudiantes asignados al tutor:

```dart
Future<void> _loadStudents() async {
  try {
    final userService = UserService();
    final students = await userService.getStudentsByTutor(widget.tutorId);

    if (mounted) {
      setState(() {
        _students = students;
        _isLoading = false;
      });
    }
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/student/student_list_screen.dart`
- Líneas: 39-65

### 3.4. Añadir Estudiantes

El tutor puede añadir estudiantes a su lista mediante un diálogo:

```dart
void _showAddStudentsDialog() {
  showDialog(
    context: context,
    builder: (context) => AddStudentsDialog(tutorId: widget.user.id),
  ).then((_) => _loadData()); // Recargar datos al cerrar
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/tutor_dashboard.dart`
- Líneas: 605-610

El diálogo permite seleccionar estudiantes disponibles y asignarlos al tutor:

```dart
class AddStudentsDialog extends StatefulWidget {
  final int tutorId;

  const AddStudentsDialog({super.key, required this.tutorId});
}
```

**Referencia de código:**
- Archivo: `frontend/lib/widgets/dialogs/add_students_dialog.dart`
- Líneas: 1-50 (aproximadamente)

### 3.5. Edición de Estudiantes

El tutor puede editar información de sus estudiantes:

```dart
Future<void> _editStudent(app_user.User student) async {
  await showDialog(
    context: context,
    builder: (context) => Dialog(
      child: SingleChildScrollView(
        child: EditStudentForm(
          student: student,
          onStudentUpdated: (updatedStudent) async {
            await _loadStudents();
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
- Archivo: `frontend/lib/screens/student/student_list_screen.dart`
- Líneas: 150-180 (aproximadamente)

---

## 4. Revisión de Anteproyectos

### 4.1. Acceso a Anteproyectos

El tutor puede acceder a la lista de anteproyectos para revisión:

```dart
void _reviewAnteprojects() {
  context.go('/anteprojects', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/tutor_dashboard.dart`
- Líneas: 619-622

### 4.2. Pantalla de Revisión

La pantalla `AnteprojectsReviewScreen` muestra los anteproyectos asignados al tutor:

```dart
GoRoute(
  path: '/anteprojects',
  name: 'anteprojects',
  builder: (context, state) {
    User? user = state.extra as User?;
    if (user == null) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        user = authState.user;
      }
    }

    if (user == null) {
      return const LoginScreenBloc();
    }

    // Para tutores - usar AnteprojectsReviewScreen
    Widget body;
    if (user.role == UserRole.student) {
      body = MyAnteprojectsList(user: user);
    } else {
      body = const AnteprojectsReviewScreen();
    }

    return PersistentScaffold(
      title: 'Anteproyectos',
      titleKey: 'anteprojects',
      user: user,
      body: body,
    );
  },
),
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 139-176

### 4.3. Obtención de Anteproyectos del Tutor

El servicio obtiene los anteproyectos asignados al tutor con información de estudiantes:

```dart
Future<List<Map<String, dynamic>>> getTutorAnteprojects() async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    final userResponse = await _supabase
        .from('users')
        .select('id')
        .eq('email', user.email!)
        .single();

    final tutorId = userResponse['id'] as int;

    final response = await _supabase
        .from('anteprojects')
        .select('''
          *,
          anteproject_students(
            student_id,
            is_lead_author,
            users(
              id,
              full_name,
              email,
              nre,
              tutor_id
            )
          )
        ''')
        .eq('tutor_id', tutorId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    throw AnteprojectsException('Error al obtener anteproyectos del tutor: $e');
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 822-851

---

## 5. Flujo de Aprobación

### 5.1. Acceso al Flujo de Aprobación

El tutor puede acceder al flujo de aprobación de anteproyectos:

```dart
void _navigateToApprovalWorkflow() {
  context.go('/approval-workflow', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/tutor_dashboard.dart`
- Líneas: 614-617

### 5.2. Pantalla de Aprobación

La pantalla `ApprovalScreen` muestra anteproyectos pendientes y revisados:

```dart
class ApprovalScreen extends StatefulWidget {
  final int? selectedTutorId;
  final bool showBackButton;
  final bool useOwnScaffold;

  const ApprovalScreen({
    super.key,
    this.selectedTutorId,
    this.showBackButton = false,
    this.useOwnScaffold = false,
  });
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/approval/approval_screen.dart`
- Líneas: 13-29

### 5.3. Carga de Anteproyectos Pendientes

El BLoC carga los anteproyectos pendientes de revisión:

```dart
@override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);

  // Cargar los datos iniciales
  context.read<ApprovalBloc>().add(
    LoadPendingApprovals(tutorId: widget.selectedTutorId),
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/approval/approval_screen.dart`
- Líneas: 36-49

### 5.4. Aprobación de Anteproyectos

El servicio `ApprovalService` maneja la aprobación de anteproyectos:

```dart
Future<ApprovalResult> approveAnteproject(
  int anteprojectId, {
  String? comments,
}) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    // Aprobar anteproyecto
    await _anteprojectsService.approveAnteproject(
      anteprojectId,
      comments ?? '',
    );

    // Crear resultado de aprobación
    final result = ApprovalResult(
      success: true,
      message: 'Anteproyecto aprobado exitosamente',
      anteprojectId: anteprojectId,
    );

    // Enviar email de notificación al estudiante
    await _sendStatusChangeEmail(anteprojectId, 'approved', comments);

    return result;
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/approval_service.dart`
- Líneas: 54-100

### 5.5. Rechazo de Anteproyectos

El tutor puede rechazar un anteproyecto con comentarios obligatorios:

```dart
Future<ApprovalResult> rejectAnteproject(
  int anteprojectId, {
  required String comments,
}) async {
  try {
    if (comments.trim().isEmpty) {
      throw ApprovalException('comments_required', ...);
    }

    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    // Rechazar anteproyecto
    await _anteprojectsService.rejectAnteproject(
      anteprojectId,
      comments,
    );

    // Enviar email de notificación
    await _sendStatusChangeEmail(anteprojectId, 'rejected', comments);

    return ApprovalResult(
      success: true,
      message: 'Anteproyecto rechazado',
      anteprojectId: anteprojectId,
    );
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/approval_service.dart`
- Líneas: 102-150 (aproximadamente)

### 5.6. Solicitud de Cambios

El tutor puede solicitar cambios en un anteproyecto:

```dart
Future<ApprovalResult> requestChanges(
  int anteprojectId, {
  required String comments,
}) async {
  try {
    if (comments.trim().isEmpty) {
      throw ApprovalException('comments_required', ...);
    }

    // Solicitar cambios
    await _anteprojectsService.requestChanges(
      anteprojectId,
      comments,
    );

    // Enviar email de notificación
    await _sendStatusChangeEmail(anteprojectId, 'changes_requested', comments);

    return ApprovalResult(
      success: true,
      message: 'Cambios solicitados',
      anteprojectId: anteprojectId,
    );
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/approval_service.dart`
- Líneas: 152-200 (aproximadamente)

---

## 6. Comunicación con Estudiantes

### 6.1. Sistema de Mensajería

El tutor puede comunicarse con sus estudiantes mediante el sistema de mensajería:

```dart
GoRoute(
  path: '/messages/tutor',
  name: 'tutor-messages',
  builder: (context, state) {
    final user = state.extra as User?;
    if (user == null) {
      return const LoginScreenBloc();
    }
    return TutorMessagesSelectorScreen(user: user);
  },
),
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 300-310 (aproximadamente)

### 6.2. Selección de Estudiante y Proyecto

El tutor selecciona un estudiante y su proyecto/anteproyecto para enviar mensajes:

```dart
class TutorMessagesSelectorScreen extends StatefulWidget {
  final User user;

  const TutorMessagesSelectorScreen({super.key, required this.user});
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/messages/tutor_messages_selector_screen.dart`
- Líneas: 1-50 (aproximadamente)

---

## 7. Navegación y Rutas

### 7.1. Menú Hamburguesa Persistente

La aplicación utiliza un **menú hamburguesa persistente** (`PersistentScaffold`) que mantiene el AppBar y el drawer consistentes en todas las rutas. Esto proporciona una experiencia de navegación uniforme y accesible.

**Opciones del menú para tutores:**
- **Panel Principal**: Dashboard con resumen de estudiantes y proyectos
- **Mis Estudiantes**: Lista de estudiantes asignados
- **Notificaciones**: Alertas y notificaciones del sistema
- **Mensajes**: Sistema de mensajería con estudiantes
- **Anteproyectos**: Anteproyectos pendientes de revisión
- **Flujo de Aprobación**: Gestión del flujo de aprobación
- **Ayuda**: Guía de uso del sistema

```dart
// PersistentScaffold mantiene el menú en todas las pantallas
return PersistentScaffold(
  title: 'Mis Estudiantes',
  titleKey: 'students',
  user: user,
  body: body,
);
```

**Referencia de código:**
- Archivo: `frontend/lib/widgets/navigation/persistent_scaffold.dart`
- Archivo: `frontend/lib/widgets/navigation/app_side_drawer.dart`
- Líneas: 131-156 (menú específico para tutores)

### 7.2. Rutas Específicas del Tutor

El router define rutas específicas para el tutor:

```dart
// Lista de estudiantes
GoRoute(
  path: '/students',
  name: 'students',
  builder: (context, state) {
    final user = state.extra as User?;
    if (user == null) {
      return const LoginScreenBloc();
    }
    return PersistentScaffold(
      title: 'Mis Estudiantes',
      titleKey: 'students',
      user: user,
      body: StudentListScreen(tutorId: user.id),
    );
  },
),
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 320-340 (aproximadamente)

### 7.3. Filtrado por Año Académico

El dashboard del tutor permite filtrar estudiantes y anteproyectos por año académico:

```dart
List<User> get _filteredStudents {
  return _students.where((student) {
    return student.academicYear == _selectedAcademicYear;
  }).toList();
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/tutor_dashboard.dart`
- Líneas: 170-174

---

## 8. Permisos y Seguridad

### 8.1. Verificación de Rol

El sistema verifica el rol del tutor antes de permitir acciones:

```dart
// En el servicio de anteproyectos
Future<List<Map<String, dynamic>>> getTutorAnteprojects() async {
  final user = _supabase.auth.currentUser;
  if (user == null) {
    throw AuthenticationException('not_authenticated', ...);
  }

  // Obtener el ID del tutor desde la tabla users
  final userResponse = await _supabase
      .from('users')
      .select('id')
      .eq('email', user.email!)
      .single();

  final tutorId = userResponse['id'] as int;

  // Solo obtener anteproyectos asignados a este tutor
  final response = await _supabase
      .from('anteprojects')
      .select('*')
      .eq('tutor_id', tutorId)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 822-851

### 8.2. Row Level Security (RLS)

Las políticas RLS en la base de datos aseguran que los tutores solo vean sus propios anteproyectos:

```sql
-- Política para que tutores vean solo sus anteproyectos
CREATE POLICY "Tutors can view their own anteprojects" ON anteprojects
    FOR SELECT USING (
        public.user_id() = tutor_id
    );
```

**Referencia de código:**
- Archivo: `docs/base_datos/migraciones/schema_completo.sql` (sección RLS)
- Líneas: 141-145

### 8.3. Restricción de Aprobación

Solo el tutor asignado puede aprobar un anteproyecto:

```dart
// En el servicio de aprobación
Future<void> approveAnteproject(int anteprojectId, String comments) async {
  // Verificar que el tutor es el asignado al anteproyecto
  final anteproject = await _supabase
      .from('anteprojects')
      .select('tutor_id')
      .eq('id', anteprojectId)
      .single();

  final currentUser = _supabase.auth.currentUser;
  final userResponse = await _supabase
      .from('users')
      .select('id')
      .eq('email', currentUser!.email!)
      .single();

  if (anteproject['tutor_id'] != userResponse['id']) {
    throw ApprovalException('unauthorized', ...);
  }

  // Aprobar anteproyecto
  // ...
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 600-700 (aproximadamente)

---

## Resumen del Flujo del Tutor

### Flujo Principal

```
1. Login exitoso
   ↓
2. Redirección a /dashboard/tutor
   ↓
3. Carga de datos:
   - Estudiantes asignados
   - Anteproyectos pendientes de revisión
   - Anteproyectos ya revisados
   ↓
4. Dashboard muestra:
   - Estadísticas (pendientes, estudiantes, revisados)
   - Lista de estudiantes asignados
   - Accesos rápidos
   ↓
5. Acciones disponibles:
   - Revisar anteproyectos pendientes
   - Aprobar/Rechazar/Solicitar cambios
   - Gestionar estudiantes asignados
   - Comunicarse con estudiantes
   - Ver proyectos activos
```

### Puntos Clave

- **Acceso limitado**: El tutor solo ve sus estudiantes asignados y sus anteproyectos
- **Revisión de anteproyectos**: Puede aprobar, rechazar o solicitar cambios
- **Gestión de estudiantes**: Puede añadir, editar y gestionar sus estudiantes
- **Comunicación**: Puede comunicarse con estudiantes mediante mensajería
- **Seguridad**: Las políticas RLS aseguran que solo vea datos de sus estudiantes

---

**Última actualización**: Diciembre 2025  
**Versión del documento**: 1.0

