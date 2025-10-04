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

## 2. Modelo de Datos y Migraciones
- [x] Actualizar la entidad `Task` para que `kanbanPosition` sea `double?`
  - `frontend/lib/models/task.dart` y `task.g.dart` regenerado ahora tratan `kanbanPosition` como `double?`. `copyWith` acepta `double?`, y la deserialización usa `.toDouble()`.
- [x] Generar migración en Supabase para cambiar el tipo de `kanban_position` a `double precision`
- [x] Añadir índice compuesto (`project_id`, `status`, `kanban_position`) para ordenar columnas
- [x] Migrar datos existentes asignando posiciones enteras como `n.0`
- [x] Documentar los cambios en `docs/desarrollo/02-progreso/progreso_mocking_supabase.md`

## 3. Servicio (`TasksService`)
### 3.1. API de movimiento
- [ ] Implementar `moveTask` con parámetros `taskId`, `fromStatus`, `toStatus`, `targetPosition`
- [ ] Calcular nueva posición usando promedio entre vecinos
- [ ] Añadir fallback de reindexación cuando la distancia entre posiciones sea insuficiente
- [ ] Encapsular operaciones en transacción/RPC para evitar estados inconsistentes

### 3.2. Reindexado controlado
- [ ] Implementar `_reindexColumn(projectId, status)` que reasigne posiciones secuenciales como `n.0`
- [ ] Exponer bandera para ejecutar reindex tras movimientos masivos o conflictos
- [ ] Registrar en `LoggingService` cada reindex con métricas (tiempo, número de tareas)

## 4. Capa BLoC (`TasksBloc`)
- [ ] Crear evento único `TaskMoveRequested`
- [ ] Gestionar movimiento optimista actualizando el estado local antes de llamar al servicio
- [ ] Implementar rollback cuando `moveTask` falle
- [ ] Reducir recarga global: solo recargar cuando la transacción indique reindex
- [ ] Actualizar pruebas unitarias del BLoC cubriendo:
  - [ ] Cambio de columna
  - [ ] Reordenamiento dentro de columna
  - [ ] Manejo de error y recuperación

## 5. UI (`KanbanBoard`)
### 5.1. Drag targets por tarjeta
- [ ] Envolver cada tarjeta en `DragTarget<Task>` con zonas de inserción superiores/inferiores
- [ ] Mostrar placeholder visual (línea o contenedor sombreado) al arrastrar
- [ ] Calcular índice destino considerando drop en hueco superior/inferior

### 5.2. Integración con BLoC
- [ ] Llamar a `TaskMoveRequested` con `targetIndex` y `status` adecuado
- [ ] Eliminar `_isProcessingDrop` y sincronizar estado con respuesta optimista
- [ ] Asegurar accesibilidad: soporte para teclado y lectores de pantalla
- [ ] Ajustar feedback visual (clases de Material 3) y animaciones

## 6. QA y Monitoreo
- [ ] Ejecutar `flutter analyze` y corregir lints
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
