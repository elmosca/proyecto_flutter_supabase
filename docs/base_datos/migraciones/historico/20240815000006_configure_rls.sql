-- =====================================================
-- MIGRACIÓN: Configuración de Row Level Security (RLS)
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- =====================================================
-- 1. HABILITAR RLS EN TODAS LAS TABLAS
-- =====================================================

-- Tablas principales
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE dam_objectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteprojects ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteproject_objectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteproject_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_assignees ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE file_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteproject_evaluation_criteria ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteproject_evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE pdf_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. FUNCIONES DE UTILIDAD PARA RLS
-- =====================================================

-- Función para obtener el ID del usuario autenticado
CREATE OR REPLACE FUNCTION auth.user_id()
RETURNS INT AS $$
BEGIN
    RETURN (current_setting('request.jwt.claims', true)::json->>'user_id')::INT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener el rol del usuario autenticado
CREATE OR REPLACE FUNCTION auth.user_role()
RETURNS user_role AS $$
BEGIN
    RETURN (current_setting('request.jwt.claims', true)::json->>'role')::user_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es administrador
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth.user_role() = 'admin';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es tutor
CREATE OR REPLACE FUNCTION auth.is_tutor()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth.user_role() = 'tutor';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es estudiante
CREATE OR REPLACE FUNCTION auth.is_student()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth.user_role() = 'student';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es tutor de un proyecto
CREATE OR REPLACE FUNCTION auth.is_project_tutor(project_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM projects 
        WHERE id = project_id AND tutor_id = auth.user_id()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es estudiante de un proyecto
CREATE OR REPLACE FUNCTION auth.is_project_student(project_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM project_students 
        WHERE project_id = project_id AND student_id = auth.user_id()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es tutor de un anteproyecto
CREATE OR REPLACE FUNCTION auth.is_anteproject_tutor(anteproject_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM anteprojects 
        WHERE id = anteproject_id AND tutor_id = auth.user_id()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es autor de un anteproyecto
CREATE OR REPLACE FUNCTION auth.is_anteproject_author(anteproject_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM anteproject_students 
        WHERE anteproject_id = anteproject_id AND student_id = auth.user_id()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. POLÍTICAS PARA USUARIOS
-- =====================================================

-- Administradores pueden ver todos los usuarios
CREATE POLICY "admin_view_all_users" ON users
    FOR SELECT USING (auth.is_admin());

-- Usuarios pueden ver su propio perfil
CREATE POLICY "users_view_own_profile" ON users
    FOR SELECT USING (id = auth.user_id());

-- Usuarios pueden actualizar su propio perfil
CREATE POLICY "users_update_own_profile" ON users
    FOR UPDATE USING (id = auth.user_id());

-- Administradores pueden insertar, actualizar y eliminar usuarios
CREATE POLICY "admin_manage_users" ON users
    FOR ALL USING (auth.is_admin());

-- =====================================================
-- 4. POLÍTICAS PARA OBJETIVOS DAM
-- =====================================================

-- Todos los usuarios autenticados pueden ver los objetivos
CREATE POLICY "view_dam_objectives" ON dam_objectives
    FOR SELECT USING (true);

-- Solo administradores pueden gestionar objetivos
CREATE POLICY "admin_manage_objectives" ON dam_objectives
    FOR ALL USING (auth.is_admin());

-- =====================================================
-- 5. POLÍTICAS PARA ANTEPROYECTOS
-- =====================================================

-- Administradores pueden ver todos los anteproyectos
CREATE POLICY "admin_view_all_anteprojects" ON anteprojects
    FOR SELECT USING (auth.is_admin());

-- Tutores pueden ver anteproyectos asignados
CREATE POLICY "tutor_view_assigned_anteprojects" ON anteprojects
    FOR SELECT USING (auth.is_tutor() AND tutor_id = auth.user_id());

-- Estudiantes pueden ver sus propios anteproyectos
CREATE POLICY "student_view_own_anteprojects" ON anteprojects
    FOR SELECT USING (
        auth.is_student() AND 
        EXISTS (
            SELECT 1 FROM anteproject_students 
            WHERE anteproject_id = anteprojects.id AND student_id = auth.user_id()
        )
    );

-- Tutores pueden actualizar anteproyectos asignados
CREATE POLICY "tutor_update_assigned_anteprojects" ON anteprojects
    FOR UPDATE USING (auth.is_tutor() AND tutor_id = auth.user_id());

-- Estudiantes pueden crear anteproyectos
CREATE POLICY "student_create_anteprojects" ON anteprojects
    FOR INSERT WITH CHECK (auth.is_student());

-- Estudiantes pueden actualizar sus anteproyectos en borrador
CREATE POLICY "student_update_draft_anteprojects" ON anteprojects
    FOR UPDATE USING (
        auth.is_student() AND 
        status = 'draft' AND
        EXISTS (
            SELECT 1 FROM anteproject_students 
            WHERE anteproject_id = anteprojects.id AND student_id = auth.user_id()
        )
    );

-- =====================================================
-- 6. POLÍTICAS PARA PROYECTOS
-- =====================================================

-- Administradores pueden ver todos los proyectos
CREATE POLICY "admin_view_all_projects" ON projects
    FOR SELECT USING (auth.is_admin());

-- Tutores pueden ver proyectos asignados
CREATE POLICY "tutor_view_assigned_projects" ON projects
    FOR SELECT USING (auth.is_tutor() AND tutor_id = auth.user_id());

-- Estudiantes pueden ver proyectos en los que participan
CREATE POLICY "student_view_participating_projects" ON projects
    FOR SELECT USING (
        auth.is_student() AND 
        EXISTS (
            SELECT 1 FROM project_students 
            WHERE project_id = projects.id AND student_id = auth.user_id()
        )
    );

-- Tutores pueden actualizar proyectos asignados
CREATE POLICY "tutor_update_assigned_projects" ON projects
    FOR UPDATE USING (auth.is_tutor() AND tutor_id = auth.user_id());

-- Estudiantes pueden actualizar URL de GitHub en proyectos donde participan
CREATE POLICY "student_update_github_url" ON projects
    FOR UPDATE USING (
        auth.is_student() AND 
        EXISTS (
            SELECT 1 FROM project_students 
            WHERE project_id = projects.id AND student_id = auth.user_id()
        )
    );

-- =====================================================
-- 7. POLÍTICAS PARA MILESTONES
-- =====================================================

-- Ver milestones según permisos del proyecto
CREATE POLICY "view_milestones_by_project" ON milestones
    FOR SELECT USING (
        auth.is_admin() OR
        auth.is_project_tutor(project_id) OR
        auth.is_project_student(project_id)
    );

-- Tutores pueden gestionar milestones de proyectos asignados
CREATE POLICY "tutor_manage_milestones" ON milestones
    FOR ALL USING (auth.is_project_tutor(project_id));

-- =====================================================
-- 8. POLÍTICAS PARA TAREAS
-- =====================================================

-- Ver tareas según permisos del proyecto
CREATE POLICY "view_tasks_by_project" ON tasks
    FOR SELECT USING (
        auth.is_admin() OR
        auth.is_project_tutor(project_id) OR
        auth.is_project_student(project_id)
    );

-- Tutores pueden gestionar tareas de proyectos asignados
CREATE POLICY "tutor_manage_tasks" ON tasks
    FOR ALL USING (auth.is_project_tutor(project_id));

-- Estudiantes pueden actualizar tareas asignadas
CREATE POLICY "student_update_assigned_tasks" ON tasks
    FOR UPDATE USING (
        auth.is_student() AND
        EXISTS (
            SELECT 1 FROM task_assignees 
            WHERE task_id = tasks.id AND user_id = auth.user_id()
        )
    );

-- =====================================================
-- 9. POLÍTICAS PARA COMENTARIOS
-- =====================================================

-- Ver comentarios según permisos de la tarea
CREATE POLICY "view_comments_by_task" ON comments
    FOR SELECT USING (
        auth.is_admin() OR
        auth.is_project_tutor((SELECT project_id FROM tasks WHERE id = comments.task_id)) OR
        auth.is_project_student((SELECT project_id FROM tasks WHERE id = comments.task_id))
    );

-- Usuarios pueden crear comentarios en tareas donde participan
CREATE POLICY "create_comments_in_participating_tasks" ON comments
    FOR INSERT WITH CHECK (
        auth.is_admin() OR
        auth.is_project_tutor((SELECT project_id FROM tasks WHERE id = comments.task_id)) OR
        auth.is_project_student((SELECT project_id FROM tasks WHERE id = comments.task_id))
    );

-- Usuarios pueden actualizar sus propios comentarios
CREATE POLICY "update_own_comments" ON comments
    FOR UPDATE USING (author_id = auth.user_id());

-- =====================================================
-- 10. POLÍTICAS PARA ARCHIVOS
-- =====================================================

-- Ver archivos según permisos de la entidad asociada
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
        ))
    );

-- Usuarios pueden subir archivos en entidades donde participan
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
        ))
    );

-- Usuarios pueden eliminar sus propios archivos
CREATE POLICY "delete_own_files" ON files
    FOR DELETE USING (uploaded_by = auth.user_id());

-- =====================================================
-- 11. POLÍTICAS PARA NOTIFICACIONES
-- =====================================================

-- Usuarios solo pueden ver sus propias notificaciones
CREATE POLICY "view_own_notifications" ON notifications
    FOR SELECT USING (user_id = auth.user_id());

-- Usuarios pueden marcar sus notificaciones como leídas
CREATE POLICY "update_own_notifications" ON notifications
    FOR UPDATE USING (user_id = auth.user_id());

-- =====================================================
-- 12. POLÍTICAS PARA ACTIVITY_LOG
-- =====================================================

-- Solo administradores pueden ver el log de actividad
CREATE POLICY "admin_view_activity_log" ON activity_log
    FOR SELECT USING (auth.is_admin());

-- =====================================================
-- 13. POLÍTICAS PARA EVALUACIONES
-- =====================================================

-- Ver evaluaciones según permisos del anteproyecto
CREATE POLICY "view_evaluations_by_anteproject" ON anteproject_evaluations
    FOR SELECT USING (
        auth.is_admin() OR
        auth.is_anteproject_tutor(anteproject_id) OR
        auth.is_anteproject_author(anteproject_id)
    );

-- Solo tutores pueden crear evaluaciones
CREATE POLICY "tutor_create_evaluations" ON anteproject_evaluations
    FOR INSERT WITH CHECK (auth.is_anteproject_tutor(anteproject_id));

-- Solo tutores pueden actualizar evaluaciones
CREATE POLICY "tutor_update_evaluations" ON anteproject_evaluations
    FOR UPDATE USING (auth.is_anteproject_tutor(anteproject_id));

-- =====================================================
-- 14. POLÍTICAS PARA SYSTEM_SETTINGS
-- =====================================================

-- Solo administradores pueden gestionar configuraciones del sistema
CREATE POLICY "admin_manage_system_settings" ON system_settings
    FOR ALL USING (auth.is_admin());

-- =====================================================
-- 15. POLÍTICAS PARA PDF_TEMPLATES
-- =====================================================

-- Solo administradores pueden gestionar plantillas PDF
CREATE POLICY "admin_manage_pdf_templates" ON pdf_templates
    FOR ALL USING (auth.is_admin());

-- =====================================================
-- 16. POLÍTICAS PARA TABLAS DE RELACIÓN
-- =====================================================

-- Políticas para anteproject_objectives
CREATE POLICY "view_anteproject_objectives_by_anteproject" ON anteproject_objectives
    FOR SELECT USING (
        auth.is_admin() OR
        auth.is_anteproject_tutor(anteproject_id) OR
        auth.is_anteproject_author(anteproject_id)
    );

-- Políticas para anteproject_students
CREATE POLICY "view_anteproject_students_by_anteproject" ON anteproject_students
    FOR SELECT USING (
        auth.is_admin() OR
        auth.is_anteproject_tutor(anteproject_id) OR
        auth.is_anteproject_author(anteproject_id)
    );

-- Políticas para project_students
CREATE POLICY "view_project_students_by_project" ON project_students
    FOR SELECT USING (
        auth.is_admin() OR
        auth.is_project_tutor(project_id) OR
        auth.is_project_student(project_id)
    );

-- Políticas para task_assignees
CREATE POLICY "view_task_assignees_by_task" ON task_assignees
    FOR SELECT USING (
        auth.is_admin() OR
        auth.is_project_tutor((SELECT project_id FROM tasks WHERE id = task_id)) OR
        auth.is_project_student((SELECT project_id FROM tasks WHERE id = task_id))
    );

-- =====================================================
-- 17. POLÍTICAS PARA FILE_VERSIONS
-- =====================================================

-- Ver versiones de archivos según permisos del archivo original
CREATE POLICY "view_file_versions_by_file" ON file_versions
    FOR SELECT USING (
        auth.is_admin() OR
        EXISTS (
            SELECT 1 FROM files f
            WHERE f.id = file_versions.original_file_id AND (
                (f.attachable_type = 'task' AND (
                    auth.is_project_tutor((SELECT project_id FROM tasks WHERE id = f.attachable_id)) OR
                    auth.is_project_student((SELECT project_id FROM tasks WHERE id = f.attachable_id))
                )) OR
                (f.attachable_type = 'anteproject' AND (
                    auth.is_anteproject_tutor(f.attachable_id) OR
                    auth.is_anteproject_author(f.attachable_id)
                ))
            )
        )
    );

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON FUNCTION auth.user_id() IS 'Obtiene el ID del usuario autenticado desde JWT';
COMMENT ON FUNCTION auth.user_role() IS 'Obtiene el rol del usuario autenticado desde JWT';
COMMENT ON FUNCTION auth.is_admin() IS 'Verifica si el usuario autenticado es administrador';
COMMENT ON FUNCTION auth.is_tutor() IS 'Verifica si el usuario autenticado es tutor';
COMMENT ON FUNCTION auth.is_student() IS 'Verifica si el usuario autenticado es estudiante';
COMMENT ON FUNCTION auth.is_project_tutor(INT) IS 'Verifica si el usuario es tutor de un proyecto específico';
COMMENT ON FUNCTION auth.is_project_student(INT) IS 'Verifica si el usuario es estudiante de un proyecto específico';
COMMENT ON FUNCTION auth.is_anteproject_tutor(INT) IS 'Verifica si el usuario es tutor de un anteproyecto específico';
COMMENT ON FUNCTION auth.is_anteproject_author(INT) IS 'Verifica si el usuario es autor de un anteproyecto específico';
