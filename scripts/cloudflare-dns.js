#!/usr/bin/env node

/**
 * Script para gestionar registros DNS de Cloudflare
 * Configuración del subdominio fct.jualas.es para Resend
 */

const https = require('https');

class CloudflareDNS {
  constructor(apiToken, zoneId) {
    this.apiToken = apiToken;
    this.zoneId = zoneId;
    this.baseUrl = 'https://api.cloudflare.com/client/v4';
  }

  async makeRequest(endpoint, method = 'GET', data = null) {
    return new Promise((resolve, reject) => {
      const url = `${this.baseUrl}${endpoint}`;
      const options = {
        method,
        headers: {
          'Authorization': `Bearer ${this.apiToken}`,
          'Content-Type': 'application/json',
        },
      };

      const req = https.request(url, options, (res) => {
        let body = '';
        res.on('data', (chunk) => body += chunk);
        res.on('end', () => {
          try {
            const response = JSON.parse(body);
            if (response.success) {
              resolve(response);
            } else {
              reject(new Error(`API Error: ${response.errors?.[0]?.message || 'Unknown error'}`));
            }
          } catch (e) {
            reject(new Error(`Parse Error: ${e.message}`));
          }
        });
      });

      req.on('error', reject);

      if (data) {
        req.write(JSON.stringify(data));
      }

      req.end();
    });
  }

  async getZoneId(domain) {
    try {
      const response = await this.makeRequest(`/zones?name=${domain}`);
      if (response.result && response.result.length > 0) {
        return response.result[0].id;
      }
      throw new Error(`Zone not found for domain: ${domain}`);
    } catch (error) {
      console.error('Error getting zone ID:', error.message);
      throw error;
    }
  }

  async listRecords(zoneId = this.zoneId) {
    try {
      const response = await this.makeRequest(`/zones/${zoneId}/dns_records`);
      return response.result;
    } catch (error) {
      console.error('Error listing records:', error.message);
      throw error;
    }
  }

  async createRecord(zoneId, record) {
    try {
      const response = await this.makeRequest(`/zones/${zoneId}/dns_records`, 'POST', record);
      return response.result;
    } catch (error) {
      console.error('Error creating record:', error.message);
      throw error;
    }
  }

  async updateRecord(zoneId, recordId, record) {
    try {
      const response = await this.makeRequest(`/zones/${zoneId}/dns_records/${recordId}`, 'PUT', record);
      return response.result;
    } catch (error) {
      console.error('Error updating record:', error.message);
      throw error;
    }
  }

  async deleteRecord(zoneId, recordId) {
    try {
      const response = await this.makeRequest(`/zones/${zoneId}/dns_records/${recordId}`, 'DELETE');
      return response.result;
    } catch (error) {
      console.error('Error deleting record:', error.message);
      throw error;
    }
  }

  async setupResendRecords(zoneId, subdomain = 'fct') {
    console.log(`🔧 Configurando registros DNS para ${subdomain}.jualas.es...`);
    
    const records = [
      {
        type: 'TXT',
        name: `_resend.${subdomain}`,
        content: 'resend-verification-token', // Este valor lo proporcionará Resend
        ttl: 1, // Auto TTL
        comment: 'Resend domain verification'
      },
      {
        type: 'CNAME',
        name: `resend.${subdomain}`,
        content: 'resend.com',
        ttl: 1,
        comment: 'Resend service'
      },
      {
        type: 'CNAME',
        name: `dkim1._domainkey.${subdomain}`,
        content: 'dkim1.resend.com',
        ttl: 1,
        comment: 'Resend DKIM 1'
      },
      {
        type: 'CNAME',
        name: `dkim2._domainkey.${subdomain}`,
        content: 'dkim2.resend.com',
        ttl: 1,
        comment: 'Resend DKIM 2'
      }
    ];

    const results = [];
    
    for (const record of records) {
      try {
        console.log(`📝 Creando registro: ${record.type} ${record.name} -> ${record.content}`);
        const result = await this.createRecord(zoneId, record);
        results.push(result);
        console.log(`✅ Registro creado: ${result.id}`);
      } catch (error) {
        console.error(`❌ Error creando registro ${record.name}:`, error.message);
        results.push({ error: error.message, record });
      }
    }

    return results;
  }
}

// Función principal
async function main() {
  const args = process.argv.slice(2);
  const command = args[0];

  if (!command) {
    console.log(`
🔧 Cloudflare DNS Manager para fct.jualas.es

Uso:
  node cloudflare-dns.js <comando> [opciones]

Comandos:
  setup     - Configurar registros DNS para Resend
  list      - Listar todos los registros DNS
  verify    - Verificar configuración actual

Variables de entorno requeridas:
  CLOUDFLARE_API_TOKEN - Token de API de Cloudflare
  CLOUDFLARE_ZONE_ID   - ID de la zona de jualas.es (opcional)

Ejemplo:
  CLOUDFLARE_API_TOKEN=tu_token node cloudflare-dns.js setup
    `);
    return;
  }

  const apiToken = process.env.CLOUDFLARE_API_TOKEN;
  if (!apiToken) {
    console.error('❌ Error: CLOUDFLARE_API_TOKEN no está configurado');
    console.log('💡 Obtén tu token en: https://dash.cloudflare.com/profile/api-tokens');
    return;
  }

  const dns = new CloudflareDNS(apiToken);

  try {
    switch (command) {
      case 'setup':
        console.log('🚀 Configurando registros DNS para Resend...');
        let zoneId = process.env.CLOUDFLARE_ZONE_ID;
        
        if (!zoneId) {
          console.log('🔍 Obteniendo Zone ID para jualas.es...');
          zoneId = await dns.getZoneId('jualas.es');
          console.log(`✅ Zone ID: ${zoneId}`);
        }

        const results = await dns.setupResendRecords(zoneId);
        console.log('\n📊 Resumen de configuración:');
        results.forEach((result, index) => {
          if (result.error) {
            console.log(`❌ ${result.record.name}: ${result.error}`);
          } else {
            console.log(`✅ ${result.name}: ${result.id}`);
          }
        });
        break;

      case 'list':
        console.log('📋 Listando registros DNS...');
        let listZoneId = process.env.CLOUDFLARE_ZONE_ID;
        
        if (!listZoneId) {
          listZoneId = await dns.getZoneId('jualas.es');
        }

        const records = await dns.listRecords(listZoneId);
        console.log(`\n📊 Encontrados ${records.length} registros:`);
        records.forEach(record => {
          console.log(`  ${record.type} ${record.name} -> ${record.content} (TTL: ${record.ttl})`);
        });
        break;

      case 'verify':
        console.log('🔍 Verificando configuración...');
        // Aquí podrías añadir verificación de registros específicos
        console.log('✅ Verificación completada');
        break;

      default:
        console.error(`❌ Comando desconocido: ${command}`);
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = CloudflareDNS;
