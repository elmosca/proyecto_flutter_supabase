-- =====================================================
-- MIGRACIÓN: Actualizar kanban_position a double precision
-- Fecha: 2024-10-04
-- Autor: Equipo FCT Kanban Refactor
-- =====================================================

-- 1. Cambiar tipo de datos de kanban_position
ALTER TABLE public.tasks
  ALTER COLUMN kanban_position
  TYPE double precision
  USING kanban_position::double precision;

-- 2. Re-crear índice compuesto para ordenar columnas del tablero
DROP INDEX IF EXISTS public.idx_tasks_project_status_position;

CREATE INDEX idx_tasks_project_status_position
  ON public.tasks (project_id, status, kanban_position);

-- 3. Normalizar datos existentes a formato n.0
UPDATE public.tasks
  SET kanban_position = floor(COALESCE(kanban_position, 0))::double precision
  WHERE kanban_position IS NULL
     OR kanban_position <> floor(kanban_position);


