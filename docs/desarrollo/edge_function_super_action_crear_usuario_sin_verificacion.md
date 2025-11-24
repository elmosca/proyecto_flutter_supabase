# Edge Function: Crear Usuario Sin Verificación de Email

## 📋 Código para la Edge Function `super-action`

Actualiza la Edge Function `super-action` para que también pueda crear usuarios sin verificación de email.

**⚠️ IMPORTANTE:** Copia SOLO el código TypeScript, NO el texto markdown. El código completo está en: `docs/desarrollo/super-action_edge_function_completo.ts`

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
    const body = await req.json();
    const { action, user_email, new_password, user_data } = body;

    if (!action) {
      return new Response(
        JSON.stringify({ error: 'action es requerido (reset_password o create_user)' }),
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

    if (action === 'reset_password') {
      // Lógica existente para resetear contraseña
      if (!user_email || !new_password) {
        return new Response(
          JSON.stringify({ error: 'user_email y new_password son requeridos para reset_password' }),
          { 
            status: 400, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

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
    } else if (action === 'create_user') {
      // Nueva lógica para crear usuario sin verificación
      if (!user_data || !user_data.email || !user_data.password) {
        return new Response(
          JSON.stringify({ error: 'user_data con email y password son requeridos para create_user' }),
          { 
            status: 400, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      // Crear usuario con email ya confirmado (sin verificación)
      const { data: newUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
        email: user_data.email,
        password: user_data.password,
        email_confirm: true, // Esto marca el email como confirmado automáticamente
        user_metadata: {
          full_name: user_data.full_name || '',
          role: user_data.role || 'student',
        },
      });

      if (createError) {
        throw createError;
      }

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Usuario creado exitosamente sin verificación de email',
          user_id: newUser.user.id,
        }),
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
    } else {
      return new Response(
        JSON.stringify({ error: `Acción desconocida: ${action}` }),
        { 
          status: 400, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          } 
        }
      );
    }
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

## 📝 Notas

- `email_confirm: true` crea el usuario con el email ya confirmado, sin necesidad de verificación
- El usuario puede iniciar sesión inmediatamente después de ser creado
- No se envía email de verificación de Supabase Auth
- La Edge Function ahora soporta tres acciones:
  - `reset_password`: Resetea la contraseña de un usuario
  - `create_user`: Crea un usuario sin verificación de email
  - `delete_user`: Elimina un usuario de Supabase Auth

