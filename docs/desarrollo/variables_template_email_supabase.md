# 📧 Variables Disponibles en Templates de Email de Supabase

Esta guía explica cómo funcionan las variables en los templates de email de Supabase y cómo usarlas correctamente.

## 🔍 Variables Disponibles

Supabase proporciona varias variables predefinidas que puedes usar en tus templates de email:

### Variables Principales

| Variable | Descripción | Ejemplo |
|---------|-------------|---------|
| `{{ .Email }}` | Email del usuario | `usuario@ejemplo.com` |
| `{{ .ConfirmationURL }}` | URL de confirmación de email | `https://.../auth/v1/verify?token=...` |
| `{{ .Token }}` | Token de verificación | `abc123...` |
| `{{ .TokenHash }}` | Hash del token (para PKCE flow) | `hash123...` |
| `{{ .SiteURL }}` | URL base de tu sitio | `https://tu-dominio.com` |
| `{{ .RedirectTo }}` | URL de redirección después de verificar | `https://tu-dominio.com/welcome` |
| `{{ .Data }}` | Objeto con los metadatos del usuario | `{"full_name": "Juan Pérez", ...}` |

### Acceder a Metadatos del Usuario

Los metadatos pasados en `signUp()` con el parámetro `data` están disponibles como `{{ .Data.campo }}`:

```html
<!-- Si pasaste data: { full_name: "Juan Pérez", role: "student" } -->
<p>Hola {{ .Data.full_name }}</p>
<p>Tu rol es: {{ .Data.role }}</p>
```

### Variables con Fallback

Puedes usar condicionales para tener valores por defecto:

```html
{{ if .Data.full_name }}
  <p>Hola {{ .Data.full_name }}</p>
{{ else }}
  <p>Hola</p>
{{ end }}
```

O más conciso:

```html
<p>Hola{{ if .Data.full_name }} {{ .Data.full_name }}{{ else }} Usuario{{ end }},</p>
```

## 🔧 Cómo Funciona en Nuestro Código

### En `UserManagementService.createStudent()`

Cuando creamos un estudiante, pasamos los metadatos así:

```dart
await _supabase.auth.signUp(
  email: email,
  password: password,
  data: {
    'full_name': fullName,  // ← Esto se almacena en user_metadata
    'role': 'student',
  },
);
```

Estos datos se almacenan en la tabla `auth.users` en la columna `raw_user_meta_data` y están disponibles en los templates como:

- `{{ .Data.full_name }}` → Nombre completo
- `{{ .Data.role }}` → Rol del usuario

### En `UserManagementService.createTutor()`

Para tutores, si usas una función RPC, los metadatos deben pasarse en la función RPC o también puedes hacer signUp antes:

```dart
// Opción 1: Si la RPC maneja todo
await _supabase.rpc('create_tutor', params: {...});

// Opción 2: Si quieres pasar metadatos explícitamente
await _supabase.auth.signUp(
  email: email,
  password: password,
  data: {
    'full_name': fullName,
    'role': 'tutor',
  },
);
```

## 📝 Template Recomendado

Aquí está el template completo con manejo correcto de variables:

```html
<h2>Bienvenido al Sistema de Gestión TFG</h2>

<p>Hola{{ if .Data.full_name }} {{ .Data.full_name }}{{ else }}{{ if .Email }}{{ .Email }}{{ end }}{{ end }},</p>

<p>Se ha creado una cuenta para ti en el <strong>Sistema de Gestión de Proyectos TFG</strong> del CIFP Carlos III.</p>

<p><strong>Para completar tu registro, sigue estos pasos:</strong></p>

<ol>
  <li><strong>Verifica tu email:</strong> Haz clic en el siguiente enlace para confirmar tu dirección de correo:</li>
  <li style="margin: 16px 0;">
    <a href="{{ .ConfirmationURL }}" style="background-color: #2196F3; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;">
      ✅ Confirmar mi email
    </a>
  </li>
  <li><strong>Establece tu contraseña:</strong> Después de verificar tu email, ve a la pantalla de login y haz clic en <strong>"¿Olvidaste tu contraseña?"</strong></li>
  <li><strong>Ingresa tu email</strong> ({{ .Email }}) y recibirás un enlace para establecer tu contraseña personal</li>
  <li><strong>Inicia sesión</strong> con tu nueva contraseña</li>
</ol>

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

## 🔍 Verificar Metadatos

Para verificar que los metadatos se están guardando correctamente:

1. Ve a Supabase Dashboard → Authentication → Users
2. Selecciona un usuario
3. Busca la sección "User Metadata" o "Raw User Meta Data"
4. Deberías ver algo como:

```json
{
  "full_name": "Juan Pérez García",
  "role": "student"
}
```

## ⚠️ Notas Importantes

1. **Sintaxis Go Templates**: Supabase usa la sintaxis de Go Templates
2. **Mayúsculas/Minúsculas**: Las variables son case-sensitive: `{{ .Data.full_name }}` no es igual a `{{ .Data.FullName }}`
3. **Nombres de campos**: Los nombres deben coincidir exactamente con los pasados en `data`
4. **Variables disponibles**: No todas las variables están disponibles en todos los templates (Confirm sign up vs Reset password)

## 🧪 Prueba del Template

Para probar que el template funciona:

1. Crea un usuario de prueba desde la aplicación
2. Revisa el email recibido
3. Verifica que:
   - El nombre del usuario aparezca correctamente
   - El enlace de confirmación funcione
   - Todas las variables se rendericen correctamente

## 📚 Referencias

- [Go Templates Documentation](https://pkg.go.dev/text/template)
- [Supabase Email Templates](https://supabase.com/docs/guides/auth/auth-email-templates)
- [Supabase Auth signUp](https://supabase.com/docs/reference/javascript/auth-signup)

