# Solución Simple para Resetear Contraseñas

## ✅ Confirmación

**Sí, está claro**: Los tutores y administradores pueden cambiar contraseñas de estudiantes en Supabase Auth.

## 🎯 Solución Recomendada: Edge Function Simplificada

La forma más simple y segura es usar una Edge Function. Vamos a asegurarnos de que funcione correctamente.

### Paso 1: Verificar que la Edge Function `super-action` existe

1. Ve a **Supabase Dashboard** → **Edge Functions**
2. Busca `super-action` en la lista
3. Si **NO existe**, créala siguiendo el paso 2
4. Si **existe**, verifica el código (paso 3)

### Paso 2: Crear/Actualizar la Edge Function

1. Ve a **Edge Functions** → **"Deploy a new function"** o edita `super-action` si existe
2. Nombre: `super-action`
3. Pega este código **completo y simplificado**:

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

Deno.serve(async (req: Request) => {
  // Manejar CORS
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    });
  }

  try {
    const { user_email, new_password } = await req.json();

    if (!user_email || !new_password) {
      return new Response(
        JSON.stringify({ error: 'user_email y new_password son requeridos' }),
        { 
          status: 400, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          } 
        }
      );
    }

    // Crear cliente con service_role
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    );

    // Obtener el usuario por email
    const { data: users, error: listError } = await supabaseAdmin.auth.admin.listUsers();
    
    if (listError) {
      throw listError;
    }

    const user = users.users.find(u => u.email === user_email);
    
    if (!user) {
      return new Response(
        JSON.stringify({ error: 'Usuario no encontrado' }),
        { 
          status: 404, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          } 
        }
      );
    }

    // Actualizar la contraseña usando Admin API
    const { data, error } = await supabaseAdmin.auth.admin.updateUserById(
      user.id,
      { password: new_password }
    );

    if (error) {
      throw error;
    }

    return new Response(
      JSON.stringify({ success: true, message: 'Contraseña actualizada exitosamente' }),
      { 
        status: 200, 
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        } 
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message || 'Error desconocido' }),
      { 
        status: 500, 
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        } 
      }
    );
  }
});
```

4. **Guarda y despliega**

### Paso 3: Probar la Edge Function

1. Ve a **Edge Functions** → `super-action` → **"Test"** o **"Invoke"**
2. Método: **POST**
3. Body (JSON):
```json
{
  "user_email": "email-del-estudiante@ejemplo.com",
  "new_password": "TestPassword123"
}
```
4. Haz clic en **"Invoke"**
5. Deberías ver: `{ "success": true, "message": "Contraseña actualizada exitosamente" }`

### Paso 4: Verificar en la Aplicación

1. Abre la aplicación Flutter
2. Como tutor o admin, intenta resetear la contraseña de un estudiante
3. Revisa la consola del navegador (F12) para ver los logs
4. Verifica que el estudiante recibe la notificación interna

---

## 🔍 Si la Edge Function NO funciona

### Verificar Logs

1. Ve a **Edge Functions** → `super-action` → **Logs**
2. Intenta resetear una contraseña desde la app
3. Revisa los logs para ver errores

### Errores Comunes

1. **"SUPABASE_URL not found"** o **"SUPABASE_SERVICE_ROLE_KEY not found"**
   - **Solución**: Estas variables están disponibles automáticamente en Edge Functions. Si ves este error, puede ser un problema de configuración de Supabase.

2. **"Usuario no encontrado"**
   - **Solución**: Verifica que el email del estudiante existe en `auth.users`

3. **"Permission denied"**
   - **Solución**: Verifica que la Edge Function tiene acceso a `SUPABASE_SERVICE_ROLE_KEY`

---

## ✅ Flujo Final

1. **Tutor/Admin** resetea contraseña desde la app
2. **Flutter** llama a la Edge Function `super-action`
3. **Edge Function** actualiza la contraseña en `auth.users` usando Admin API
4. **Flutter** envía notificación interna al estudiante con la nueva contraseña
5. **Estudiante** recibe notificación y puede iniciar sesión

---

## 📝 Nota Importante

La función RPC con `pg_net` es más compleja y requiere configuración adicional. La Edge Function es la solución recomendada por Supabase y es más simple de mantener.

