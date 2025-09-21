import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'http://127.0.0.1:54321';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

async function createBasicTables() {
  console.log('🚀 Creando tablas básicas en Supabase Local...\n');

  // Crear tabla users básica
  try {
    console.log('📄 Creando tabla users...');
    
    const { data, error } = await supabase.rpc('exec', {
      sql: `
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          full_name VARCHAR(255) NOT NULL,
          email VARCHAR(255) UNIQUE NOT NULL,
          role VARCHAR(50) DEFAULT 'student',
          status VARCHAR(50) DEFAULT 'active',
          created_at TIMESTAMP DEFAULT NOW(),
          updated_at TIMESTAMP DEFAULT NOW()
        );
      `
    });

    if (error) {
      console.error('❌ Error creando tabla users:', error);
    } else {
      console.log('✅ Tabla users creada correctamente');
    }
  } catch (e) {
    console.error('❌ Error creando tabla users:', e.message);
  }

  // Crear tabla projects básica
  try {
    console.log('📄 Creando tabla projects...');
    
    const { data, error } = await supabase.rpc('exec', {
      sql: `
        CREATE TABLE IF NOT EXISTS projects (
          id SERIAL PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          description TEXT,
          student_id INTEGER REFERENCES users(id),
          tutor_id INTEGER REFERENCES users(id),
          status VARCHAR(50) DEFAULT 'draft',
          created_at TIMESTAMP DEFAULT NOW(),
          updated_at TIMESTAMP DEFAULT NOW()
        );
      `
    });

    if (error) {
      console.error('❌ Error creando tabla projects:', error);
    } else {
      console.log('✅ Tabla projects creada correctamente');
    }
  } catch (e) {
    console.error('❌ Error creando tabla projects:', e.message);
  }

  console.log('\n🎉 Proceso completado!');
  console.log('📋 Verificando tablas creadas...');
  
  // Verificar que las tablas se crearon
  try {
    const { data: tables, error } = await supabase
      .from('information_schema.tables')
      .select('table_name')
      .eq('table_schema', 'public');
    
    if (error) {
      console.error('❌ Error verificando tablas:', error);
    } else {
      console.log('📊 Tablas encontradas:');
      tables.forEach(table => {
        console.log(`  - ${table.table_name}`);
      });
    }
  } catch (e) {
    console.error('❌ Error verificando tablas:', e.message);
  }
}

createBasicTables();
