# Ciclo de Vida del Proyecto - Documentación Técnica

Este documento explica detalladamente el funcionamiento completo del ciclo de vida del **Proyecto** en la aplicación, basado en el código fuente real del proyecto.

## Tabla de Contenidos

1. [Introducción](#1-introducción)
2. [Estados del Proyecto](#2-estados-del-proyecto)
3. [Creación Automática del Proyecto](#3-creación-automática-del-proyecto)
4. [Transiciones de Estado](#4-transiciones-de-estado)
5. [Gestión del Proyecto](#5-gestión-del-proyecto)
6. [Relación con Anteproyectos](#6-relación-con-anteproyectos)
7. [Relación con Tareas](#7-relación-con-tareas)
8. [Modelo de Datos](#8-modelo-de-datos)
9. [Permisos y Seguridad](#9-permisos-y-seguridad)

---

## 1. Introducción

El proyecto es la entidad principal que representa el Trabajo de Fin de Grado en fase de desarrollo. Un proyecto se crea **automáticamente** cuando un anteproyecto es aprobado por el tutor. El proyecto pasa por varios estados a medida que el estudiante avanza en su desarrollo.

**Flujo general:**
```
Anteproyecto Aprobado → Proyecto Creado (planning) → Desarrollo → Revisión → Completado
```

---

## 2. Estados del Proyecto

El modelo `Project` define los siguientes estados posibles:

| Estado | Valor en BD | Descripción |
| :--- | :--- | :--- |
| **Borrador** | `draft` | Estado inicial del proyecto (puede no usarse activamente). |
| **Planificación** | `planning` | El proyecto está en fase de planificación. El estudiante define tareas y hitos. Es el estado inicial cuando se crea desde un anteproyecto aprobado. |
| **Desarrollo** | `development` | El proyecto está en fase de desarrollo activo. El estudiante trabaja en las tareas. |
| **Revisión** | `review` | El proyecto está en fase de revisión por el tutor. |
| **Completado** | `completed` | El proyecto ha sido finalizado y entregado. |

**Referencia de código:**
- Archivo: `frontend/lib/models/project.dart`
- Líneas: 91-102

```dart
enum ProjectStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('planning')
  planning,
  @JsonValue('development')
  development,
  @JsonValue('review')
  review,
  @JsonValue('completed')
  completed,
}
```

---

## 3. Creación Automática del Proyecto

### 3.1. Trigger de Creación

Cuando un anteproyecto es aprobado, el sistema crea automáticamente un proyecto asociado:

```dart
Future<void> approveAnteproject(
  int id,
  String comments, {
  Map<String, dynamic>? timeline,
}) async {
  // ... aprobar anteproyecto ...

  // Crear proyecto automáticamente basado en el anteproyecto aprobado
  await _createProjectFromAnteproject(
    anteprojectId: id,
    title: anteprojectTitle,
    description: anteprojectDescription ?? '',
    tutorId: tutorId,
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 682-749

### 3.2. Proceso de Creación

El método `_createProjectFromAnteproject` crea el proyecto con estado inicial `planning`:

```dart
Future<void> _createProjectFromAnteproject({
  required int anteprojectId,
  required String title,
  required String description,
  required int tutorId,
}) async {
  try {
    // Verificar si ya existe un proyecto para este anteproyecto
    final existingProject = await _supabase
        .from('projects')
        .select('id')
        .eq('anteproject_id', anteprojectId)
        .maybeSingle();

    if (existingProject != null) {
      // Ya existe, solo actualizar la referencia
      await _supabase
          .from('anteprojects')
          .update({'project_id': existingProject['id']})
          .eq('id', anteprojectId);
      return;
    }

    // Obtener el estudiante autor del anteproyecto
    final studentResponse = await _supabase
        .from('anteproject_students')
        .select('student_id')
        .eq('anteproject_id', anteprojectId)
        .eq('is_lead_author', true)
        .maybeSingle();

    final studentId = studentResponse?['student_id'] as int?;

    // Crear el proyecto con la referencia al anteproyecto
    final projectData = {
      'title': title,
      'description': description,
      'tutor_id': tutorId,
      'anteproject_id': anteprojectId, // Vincular con el anteproyecto
      'status': 'planning', // Estado inicial: planning
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final projectResponse = await _supabase
        .from('projects')
        .insert(projectData)
        .select()
        .single();

    final projectId = projectResponse['id'] as int;

    // Actualizar el project_id en el anteproyecto para vincularlos
    await _supabase
        .from('anteprojects')
        .update({
          'project_id': projectId,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', anteprojectId);

    // Crear la relación estudiante-proyecto si existe estudiante
    if (studentId != null) {
      await _supabase.from('project_students').insert({
        'project_id': projectId,
        'student_id': studentId,
        'is_lead': true,
        'joined_at': DateTime.now().toIso8601String(),
      });
    }
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 1329-1428

### 3.3. Relación con Anteproyecto

El proyecto mantiene una relación bidireccional con el anteproyecto:

- El proyecto tiene `anteproject_id` que referencia al anteproyecto
- El anteproyecto tiene `project_id` que referencia al proyecto creado

```dart
// Actualizar el project_id en el anteproyecto
await _supabase
    .from('anteprojects')
    .update({
      'project_id': projectId,
      'updated_at': DateTime.now().toIso8601String(),
    })
    .eq('id', anteprojectId);
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 1392-1399

---

## 4. Transiciones de Estado

Esta sección describe qué acciones provocan un cambio de estado y qué roles pueden realizar esas acciones.

| Transición | Acción | Rol | Descripción |
| :--- | :--- | :--- | :--- |
| Creación → `planning` | Aprobación de anteproyecto | Sistema (automático) | Cuando el tutor aprueba un anteproyecto, se crea un proyecto en estado `planning`. |
| `planning` → `development` | Iniciar desarrollo | Estudiante | El estudiante comienza el desarrollo del proyecto. |
| `development` → `review` | Solicitar revisión | Estudiante | El estudiante solicita una revisión del proyecto al tutor. |
| `review` → `development` | Solicitar cambios | Tutor | El tutor solicita cambios y el proyecto vuelve a desarrollo. |
| `review` → `completed` | Aprobar proyecto | Tutor | El tutor aprueba el proyecto y lo marca como completado. |

**Diagrama de flujo:**
```
[planning] --iniciar desarrollo--> [development]
[development] --solicitar revisión--> [review]
[review] --solicitar cambios--> [development]
[review] --aprobar--> [completed]
```

**Nota:** Las transiciones exactas pueden variar según la implementación actual del sistema. Es importante verificar el código para confirmar el flujo exacto.

---

## 5. Gestión del Proyecto

### 5.1. Obtención de Proyectos del Estudiante

El estudiante puede obtener sus proyectos activos:

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

### 5.2. Obtención de Proyectos del Tutor

El tutor puede obtener los proyectos de sus estudiantes asignados:

```dart
Future<List<Map<String, dynamic>>> getTutorProjects() async {
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
        .from('projects')
        .select('''
          *,
          anteprojects(
            id,
            title,
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
          )
        ''')
        .eq('tutor_id', tutorId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    throw DatabaseException('Error in getTutorProjects: $e', ...);
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/projects_service.dart`
- Líneas: 300-400 (aproximadamente)

### 5.3. Actualización del Estado

El estado del proyecto se puede actualizar mediante el servicio:

```dart
Future<Project> updateProject(int id, Project project) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    final data = project.toJson();
    data.remove('id');
    data.remove('created_at');
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('projects')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Project.fromJson(response);
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/projects_service.dart`
- Líneas: 250-300 (aproximadamente)

---

## 6. Relación con Anteproyectos

### 6.1. Obtención del Anteproyecto Asociado

Se puede obtener el anteproyecto asociado a un proyecto:

```dart
Future<Anteproject?> getAnteprojectFromProject(int projectId) async {
  try {
    final projectResponse = await _supabase
        .from('projects')
        .select('anteproject_id')
        .eq('id', projectId)
        .single();

    final anteprojectId = projectResponse['anteproject_id'] as int?;
    if (anteprojectId == null) return null;

    final anteprojectResponse = await _supabase
        .from('anteprojects')
        .select('*')
        .eq('id', anteprojectId)
        .single();

    return Anteproject.fromJson(anteprojectResponse);
  } catch (e) {
    return null;
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/projects_service.dart`
- Líneas: 176-210 (aproximadamente)

### 6.2. Unicidad de la Relación

Un anteproyecto solo puede tener un proyecto asociado:

```dart
// Verificar si ya existe un proyecto para este anteproyecto
final existingProject = await _supabase
    .from('projects')
    .select('id')
    .eq('anteproject_id', anteprojectId)
    .maybeSingle();

if (existingProject != null) {
  // Ya existe, solo actualizar la referencia
  await _supabase
      .from('anteprojects')
      .update({'project_id': existingProject['id']})
      .eq('id', anteprojectId);
  return;
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 1337-1354

---

## 7. Relación con Tareas

### 7.1. Tareas del Proyecto

Las tareas se asocian a proyectos mediante el campo `project_id`:

```dart
Future<List<Task>> getProjectTasks(int projectId) async {
  try {
    final response = await _supabase
        .from('tasks')
        .select('*')
        .eq('project_id', projectId)
        .order('kanban_position', ascending: true);

    return response.map((row) {
      return Task.fromJson(row as Map<String, dynamic>);
    }).toList();
  } catch (e) {
    throw DatabaseException('Error getting project tasks: $e', ...);
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/tasks_service.dart`
- Líneas: 150-200 (aproximadamente)

### 7.2. Progreso del Proyecto

El progreso del proyecto está directamente relacionado con el estado de las tareas asociadas. El sistema puede calcular el progreso basándose en las tareas completadas:

```dart
// Ejemplo de cálculo de progreso (pseudocódigo)
double calculateProjectProgress(List<Task> tasks) {
  if (tasks.isEmpty) return 0.0;
  
  final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
  return completedTasks / tasks.length * 100;
}
```

---

## 8. Modelo de Datos

### 8.1. Estructura del Modelo

El modelo `Project` contiene la siguiente información:

```dart
class Project {
  final int id;
  final String title;
  final String description;
  final ProjectStatus status;
  final DateTime? startDate;
  final DateTime? estimatedEndDate;
  final DateTime? actualEndDate;
  final int tutorId;
  final int? anteprojectId; // Referencia al anteproyecto
  final String? githubRepositoryUrl;
  final String githubMainBranch;
  final DateTime? lastActivityAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Referencia de código:**
- Archivo: `frontend/lib/models/project.dart`
- Líneas: 6-37

### 8.2. Relación con Estudiantes

Los proyectos se relacionan con estudiantes mediante la tabla `project_students`:

```dart
// Al crear un proyecto desde un anteproyecto aprobado
if (studentId != null) {
  await _supabase.from('project_students').insert({
    'project_id': projectId,
    'student_id': studentId,
    'is_lead': true,
    'joined_at': DateTime.now().toIso8601String(),
  });
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 1402-1417

---

## 9. Permisos y Seguridad

### 9.1. Row Level Security (RLS)

Las políticas RLS aseguran que cada usuario solo vea sus propios proyectos:

```sql
-- Política para que estudiantes vean solo sus proyectos
CREATE POLICY "Students can view their own projects" ON projects
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM project_students
            WHERE project_id = projects.id
            AND student_id = public.user_id()
        )
    );

-- Política para que tutores vean solo sus proyectos asignados
CREATE POLICY "Tutors can view their own projects" ON projects
    FOR SELECT USING (
        public.user_id() = tutor_id
    );
```

**Referencia de código:**
- Archivo: `docs/base_datos/migraciones/20240815000004_configure_rls_fixed.sql`
- Líneas: 200-250 (aproximadamente)

### 9.2. Verificación de Propiedad

El sistema verifica que el estudiante sea el dueño del proyecto antes de permitir modificaciones:

```dart
// Verificar que el estudiante es el dueño
final relationship = await _supabase
    .from('project_students')
    .select('*')
    .eq('project_id', project.id)
    .eq('student_id', studentId)
    .single();

if (relationship == null) {
  throw AuthenticationException('unauthorized', ...);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/projects_service.dart`
- Líneas: 300-400 (aproximadamente)

---

## Resumen del Flujo del Proyecto

### Flujo Principal

```
1. Anteproyecto aprobado por tutor
   ↓
2. Sistema crea proyecto automáticamente
   ↓ Estado: planning
   ↓ Relación: anteproject_id vinculado
   ↓ Relación: project_students creada
   ↓
3. Estudiante inicia desarrollo
   ↓ Estado: development
   ↓
4. Estudiante crea y gestiona tareas
   ↓ Tareas asociadas al proyecto
   ↓
5. Estudiante solicita revisión
   ↓ Estado: review
   ↓
6. Tutor revisa proyecto
   ↓ Opciones:
   ├─ Solicitar cambios → Estado: development (vuelve al paso 4)
   └─ Aprobar → Estado: completed
```

### Puntos Clave

- **Creación automática**: Los proyectos se crean automáticamente cuando se aprueba un anteproyecto
- **Estado inicial**: Todos los proyectos comienzan en estado `planning`
- **Relación con anteproyecto**: Cada proyecto está vinculado a un anteproyecto aprobado
- **Gestión de tareas**: Las tareas se asocian a proyectos para gestionar el trabajo
- **Progreso**: El progreso del proyecto se relaciona con el estado de las tareas

---

**Última actualización**: Noviembre 2025  
**Versión del documento**: 1.0

