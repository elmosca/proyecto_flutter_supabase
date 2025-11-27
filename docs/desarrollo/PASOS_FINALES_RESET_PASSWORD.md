# ✅ Pasos Finales para Probar Reset Password

## 🎯 Estado Actual

- ✅ Configuración de Supabase completada
- ✅ Código actualizado para usar `Uri.base.origin`
- ✅ Aplicación reconstruida con `flutter build web`

## 🚀 Pasos para Probar AHORA

### 1️⃣ Forzar Recarga del Navegador

**MUY IMPORTANTE:** El navegador tiene la versión antigua en caché.

```
Presiona: Ctrl + Shift + R
```

O:
1. Abre DevTools (F12)
2. Pestaña "Network"
3. Marca "Disable cache"
4. Recarga la página

### 2️⃣ Abrir DevTools para Ver Logs

1. Presiona **F12**
2. Ve a la pestaña **"Console"**
3. Déjala abierta durante todo el proceso

### 3️⃣ Solicitar Nuevo Enlace de Recuperación

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

### 4️⃣ Verificar el Email

1. Abre el buzón de correo
2. Busca el email de "Restablecer Contraseña"
3. **ANTES de hacer clic**, pasa el mouse sobre el botón "🔒 Restablecer mi contraseña"
4. En la esquina inferior izquierda del navegador, verás la URL de destino

**✅ URL esperada:**
```
http://localhost:8082/reset-password?token=...&type=...
```

**❌ URL antigua (si ves esto, necesitas solicitar un NUEVO enlace):**
```
http://localhost:8082/?code=...#/login
```

### 5️⃣ Hacer Clic en el Enlace del Email

1. Asegúrate de que la consola sigue abierta (F12)
2. Haz clic en el botón "🔒 Restablecer mi contraseña"

**En la consola deberías ver:**
```
🧹 Limpiando hash problemático: #/login
🔗 URL actual: http://localhost:8082/reset-password?code=...&type=reset#/login
🔗 Pathname: /reset-password
🔗 Search: ?code=...&type=reset
✅ URL limpiada a: /reset-password?code=...&type=reset
🔍 Iniciando procesamiento de token...
🔗 URL actual: http://localhost:8082/reset-password?code=...&type=reset
🔐 Intentando obtener sesión desde URL...
📊 Sesión obtenida: ✅ SÍ
✅ Token válido - usuario autenticado temporalmente
👤 Usuario: juanantonio.frances.perez@gmail.com
🔗 URL final limpia: /reset-password?type=reset
```

### 6️⃣ Verificar la Pantalla

**✅ Deberías ver:**
- Título: "Restablecer Contraseña"
- Icono de candado 🔒
- **DOS campos de entrada:**
  - "Nueva Contraseña"
  - "Confirmar Contraseña"
- Botón: "Cambiar Contraseña"

**❌ NO deberías ver:**
- Pantalla de login
- Campos de "Email" y "Contraseña" de inicio de sesión

### 7️⃣ Cambiar la Contraseña

1. **Nueva Contraseña:** Introduce `TestPass123!`
2. **Confirmar Contraseña:** Introduce `TestPass123!`
3. Haz clic en **"Cambiar Contraseña"**

**Resultado esperado:**
- ✅ Mensaje de confirmación: "Contraseña cambiada exitosamente"
- ✅ Espera 2 segundos
- ✅ Redirigido automáticamente al login

### 8️⃣ Iniciar Sesión con Nueva Contraseña

1. **Email:** `juanantonio.frances.perez@gmail.com`
2. **Contraseña:** `TestPass123!`
3. Haz clic en "Iniciar Sesión"

**Resultado esperado:**
- ✅ Acceso exitoso al dashboard del estudiante

## 🔍 Qué Hacer Según lo que Veas

### ✅ Caso 1: Todo Funciona

Si ves el formulario de cambio de contraseña:
- **¡Perfecto!** El problema está resuelto
- Completa los pasos 7 y 8
- Confirma que el login funciona con la nueva contraseña

### ❌ Caso 2: Sigo viendo el Login

Si todavía ves la pantalla de login:
- **Copia TODOS los logs** de la consola (desde el paso 3)
- Envíamelos para diagnóstico
- **Copia la URL completa** que ves en la barra de direcciones
- Envíamela también

### ⚠️ Caso 3: Error "otp_expired"

Si ves un mensaje de error sobre enlace expirado:
- El enlace ya expiró (válido por 1 hora)
- Solicita un **nuevo** enlace desde el paso 3
- Haz clic en el nuevo enlace dentro de 1 hora

## 📋 Checklist Completo

- [ ] Navegador recargado con `Ctrl + Shift + R`
- [ ] DevTools abierta (F12) en pestaña "Console"
- [ ] Solicitado nuevo enlace de recuperación
- [ ] Logs visibles en consola con URL base correcta
- [ ] Email recibido
- [ ] URL del enlace verificada (pasa mouse sobre botón)
- [ ] URL contiene `/reset-password` (no solo `/?code=...`)
- [ ] Hecho clic en el enlace
- [ ] Logs de procesamiento visibles en consola
- [ ] Formulario de cambio de contraseña mostrado
- [ ] Contraseña cambiada exitosamente
- [ ] Login con nueva contraseña funciona

## 💡 Tips Importantes

### Si la URL del Email sigue siendo `/?code=...`

Esto significa que el enlace se generó **ANTES** de actualizar el código. Los enlaces antiguos no cambiarán.

**Solución:**
1. Solicita un **NUEVO** enlace
2. Verifica que la consola muestre:
   ```
   📧 URL base: http://localhost:8082
   📧 URL de redirect completa: http://localhost:8082/reset-password?type=reset
   ```
3. El nuevo enlace debería tener la URL correcta

### Si sigo sin ver los Logs

**Verifica que:**
1. La consola no tiene filtros activos
2. El nivel de logs es "Verbose" o "All levels"
3. Has recargado con `Ctrl + Shift + R`
4. Estás en la pestaña correcta del navegador

## 📸 Capturas Esperadas

### En la Consola (Paso 3):
```
🔐 Solicitando reset de contraseña para: juanantonio.frances.perez@gmail.com
📧 URL base: http://localhost:8082
📧 URL de redirect completa: http://localhost:8082/reset-password?type=reset
✅ Email de reset de contraseña enviado
```

### En el Email (Paso 4):
Pasa el mouse sobre el botón y en la esquina inferior verás:
```
http://localhost:8082/reset-password?token=abc123...
```

### En la Consola (Paso 5):
```
🧹 Limpiando hash problemático: #/login
✅ URL limpiada a: /reset-password?code=...
🔍 Iniciando procesamiento de token...
📊 Sesión obtenida: ✅ SÍ
✅ Token válido - usuario autenticado temporalmente
```

### En la Pantalla (Paso 6):
- Título grande: "Restablecer Contraseña"
- Texto explicativo
- Dos campos de texto para contraseña
- Botón azul: "Cambiar Contraseña"

---

**🚨 IMPORTANTE:** Por favor, realiza estos pasos en orden y compárteme:
1. Los logs completos de la consola
2. La URL que aparece en el email (paso 4)
3. Qué pantalla ves después de hacer clic (formulario o login)

Con esta información podré ayudarte a diagnosticar cualquier problema restante.

