# Migraciones RLS - Habilitación de Row Level Security

## 📋 Resumen

Este conjunto de migraciones resuelve **22 errores críticos de seguridad** detectados por Supabase, habilitando Row Level Security (RLS) en 11 tablas que tenían políticas creadas pero RLS deshabilitado.

## 🎯 Objetivo

- ✅ Habilitar RLS en todas las tablas críticas
- ✅ Mantener acceso durante desarrollo (políticas temporales)
- ✅ Facilitar rollback granular por tabla
- ✅ Eliminar errores de seguridad de Supabase

## 📊 Tablas Afectadas

| Orden | Tabla | Registros | Riesgo | Migración | Rollback |
|-------|-------|-----------|--------|-----------|----------|
| 1 | `comments` | 0 | Sin riesgo | `20250119000001` | `20250119000001_rollback` |
| 2 | `milestones` | 0 | Sin riesgo | `20250119000002` | `20250119000002_rollback` |
| 3 | `notifications` | 2 | Bajo | `20250119000003` | `20250119000003_rollback` |
| 4 | `files` | 1 | Bajo | `20250119000004` | `20250119000004_rollback` |
| 5 | `task_assignees` | 16 | Medio | `20250119000005` | `20250119000005_rollback` |
| 6 | `tasks` | 18 | Medio | `20250119000006` | `20250119000006_rollback` |
| 7 | `anteproject_students` | 4 | Medio | `20250119000007` | `20250119000007_rollback` |
| 8 | `project_students` | 2 | Medio | `20250119000008` | `20250119000008_rollback` |
| 9 | `anteprojects` | 4 | Alto | `20250119000009` | `20250119000009_rollback` |
| 10 | `projects` | 2 | Alto | `20250119000010` | `20250119000010_rollback` |
| 11 | `users` | 10 | Crítico | `20250119000011` | `20250119000011_rollback` |

## 🚀 Guía de Aplicación

### Aplicar Todas las Migraciones (Recomendado)

```bash
# Aplicar en orden de menor a mayor riesgo
supabase db reset --linked
# O ejecutar individualmente en Supabase SQL Editor:
```

1. **Sin Riesgo** (tablas vacías):
   ```sql
   -- Ejecutar en Supabase SQL Editor
   \i docs/base_datos/migraciones/20250119000001_enable_rls_comments.sql
   \i docs/base_datos/migraciones/20250119000002_enable_rls_milestones.sql
   ```

2. **Bajo Riesgo** (pocos datos):
   ```sql
   \i docs/base_datos/migraciones/20250119000003_enable_rls_notifications.sql
   \i docs/base_datos/migraciones/20250119000004_enable_rls_files.sql
   ```

3. **Riesgo Medio** (datos de asignaciones):
   ```sql
   \i docs/base_datos/migraciones/20250119000005_enable_rls_task_assignees.sql
   \i docs/base_datos/migraciones/20250119000006_enable_rls_tasks.sql
   \i docs/base_datos/migraciones/20250119000007_enable_rls_anteproject_students.sql
   \i docs/base_datos/migraciones/20250119000008_enable_rls_project_students.sql
   ```

4. **Riesgo Alto** (datos críticos):
   ```sql
   \i docs/base_datos/migraciones/20250119000009_enable_rls_anteprojects.sql
   \i docs/base_datos/migraciones/20250119000010_enable_rls_projects.sql
   \i docs/base_datos/migraciones/20250119000011_enable_rls_users.sql
   ```

5. **Verificación Final**:
   ```sql
   \i docs/base_datos/migraciones/20250119000012_verify_rls_enabled.sql
   ```

### Aplicar Migración Individual

```sql
-- Ejemplo: Solo habilitar RLS en comments
\i docs/base_datos/migraciones/20250119000001_enable_rls_comments.sql
```

## 🔄 Rollback

### Rollback Individual

```sql
-- Ejemplo: Revertir RLS en comments
\i docs/base_datos/migraciones/20250119000001_enable_rls_comments_rollback.sql
```

### Rollback Completo (Todas las Tablas)

```sql
-- Ejecutar en orden inverso
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

## ⚠️ Políticas Temporales de Desarrollo

**IMPORTANTE**: Cada migración crea una política temporal `"Development access to [tabla]"` que:

- ✅ **Permite desarrollo sin interrupciones**
- ⚠️ **Debe eliminarse cuando JWT esté activo**
- 🔒 **Proporciona acceso completo temporal**

### Eliminar Políticas Temporales (Futuro)

```sql
-- Cuando la autenticación JWT esté configurada, ejecutar:
DROP POLICY "Development access to comments" ON comments;
DROP POLICY "Development access to milestones" ON milestones;
DROP POLICY "Development access to notifications" ON notifications;
DROP POLICY "Development access to files" ON files;
DROP POLICY "Development access to task_assignees" ON task_assignees;
DROP POLICY "Development access to tasks" ON tasks;
DROP POLICY "Development access to anteproject_students" ON anteproject_students;
DROP POLICY "Development access to project_students" ON project_students;
DROP POLICY "Development access to anteprojects" ON anteprojects;
DROP POLICY "Development access to projects" ON projects;
DROP POLICY "Development access to users" ON users;
```

## 🔍 Verificación

### Verificación Automática

```sql
-- Ejecutar script de verificación completo
\i docs/base_datos/migraciones/20250119000012_verify_rls_enabled.sql
```

### Verificación Manual

```sql
-- Verificar RLS habilitado
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename IN ('users', 'anteprojects', 'projects', 'tasks', 'files')
ORDER BY tablename;

-- Verificar políticas activas
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

## 📈 Impacto Esperado

### Seguridad
- ✅ **22 errores críticos de Supabase resueltos**
- ✅ **RLS activo en todas las tablas públicas**
- ⚠️ **Políticas temporales mantienen acceso durante desarrollo**

### Funcionalidad
- ✅ **Sin interrupción de desarrollo**
- ✅ **Políticas existentes siguen activas**
- ⚠️ **Requiere migración futura para remover políticas temporales**

### Performance
- ✅ **Impacto mínimo (políticas ya definidas)**
- ℹ️ **RLS evalúa políticas en cada query (overhead normal)**

## 🚨 Consideraciones Importantes

1. **Orden de Aplicación**: Seguir el orden especificado (menor a mayor riesgo)
2. **Verificación**: Ejecutar script de verificación después de cada migración
3. **Rollback**: Mantener scripts de rollback para cada tabla
4. **Políticas Temporales**: Recordar eliminarlas cuando JWT esté activo
5. **Testing**: Probar autenticación después de aplicar migraciones

## 📚 Documentación Relacionada

- [Arquitectura RLS](../arquitectura/rls_security.md)
- [Políticas de Seguridad](../arquitectura/security_policies.md)
- [Guía de Autenticación](../desarrollo/authentication.md)

## 🆘 Soporte

Si encuentras problemas:

1. **Verificar estado**: Ejecutar script de verificación
2. **Rollback individual**: Usar script de rollback específico
3. **Rollback completo**: Revertir todas las migraciones
4. **Consultar logs**: Revisar mensajes de error en Supabase

---

**Fecha de Creación**: 2025-01-19  
**Versión**: 1.0  
**Estado**: Listo para aplicación
