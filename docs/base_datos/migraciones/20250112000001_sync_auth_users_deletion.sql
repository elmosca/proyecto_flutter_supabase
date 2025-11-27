-- =====================================================
-- MIGRACIÓN: Sincronización auth.users → users
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- 
-- Esta migración crea un trigger que elimina automáticamente
-- el usuario de la tabla users cuando se elimina de auth.users.
-- 
-- Esto garantiza la sincronización bidireccional y evita
-- inconsistencias cuando se elimina un usuario desde el
-- Dashboard de Supabase.
-- =====================================================

-- Función para eliminar usuario de la tabla users cuando se elimina de auth.users
CREATE OR REPLACE FUNCTION public.handle_auth_user_deleted()
RETURNS TRIGGER AS $$
BEGIN
    -- Eliminar de la tabla users usando el email
    -- Solo si el usuario existe (evitar errores si ya fue eliminado)
    DELETE FROM public.users 
    WHERE email = OLD.email;
    
    -- Log para debugging (opcional, puede comentarse en producción)
    RAISE NOTICE 'Usuario eliminado de auth.users: % - Eliminando de tabla users...', OLD.email;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que se ejecuta cuando se elimina un usuario de auth.users
DROP TRIGGER IF EXISTS on_auth_user_deleted ON auth.users;
CREATE TRIGGER on_auth_user_deleted
    AFTER DELETE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_auth_user_deleted();

-- Comentario en la función
COMMENT ON FUNCTION public.handle_auth_user_deleted() IS 
    'Elimina automáticamente el usuario de la tabla users cuando se elimina de auth.users. Garantiza sincronización bidireccional.';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE '✅ Trigger de sincronización auth.users → users creado exitosamente';
    RAISE NOTICE '✅ Ahora, cuando elimines un usuario de auth.users, también se eliminará de la tabla users';
END $$;

