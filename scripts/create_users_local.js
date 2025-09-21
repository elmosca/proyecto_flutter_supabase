import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'http://127.0.0.1:54321';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

const testUsers = [
  { email: 'carlos.lopez@alumno.cifpcarlos3.es', password: 'password123', role: 'student', full_name: 'Carlos Lopez' },
  { email: 'maria.garcia@cifpcarlos3.es', password: 'password123', role: 'tutor', full_name: 'Maria Garcia' },
  { email: 'admin@cifpcarlos3.es', password: 'password123', role: 'admin', full_name: 'Admin User' },
];

async function createTestUsers() {
  console.log('🚀 Creando usuarios de prueba en Supabase Local...');

  for (const user of testUsers) {
    console.log(`Creando usuario: ${user.email}`);
    try {
      const { data, error } = await supabase.auth.admin.createUser({
        email: user.email,
        password: user.password,
        user_metadata: {
          full_name: user.full_name,
          role: user.role,
        },
        email_confirm: true, // Auto-confirm email for local testing
      });

      if (error) {
        console.error(`❌ Error creando usuario ${user.email}:`, error);
      } else {
        console.log(`✅ Usuario ${user.email} creado con éxito.`);
      }
    } catch (e) {
      console.error(`❌ Error creando usuario ${user.email}:`, e);
    }
  }

  console.log('\n🎉 Proceso completado!\n');
  console.log('📋 Credenciales de prueba:');
  testUsers.forEach(user => {
    console.log(`${user.role === 'student' ? 'Estudiante' : user.role === 'tutor' ? 'Tutor' : 'Admin'}: ${user.email} / ${user.password}`);
  });
}

createTestUsers();
