// Script para verificar si un usuario existe en Supabase Auth
// Uso: node check-user-auth.js email@example.com

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL || 'https://zkririyknhlwoxhsoqih.supabase.co';
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseServiceRoleKey) {
  console.error('❌ Error: SUPABASE_SERVICE_ROLE_KEY no está configurada');
  console.error('Configúrala en el archivo .env o como variable de entorno');
  process.exit(1);
}

const email = process.argv[2];

if (!email) {
  console.error('❌ Error: Debes proporcionar un email');
  console.error('Uso: node check-user-auth.js email@example.com');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function checkUser() {
  try {
    console.log(`🔍 Buscando usuario: ${email}`);
    
    // Listar todos los usuarios y buscar por email
    const { data, error } = await supabase.auth.admin.listUsers();
    
    if (error) {
      console.error('❌ Error al listar usuarios:', error);
      return;
    }
    
    const user = data.users.find(u => u.email === email);
    
    if (user) {
      console.log('✅ Usuario ENCONTRADO en Supabase Auth:');
      console.log('  ID:', user.id);
      console.log('  Email:', user.email);
      console.log('  Email confirmado:', user.email_confirmed_at ? 'Sí' : 'No');
      console.log('  Creado:', user.created_at);
      console.log('  Última sesión:', user.last_sign_in_at || 'Nunca');
      console.log('  Metadata:', JSON.stringify(user.user_metadata, null, 2));
    } else {
      console.log('❌ Usuario NO encontrado en Supabase Auth');
      console.log('✅ El usuario ha sido eliminado correctamente');
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

checkUser();

