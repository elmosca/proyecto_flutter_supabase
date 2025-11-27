# Implementar Edge Function para Resetear Contraseñas

## Problema

El método `resetStudentPassword` en `UserManagementService` necesita actualizar la contraseña de un usuario en `auth.users`, pero esto requiere permisos de `service_role` que no están disponibles en el cliente Flutter.

## Solución: Edge Function

Necesitas crear una Edge Function en Supabase que use la API de administración para actualizar la contraseña.

### Paso 1: Crear la Edge Function

Tienes **dos opciones** para crear la Edge Function:

#### **Opción A: Via Editor (Recomendado - Más Simple)**

1. Ve a tu proyecto en Supabase Dashboard: https://supabase.com/dashboard
2. En el menú lateral, haz clic en **Edge Functions**
3. Haz clic en el botón **"Deploy a new function"** (botón verde)
4. Selecciona **"Via Editor"** (primera opción con icono `< >`)
5. En el campo **Function name**, escribe: `super-action` (o el nombre que prefieras, pero debe coincidir con el código de Flutter)
6. Pega el siguiente código en el editor:

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

Deno.serve(async (req: Request) => {
  // Manejar CORS para peticiones desde el navegador
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

    // Crear cliente con service_role (solo disponible en Edge Functions)
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
      JSON.stringify({ error: error.message }),
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

7. Haz clic en **"Deploy function"** (botón en la parte inferior)
8. Espera a que se despliegue (verás un mensaje de éxito)

**¡Listo!** La Edge Function está creada y desplegada.

#### **Opción B: Via CLI (Para desarrollo avanzado)**

Si prefieres usar la línea de comandos:

1. Crea la estructura de carpetas:
   ```bash
   mkdir -p supabase/functions/super-action
   ```

2. Crea el archivo `supabase/functions/super-action/index.ts` con el código de abajo

3. Despliega usando Supabase CLI:
   ```bash
   supabase functions deploy super-action
   ```

### Paso 2: Configurar Variables de Entorno

**No necesitas configurar nada manualmente.** Las Edge Functions tienen acceso automático a:
- `SUPABASE_URL`: URL de tu proyecto (automático)
- `SUPABASE_SERVICE_ROLE_KEY`: Service Role Key (automático)

Estas variables están disponibles automáticamente en todas las Edge Functions.

### Paso 3: Verificar que Funciona

1. Ve a **Edge Functions** en el dashboard
2. Deberías ver `super-action` (o el nombre que hayas elegido) en la lista
3. Haz clic en ella para ver los logs y detalles
4. **Importante**: El nombre de la función debe coincidir con el que usas en Flutter (`super-action`)

### Paso 4: Probar desde la Aplicación

Una vez desplegada, el método `resetStudentPassword` en Flutter debería funcionar correctamente:

1. Abre la aplicación Flutter
2. Ve a la lista de estudiantes (como tutor o admin)
3. Haz clic en el botón de resetear contraseña de un estudiante
4. Establece una nueva contraseña
5. El estudiante recibirá una notificación con la nueva contraseña

## Alternativa Temporal

Si no puedes crear la Edge Function ahora, puedes modificar temporalmente el método para que use `updateUser` después de hacer signIn temporal como el estudiante (requiere conocer la contraseña actual, no es ideal).

