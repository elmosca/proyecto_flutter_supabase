import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');

console.log('🔍 Debug - RESEND_API_KEY exists:', !!RESEND_API_KEY);
console.log('🔍 Debug - RESEND_API_KEY length:', RESEND_API_KEY ? RESEND_API_KEY.length : 0);
console.log('🔍 Debug - RESEND_API_KEY starts with re_:', RESEND_API_KEY ? RESEND_API_KEY.startsWith('re_') : false);

if (!RESEND_API_KEY) {
  console.error('❌ RESEND_API_KEY environment variable is required');
  throw new Error('RESEND_API_KEY environment variable is required');
}

console.log('✅ Resend API Key configured');

async function sendEmail(emailData: {
  to: string;
  subject: string;
  html: string;
  text: string;
}) {
  console.log('📧 Attempting to send email to:', emailData.to);
  console.log('📧 Subject:', emailData.subject);

  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      from: 'Sistema TFG <noreply@fct.jualas.es>',
      to: [emailData.to],
      subject: emailData.subject,
      html: emailData.html,
      text: emailData.text
    })
  });

  console.log('📧 Response status:', response.status);
  console.log('📧 Response headers:', Object.fromEntries(response.headers.entries()));

  if (!response.ok) {
    const error = await response.text();
    console.error('❌ Email send failed:', error);
    throw new Error(`Failed to send email: ${error}`);
  }

  const result = await response.json();
  console.log('✅ Email sent successfully:', result);
  // Devolver el resultado parseado en lugar del response para evitar "Body already consumed"
  return result;
}

function generateCommentNotificationEmail(data: {
  studentEmail: string;
  studentName: string;
  tutorName: string;
  anteprojectTitle: string;
  commentContent: string;
  section: string;
  anteprojectUrl: string;
}) {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Nuevo Comentario en tu Anteproyecto</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #2563eb; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f8fafc; padding: 30px; border-radius: 0 0 8px 8px; }
        .comment-box { background: white; padding: 20px; border-radius: 8px; border-left: 4px solid #2563eb; margin: 20px 0; }
        .section-badge { background: #dbeafe; color: #1e40af; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .button { display: inline-block; background: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
        .footer { text-align: center; color: #6b7280; font-size: 14px; margin-top: 30px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>📝 Nuevo Comentario en tu Anteproyecto</h1>
        </div>
        <div class="content">
          <p>Hola <strong>${data.studentName}</strong>,</p>
          
          <p>Tu tutor <strong>${data.tutorName}</strong> ha realizado un nuevo comentario en tu anteproyecto:</p>
          
          <h2>📋 ${data.anteprojectTitle}</h2>
          
          <div class="comment-box">
            <p><span class="section-badge">${data.section}</span></p>
            <p><strong>Comentario:</strong></p>
            <p>${data.commentContent}</p>
          </div>
          
          <p>Puedes ver todos los comentarios y responder desde la plataforma:</p>
          
          <a href="${data.anteprojectUrl}" class="button">Ver Anteproyecto</a>
          
          <p>¡Sigue trabajando en tu proyecto!</p>
        </div>
        <div class="footer">
          <p>Sistema de Seguimiento de Proyectos TFG</p>
          <p>Este es un mensaje automático, por favor no respondas a este correo.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const text = `
Nuevo Comentario en tu Anteproyecto

Hola ${data.studentName},

Tu tutor ${data.tutorName} ha realizado un nuevo comentario en tu anteproyecto:

Proyecto: ${data.anteprojectTitle}
Sección: ${data.section}

Comentario:
${data.commentContent}

Puedes ver todos los comentarios desde: ${data.anteprojectUrl}

¡Sigue trabajando en tu proyecto!

Sistema de Seguimiento de Proyectos TFG
  `;

  return {
    to: data.studentEmail,
    subject: `📝 Nuevo comentario en "${data.anteprojectTitle}"`,
    html,
    text
  };
}

function generateStatusChangeEmail(data: {
  studentEmail: string;
  studentName: string;
  tutorName: string;
  anteprojectTitle: string;
  newStatus: string;
  tutorComments?: string;
  anteprojectUrl: string;
}) {
  const isApproved = data.newStatus === 'approved';
  const statusText = isApproved ? 'APROBADO' : 'RECHAZADO';
  const statusEmoji = isApproved ? '✅' : '❌';
  const statusColor = isApproved ? '#10b981' : '#ef4444';

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Anteproyecto ${statusText}</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: ${statusColor}; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f8fafc; padding: 30px; border-radius: 0 0 8px 8px; }
        .status-box { background: white; padding: 20px; border-radius: 8px; border-left: 4px solid ${statusColor}; margin: 20px 0; text-align: center; }
        .button { display: inline-block; background: ${statusColor}; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
        .footer { text-align: center; color: #6b7280; font-size: 14px; margin-top: 30px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>${statusEmoji} Anteproyecto ${statusText}</h1>
        </div>
        <div class="content">
          <p>Hola <strong>${data.studentName}</strong>,</p>
          
          <p>Tu anteproyecto ha sido <strong>${statusText.toLowerCase()}</strong> por tu tutor <strong>${data.tutorName}</strong>:</p>
          
          <div class="status-box">
            <h2>📋 ${data.anteprojectTitle}</h2>
            <h3 style="color: ${statusColor};">${statusEmoji} ${statusText}</h3>
          </div>
          
          ${data.tutorComments ? `
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <h3>Comentarios del Tutor:</h3>
              <p>${data.tutorComments}</p>
            </div>
          ` : ''}
          
          ${isApproved ? `
            <p>🎉 ¡Felicidades! Tu anteproyecto ha sido aprobado. Puedes continuar con el desarrollo de tu proyecto.</p>
          ` : `
            <p>📝 Tu anteproyecto necesita algunas modificaciones. Revisa los comentarios del tutor y realiza los cambios necesarios.</p>
          `}
          
          <a href="${data.anteprojectUrl}" class="button">Ver Anteproyecto</a>
        </div>
        <div class="footer">
          <p>Sistema de Seguimiento de Proyectos TFG</p>
          <p>Este es un mensaje automático, por favor no respondas a este correo.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const text = `
Anteproyecto ${statusText}

Hola ${data.studentName},

Tu anteproyecto ha sido ${statusText.toLowerCase()} por tu tutor ${data.tutorName}:

Proyecto: ${data.anteprojectTitle}
Estado: ${statusText}

${data.tutorComments ? `Comentarios del Tutor:\n${data.tutorComments}\n` : ''}

${isApproved ? '¡Felicidades! Tu anteproyecto ha sido aprobado. Puedes continuar con el desarrollo de tu proyecto.' : 'Tu anteproyecto necesita algunas modificaciones. Revisa los comentarios del tutor y realiza los cambios necesarios.'}

Ver anteproyecto: ${data.anteprojectUrl}

Sistema de Seguimiento de Proyectos TFG
  `;

  return {
    to: data.studentEmail,
    subject: `${statusEmoji} Anteproyecto "${data.anteprojectTitle}" ${statusText}`,
    html,
    text
  };
}

function generateMessageToTutorEmail(data: {
  tutorEmail: string;
  tutorName: string;
  studentName: string;
  studentEmail: string;
  anteprojectTitle: string;
  messageContent: string;
}) {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Nuevo Mensaje de Estudiante</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #2563eb; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f8fafc; padding: 30px; border-radius: 0 0 8px 8px; }
        .message-box { background: white; padding: 20px; border-radius: 8px; border-left: 4px solid #2563eb; margin: 20px 0; }
        .button { display: inline-block; background: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
        .footer { text-align: center; color: #6b7280; font-size: 14px; margin-top: 30px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>💬 Nuevo Mensaje de Estudiante</h1>
        </div>
        <div class="content">
          <p>Hola <strong>${data.tutorName}</strong>,</p>
          
          <p>Tu estudiante <strong>${data.studentName}</strong> (${data.studentEmail}) te ha enviado un nuevo mensaje:</p>
          
          <h2>📋 ${data.anteprojectTitle}</h2>
          
          <div class="message-box">
            <p><strong>Mensaje:</strong></p>
            <p>${data.messageContent}</p>
          </div>
          
          <p>Puedes responder desde la plataforma:</p>
          
          <a href="https://fct.jualas.es" class="button">Ver Conversación</a>
        </div>
        <div class="footer">
          <p>Sistema de Seguimiento de Proyectos TFG</p>
          <p>Este es un mensaje automático, por favor no respondas a este correo.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const text = `
Nuevo Mensaje de Estudiante

Hola ${data.tutorName},

Tu estudiante ${data.studentName} (${data.studentEmail}) te ha enviado un nuevo mensaje:

Proyecto: ${data.anteprojectTitle}

Mensaje:
${data.messageContent}

Puedes responder desde: https://fct.jualas.es

Sistema de Seguimiento de Proyectos TFG
  `;

  return {
    to: data.tutorEmail,
    subject: `💬 Nuevo mensaje de ${data.studentName} - ${data.anteprojectTitle}`,
    html,
    text
  };
}

function generateMessageToStudentEmail(data: {
  studentEmail: string;
  studentName: string;
  tutorName: string;
  anteprojectTitle: string;
  messageContent: string;
}) {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Nuevo Mensaje de tu Tutor</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #10b981; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f8fafc; padding: 30px; border-radius: 0 0 8px 8px; }
        .message-box { background: white; padding: 20px; border-radius: 8px; border-left: 4px solid #10b981; margin: 20px 0; }
        .button { display: inline-block; background: #10b981; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
        .footer { text-align: center; color: #6b7280; font-size: 14px; margin-top: 30px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>💬 Nuevo Mensaje de tu Tutor</h1>
        </div>
        <div class="content">
          <p>Hola <strong>${data.studentName}</strong>,</p>
          
          <p>Tu tutor <strong>${data.tutorName}</strong> te ha enviado un nuevo mensaje:</p>
          
          <h2>📋 ${data.anteprojectTitle}</h2>
          
          <div class="message-box">
            <p><strong>Mensaje:</strong></p>
            <p>${data.messageContent}</p>
          </div>
          
          <p>Puedes responder desde la plataforma:</p>
          
          <a href="https://fct.jualas.es" class="button">Ver Conversación</a>
        </div>
        <div class="footer">
          <p>Sistema de Seguimiento de Proyectos TFG</p>
          <p>Este es un mensaje automático, por favor no respondas a este correo.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const text = `
Nuevo Mensaje de tu Tutor

Hola ${data.studentName},

Tu tutor ${data.tutorName} te ha enviado un nuevo mensaje:

Proyecto: ${data.anteprojectTitle}

Mensaje:
${data.messageContent}

Puedes responder desde: https://fct.jualas.es

Sistema de Seguimiento de Proyectos TFG
  `;

  return {
    to: data.studentEmail,
    subject: `💬 Nuevo mensaje de ${data.tutorName} - ${data.anteprojectTitle}`,
    html,
    text
  };
}

function generatePasswordResetRequestToTutorEmail(data: {
  tutorEmail: string;
  tutorName: string;
  studentEmail: string;
  studentName: string;
}) {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Solicitud de Restablecimiento de Contraseña</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #f59e0b; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f8fafc; padding: 30px; border-radius: 0 0 8px 8px; }
        .alert-box { background: #fef3c7; border: 2px solid #f59e0b; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .student-info { background: white; padding: 15px; border-radius: 8px; margin: 20px 0; }
        .steps { background: white; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .steps ol { margin: 0; padding-left: 20px; }
        .steps li { margin: 10px 0; }
        .button { display: inline-block; background: #f59e0b; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; font-weight: bold; }
        .footer { text-align: center; color: #6b7280; font-size: 14px; margin-top: 30px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🔐 Solicitud de Restablecimiento de Contraseña</h1>
        </div>
        <div class="content">
          <p>Hola <strong>${data.tutorName}</strong>,</p>
          
          <div class="alert-box">
            <p style="margin: 0;"><strong>⚠️ Acción Requerida:</strong> Uno de tus estudiantes necesita restablecer su contraseña.</p>
          </div>
          
          <div class="student-info">
            <p><strong>Estudiante:</strong> ${data.studentName}</p>
            <p><strong>Email:</strong> ${data.studentEmail}</p>
          </div>
          
          <p>Como tutor asignado, necesitas generar una nueva contraseña temporal para este estudiante desde la plataforma de gestión.</p>
          
          <div class="steps">
            <h3 style="margin-top: 0;">📋 Pasos a seguir:</h3>
            <ol>
              <li>Accede a la plataforma de gestión TFG</li>
              <li>Ve a la sección <strong>"Mis Estudiantes"</strong></li>
              <li>Selecciona a <strong>${data.studentName}</strong></li>
              <li>Haz clic en la opción <strong>"Restablecer Contraseña"</strong></li>
              <li>Se generará una contraseña temporal que deberás compartir con el estudiante</li>
            </ol>
          </div>
          
          <div style="text-align: center; margin: 30px 0;">
            <a href="https://fct.jualas.es/login" class="button">Acceder a la Plataforma</a>
          </div>
          
          <p style="font-size: 14px; color: #6b7280;">
            💡 <strong>Nota:</strong> La contraseña temporal debe ser cambiada por el estudiante en su primer inicio de sesión.
          </p>
        </div>
        <div class="footer">
          <p>Sistema de Seguimiento de Proyectos TFG</p>
          <p>Este es un mensaje automático, por favor no respondas a este correo.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const text = `
Solicitud de Restablecimiento de Contraseña

Hola ${data.tutorName},

Tu estudiante ${data.studentName} (${data.studentEmail}) ha solicitado restablecer su contraseña.

Como tutor asignado, necesitas generar una nueva contraseña temporal para este estudiante desde la plataforma de gestión.

Pasos a seguir:
1. Accede a la plataforma de gestión TFG
2. Ve a la sección "Mis Estudiantes"
3. Selecciona a ${data.studentName}
4. Haz clic en la opción "Restablecer Contraseña"
5. Se generará una contraseña temporal que deberás compartir con el estudiante

Accede aquí: https://fct.jualas.es/login

Nota: La contraseña temporal debe ser cambiada por el estudiante en su primer inicio de sesión.

---
Sistema de Seguimiento de Proyectos TFG
Este es un mensaje automático, por favor no respondas a este correo.
  `;

  return {
    to: data.tutorEmail,
    subject: `🔐 Solicitud de Restablecimiento de Contraseña - ${data.studentName}`,
    html,
    text
  };
}

function generateStudentWelcomeEmail(data: {
  studentEmail: string;
  studentName: string;
  password: string;
  academicYear?: string;
  studentPhone?: string;
  studentNre?: string;
  studentSpecialty?: string;
  tutorName?: string;
  tutorEmail?: string;
  tutorPhone?: string;
  createdBy: string;
  createdByName: string;
}) {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Bienvenida al Sistema de Seguimiento de Proyectos TFG</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #10b981; color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f8fafc; padding: 30px; border-radius: 0 0 8px 8px; }
        .welcome-box { background: white; padding: 25px; border-radius: 8px; border-left: 4px solid #10b981; margin: 20px 0; }
        .credentials-box { background: #fef3c7; border: 2px solid #f59e0b; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .info-section { background: white; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .info-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #e5e7eb; }
        .info-row:last-child { border-bottom: none; }
        .info-label { font-weight: bold; color: #6b7280; }
        .info-value { color: #111827; }
        .password-display { font-family: monospace; font-size: 18px; font-weight: bold; color: #dc2626; background: white; padding: 10px; border-radius: 4px; text-align: center; margin: 10px 0; }
        .button { display: inline-block; background: #10b981; color: white; padding: 14px 28px; text-decoration: none; border-radius: 6px; margin: 20px 0; font-weight: bold; }
        .footer { text-align: center; color: #6b7280; font-size: 14px; margin-top: 30px; }
        .warning { background: #fef2f2; border-left: 4px solid #ef4444; padding: 15px; border-radius: 4px; margin: 20px 0; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🎓 Bienvenida al Sistema de Seguimiento de Proyectos TFG</h1>
        </div>
        <div class="content">
          <p>Hola <strong>${data.studentName}</strong>,</p>
          
          <div class="welcome-box">
            <p>¡Bienvenido/a al Sistema de Seguimiento de Proyectos TFG!</p>
            <p>Tu cuenta ha sido creada exitosamente por <strong>${data.createdByName}</strong> (${data.createdBy}).</p>
          </div>

          <div class="credentials-box">
            <h2 style="margin-top: 0; color: #92400e;">🔑 Tus Credenciales de Acceso</h2>
            <div class="info-row">
              <span class="info-label">Email:</span>
              <span class="info-value">${data.studentEmail}</span>
            </div>
            <div style="margin: 15px 0;">
              <span class="info-label">Contraseña temporal:</span>
              <div class="password-display">${data.password}</div>
            </div>
          </div>

          <div class="warning">
            <p style="margin: 0;"><strong>⚠️ Importante:</strong> Por seguridad, cambia esta contraseña temporal en tu primer inicio de sesión.</p>
          </div>

          ${data.academicYear ? `
            <div class="info-section">
              <h3 style="margin-top: 0;">📅 Información Académica</h3>
              <div class="info-row">
                <span class="info-label">Año Académico:</span>
                <span class="info-value">${data.academicYear}</span>
              </div>
              ${data.studentNre ? `
                <div class="info-row">
                  <span class="info-label">NRE:</span>
                  <span class="info-value">${data.studentNre}</span>
                </div>
              ` : ''}
              ${data.studentSpecialty ? `
                <div class="info-row">
                  <span class="info-label">Especialidad:</span>
                  <span class="info-value">${data.studentSpecialty}</span>
                </div>
              ` : ''}
              ${data.studentPhone ? `
                <div class="info-row">
                  <span class="info-label">Teléfono:</span>
                  <span class="info-value">${data.studentPhone}</span>
                </div>
              ` : ''}
            </div>
          ` : ''}

          ${data.tutorName ? `
            <div class="info-section">
              <h3 style="margin-top: 0;">👨‍🏫 Tu Tutor Asignado</h3>
              <div class="info-row">
                <span class="info-label">Nombre:</span>
                <span class="info-value">${data.tutorName}</span>
              </div>
              ${data.tutorEmail ? `
                <div class="info-row">
                  <span class="info-label">Email:</span>
                  <span class="info-value">${data.tutorEmail}</span>
                </div>
              ` : ''}
              ${data.tutorPhone ? `
                <div class="info-row">
                  <span class="info-label">Teléfono:</span>
                  <span class="info-value">${data.tutorPhone}</span>
                </div>
              ` : ''}
            </div>
          ` : ''}

          <div style="text-align: center; margin: 30px 0;">
            <a href="https://fct.jualas.es/login" class="button">Acceder al Sistema</a>
          </div>

          <div class="info-section">
            <h3 style="margin-top: 0;">📋 Próximos Pasos</h3>
            <ol style="padding-left: 20px;">
              <li>Inicia sesión con tus credenciales proporcionadas arriba</li>
              <li>Cambia tu contraseña temporal por una contraseña segura</li>
              <li>Completa tu perfil si es necesario</li>
              <li>Comienza a trabajar en tu anteproyecto</li>
            </ol>
          </div>

          <p>Si tienes alguna pregunta o necesitas ayuda, no dudes en contactar a tu tutor o al administrador del sistema.</p>

          <p>¡Te deseamos mucho éxito en tu proyecto!</p>
        </div>
        <div class="footer">
          <p><strong>Sistema de Seguimiento de Proyectos TFG</strong></p>
          <p>Este es un mensaje automático, por favor no respondas a este correo.</p>
          <p>Si no solicitaste esta cuenta, por favor contacta con el administrador.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const text = `
Bienvenida al Sistema de Seguimiento de Proyectos TFG

Hola ${data.studentName},

¡Bienvenido/a al Sistema de Seguimiento de Proyectos TFG!

Tu cuenta ha sido creada exitosamente por ${data.createdByName} (${data.createdBy}).

🔑 TUS CREDENCIALES DE ACCESO:

Email: ${data.studentEmail}
Contraseña temporal: ${data.password}

⚠️ IMPORTANTE: Por seguridad, cambia esta contraseña temporal en tu primer inicio de sesión.

${data.academicYear ? `
📅 INFORMACIÓN ACADÉMICA:

Año Académico: ${data.academicYear}
${data.studentNre ? `NRE: ${data.studentNre}\n` : ''}${data.studentSpecialty ? `Especialidad: ${data.studentSpecialty}\n` : ''}${data.studentPhone ? `Teléfono: ${data.studentPhone}\n` : ''}
` : ''}${data.tutorName ? `
👨‍🏫 TU TUTOR ASIGNADO:

Nombre: ${data.tutorName}
${data.tutorEmail ? `Email: ${data.tutorEmail}\n` : ''}${data.tutorPhone ? `Teléfono: ${data.tutorPhone}\n` : ''}
` : ''}
📋 PRÓXIMOS PASOS:

1. Inicia sesión con tus credenciales proporcionadas arriba
2. Cambia tu contraseña temporal por una contraseña segura
3. Completa tu perfil si es necesario
4. Comienza a trabajar en tu anteproyecto

Accede al sistema: https://fct.jualas.es/login

Si tienes alguna pregunta o necesitas ayuda, no dudes en contactar a tu tutor o al administrador del sistema.

¡Te deseamos mucho éxito en tu proyecto!

---

Sistema de Seguimiento de Proyectos TFG
Este es un mensaje automático, por favor no respondas a este correo.
Si no solicitaste esta cuenta, por favor contacta con el administrador.
  `;

  return {
    to: data.studentEmail,
    subject: 'Bienvenida al Sistema de Seguimiento de Proyectos TFG',
    html,
    text
  };
}

// Note: Deno.serve is available in Supabase Edge Functions runtime
// The TypeScript error here is expected in the IDE but won't occur at runtime
Deno.serve(async (req: Request) => {
  // Manejar CORS - Preflight request (OPTIONS)
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    });
  }

  try {
    console.log('🚀 Edge Function called');
    console.log('📝 Request method:', req.method);
    
    // Leer el body una sola vez con manejo robusto de errores
    let requestBody;
    try {
      requestBody = await req.json();
    } catch (e) {
      const errorMsg = e instanceof Error ? e.message : String(e);
      console.error('❌ Error reading request body:', errorMsg);
      
      // Si el error es "Body already consumed", devolver un error más descriptivo
      if (errorMsg.includes('already consumed') || errorMsg.includes('body used') || errorMsg.includes('Body stream')) {
        return new Response(JSON.stringify({
          success: false,
          error: 'Request body processing error. The request body may have been read multiple times.'
        }), {
          status: 400,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
          }
        });
      }
      throw e;
    }
    
    if (!requestBody || !requestBody.type) {
      throw new Error('Invalid request: missing type field');
    }
    
    const { type, data } = requestBody;
    
    console.log('📝 Request type:', type);
    console.log('📝 Request data keys:', data ? Object.keys(data) : 'no data');

    let emailData;

    switch (type) {
      case 'comment_notification':
        emailData = generateCommentNotificationEmail(data);
        break;

      case 'status_change':
        emailData = generateStatusChangeEmail(data);
        break;

      case 'password_reset_request_to_tutor':
        emailData = generatePasswordResetRequestToTutorEmail(data);
        break;

      case 'message_to_tutor':
        emailData = generateMessageToTutorEmail(data);
        break;

      case 'message_to_student':
        emailData = generateMessageToStudentEmail(data);
        break;

      case 'student_welcome':
        emailData = generateStudentWelcomeEmail(data);
        break;

      default:
        throw new Error(`Unknown email type: ${type}`);
    }

    console.log('📧 Generated email data:', emailData);

    // sendEmail ahora devuelve directamente el resultado parseado
    const emailResult = await sendEmail(emailData);

    console.log('✅ Email sent successfully:', emailResult);

    return new Response(JSON.stringify({
      success: true,
      message: 'Email sent successfully',
      emailId: emailResult.id
    }), {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    });

  } catch (error) {
    console.error('❌ Error sending email:', error);
    
    const errorMessage = error instanceof Error ? error.message : String(error);
    
    return new Response(JSON.stringify({
      success: false,
      error: errorMessage
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    });
  }
});

