#!/usr/bin/env node

/**
 * Script de prueba para enviar correos electrónicos
 * Usa el subdominio fct.jualas.es configurado en Resend
 */

const https = require('https');

class EmailTester {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://api.resend.com';
  }

  async sendEmail(to, subject, text, html = null) {
    return new Promise((resolve, reject) => {
      const emailData = {
        from: 'noreply@fct.jualas.es',
        to: [to],
        subject: subject,
        text: text,
        html: html || text
      };
      
      const data = JSON.stringify(emailData);

      const options = {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
          'Content-Length': data.length
        }
      };

      const req = https.request(`${this.baseUrl}/emails`, options, (res) => {
        let body = '';
        res.on('data', (chunk) => body += chunk);
        res.on('end', () => {
          try {
            const response = JSON.parse(body);
            if (res.statusCode >= 200 && res.statusCode < 300) {
              resolve(response);
            } else {
              reject(new Error(`API Error: ${response.message || 'Unknown error'}`));
            }
          } catch (e) {
            reject(new Error(`Parse Error: ${e.message}`));
          }
        });
      });

      req.on('error', reject);
      req.write(data);
      req.end();
    });
  }

  async testEmailToStudent(studentEmail) {
    const subject = 'Mensaje de prueba - Sistema FCT';
    const text = `
Estimado/a alumno/a,

Este es un mensaje de prueba desde el sistema de gestión de FCT.

Si recibes este correo, significa que la configuración del subdominio fct.jualas.es está funcionando correctamente.

Características del sistema:
- Subdominio verificado: fct.jualas.es
- Servicio de email: Resend
- Gestión DNS: Cloudflare

Si tienes alguna consulta o necesitas asistencia, no dudes en contactarnos.

Saludos cordiales,
Equipo de desarrollo FCT
    `.trim();

    const html = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${subject}</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .content { padding: 20px; }
        .footer { background-color: #e9ecef; padding: 15px; border-radius: 8px; margin-top: 20px; font-size: 0.9em; }
        .highlight { background-color: #d4edda; padding: 10px; border-radius: 4px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>🎓 Sistema de Gestión FCT</h2>
        </div>
        
        <div class="content">
            <p>Estimado/a alumno/a,</p>
            
            <p>Este es un mensaje de prueba desde el sistema de gestión de FCT.</p>
            
            <div class="highlight">
                <strong>✅ Si recibes este correo, significa que la configuración del subdominio fct.jualas.es está funcionando correctamente.</strong>
            </div>
            
            <h3>Características del sistema:</h3>
            <ul>
                <li>🌐 Subdominio verificado: <code>fct.jualas.es</code></li>
                <li>📧 Servicio de email: Resend</li>
                <li>☁️ Gestión DNS: Cloudflare</li>
            </ul>
            
            <p>Si tienes alguna consulta o necesitas asistencia, no dudes en contactarnos.</p>
        </div>
        
        <div class="footer">
            <p><strong>Saludos cordiales,</strong><br>
            Equipo de desarrollo FCT</p>
        </div>
    </div>
</body>
</html>
    `.trim();

    try {
      console.log(`📧 Enviando correo de prueba a: ${studentEmail}`);
      const result = await this.sendEmail(studentEmail, subject, text, html);
      
      console.log('✅ Correo enviado exitosamente!');
      console.log(`📋 ID del correo: ${result.id}`);
      console.log(`📅 Enviado el: ${new Date().toLocaleString()}`);
      
      return result;
    } catch (error) {
      console.error('❌ Error enviando correo:', error.message);
      throw error;
    }
  }
}

// Función principal
async function main() {
  const args = process.argv.slice(2);
  const studentEmail = args[0];

  if (!studentEmail) {
    console.log(`
📧 Test de Envío de Correos - Sistema FCT

Uso:
  node test-email.js <email_destinatario>

Ejemplo:
  node test-email.js 3850437@alu.murciaeduca.es

Variables de entorno requeridas:
  RESEND_API_KEY - Clave de API de Resend

Nota: Asegúrate de que el dominio fct.jualas.es esté verificado en Resend
    `);
    return;
  }

  const apiKey = process.env.RESEND_API_KEY;
  if (!apiKey) {
    console.error('❌ Error: RESEND_API_KEY no está configurado');
    console.log('💡 Obtén tu clave en: https://resend.com/api-keys');
    return;
  }

  const tester = new EmailTester(apiKey);

  try {
    await tester.testEmailToStudent(studentEmail);
    console.log('\n🎉 ¡Prueba completada exitosamente!');
  } catch (error) {
    console.error('\n💥 La prueba falló:', error.message);
    
    if (error.message.includes('403')) {
      console.log('\n💡 Posibles soluciones:');
      console.log('  1. Verifica que el dominio fct.jualas.es esté verificado en Resend');
      console.log('  2. Asegúrate de que los registros DNS estén configurados correctamente');
      console.log('  3. Espera hasta 24 horas para la propagación DNS completa');
    }
    
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = EmailTester;
