-- =====================================================
-- ROLLBACK: Revertir password_hash a NOT NULL
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- 
-- Esta migración revierte el cambio de hacer password_hash nullable.
-- Solo usar si necesitas volver al sistema anterior.
--
-- Fecha: 2025-01-27
-- =====================================================

-- Primero, actualizar todos los valores NULL a un valor por defecto
UPDATE public.users 
SET password_hash = 'legacy_password_required' 
WHERE password_hash IS NULL;

-- Hacer password_hash NOT NULL nuevamente
ALTER TABLE public.users 
  ALTER COLUMN password_hash SET NOT NULL;

-- Remover el comentario
COMMENT ON COLUMN public.users.password_hash IS NULL;

