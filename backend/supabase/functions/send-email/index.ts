import "jsr:@supabase/functions-js/edge-runtime.d.ts";
/// <reference path="./types.d.ts" />

// Declaración de tipos para Deno
declare const Deno: {
  serve: (handler: (req: Request) => Response | Promise<Response>) => void;
  env: {
    get: (key: string) => string | undefined;
  };
};

interface EmailData {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

interface CommentNotificationData {
  studentEmail: string;
  studentName: string;
  tutorName: string;
  anteprojectTitle: string;
  commentContent: string;
  section: string;
  anteprojectUrl: string;
}

interface StatusChangeNotificationData {
  studentEmail: string;
  studentName: string;
  tutorName: string;
  anteprojectTitle: string;
  newStatus: 'approved' | 'rejected';
  tutorComments?: string;
  anteprojectUrl: string;
}

interface TutorNotificationData {
  tutorEmail: string;
  tutorName: string;
  studentName: string;
  anteprojectTitle: string;
  notificationType: string;
  message: string;
  anteprojectUrl: string;
}

// Obtener la API key de Resend
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');

if (!RESEND_API_KEY) {
  console.error('❌ RESEND_API_KEY environment variable is required');
  throw new Error('RESEND_API_KEY environment variable is required');
}

console.log('✅ Resend API Key configured');

async function sendEmail(emailData: EmailData): Promise<Response> {
  // TEMPORAL: Enviar todos los emails a jualas@gmail.com para testing
  // hasta que se verifique un dominio en Resend
  const testEmail = 'jualas@gmail.com';
  const originalRecipient = emailData.to;
  
  // Modificar el asunto para incluir el destinatario original
  const modifiedSubject = `[TEST - Para: ${originalRecipient}] ${emailData.subject}`;
  
  // Modificar el contenido HTML para mostrar el destinatario original
  const modifiedHtml = emailData.html.replace(
    '<div class="content">',
    `<div class="content">
      <div style="background: #fef3c7; border: 1px solid #f59e0b; padding: 10px; border-radius: 6px; margin-bottom: 20px;">
        <strong>🧪 EMAIL DE PRUEBA</strong><br>
        <strong>Destinatario original:</strong> ${originalRecipient}<br>
        <strong>Enviado a:</strong> ${testEmail} (modo de prueba)
      </div>`
  );
  
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: 'Sistema TFG <onboarding@resend.dev>',
      to: [testEmail],
      subject: modifiedSubject,
      html: modifiedHtml,
      text: emailData.text,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to send email: ${error}`);
  }

  return response;
}

function generateCommentNotificationEmail(data: CommentNotificationData): EmailData {
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
    text,
  };
}

function generateStatusChangeEmail(data: StatusChangeNotificationData): EmailData {
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

${isApproved ? 
  '¡Felicidades! Tu anteproyecto ha sido aprobado. Puedes continuar con el desarrollo de tu proyecto.' : 
  'Tu anteproyecto necesita algunas modificaciones. Revisa los comentarios del tutor y realiza los cambios necesarios.'
}

Ver anteproyecto: ${data.anteprojectUrl}

Sistema de Seguimiento de Proyectos TFG
  `;

  return {
    to: data.studentEmail,
    subject: `${statusEmoji} Anteproyecto "${data.anteprojectTitle}" ${statusText}`,
    html,
    text,
  };
}

function generateTutorNotificationEmail(data: TutorNotificationData): EmailData {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Notificación de Anteproyecto</title>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #2563eb; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f8fafc; padding: 30px; border-radius: 0 0 8px 8px; }
        .notification-box { background: white; padding: 20px; border-radius: 8px; border-left: 4px solid #2563eb; margin: 20px 0; }
        .button { display: inline-block; background: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
        .footer { text-align: center; color: #6b7280; font-size: 14px; margin-top: 30px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>📋 Notificación de Anteproyecto</h1>
        </div>
        <div class="content">
          <p>Hola <strong>${data.tutorName}</strong>,</p>
          
          <p>Has recibido una nueva notificación sobre un anteproyecto:</p>
          
          <div class="notification-box">
            <h2>📋 ${data.anteprojectTitle}</h2>
            <p><strong>Estudiante:</strong> ${data.studentName}</p>
            <p><strong>Mensaje:</strong></p>
            <p>${data.message}</p>
          </div>
          
          <p>Puedes revisar el anteproyecto desde la plataforma:</p>
          
          <a href="${data.anteprojectUrl}" class="button">Revisar Anteproyecto</a>
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
Notificación de Anteproyecto

Hola ${data.tutorName},

Has recibido una nueva notificación sobre un anteproyecto:

Proyecto: ${data.anteprojectTitle}
Estudiante: ${data.studentName}

Mensaje:
${data.message}

Puedes revisar el anteproyecto desde: ${data.anteprojectUrl}

Sistema de Seguimiento de Proyectos TFG
  `;

  return {
    to: data.tutorEmail,
    subject: `📋 Notificación: "${data.anteprojectTitle}"`,
    html,
    text,
  };
}

Deno.serve(async (req: Request) => {
  try {
    const { type, data } = await req.json();

    let emailData: EmailData;

    switch (type) {
      case 'comment_notification':
        emailData = generateCommentNotificationEmail(data as CommentNotificationData);
        break;
      case 'status_change':
        emailData = generateStatusChangeEmail(data as StatusChangeNotificationData);
        break;
      case 'tutor_notification':
        emailData = generateTutorNotificationEmail(data as TutorNotificationData);
        break;
      default:
        throw new Error(`Unknown email type: ${type}`);
    }

    const response = await sendEmail(emailData);
    const result = await response.json();

    return new Response(JSON.stringify({
      success: true,
      message: 'Email sent successfully',
      emailId: result.id,
    }), {
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Error sending email:', error);
    
    return new Response(JSON.stringify({
      success: false,
      error: error.message,
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
