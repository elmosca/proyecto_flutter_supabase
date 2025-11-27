# 📧 Template de Email para Reset de Contraseña - Edge Function

## 📋 Instrucciones

Este documento contiene el código completo para añadir el template de email de reset de contraseña a la Edge Function `send-email` en Supabase.

---

## 🔧 Paso 1: Acceder a la Edge Function

1. Ve a Supabase Dashboard: https://supabase.com/dashboard
2. Selecciona tu proyecto
3. Navega a **Edge Functions** → **send-email**
4. Haz clic en la pestaña **"Code"**

---

## 📝 Paso 2: Añadir el caso `password_reset`

En el switch/case principal de la Edge Function, añade este caso:

```typescript
case 'password_reset':
  return await sendPasswordResetEmail(data);
```

**Ubicación**: Debe ir junto con los otros casos como `'comment_notification'`, `'status_change'`, etc.

---

## 📝 Paso 3: Crear la función `sendPasswordResetEmail`

Añade esta función al final del archivo, antes del cierre:

```typescript
/**
 * Envía email de notificación cuando se resetea una contraseña de estudiante
 */
async function sendPasswordResetEmail(data: any) {
  const { studentEmail, studentName, newPassword, resetBy, resetByName } = data;

  // Obtener la URL de la aplicación desde variables de entorno o usar un valor por defecto
  const APP_URL = Deno.env.get('APP_URL') || 'https://tu-app.supabase.co';

  // Template HTML del email
  const html = `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Contraseña Restablecida</title>
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
      transition: transform 0.2s;
    }
    .button:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 8px rgba(102, 126, 234, 0.4);
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
    .info-box {
      background-color: #e7f3ff;
      border-left: 4px solid #2196F3;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
      font-size: 14px;
      color: #0c5460;
    }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <h1>🔒 Contraseña Restablecida</h1>
    </div>
    
    <div class="content">
      <div class="greeting">
        Hola <strong>${studentName}</strong>,
      </div>
      
      <div class="message">
        Tu contraseña ha sido restablecida por <strong>${resetByName}</strong> (${resetBy === 'administrador' ? 'Administrador' : 'Tutor'}).
      </div>
      
      <div class="password-container">
        <div class="password-label">Tu Nueva Contraseña</div>
        <div class="password-value">${newPassword}</div>
      </div>
      
      <div class="warning-box">
        <strong>⚠️ Importante:</strong>
        <ul>
          <li>Guarda esta contraseña en un lugar seguro</li>
          <li>Puedes cambiarla después de iniciar sesión desde tu perfil</li>
          <li>Si no solicitaste este cambio, contacta inmediatamente a tu tutor o administrador</li>
          <li>Por seguridad, no compartas esta contraseña con nadie</li>
        </ul>
      </div>
      
      <div class="info-box">
        <strong>💡 Consejo:</strong> Después de iniciar sesión, te recomendamos cambiar esta contraseña por una que solo tú conozcas.
      </div>
      
      <div class="button-container">
        <a href="${APP_URL}/login" class="button">Iniciar Sesión</a>
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
  `;

  // Template de texto plano (para clientes de email que no soportan HTML)
  const text = `
🔒 CONTRASEÑA RESTABLECIDA

Hola ${studentName},

Tu contraseña ha sido restablecida por ${resetByName} (${resetBy === 'administrador' ? 'Administrador' : 'Tutor'}).

TU NUEVA CONTRASEÑA:
${newPassword}

⚠️ IMPORTANTE:
- Guarda esta contraseña en un lugar seguro
- Puedes cambiarla después de iniciar sesión desde tu perfil
- Si no solicitaste este cambio, contacta inmediatamente a tu tutor o administrador
- Por seguridad, no compartas esta contraseña con nadie

💡 CONSEJO:
Después de iniciar sesión, te recomendamos cambiar esta contraseña por una que solo tú conozcas.

Inicia sesión en: ${APP_URL}/login

---
Sistema de Gestión de Proyectos TFG
CIFP Carlos III

Este es un email automático, por favor no respondas.
Si tienes problemas para acceder, contacta a tu tutor o administrador.
  `;

  // Enviar el email usando Resend API
  const resendApiKey = Deno.env.get('RESEND_API_KEY');
  if (!resendApiKey) {
    throw new Error('RESEND_API_KEY no está configurada');
  }

  // Usar fetch directamente a la API de Resend (más compatible con Edge Functions)
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${resendApiKey}`,
    },
    body: JSON.stringify({
      from: 'Sistema TFG <noreply@cifpcarlos3.es>', // ⚠️ Cambia esto por tu dominio verificado
      to: studentEmail,
      subject: '🔒 Tu contraseña ha sido restablecida - Sistema TFG',
      html: html,
      text: text,
    }),
  });

  // Leer el texto de la respuesta primero para manejar respuestas vacías o no-JSON
  const responseText = await response.text();
  
  // Verificar si la respuesta está vacía
  if (!responseText || responseText.trim().length === 0) {
    throw new Error(`Error enviando email: Respuesta vacía de Resend API (Status: ${response.status})`);
  }

  // Intentar parsear JSON
  let result;
  try {
    result = JSON.parse(responseText);
  } catch (parseError) {
    throw new Error(`Error parseando respuesta de Resend: ${parseError.message}. Respuesta recibida: ${responseText.substring(0, 200)}`);
  }

  // Verificar si hay errores en la respuesta
  if (!response.ok) {
    const errorMessage = result?.error?.message || result?.message || result?.error || `Error HTTP ${response.status}`;
    throw new Error(`Error enviando email: ${errorMessage}`);
  }

  if (result.error) {
    throw new Error(`Error enviando email: ${result.error.message || result.error || 'Error desconocido'}`);
  }

  return {
    success: true,
    messageId: result.id || 'unknown',
  };
}
```

---

## ⚠️ Importante: No se requiere importar Resend

Este código usa `fetch` directamente a la API de Resend, por lo que **NO necesitas importar el SDK de Resend**. 

El código es compatible con Edge Functions de Supabase sin dependencias adicionales. Solo necesitas tener configurada la variable de entorno `RESEND_API_KEY` en Supabase.

---

## 🔧 Paso 4: Configurar Variable de Entorno (Opcional)

Si quieres usar una URL dinámica de la aplicación, añade esta variable de entorno en Supabase:

1. Ve a **Settings** → **Edge Functions** → **Secrets**
2. Añade: `APP_URL` = `https://tu-dominio.com`

Si no la configuras, se usará el valor por defecto del código.

---

## 📋 Código Completo del Switch/Case

Si necesitas ver cómo debería verse el switch completo, aquí tienes un ejemplo:

```typescript
serve(async (req) => {
  try {
    const { type, data } = await req.json();

    switch (type) {
      case 'comment_notification':
        return await sendCommentNotification(data);
      
      case 'status_change':
        return await sendStatusChangeNotification(data);
      
      case 'welcome':
        return await sendWelcomeEmail(data);
      
      case 'reminder':
        return await sendReminderNotification(data);
      
      case 'tutor_notification':
        return await sendTutorNotification(data);
      
      case 'password_reset':  // ← AÑADE ESTE CASO
        return await sendPasswordResetEmail(data);
      
      default:
        return new Response(
          JSON.stringify({ error: `Tipo de email desconocido: ${type}` }),
          { status: 400, headers: { 'Content-Type': 'application/json' } }
        );
    }
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});
```

---

## ✅ Verificación

Después de añadir el código:

1. **Guarda los cambios** en la Edge Function
2. **Despliega** la función (si es necesario)
3. **Prueba** desde la aplicación Flutter reseteando una contraseña
4. **Verifica** que el email llega correctamente

---

## 🎨 Personalización

Puedes personalizar:

- **Colores**: Cambia los valores de `#667eea` y `#764ba2` por los colores de tu marca
- **Dominio del remitente**: Cambia `noreply@cifpcarlos3.es` por tu dominio verificado en Resend
- **URL de la aplicación**: Configura `APP_URL` o cambia el valor por defecto
- **Estilos**: Modifica los estilos CSS según tus preferencias

---

## 📝 Notas de Seguridad

- ⚠️ **Nunca registres contraseñas en logs**: El código no registra la contraseña
- ⚠️ **Usa HTTPS**: Asegúrate de que `APP_URL` use HTTPS
- ⚠️ **Verifica el dominio**: El dominio del remitente debe estar verificado en Resend

---

## 🔗 Referencias

- Documentación de Resend: https://resend.com/docs
- Edge Functions de Supabase: https://supabase.com/docs/guides/functions

