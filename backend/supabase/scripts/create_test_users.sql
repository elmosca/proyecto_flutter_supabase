-- Script para crear usuarios de prueba en Supabase Auth
-- Ejecutar este script en Supabase Studio o via API

-- Crear usuarios de prueba con roles específicos
-- Nota: Estos usuarios se crean directamente en la tabla auth.users
-- Los UUIDs son generados para mantener consistencia

-- 1. Administrador
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '550e8400-e29b-41d4-a716-446655440001',
  'admin@cifpcarlos3.es',
  crypt('password123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"], "role": "admin"}',
  '{"name": "Administrador", "role": "admin"}',
  false,
  '',
  '',
  '',
  ''
);

-- 2. Tutor 1
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '550e8400-e29b-41d4-a716-446655440002',
  'maria.garcia@cifpcarlos3.es',
  crypt('password123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"], "role": "tutor"}',
  '{"name": "María García", "role": "tutor"}',
  false,
  '',
  '',
  '',
  ''
);

-- 3. Tutor 2
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '550e8400-e29b-41d4-a716-446655440003',
  'juan.martinez@cifpcarlos3.es',
  crypt('password123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"], "role": "tutor"}',
  '{"name": "Juan Martínez", "role": "tutor"}',
  false,
  '',
  '',
  '',
  ''
);

-- 4. Estudiante 1
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '550e8400-e29b-41d4-a716-446655440004',
  'carlos.lopez@alumno.cifpcarlos3.es',
  crypt('password123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"], "role": "student"}',
  '{"name": "Carlos López", "role": "student"}',
  false,
  '',
  '',
  '',
  ''
);

-- 5. Estudiante 2
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '550e8400-e29b-41d4-a716-446655440005',
  'ana.rodriguez@alumno.cifpcarlos3.es',
  crypt('password123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"], "role": "student"}',
  '{"name": "Ana Rodríguez", "role": "student"}',
  false,
  '',
  '',
  '',
  ''
);

-- Verificar que los usuarios se crearon correctamente
SELECT 
  id,
  email,
  raw_user_meta_data->>'name' as name,
  raw_user_meta_data->>'role' as role,
  email_confirmed_at,
  created_at
FROM auth.users 
WHERE email IN (
  'admin@cifpcarlos3.es',
  'maria.garcia@cifpcarlos3.es',
  'juan.martinez@cifpcarlos3.es',
  'carlos.lopez@alumno.cifpcarlos3.es',
  'ana.rodriguez@alumno.cifpcarlos3.es'
)
ORDER BY role, name;
