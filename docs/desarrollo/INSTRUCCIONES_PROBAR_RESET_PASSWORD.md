# 🧪 Instrucciones para Probar Reset Password

## ✅ Cambios Implementados

He corregido el problema donde el enlace de recuperación de contraseña redirigía al login.

**Mejoras aplicadas:**
1. ✅ URL de redirect configurada como `https://fct.jualas.es/reset-password`
2. ✅ Limpieza mejorada del hash `#/login` que causaba problemas
3. ✅ Logs detallados para debugging
4. ✅ Aplicación reconstruida con `flutter build web`

## 🚀 Pasos para Probar

### 1. Desplegar la Nueva Versión

La aplicación ya está reconstruida. Necesitas desplegar la carpeta `frontend/build/web` a tu servidor.

### 2. Forzar Recarga en el Navegador

**MUY IMPORTANTE:** El navegador puede tener la versión antigua en caché.

**En Windows:**
```
Ctrl + Shift + R
```

**En Mac:**
```
Cmd + Shift + R
```

**Alternativa:**
1. Abre DevTools (F12)
2. Pestaña "Network"
3. Marca "Disable cache"
4. Recarga la página

### 3. Probar el Flujo Completo

#### Paso 1: Solicitar Recuperación

1. Ve a http://localhost:8082/login
2. Haz clic en "¿Olvidaste tu contraseña?"
3. Introduce: `juanantonio.frances.perez@gmail.com`
4. Envía

**✅ Deberías ver:** "Se ha enviado un correo..."

#### Paso 2: Abrir DevTools

**ANTES** de hacer clic en el enlace del email:

1. Presiona **F12** para abrir DevTools
2. Ve a la pestaña **"Console"**
3. Déjala abierta para ver los logs

#### Paso 3: Hacer Clic en el Enlace

1. Abre el email recibido
2. Haz clic en "🔒 Restablecer mi contraseña"

**✅ En la consola deberías ver:**
```
🧹 Limpiando hash problemático: #/login
🔗 URL actual: ...
✅ URL limpiada a: ...
🔍 Iniciando procesamiento de token...
🔐 Intentando obtener sesión desde URL...
📊 Sesión obtenida: ✅ SÍ
✅ Token válido - usuario autenticado temporalmente
👤 Usuario: juanantonio.frances.perez@gmail.com
🔗 URL final limpia: /reset-password?type=reset
```

**✅ En la pantalla deberías ver:**
- Un formulario con dos campos: "Nueva Contraseña" y "Confirmar Contraseña"
- **NO** la pantalla de login

#### Paso 4: Cambiar la Contraseña

1. Introduce una nueva contraseña: `TestPass123!`
2. Confirma la misma contraseña
3. Haz clic en "Cambiar Contraseña"

**✅ Deberías ver:**
- Mensaje de confirmación
- Redirigido al login automáticamente

#### Paso 5: Iniciar Sesión

1. Email: `juanantonio.frances.perez@gmail.com`
2. Contraseña: `TestPass123!`
3. Iniciar Sesión

**✅ Deberías:** Acceder al dashboard correctamente

## 🔍 Qué Buscar en los Logs

### ✅ Logs Buenos (Funcionando)

```
🧹 Limpiando hash problemático: #/login
✅ URL limpiada a: /reset-password?code=...
🔍 Iniciando procesamiento de token...
🔐 Intentando obtener sesión desde URL...
📊 Sesión obtenida: ✅ SÍ
✅ Token válido - usuario autenticado temporalmente
```

**Significado:** Todo funciona correctamente. El hash se limpió, el token se procesó, y la sesión es válida.

### ❌ Logs Malos (Problema)

```
❌ Error detectado en URL: otp_expired
```
**Significado:** El enlace expiró (1 hora). Solicita un nuevo enlace.

```
📊 Sesión obtenida: ❌ NO
❌ No se pudo obtener una sesión válida
```
**Significado:** El token no se pudo procesar. Posibles causas:
- El enlace ya fue usado
- El enlace expiró
- Hay un problema de conectividad

```
❌ Error al procesar token: ...
```
**Significado:** Hubo una excepción. Revisa el mensaje de error para más detalles.

## 🐛 Si Sigue Fallando

### Opción 1: Verificar Versión Desplegada

Asegúrate de que la nueva versión está desplegada:

```powershell
cd C:\dev\proyecto_flutter_supabase\frontend
# Verifica la fecha de build/web
Get-ChildItem build\web -Recurse | Select-Object Name, LastWriteTime
```

Si la fecha no es reciente (hoy), ejecuta:
```powershell
flutter build web
```

### Opción 2: Limpiar Todo el Caché

1. Cierra el navegador completamente
2. Reabre el navegador
3. Ve directo a http://localhost:8082/login
4. Presiona `Ctrl + Shift + R`
5. Solicita un nuevo enlace

### Opción 3: Usar Modo Incógnito

1. Abre una ventana de incógnito
2. Ve a http://localhost:8082/login
3. Solicita recuperación de contraseña
4. Prueba el flujo completo

### Opción 4: Verificar Configuración de Supabase

Ve a Supabase Dashboard → Authentication → URL Configuration

**Verifica:**
- **Site URL:** `https://fct.jualas.es`
- **Redirect URLs:** Debe incluir:
  - `https://fct.jualas.es/reset-password`
  - `http://localhost:8082/reset-password`

Si no están, añádelas y prueba de nuevo.

## 📸 Capturas Esperadas

### ✅ Correcto: Formulario de Cambio de Contraseña

Deberías ver:
- Título: "Restablecer Contraseña"
- Icono de candado
- Texto explicativo
- **Dos campos de entrada:**
  - "Nueva Contraseña"
  - "Confirmar Contraseña"
- Botón "Cambiar Contraseña"

### ❌ Incorrecto: Pantalla de Login

Si ves:
- Título: "Iniciar Sesión"
- Campo de email
- Campo de contraseña
- Botón "Iniciar Sesión"

**Entonces la redirección sigue fallando.** Comparte los logs de la consola.

## 📋 Checklist de Prueba

- [ ] Aplicación reconstruida con `flutter build web`
- [ ] Nueva versión desplegada (si aplica)
- [ ] Navegador recargado con `Ctrl + Shift + R`
- [ ] DevTools abierta en pestaña "Console"
- [ ] Solicitud de recuperación enviada
- [ ] Email recibido
- [ ] Clic en enlace del email
- [ ] Logs visibles en consola
- [ ] Formulario de cambio de contraseña mostrado (NO login)
- [ ] Contraseña cambiada exitosamente
- [ ] Login con nueva contraseña funciona

## 💬 Comparte los Resultados

Por favor, comparte:

1. **Los logs de la consola** (cópialos y pégalos)
2. **Qué pantalla ves** (formulario de cambio o login)
3. **Algún mensaje de error** si aparece

Esto me ayudará a diagnosticar si persiste algún problema.

## 📚 Documentación Adicional

- `SOLUCION_RESET_PASSWORD_LOGIN_REDIRECT.md` - Explicación técnica detallada
- `CONFIGURAR_EMAIL_RECUPERACION_CONTRASEÑA.md` - Configuración de Supabase
- `RESUMEN_CONFIGURACION_RECUPERACION_PASSWORD.md` - Resumen ejecutivo

---

**¡Importante!** Si después de estos pasos sigues viendo la pantalla de login, comparte los logs de la consola para que pueda ayudarte a diagnosticar el problema.

