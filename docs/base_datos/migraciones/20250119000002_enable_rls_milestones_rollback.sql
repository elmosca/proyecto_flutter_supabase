-- =====================================================
-- ROLLBACK: Deshabilitar RLS en tabla milestones
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Revertir habilitación de RLS en tabla milestones
-- Uso: Ejecutar si es necesario revertir la migración

-- =====================================================
-- 1. VERIFICACIÓN PREVIA
-- =====================================================

-- Verificar estado actual de RLS
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'milestones';

-- Verificar políticas existentes
SELECT policyname, cmd as command
FROM pg_policies 
WHERE tablename = 'milestones'
ORDER BY policyname;

-- =====================================================
-- 2. ELIMINAR POLÍTICA TEMPORAL
-- =====================================================

-- Eliminar política temporal de desarrollo
DROP POLICY IF EXISTS "Development access to milestones" ON milestones;

-- =====================================================
-- 3. DESHABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Deshabilitar RLS en la tabla
ALTER TABLE milestones DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4. VERIFICACIÓN POSTERIOR
-- =====================================================

-- Verificar que RLS está deshabilitado
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'milestones';

-- Verificar que no quedan políticas
SELECT COUNT(*) as politicas_restantes
FROM pg_policies 
WHERE tablename = 'milestones';

-- =====================================================
-- 5. DOCUMENTACIÓN
-- =====================================================

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS deshabilitado exitosamente en tabla milestones';
    RAISE NOTICE 'Política temporal eliminada';
    RAISE NOTICE 'Tabla vuelve a estado sin RLS';
END $$;
