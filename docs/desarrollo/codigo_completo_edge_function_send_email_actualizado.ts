// @ts-nocheck - Deno runtime types
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL') || 'Sistema TFG <onboarding@resend.dev>';

console.log('🔍 Debug - RESEND_API_KEY exists:', !!RESEND_API_KEY);
console.log('🔍 Debug - RESEND_API_KEY length:', RESEND_API_KEY ? RESEND_API_KEY.length : 0);
console.log('🔍 Debug - RESEND_API_KEY starts with re_:', RESEND_API_KEY ? RESEND_API_KEY.startsWith('re_') : false);
console.log('🔍 Debug - RESEND_FROM_EMAIL:', RESEND_FROM_EMAIL);

if (!RESEND_API_KEY) {
  console.error('❌ RESEND_API_KEY environment variable is required');
  throw new Error('RESEND_API_KEY environment variable is required');
}
console.log('✅ Resend API Key configured');

async function sendEmail(emailData) {
  console.log('📧 Attempting to send email to:', emailData.to);
  console.log('📧 Subject:', emailData.subject);
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      from: RESEND_FROM_EMAIL,
      to: [
        emailData.to
      ],
      subject: emailData.subject,
      html: emailData.html,
      text: emailData.text
    })
  });
  console.log('📧 Response status:', response.status);
  console.log('📧 Response headers:', Object.fromEntries(response.headers.entries()));
  
  // Leer el texto de la respuesta primero para manejar respuestas vacías o no-JSON
  const responseText = await response.text();
  console.log('📧 Response text:', responseText);
  
  // Verificar si la respuesta está vacía
  if (!responseText || responseText.trim().length === 0) {
    console.error('❌ Email send failed: Empty response from Resend API');
    throw new Error(`Failed to send email: Empty response from Resend API (Status: ${response.status})`);
  }
  
  // Intentar parsear JSON
  let result;
  try {
    result = JSON.parse(responseText);
  } catch (parseError) {
    console.error('❌ Error parsing response:', parseError);
    throw new Error(`Error parsing response from Resend: ${parseError.message}. Response received: ${responseText.substring(0, 200)}`);
  }
  
  if (!response.ok) {
    const errorMessage = result?.error?.message || result?.message || result?.error || `Error HTTP ${response.status}`;
    console.error('❌ Email send failed:', errorMessage);
    
    // Detectar si el error es por dominio no verificado
    if (errorMessage.includes('only send testing emails') || 
        errorMessage.includes('verify a domain') ||
        errorMessage.includes('onboarding@resend.dev')) {
      const detailedError = `Error de configuración de Resend: ${errorMessage}. Para enviar emails a otros destinatarios, necesitas verificar un dominio en resend.com/domains y configurar la variable de entorno RESEND_FROM_EMAIL con una dirección de ese dominio (ej: Sistema TFG <noreply@tudominio.com>).`;
      console.error('❌', detailedError);
      throw new Error(detailedError);
    }
    
    throw new Error(`Failed to send email: ${errorMessage}`);
  }
  
  if (result.error) {
    console.error('❌ Email send failed:', result.error);
    throw new Error(`Failed to send email: ${result.error.message || result.error || 'Unknown error'}`);
  }
  
  console.log('✅ Email sent successfully:', result);
  return result;
}

function generateCommentNotificationEmail(data) {
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

function generateStatusChangeEmail(data) {
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

/**
 * Genera el email de notificación cuando se resetea una contraseña de estudiante
 */
function generatePasswordResetEmail(data) {
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

  return {
    to: studentEmail,
    subject: '🔒 Tu contraseña ha sido restablecida - Sistema TFG',
    html,
    text
  };
}

/**
 * Genera email de bienvenida cuando se crea un nuevo estudiante
 */
function generateStudentWelcomeEmail(data) {
  const {
    studentEmail,
    studentName,
    password,
    academicYear,
    studentPhone,
    studentNre,
    studentSpecialty,
    tutorName,
    tutorEmail,
    tutorPhone,
    createdBy,
    createdByName,
  } = data;

  // Obtener la URL de la aplicación desde variables de entorno o usar un valor por defecto
  const APP_URL = Deno.env.get('APP_URL') || 'https://tu-app.supabase.co';

  // Template HTML del email
  const html = `
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
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <h1>🎓 ¡Bienvenido al Sistema TFG!</h1>
    </div>
    
    <div class="content">
      <div class="greeting">
        Hola <strong>${studentName}</strong>,
      </div>
      
      <div class="message">
        Has sido añadido al <strong>Sistema de Gestión de Proyectos TFG</strong> del CIFP Carlos III.
      </div>
      
      <div class="info-box">
        <strong>📋 Información de tu cuenta:</strong>
        <p><strong>Nombre completo:</strong> ${studentName}</p>
        <p><strong>Email:</strong> ${studentEmail}</p>
        ${studentNre ? `<p><strong>NRE:</strong> ${studentNre}</p>` : ''}
        ${studentPhone ? `<p><strong>Teléfono:</strong> ${studentPhone}</p>` : ''}
        ${academicYear ? `<p><strong>Año académico:</strong> ${academicYear}</p>` : ''}
        ${studentSpecialty ? `<p><strong>Especialidad:</strong> ${studentSpecialty}</p>` : ''}
        <p><strong>Creado por:</strong> ${createdByName} (${createdBy === 'administrador' ? 'Administrador' : 'Tutor'})</p>
      </div>
      
      ${tutorName ? `
      <div class="tutor-info">
        <h3>👨‍🏫 Tu Tutor Asignado</h3>
        <p><strong>Nombre:</strong> ${tutorName}</p>
        ${tutorEmail ? `<p><strong>Email:</strong> <a href="mailto:${tutorEmail}">${tutorEmail}</a></p>` : ''}
        ${tutorPhone ? `<p><strong>Teléfono:</strong> <a href="tel:${tutorPhone}">${tutorPhone}</a></p>` : ''}
        <p style="margin-top: 10px; font-size: 13px; color: #075985;">
          <strong>💬 Puedes contactar a tu tutor directamente por email o teléfono para cualquier consulta sobre tu proyecto TFG.</strong>
        </p>
      </div>
      ` : ''}
      
      <div class="password-container">
        <div class="password-label">Tu Contraseña de Acceso</div>
        <div class="password-value">${password}</div>
      </div>
      
      <div class="warning-box">
        <strong>⚠️ Importante:</strong>
        <ul>
          <li>Guarda esta contraseña en un lugar seguro</li>
          <li>Puedes cambiarla después de iniciar sesión desde tu perfil</li>
          <li>Por seguridad, no compartas esta contraseña con nadie</li>
          <li>Si tienes problemas para acceder, contacta a tu tutor o administrador</li>
        </ul>
      </div>
      
      <div class="button-container">
        <a href="${APP_URL}/login" class="button">Iniciar Sesión</a>
      </div>
      
      <div class="info-box">
        <strong>💡 Próximos pasos:</strong>
        <p>1. Inicia sesión con tu email y la contraseña proporcionada</p>
        <p>2. Completa tu perfil si es necesario</p>
        <p>3. Comienza a trabajar en tu proyecto TFG</p>
        ${tutorName ? `<p>4. Contacta a tu tutor ${tutorName} si tienes alguna pregunta</p>` : ''}
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
🎓 ¡BIENVENIDO AL SISTEMA TFG!

Hola ${studentName},

Has sido añadido al Sistema de Gestión de Proyectos TFG del CIFP Carlos III.

📋 INFORMACIÓN DE TU CUENTA:
Nombre completo: ${studentName}
Email: ${studentEmail}
${studentNre ? `NRE: ${studentNre}\n` : ''}${studentPhone ? `Teléfono: ${studentPhone}\n` : ''}${academicYear ? `Año académico: ${academicYear}\n` : ''}${studentSpecialty ? `Especialidad: ${studentSpecialty}\n` : ''}Creado por: ${createdByName} (${createdBy === 'administrador' ? 'Administrador' : 'Tutor'})

${tutorName ? `
👨‍🏫 TU TUTOR ASIGNADO:
Nombre: ${tutorName}
${tutorEmail ? `Email: ${tutorEmail}\n` : ''}${tutorPhone ? `Teléfono: ${tutorPhone}\n` : ''}
💬 Puedes contactar a tu tutor directamente por email o teléfono para cualquier consulta sobre tu proyecto TFG.

` : ''}

TU CONTRASEÑA DE ACCESO:
${password}

⚠️ IMPORTANTE:
- Guarda esta contraseña en un lugar seguro
- Puedes cambiarla después de iniciar sesión desde tu perfil
- Por seguridad, no compartas esta contraseña con nadie
- Si tienes problemas para acceder, contacta a tu tutor o administrador

💡 PRÓXIMOS PASOS:
1. Inicia sesión con tu email y la contraseña proporcionada
2. Completa tu perfil si es necesario
3. Comienza a trabajar en tu proyecto TFG
${tutorName ? `4. Contacta a tu tutor ${tutorName} si tienes alguna pregunta\n` : ''}

Inicia sesión en: ${APP_URL}/login

---
Sistema de Gestión de Proyectos TFG
CIFP Carlos III

Este es un email automático, por favor no respondas.
Si tienes problemas para acceder, contacta a tu tutor o administrador.
  `;

  return {
    to: studentEmail,
    subject: '🎓 ¡Bienvenido al Sistema TFG - CIFP Carlos III!',
    html,
    text,
  };
}

Deno.serve(async (req) => {
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
    const { type, data } = await req.json();
    console.log('📝 Request type:', type);
    console.log('📝 Request data:', data);
    
    let emailData;
    switch(type) {
      case 'comment_notification':
        emailData = generateCommentNotificationEmail(data);
        break;
      case 'status_change':
        emailData = generateStatusChangeEmail(data);
        break;
      case 'password_reset':
        emailData = generatePasswordResetEmail(data);
        break;
      case 'student_welcome':
        emailData = generateStudentWelcomeEmail(data);
        break;
      default:
        throw new Error(`Unknown email type: ${type}`);
    }
    
    console.log('📧 Generated email data:', emailData);
    const result = await sendEmail(emailData);
    console.log('✅ Email sent successfully:', result);
    
    return new Response(JSON.stringify({
      success: true,
      message: 'Email sent successfully',
      emailId: result.id
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
    return new Response(JSON.stringify({
      success: false,
      error: error.message
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

