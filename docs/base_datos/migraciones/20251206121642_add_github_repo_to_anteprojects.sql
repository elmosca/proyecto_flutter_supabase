-- MIGRACIÓN: Añadir campo para repositorio de GitHub a la tabla de anteproyectos
--

ALTER TABLE public.anteprojects
ADD COLUMN github_repository_url VARCHAR(500) NULL;

COMMENT ON COLUMN public.anteprojects.github_repository_url IS 'URL del repositorio de GitHub asociado al anteproyecto';

