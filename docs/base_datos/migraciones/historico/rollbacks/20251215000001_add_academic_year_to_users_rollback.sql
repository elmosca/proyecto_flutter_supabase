-- =====================================================
-- ROLLBACK: Revertir migración add_academic_year_to_users
-- Fecha: 2025-12-15
-- Descripción: Revierte los cambios de la migración que agregó
--              el campo academic_year a la tabla users.
-- =====================================================

-- =====================================================
-- 1. ELIMINAR TRIGGER
-- =====================================================
DROP TRIGGER IF EXISTS assign_academic_year_trigger ON users;

-- =====================================================
-- 2. ELIMINAR FUNCIÓN
-- =====================================================
DROP FUNCTION IF EXISTS assign_academic_year_to_student();

-- =====================================================
-- 3. ELIMINAR ÍNDICE
-- =====================================================
DROP INDEX IF EXISTS idx_users_academic_year;

-- =====================================================
-- 4. ELIMINAR COLUMNA
-- =====================================================
ALTER TABLE users 
DROP COLUMN IF EXISTS academic_year;

-- =====================================================
-- 5. CONFIRMACIÓN
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE 'Rollback completado: campo academic_year eliminado de la tabla users';
END $$;

-- =====================================================
-- FIN DEL ROLLBACK
-- =====================================================
