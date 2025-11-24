-- =====================================================
-- MIGRACIÓN: Función RPC para resetear contraseñas de usuarios
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- 
-- Razón: Permite a administradores y tutores resetear contraseñas
-- de estudiantes sin necesidad de usar el flujo de "olvidé mi contraseña"
-- de Supabase Auth.
--
-- Fecha: 2025-01-27
-- =====================================================

-- Crear función RPC para resetear contraseña de usuario
-- Esta función actualiza la contraseña en auth.users usando el servicio de Supabase
CREATE OR REPLACE FUNCTION reset_user_password(
  user_email TEXT,
  new_password TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  auth_user_id UUID;
BEGIN
  -- Verificar que el usuario existe en auth.users
  SELECT id INTO auth_user_id
  FROM auth.users
  WHERE email = user_email;

  IF auth_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuario no encontrado en auth.users: %', user_email;
  END IF;

  -- Actualizar la contraseña en auth.users
  -- Nota: Esto requiere permisos de service_role o usar la función de Supabase
  -- En producción, esto debería hacerse mediante la API de administración de Supabase
  -- o mediante una Edge Function con permisos de service_role
  
  -- Actualizar usando la función crypt de pgcrypto para hashear la contraseña
  -- Sin embargo, Supabase Auth usa su propio sistema de hash, así que
  -- necesitamos usar la API de administración de Supabase
  
  -- Por ahora, lanzamos un error indicando que se debe usar la API de administración
  RAISE EXCEPTION 'Esta función requiere usar la API de administración de Supabase. Por favor, implementa una Edge Function con permisos de service_role.';
END;
$$;

-- Comentario en la función
COMMENT ON FUNCTION reset_user_password IS 
  'Resetea la contraseña de un usuario en auth.users. Requiere permisos de service_role. Debe implementarse mediante Edge Function o API de administración de Supabase.';

