-- =====================================================
-- MIGRACIÓN: Agregar 'project' al enum attachable_type
-- Fecha: 2025-01-29
-- Descripción: Agrega el valor 'project' al enum attachable_type
--              para permitir archivos adjuntos a proyectos
-- =====================================================

-- Agregar 'project' al enum attachable_type
ALTER TYPE attachable_type ADD VALUE IF NOT EXISTS 'project';

-- Comentario de documentación
COMMENT ON TYPE attachable_type IS 'Tipos de entidades a las que se pueden adjuntar archivos: task, comment, anteproject, project';

