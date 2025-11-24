# 📧 Configuración de Email de Verificación de Usuarios

Esta guía explica cómo configurar el sistema de creación de usuarios y verificación de email para que los usuarios puedan establecer sus propias contraseñas.

## 🎯 Flujo Completo

Cuando un administrador o tutor crea un usuario:

1. **Admin/Tutor crea usuario** con email y contraseña temporal
2. **Sistema envía email de verificación** automáticamente a través de Supabase
3. **Usuario recibe email** y verifica su dirección de correo
4. **Usuario usa "¿Olvidaste tu contraseña?"** para establecer su contraseña personal
5. **Usuario puede iniciar sesión** con su nueva contraseña

## 🔧 Configuración en Supabase Dashboard

### Paso 1: Configurar Template de Email "Confirm sign up"

1. Ve a tu proyecto en Supabase Dashboard
2. Navega a **Authentication > Email Templates**
3. Selecciona el template **"Confirm sign up"**
4. Modifica el template HTML con el siguiente contenido (usa `{{ .Data.full_name }}` en lugar de `{{ .FullName }}`):

```html
<h2>Bienvenido al Sistema de Gestión TFG</h2>

<p>Hola{{ if .Data.full_name }} {{ .Data.full_name }}{{ else }}{{ if .Email }} {{ .Email }}{{ end }}{{ end }},</p>

<p>Se ha creado una cuenta para ti en el Sistema de Gestión de Proyectos TFG del CIFP Carlos III.</p>

<p><strong>Para completar tu registro, sigue estos pasos:</strong></p>

<ol>
  <li><strong>Verifica tu email:</strong> Haz clic en el siguiente enlace para confirmar tu dirección de correo:</li>
  <li><a href="{{ .ConfirmationURL }}">Confirmar mi email</a></li>
  <li><strong>Establece tu contraseña:</strong> Después de verificar tu email, ve a la pantalla de login y haz clic en "¿Olvidaste tu contraseña?"</li>
  <li><strong>Ingresa tu email</strong> y recibirás un enlace para establecer tu contraseña personal</li>
  <li><strong>Inicia sesión</strong> con tu nueva contraseña</li>
</ol>

<p><strong>Información importante:</strong></p>
<ul>
  <li>Tu contraseña es privada y solo tú la conoces</li>
  <li>Debes establecer tu contraseña personal antes de iniciar sesión por primera vez</li>
  <li>Si tienes problemas, contacta a tu tutor o administrador</li>
</ul>

<p>Si no solicitaste esta cuenta, puedes ignorar este email.</p>

<p>Saludos,<br>
Equipo del Sistema TFG<br>
CIFP Carlos III</p>
```

### Paso 2: Configurar Template de Email "Reset password"

Este template se usa cuando un usuario solicita restablecer su contraseña.

1. En Supabase Dashboard, ve a **Authentication > Email Templates**
2. Selecciona el template **"Reset password"**
3. Modifica el template HTML con el siguiente contenido:

```html
<h2>Restablecer Contraseña</h2>

<p>Hola{{ if .Data.full_name }} {{ .Data.full_name }}{{ else }}{{ if .Email }} {{ .Email }}{{ end }}{{ end }},</p>

<p>Recibimos una solicitud para restablecer la contraseña de tu cuenta en el <strong>Sistema de Gestión de Proyectos TFG</strong> del CIFP Carlos III.</p>

<p><strong>Para establecer una nueva contraseña, sigue estos pasos:</strong></p>

<ol>
  <li>Haz clic en el siguiente enlace (válido por 1 hora):</li>
  <li><a href="{{ .ConfirmationURL }}">🔒 Restablecer mi contraseña</a></li>
  <li>Serás redirigido a una página donde podrás ingresar tu nueva contraseña</li>
  <li>Ingresa tu nueva contraseña dos veces para confirmarla</li>
  <li>Haz clic en "Cambiar Contraseña"</li>
  <li>Inicia sesión con tu nueva contraseña</li>
</ol>

<p><strong>⚠️ Importante:</strong> Este enlace expira en 1 hora por seguridad. Si no solicitaste este cambio, puedes ignorar este email.</p>

<p>Saludos,<br>
Equipo del Sistema TFG<br>
CIFP Carlos III</p>
```

### Paso 3: Configurar URL de Redirección

1. Ve a **Authentication > URL Configuration**
2. En **"Redirect URLs"**, añade las siguientes URLs:
   - Para desarrollo: `http://localhost:8080/reset-password`
   - Para producción: `https://tu-dominio.com/reset-password`
   - También añade: `https://tu-dominio.com/**` (para permitir cualquier ruta)

### Paso 4: Verificar Configuración de Email

1. Ve a **Authentication > Settings**
2. Asegúrate de que:
   - ✅ **"Confirm email"** está activado (ON)
   - ✅ **"Allow new users to sign up"** está activado (ON)

### Paso 5: Configurar SMTP (Recomendado para Producción)

Para producción, es recomendable configurar un SMTP personalizado:

1. Ve a **Authentication > Email Templates**
2. Haz clic en **"Set up SMTP"**
3. Configura tu proveedor de email (Gmail, SendGrid, Resend, etc.)
4. Sigue las instrucciones del proveedor

**Nota:** El servicio de email integrado de Supabase tiene límites de tasa y no es recomendado para producción.

## 📱 Experiencia del Usuario

### Cuando un Admin/Tutor crea un usuario:

1. **Mensaje en la aplicación:**
   ```
   Usuario creado exitosamente
   El usuario recibirá un email de verificación. Después de verificar, 
   deberá usar "¿Olvidaste tu contraseña?" para establecer su contraseña.
   ```

2. **Email recibido por el usuario:**
   - Contiene instrucciones claras
   - Enlace para verificar email
   - Pasos para establecer contraseña

3. **Proceso del usuario:**
   - Verifica email → Click en enlace
   - Va a login → Click en "¿Olvidaste tu contraseña?"
   - Ingresa email → Recibe enlace de reset
   - Establece contraseña → Puede iniciar sesión

## 🔒 Seguridad

- **Contraseñas privadas:** Cada usuario establece su propia contraseña
- **Verificación de email:** Previene creación de cuentas falsas
- **Control de acceso:** Admin/Tutor pueden desactivar usuarios si es necesario
- **Reset de contraseña:** Los usuarios pueden recuperar su contraseña si la olvidan

## 🧪 Pruebas

Para probar el flujo completo:

1. **Crear usuario de prueba:**
   - Admin crea un usuario con email válido
   - Verifica que se muestre el mensaje de éxito

2. **Verificar email:**
   - Abre el email recibido
   - Haz clic en el enlace de verificación
   - Verifica que se confirme el email

3. **Establecer contraseña:**
   - Ve a la pantalla de login
   - Haz clic en "¿Olvidaste tu contraseña?"
   - Ingresa el email
   - Recibe el enlace de reset
   - Establece una nueva contraseña

4. **Iniciar sesión:**
   - Usa el email y la nueva contraseña
   - Verifica que puedas acceder al sistema

## 📝 Notas Importantes

- **Contraseña temporal:** La contraseña que ingresa el admin/tutor al crear el usuario es temporal y no se usa para login
- **Privacidad:** El usuario es el único que conoce su contraseña final
- **Flexibilidad:** Si un usuario olvida su contraseña, puede usar "¿Olvidaste tu contraseña?" en cualquier momento
- **Control administrativo:** Los admins pueden desactivar usuarios, pero no pueden ver sus contraseñas

## 🐛 Solución de Problemas

### El usuario no recibe el email de verificación:
- Verifica la configuración SMTP
- Revisa la carpeta de spam
- Verifica que el email esté correcto
- Revisa los logs en Supabase Dashboard

### El enlace de reset no funciona:
- Verifica que la URL esté en "Redirect URLs"
- Verifica que la URL de la aplicación sea correcta
- Revisa los logs del navegador para errores

### El usuario no puede establecer contraseña:
- Verifica que haya verificado su email primero
- Verifica que el enlace de reset no haya expirado
- Intenta solicitar un nuevo enlace de reset

## 📚 Referencias

- [Documentación de Supabase Auth](https://supabase.com/docs/guides/auth)
- [Email Templates de Supabase](https://supabase.com/docs/guides/auth/auth-email-templates)
- [Configuración de SMTP](https://supabase.com/docs/guides/auth/auth-smtp)

