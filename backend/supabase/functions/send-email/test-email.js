/**
 * Script de prueba para verificar el sistema de envío de emails
 * Ejecutar desde la consola de Supabase o como Edge Function de prueba
 */

// Datos de prueba para los emails configurados
const testEmails = {
  // Email de prueba para comentario de tutor
  commentNotification: {
    type: 'comment_notification',
    data: {
      studentEmail: '3850437@alu.murciaeduca.es',
      studentName: 'Juan Antonio Francés Pérez',
      tutorName: 'Tutor Jualas',
      anteprojectTitle: 'Sistema de Gestión de Anteproyectos TFG',
      commentContent: 'Este es un comentario de prueba para verificar que el sistema de emails funciona correctamente.',
      section: 'Introducción',
      anteprojectUrl: 'https://tu-dominio.com/anteproject/1'
    }
  },

  // Email de prueba para cambio de estado
  statusChange: {
    type: 'status_change',
    data: {
      studentEmail: '3850437@alu.murciaeduca.es',
      studentName: 'Juan Antonio Francés Pérez',
      tutorName: 'Tutor Jualas',
      anteprojectTitle: 'Sistema de Gestión de Anteproyectos TFG',
      newStatus: 'approved',
      tutorComments: 'Excelente trabajo. El anteproyecto cumple con todos los requisitos solicitados.',
      anteprojectUrl: 'https://tu-dominio.com/anteproject/1'
    }
  },

  // Email de prueba para notificación a tutor
  tutorNotification: {
    type: 'tutor_notification',
    data: {
      tutorEmail: 'jualas@jualas.es',
      tutorName: 'Tutor Jualas',
      studentName: 'Juan Antonio Francés Pérez',
      anteprojectTitle: 'Sistema de Gestión de Anteproyectos TFG',
      notificationType: 'submission',
      message: 'El estudiante ha enviado un nuevo anteproyecto para revisión.',
      anteprojectUrl: 'https://tu-dominio.com/anteproject/1'
    }
  }
};

// Función para probar el envío de emails
async function testEmailSending() {
  console.log('🧪 Iniciando pruebas de envío de emails...\n');

  for (const [testName, testData] of Object.entries(testEmails)) {
    try {
      console.log(`📧 Probando: ${testName}`);
      
      // Simular llamada a la Edge Function
      const response = await fetch('https://tu-proyecto.supabase.co/functions/v1/send-email', {
        method: 'POST',
        headers: {
          'Authorization': 'Bearer tu-anon-key',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(testData)
      });

      const result = await response.json();
      
      if (result.success) {
        console.log(`✅ ${testName}: Email enviado exitosamente`);
        console.log(`   ID del email: ${result.emailId}`);
      } else {
        console.log(`❌ ${testName}: Error - ${result.error}`);
      }
      
    } catch (error) {
      console.log(`❌ ${testName}: Error de conexión - ${error.message}`);
    }
    
    console.log(''); // Línea en blanco
  }

  console.log('🏁 Pruebas completadas');
}

// Función para verificar configuración
function checkConfiguration() {
  console.log('🔍 Verificando configuración de emails...\n');
  
  console.log('📋 Emails configurados:');
  console.log('   Admin: admin@jualas.es');
  console.log('   Tutor Principal: jualas@jualas.es');
  console.log('   Tutor Test: jualas@gmail.com');
  console.log('   Estudiante: 3850437@alu.murciaeduca.es');
  
  console.log('\n📧 Tipos de email soportados:');
  console.log('   - comment_notification');
  console.log('   - status_change');
  console.log('   - tutor_notification');
  
  console.log('\n⚙️ Configuración técnica:');
  console.log('   - Proveedor: Resend');
  console.log('   - API Key: Configurada en variables de entorno');
  console.log('   - Dominio: onboarding@resend.dev');
}

// Ejecutar verificación de configuración
checkConfiguration();

// Para ejecutar las pruebas, descomenta la siguiente línea:
// testEmailSending();

console.log('\n💡 Para probar el envío de emails:');
console.log('   1. Descomenta la línea testEmailSending()');
console.log('   2. Actualiza la URL y API key con tus datos reales');
console.log('   3. Ejecuta el script');
