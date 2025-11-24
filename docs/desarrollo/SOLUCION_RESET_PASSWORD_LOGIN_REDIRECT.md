# 🔧 Solución: Redirección al Login desde Reset Password

## 🐛 El Problema

Al hacer clic en el enlace de "Restablecer Contraseña" del email, el usuario ve:
- ✅ La URL correcta: `localhost:8082/reset-password?code=...&type=reset`
- ❌ Pero aparece la pantalla de LOGIN en lugar del formulario de cambio de contraseña
- ❌ Al final de la URL aparece `#/login` que interfiere con el procesamiento

**Ejemplo de URL problemática:**
```
localhost:8082/reset-password?code=d7ee39f0-ea08-4503-9da1-c149cfc31b45&type=reset#/login
```

## 🔍 Causa del Problema

El problema tiene dos causas principales:

1. **GoRouter interfiere:** El hash fragment `#/login` al final de la URL hace que GoRouter intente redirigir al usuario al login.

2. **Timing del procesamiento:** El token de Supabase se procesa antes de que la URL esté completamente limpia.

## ✅ Solución Implementada

### 1. Limpieza Mejorada de URL

Se agregó un método dedicado `_cleanUrlHash()` que:
- Limpia **inmediatamente** cualquier hash fragment (`#/login`, `#/`, etc.)
- Se ejecuta **antes** de procesar el token de Supabase
- Registra logs detallados para debugging

### 2. Procesamiento con Delay

El procesamiento del token ahora:
- Se ejecuta con `Future.microtask()` para dar tiempo a que la URL se limpie
- Incluye múltiples pasos de limpieza durante el proceso
- Proporciona logs detallados en cada paso

### 3. Logs de Debug Mejorados

Ahora verás en la consola del navegador:
```
🧹 Limpiando hash problemático: #/login
🔗 URL actual: localhost:8082/reset-password?code=...#/login
✅ URL limpiada a: /reset-password?code=...
🔍 Iniciando procesamiento de token...
🔐 Intentando obtener sesión desde URL...
✅ Token válido - usuario autenticado temporalmente
👤 Usuario: estudiante@example.com
🔗 URL final limpia: /reset-password?type=reset
```

## 🧪 Pruebas

### Test 1: Solicitar Recuperación de Contraseña

1. **Acción:** Ve a http://localhost:8082/login
2. **Acción:** Haz clic en "¿Olvidaste tu contraseña?"
3. **Acción:** Introduce un email válido (ej: `juanantonio.frances.perez@gmail.com`)
4. **Acción:** Envía la solicitud

**Resultado esperado:**
- ✅ Mensaje: "Se ha enviado un correo con instrucciones..."

### Test 2: Hacer Clic en el Enlace del Email

1. **Acción:** Abre el email recibido
2. **Acción:** Haz clic en "🔒 Restablecer mi contraseña"

**Resultado esperado:**
- ✅ Serás redirigido a: `localhost:8082/reset-password?code=...&type=reset`
- ✅ Verás el mensaje: "Procesando enlace de restablecimiento..."
- ✅ Después verás el **formulario de cambio de contraseña** con dos campos
- ❌ NO deberías ver la pantalla de login

### Test 3: Ver los Logs en Consola

1. **Acción:** Abre las DevTools del navegador (F12)
2. **Acción:** Ve a la pestaña "Console"

**Resultado esperado - verás estos logs:**
```
🧹 Limpiando hash problemático: #/login
🔗 URL actual: http://localhost:8082/reset-password?code=d7ee39f0-ea08-4503-9da1-c149cfc31b45&type=reset#/login
🔗 Pathname: /reset-password
🔗 Search: ?code=d7ee39f0-ea08-4503-9da1-c149cfc31b45&type=reset
✅ URL limpiada a: /reset-password?code=d7ee39f0-ea08-4503-9da1-c149cfc31b45&type=reset
🔍 Iniciando procesamiento de token...
🔗 URL actual: http://localhost:8082/reset-password?code=d7ee39f0-ea08-4503-9da1-c149cfc31b45&type=reset
🔐 Intentando obtener sesión desde URL...
📊 Sesión obtenida: ✅ SÍ
✅ Token válido - usuario autenticado temporalmente
👤 Usuario: estudiante@example.com
🔗 URL final limpia: /reset-password?type=reset
```

### Test 4: Cambiar la Contraseña

1. **Acción:** Introduce una nueva contraseña (ej: `NuevaPass123!`)
2. **Acción:** Confirma la contraseña
3. **Acción:** Haz clic en "Cambiar Contraseña"

**Resultado esperado:**
- ✅ Mensaje: "Contraseña cambiada exitosamente"
- ✅ Redirigido automáticamente al login después de 2 segundos
- ✅ Puedes iniciar sesión con la nueva contraseña

## 🔍 Troubleshooting

### Problema: Sigo viendo la pantalla de login

**Solución 1: Forzar recarga del navegador**
1. Presiona `Ctrl + Shift + R` (Windows/Linux) o `Cmd + Shift + R` (Mac)
2. Esto forzará la descarga de la nueva versión de la aplicación
3. Solicita un nuevo enlace de recuperación
4. Prueba de nuevo

**Solución 2: Limpiar caché del navegador**
1. Abre DevTools (F12)
2. Ve a la pestaña "Network"
3. Marca "Disable cache"
4. Recarga la página
5. Solicita un nuevo enlace

**Solución 3: Verificar que la nueva versión está desplegada**
```powershell
# En Windows PowerShell
cd C:\dev\proyecto_flutter_supabase\frontend
flutter build web
# Luego despliega la carpeta build/web a tu servidor
```

### Problema: Los logs no aparecen en la consola

**Causa:** Puede que tengas un filtro activo en la consola.

**Solución:**
1. Abre DevTools (F12)
2. Ve a "Console"
3. Asegúrate de que **no haya filtros** activos
4. Verifica que el nivel de log sea "Verbose" o "All levels"

### Problema: Error "otp_expired"

**Causa:** El enlace ha expirado (válido por 1 hora).

**Solución:**
1. Solicita un nuevo enlace desde "¿Olvidaste tu contraseña?"
2. Haz clic en el nuevo enlace dentro de 1 hora
3. Completa el cambio de contraseña

### Problema: Error "No se pudo validar el enlace"

**Posibles causas:**
1. El enlace ya fue usado anteriormente
2. El enlace expiró
3. Hay un problema de conectividad con Supabase

**Solución:**
1. Verifica que tienes conexión a internet
2. Solicita un nuevo enlace
3. No hagas clic múltiples veces en el mismo enlace

## 📊 Comparación: Antes vs Después

| Aspecto | Antes | Después |
|---------|-------|---------|
| URL de redirect | `http://localhost:8082/reset-password` | `https://fct.jualas.es/reset-password` ✅ |
| Limpieza de hash | ❌ Tardía, insuficiente | ✅ Inmediata, múltiple |
| Logs de debug | ❌ Mínimos | ✅ Detallados |
| Timing del procesamiento | ❌ Inmediato (race condition) | ✅ Con microtask delay |
| Pantalla mostrada | ❌ Login (incorrecto) | ✅ Formulario de cambio ✅ |
| Experiencia del usuario | ❌ Confusa | ✅ Clara |

## 📝 Archivos Modificados

1. **`frontend/lib/services/auth_service.dart`**
   - Cambiado `redirectTo` a URL fija de producción
   - Añadido log de la URL de redirect

2. **`frontend/lib/screens/auth/reset_password_screen.dart`**
   - Nuevo método `_cleanUrlHash()`
   - Procesamiento con `Future.microtask()`
   - Logs detallados en todo el flujo
   - Múltiples pasos de limpieza de URL

3. **Rebuild de la aplicación**
   - `flutter build web` ejecutado
   - Nueva versión lista para deploy

## ✅ Checklist de Verificación

**Después de desplegar:**
- [ ] Forzar recarga del navegador (`Ctrl + Shift + R`)
- [ ] Solicitar nuevo enlace de recuperación
- [ ] Verificar logs en consola del navegador
- [ ] Confirmar que se muestra el formulario de cambio
- [ ] Probar cambio de contraseña completo
- [ ] Verificar login con nueva contraseña

**En producción (fct.jualas.es):**
- [ ] URLs configuradas en Supabase:
  - Site URL: `https://fct.jualas.es`
  - Redirect URLs incluye: `https://fct.jualas.es/reset-password`
- [ ] Aplicación desplegada en el servidor
- [ ] Probar flujo completo en producción

## 🎯 Resultado Esperado Final

```
Usuario solicita recuperación
    ↓
Email enviado con enlace: https://fct.jualas.es/reset-password?code=...
    ↓
Usuario hace clic en el enlace
    ↓
URL limpiada automáticamente (sin #/login)
    ↓
Token procesado correctamente
    ↓
✅ Se muestra FORMULARIO DE CAMBIO de contraseña
    (NO la pantalla de login)
    ↓
Usuario introduce nueva contraseña 2 veces
    ↓
Contraseña actualizada en Supabase Auth
    ↓
Redirigido al login después de 2 segundos
    ↓
Usuario inicia sesión con nueva contraseña
    ↓
✅ Acceso exitoso al sistema
```

---

**Documentación relacionada:**
- `docs/desarrollo/CONFIGURAR_EMAIL_RECUPERACION_CONTRASEÑA.md`
- `docs/desarrollo/RESUMEN_CONFIGURACION_RECUPERACION_PASSWORD.md`
- `frontend/lib/screens/auth/reset_password_screen.dart`
- `frontend/lib/services/auth_service.dart`

