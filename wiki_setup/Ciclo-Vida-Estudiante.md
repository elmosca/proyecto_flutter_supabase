# Ciclo de Vida del Rol Estudiante - Documentación Técnica

Este documento explica detalladamente el funcionamiento completo del ciclo de vida del rol **Estudiante** en la aplicación, basado en el código fuente real del proyecto.

## Tabla de Contenidos

1. [Acceso al Dashboard](#1-acceso-al-dashboard)
2. [Inicialización del Dashboard](#2-inicialización-del-dashboard)
3. [Creación de Anteproyectos](#3-creación-de-anteproyectos)
4. [Gestión de Proyectos](#4-gestión-de-proyectos)
5. [Gestión de Tareas](#5-gestión-de-tareas)
6. [Tablero Kanban](#6-tablero-kanban)
7. [Comunicación con el Tutor](#7-comunicación-con-el-tutor)
8. [Navegación y Rutas](#8-navegación-y-rutas)
9. [Permisos y Seguridad](#9-permisos-y-seguridad)

---

## 1. Acceso al Dashboard

### 1.1. Navegación Post-Login

Después de un login exitoso, el sistema redirige al estudiante a su dashboard específico:

```dart
static void goToDashboard(BuildContext context, User user) {
  final route = _getDashboardRoute(user.role);
  // Para estudiante: '/dashboard/student'
  context.go(route, extra: user);
}

static String _getDashboardRoute(UserRole role) {
  switch (role) {
    case UserRole.student:
      return '/dashboard/student';
    // ...
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 449-469

### 1.2. Construcción del Dashboard

El dashboard del estudiante se construye con el usuario autenticado:

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
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 95-111

---

## 2. Inicialización del Dashboard

### 2.1. Componente Principal

El dashboard del estudiante es un `StatefulWidget` que carga datos al inicializarse:

```dart
class StudentDashboardScreen extends StatefulWidget {
  final User user;

  const StudentDashboardScreen({super.key, required this.user});
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/student_dashboard_screen.dart`
- Líneas: 21-28

### 2.2. Carga de Datos Iniciales

Al montar el widget, se cargan anteproyectos, proyectos y tareas del estudiante:

```dart
Future<void> _loadData() async {
  if (!mounted) return;

  try {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // Cargar datos en paralelo
    final futures = await Future.wait([
      _anteprojectsService.getStudentAnteprojects(),
      _projectsService.getStudentProjects(),
      _tasksService.getTasks(),
    ]);

    if (!mounted) return;

    final anteprojects = futures[0] as List<Anteproject>;
    final projects = futures[1] as List<Project>;
    final tasks = futures[2] as List<Task>;

    if (mounted) {
      setState(() {
        _anteprojects = anteprojects;
        _projects = projects;
        _tasks = tasks;
        _isLoading = false;
      });
    }
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/student_dashboard_screen.dart`
- Líneas: 55-103

### 2.3. Estadísticas del Dashboard

El dashboard muestra métricas clave:

- **Anteproyectos Pendientes**: Anteproyectos en revisión
- **Proyectos Activos**: Proyectos aprobados en desarrollo
- **Tareas Pendientes**: Tareas que requieren atención

```dart
Widget _buildStatistics() {
  return Row(
    children: [
      Expanded(
        child: _buildStatCard(
          title: 'Anteproyectos Pendientes',
          value: _pendingAnteprojects.length.toString(),
          icon: Icons.pending_actions,
          color: Colors.orange,
          onTap: _viewAnteprojects,
        ),
      ),
      Expanded(
        child: _buildStatCard(
          title: 'Proyectos Activos',
          value: _projects.length.toString(),
          icon: Icons.work,
          color: Colors.green,
          onTap: _viewProjects,
        ),
      ),
      Expanded(
        child: _buildStatCard(
          title: 'Tareas Pendientes',
          value: _pendingTasks.length.toString(),
          icon: Icons.task_alt,
          color: Colors.blue,
          onTap: _viewTasks,
        ),
      ),
    ],
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/student_dashboard_screen.dart`
- Líneas: 263-297

---

## 3. Creación de Anteproyectos

### 3.1. Acceso al Formulario

El estudiante puede crear un anteproyecto desde el dashboard:

```dart
void _createAnteproject() {
  context.go('/anteprojects', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/student_dashboard_screen.dart`
- Líneas: 774-777

### 3.2. Formulario de Anteproyecto

El formulario `AnteprojectForm` permite crear un nuevo anteproyecto:

```dart
class AnteprojectForm extends StatefulWidget {
  const AnteprojectForm({super.key});
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/forms/anteproject_form.dart`
- Líneas: 17-22

### 3.3. Campos del Formulario

El formulario incluye los siguientes campos:

- **Título**: Título del proyecto
- **Descripción**: Descripción detallada (mínimo 200 palabras)
- **Tipo de Proyecto**: Ejecución, Investigación, etc.
- **Objetivos**: Objetivos específicos del proyecto
- **Año Académico**: Año académico del proyecto
- **Hitos**: Resultados esperados con fechas

```dart
final TextEditingController _titleController = TextEditingController();
final TextEditingController _descriptionController = TextEditingController();
final TextEditingController _academicYearController = TextEditingController();
final TextEditingController _objectivesController = TextEditingController();
ProjectType? _projectType = ProjectType.execution;
List<Hito> _hitos = [];
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/forms/anteproject_form.dart`
- Líneas: 28-36

### 3.4. Guardado como Borrador

El estudiante puede guardar el anteproyecto como borrador:

```dart
void _saveDraft() {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final anteproject = Anteproject(
    id: 0, // Nuevo anteproyecto
    title: _titleController.text.trim(),
    description: _descriptionController.text.trim(),
    projectType: _projectType!,
    status: AnteprojectStatus.draft,
    academicYear: _academicYearController.text.trim(),
    objectives: _objectivesController.text.trim(),
    hitos: _hitos,
    // ...
  );

  context.read<AnteprojectsBloc>().add(
    AnteprojectCreateRequested(anteproject),
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/forms/anteproject_form.dart`
- Líneas: 200-250 (aproximadamente)

### 3.5. Envío para Revisión

Cuando el anteproyecto está completo, el estudiante lo envía para revisión:

```dart
void _submitForReview() {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final anteproject = Anteproject(
    id: 0,
    title: _titleController.text.trim(),
    description: _descriptionController.text.trim(),
    projectType: _projectType!,
    status: AnteprojectStatus.submitted, // Cambiar a 'submitted'
    academicYear: _academicYearController.text.trim(),
    objectives: _objectivesController.text.trim(),
    hitos: _hitos,
    submittedAt: DateTime.now(),
    // ...
  );

  context.read<AnteprojectsBloc>().add(
    AnteprojectCreateRequested(anteproject),
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/forms/anteproject_form.dart`
- Líneas: 250-300 (aproximadamente)

### 3.6. Obtención de Anteproyectos del Estudiante

El servicio obtiene los anteproyectos del estudiante:

```dart
Future<List<Anteproject>> getStudentAnteprojects() async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    // Obtener el ID del estudiante desde la tabla users
    final userResponse = await _supabase
        .from('users')
        .select('id')
        .eq('email', user.email!)
        .single();

    final studentId = userResponse['id'] as int;

    // Obtener anteproyectos del estudiante
    final response = await _supabase
        .from('anteproject_students')
        .select('anteproject_id, anteprojects!inner(*)')
        .eq('student_id', studentId);

    final anteprojects = response.map((row) {
      return Anteproject.fromJson(row['anteprojects'] as Map<String, dynamic>);
    }).toList();

    return anteprojects;
  } catch (e) {
    throw AnteprojectsException('Error al obtener anteproyectos: $e');
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 1093-1120 (aproximadamente)

---

## 4. Gestión de Proyectos

### 4.1. Acceso a Proyectos

El estudiante puede acceder a sus proyectos activos:

```dart
void _viewProjects() {
  context.go('/projects', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/student_dashboard_screen.dart`
- Líneas: 788-790

### 4.2. Obtención de Proyectos

El servicio obtiene los proyectos del estudiante:

```dart
Future<List<Project>> getStudentProjects() async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    // Obtener el ID del estudiante
    final userResponse = await _supabase
        .from('users')
        .select('id')
        .eq('email', user.email!)
        .single();

    final studentId = userResponse['id'] as int;

    // Obtener proyectos del estudiante a través de anteproyectos
    final response = await _supabase
        .from('projects')
        .select('''
          *,
          anteprojects!inner(
            id,
            anteproject_students!inner(
              student_id
            )
          )
        ''')
        .eq('anteprojects.anteproject_students.student_id', studentId);

    final projects = response.map((row) {
      return Project.fromJson(row as Map<String, dynamic>);
    }).toList();

    return projects;
  } catch (e) {
    throw DatabaseException('Error al obtener proyectos: $e', ...);
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/projects_service.dart`
- Líneas: 200-250 (aproximadamente)

### 4.3. Creación Automática de Proyecto

Cuando un anteproyecto es aprobado, el sistema crea automáticamente un proyecto:

```dart
// En el servicio de aprobación
Future<void> approveAnteproject(int anteprojectId, String comments) async {
  // Aprobar anteproyecto
  await _supabase
      .from('anteprojects')
      .update({
        'status': 'approved',
        'reviewed_at': DateTime.now().toIso8601String(),
        'review_comments': comments,
      })
      .eq('id', anteprojectId);

  // Crear proyecto automáticamente
  final anteproject = await _supabase
      .from('anteprojects')
      .select('*')
      .eq('id', anteprojectId)
      .single();

  await _supabase.from('projects').insert({
    'anteproject_id': anteprojectId,
    'title': anteproject['title'],
    'status': 'planning',
    'tutor_id': anteproject['tutor_id'],
    'created_at': DateTime.now().toIso8601String(),
  });
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 600-700 (aproximadamente)

---

## 5. Gestión de Tareas

### 5.1. Acceso a Tareas

El estudiante puede acceder a sus tareas:

```dart
void _viewTasks() {
  context.go('/tasks', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/student_dashboard_screen.dart`
- Líneas: 792-794

### 5.2. Creación de Tareas

El estudiante puede crear tareas para sus proyectos:

```dart
void _createTask() {
  context.go('/tasks', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/student_dashboard_screen.dart`
- Líneas: 779-782

### 5.3. Formulario de Tarea

El formulario `TaskForm` permite crear y editar tareas:

```dart
class TaskForm extends StatefulWidget {
  final int? projectId;
  final Task? task;

  const TaskForm({
    super.key,
    this.projectId,
    this.task,
  });
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/forms/task_form.dart`
- Líneas: 1-50 (aproximadamente)

### 5.4. Estados de Tareas

Las tareas pueden tener los siguientes estados:

- **pending**: Pendiente
- **in_progress**: En progreso
- **in_review**: En revisión
- **completed**: Completada

```dart
enum TaskStatus {
  pending,
  inProgress,
  underReview,
  completed,
}
```

**Referencia de código:**
- Archivo: `frontend/lib/models/task.dart`
- Líneas: 1-50 (aproximadamente)

### 5.5. Obtención de Tareas

El servicio obtiene las tareas del estudiante:

```dart
Future<List<Task>> getTasks({int? projectId}) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    // Obtener el ID del estudiante
    final userResponse = await _supabase
        .from('users')
        .select('id')
        .eq('email', user.email!)
        .single();

    final studentId = userResponse['id'] as int;

    // Obtener tareas del estudiante
    var query = _supabase
        .from('tasks')
        .select('*')
        .eq('assigned_to', studentId);

    if (projectId != null) {
      query = query.eq('project_id', projectId);
    }

    final response = await query.order('created_at', ascending: false);

    final tasks = response.map((row) {
      return Task.fromJson(row as Map<String, dynamic>);
    }).toList();

    return tasks;
  } catch (e) {
    throw DatabaseException('Error al obtener tareas: $e', ...);
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 100-200 (aproximadamente)

---

## 6. Tablero Kanban

### 6.1. Acceso al Kanban

El estudiante puede acceder al tablero Kanban para gestionar tareas visualmente:

```dart
void _viewKanban() {
  context.go('/kanban', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/student_dashboard_screen.dart`
- Líneas: 796-798

### 6.2. Componente Kanban

El componente `KanbanBoard` muestra las tareas organizadas por columnas:

```dart
class KanbanBoard extends StatefulWidget {
  final int? projectId;
  final bool isEmbedded;

  const KanbanBoard({
    super.key,
    this.projectId,
    this.isEmbedded = false,
  });
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/kanban/kanban_board.dart`
- Líneas: 1-50 (aproximadamente)

### 6.3. Drag and Drop

El estudiante puede mover tareas entre columnas mediante drag and drop:

```dart
void _handleTaskDrop(Task task, TaskStatus newStatus, int targetIndex) {
  // Enviar el evento al BLoC
  context.read<TasksBloc>().add(
    TaskReorderRequested(
      taskId: task.id,
      newStatus: newStatus,
      newPosition: targetIndex.toDouble(),
    ),
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/kanban/kanban_board.dart`
- Líneas: 400-450 (aproximadamente)

---

## 7. Comunicación con el Tutor

### 7.1. Sistema de Mensajería

El estudiante puede comunicarse con su tutor mediante el sistema de mensajería:

```dart
GoRoute(
  path: '/messages',
  name: 'messages',
  builder: (context, state) {
    final user = state.extra as User?;
    if (user == null) {
      return const LoginScreenBloc();
    }
    return MessageProjectSelectorScreen(user: user);
  },
),
```

**Referencia de código:**
- Archivo: `frontend/lib/router/app_router.dart`
- Líneas: 280-290 (aproximadamente)

### 7.2. Selección de Proyecto/Anteproyecto

El estudiante selecciona un proyecto o anteproyecto para enviar mensajes:

```dart
class MessageProjectSelectorScreen extends StatefulWidget {
  final User user;

  const MessageProjectSelectorScreen({super.key, required this.user});
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/messages/message_project_selector_screen.dart`
- Líneas: 1-50 (aproximadamente)

---

## 8. Navegación y Rutas

### 8.1. Rutas Específicas del Estudiante

El router define rutas específicas para el estudiante:

```dart
// Lista de anteproyectos
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

    // Para estudiantes - usar MyAnteprojectsList
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

---

## 9. Permisos y Seguridad

### 9.1. Verificación de Rol

El sistema verifica el rol del estudiante antes de permitir acciones:

```dart
// En el servicio de anteproyectos
Future<List<Anteproject>> getStudentAnteprojects() async {
  final user = _supabase.auth.currentUser;
  if (user == null) {
    throw AuthenticationException('not_authenticated', ...);
  }

  // Obtener el ID del estudiante
  final userResponse = await _supabase
      .from('users')
      .select('id')
      .eq('email', user.email!)
      .single();

  final studentId = userResponse['id'] as int;

  // Solo obtener anteproyectos del estudiante
  final response = await _supabase
      .from('anteproject_students')
      .select('anteproject_id, anteprojects!inner(*)')
      .eq('student_id', studentId);

  return response.map((row) {
    return Anteproject.fromJson(row['anteprojects'] as Map<String, dynamic>);
  }).toList();
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 1093-1120 (aproximadamente)

### 9.2. Row Level Security (RLS)

Las políticas RLS en la base de datos aseguran que los estudiantes solo vean sus propios datos:

```sql
-- Política para que estudiantes vean solo sus anteproyectos
CREATE POLICY "Students can view their own anteprojects" ON anteprojects
    FOR SELECT USING (
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

### 9.3. Restricción de Edición

Los estudiantes solo pueden editar sus propios anteproyectos cuando están en estado `draft` o `changes_requested`:

```dart
// En el servicio de anteproyectos
Future<void> updateAnteproject(Anteproject anteproject) async {
  // Verificar que el estudiante es el dueño
  final user = _supabase.auth.currentUser;
  final userResponse = await _supabase
      .from('users')
      .select('id')
      .eq('email', user!.email!)
      .single();

  final studentId = userResponse['id'] as int;

  // Verificar que el anteproyecto pertenece al estudiante
  final relationship = await _supabase
      .from('anteproject_students')
      .select('*')
      .eq('anteproject_id', anteproject.id)
      .eq('student_id', studentId)
      .single();

  if (relationship == null) {
    throw AuthenticationException('unauthorized', ...);
  }

  // Verificar que el estado permite edición
  if (anteproject.status != AnteprojectStatus.draft &&
      anteproject.status != AnteprojectStatus.changesRequested) {
    throw ValidationException('anteproject_not_editable', ...);
  }

  // Actualizar anteproyecto
  // ...
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 400-500 (aproximadamente)

---

## Resumen del Flujo del Estudiante

### Flujo Principal

```
1. Login exitoso
   ↓
2. Redirección a /dashboard/student
   ↓
3. Carga de datos:
   - Anteproyectos (pendientes, aprobados, rechazados)
   - Proyectos activos
   - Tareas (pendientes, en progreso, completadas)
   ↓
4. Dashboard muestra:
   - Estadísticas (anteproyectos, proyectos, tareas)
   - Acciones rápidas
   - Anteproyectos pendientes
   - Proyectos activos
   - Tareas próximas
   ↓
5. Acciones disponibles:
   - Crear anteproyecto
   - Enviar anteproyecto para revisión
   - Gestionar tareas
   - Usar tablero Kanban
   - Comunicarse con tutor
   - Ver proyectos activos
```

### Puntos Clave

- **Autonomía**: El estudiante gestiona su propio trabajo de manera autónoma
- **Creación de anteproyectos**: Puede crear y enviar anteproyectos para revisión
- **Gestión de tareas**: Puede crear y gestionar sus propias tareas
- **Tablero Kanban**: Visualización ágil del estado de las tareas
- **Comunicación**: Puede comunicarse con su tutor mediante mensajería
- **Seguridad**: Las políticas RLS aseguran que solo vea sus propios datos

---

**Última actualización**: Noviembre 2025  
**Versión del documento**: 1.0

