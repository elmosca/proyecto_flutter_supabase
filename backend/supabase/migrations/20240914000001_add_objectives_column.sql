-- =====================================================
-- MIGRACIÓN: Agregar columna objectives a anteprojects
-- =====================================================

-- Agregar columna objectives a la tabla anteprojects
ALTER TABLE anteprojects ADD COLUMN objectives TEXT;

-- Comentario para documentar la columna
COMMENT ON COLUMN anteprojects.objectives IS 'Objetivos específicos del anteproyecto en formato texto libre';
