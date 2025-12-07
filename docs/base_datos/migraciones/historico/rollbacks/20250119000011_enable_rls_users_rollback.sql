-- =====================================================
-- ROLLBACK: Deshabilitar RLS en tabla users
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Revertir habilitación de RLS en tabla users
-- Uso: Ejecutar si es necesario revertir la migración

-- =====================================================
-- 1. VERIFICACIÓN PREVIA
-- =====================================================

-- Verificar estado actual de RLS
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'users';

-- Verificar políticas existentes
SELECT policyname, cmd as command
FROM pg_policies 
WHERE tablename = 'users'
ORDER BY policyname;

-- Verificar datos existentes
SELECT COUNT(*) as total_registros FROM users;

-- =====================================================
-- 2. ELIMINAR POLÍTICA TEMPORAL
-- =====================================================

-- Eliminar política temporal de desarrollo
DROP POLICY IF EXISTS "Development access to users" ON users;

-- =====================================================
-- 3. DESHABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Deshabilitar RLS en la tabla
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4. VERIFICACIÓN POSTERIOR
-- =====================================================

-- Verificar que RLS está deshabilitado
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'users';

-- Verificar que no quedan políticas
SELECT COUNT(*) as politicas_restantes
FROM pg_policies 
WHERE tablename = 'users';

-- Verificar que los datos siguen accesibles
SELECT COUNT(*) as registros_accesibles FROM users;

-- =====================================================
-- 5. DOCUMENTACIÓN
-- =====================================================

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS deshabilitado exitosamente en tabla users';
    RAISE NOTICE 'Política temporal eliminada';
    RAISE NOTICE 'Tabla vuelve a estado sin RLS';
    RAISE NOTICE 'ATENCIÓN: Verificar que autenticación sigue funcionando';
END $$;
