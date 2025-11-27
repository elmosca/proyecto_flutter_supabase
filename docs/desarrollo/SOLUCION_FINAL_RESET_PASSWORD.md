# ✅ Solución Final: Reset Password Funcionando

## 🐛 Problemas Identificados y Resueltos

### Problema 1: Error de Inicialización de Supabase ✅
**Error:** `configuration_missing - Supabase client not initialized`

**Causa:** Supabase se inicializaba de forma asíncrona en `_initApp()` pero la UI se construía antes de que terminara la inicialización.

**Solución:** Movida la inicialización de Supabase al `main()` con `await`, asegurando que Supabase esté completamente inicializado antes de construir la aplicación.

### Problema 2: Enlace Expirado ✅
**Error:** `otp_expired` en la URL

**Causa:** Los enlaces de recuperación de contraseña expiran en **1 hora** y son de **un solo uso**.

**Solución:** Necesitas solicitar un **NUEVO** enlace cada vez que quieras probar.

## 🔧 Cambios Aplicados

### 1. `frontend/lib/main.dart`

**Antes:**
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Supabase se inicializaba en _initApp() después
```

**Después:**
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase ANTES de construir la app
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    debugPrint('✅ Supabase inicializado correctamente');
  } catch (e) {
    debugPrint('❌ Error inicializando Supabase: $e');
  }
  
  runApp(const MyApp());
}
```

### 2. `frontend/lib/services/auth_service.dart`

**URL de redirect ahora usa `Uri.base.origin`:**
```dart
final baseUrl = Uri.base.origin;
final redirectUrl = '$baseUrl/reset-password?type=reset';
```

Esto significa:
- En desarrollo: `http://localhost:8082/reset-password?type=reset`
- En producción: `https://fct.jualas.es/reset-password?type=reset`

### 3. Aplicación Reconstruida ✅
- `flutter build web` ejecutado exitosamente

## 🚀 Pasos para Probar AHORA

### ⚠️ MUY IMPORTANTE

Los enlaces de recuperación:
- ✅ Expiran en **1 hora**
- ✅ Son de **un solo uso**
- ❌ Los enlaces antiguos **NO funcionarán**

**Debes solicitar un NUEVO enlace cada vez que pruebes.**

### Paso 1: Limpiar Todo

1. **Cierra completamente el navegador** (todas las ventanas)
2. **Reabre el navegador**
3. **Ve a:** http://localhost:8082
4. **Fuerza recarga:** `Ctrl + Shift + R`

### Paso 2: Abrir DevTools

1. Presiona **F12**
2. Ve a **"Console"**
3. Limpia la consola (botón 🚫 o `Ctrl + L`)

### Paso 3: Verificar Inicialización

Deberías ver en la consola:
```
✅ Supabase inicializado correctamente
```

**❌ Si ves:**
```
❌ Error inicializando Supabase: ...
```
**Entonces hay un problema con la configuración de Supabase.**

### Paso 4: Solicitar Nuevo Enlace

1. Ve a http://localhost:8082/login
2. Haz clic en "¿Olvidaste tu contraseña?"
3. Introduce: `juanantonio.frances.perez@gmail.com`
4. Haz clic en "Enviar"

**En la consola deberías ver:**
```
🔐 Solicitando reset de contraseña para: juanantonio.frances.perez@gmail.com
📧 URL base: http://localhost:8082
📧 URL de redirect completa: http://localhost:8082/reset-password?type=reset
✅ Email de reset de contraseña enviado
```

### Paso 5: Verificar Email

1. Abre el buzón de correo
2. Busca el email (puede tardar 1-2 minutos)
3. **ANTES de hacer clic**, pasa el mouse sobre el botón "🔒 Restablecer mi contraseña"
4. En la esquina inferior izquierda verás la URL

**✅ URL correcta:**
```
http://localhost:8082/reset-password?token=abc123...&type=...
```

**❌ URL incorrecta (si todavía ves esto):**
```
http://localhost:8082/?code=abc123...
```

### Paso 6: Hacer Clic en el Enlace

**⏰ IMPORTANTE:** Haz clic dentro de 1 hora desde que recibiste el email.

1. Haz clic en el botón "🔒 Restablecer mi contraseña"

**En la consola deberías ver:**
```
🧹 Limpiando hash problemático: #/login
✅ URL limpiada a: /reset-password?code=...&type=reset
🔍 Iniciando procesamiento de token...
🔐 Intentando obtener sesión desde URL...
📊 Sesión obtenida: ✅ SÍ
✅ Token válido - usuario autenticado temporalmente
👤 Usuario: juanantonio.frances.perez@gmail.com
```

**En la pantalla deberías ver:**
- ✅ Formulario con DOS campos de contraseña
- ✅ Botón "Cambiar Contraseña"
- ❌ NO la pantalla de login

### Paso 7: Cambiar Contraseña

1. **Nueva Contraseña:** `TestPass123!`
2. **Confirmar Contraseña:** `TestPass123!`
3. Haz clic en "Cambiar Contraseña"

**Resultado esperado:**
- ✅ Mensaje de éxito
- ✅ Redirigido al login después de 2 segundos

### Paso 8: Iniciar Sesión

1. **Email:** `juanantonio.frances.perez@gmail.com`
2. **Contraseña:** `TestPass123!`
3. Iniciar Sesión

**Resultado esperado:**
- ✅ Acceso exitoso al dashboard

## 🔍 Diagnóstico de Errores

### Error 1: "Supabase client not initialized"

**Logs:**
```
❌ Error inicializando AuthBloc: configuration_missing - Supabase client not initialized
```

**Causa:** La aplicación no se recargó correctamente.

**Solución:**
1. Cierra el navegador completamente
2. Reabre y ve a http://localhost:8082
3. Fuerza recarga: `Ctrl + Shift + R`
4. Verifica que veas: `✅ Supabase inicializado correctamente`

### Error 2: "otp_expired"

**URL:**
```
http://localhost:8082/reset-password?error=access_denied&error_code=otp_expired
```

**Causa:** El enlace expiró (>1 hora) o ya fue usado.

**Solución:**
1. Solicita un **NUEVO** enlace
2. Haz clic en él **dentro de 1 hora**
3. Usa el enlace **solo una vez**

### Error 3: URL sigue siendo `/?code=...`

**Causa:** El email se generó antes de actualizar el código.

**Solución:**
1. Solicita un **NUEVO** enlace
2. Verifica en la consola que veas:
   ```
   📧 URL de redirect completa: http://localhost:8082/reset-password?type=reset
   ```
3. El nuevo email debería tener la URL correcta

### Error 4: Sigo viendo la pantalla de login

**Causa posible 1:** El navegador tiene caché antiguo.

**Solución:**
1. Cierra el navegador completamente
2. Reabre en modo incógnito
3. Ve a http://localhost:8082
4. Solicita nuevo enlace

**Causa posible 2:** Supabase no está inicializado.

**Solución:**
1. Abre DevTools (F12)
2. Busca en la consola: `✅ Supabase inicializado correctamente`
3. Si no aparece, hay un problema de configuración

## 📊 Flujo Completo Esperado

```
Navegador abierto
    ↓
main.dart ejecutado
    ↓
✅ Supabase inicializado correctamente
    ↓
Usuario en login → "¿Olvidaste tu contraseña?"
    ↓
Introduce email y envía
    ↓
Console: 📧 URL de redirect completa: http://localhost:8082/reset-password?type=reset
Console: ✅ Email de reset de contraseña enviado
    ↓
Email recibido (1-2 minutos)
    ↓
Usuario hace clic en el enlace (dentro de 1 hora)
    ↓
Navegador navega a: http://localhost:8082/reset-password?code=...&type=reset
    ↓
Console: 🧹 Limpiando hash problemático
Console: 📊 Sesión obtenida: ✅ SÍ
    ↓
✅ Se muestra FORMULARIO de cambio de contraseña
    ↓
Usuario introduce nueva contraseña (2 veces)
    ↓
Contraseña actualizada en Supabase Auth
    ↓
Redirigido al login
    ↓
Usuario inicia sesión con nueva contraseña
    ↓
✅ Acceso exitoso al dashboard
```

## 📋 Checklist Final

**Preparación:**
- [ ] Navegador cerrado y reabierto
- [ ] DevTools abierta (F12) en "Console"
- [ ] Consola limpiada

**Verificación Inicial:**
- [ ] Se ve: `✅ Supabase inicializado correctamente`
- [ ] NO se ve: `❌ Error inicializando Supabase`

**Solicitud de Enlace:**
- [ ] Navegado a http://localhost:8082/login
- [ ] Solicitado enlace de recuperación
- [ ] Se ve en consola: `📧 URL de redirect completa: http://localhost:8082/reset-password?type=reset`
- [ ] Se ve en consola: `✅ Email de reset de contraseña enviado`

**Verificación de Email:**
- [ ] Email recibido
- [ ] URL del enlace contiene `/reset-password` (pasa mouse sobre botón)
- [ ] Clic en enlace realizado **dentro de 1 hora**

**Procesamiento:**
- [ ] Logs de limpieza de URL visibles
- [ ] Log: `📊 Sesión obtenida: ✅ SÍ`
- [ ] Log: `✅ Token válido - usuario autenticado temporalmente`

**Pantalla:**
- [ ] Se muestra formulario con 2 campos de contraseña
- [ ] NO se muestra pantalla de login

**Cambio de Contraseña:**
- [ ] Contraseña cambiada exitosamente
- [ ] Redirigido al login
- [ ] Login con nueva contraseña funciona

## 💬 Información para Compartir

Si sigue sin funcionar, por favor comparte:

1. **Logs completos de la consola** (desde "✅ Supabase inicializado" hasta el error)
2. **La URL completa** que aparece en el navegador después de hacer clic en el enlace
3. **La URL del email** (pasa mouse sobre botón y copia)
4. **Qué pantalla ves** (formulario de cambio o pantalla de login)
5. **Cuánto tiempo pasó** desde que recibiste el email hasta que hiciste clic

## 🎯 Resultado Final Esperado

Después de estos pasos:
- ✅ Supabase se inicializa correctamente al arrancar la aplicación
- ✅ Los enlaces de recuperación usan la URL correcta (`/reset-password`)
- ✅ El formulario de cambio de contraseña se muestra correctamente
- ✅ Los usuarios pueden cambiar su contraseña de forma autónoma
- ✅ El flujo funciona tanto en desarrollo como en producción

---

**Archivos modificados:**
- ✅ `frontend/lib/main.dart` - Inicialización de Supabase en `main()`
- ✅ `frontend/lib/services/auth_service.dart` - URL de redirect con `Uri.base.origin`
- ✅ `frontend/lib/screens/auth/reset_password_screen.dart` - Limpieza mejorada de URL
- ✅ Aplicación reconstruida con `flutter build web`

