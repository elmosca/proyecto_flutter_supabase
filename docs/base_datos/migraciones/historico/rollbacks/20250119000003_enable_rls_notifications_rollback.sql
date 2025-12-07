-- =====================================================
-- ROLLBACK: Deshabilitar RLS en tabla notifications
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Revertir habilitación de RLS en tabla notifications
-- Uso: Ejecutar si es necesario revertir la migración

-- =====================================================
-- 1. VERIFICACIÓN PREVIA
-- =====================================================

-- Verificar estado actual de RLS
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'notifications';

-- Verificar políticas existentes
SELECT policyname, cmd as command
FROM pg_policies 
WHERE tablename = 'notifications'
ORDER BY policyname;

-- Verificar datos existentes
SELECT COUNT(*) as total_registros FROM notifications;

-- =====================================================
-- 2. ELIMINAR POLÍTICA TEMPORAL
-- =====================================================

-- Eliminar política temporal de desarrollo
DROP POLICY IF EXISTS "Development access to notifications" ON notifications;

-- =====================================================
-- 3. DESHABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Deshabilitar RLS en la tabla
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4. VERIFICACIÓN POSTERIOR
-- =====================================================

-- Verificar que RLS está deshabilitado
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'notifications';

-- Verificar que no quedan políticas
SELECT COUNT(*) as politicas_restantes
FROM pg_policies 
WHERE tablename = 'notifications';

-- Verificar que los datos siguen accesibles
SELECT COUNT(*) as registros_accesibles FROM notifications;

-- =====================================================
-- 5. DOCUMENTACIÓN
-- =====================================================

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS deshabilitado exitosamente en tabla notifications';
    RAISE NOTICE 'Política temporal eliminada';
    RAISE NOTICE 'Tabla vuelve a estado sin RLS';
END $$;
