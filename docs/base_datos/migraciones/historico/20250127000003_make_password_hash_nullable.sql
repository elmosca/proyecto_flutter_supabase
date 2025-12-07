-- =====================================================
-- MIGRACIÓN: Hacer password_hash nullable en users
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- 
-- Razón: Ahora usamos Supabase Auth para gestionar contraseñas.
-- Las contraseñas se almacenan en auth.users, no en la tabla users.
-- Por lo tanto, password_hash en users ya no es necesario.
--
-- Fecha: 2025-01-27
-- =====================================================

-- Hacer password_hash nullable
ALTER TABLE public.users 
  ALTER COLUMN password_hash DROP NOT NULL;

-- Actualizar registros existentes que tengan valores placeholder
-- a NULL si es necesario (solo para usuarios creados con Supabase Auth)
UPDATE public.users 
SET password_hash = NULL 
WHERE password_hash = 'supabase_auth_managed' 
   OR password_hash = 'temp_password_hash';

-- Comentario en la columna para documentar el cambio
COMMENT ON COLUMN public.users.password_hash IS 
  'Hash de contraseña (deprecated). Las contraseñas ahora se gestionan mediante Supabase Auth en auth.users. Este campo puede ser NULL para usuarios creados con Supabase Auth.';

