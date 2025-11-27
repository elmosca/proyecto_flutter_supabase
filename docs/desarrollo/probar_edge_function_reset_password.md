# 🧪 Guía: Probar Edge Function reset-password

## 📋 Información de tu Proyecto

Según tu configuración:
- **URL de Supabase**: `https://zkririyknhlwoxhsoqih.supabase.co`
- **Edge Function**: `super-action`
- **Endpoint completo**: `https://zkririyknhlwoxhsoqih.supabase.co/functions/v1/super-action`

---

## 🎯 Método 1: Usar el Botón "Test" en el Dashboard

### Paso 1: Acceder a la Edge Function

1. Ve a Supabase Dashboard: https://supabase.com/dashboard
2. Selecciona tu proyecto
3. Navega a **Edge Functions** → **super-action**
4. Haz clic en la pestaña **"Code"** o **"Details"**

### Paso 2: Usar el Botón "Test"

1. Busca el botón **"Test"** en la parte superior derecha (icono de rayo ⚡ o botón verde)
2. Haz clic en **"Test"**
3. Se abrirá un modal o panel de prueba

### Paso 3: Configurar el Body de la Prueba

En el campo **"Body"** o **"Request Body"**, pega este JSON:

```json
{
  "user_email": "manolo.cabeza.bolo@ejemplo.com",
  "new_password": "NuevaPassword123!"
}
```

**⚠️ Importante**: 
- Reemplaza `manolo.cabeza.bolo@ejemplo.com` con el email de un estudiante real que exista en tu `auth.users`
- Usa una contraseña segura (mínimo 6 caracteres)

### Paso 4: Ejecutar la Prueba

1. Haz clic en **"Run"** o **"Invoke"**
2. Espera la respuesta

### Paso 5: Verificar la Respuesta

**Respuesta exitosa** debería ser:
```json
{
  "success": true,
  "message": "Contraseña actualizada exitosamente"
}
```

**Si hay error**, verás algo como:
```json
{
  "error": "Usuario no encontrado"
}
```

---

## 🎯 Método 2: Usar cURL desde Terminal

### Paso 1: Obtener tu Anon Key

1. Ve a Supabase Dashboard → **Settings** → **API**
2. Copia la **"anon public"** key (no la service_role key)

### Paso 2: Preparar el Comando cURL

Abre una terminal (PowerShell en Windows) y ejecuta:

```bash
curl -L -X POST 'https://zkririyknhlwoxhsoqih.supabase.co/functions/v1/super-action' \
-H 'Authorization: Bearer TU_ANON_KEY_AQUI' \
-H 'apikey: TU_ANON_KEY_AQUI' \
-H 'Content-Type: application/json' \
--data '{"user_email": "manolo.cabeza.bolo@ejemplo.com", "new_password": "NuevaPassword123!"}'
```

**⚠️ Reemplaza**:
- `TU_ANON_KEY_AQUI` con tu anon key de Supabase
- `manolo.cabeza.bolo@ejemplo.com` con un email real de estudiante
- `NuevaPassword123!` con la contraseña que quieras establecer

### Paso 3: Ejecutar el Comando

1. Copia el comando completo (con tus valores)
2. Pégalo en PowerShell
3. Presiona Enter
4. Observa la respuesta

### Ejemplo de Respuesta Exitosa

```json
{"success":true,"message":"Contraseña actualizada exitosamente"}
```

---

## 🎯 Método 3: Usar JavaScript en la Consola del Navegador

### Paso 1: Abrir la Consola

1. Abre tu aplicación Flutter en el navegador
2. Presiona **F12** para abrir las herramientas de desarrollador
3. Ve a la pestaña **"Console"**

### Paso 2: Ejecutar el Código

Pega este código en la consola (reemplaza los valores):

```javascript
// Obtener el cliente de Supabase
const supabaseClient = window.supabase || 
  (window.__SUPABASE__ && window.__SUPABASE__.client);

if (!supabaseClient) {
  console.error('Supabase client no encontrado');
} else {
  // Probar la Edge Function
  supabaseClient.functions.invoke('super-action', {
    body: {
      user_email: 'manolo.cabeza.bolo@ejemplo.com',
      new_password: 'NuevaPassword123!'
    }
  })
  .then(response => {
    console.log('✅ Respuesta:', response);
    console.log('✅ Datos:', response.data);
  })
  .catch(error => {
    console.error('❌ Error:', error);
  });
}
```

---

## 🔍 Verificar que Funciona

### 1. Verificar en los Logs

1. Ve a **Edge Functions** → **super-action** → **Logs**
2. Deberías ver una entrada reciente con:
   - Status: `200`
   - Mensaje de éxito

### 2. Verificar que la Contraseña se Actualizó

1. Ve a **Authentication** → **Users** en Supabase Dashboard
2. Busca el usuario por email
3. La contraseña debería estar actualizada (aunque no la verás directamente por seguridad)

### 3. Probar Login con la Nueva Contraseña

1. En tu aplicación Flutter, intenta iniciar sesión con:
   - Email: el email que usaste en la prueba
   - Contraseña: la nueva contraseña que estableciste
2. Debería funcionar correctamente

---

## ❌ Solución de Problemas

### Error: "Usuario no encontrado"

**Causa**: El email no existe en `auth.users`

**Solución**:
1. Ve a **Authentication** → **Users** en Supabase Dashboard
2. Verifica que el usuario existe
3. Si no existe, créalo primero desde la aplicación Flutter

### Error: "Connection refused" o "Network error"

**Causa**: Problema de conectividad o la Edge Function no está desplegada

**Solución**:
1. Verifica que la Edge Function está desplegada (no en estado "draft")
2. Verifica tu conexión a internet
3. Revisa los logs de la Edge Function

### Error: "Unauthorized" o "Invalid API key"

**Causa**: La anon key no es correcta o ha expirado

**Solución**:
1. Ve a **Settings** → **API** en Supabase Dashboard
2. Copia la anon key nuevamente
3. Asegúrate de usar la key correcta (anon, no service_role)

### Error: "user_email y new_password son requeridos"

**Causa**: El body del request no tiene los campos correctos

**Solución**:
- Verifica que el JSON tiene exactamente estos campos:
  ```json
  {
    "user_email": "...",
    "new_password": "..."
  }
  ```
- No uses `email` en lugar de `user_email`
- No uses `password` en lugar de `new_password`

---

## 📝 Checklist de Verificación

Antes de probar, asegúrate de:

- [ ] La Edge Function `reset-password` está desplegada (no en draft)
- [ ] Tienes la anon key de Supabase
- [ ] Tienes el email de un estudiante que existe en `auth.users`
- [ ] La contraseña nueva tiene al menos 6 caracteres
- [ ] Estás autenticado en Supabase Dashboard

---

## 🎯 Prueba Rápida con PowerShell

Si estás en Windows, puedes usar este script de PowerShell:

```powershell
# Configuración
$supabaseUrl = "https://zkririyknhlwoxhsoqih.supabase.co"
$anonKey = "TU_ANON_KEY_AQUI"
$userEmail = "manolo.cabeza.bolo@ejemplo.com"
$newPassword = "NuevaPassword123!"

# Preparar el body
$body = @{
    user_email = $userEmail
    new_password = $newPassword
} | ConvertTo-Json

# Headers
$headers = @{
    "Authorization" = "Bearer $anonKey"
    "apikey" = $anonKey
    "Content-Type" = "application/json"
}

# Hacer la petición
try {
    $response = Invoke-RestMethod -Uri "$supabaseUrl/functions/v1/reset-password" `
        -Method Post `
        -Headers $headers `
        -Body $body
    
    Write-Host "✅ Éxito:" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json)
} catch {
    Write-Host "❌ Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Write-Host $_.ErrorDetails.Message
}
```

Guarda esto en un archivo `.ps1` y ejecútalo desde PowerShell.

---

## 📞 Siguiente Paso

Una vez que la prueba funcione correctamente, podrás usar la funcionalidad de resetear contraseña desde tu aplicación Flutter sin problemas.

