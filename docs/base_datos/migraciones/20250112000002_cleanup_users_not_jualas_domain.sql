-- =====================================================
-- MIGRACIÓN: Limpieza de usuarios fuera del dominio jualas.es
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- 
-- Este script elimina de la tabla users a todos los usuarios
-- que NO pertenezcan al dominio jualas.es o fct.jualas.es
-- 
-- ⚠️ ADVERTENCIA: Este script es DESTRUCTIVO
-- Ejecutar solo después de verificar qué usuarios se eliminarán
-- =====================================================

-- Primero, mostrar qué usuarios se van a eliminar (para verificación)
DO $$
DECLARE
    users_to_delete RECORD;
    delete_count INT := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'USUARIOS QUE SERÁN ELIMINADOS:';
    RAISE NOTICE '========================================';
    
    FOR users_to_delete IN 
        SELECT id, email, full_name, role
        FROM public.users
        WHERE email NOT LIKE '%@jualas.es'
          AND email NOT LIKE '%@fct.jualas.es'
        ORDER BY role, email
    LOOP
        RAISE NOTICE 'ID: %, Email: %, Nombre: %, Rol: %', 
            users_to_delete.id, 
            users_to_delete.email, 
            users_to_delete.full_name, 
            users_to_delete.role;
        delete_count := delete_count + 1;
    END LOOP;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'TOTAL DE USUARIOS A ELIMINAR: %', delete_count;
    RAISE NOTICE '========================================';
    
    IF delete_count = 0 THEN
        RAISE NOTICE '✅ No hay usuarios fuera del dominio jualas.es para eliminar';
    END IF;
END $$;

-- Eliminar usuarios que NO pertenecen a los dominios autorizados
-- Dominios permitidos: @jualas.es y @fct.jualas.es
DELETE FROM public.users
WHERE email NOT LIKE '%@jualas.es'
  AND email NOT LIKE '%@fct.jualas.es';

-- Mostrar resultado
DO $$
DECLARE
    remaining_count INT;
BEGIN
    SELECT COUNT(*) INTO remaining_count FROM public.users;
    RAISE NOTICE '✅ Limpieza completada. Usuarios restantes en la tabla users: %', remaining_count;
END $$;

-- Comentario
COMMENT ON FUNCTION public.handle_auth_user_deleted() IS 
    'Elimina automáticamente el usuario de la tabla users cuando se elimina de auth.users. Garantiza sincronización bidireccional.';

