# 🔄 Sincronización entre `auth.users` y tabla `users`

## ❌ Situación Actual

**NO hay sincronización automática** entre `auth.users` (tabla de autenticación de Supabase) y la tabla `users` (tabla personalizada de la aplicación).

### Arquitectura Actual

1. **Tabla `users` (personalizada)**:
   - ID: `SERIAL` (INT)
   - Email: `VARCHAR(255) UNIQUE`
   - **NO tiene foreign key a `auth.users`**
   - Se usa para almacenar información adicional del usuario (nombre, rol, NRE, etc.)

2. **Tabla `auth.users` (Supabase Auth)**:
   - ID: `UUID` (generado por Supabase)
   - Email: `VARCHAR(255) UNIQUE`
   - Se usa para autenticación y gestión de sesiones

3. **Relación**:
   - La relación se establece por **email** (no por ID)
   - No hay sincronización automática mediante triggers o foreign keys

### Problema Identificado

Si eliminas un usuario directamente desde el **Dashboard de Supabase** (`Authentication → Users → Delete`):

- ✅ Se elimina de `auth.users`
- ❌ **NO se elimina automáticamente** de la tabla `users`
- ⚠️ Esto causa **inconsistencias** en la base de datos

### Flujo Actual de Eliminación

El código actual (`user_service.dart`) elimina en este orden:

```dart
// 1. Eliminar de la tabla users primero
await _supabase.from('users').delete().eq('id', userId);

// 2. Luego eliminar de auth.users
await userManagementService.deleteUserFromAuth(userEmail);
```

**Problema**: Si eliminas desde el Dashboard de Supabase, solo se elimina de `auth.users`, pero el registro permanece en la tabla `users`.

## ✅ Solución Propuesta

### Opción 1: Trigger en `auth.users` (Recomendada)

Crear un trigger en Supabase que elimine automáticamente de la tabla `users` cuando se elimina de `auth.users`:

```sql
-- Función para eliminar usuario de la tabla users cuando se elimina de auth.users
CREATE OR REPLACE FUNCTION public.handle_auth_user_deleted()
RETURNS TRIGGER AS $$
BEGIN
    -- Eliminar de la tabla users usando el email
    DELETE FROM public.users 
    WHERE email = OLD.email;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que se ejecuta cuando se elimina un usuario de auth.users
CREATE TRIGGER on_auth_user_deleted
    AFTER DELETE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_auth_user_deleted();
```

**Ventajas**:
- ✅ Sincronización automática bidireccional
- ✅ Funciona incluso si eliminas desde el Dashboard
- ✅ Mantiene la consistencia de datos

**Desventajas**:
- ⚠️ Requiere permisos `SECURITY DEFINER`
- ⚠️ Puede causar problemas si hay usuarios en `users` sin correspondencia en `auth.users`

### Opción 2: Función RPC para Eliminación Completa

Crear una función RPC que elimine de ambas tablas:

```sql
CREATE OR REPLACE FUNCTION public.delete_user_complete(user_email TEXT)
RETURNS JSON AS $$
DECLARE
    auth_user_id UUID;
    deleted_from_users BOOLEAN := FALSE;
    deleted_from_auth BOOLEAN := FALSE;
BEGIN
    -- 1. Eliminar de la tabla users
    DELETE FROM public.users WHERE email = user_email;
    GET DIAGNOSTICS deleted_from_users = FOUND;
    
    -- 2. Obtener el ID del usuario en auth.users
    SELECT id INTO auth_user_id
    FROM auth.users
    WHERE email = user_email;
    
    -- 3. Eliminar de auth.users (requiere permisos de service_role)
    -- NOTA: Esto debe hacerse mediante Edge Function o API de administración
    -- porque no se puede eliminar directamente desde una función RPC
    
    RETURN json_build_object(
        'success', TRUE,
        'deleted_from_users', deleted_from_users,
        'deleted_from_auth', deleted_from_auth,
        'message', 'Usuario eliminado correctamente'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Ventajas**:
- ✅ Control total sobre el proceso de eliminación
- ✅ Puede incluir validaciones adicionales

**Desventajas**:
- ❌ No funciona automáticamente si eliminas desde el Dashboard
- ❌ Requiere llamar a la función explícitamente

### Opción 3: Mantener el Código Actual (Con Mejoras)

Mejorar el código actual para manejar mejor los casos de inconsistencia:

```dart
Future<void> deleteUser(int userId) async {
  try {
    // 1. Obtener información del usuario
    final userResponse = await _supabase
        .from('users')
        .select('email, role')
        .eq('id', userId)
        .single();

    final userEmail = userResponse['email'] as String?;
    final userRole = userResponse['role'] as String?;

    // 2. Eliminar de auth.users PRIMERO (para evitar inconsistencias)
    if (userEmail != null && (userRole == 'student' || userRole == 'tutor')) {
      try {
        final userManagementService = UserManagementService();
        await userManagementService.deleteUserFromAuth(userEmail);
        debugPrint('✅ Usuario eliminado de Auth: $userEmail');
      } catch (e) {
        // Si falla, verificar si el usuario ya no existe en Auth
        debugPrint('⚠️ Error eliminando usuario de Auth: $e');
        // Continuar con la eliminación de users de todas formas
      }
    }

    // 3. Eliminar de la tabla users
    await _supabase.from('users').delete().eq('id', userId);
    
  } catch (e) {
    throw Exception('Error al eliminar usuario: $e');
  }
}
```

**Ventajas**:
- ✅ No requiere cambios en la base de datos
- ✅ Funciona con el código actual

**Desventajas**:
- ❌ No sincroniza si eliminas desde el Dashboard
- ❌ Puede dejar inconsistencias

## 🎯 Recomendación

**Implementar la Opción 1 (Trigger)** porque:

1. ✅ Garantiza sincronización automática
2. ✅ Funciona incluso si eliminas desde el Dashboard
3. ✅ Mantiene la consistencia de datos
4. ✅ Es la solución más robusta

### Implementación del Trigger

Crear una nueva migración:

```sql
-- =====================================================
-- MIGRACIÓN: Sincronización auth.users → users
-- =====================================================

-- Función para eliminar usuario de la tabla users cuando se elimina de auth.users
CREATE OR REPLACE FUNCTION public.handle_auth_user_deleted()
RETURNS TRIGGER AS $$
BEGIN
    -- Eliminar de la tabla users usando el email
    DELETE FROM public.users 
    WHERE email = OLD.email;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que se ejecuta cuando se elimina un usuario de auth.users
DROP TRIGGER IF EXISTS on_auth_user_deleted ON auth.users;
CREATE TRIGGER on_auth_user_deleted
    AFTER DELETE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_auth_user_deleted();

-- Comentario
COMMENT ON FUNCTION public.handle_auth_user_deleted() IS 
    'Elimina automáticamente el usuario de la tabla users cuando se elimina de auth.users';
```

## 📋 Verificación

Para verificar que funciona:

1. **Crear un usuario de prueba**
2. **Eliminarlo desde el Dashboard de Supabase** (`Authentication → Users`)
3. **Verificar que también se eliminó de la tabla `users`**:
   ```sql
   SELECT * FROM users WHERE email = 'email_de_prueba@example.com';
   -- Debe retornar 0 filas
   ```

## ⚠️ Consideraciones Importantes

1. **Permisos**: El trigger requiere `SECURITY DEFINER` para poder eliminar de la tabla `users`.

2. **RLS (Row Level Security)**: Asegúrate de que las políticas RLS permitan la eliminación desde el trigger.

3. **Usuarios huérfanos**: Si hay usuarios en la tabla `users` sin correspondencia en `auth.users`, el trigger no los afectará (solo actúa cuando se elimina de `auth.users`).

4. **Orden de eliminación**: El código actual elimina primero de `users` y luego de `auth.users`. Con el trigger, el orden se invierte automáticamente cuando eliminas desde el Dashboard.

## 🔍 Casos de Uso

### Caso 1: Eliminación desde la Aplicación
- El código elimina de `users` primero
- Luego elimina de `auth.users`
- ✅ Funciona correctamente

### Caso 2: Eliminación desde Dashboard de Supabase
- Se elimina de `auth.users`
- El trigger elimina automáticamente de `users`
- ✅ Funciona correctamente

### Caso 3: Usuario huérfano (solo en `users`, no en `auth.users`)
- El usuario permanece en `users`
- No se puede autenticar
- ⚠️ Requiere limpieza manual

