import "jsr:@supabase/functions-js/edge-runtime.d.ts";
/// <reference path="./types.d.ts" />

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

// Obtener la API key de Resend
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');

if (!RESEND_API_KEY) {
  console.error('❌ RESEND_API_KEY environment variable is required');
  throw new Error('RESEND_API_KEY environment variable is required');
}

console.log('✅ Resend API Key configured');

async function sendEmail(emailData: EmailData): Promise<Response> {
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: 'Sistema TFG <onboarding@resend.dev>',
      to: [emailData.to],
      subject: emailData.subject,
      html: emailData.html,
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
