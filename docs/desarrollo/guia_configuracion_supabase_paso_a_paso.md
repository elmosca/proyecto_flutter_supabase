# 🔧 Guía Paso a Paso: Configuración de Supabase para Creación de Usuarios

Esta guía te ayudará a configurar Supabase Dashboard para que el sistema de creación de usuarios funcione correctamente.

## 📋 Índice

1. [Configurar Template de Email "Confirm sign up"](#1-configurar-template-de-email-confirm-sign-up)
2. [Configurar Template de Email "Reset password"](#2-configurar-template-de-email-reset-password)
3. [Configurar URLs de Redirección](#3-configurar-urls-de-redirección)
4. [Verificar Configuración de Autenticación](#4-verificar-configuración-de-autenticación)
5. [Configurar SMTP (Opcional para Producción)](#5-configurar-smtp-opcional-para-producción)

---

## 1. Configurar Template de Email "Confirm sign up"

### Paso 1: Acceder al Template

1. En Supabase Dashboard, ve a **Authentication** → **Emails**
2. Asegúrate de estar en la pestaña **"Templates"**
3. Selecciona el template **"Confirm sign up"**

### Paso 2: Modificar el Subject

1. En el campo **"Subject heading"**, cambia:
   - **De:** `Confirm Your Signup`
   - **A:** `Bienvenido al Sistema de Gestión TFG - Verifica tu Email`

### Paso 3: Modificar el Contenido del Email

1. Asegúrate de estar en la pestaña **"<> Source"** (no Preview)
2. **Reemplaza todo el contenido HTML** con el siguiente código:

```html
<h2>Bienvenido al Sistema de Gestión TFG</h2>

<p>Hola{{ if .Data.full_name }} {{ .Data.full_name }}{{ else }}{{ if .Email }} {{ .Email }}{{ end }}{{ end }},</p>

<p>Se ha creado una cuenta para ti en el <strong>Sistema de Gestión de Proyectos TFG</strong> del CIFP Carlos III.</p>

<p><strong>Para completar tu registro, sigue estos pasos:</strong></p>

<ol>
  <li><strong>Verifica tu email:</strong> Haz clic en el siguiente enlace para confirmar tu dirección de correo:</li>
  <li style="margin: 16px 0;">
    <a href="{{ .ConfirmationURL }}" style="background-color: #2196F3; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;">
      ✅ Confirmar mi email
    </a>
  </li>
  <li><strong>Establece tu contraseña:</strong> Después de verificar tu email, serás redirigido automáticamente a una página donde podrás establecer tu contraseña personal</li>
  <li><strong>Inicia sesión</strong> con tu nueva contraseña</li>
</ol>

<p><strong>Nota técnica:</strong> El redireccionamiento a la pantalla de configuración de contraseña se configura automáticamente en el código de la aplicación. No necesitas modificar el enlace en el template.</p>

<div style="background-color: #f5f5f5; padding: 16px; border-radius: 4px; margin: 20px 0;">
  <p><strong>📌 Información importante:</strong></p>
  <ul>
    <li>Tu contraseña es privada y solo tú la conoces</li>
    <li>Debes establecer tu contraseña personal antes de iniciar sesión por primera vez</li>
    <li>Si tienes problemas, contacta a tu tutor o administrador</li>
  </ul>
</div>

<p>Si no solicitaste esta cuenta, puedes ignorar este email.</p>

<hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">

<p style="color: #666; font-size: 14px;">
  Saludos,<br>
  <strong>Equipo del Sistema TFG</strong><br>
  CIFP Carlos III
</p>
```

### Paso 4: Verificar el Preview

1. Haz clic en la pestaña **"Preview"** para ver cómo se verá el email
2. Verifica que el enlace de confirmación esté visible y funcional
3. Asegúrate de que las instrucciones sean claras

### Paso 5: Guardar Cambios

1. Haz clic en el botón verde **"Save changes"** en la parte inferior derecha
2. Espera a que aparezca el mensaje de confirmación

---

## 2. Configurar Template de Email "Reset password"

Este template se usa cuando un usuario solicita restablecer su contraseña (haciendo clic en "¿Olvidaste tu contraseña?").

### Paso 1: Acceder al Template

1. En Supabase Dashboard, ve a **Authentication** → **Emails**
2. Asegúrate de estar en la pestaña **"Templates"**
3. Selecciona el template **"Reset password"**

### Paso 2: Modificar el Subject

1. En el campo **"Subject heading"**, cambia:
   - **De:** `Reset Your Password`
   - **A:** `Restablecer Contraseña - Sistema TFG`

### Paso 3: Modificar el Contenido del Email

1. Asegúrate de estar en la pestaña **"<> Source"** (no Preview)
2. **Reemplaza todo el contenido HTML** con el siguiente código:

```html
<h2>Restablecer Contraseña</h2>

<p>Hola{{ if .Data.full_name }} {{ .Data.full_name }}{{ else }}{{ if .Email }} {{ .Email }}{{ end }}{{ end }},</p>

<p>Recibimos una solicitud para restablecer la contraseña de tu cuenta en el <strong>Sistema de Gestión de Proyectos TFG</strong> del CIFP Carlos III.</p>

<p><strong>Para establecer una nueva contraseña, sigue estos pasos:</strong></p>

<ol>
  <li>Haz clic en el siguiente enlace (válido por 1 hora):</li>
  <li style="margin: 16px 0;">
    <a href="{{ .ConfirmationURL }}" style="background-color: #2196F3; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;">
      🔒 Restablecer mi contraseña
    </a>
  </li>
  <li>Serás redirigido a una página donde podrás ingresar tu nueva contraseña</li>
  <li>Ingresa tu nueva contraseña dos veces para confirmarla</li>
  <li>Haz clic en "Cambiar Contraseña"</li>
  <li>Inicia sesión con tu nueva contraseña</li>
</ol>

<div style="background-color: #fff3cd; padding: 16px; border-radius: 4px; margin: 20px 0; border-left: 4px solid #ffc107;">
  <p><strong>⚠️ Importante:</strong></p>
  <ul>
    <li>Este enlace expira en <strong>1 hora</strong> por seguridad</li>
    <li>Si no solicitaste este cambio, puedes ignorar este email</li>
    <li>Tu contraseña actual seguirá siendo válida si no haces clic en el enlace</li>
    <li>Si tienes problemas, contacta a tu tutor o administrador</li>
  </ul>
</div>

<p style="color: #666; font-size: 14px;">
  Si no solicitaste restablecer tu contraseña, puedes ignorar este email de forma segura.
</p>

<hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">

<p style="color: #666; font-size: 14px;">
  Saludos,<br>
  <strong>Equipo del Sistema TFG</strong><br>
  CIFP Carlos III
</p>
```

### Paso 4: Verificar el Preview

1. Haz clic en la pestaña **"Preview"** para ver cómo se verá el email
2. Verifica que el enlace de restablecimiento esté visible y funcional
3. Asegúrate de que las instrucciones sean claras

### Paso 5: Guardar Cambios

1. Haz clic en el botón verde **"Save changes"** en la parte inferior derecha
2. Espera a que aparezca el mensaje de confirmación

---

## 3. Configurar URLs de Redirección

### Paso 1: Acceder a URL Configuration

1. En Supabase Dashboard, ve a **Authentication** → **URL Configuration**

### Paso 2: Configurar Site URL

1. En el campo **"Site URL"**, ingresa:
   - **Desarrollo:** `http://localhost:8080`
   - **Producción:** `https://tu-dominio.com` (tu dominio real)

### Paso 3: Añadir Redirect URLs

**⚠️ IMPORTANTE:** Las URLs deben ser **completas** (con protocolo `http://` o `https://` y dominio), NO solo rutas como `/reset-password`.

1. En la sección **"Redirect URLs"**, haz clic en **"Add URL"** o el botón **"+"** (icono de más)
2. Añade las siguientes URLs **una por una**, haciendo clic en **"Add URL"** cada vez:

   **Para Desarrollo:**
   ```
   http://localhost:8080/reset-password
   http://localhost:8080/reset-password?type=setup
   http://localhost:8080/reset-password?type=reset
   http://localhost:8080/**
   ```

   **Para Producción:**
   ```
   https://tu-dominio.com/reset-password
   https://tu-dominio.com/reset-password?type=setup
   https://tu-dominio.com/reset-password?type=reset
   https://tu-dominio.com/**
   ```

   **Ejemplo visual de cómo debe verse:**
   ```
   ✅ CORRECTO:
   http://localhost:8080/reset-password
   https://mi-app.com/reset-password
   
   ❌ INCORRECTO:
   /reset-password                    ← Falta protocolo y dominio
   reset-password                     ← Falta protocolo y dominio
   localhost:8080/reset-password      ← Falta http://
   ```

   **Nota importante:** 
   - El patrón `**` (wildcard) permite cualquier ruta en tu dominio, lo cual es útil para desarrollo. En producción, puedes ser más específico si lo prefieres.
   - Las URLs con `?type=setup` y `?type=reset` permiten diferenciar entre el establecimiento de contraseña por primera vez y la recuperación de contraseña.
   - **Alternativa más simple:** Si solo quieres añadir una URL, puedes usar el wildcard `http://localhost:8080/**` que cubrirá todas las rutas, incluyendo los parámetros de query (`?type=setup`, `?type=reset`).

### Paso 4: Guardar Cambios

1. Haz clic en **"Save changes"** en la parte inferior
2. Verifica que todas las URLs aparezcan en la lista

---

## 4. Diferenciación entre Primer Uso y Recuperación de Contraseña

El sistema diferencia automáticamente entre dos escenarios:

### Escenario 1: Usuario Nuevo (Primera Vez) - `type=setup`

**Cuándo ocurre:**
- Cuando un administrador o tutor crea un nuevo usuario
- El usuario recibe un email "Confirm sign up" para verificar su email
- Después de verificar, necesita establecer su contraseña por primera vez

**Cómo funciona:**
1. El usuario hace clic en el enlace del email "Confirm sign up"
2. El enlace puede redirigir a `/reset-password?type=setup` (si se configura en el template)
3. La pantalla muestra: **"Establecer Contraseña"** con instrucciones específicas para primera vez
4. El usuario establece su contraseña personal
5. Puede iniciar sesión con su nueva contraseña

### Escenario 2: Usuario Existente (Recuperación) - `type=reset`

**Cuándo ocurre:**
- Cuando un usuario existente olvida su contraseña
- El usuario hace clic en "¿Olvidaste tu contraseña?" en la pantalla de login

**Cómo funciona:**
1. El usuario ingresa su email en el diálogo "¿Olvidaste tu contraseña?"
2. Recibe un email "Reset password" con un enlace
3. El enlace redirige automáticamente a `/reset-password?type=reset` (configurado en el código)
4. La pantalla muestra: **"Restablecer Contraseña"** con instrucciones para recuperación
5. El usuario establece una nueva contraseña
6. Puede iniciar sesión con su nueva contraseña

### Diferencias Visuales

| Aspecto | Primera Vez (`type=setup`) | Recuperación (`type=reset`) |
|---------|---------------------------|---------------------------|
| **Título** | "Establecer Contraseña" | "Restablecer Contraseña" |
| **Icono** | 🔓 Lock Open | 🔒 Lock Reset |
| **Instrucciones** | "Establece tu contraseña personal para acceder al sistema..." | "Ingresa tu nueva contraseña para restablecer el acceso..." |
| **Contexto** | Usuario nuevo, primera configuración | Usuario existente, recuperación |

---

## 5. Verificar Configuración de Autenticación

### Paso 1: Acceder a Sign In / Providers

1. En Supabase Dashboard, ve a **Authentication** → **Sign In / Providers**
2. Asegúrate de estar en la pestaña **"Supabase Auth"**

### Paso 2: Verificar Configuración

Verifica que estos ajustes estén configurados así:

✅ **Allow new users to sign up:** **ON** (verde)
- Esto permite que los administradores creen usuarios mediante `signUp()`

✅ **Confirm email:** **ON** (verde)
- Esto asegura que los usuarios reciban el email de verificación

❌ **Allow manual linking:** **OFF** (gris)
- No es necesario para este flujo

❌ **Allow anonymous sign-ins:** **OFF** (gris)
- No es necesario para este flujo

### Paso 3: Guardar si hay Cambios

1. Si hiciste algún cambio, haz clic en **"Save changes"**

---

## 6. Configurar SMTP (Opcional para Producción)

> ⚠️ **Importante:** El servicio de email integrado de Supabase tiene límites de tasa. Para producción, es **altamente recomendado** configurar un SMTP personalizado.

### Paso 1: Acceder a SMTP Settings

1. En Supabase Dashboard, ve a **Authentication** → **Emails**
2. Haz clic en la pestaña **"SMTP Settings"**
3. Haz clic en el botón **"Set up SMTP"** (o en el toggle "Enable Custom SMTP")

### Paso 2: Configurar Sender Details

**Sender email:**
- Ingresa: `noreply@cifpcarlos3.es` (o tu dominio)
- Este es el email desde el que se enviarán los correos

**Sender name:**
- Ingresa: `Sistema TFG - CIFP Carlos III`
- Este es el nombre que verán los usuarios en su bandeja de entrada

### Paso 3: Configurar SMTP Provider

**Opciones de Proveedores SMTP:**

#### Opción A: Gmail (Pruebas)
- **Host:** `smtp.gmail.com`
- **Port:** `587` (o `465` para SSL)
- **Username:** Tu email de Gmail
- **Password:** Una contraseña de aplicación de Gmail (no tu contraseña normal)

#### Opción B: Resend (Recomendado)
- **Host:** `smtp.resend.com`
- **Port:** `587`
- **Username:** `resend`
- **Password:** Tu API key de Resend

#### Opción C: SendGrid
- **Host:** `smtp.sendgrid.net`
- **Port:** `587`
- **Username:** `apikey`
- **Password:** Tu API key de SendGrid

#### Opción D: Mailgun
- **Host:** `smtp.mailgun.org`
- **Port:** `587`
- **Username:** Tu SMTP username de Mailgun
- **Password:** Tu SMTP password de Mailgun

### Paso 4: Configurar Intervalo

**Minimum interval between emails:**
- Deja el valor por defecto: `60` segundos
- Esto previene el envío excesivo de emails

### Paso 5: Habilitar y Guardar

1. Activa el toggle **"Enable Custom SMTP"** (debe estar verde)
2. Verifica que todos los campos estén completos (aparece un aviso amarillo si falta algo)
3. Haz clic en **"Save changes"**
4. Espera a que aparezca el mensaje de confirmación

### Paso 6: Probar el SMTP

1. Crea un usuario de prueba desde la aplicación
2. Verifica que el email llegue correctamente
3. Revisa los logs en Supabase Dashboard si hay problemas

---

## ✅ Checklist de Verificación

Antes de considerar la configuración completa, verifica:

- [ ] Template "Confirm sign up" modificado con instrucciones claras
- [ ] Template "Reset password" modificado con instrucciones claras
- [ ] Site URL configurada correctamente
- [ ] Redirect URLs incluyen `/reset-password`
- [ ] "Allow new users to sign up" está ON
- [ ] "Confirm email" está ON
- [ ] SMTP configurado (para producción) o al menos verificado que funciona
- [ ] Prueba de creación de usuario funciona
- [ ] Email de verificación llega correctamente
- [ ] Usuario puede verificar email
- [ ] Usuario puede usar "¿Olvidaste tu contraseña?" para establecer contraseña
- [ ] Email de reset de contraseña llega correctamente
- [ ] Usuario puede restablecer su contraseña desde el enlace

---

## 🧪 Prueba Completa del Flujo

### 1. Crear Usuario de Prueba

1. En la aplicación, como administrador, crea un nuevo estudiante o tutor
2. Verifica que aparezca el mensaje de éxito con instrucciones
3. Anota el email del usuario creado

### 2. Verificar Email

1. Revisa el buzón de entrada del email del usuario
2. Verifica que el email tenga:
   - Asunto correcto
   - Instrucciones claras
   - Enlace de confirmación funcional

### 3. Verificar Email del Usuario

1. Haz clic en el enlace "Confirmar mi email"
2. Verifica que se abra la aplicación y confirme el email
3. Deberías ver un mensaje de confirmación

### 4. Establecer Contraseña (Primera vez)

1. Ve a la pantalla de login
2. Haz clic en "¿Olvidaste tu contraseña?"
3. Ingresa el email del usuario
4. Verifica que llegue el email de reset con el template configurado
5. Abre el email y verifica que tenga instrucciones claras
6. Haz clic en el enlace "Restablecer mi contraseña"
7. Verifica que se abra la pantalla de cambio de contraseña
8. Establece una nueva contraseña
9. Verifica que puedas iniciar sesión con la nueva contraseña

### 5. Probar Restablecimiento de Contraseña (Usuario existente)

1. Como usuario autenticado, cierra sesión
2. Ve a la pantalla de login
3. Haz clic en "¿Olvidaste tu contraseña?"
4. Ingresa tu email
5. Verifica que llegue el email de reset
6. Verifica que el email tenga instrucciones claras y el enlace funcional
7. Haz clic en el enlace y cambia tu contraseña
8. Inicia sesión con la nueva contraseña

---

## 🐛 Solución de Problemas Comunes

### ❌ El email no llega

**Solución:**
1. Verifica la carpeta de spam
2. Revisa los logs en Supabase Dashboard → Authentication → Logs
3. Verifica que el SMTP esté configurado correctamente
4. Verifica que el email del usuario sea válido

### ❌ El enlace de verificación no funciona

**Solución:**
1. Verifica que la URL esté en "Redirect URLs"
2. Verifica que la Site URL sea correcta
3. Revisa los logs del navegador (F12) para ver errores
4. Verifica que la URL de la aplicación sea accesible

### ❌ El usuario no puede establecer contraseña

**Solución:**
1. Verifica que el usuario haya verificado su email primero
2. Verifica que el enlace de reset no haya expirado (normalmente expiran en 1 hora)
3. Intenta solicitar un nuevo enlace de reset
4. Verifica que la ruta `/reset-password` esté en Redirect URLs

### ❌ Error "User already registered"

**Solución:**
1. Esto significa que el email ya existe en Supabase Auth
2. El usuario puede usar "¿Olvidaste tu contraseña?" directamente
3. O puedes eliminar el usuario de Supabase Auth y crearlo nuevamente

---

## 📚 Recursos Adicionales

- [Documentación oficial de Supabase Auth](https://supabase.com/docs/guides/auth)
- [Email Templates de Supabase](https://supabase.com/docs/guides/auth/auth-email-templates)
- [Configuración de SMTP](https://supabase.com/docs/guides/auth/auth-smtp)
- [Guía de Resend](https://resend.com/docs)

---

## 💡 Consejos

1. **Prueba primero en desarrollo** antes de configurar producción
2. **Usa un servicio SMTP confiable** para producción (Resend, SendGrid, etc.)
3. **Revisa los logs regularmente** para detectar problemas
4. **Mantén las URLs actualizadas** si cambias de dominio
5. **Documenta tus credenciales SMTP** de forma segura

---

**Última actualización:** Enero 2025  
**Versión:** 1.0

