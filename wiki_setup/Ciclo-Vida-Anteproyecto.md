# Ciclo de Vida del Anteproyecto - Documentación Técnica

Este documento explica detalladamente el funcionamiento completo del ciclo de vida del **Anteproyecto** en la aplicación, basado en el código fuente real del proyecto.

## Tabla de Contenidos

1. [Introducción](#1-introducción)
2. [Estados del Anteproyecto](#2-estados-del-anteproyecto)
3. [Transiciones de Estado](#3-transiciones-de-estado)
4. [Creación del Anteproyecto](#4-creación-del-anteproyecto)
5. [Envío para Revisión](#5-envío-para-revisión)
6. [Revisión por el Tutor](#6-revisión-por-el-tutor)
7. [Aprobación y Creación de Proyecto](#7-aprobación-y-creación-de-proyecto)
8. [Rechazo y Solicitud de Cambios](#8-rechazo-y-solicitud-de-cambios)
9. [Modelo de Datos](#9-modelo-de-datos)
10. [Permisos y Seguridad](#10-permisos-y-seguridad)

---

## 1. Introducción

El anteproyecto es el documento inicial que un estudiante debe crear para proponer su Trabajo de Fin de Grado. El anteproyecto pasa por varios estados a medida que es revisado y aprobado por el tutor asignado. Una vez aprobado, se crea automáticamente un proyecto asociado.

**Flujo general:**
```
Creación → Borrador → Enviado → En Revisión → Aprobado/Rechazado
                                              ↓
                                         Proyecto Creado
```

---

## 2. Estados del Anteproyecto

El modelo `Anteproject` define los siguientes estados posibles:

| Estado | Valor en BD | Descripción |
| :--- | :--- | :--- |
| **Borrador** | `draft` | El anteproyecto está en proceso de creación o edición por el estudiante. Es el estado inicial. |
| **Enviado** | `submitted` | El estudiante ha enviado el anteproyecto para revisión. El anteproyecto no es editable en este estado. |
| **En Revisión** | `under_review` | El tutor está revisando el anteproyecto. También se usa cuando el tutor solicita cambios. |
| **Aprobado** | `approved` | El tutor ha aprobado el anteproyecto. Se crea automáticamente un proyecto asociado. |
| **Rechazado** | `rejected` | El tutor ha rechazado el anteproyecto. El estudiante debe crear un nuevo anteproyecto. |

**Referencia de código:**
- Archivo: `frontend/lib/models/anteproject.dart`
- Líneas: 167-188

```dart
enum AnteprojectStatus {
  /// Borrador inicial, editable por el estudiante.
  @JsonValue('draft')
  draft,

  /// Enviado para revisión, no editable por el estudiante.
  @JsonValue('submitted')
  submitted,

  /// En revisión por el tutor asignado.
  @JsonValue('under_review')
  underReview,

  /// Aprobado por el tutor, puede convertirse en proyecto.
  @JsonValue('approved')
  approved,

  /// Rechazado con comentarios del tutor.
  @JsonValue('rejected')
  rejected,
}
```

---

## 3. Transiciones de Estado

Esta sección describe qué acciones provocan un cambio de estado y qué roles pueden realizar esas acciones.

| Transición | Acción | Rol | Descripción |
| :--- | :--- | :--- | :--- |
| `draft` → `submitted` | Enviar anteproyecto | Estudiante | El estudiante completa el anteproyecto y lo envía para revisión. |
| `submitted` → `under_review` | Solicitar cambios | Tutor | El tutor revisa el anteproyecto y solicita modificaciones. |
| `under_review` → `submitted` | Reenviar anteproyecto | Estudiante | El estudiante realiza los cambios solicitados y vuelve a enviar el anteproyecto. |
| `submitted` → `approved` | Aprobar anteproyecto | Tutor | El tutor aprueba el anteproyecto. Se crea un proyecto automáticamente. |
| `submitted` → `rejected` | Rechazar anteproyecto | Tutor | El tutor rechaza el anteproyecto con comentarios. |

**Diagrama de flujo:**
```
[draft] --enviar--> [submitted]
[submitted] --solicitar cambios--> [under_review]
[under_review] --reenviar--> [submitted]
[submitted] --aprobar--> [approved] --> [Proyecto Creado]
[submitted] --rechazar--> [rejected]
```

---

## 4. Creación del Anteproyecto

### 4.1. Acceso al Formulario

El estudiante accede al formulario de creación desde su dashboard o desde la lista de anteproyectos:

```dart
void _createAnteproject() {
  context.go('/anteprojects', extra: widget.user);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/dashboard/student_dashboard_screen.dart`
- Líneas: 774-777

### 4.2. Formulario de Creación

El formulario `AnteprojectForm` permite crear un nuevo anteproyecto:

```dart
class AnteprojectForm extends StatefulWidget {
  const AnteprojectForm({super.key});
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/forms/anteproject_form.dart`
- Líneas: 17-22

### 4.3. Campos del Formulario

El formulario incluye los siguientes campos:

- **Título**: Título del proyecto (requerido)
- **Descripción**: Descripción detallada (mínimo 200 palabras)
- **Tipo de Proyecto**: Ejecución, Investigación, Bibliográfico, Gestión
- **Objetivos**: Objetivos específicos del proyecto
- **Año Académico**: Año académico del proyecto
- **URL del Repositorio de GitHub**: URL del repositorio de GitHub asociado al anteproyecto (opcional, formato: `https://github.com/usuario/repositorio`)
- **Hitos**: Resultados esperados con fechas

```dart
final TextEditingController _titleController = TextEditingController();
final TextEditingController _descriptionController = TextEditingController();
final TextEditingController _academicYearController = TextEditingController();
final TextEditingController _objectivesController = TextEditingController();
final TextEditingController _githubRepositoryController = TextEditingController();
ProjectType? _projectType = ProjectType.execution;
List<Hito> _hitos = [];
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/forms/anteproject_form.dart`
- Líneas: 28-36

### 4.4. Guardado como Borrador

El estudiante puede guardar el anteproyecto como borrador para continuar editándolo más tarde:

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
    status: AnteprojectStatus.draft, // Estado borrador
    academicYear: _academicYearController.text.trim(),
    objectives: _objectivesController.text.trim(),
    githubRepositoryUrl: _githubRepositoryController.text.trim().isEmpty
        ? null
        : _githubRepositoryController.text.trim(),
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

### 4.5. Validación de Anteproyecto Aprobado

Antes de crear un nuevo anteproyecto, el sistema verifica si el estudiante ya tiene uno aprobado:

```dart
// Verificar si el estudiante ya tiene un anteproyecto aprobado
if (userRole == 'student') {
  final hasApproved = await hasApprovedAnteproject();
  if (hasApproved) {
    throw ValidationException(
      'cannot_create_anteproject_with_approved',
      technicalMessage:
          'No puedes crear un nuevo anteproyecto porque ya tienes uno aprobado. Debes desarrollar el proyecto asociado.',
    );
  }
}
```

**Regla de negocio**: Un estudiante solo puede tener un anteproyecto aprobado a la vez. Si ya tiene uno aprobado, debe trabajar en el proyecto asociado antes de crear un nuevo anteproyecto.

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 447-457

### 4.6. Creación en la Base de Datos

El servicio `AnteprojectsService` crea el anteproyecto en la base de datos:

```dart
Future<Anteproject> createAnteproject(Anteproject anteproject) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    // Obtener información del usuario actual
    final userResponse = await _supabase
        .from('users')
        .select('id, role, tutor_id')
        .eq('email', user.email!)
        .single();

    final userId = userResponse['id'] as int;
    final userRole = userResponse['role'] as String;
    final tutorId = userResponse['tutor_id'] as int?;

    // Verificar si el estudiante ya tiene un anteproyecto aprobado
    if (userRole == 'student') {
      final hasApproved = await hasApprovedAnteproject();
      if (hasApproved) {
        throw ValidationException(
          'cannot_create_anteproject_with_approved',
          technicalMessage:
              'No puedes crear un nuevo anteproyecto porque ya tienes uno aprobado.',
        );
      }
    }

    final data = anteproject.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');

    // Asignar tutor automáticamente
    if (userRole == 'student' && tutorId != null) {
      data['tutor_id'] = tutorId;
    }

    final response = await _supabase
        .from('anteprojects')
        .insert(data)
        .select()
        .single();

    final createdAnteproject = Anteproject.fromJson(response);
    final anteprojectId = createdAnteproject.id;

    // Si es un estudiante, crear la relación en anteproject_students
    if (userRole == 'student') {
      await _supabase.from('anteproject_students').insert({
        'anteproject_id': anteprojectId,
        'student_id': userId,
        'is_lead_author': true,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return createdAnteproject;
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 416-526

---

## 5. Envío para Revisión

### 5.1. Acción de Envío

Cuando el anteproyecto está completo, el estudiante lo envía para revisión:

```dart
void _submitForReview() {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final anteproject = Anteproject(
    id: _anteprojectId,
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
    AnteprojectUpdateRequested(anteproject),
  );
}
```

**Referencia de código:**
- Archivo: `frontend/lib/screens/forms/anteproject_form.dart`
- Líneas: 250-300 (aproximadamente)

### 5.2. Validación de Anteproyecto Aprobado

Antes de enviar un anteproyecto para revisión, el sistema verifica si el estudiante ya tiene uno aprobado:

```dart
// Verificar si el estudiante ya tiene un anteproyecto aprobado
if (userRole == 'student') {
  final hasApproved = await hasApprovedAnteproject();
  if (hasApproved) {
    throw ValidationException(
      'cannot_submit_anteproject_with_approved',
      technicalMessage:
          'No puedes enviar este anteproyecto porque ya tienes uno aprobado. Debes desarrollar el proyecto asociado.',
    );
  }
}
```

**Regla de negocio**: Un estudiante no puede enviar un anteproyecto para revisión si ya tiene uno aprobado. Debe completar el proyecto asociado primero.

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 682-692

### 5.3. Actualización del Estado

El servicio actualiza el estado del anteproyecto a `submitted`:

```dart
Future<void> submitAnteproject(int id) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    // Obtener información del usuario actual
    final userResponse = await _supabase
        .from('users')
        .select('id, role')
        .eq('email', user.email!)
        .single();

    final userRole = userResponse['role'] as String;

    // Verificar si el estudiante ya tiene un anteproyecto aprobado
    if (userRole == 'student') {
      final hasApproved = await hasApprovedAnteproject();
      if (hasApproved) {
        throw ValidationException(
          'cannot_submit_anteproject_with_approved',
          technicalMessage:
              'No puedes enviar este anteproyecto porque ya tienes uno aprobado.',
        );
      }
    }

    await _supabase
        .from('anteprojects')
        .update({
          'status': 'submitted',
          'submitted_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);

    // Enviar notificación al tutor
    await _notifyTutorOnSubmission(id);
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 636-675

### 5.4. Restricciones de Edición

Una vez enviado, el anteproyecto no es editable por el estudiante hasta que el tutor solicite cambios:

```dart
// En el servicio de anteproyectos
Future<void> updateAnteproject(int id, Anteproject anteproject) async {
  // Verificar que el estado permite edición
  final currentAnteproject = await getAnteproject(id);
  
  if (currentAnteproject.status != AnteprojectStatus.draft &&
      currentAnteproject.status != AnteprojectStatus.underReview) {
    throw ValidationException('anteproject_not_editable', ...);
  }

  // Actualizar anteproyecto
  // ...
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 528-634

---

## 6. Revisión por el Tutor

### 6.1. Acceso a Anteproyectos Pendientes

El tutor puede acceder a los anteproyectos pendientes de revisión:

```dart
Future<List<Map<String, dynamic>>> getPendingApprovals({int? tutorId}) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    int userIdToFilter;
    if (tutorId != null) {
      userIdToFilter = tutorId;
    } else {
      final userResponse = await _supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();
      userIdToFilter = userResponse['id'] as int;
    }

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
        .inFilter('status', ['submitted', 'under_review'])
        .eq('tutor_id', userIdToFilter)
        .order('submitted_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/approval_service.dart`
- Líneas: 235-280 (aproximadamente)

---

## 7. Aprobación y Creación de Proyecto

### 7.1. Aprobación por el Tutor

El tutor puede aprobar un anteproyecto mediante el servicio de aprobación:

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

### 7.2. Actualización del Estado

El servicio actualiza el estado del anteproyecto a `approved`:

```dart
Future<void> approveAnteproject(
  int id,
  String comments, {
  Map<String, dynamic>? timeline,
}) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    // Obtener información del anteproyecto antes de aprobarlo
    final anteprojectResponse = await _supabase
        .from('anteprojects')
        .select('title, description, tutor_id')
        .eq('id', id)
        .single();

    final anteprojectTitle = anteprojectResponse['title'] as String;
    final anteprojectDescription = anteprojectResponse['description'] as String?;
    final tutorId = anteprojectResponse['tutor_id'] as int;

    // Preparar datos de actualización
    final updateData = <String, dynamic>{
      'status': 'approved',
      'reviewed_at': DateTime.now().toIso8601String(),
      'tutor_comments': comments,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Aprobar el anteproyecto
    await _supabase.from('anteprojects').update(updateData).eq('id', id);

    // Crear proyecto automáticamente basado en el anteproyecto aprobado
    await _createProjectFromAnteproject(
      anteprojectId: id,
      title: anteprojectTitle,
      description: anteprojectDescription ?? '',
      tutorId: tutorId,
    );
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 682-749

### 7.3. Creación Automática del Proyecto

Cuando un anteproyecto es aprobado, se crea automáticamente un proyecto:

```dart
Future<void> _createProjectFromAnteproject({
  required int anteprojectId,
  required String title,
  required String description,
  required int tutorId,
}) async {
  try {
    // Crear proyecto con estado 'planning'
    final projectResponse = await _supabase
        .from('projects')
        .insert({
          'anteproject_id': anteprojectId,
          'title': title,
          'description': description,
          'status': 'planning',
          'tutor_id': tutorId,
          'github_main_branch': 'main',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final projectId = projectResponse['id'] as int;

    // Actualizar el anteproyecto con el ID del proyecto creado
    await _supabase
        .from('anteprojects')
        .update({'project_id': projectId})
        .eq('id', anteprojectId);

    debugPrint('✅ Proyecto creado automáticamente: $projectId');
  } catch (e) {
    debugPrint('❌ Error creando proyecto desde anteproyecto: $e');
    throw BusinessLogicException(
      'project_creation_failed',
      technicalMessage: 'Error creating project from anteproject: $e',
      originalError: e,
    );
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 850-900 (aproximadamente)

---

## 8. Rechazo y Solicitud de Cambios

### 8.1. Rechazo del Anteproyecto

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
- Líneas: 102-171

### 8.2. Actualización del Estado a Rechazado

El servicio actualiza el estado del anteproyecto a `rejected`:

```dart
Future<void> rejectAnteproject(int id, String comments) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    await _supabase
        .from('anteprojects')
        .update({
          'status': 'rejected',
          'reviewed_at': DateTime.now().toIso8601String(),
          'tutor_comments': comments,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 751-788

### 8.3. Solicitud de Cambios

El tutor puede solicitar cambios en un anteproyecto, lo que cambia el estado a `under_review`:

```dart
Future<ApprovalResult> requestChanges(
  int anteprojectId,
  String comments,
) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthenticationException('not_authenticated', ...);
    }

    if (comments.trim().isEmpty) {
      throw const ApprovalException(
        'Los comentarios son obligatorios para solicitar cambios',
      );
    }

    // Actualizar el anteproyecto directamente en la base de datos
    await _supabase
        .from('anteprojects')
        .update({
          'status': 'under_review',
          'tutor_comments': comments,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', anteprojectId);

    // Crear resultado de solicitud de cambios
    final result = ApprovalResult(
      success: true,
      message: 'Cambios solicitados al estudiante',
      anteprojectId: anteprojectId,
    );

    // Enviar email de notificación al estudiante
    await _sendStatusChangeEmail(anteprojectId, 'changes_requested', comments);

    return result;
  } catch (e) {
    // Manejo de errores
  }
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/approval_service.dart`
- Líneas: 173-233

**Nota importante:** Cuando el tutor solicita cambios, el estado cambia a `under_review`, lo que permite que el estudiante edite el anteproyecto nuevamente. Una vez que el estudiante realiza los cambios y reenvía, el estado vuelve a `submitted`.

---

## 9. Modelo de Datos

### 9.1. Estructura del Modelo

El modelo `Anteproject` contiene la siguiente información:

```dart
class Anteproject {
  final int id;
  final String title;
  final ProjectType projectType;
  final String description;
  final String academicYear;
  final String? objectives;
  final Map<String, dynamic> expectedResults;
  final Map<String, dynamic> timeline;
  final AnteprojectStatus status;
  final int? tutorId;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final int? projectId; // ID del proyecto creado cuando se aprueba
  final String? tutorComments;
  final String? githubRepositoryUrl; // URL del repositorio de GitHub
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Referencia de código:**
- Archivo: `frontend/lib/models/anteproject.dart`
- Líneas: 45-90

### 9.2. Relación con Estudiantes

Los anteproyectos se relacionan con estudiantes mediante la tabla `anteproject_students`:

```dart
// Al crear un anteproyecto, se crea la relación
if (userRole == 'student') {
  await _supabase.from('anteproject_students').insert({
    'anteproject_id': anteprojectId,
    'student_id': userId,
    'is_lead_author': true,
    'created_at': DateTime.now().toIso8601String(),
  });
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 486-504

### 9.3. Relación con Proyectos

Cuando un anteproyecto es aprobado, se crea un proyecto y se establece la relación:

```dart
// Actualizar el anteproyecto con el ID del proyecto creado
await _supabase
    .from('anteprojects')
    .update({'project_id': projectId})
    .eq('id', anteprojectId);
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 850-900 (aproximadamente)

---

## 10. Permisos y Seguridad

### 10.1. Restricciones de Edición

Los estudiantes solo pueden editar anteproyectos en estados `draft` o `under_review`:

```dart
// Verificación en el servicio
Future<void> updateAnteproject(int id, Anteproject anteproject) async {
  // Obtener el anteproyecto actual
  final currentAnteproject = await getAnteproject(id);
  
  // Verificar que el estado permite edición
  if (currentAnteproject.status != AnteprojectStatus.draft &&
      currentAnteproject.status != AnteprojectStatus.underReview) {
    throw ValidationException(
      'anteproject_not_editable',
      technicalMessage: 'Anteproyecto no editable en estado ${currentAnteproject.status}',
    );
  }

  // Continuar con la actualización
  // ...
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 528-634

### 10.2. Row Level Security (RLS)

Las políticas RLS aseguran que cada usuario solo vea sus propios anteproyectos:

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

-- Política para que tutores vean solo sus anteproyectos asignados
CREATE POLICY "Tutors can view their own anteprojects" ON anteprojects
    FOR SELECT USING (
        public.user_id() = tutor_id
    );
```

**Referencia de código:**
- Archivo: `docs/base_datos/migraciones/schema_completo.sql` (sección RLS)
- Líneas: 141-145

### 10.3. Verificación de Propiedad

El sistema verifica que el estudiante sea el dueño del anteproyecto antes de permitir ediciones:

```dart
// Verificar que el estudiante es el dueño
final relationship = await _supabase
    .from('anteproject_students')
    .select('*')
    .eq('anteproject_id', anteproject.id)
    .eq('student_id', studentId)
    .single();

if (relationship == null) {
  throw AuthenticationException('unauthorized', ...);
}
```

**Referencia de código:**
- Archivo: `frontend/lib/services/anteprojects_service.dart`
- Líneas: 400-500 (aproximadamente)

---

## Resumen del Flujo del Anteproyecto

### Flujo Principal

```
1. Estudiante crea anteproyecto
   ↓ Verificación: ¿Tiene anteproyecto aprobado?
   ├─ SÍ → Error: No puede crear (debe trabajar en proyecto aprobado)
   └─ NO → Continúa
   ↓ Estado: draft
   ↓
2. Estudiante completa información
   ↓ Puede guardar como borrador múltiples veces
   ↓ Incluye: título, descripción, tipo, objetivos, año académico, URL de GitHub, hitos
   ↓
3. Estudiante envía para revisión
   ↓ Verificación: ¿Tiene anteproyecto aprobado?
   ├─ SÍ → Error: No puede enviar (debe trabajar en proyecto aprobado)
   └─ NO → Continúa
   ↓ Estado: submitted
   ↓ Notificación al tutor
   ↓
4. Tutor revisa el anteproyecto
   ↓ Opciones:
   ├─ Aprobar → Estado: approved → Proyecto creado automáticamente
   ├─ Rechazar → Estado: rejected → Estudiante debe crear nuevo
   └─ Solicitar cambios → Estado: under_review → Estudiante puede editar
   ↓
5. Si se solicitaron cambios:
   ↓ Estudiante edita y reenvía
   ↓ Estado: submitted (vuelve al paso 4)
```

### Puntos Clave

- **Estado inicial**: Todos los anteproyectos comienzan en estado `draft`
- **Asignación automática**: El tutor se asigna automáticamente según el estudiante
- **Creación de proyecto**: Cuando se aprueba, se crea automáticamente un proyecto
- **Restricciones de edición**: Solo editable en estados `draft` y `under_review`
- **Restricción de un solo anteproyecto aprobado**: Un estudiante solo puede tener un anteproyecto aprobado a la vez. Si ya tiene uno aprobado, no puede crear ni enviar nuevos anteproyectos hasta completar el proyecto asociado.
- **Campo GitHub Repository**: Los estudiantes pueden incluir la URL del repositorio de GitHub al crear o editar un anteproyecto (opcional)
- **Notificaciones**: Se envían emails al tutor cuando se envía y al estudiante cuando se revisa

---

**Última actualización**: Diciembre 2025  
**Versión del documento**: 1.1

