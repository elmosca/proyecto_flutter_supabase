#!/usr/bin/env node

/**
 * Script simple para probar envío de correos con Resend
 */

const https = require('https');

async function sendSimpleEmail() {
  const apiKey = process.env.RESEND_API_KEY;
  const to = '3850437@alu.murciaeduca.es';
  
  if (!apiKey) {
    console.error('❌ Error: RESEND_API_KEY no está configurado');
    return;
  }

  console.log('📧 Enviando correo de prueba...');
  console.log(`📋 Destinatario: ${to}`);
  console.log(`📋 Desde: noreply@fct.jualas.es`);

  const emailData = {
    from: 'noreply@fct.jualas.es',
    to: [to],
    subject: 'Mensaje de prueba - Sistema FCT',
    text: 'Este es un mensaje de prueba desde el sistema FCT. Si recibes este correo, la configuración está funcionando correctamente.',
    html: `
      <h2>🎓 Sistema de Gestión FCT</h2>
      <p>Este es un mensaje de prueba desde el sistema FCT.</p>
      <p><strong>✅ Si recibes este correo, la configuración está funcionando correctamente.</strong></p>
      <p>Características del sistema:</p>
      <ul>
        <li>🌐 Subdominio: fct.jualas.es</li>
        <li>📧 Servicio: Resend</li>
        <li>☁️ DNS: Cloudflare</li>
      </ul>
      <p>Saludos cordiales,<br>Equipo de desarrollo FCT</p>
    `
  };

  const data = JSON.stringify(emailData);
  console.log('📋 Datos JSON:', data);

  return new Promise((resolve, reject) => {
    const options = {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data)
      }
    };

    const req = https.request('https://api.resend.com/emails', options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        console.log(`📊 Status Code: ${res.statusCode}`);
        console.log(`📋 Response: ${body}`);
        
        try {
          const response = JSON.parse(body);
          if (res.statusCode >= 200 && res.statusCode < 300) {
            console.log('✅ ¡Correo enviado exitosamente!');
            console.log(`📋 ID del correo: ${response.id}`);
            resolve(response);
          } else {
            console.error('❌ Error enviando correo:', response.message || 'Unknown error');
            reject(new Error(response.message || 'Unknown error'));
          }
        } catch (e) {
          console.error('❌ Error parseando respuesta:', e.message);
          reject(e);
        }
      });
    });

    req.on('error', (error) => {
      console.error('❌ Error de conexión:', error.message);
      reject(error);
    });

    req.write(data);
    req.end();
  });
}

async function main() {
  try {
    await sendSimpleEmail();
    console.log('\n🎉 ¡Prueba completada exitosamente!');
  } catch (error) {
    console.error('\n💥 La prueba falló:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}
