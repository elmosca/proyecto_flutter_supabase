# Índice de Migraciones - Sistema TFG

## 📋 Resumen General

Este directorio contiene todas las migraciones de base de datos del Sistema de Seguimiento de Proyectos TFG - Ciclo DAM.

## 🗂️ Estructura de Archivos

### Migraciones por Fecha

```
docs/base_datos/migraciones/
├── 20240815000001_create_initial_schema.sql
├── 20240815000002_create_triggers_and_functions.sql
├── 20240815000003_seed_initial_data.sql
├── 20240815000004_configure_rls_fixed.sql
├── 20240815000005_configure_auth.sql
├── 20240815000006_configure_rls.sql
├── 20240914000001_add_objectives_column.sql
├── 20241215000001_create_schedule_tables.sql
├── 20250127000001_create_profiles_table.sql
├── 20250127000003_make_password_hash_nullable.sql
├── 20241004T120000_update_tasks_kanban_position.sql
└── 20250119000001_enable_rls_comments.sql (y siguientes...)
```

## 🔧 Migraciones RLS (2025-01-19)

### Problema Resuelto
- **22 errores críticos de seguridad** en Supabase
- **11 tablas** con políticas RLS creadas pero RLS deshabilitado

### Migraciones Creadas

| Archivo | Tabla | Registros | Riesgo | Propósito |
|---------|-------|-----------|--------|-----------|
| `20250119000001_enable_rls_comments.sql` | comments | 0 | Sin riesgo | Habilitar RLS |
| `20250119000002_enable_rls_milestones.sql` | milestones | 0 | Sin riesgo | Habilitar RLS |
| `20250119000003_enable_rls_notifications.sql` | notifications | 2 | Bajo | Habilitar RLS |
| `20250119000004_enable_rls_files.sql` | files | 1 | Bajo | Habilitar RLS |
| `20250119000005_enable_rls_task_assignees.sql` | task_assignees | 16 | Medio | Habilitar RLS |
| `20250119000006_enable_rls_tasks.sql` | tasks | 18 | Medio | Habilitar RLS |
| `20250119000007_enable_rls_anteproject_students.sql` | anteproject_students | 4 | Medio | Habilitar RLS |
| `20250119000008_enable_rls_project_students.sql` | project_students | 2 | Medio | Habilitar RLS |
| `20250119000009_enable_rls_anteprojects.sql` | anteprojects | 4 | Alto | Habilitar RLS |
| `20250119000010_enable_rls_projects.sql` | projects | 2 | Alto | Habilitar RLS |
| `20250119000011_enable_rls_users.sql` | users | 10 | Crítico | Habilitar RLS |

### Scripts de Rollback

| Archivo | Tabla | Propósito |
|---------|-------|-----------|
| `20250119000001_enable_rls_comments_rollback.sql` | comments | Revertir RLS |
| `20250119000002_enable_rls_milestones_rollback.sql` | milestones | Revertir RLS |
| `20250119000003_enable_rls_notifications_rollback.sql` | notifications | Revertir RLS |
| `20250119000004_enable_rls_files_rollback.sql` | files | Revertir RLS |
| `20250119000005_enable_rls_task_assignees_rollback.sql` | task_assignees | Revertir RLS |
| `20250119000006_enable_rls_tasks_rollback.sql` | tasks | Revertir RLS |
| `20250119000007_enable_rls_anteproject_students_rollback.sql` | anteproject_students | Revertir RLS |
| `20250119000008_enable_rls_project_students_rollback.sql` | project_students | Revertir RLS |
| `20250119000009_enable_rls_anteprojects_rollback.sql` | anteprojects | Revertir RLS |
| `20250119000010_enable_rls_projects_rollback.sql` | projects | Revertir RLS |
| `20250119000011_enable_rls_users_rollback.sql` | users | Revertir RLS |

### Scripts de Verificación

| Archivo | Propósito |
|---------|-----------|
| `20250119000012_verify_rls_enabled.sql` | Verificar RLS habilitado en todas las tablas |

## 📚 Documentación

| Archivo | Propósito |
|---------|-----------|
| `README_RLS_MIGRATIONS.md` | Guía completa de migraciones RLS |
| `INDICE_MIGRACIONES.md` | Este archivo - índice general |

## 🚀 Guía de Uso Rápido

### Aplicar Todas las Migraciones RLS

```bash
# En Supabase SQL Editor, ejecutar en orden:
\i docs/base_datos/migraciones/20250119000001_enable_rls_comments.sql
\i docs/base_datos/migraciones/20250119000002_enable_rls_milestones.sql
\i docs/base_datos/migraciones/20250119000003_enable_rls_notifications.sql
\i docs/base_datos/migraciones/20250119000004_enable_rls_files.sql
\i docs/base_datos/migraciones/20250119000005_enable_rls_task_assignees.sql
\i docs/base_datos/migraciones/20250119000006_enable_rls_tasks.sql
\i docs/base_datos/migraciones/20250119000007_enable_rls_anteproject_students.sql
\i docs/base_datos/migraciones/20250119000008_enable_rls_project_students.sql
\i docs/base_datos/migraciones/20250119000009_enable_rls_anteprojects.sql
\i docs/base_datos/migraciones/20250119000010_enable_rls_projects.sql
\i docs/base_datos/migraciones/20250119000011_enable_rls_users.sql

# Verificar resultado:
\i docs/base_datos/migraciones/20250119000012_verify_rls_enabled.sql
```

### Rollback Completo

```bash
# En Supabase SQL Editor, ejecutar en orden inverso:
\i docs/base_datos/migraciones/20250119000011_enable_rls_users_rollback.sql
\i docs/base_datos/migraciones/20250119000010_enable_rls_projects_rollback.sql
\i docs/base_datos/migraciones/20250119000009_enable_rls_anteprojects_rollback.sql
\i docs/base_datos/migraciones/20250119000008_enable_rls_project_students_rollback.sql
\i docs/base_datos/migraciones/20250119000007_enable_rls_anteproject_students_rollback.sql
\i docs/base_datos/migraciones/20250119000006_enable_rls_tasks_rollback.sql
\i docs/base_datos/migraciones/20250119000005_enable_rls_task_assignees_rollback.sql
\i docs/base_datos/migraciones/20250119000004_enable_rls_files_rollback.sql
\i docs/base_datos/migraciones/20250119000003_enable_rls_notifications_rollback.sql
\i docs/base_datos/migraciones/20250119000002_enable_rls_milestones_rollback.sql
\i docs/base_datos/migraciones/20250119000001_enable_rls_comments_rollback.sql
```

## 📊 Estado Actual

- ✅ **11 migraciones RLS creadas**
- ✅ **11 scripts de rollback creados**
- ✅ **1 script de verificación creado**
- ✅ **Documentación completa**
- ✅ **Listo para aplicación**

## 🔄 Próximos Pasos

1. **Aplicar migraciones** en orden de menor a mayor riesgo
2. **Verificar resultado** con script de verificación
3. **Configurar autenticación JWT** en frontend
4. **Eliminar políticas temporales** cuando JWT esté activo
5. **Auditar acceso** con activity_log

---

## 🔐 Migración: password_hash nullable (2025-01-27)

### Propósito
Hacer `password_hash` nullable en la tabla `users` porque ahora usamos Supabase Auth para gestionar contraseñas. Las contraseñas se almacenan en `auth.users`, no en la tabla `users`.

### Archivos
- `20250127000003_make_password_hash_nullable.sql` - Migración principal
- `20250127000003_make_password_hash_nullable_rollback.sql` - Rollback

### Estado
- ✅ Migración aplicada
- ✅ `password_hash` ahora es nullable
- ✅ Código actualizado para no incluir password_hash

---

**Última Actualización**: 2025-01-27  
**Versión**: 1.1  
**Estado**: Implementación Completa
