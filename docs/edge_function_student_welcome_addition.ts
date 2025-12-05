// Código para agregar a la Edge Function send-email
// Agregar esta función antes del Deno.serve

function generateStudentWelcomeEmail(data) {
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

// ============================================================================
// INSTRUCCIONES PARA AGREGAR A LA EDGE FUNCTION:
// ============================================================================
//
// 1. Copia la función generateStudentWelcomeEmail() completa (arriba)
//    y agrégala en tu Edge Function antes de Deno.serve()
//
// 2. Dentro del switch statement en Deno.serve(), agrega este caso:
//
//    case 'student_welcome':
//      emailData = generateStudentWelcomeEmail(data);
//      break;
//
// ============================================================================

