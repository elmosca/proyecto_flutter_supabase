# 🔧 Solución de Problemas: Edge Function reset-password

## ❌ Error: "Connection was refused or reset"

Este error indica que la aplicación Flutter no puede conectarse a la Edge Function `super-action` en Supabase.

### 🔍 Posibles Causas

1. **Edge Function no desplegada**
   - La función no existe en Supabase
   - La función no se desplegó correctamente

2. **Problema de CORS**
   - La Edge Function no permite solicitudes desde tu dominio

3. **Problema de autenticación**
   - El usuario no está autenticado correctamente
   - El token de autenticación ha expirado

4. **Problema de red**
   - Problemas de conectividad
   - Firewall bloqueando la conexión

5. **URL incorrecta**
   - La URL de Supabase no está configurada correctamente

---

## ✅ Soluciones Paso a Paso

### 1. Verificar que la Edge Function está desplegada

1. Ve a tu proyecto en Supabase Dashboard: https://supabase.com/dashboard
2. Navega a **Edge Functions** en el menú lateral
3. Verifica que `super-action` aparece en la lista
4. Si no aparece, créala siguiendo: `docs/desarrollo/implementar_reset_password_edge_function.md`

### 2. Verificar los logs de la Edge Function

1. En Supabase Dashboard → **Edge Functions** → `super-action`
2. Haz clic en **"Logs"** o **"View logs"**
3. Intenta resetear una contraseña desde la aplicación
4. Revisa los logs para ver si hay errores

**Errores comunes en logs:**
- `SUPABASE_URL not found` → La variable de entorno no está configurada
- `SUPABASE_SERVICE_ROLE_KEY not found` → La clave no está disponible
- `User not found` → El email del estudiante no existe en `auth.users`
- `Permission denied` → Problema con permisos de service_role

### 3. Verificar la configuración de la Edge Function

Asegúrate de que la Edge Function tiene este código:

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

Deno.serve(async (req: Request) => {
  try {
    const { user_email, new_password } = await req.json();

    if (!user_email || !new_password) {
      return new Response(
        JSON.stringify({ error: 'user_email y new_password son requeridos' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
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
        { status: 404, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Actualizar la contraseña
    const { data, error } = await supabaseAdmin.auth.admin.updateUserById(
      user.id,
      { password: new_password }
    );

    if (error) {
      throw error;
    }

    return new Response(
      JSON.stringify({ success: true, message: 'Contraseña actualizada exitosamente' }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});
```

### 4. Verificar variables de entorno

Las variables `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY` están disponibles automáticamente en Edge Functions. No necesitas configurarlas manualmente.

### 5. Probar la Edge Function manualmente

Puedes probar la Edge Function directamente desde Supabase Dashboard:

1. Ve a **Edge Functions** → `reset-password`
2. Haz clic en **"Invoke"** o **"Test"**
3. Usa este JSON de prueba:
   ```json
   {
     "user_email": "estudiante@ejemplo.com",
     "new_password": "nuevaPassword123"
   }
   ```
4. Verifica que retorna `{ "success": true, "message": "Contraseña actualizada exitosamente" }`

### 6. Verificar autenticación en Flutter

Asegúrate de que el usuario está autenticado antes de intentar resetear la contraseña:

```dart
final currentUser = _supabase.auth.currentUser;
if (currentUser == null) {
  // El usuario no está autenticado
}
```

### 7. Verificar la URL de Supabase

Asegúrate de que la URL de Supabase está configurada correctamente en tu aplicación Flutter:

1. Verifica el archivo de configuración de Supabase
2. Asegúrate de que la URL es correcta (formato: `https://xxxxx.supabase.co`)

### 8. Verificar CORS (si aplica)

Si estás ejecutando la aplicación en desarrollo local (`localhost`), asegúrate de que:

1. La URL de Supabase permite solicitudes desde `localhost`
2. No hay restricciones de CORS en la configuración de Supabase

---

## 🧪 Pruebas de Diagnóstico

### Prueba 1: Verificar conectividad

Abre la consola del navegador (F12) y ejecuta:

```javascript
// Verificar que Supabase está configurado
console.log('Supabase URL:', window.supabase?.supabaseUrl);
```

### Prueba 2: Llamar a la Edge Function directamente

Desde la consola del navegador:

```javascript
const { createClient } = supabase;
const supabaseClient = createClient('TU_SUPABASE_URL', 'TU_ANON_KEY');

supabaseClient.functions.invoke('reset-password', {
  body: {
    user_email: 'test@ejemplo.com',
    new_password: 'test123'
  }
}).then(response => {
  console.log('Respuesta:', response);
}).catch(error => {
  console.error('Error:', error);
});
```

### Prueba 3: Verificar logs en Supabase

1. Ve a **Edge Functions** → `reset-password` → **Logs**
2. Intenta resetear una contraseña
3. Revisa los logs en tiempo real

---

## 📋 Checklist de Verificación

- [ ] Edge Function `super-action` existe en Supabase Dashboard
- [ ] Edge Function está desplegada (no en estado "draft")
- [ ] Los logs de la Edge Function no muestran errores
- [ ] El usuario está autenticado en Flutter
- [ ] La URL de Supabase está configurada correctamente
- [ ] La Edge Function retorna `{ "success": true }` cuando se prueba manualmente
- [ ] No hay errores de red en la consola del navegador

---

## 🆘 Si el problema persiste

1. **Revisa los logs de la Edge Function** en Supabase Dashboard
2. **Revisa la consola del navegador** (F12) para ver errores de red
3. **Verifica que el código de la Edge Function es correcto** (ver sección 3)
4. **Intenta desplegar la Edge Function nuevamente** desde el editor
5. **Contacta al soporte de Supabase** si el problema es con la plataforma

---

## 📝 Notas Adicionales

- La Edge Function necesita permisos de `service_role` para actualizar `auth.users`
- Las variables `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY` están disponibles automáticamente
- El error "Connection was refused or reset" generalmente indica un problema de conectividad o que la Edge Function no está desplegada

