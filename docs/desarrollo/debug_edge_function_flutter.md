# 🔍 Debug: Edge Function funciona desde script pero no desde Flutter

## ✅ Situación Actual

- **Script PowerShell**: ✅ Funciona correctamente
- **Aplicación Flutter**: ❌ Error "Connection was refused or reset"

## 🔍 Diferencias Clave

### Script PowerShell
- Usa `anon key` directamente en headers
- No requiere autenticación del usuario
- Headers:
  ```
  Authorization: Bearer ANON_KEY
  apikey: ANON_KEY
  ```

### Aplicación Flutter
- Usa `Supabase.instance.client.functions.invoke()`
- **Automáticamente añade el token JWT del usuario autenticado**
- Headers:
  ```
  Authorization: Bearer USER_JWT_TOKEN
  apikey: ANON_KEY
  ```

## 🎯 Posibles Causas

### 1. La Edge Function no acepta tokens JWT de usuarios

**Solución**: La Edge Function debe verificar el token JWT o permitir solicitudes sin autenticación.

### 2. Problema de CORS (menos probable)

El script funciona, así que CORS no debería ser el problema.

### 3. La aplicación no se reconstruyó

**Solución**: Ejecuta `flutter clean` y reconstruye la aplicación.

### 4. El token JWT ha expirado

**Solución**: Cierra sesión y vuelve a iniciar sesión en la aplicación.

## 🛠️ Soluciones

### Solución 1: Verificar logs en la consola del navegador

1. Abre la aplicación Flutter en el navegador
2. Presiona **F12** para abrir las herramientas de desarrollador
3. Ve a la pestaña **Console**
4. Intenta resetear una contraseña
5. Busca los mensajes de debug que empiezan con `🔐` o `❌`

Deberías ver:
```
🔐 Intentando resetear contraseña para: email@ejemplo.com
🔐 Llamando a Edge Function: super-action
❌ Error al llamar Edge Function: ...
```

### Solución 2: Verificar logs de la Edge Function

1. Ve a Supabase Dashboard → **Edge Functions** → **super-action** → **Logs**
2. Intenta resetear una contraseña desde Flutter
3. Revisa los logs para ver si la petición llega a la Edge Function

**Si NO hay logs**: La petición no está llegando a la Edge Function (problema de red/CORS)
**Si HAY logs con error**: El problema está en la Edge Function

### Solución 3: Modificar la Edge Function para aceptar solicitudes sin autenticación

Si la Edge Function requiere autenticación pero no la está manejando correctamente, puedes modificarla para que funcione sin autenticación (solo para esta función específica):

```typescript
Deno.serve(async (req: Request) => {
  // Permitir solicitudes sin autenticación (solo para reset-password)
  // La Edge Function usa service_role internamente, así que es segura
  
  try {
    const { user_email, new_password } = await req.json();
    // ... resto del código ...
  } catch (error) {
    // ... manejo de errores ...
  }
});
```

### Solución 4: Verificar que el usuario está autenticado

Añade este código antes de llamar a la Edge Function:

```dart
final currentUser = _supabase.auth.currentUser;
if (currentUser == null) {
  throw AuthenticationException(
    'not_authenticated',
    technicalMessage: 'Usuario no autenticado',
  );
}
debugPrint('✅ Usuario autenticado: ${currentUser.email}');
```

### Solución 5: Reconstruir la aplicación

```bash
cd frontend
flutter clean
flutter pub get
flutter run -d chrome
```

## 📋 Checklist de Diagnóstico

- [ ] Abrir consola del navegador (F12) y ver logs de debug
- [ ] Verificar logs de la Edge Function en Supabase Dashboard
- [ ] Verificar que el usuario está autenticado en Flutter
- [ ] Verificar que la aplicación se reconstruyó después de los cambios
- [ ] Probar cerrar sesión y volver a iniciar sesión
- [ ] Verificar que la URL de Supabase es correcta en `app_config.dart`

## 🔧 Próximos Pasos

1. **Ejecuta la aplicación con los nuevos logs de debug**
2. **Abre la consola del navegador (F12)**
3. **Intenta resetear una contraseña**
4. **Copia los mensajes de debug que aparezcan**
5. **Revisa los logs de la Edge Function en Supabase Dashboard**

Con esta información podremos identificar exactamente dónde está fallando.

