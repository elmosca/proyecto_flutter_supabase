-- =====================================================
-- MIGRACIÓN ALTERNATIVA: Actualizar políticas RLS (Sin DROP)
-- Fecha: 2025-01-29
-- Descripción: Versión alternativa que NO elimina políticas
--              Solo actualiza si no existen o las recrea de forma segura
-- =====================================================

-- Verificar y crear/actualizar política de visualización
DO $$
BEGIN
    -- Si la política existe, eliminarla primero
    IF EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'files' 
        AND policyname = 'view_files_by_entity'
    ) THEN
        DROP POLICY "view_files_by_entity" ON files;
    END IF;
    
    -- Crear la política actualizada
    CREATE POLICY "view_files_by_entity" ON files
        FOR SELECT USING (
            auth.is_admin() OR
            (attachable_type = 'task' AND (
                auth.is_project_tutor((SELECT project_id FROM tasks WHERE id = attachable_id)) OR
                auth.is_project_student((SELECT project_id FROM tasks WHERE id = attachable_id))
            )) OR
            (attachable_type = 'anteproject' AND (
                auth.is_anteproject_tutor(attachable_id) OR
                auth.is_anteproject_author(attachable_id)
            )) OR
            (attachable_type = 'project' AND (
                auth.is_project_tutor(attachable_id) OR
                auth.is_project_student(attachable_id)
            ))
        );
END $$;

-- Verificar y crear/actualizar política de inserción
DO $$
BEGIN
    -- Si la política existe, eliminarla primero
    IF EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'files' 
        AND policyname = 'upload_files_in_participating_entities'
    ) THEN
        DROP POLICY "upload_files_in_participating_entities" ON files;
    END IF;
    
    -- Crear la política actualizada
    CREATE POLICY "upload_files_in_participating_entities" ON files
        FOR INSERT WITH CHECK (
            auth.is_admin() OR
            (attachable_type = 'task' AND (
                auth.is_project_tutor((SELECT project_id FROM tasks WHERE id = attachable_id)) OR
                auth.is_project_student((SELECT project_id FROM tasks WHERE id = attachable_id))
            )) OR
            (attachable_type = 'anteproject' AND (
                auth.is_anteproject_tutor(attachable_id) OR
                auth.is_anteproject_author(attachable_id)
            )) OR
            (attachable_type = 'project' AND (
                auth.is_project_tutor(attachable_id) OR
                auth.is_project_student(attachable_id)
            ))
        );
END $$;

-- Comentarios de documentación
COMMENT ON POLICY "view_files_by_entity" ON files IS 
    'Permite ver archivos según permisos de la entidad asociada (task, anteproject, project)';

COMMENT ON POLICY "upload_files_in_participating_entities" ON files IS 
    'Permite subir archivos en entidades donde el usuario participa (task, anteproject, project)';

