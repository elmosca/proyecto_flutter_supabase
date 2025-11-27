# Actualización Requerida para Edge Function send-email

## ⚠️ Acción Necesaria

La Edge Function `send-email` necesita manejar un nuevo tipo de notificación.

## 🆕 Nuevo Tipo de Email

Agregar soporte para: **`password_reset_request_to_tutor`**

### Datos que recibirá:

```typescript
{
  type: 'password_reset_request_to_tutor',
  data: {
    tutorEmail: string,      // Email del tutor
    tutorName: string,        // Nombre del tutor
    studentEmail: string,     // Email del estudiante
    studentName: string,      // Nombre del estudiante
  }
}
```

### Plantilla de Email Sugerida:

```typescript
case 'password_reset_request_to_tutor':
  return {
    to: data.tutorEmail,
    from: 'noreply@tuapp.com',
    subject: `Solicitud de Restablecimiento de Contraseña - ${data.studentName}`,
    html: `
      <h2>Hola ${data.tutorName},</h2>
      
      <p>Tu estudiante <strong>${data.studentName}</strong> (${data.studentEmail}) 
      ha solicitado restablecer su contraseña.</p>
      
      <p>Como su tutor asignado, necesitas generar una nueva contraseña temporal 
      para el estudiante desde la plataforma de gestión.</p>
      
      <h3>¿Qué hacer?</h3>
      <ol>
        <li>Accede a la plataforma de gestión TFG</li>
        <li>Ve a "Mis Estudiantes"</li>
        <li>Selecciona a ${data.studentName}</li>
        <li>Usa la opción "Restablecer Contraseña"</li>
        <li>Se generará una contraseña temporal que deberás compartir con el estudiante</li>
      </ol>
      
      <p><a href="https://tuapp.com/login" 
         style="background-color: #4CAF50; color: white; padding: 10px 20px; 
                text-decoration: none; border-radius: 5px; display: inline-block;">
        Acceder a la Plataforma
      </a></p>
      
      <hr>
      <p style="font-size: 12px; color: #666;">
        Este es un mensaje automático, por favor no respondas a este email.
      </p>
    `,
    text: `
Hola ${data.tutorName},

Tu estudiante ${data.studentName} (${data.studentEmail}) ha solicitado restablecer su contraseña.

Como su tutor asignado, necesitas generar una nueva contraseña temporal para el estudiante desde la plataforma de gestión.

¿Qué hacer?
1. Accede a la plataforma de gestión TFG
2. Ve a "Mis Estudiantes"
3. Selecciona a ${data.studentName}
4. Usa la opción "Restablecer Contraseña"
5. Se generará una contraseña temporal que deberás compartir con el estudiante

Accede aquí: https://tuapp.com/login

---
Este es un mensaje automático, por favor no respondas a este email.
    `,
  };
```

## 📝 Ejemplo de Implementación Completa

```typescript
// supabase/functions/send-email/index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { Resend } from 'npm:resend@2.0.0';

const resend = new Resend(Deno.env.get('RESEND_API_KEY'));

serve(async (req) => {
  try {
    const { type, data } = await req.json();

    let emailParams;

    switch (type) {
      case 'password_reset_request_to_tutor':
        emailParams = {
          from: 'TFG Platform <noreply@tuapp.com>',
          to: data.tutorEmail,
          subject: `Solicitud de Restablecimiento de Contraseña - ${data.studentName}`,
          html: generatePasswordResetRequestEmail(data),
        };
        break;

      // ... otros casos (comment_notification, status_change, etc.)

      default:
        return new Response(
          JSON.stringify({ error: 'Unknown email type' }),
          { status: 400, headers: { 'Content-Type': 'application/json' } }
        );
    }

    const result = await resend.emails.send(emailParams);

    return new Response(
      JSON.stringify({ success: true, id: result.id }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});

function generatePasswordResetRequestEmail(data) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
    </head>
    <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
      <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
        <h2 style="color: #2c3e50;">Hola ${data.tutorName},</h2>
        
        <p>Tu estudiante <strong>${data.studentName}</strong> (${data.studentEmail}) 
        ha solicitado restablecer su contraseña.</p>
        
        <p>Como su tutor asignado, necesitas generar una nueva contraseña temporal 
        para el estudiante desde la plataforma de gestión.</p>
        
        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <h3 style="margin-top: 0;">¿Qué hacer?</h3>
          <ol style="margin: 0;">
            <li>Accede a la plataforma de gestión TFG</li>
            <li>Ve a "Mis Estudiantes"</li>
            <li>Selecciona a ${data.studentName}</li>
            <li>Usa la opción "Restablecer Contraseña"</li>
            <li>Se generará una contraseña temporal que deberás compartir con el estudiante</li>
          </ol>
        </div>
        
        <div style="text-align: center; margin: 30px 0;">
          <a href="https://tuapp.com/login" 
             style="background-color: #4CAF50; color: white; padding: 12px 30px; 
                    text-decoration: none; border-radius: 5px; display: inline-block; 
                    font-weight: bold;">
            Acceder a la Plataforma
          </a>
        </div>
        
        <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
        
        <p style="font-size: 12px; color: #666; text-align: center;">
          Este es un mensaje automático, por favor no respondas a este email.
        </p>
      </div>
    </body>
    </html>
  `;
}
```

## 🚀 Desplegar Actualización

```bash
# Desde el directorio raíz del proyecto
cd supabase/functions/send-email

# Desplegar la función actualizada
supabase functions deploy send-email --no-verify-jwt

# O si necesitas especificar el proyecto
supabase functions deploy send-email --project-ref TU_PROJECT_REF
```

## ✅ Verificación

Una vez desplegada la Edge Function, prueba el flujo:

1. Como estudiante, haz clic en "¿Olvidaste tu contraseña?"
2. Ingresa el email del estudiante
3. Verifica que el tutor asignado reciba el email

## 📧 Configuración de Resend

Asegúrate de tener configurada la API Key de Resend:

```bash
# En Supabase Dashboard > Project Settings > Edge Functions > Secrets
RESEND_API_KEY=re_xxxxxxxxxxxxx
```

