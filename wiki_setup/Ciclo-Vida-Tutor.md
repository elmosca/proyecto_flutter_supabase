# Ciclo de Vida del Tutor

Aquí explico cómo funciona el panel de tutor y qué puede hacer un usuario con rol de tutor en la aplicación.

> Si necesitas una visión más general de la arquitectura, puedes consultar la página de [Arquitectura del Sistema](01-Arquitectura).

## Índice

1.  Dashboard del tutor
2.  Gestión de estudiantes
3.  Revisión de anteproyectos
4.  Comunicación con estudiantes
5.  Permisos y seguridad

---

## 1. Dashboard del Tutor

### 1.1. Acceso al dashboard

Cuando un tutor hace login, el `AppRouter` lo redirige a `/dashboard/tutor`.

### 1.2. Carga de datos iniciales

El `TutorDashboard` carga varias estadísticas en paralelo:

- Estadísticas del tutor (cuántos estudiantes tiene, cuántos anteproyectos pendientes, etc.)
- Lista de estudiantes asignados
- Lista de anteproyectos pendientes de revisión

```dart
Future<void> _loadData() async {
  try {
    final futures = await Future.wait([
      _statsService.getTutorStats(widget.user.id),
      _studentsService.getTutorStudents(widget.user.id),
      _anteprojectsService.getTutorAnteprojects(widget.user.id),
    ]);

    if (mounted) {
      setState(() {
        _stats = futures[0] as TutorStats;
        _students = futures[1] as List<User>;
        _pendingAnteprojects = (futures[2] as List<Anteproject>)
            .where((a) => a.status == AnteprojectStatus.submitted)
            .toList();
      });
    }
  } catch (e) {
    // ...
  }
}
```

### 1.3. Estadísticas del tutor

El dashboard muestra tarjetas con las métricas más importantes:

- **Estudiantes Asignados:** Cuántos estudiantes tiene a su cargo.
- **Anteproyectos Pendientes:** Cuántos anteproyectos tiene que revisar.
- **Proyectos Activos:** Cuántos proyectos de sus estudiantes están en desarrollo.

---

## 2. Gestión de Estudiantes

### 2.1. Acceso a la gestión de estudiantes

Desde el dashboard, el tutor puede ir a la pantalla de gestión de sus estudiantes (`/tutor/students`).

### 2.2. Añadir estudiantes

El tutor puede añadir estudiantes a su lista de tutorizados. Puede hacerlo de dos formas:

- **Manualmente:** Buscando un estudiante por su NRE y añadiéndolo.
- **Importando un CSV:** Subiendo un archivo CSV con los datos de los estudiantes. Esto es útil al principio del curso.

### 2.3. Ver detalles de un estudiante

El tutor puede ver el perfil de cada uno de sus estudiantes, incluyendo sus datos de contacto, los anteproyectos que ha presentado y los proyectos que tiene activos.

---

## 3. Revisión de Anteproyectos

### 3.1. Acceso a la revisión de anteproyectos

Desde el dashboard, el tutor puede ir a la pantalla de revisión de anteproyectos (`/tutor/approval-workflow`).

### 3.2. Lista de anteproyectos pendientes

La pantalla muestra una lista de los anteproyectos que sus estudiantes han enviado para revisión (estado `submitted`).

### 3.3. Revisar un anteproyecto

El tutor puede abrir un anteproyecto para ver todos sus detalles. Desde aquí, puede hacer tres cosas:

- **Aprobar:** Si el anteproyecto está bien, el tutor lo aprueba. Esto cambia el estado a `approved` y crea automáticamente un proyecto asociado.
- **Rechazar:** Si el anteproyecto no es viable, el tutor lo rechaza. Esto cambia el estado a `rejected`.
- **Pedir cambios:** Si el anteproyecto necesita mejoras, el tutor puede pedir cambios. Esto cambia el estado a `under_review` y el estudiante puede volver a editarlo.

En los tres casos, el tutor puede dejar comentarios para que el estudiante sepa por qué ha tomado esa decisión.

```dart
Future<void> approveAnteproject(int id, String comments) async {
  // ... cambiar estado a approved

  // Crear proyecto automáticamente
  await _createProjectFromAnteproject(...);
}

Future<void> rejectAnteproject(int id, String comments) async {
  // ... cambiar estado a rejected
}

Future<void> requestChanges(int id, String comments) async {
  // ... cambiar estado a under_review
}
```

---

## 4. Comunicación con Estudiantes

### 4.1. Comentarios en anteproyectos

La principal forma de comunicación es a través de los comentarios en los anteproyectos. Cuando el tutor revisa un anteproyecto, puede dejar comentarios para guiar al estudiante.

### 4.2. Notificaciones

Cuando un estudiante envía un anteproyecto para revisión, el tutor recibe una notificación. De la misma forma, cuando el tutor revisa un anteproyecto, el estudiante recibe una notificación con el resultado.

---

## 5. Permisos y Seguridad

### 5.1. Verificación de rol

Todas las acciones y rutas del tutor están protegidas. El código siempre comprueba que el rol del usuario sea `tutor`.

### 5.2. Row Level Security (RLS)

Las políticas de RLS aseguran que un tutor solo pueda ver y gestionar los datos de sus propios estudiantes. Por ejemplo, un tutor no puede ver los anteproyectos de los estudiantes de otro tutor.

```sql
-- Política para que un tutor solo pueda ver sus propios estudiantes
CREATE POLICY "Tutors can view their own students" ON students
    FOR SELECT USING (id IN (SELECT student_id FROM tutor_students WHERE tutor_id = auth.uid()));
```
