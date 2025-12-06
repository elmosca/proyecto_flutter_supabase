# Análisis: Implementación del Estado 'blocked' para Tareas

## Resumen Ejecutivo

El estado `blocked` está mencionado en el plan de documentación pero **NO está implementado** en el código actual. Este documento analiza todas las implicaciones de implementarlo.

## Estado Actual

### Base de Datos

- **Tipo ENUM**: `task_status` definido como `('pending', 'in_progress', 'under_review', 'completed')`
- **Ubicación**: `docs/base_datos/migraciones/20240815000001_create_initial_schema.sql` línea 190
- **Índices**: Existen índices que incluyen `status` que se verían afectados

### Código Frontend

- **Modelo**: `TaskStatus` enum en `frontend/lib/models/task.dart` (líneas 159-175) - **NO incluye `blocked`**
- **Kanban**: Genera columnas dinámicamente usando `TaskStatus.values` (línea 158 de `kanban_board.dart`)
- **Servicios**: `TasksService` maneja transiciones entre estados actuales
- **BLoC**: `TasksBloc` procesa eventos de cambio de estado

## Cambios Requeridos para Implementar 'blocked'

### 1. Base de Datos (CRÍTICO - Requiere Migración)

**Archivo**: `docs/base_datos/migraciones/[timestamp]_add_blocked_status_to_tasks.sql`

**Cambios necesarios**:

```sql
-- 1. Alterar el tipo ENUM para añadir 'blocked'
ALTER TYPE task_status ADD VALUE 'blocked';

-- 2. Verificar que no haya datos inconsistentes
-- (No necesario si se añade al final del ENUM)

-- 3. Actualizar funciones que usan task_status si es necesario
-- Verificar get_tasks_by_status() y otras funciones
```

**Impacto**:

- **Migración irreversible**: Añadir valores a ENUMs en PostgreSQL requiere recrear el tipo si hay datos existentes
- **Downtime potencial**: Dependiendo del tamaño de la tabla `tasks`
- **Backup necesario**: Antes de ejecutar la migración

**Archivos afectados**:

- `docs/base_datos/migraciones/20240815000001_create_initial_schema.sql` (referencia)
- Nueva migración a crear
- `docs/base_datos/migraciones/20240815000002_create_triggers_and_functions.sql` (función `get_tasks_by_status`)

### 2. Modelo Dart (frontend/lib/models/task.dart)

**Cambios necesarios**:

```dart
enum TaskStatus {
  // ... estados existentes ...
  
  /// Tarea bloqueada por dependencia o impedimento.
  @JsonValue('blocked')
  blocked,
}

extension TaskStatusExtension on TaskStatus {
  // Añadir getter
  bool get isBlocked => this == TaskStatus.blocked;
  
  // Actualizar dbValue
  String get dbValue {
    switch (this) {
      // ... casos existentes ...
      case TaskStatus.blocked:
        return 'blocked';
    }
  }
}
```

**Archivos afectados**:

- `frontend/lib/models/task.dart` (líneas 159-214)
- Requiere regenerar `task.g.dart` con `flutter pub run build_runner build`

### 3. Tablero Kanban (frontend/lib/screens/kanban/kanban_board.dart)

**Cambios necesarios**:

**3.1. Nueva columna en el tablero**:

- El Kanban genera columnas dinámicamente con `TaskStatus.values.map()` (línea 158)
- **Automático**: Se creará una nueva columna sin cambios adicionales
- **Problema**: El orden de las columnas dependerá del orden del enum

**3.2. Título y color de la columna**:

```dart
String _getColumnTitle(TaskStatus status, AppLocalizations l10n) {
  switch (status) {
    // ... casos existentes ...
    case TaskStatus.blocked:
      return l10n.taskStatusBlocked; // Requiere añadir a localizaciones
  }
}

Color _getColumnColor(TaskStatus status) {
  switch (status) {
    // ... casos existentes ...
    case TaskStatus.blocked:
      return Colors.red.shade400; // Color para indicar bloqueo
  }
}
```

**Archivos afectados**:

- `frontend/lib/screens/kanban/kanban_board.dart` (líneas 679-698 aproximadamente)
- `frontend/lib/l10n/app_es.arb` y `app_en.arb` (nuevas traducciones)

### 4. Servicios (frontend/lib/services/tasks_service.dart)

**Cambios necesarios**:

**4.1. Validación de transiciones**:

- Actualmente no hay validación explícita de transiciones válidas
- **Recomendación**: Añadir lógica para validar transiciones desde/hacia `blocked`

**4.2. Lógica de negocio para `blocked`**:

```dart
// Ejemplo de validación de transición
if (toStatus == TaskStatus.blocked) {
  // ¿Se permite desde cualquier estado?
  // ¿Requiere razón/comentario obligatorio?
}

if (fromStatus == TaskStatus.blocked) {
  // ¿A qué estados se puede desbloquear?
  // ¿Se guarda el estado anterior?
}
```

**Archivos afectados**:

- `frontend/lib/services/tasks_service.dart` (método `moveTask`, línea 713)
- Posiblemente crear método `blockTask(int taskId, String reason)`
- Posiblemente crear método `unblockTask(int taskId, TaskStatus targetStatus)`

### 5. BLoC (frontend/lib/blocs/tasks_bloc.dart)

**Cambios necesarios**:

- El BLoC actual procesa `TaskReorderRequested` que acepta cualquier `TaskStatus`
- **No requiere cambios** si se permite transición libre
- **Sí requiere cambios** si se añaden validaciones de negocio

**Archivos afectados**:

- `frontend/lib/blocs/tasks_bloc.dart` (método `_onTaskReorderRequested`, línea 309)
- Posiblemente añadir eventos específicos: `TaskBlockRequested`, `TaskUnblockRequested`

### 6. UI/UX - Formularios y Listas

**Cambios necesarios**:

**6.1. Formulario de tarea** (`frontend/lib/screens/forms/task_form.dart`):

- Añadir opción para marcar tarea como bloqueada
- Campo opcional para razón del bloqueo

**6.2. Lista de tareas** (`frontend/lib/screens/lists/tasks_list.dart`):

- Mostrar indicador visual para tareas bloqueadas
- Filtrar por estado bloqueado

**Archivos afectados**:

- `frontend/lib/screens/forms/task_form.dart`
- `frontend/lib/screens/lists/tasks_list.dart`
- Widgets de visualización de tareas

### 7. Localizaciones (i18n)

**Cambios necesarios**:

- Añadir traducciones para "Bloqueada" / "Blocked"
- Añadir traducciones para acciones: "Bloquear tarea", "Desbloquear tarea"
- Añadir traducciones para mensajes: "Razón del bloqueo", etc.

**Archivos afectados**:

- `frontend/lib/l10n/app_es.arb`
- `frontend/lib/l10n/app_en.arb`
- Requiere ejecutar `flutter gen-l10n`

### 8. Documentación

**Cambios necesarios**:

**8.1. Wiki**:

- Actualizar `wiki_setup/Ciclo-Vida-Tarea.md`:
  - Añadir `blocked` a la tabla de estados
  - Actualizar diagrama de flujo
  - Documentar transiciones desde/hacia `blocked`
  - Eliminar la nota que indica que no está implementado

**8.2. Plan de documentación**:

- Actualizar `docs/plan_documentacion_detallado.md` para reflejar implementación

**Archivos afectados**:

- `wiki_setup/Ciclo-Vida-Tarea.md`
- `docs/plan_documentacion_detallado.md`

## Impacto en el Ciclo de Vida de las Tareas

### Flujo Actual

```
pending → in_progress → under_review → completed
         ↑                              ↓
         └────────── (solicitar cambios) ─┘
```

### Flujo con 'blocked'

```
pending → in_progress → under_review → completed
   ↓          ↓              ↓
blocked ← blocked ← blocked
   ↑          ↑              ↑
   └──────────┴──────────────┘
   (puede bloquearse desde cualquier estado)
```

### Reglas de Negocio Propuestas

1. **Bloqueo**:

   - Se puede bloquear desde cualquier estado
   - Requiere razón/comentario obligatorio
   - No se puede trabajar en una tarea bloqueada

2. **Desbloqueo**:

   - Se desbloquea a un estado válido (pending, in_progress, under_review)
   - Se puede desbloquear al estado anterior o elegir manualmente
   - Requiere confirmación del usuario

3. **Visualización**:

   - Tareas bloqueadas se muestran con indicador visual distintivo
   - Filtro específico para ver solo tareas bloqueadas
   - Contador de tareas bloqueadas en dashboard

## Consideraciones Adicionales

### Base de Datos - Función get_tasks_by_status

**Archivo**: `docs/base_datos/migraciones/20240815000002_create_triggers_and_functions.sql`

La función `get_tasks_by_status` agrupa tareas por estado. **No requiere cambios** si solo se añade el valor al ENUM, pero se debe verificar que funcione correctamente.

### Índices

Los índices existentes que incluyen `status` seguirán funcionando:

- `idx_tasks_project_status_position` (proyecto, estado, posición)
- `idx_tasks_status` (estado)

### Notificaciones

Si existe sistema de notificaciones:

- Añadir notificación cuando una tarea se bloquea
- Añadir notificación cuando una tarea se desbloquea
- Notificar a asignados cuando su tarea se bloquea

### Reportes y Estadísticas

Si existen reportes:

- Incluir tareas bloqueadas en estadísticas
- Métricas de tiempo en estado bloqueado
- Razones más comunes de bloqueo

## Estimación de Esfuerzo

### Complejidad: Media-Alta

**Tiempo estimado**: 4-6 horas de desarrollo + 1-2 horas de testing

**Desglose**:

1. Migración de base de datos: 30 min (incluyendo backup y testing)
2. Modelo Dart y regeneración: 15 min
3. Kanban board (colores, títulos): 30 min
4. Servicios y lógica de negocio: 1-2 horas
5. UI/UX (formularios, listas): 1 hora
6. Localizaciones: 15 min
7. Documentación: 30 min
8. Testing completo: 1-2 horas

## Riesgos

1. **Migración de ENUM**: Puede requerir downtime si hay muchos datos
2. **Compatibilidad**: Código existente que asume 4 estados puede romperse
3. **UX**: Nueva columna puede hacer el Kanban más ancho en pantallas pequeñas
4. **Datos existentes**: No hay tareas bloqueadas, pero hay que asegurar compatibilidad

## Alternativa: No Implementar

Si se decide **NO implementar** `blocked`:

1. **Actualizar documentación**:

   - Eliminar todas las referencias a `blocked` en la wiki
   - Actualizar `docs/plan_documentacion_detallado.md`
   - Mantener la nota actual que indica que no está implementado

2. **Esfuerzo**: 15-30 minutos

3. **Archivos a modificar**:

   - `wiki_setup/Ciclo-Vida-Tarea.md`
   - `docs/plan_documentacion_detallado.md`
   - `frontend/lib/models/task.dart` (comentario línea 41)

## Recomendación

**Implementar `blocked`** si:

- Se necesita rastrear impedimentos en el desarrollo
- Los usuarios requieren visibilidad de tareas bloqueadas
- Se planea hacer análisis de bloqueos

**NO implementar `blocked`** si:

- El sistema actual es suficiente (comentarios/etiquetas)
- No hay necesidad inmediata de esta funcionalidad
- Se prefiere mantener el sistema simple

