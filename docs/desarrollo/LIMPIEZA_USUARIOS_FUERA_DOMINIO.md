# 🧹 Limpieza de Usuarios Fuera del Dominio jualas.es

## 📋 Objetivo

Eliminar de la base de datos (tabla `users` y `auth.users`) a todos los usuarios que **NO pertenezcan** al dominio `jualas.es` o `fct.jualas.es`.

## ⚠️ Advertencia

Este proceso es **DESTRUCTIVO** y **NO se puede deshacer**. Asegúrate de:

1. ✅ Hacer un backup de la base de datos antes de ejecutar
2. ✅ Verificar qué usuarios se van a eliminar
3. ✅ Confirmar que no necesitas esos usuarios

## 🎯 Dominios Permitidos

- ✅ `@jualas.es` (cualquier subdominio: `usuario@jualas.es`, `admin@jualas.es`, etc.)
- ✅ `@fct.jualas.es` (cualquier subdominio: `tutor@fct.jualas.es`, etc.)

**Cualquier otro dominio será eliminado** (ej: `@gmail.com`, `@hotmail.com`, `@example.com`, etc.)

## 📝 Pasos para Ejecutar

### Paso 1: Verificar Usuarios a Eliminar

Ejecuta este SQL en Supabase SQL Editor para ver qué usuarios se eliminarán:

```sql
-- Ver usuarios que serán eliminados
SELECT id, email, full_name, role, created_at
FROM public.users
WHERE email NOT LIKE '%@jualas.es'
  AND email NOT LIKE '%@fct.jualas.es'
ORDER BY role, email;
```

### Paso 2: Eliminar de auth.users

#### Opción A: Usando Edge Function (Recomendado)

1. **Actualizar la Edge Function `super-action`** con la nueva acción `bulk_delete_users_by_domain`
2. **Ejecutar el script PowerShell**:

```powershell
cd scripts
.\cleanup-users-not-jualas-domain.ps1
```

O manualmente usando curl/Postman:

```bash
curl -X POST "https://TU_PROJECT.supabase.co/functions/v1/super-action" \
  -H "Authorization: Bearer TU_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -H "apikey: TU_ANON_KEY" \
  -d '{
    "action": "bulk_delete_users_by_domain"
  }'
```

#### Opción B: Desde Supabase Dashboard

1. Ir a `Authentication → Users`
2. Filtrar usuarios manualmente
3. Eliminar uno por uno los que no pertenezcan al dominio

### Paso 3: Eliminar de la tabla users

Ejecuta este SQL en Supabase SQL Editor:

```sql
-- Eliminar usuarios fuera del dominio jualas.es
DELETE FROM public.users
WHERE email NOT LIKE '%@jualas.es'
  AND email NOT LIKE '%@fct.jualas.es';
```

O ejecuta la migración:

```sql
-- Ejecutar migración
\i docs/base_datos/migraciones/20250112000002_cleanup_users_not_jualas_domain.sql
```

### Paso 4: Verificar Resultado

Ejecuta este SQL para verificar que solo quedan usuarios del dominio autorizado:

```sql
-- Verificar usuarios restantes
SELECT COUNT(*) as total_usuarios,
       COUNT(*) FILTER (WHERE email LIKE '%@jualas.es') as usuarios_jualas_es,
       COUNT(*) FILTER (WHERE email LIKE '%@fct.jualas.es') as usuarios_fct_jualas_es,
       COUNT(*) FILTER (WHERE email NOT LIKE '%@jualas.es' AND email NOT LIKE '%@fct.jualas.es') as usuarios_otros_dominios
FROM public.users;
```

## 🔧 Scripts Disponibles

### 1. Script PowerShell

**Archivo**: `scripts/cleanup-users-not-jualas-domain.ps1`

**Uso**:
```powershell
# Modo normal (elimina usuarios)
.\cleanup-users-not-jualas-domain.ps1

# Modo dry-run (solo muestra qué se eliminaría)
.\cleanup-users-not-jualas-domain.ps1 -DryRun
```

**Parámetros**:
- `-DryRun`: Solo muestra información, no elimina nada
- `-SupabaseUrl`: URL de tu proyecto Supabase
- `-SupabaseAnonKey`: Anon Key de Supabase
- `-SupabaseServiceRoleKey`: Service Role Key de Supabase

### 2. Migración SQL

**Archivo**: `docs/base_datos/migraciones/20250112000002_cleanup_users_not_jualas_domain.sql`

**Uso**: Ejecutar en Supabase SQL Editor

## 📊 Respuesta de la Edge Function

La Edge Function retorna un resumen detallado:

```json
{
  "success": true,
  "message": "Eliminación masiva completada. X usuarios eliminados, Y errores",
  "summary": {
    "total_found": 10,
    "deleted": 9,
    "errors": 1,
    "allowed_domains": ["@jualas.es", "@fct.jualas.es"]
  },
  "deleted_users": [
    {
      "email": "usuario@gmail.com",
      "id": "uuid-del-usuario"
    }
  ],
  "errors": [
    {
      "email": "usuario@example.com",
      "error": "Error message"
    }
  ]
}
```

## 🔍 Verificación Post-Limpieza

### 1. Verificar auth.users

```sql
-- Ver usuarios en auth.users (requiere permisos de administrador)
-- Esto se hace mejor desde el Dashboard de Supabase
-- Authentication → Users
```

### 2. Verificar tabla users

```sql
-- Ver todos los usuarios restantes
SELECT id, email, full_name, role, status
FROM public.users
ORDER BY role, email;
```

### 3. Verificar usuarios huérfanos

```sql
-- Usuarios en users que no tienen correspondencia en auth.users
-- (Esto requiere acceso a auth.users, mejor verificar manualmente)
```

## ⚠️ Problemas Comunes

### 1. Usuarios huérfanos

Si quedan usuarios en la tabla `users` sin correspondencia en `auth.users`, puedes limpiarlos manualmente:

```sql
-- Identificar usuarios huérfanos (requiere verificación manual)
-- Mejor usar el Dashboard de Supabase para verificar
```

### 2. Errores al eliminar de auth.users

Si hay errores al eliminar de `auth.users`, verifica:
- ✅ Que la Edge Function esté desplegada correctamente
- ✅ Que la Service Role Key sea válida
- ✅ Que el usuario tenga permisos de administrador

### 3. Usuarios que no se eliminan

Algunos usuarios pueden no eliminarse si:
- ❌ Tienen sesiones activas (esperar unos minutos)
- ❌ Tienen datos relacionados (verificar foreign keys)
- ❌ Hay errores de permisos

## 📝 Notas Importantes

1. **Backup**: Siempre haz un backup antes de ejecutar scripts destructivos
2. **Verificación**: Verifica qué usuarios se eliminarán antes de ejecutar
3. **Orden**: Elimina primero de `auth.users`, luego de la tabla `users`
4. **Sincronización**: Si implementaste el trigger de sincronización, eliminar de `auth.users` también eliminará de `users` automáticamente

## 🔄 Sincronización Automática

Si ya implementaste el trigger `on_auth_user_deleted` (migración `20250112000001_sync_auth_users_deletion.sql`), entonces:

- ✅ Eliminar de `auth.users` automáticamente elimina de `users`
- ✅ Solo necesitas ejecutar la Edge Function
- ✅ El SQL de limpieza de `users` puede ser redundante, pero es seguro ejecutarlo

## 📞 Soporte

Si encuentras problemas:

1. Revisa los logs de la Edge Function en Supabase Dashboard
2. Verifica los permisos de la Service Role Key
3. Consulta la documentación de Supabase Auth Admin API

