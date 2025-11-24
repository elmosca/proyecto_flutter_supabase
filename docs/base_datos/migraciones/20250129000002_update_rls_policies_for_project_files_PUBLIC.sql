-- =====================================================
-- MIGRACIÓN: Actualizar políticas RLS para archivos de proyectos (ESQUEMA PUBLIC)
-- Fecha: 2025-01-29
-- Descripción: Actualiza las políticas RLS de la tabla files
--              para incluir soporte para attachable_type = 'project'
--              Usa el esquema PUBLIC (no auth)
-- =====================================================

-- Eliminar políticas existentes que necesitan actualización
DROP POLICY IF EXISTS "view_files_by_entity" ON files;
DROP POLICY IF EXISTS "upload_files_in_participating_entities" ON files;

-- Recrear política de visualización con soporte para 'project'
CREATE POLICY "view_files_by_entity" ON files
    FOR SELECT USING (
        public.is_admin() OR
        (attachable_type = 'task' AND (
            public.is_project_tutor((SELECT project_id FROM tasks WHERE id = attachable_id)) OR
            public.is_project_student((SELECT project_id FROM tasks WHERE id = attachable_id))
        )) OR
        (attachable_type = 'anteproject' AND (
            public.is_anteproject_tutor(attachable_id) OR
            public.is_anteproject_author(attachable_id)
        )) OR
        (attachable_type = 'project' AND (
            public.is_project_tutor(attachable_id) OR
            public.is_project_student(attachable_id)
        ))
    );

-- Recrear política de inserción con soporte para 'project'
CREATE POLICY "upload_files_in_participating_entities" ON files
    FOR INSERT WITH CHECK (
        public.is_admin() OR
        (attachable_type = 'task' AND (
            public.is_project_tutor((SELECT project_id FROM tasks WHERE id = attachable_id)) OR
            public.is_project_student((SELECT project_id FROM tasks WHERE id = attachable_id))
        )) OR
        (attachable_type = 'anteproject' AND (
            public.is_anteproject_tutor(attachable_id) OR
            public.is_anteproject_author(attachable_id)
        )) OR
        (attachable_type = 'project' AND (
            public.is_project_tutor(attachable_id) OR
            public.is_project_student(attachable_id)
        ))
    );

-- Comentario de documentación
COMMENT ON POLICY "view_files_by_entity" ON files IS 
    'Permite ver archivos según permisos de la entidad asociada (task, anteproject, project)';

COMMENT ON POLICY "upload_files_in_participating_entities" ON files IS 
    'Permite subir archivos en entidades donde el usuario participa (task, anteproject, project)';

