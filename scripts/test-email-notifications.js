// Script para probar las notificaciones por email
// Ejecutar con: node scripts/test-email-notifications.js

const { createClient } = require('@supabase/supabase-js');

// Configuración - actualiza con tus valores
const SUPABASE_URL = 'https://your-project-ref.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function testCommentNotification() {
  console.log('🧪 Probando notificación de comentario...');
  
  try {
    const response = await supabase.functions.invoke('send-email', {
      body: {
        type: 'comment_notification',
        data: {
          studentEmail: 'test@ejemplo.com', // Cambia por un email real para probar
          studentName: 'Juan Pérez',
          tutorName: 'Dr. García',
          anteprojectTitle: 'Sistema de Gestión Deportiva',
          commentContent: 'Excelente propuesta. Sugiero considerar la integración con más dispositivos wearables.',
          section: 'Descripción',
          anteprojectUrl: 'https://tu-app.com/anteprojects/123',
        },
      },
    });

    if (response.error) {
      console.error('❌ Error:', response.error);
    } else {
      console.log('✅ Notificación de comentario enviada:', response.data);
    }
  } catch (error) {
    console.error('❌ Error en la prueba:', error);
  }
}

async function testStatusChangeNotification() {
  console.log('🧪 Probando notificación de cambio de estado...');
  
  try {
    const response = await supabase.functions.invoke('send-email', {
      body: {
        type: 'status_change',
        data: {
          studentEmail: 'test@ejemplo.com', // Cambia por un email real para probar
          studentName: 'Juan Pérez',
          tutorName: 'Dr. García',
          anteprojectTitle: 'Sistema de Gestión Deportiva',
          newStatus: 'approved',
          tutorComments: 'Proyecto aprobado. Excelente trabajo en la propuesta técnica.',
          anteprojectUrl: 'https://tu-app.com/anteprojects/123',
        },
      },
    });

    if (response.error) {
      console.error('❌ Error:', response.error);
    } else {
      console.log('✅ Notificación de cambio de estado enviada:', response.data);
    }
  } catch (error) {
    console.error('❌ Error en la prueba:', error);
  }
}

async function runTests() {
  console.log('🚀 Iniciando pruebas de notificaciones por email...\n');
  
  await testCommentNotification();
  console.log('');
  await testStatusChangeNotification();
  
  console.log('\n✅ Pruebas completadas');
  console.log('📧 Revisa tu bandeja de entrada (y spam) para ver los emails');
}

// Ejecutar las pruebas
runTests().catch(console.error);
