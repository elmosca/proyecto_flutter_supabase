# Plan de Refactorización y Escalabilidad del Tablero Kanban

## 1. Preparación y Base de Conocimiento
- [ ] Documentar el estado actual de `KanbanBoard`, `TasksBloc` y `TasksService`
- [ ] Validar dependencias y migraciones necesarias para soportar posiciones `double`
- [ ] Crear respaldo de la base de datos (dump) antes de aplicar cambios
- [ ] Alinear al equipo sobre la estrategia de movimiento optimista y reindexado gradual

## 2. Modelo de Datos y Migraciones
- [ ] Actualizar la entidad `Task` para que `kanbanPosition` sea `double?`
- [ ] Generar migración en Supabase para cambiar el tipo de `kanban_position` a `double precision`
- [ ] Añadir índice compuesto (`project_id`, `status`, `kanban_position`) para ordenar columnas
- [ ] Migrar datos existentes asignando posiciones enteras como `n.0`
- [ ] Documentar los cambios en `docs/desarrollo/02-progreso/progreso_mocking_supabase.md`

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
