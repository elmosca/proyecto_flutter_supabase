#!/usr/bin/env node

/**
 * Script de prueba para verificar la conexión con Cloudflare API
 */

const https = require('https');

async function testCloudflareAPI() {
  const apiToken = process.env.CLOUDFLARE_API_TOKEN;
  
  if (!apiToken) {
    console.error('❌ Error: CLOUDFLARE_API_TOKEN no está configurado');
    return;
  }

  console.log('🔍 Probando conexión con Cloudflare API...');
  console.log(`📋 Token: ${apiToken.substring(0, 10)}...`);

  return new Promise((resolve, reject) => {
    const options = {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${apiToken}`,
        'Content-Type': 'application/json',
      },
    };

    const req = https.request('https://api.cloudflare.com/client/v4/user/tokens/verify', options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        console.log(`📊 Status Code: ${res.statusCode}`);
        console.log(`📋 Response: ${body}`);
        
        try {
          const response = JSON.parse(body);
          if (response.success) {
            console.log('✅ Token válido!');
            console.log(`👤 Usuario: ${response.result?.email || 'N/A'}`);
            resolve(response);
          } else {
            console.error('❌ Token inválido:', response.errors);
            reject(new Error('Token inválido'));
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

    req.end();
  });
}

async function getZones() {
  const apiToken = process.env.CLOUDFLARE_API_TOKEN;
  
  return new Promise((resolve, reject) => {
    const options = {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${apiToken}`,
        'Content-Type': 'application/json',
      },
    };

    const req = https.request('https://api.cloudflare.com/client/v4/zones', options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        console.log(`📊 Status Code: ${res.statusCode}`);
        
        try {
          const response = JSON.parse(body);
          if (response.success) {
            console.log('✅ Zonas obtenidas exitosamente!');
            console.log(`📋 Encontradas ${response.result.length} zonas:`);
            response.result.forEach(zone => {
              console.log(`  - ${zone.name} (ID: ${zone.id})`);
            });
            
            // Buscar jualas.es específicamente
            const jualasZone = response.result.find(zone => zone.name === 'jualas.es');
            if (jualasZone) {
              console.log(`\n✅ ¡Encontrado jualas.es! ID: ${jualasZone.id}`);
            } else {
              console.log(`\n❌ jualas.es no encontrado en las zonas disponibles`);
              console.log(`💡 Verifica que el dominio esté en tu cuenta de Cloudflare`);
            }
            resolve(response);
          } else {
            console.error('❌ Error obteniendo zonas:', response.errors);
            reject(new Error('Error obteniendo zonas'));
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

    req.end();
  });
}

async function main() {
  try {
    await testCloudflareAPI();
    console.log('\n🔍 Obteniendo zonas...');
    await getZones();
  } catch (error) {
    console.error('\n💥 Error:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}
