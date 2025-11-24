# Plantilla de Email "Invite User" en Supabase

Esta plantilla se usa cuando invitamos a un usuario (estudiante) con una **contraseña temporal visible** en el email.

## Configuración en Supabase Dashboard

1. Ve a **Authentication → Email Templates**
2. Selecciona **"Invite user"**
3. Configura los siguientes campos:

### Subject (Asunto)
```
🎓 Bienvenido al Sistema TFG - CIFP Carlos III
```

### Body (HTML)
Copia y pega el siguiente código HTML:

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bienvenido al Sistema TFG</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      line-height: 1.6;
      color: #333333;
      background-color: #f4f4f4;
      margin: 0;
      padding: 0;
    }
    .email-container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
    }
    .header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #ffffff;
      padding: 30px 20px;
      text-align: center;
    }
    .header h1 {
      margin: 0;
      font-size: 24px;
      font-weight: 600;
    }
    .content {
      padding: 30px 20px;
      background-color: #ffffff;
    }
    .greeting {
      font-size: 18px;
      margin-bottom: 20px;
      color: #333333;
    }
    .message {
      font-size: 16px;
      color: #666666;
      margin-bottom: 25px;
    }
    .info-box {
      background-color: #e7f3ff;
      border-left: 4px solid #2196F3;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
      font-size: 14px;
      color: #0c5460;
    }
    .info-box strong {
      display: block;
      margin-bottom: 8px;
      color: #0c5460;
    }
    .info-box p {
      margin: 5px 0;
    }
    .password-container {
      background-color: #f8f9fa;
      border: 2px dashed #667eea;
      border-radius: 8px;
      padding: 20px;
      margin: 25px 0;
      text-align: center;
    }
    .password-label {
      font-size: 14px;
      color: #666666;
      margin-bottom: 10px;
      text-transform: uppercase;
      letter-spacing: 1px;
    }
    .password-value {
      font-size: 24px;
      font-weight: bold;
      color: #667eea;
      font-family: 'Courier New', monospace;
      letter-spacing: 2px;
      word-break: break-all;
    }
    .tutor-info {
      background-color: #f0f9ff;
      border-left: 4px solid #0ea5e9;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
    }
    .tutor-info h3 {
      margin: 0 0 10px 0;
      color: #0c4a6e;
      font-size: 16px;
    }
    .tutor-info p {
      margin: 5px 0;
      color: #075985;
      font-size: 14px;
    }
    .warning-box {
      background-color: #fff3cd;
      border-left: 4px solid #ffc107;
      padding: 15px;
      margin: 25px 0;
      border-radius: 4px;
    }
    .warning-box strong {
      color: #856404;
      display: block;
      margin-bottom: 10px;
    }
    .warning-box ul {
      margin: 10px 0;
      padding-left: 20px;
      color: #856404;
    }
    .warning-box li {
      margin-bottom: 8px;
    }
    .button-container {
      text-align: center;
      margin: 30px 0;
    }
    .button {
      display: inline-block;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #ffffff;
      padding: 14px 28px;
      text-decoration: none;
      border-radius: 6px;
      font-weight: 600;
      font-size: 16px;
      box-shadow: 0 4px 6px rgba(102, 126, 234, 0.3);
    }
    .footer {
      background-color: #f8f9fa;
      padding: 20px;
      text-align: center;
      font-size: 12px;
      color: #999999;
      border-top: 1px solid #e9ecef;
    }
    .footer p {
      margin: 5px 0;
    }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <h1>🎓 ¡Bienvenido al Sistema TFG!</h1>
    </div>
    
    <div class="content">
      <div class="greeting">
        Hola <strong>{{ if .Data.full_name }}{{ .Data.full_name }}{{ else }}{{ .Email }}{{ end }}</strong>,
      </div>
      
      <div class="message">
        Has sido añadido al <strong>Sistema de Gestión de Proyectos TFG</strong> del CIFP Carlos III por <strong>{{ if .Data.created_by_name }}{{ .Data.created_by_name }}{{ else }}el administrador{{ end }}</strong>.
      </div>
      
      <div class="info-box">
        <strong>📋 Información de tu cuenta:</strong>
        <p><strong>Email:</strong> {{ .Email }}</p>
        {{ if .Data.student_nre }}<p><strong>NRE:</strong> {{ .Data.student_nre }}</p>{{ end }}
        {{ if .Data.student_phone }}<p><strong>Teléfono:</strong> {{ .Data.student_phone }}</p>{{ end }}
        {{ if .Data.academic_year }}<p><strong>Año académico:</strong> {{ .Data.academic_year }}</p>{{ end }}
        {{ if .Data.student_specialty }}<p><strong>Especialidad:</strong> {{ .Data.student_specialty }}</p>{{ end }}
      </div>
      
      {{ if .Data.tutor_name }}
      <div class="tutor-info">
        <h3>👨‍🏫 Tu Tutor Asignado</h3>
        <p><strong>Nombre:</strong> {{ .Data.tutor_name }}</p>
        {{ if .Data.tutor_email }}<p><strong>Email:</strong> <a href="mailto:{{ .Data.tutor_email }}">{{ .Data.tutor_email }}</a></p>{{ end }}
        {{ if .Data.tutor_phone }}<p><strong>Teléfono:</strong> <a href="tel:{{ .Data.tutor_phone }}">{{ .Data.tutor_phone }}</a></p>{{ end }}
        <p style="margin-top: 10px; font-size: 13px; color: #075985;">
          <strong>💬 Puedes contactar a tu tutor directamente por email o teléfono para cualquier consulta sobre tu proyecto TFG.</strong>
        </p>
      </div>
      {{ end }}
      
      <div class="password-container">
        <div class="password-label">Tu Contraseña Temporal</div>
        <div class="password-value">{{ .Data.temporary_password }}</div>
      </div>
      
      <div class="warning-box">
        <strong>⚠️ Importante:</strong>
        <ul>
          <li>Esta es tu contraseña temporal para acceder al sistema</li>
          <li>Guárdala en un lugar seguro</li>
          <li>Puedes cambiarla después de iniciar sesión desde tu perfil</li>
          <li>Por seguridad, no compartas esta contraseña con nadie</li>
        </ul>
      </div>
      
      <div class="button-container">
        <a href="{{ .ConfirmationURL }}" class="button">Acceder al Sistema</a>
      </div>
      
      <div class="info-box">
        <strong>💡 Próximos pasos:</strong>
        <p>1. Haz clic en el botón "Acceder al Sistema"</p>
        <p>2. Inicia sesión con tu email y la contraseña temporal</p>
        <p>3. Cambia tu contraseña desde tu perfil (recomendado)</p>
        <p>4. Completa tu perfil si es necesario</p>
        <p>5. Comienza a trabajar en tu proyecto TFG</p>
        {{ if .Data.tutor_name }}<p>6. Contacta a tu tutor {{ .Data.tutor_name }} si tienes alguna pregunta</p>{{ end }}
      </div>
    </div>
    
    <div class="footer">
      <p><strong>Sistema de Gestión de Proyectos TFG</strong></p>
      <p>CIFP Carlos III</p>
      <p>Este es un email automático, por favor no respondas.</p>
      <p style="margin-top: 10px; font-size: 11px;">
        Si tienes problemas para acceder, contacta a tu tutor o administrador.
      </p>
    </div>
  </div>
</body>
</html>
```

## Variables Disponibles en la Plantilla

Las siguientes variables están disponibles en la plantilla y se pasan desde la Edge Function:

- `{{ .Email }}` - Email del usuario
- `{{ .ConfirmationURL }}` - Enlace para acceder al sistema (con token de autenticación)
- `{{ .Data.full_name }}` - Nombre completo del estudiante
- `{{ .Data.temporary_password }}` - **Contraseña temporal** (visible en el email)
- `{{ .Data.tutor_name }}` - Nombre del tutor asignado
- `{{ .Data.tutor_email }}` - Email del tutor
- `{{ .Data.tutor_phone }}` - Teléfono del tutor
- `{{ .Data.academic_year }}` - Año académico
- `{{ .Data.student_phone }}` - Teléfono del estudiante
- `{{ .Data.student_nre }}` - NRE del estudiante
- `{{ .Data.student_specialty }}` - Especialidad del estudiante
- `{{ .Data.created_by }}` - Tipo de creador ('administrador' o 'tutor')
- `{{ .Data.created_by_name }}` - Nombre del creador

## Cómo Funciona

1. El tutor/admin crea un estudiante con una contraseña temporal desde el formulario
2. La aplicación llama a la Edge Function `super-action` con `action: 'invite_user'`
3. La Edge Function usa `inviteUserByEmail()` pasando la contraseña en `data.temporary_password`
4. Supabase envía este email con la contraseña visible
5. El estudiante puede:
   - Usar la contraseña temporal para iniciar sesión directamente
   - O hacer clic en el enlace `{{ .ConfirmationURL }}` que lo autentica automáticamente
6. Una vez dentro, puede cambiar su contraseña desde su perfil

## Ventajas de Este Enfoque

✅ El tutor ve la contraseña al crearla  
✅ El alumno la recibe por email (usando el sistema de Supabase Auth, no Resend)  
✅ El alumno puede iniciar sesión inmediatamente  
✅ El alumno puede cambiar la contraseña después  
✅ No dependemos de Resend para este email crítico  
✅ Toda la información del tutor y alumno está en el email  

## Notas Importantes

- El email se envía **automáticamente** por Supabase Auth cuando se invoca `inviteUserByEmail()`
- La contraseña se establece mediante `updateUserById()` después de la invitación
- El enlace `{{ .ConfirmationURL }}` autentica al usuario automáticamente (no requiere login)
- Si el usuario prefiere, puede ignorar el enlace y usar email + contraseña temporal para login manual

