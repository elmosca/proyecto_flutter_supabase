# Plan: Alinear Documentación con Código Actual - Eliminar Referencias a 'blocked'

## Objetivo

Eliminar todas las referencias al estado `blocked` de la documentación para alinearla con la implementación actual del código, que solo incluye 4 estados: `pending`, `in_progress`, `under_review`, `completed`.

## Referencias Encontradas

### 1. Wiki - Ciclo-Vida-Tarea.md
- **Ubicación**: `wiki_setup/Ciclo-Vida-Tarea.md`
- **Línea**: 66
- **Contenido**: Nota que menciona que `blocked` no está implementado
- **Acción**: Eliminar la nota completa

### 2. Código - task.dart
- **Ubicación**: `frontend/lib/models/task.dart`
- **Línea**: 41
- **Contenido**: Comentario en documentación del modelo que lista `blocked` como estado posible
- **Acción**: Eliminar la línea del comentario

### 3. Wiki Temporal (copia)
- **Ubicación**: `wiki_setup/wiki_temp/Ciclo-Vida-Tarea.md`
- **Línea**: 66
- **Contenido**: Misma nota que en el archivo principal
- **Acción**: Se actualizará automáticamente al ejecutar el script de publicación

## Cambios a Realizar

### Cambio 1: Eliminar Nota en Ciclo-Vida-Tarea.md

**Archivo**: `wiki_setup/Ciclo-Vida-Tarea.md`

**Línea 66 actual**:
```markdown
**Nota:** Aunque el plan menciona un estado `blocked`, este no está implementado actualmente en el enum `TaskStatus`. Las tareas bloqueadas se pueden manejar mediante comentarios o etiquetas.
```

**Acción**: Eliminar completamente esta línea.

**Contexto a mantener**:
- La sección de estados debe mostrar solo los 4 estados implementados
- El código de ejemplo del enum debe mantenerse sin cambios (ya está correcto)

### Cambio 2: Actualizar Comentario en task.dart

**Archivo**: `frontend/lib/models/task.dart`

**Líneas 36-41 actuales**:
```dart
/// ## Estados posibles:
/// - [todo]: Tarea pendiente de iniciar
/// - [in_progress]: Tarea en progreso
/// - [in_review]: Tarea en revisión
/// - [done]: Tarea completada
/// - [blocked]: Tarea bloqueada
```

**Cambio a**:
```dart
/// ## Estados posibles:
/// - [pending]: Tarea pendiente de iniciar
/// - [in_progress]: Tarea en progreso
/// - [under_review]: Tarea en revisión
/// - [completed]: Tarea completada
```

**Notas adicionales**:
- Corregir también los nombres de los estados para que coincidan con el enum real
- `todo` → `pending`
- `in_review` → `under_review`
- `done` → `completed`

## Verificación Post-Cambios

1. Verificar que no queden referencias a `blocked` en:
   - Documentación de la wiki
   - Comentarios del código
   - Archivos de planificación

2. Verificar que los nombres de estados en comentarios coincidan con el enum real

3. Ejecutar script de publicación de wiki para actualizar la versión en GitHub

## Archivos a Modificar

1. `wiki_setup/Ciclo-Vida-Tarea.md` - Eliminar nota línea 66
2. `frontend/lib/models/task.dart` - Actualizar comentario líneas 36-41

## Impacto

- **Documentación**: Más precisa y alineada con el código
- **Usuarios**: No habrá confusión sobre estados no implementados
- **Mantenimiento**: Menos discrepancias entre código y documentación

## Esfuerzo Estimado

- **Tiempo**: 5-10 minutos
- **Complejidad**: Baja
- **Riesgo**: Mínimo (solo cambios en documentación)

