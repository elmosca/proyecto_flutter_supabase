# Guía: Configurar Plantilla "Invite User" en Supabase

## 📋 Resumen

Esta guía te ayudará a configurar la plantilla de email "Invite User" en Supabase para que los estudiantes reciban un email con:
- Su contraseña temporal visible
- Información de su tutor
- Todos sus datos de registro
- Un enlace para acceder al sistema

## 🎯 Objetivo

Cuando un tutor o administrador crea un estudiante, el estudiante recibirá automáticamente un email de Supabase Auth con toda su información y su contraseña temporal.

## 📝 Pasos de Configuración

### 1. Acceder a Supabase Dashboard

1. Ve a [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Selecciona tu proyecto
3. En el menú lateral, ve a **Authentication** (icono de candado 🔒)
4. Haz clic en **Email Templates**

### 2. Seleccionar la Plantilla "Invite User"

1. En la lista de plantillas, busca **"Invite user"**
2. Haz clic sobre ella para editarla

### 3. Configurar el Asunto (Subject)

En el campo **"Subject"**, reemplaza el texto existente con:

```
🎓 Bienvenido al Sistema TFG - CIFP Carlos III
```

### 4. Configurar el Cuerpo del Email (Body)

1. **Elimina todo el contenido actual** del campo "Body"
2. **Copia y pega** el siguiente código HTML completo:

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

### 5. Guardar los Cambios

1. Revisa que el código HTML esté completo y sin errores
2. Haz clic en el botón **"Save"** (Guardar) en la parte inferior
3. Verifica que aparezca un mensaje de confirmación

## ✅ Verificación

Para verificar que la plantilla está correctamente configurada:

1. Ve a **Authentication → Email Templates → Invite user**
2. Verifica que el **Subject** sea: `🎓 Bienvenido al Sistema TFG - CIFP Carlos III`
3. Verifica que el **Body** contenga el HTML completo con las variables `{{ .Data.temporary_password }}`, `{{ .Data.tutor_name }}`, etc.

## 🔑 Variables Importantes

La plantilla usa estas variables que se pasan desde la aplicación:

- `{{ .Email }}` - Email del estudiante
- `{{ .Data.temporary_password }}` - **Contraseña temporal visible**
- `{{ .Data.full_name }}` - Nombre completo
- `{{ .Data.tutor_name }}` - Nombre del tutor
- `{{ .Data.tutor_email }}` - Email del tutor
- `{{ .Data.tutor_phone }}` - Teléfono del tutor
- `{{ .Data.academic_year }}` - Año académico
- `{{ .Data.student_phone }}` - Teléfono del estudiante
- `{{ .Data.student_nre }}` - NRE del estudiante
- `{{ .Data.student_specialty }}` - Especialidad
- `{{ .Data.created_by_name }}` - Nombre del creador
- `{{ .ConfirmationURL }}` - Enlace para acceder (autentica automáticamente)

## 🚀 Próximos Pasos

Una vez configurada la plantilla:

1. **Despliega la Edge Function** `super-action` actualizada en Supabase
2. **Prueba el flujo completo**:
   - Crea un estudiante desde el formulario
   - Verifica que el email llegue con la contraseña visible
   - Prueba el enlace de acceso
   - Verifica que el estudiante pueda iniciar sesión

## 💡 Ventajas de Este Enfoque

✅ **Email automático de Supabase Auth** - No depende de Resend  
✅ **Contraseña visible** - El tutor y el estudiante la ven  
✅ **Información completa** - Tutor, datos del alumno, etc.  
✅ **Acceso inmediato** - El estudiante puede usar la contraseña o el enlace  
✅ **Cambio opcional** - El estudiante puede cambiar su contraseña después  

## 🆘 Solución de Problemas

### El email no llega

1. Verifica que la plantilla esté guardada correctamente
2. Revisa los logs de Supabase en **Authentication → Logs**
3. Verifica que la Edge Function `super-action` esté desplegada
4. Comprueba que no haya errores en los logs de la Edge Function

### La contraseña no aparece en el email

1. Verifica que la variable `{{ .Data.temporary_password }}` esté en la plantilla
2. Comprueba que la Edge Function esté pasando `temporary_password` en el objeto `data`
3. Revisa los logs de la Edge Function para ver qué datos se están enviando

### El enlace no funciona

1. Verifica que `{{ .ConfirmationURL }}` esté en la plantilla
2. Comprueba la configuración de **Site URL** y **Redirect URLs** en **Authentication → URL Configuration**
3. Asegúrate de que la URL de tu aplicación esté correctamente configurada

## 📚 Documentación Relacionada

- [plantilla_email_invite_user_supabase.md](./plantilla_email_invite_user_supabase.md) - Plantilla completa con explicaciones
- [super-action_edge_function_completo.ts](./super-action_edge_function_completo.ts) - Código de la Edge Function
- [edge_function_super_action_crear_usuario_sin_verificacion.md](./edge_function_super_action_crear_usuario_sin_verificacion.md) - Documentación de la Edge Function

