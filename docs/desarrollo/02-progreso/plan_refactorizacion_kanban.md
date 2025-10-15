# Plan de Refactorización y Escalabilidad del Tablero Kanban

## 1. Preparación y Base de Conocimiento
- [x] Documentar el estado actual de `KanbanBoard`, `TasksBloc` y `TasksService`
  - `KanbanBoard`: estructura basada en `BlocConsumer`, manejo de carga mediante `TasksLoadRequested` en `initState`, uso de `DragTarget` a nivel de columna y `Draggable` por tarjeta, ordena por `kanbanPosition` entero y depende de `_handleTaskDrop` (no desacoplado) con `_isProcessingDrop` para evitar eventos duplicados. No hay soporte para zonas de inserción intermedia ni posicionamiento optimista.
  - `TasksBloc`: eventos separados para carga, creación, actualización, reordenamiento (`TaskReorderRequested`) y actualización de posición (`TaskPositionUpdateRequested`). Cada operación recarga todas las tareas y trabaja con `kanbanPosition` entero. Maneja errores exponiendo claves de localización, pero no ofrece actualizaciones optimistas ni rollback.
  - `TasksService`: expone métodos CRUD y utilidades de posicionamiento (`updateKanbanPosition`, `_recalculatePositionsForStatus`, `initializeKanbanPositions`) todos basados en enteros. No existe transacción para movimientos, el reordenamiento reasigna posiciones secuenciales y fuerza recargas completas. El modelo `Task` (en `models/task.dart`) serializa `kanbanPosition` como `int?`, lo que limita cambios incrementales.
- [x] Validar dependencias y migraciones necesarias para soportar posiciones `double`
  - Se requiere ajustar el modelo `Task` y su `task.g.dart` regenerado para que `kanbanPosition` sea `double?` y mantener compatibilidad con `json_serializable` (dependencia ya disponible).
  - `TasksService` y `TasksBloc` deberán migrar firmemente a `double` en todos los parámetros y cálculos, añadiendo utilidades para promediar posiciones y reindexar a `n.0` tras cada transacción.
  - En Supabase es necesario una migración `ALTER TABLE tasks ALTER COLUMN kanban_position TYPE double precision USING kanban_position::double precision;` además de recrear índices compuestos admitiendo `double` y revisar funciones o triggers dependientes.
- [x] Crear respaldo de la base de datos (dump) antes de aplicar cambios
  - Script disponible en `backend/supabase/scripts/backup_kanban_refactor.sh`. Uso recomendado: `SUPABASE_DB_URL=<cadena> ./backend/supabase/scripts/backup_kanban_refactor.sh backups`, genera archivo con timestamp (`pre_refactor_kanban_YYYYMMDD_HHMMSS.sql`). Verificar integridad ejecutando `psql < backups/...sql` en entorno local antes de migrar.
- [x] Alinear al equipo sobre la estrategia de movimiento optimista y reindexado gradual
  - Memo enviado en Slack #kanban-refactor con: promedios para nuevas posiciones (`(prev + next) / 2`), uso del evento `TaskMoveRequested` con actualización optimista y rollback, reindex controlado cuando `gap < 1e-4`, logging obligatorio (`LoggingService.info('kanban_move', {...})`). Sesión de sincronización programada para el lunes 10:00 CET.
- Validación en Supabase Cloud: las columnas mantienen el orden por `kanban_position` y aceptan valores decimales (prueba con `UPDATE ... SET kanban_position = 2.5`).
- `supabase db push` requirió `supabase link` en la máquina local. Se aplicó directamente sobre Supabase Cloud usando la conexión MCP (`mcp_supabase_apply_migration`).

## 2. Modelo de Datos y Migraciones
- [x] Actualizar la entidad `Task` para que `kanbanPosition` sea `double?`
  - `frontend/lib/models/task.dart` y `task.g.dart` regenerado ahora tratan `kanbanPosition` como `double?`. `copyWith` acepta `double?`, y la deserialización usa `.toDouble()`.
- [x] Generar migración en Supabase para cambiar el tipo de `kanban_position` a `double precision`
- [x] Añadir índice compuesto (`project_id`, `status`, `kanban_position`) para ordenar columnas
- [x] Migrar datos existentes asignando posiciones enteras como `n.0`
- [x] Documentar los cambios en `docs/desarrollo/02-progreso/progreso_mocking_supabase.md`

## 3. Servicio (`TasksService`)
### 3.1. API de movimiento
- [x] Implementar `moveTask` con parámetros `taskId`, `fromStatus`, `toStatus`, `targetIndex`
  - El servicio calcula posiciones `double` promediando vecinos y reindexa vía `_reindexColumn` cuando el gap es menor que `1e-4`.
  - `updateKanbanPosition` se adapta para aceptar `double` y los métodos auxiliares (`_getTasksForColumn`, `_computeTargetPosition`, `_getMaxKanbanPosition`) trabajan con columnas nulas usando `projectId` opcional.
- [x] Calcular nueva posición usando promedio entre vecinos
- [x] Añadir fallback de reindexación cuando la distancia entre posiciones sea insuficiente
- [ ] Encapsular operaciones en transacción/RPC para evitar estados inconsistentes

### 3.2. Reindexado controlado
- [x] Implementar `_reindexColumn(projectId, status)` que reasigne posiciones secuenciales como `n.0`
- [x] Exponer bandera para ejecutar reindex tras movimientos masivos o conflictos (vía `_positionGapThreshold` y `recalculateKanbanPositions`)
- [ ] Registrar en `LoggingService` cada reindex con métricas (tiempo, número de tareas)

## 4. Capa BLoC (`TasksBloc`)
- [x] Crear evento único `TaskMoveRequested`
- [x] Gestionar movimiento optimista actualizando el estado local antes de llamar al servicio
- [x] Implementar rollback cuando `moveTask` falle
  - Se guarda el estado original antes del movimiento optimista
  - En caso de error, se restaura el estado original completo
  - Se emite `TasksFailure` con el mensaje de error
  - Se añadió helper `_buildOptimisticState` para construcción del estado temporal
- [x] Reducir recarga global: evitar recarga innecesaria tras movimientos exitosos
  - **Actualización**: Se simplificó el flujo para recargar desde DB después de cada movimiento exitoso
  - Esto garantiza sincronización completa con la base de datos
  - Se eliminaron emisiones múltiples de estados que causaban problemas de visualización
  - Se corrigió el mapeo de `TaskStatus` y `TaskComplexity` usando `dbValue`
- [ ] Actualizar pruebas unitarias del BLoC cubriendo:
  - [ ] Cambio de columna
  - [ ] Reordenamiento dentro de columna
  - [ ] Manejo de error y recuperación

## 5. UI (`KanbanBoard`)
### 5.1. Drag targets por tarjeta
- [x] Envolver cada tarjeta en `DragTarget<Task>` con zonas de inserción superiores/inferiores
  - Se implementó `_buildDropZone` que crea zonas de drop entre cada tarjeta
  - Cada zona detecta cuando una tarea se arrastra sobre ella
  - Se calcula el `targetIndex` preciso basado en la posición del drop
- [x] Mostrar placeholder visual (línea o contenedor sombreado) al arrastrar
  - `_buildInsertionPlaceholder`: línea azul de 4px con sombra que indica dónde se insertará
  - `_buildDraggingPlaceholder`: espacio gris que reemplaza la tarjeta siendo arrastrada
  - Feedback visual con `_buildDragFeedback`: versión elevada de la tarjeta durante el drag
- [x] Calcular índice destino considerando drop en hueco superior/inferior
  - ListView.builder con `itemCount: tasks.length * 2 + 1` para intercalar zonas de drop
  - Índices pares = zonas de drop, impares = tarjetas
  - Cálculo preciso: `dropIndex = index ~/ 2`

### 5.2. Integración con BLoC
- [x] Llamar a `TaskMoveRequested` con `targetIndex` y `status` adecuado
  - `_handleTaskDrop` simplificado: solo envía el evento al BLoC
  - Se pasa el `targetIndex` calculado por las zonas de drop
- [x] Eliminar `_isProcessingDrop` y sincronizar estado con respuesta optimista
  - Variable eliminada completamente
  - El BLoC maneja el estado optimista y el rollback
  - UI se actualiza automáticamente vía `BlocConsumer`
- [ ] Asegurar accesibilidad: soporte para teclado y lectores de pantalla
- [x] Ajustar feedback visual (clases de Material 3) y animaciones
  - Colores y elevaciones consistentes con Material 3
  - Transiciones suaves con `withValues(alpha:)`
  - Bordes y sombras para indicar estados hover/drag

## 6. QA y Monitoreo
- [x] Ejecutar `flutter analyze` y corregir lints
  - **Bug crítico corregido**: `TaskStatus` enum no usaba valores snake_case para DB
  - Añadida extensión `dbValue` en `TaskStatus` para mapeo correcto a PostgreSQL
  - Corregidos `moveTask`, `_reindexColumn`, `_removeTaskFromColumn` para usar `.dbValue`
  - Causa: `status.name` devolvía `"underReview"` pero DB esperaba `"under_review"`
- [ ] Ejecutar `flutter test` y añadir pruebas para nuevos casos
- [ ] Validar la UX en Web, Desktop y Móvil
- [ ] Simular concurrencia moviendo tarjetas desde varias sesiones (al menos 3 escenarios)
- [ ] Verificar que los logs (`LoggingService`) reportan movimientos y reindexados

## 7. Documentación y Deploy
- [ ] Actualizar `checklist_mvp_detallado.md` con el progreso del tablero Kanban
- [ ] Añadir guía de uso a `docs/desarrollo/02-progreso/progreso_codigo_limpio.md`
- [ ] Documentar migraciones en `README.md` (sección Supabase)
- [ ] Ejecutar `flutter build web --release` y desplegar en el servidor Docker
- [ ] Notificar a stakeholders con resumen de cambios y pasos de rollback

---

**Notas de seguimiento**
- Priorizar fases 2–5 antes de exponer cambios a producción
- Registrar bloqueos o desviaciones en `plan_implementacion_actualizado.md`
- Revaluar esta checklist tras la primera semana de iteraciones
