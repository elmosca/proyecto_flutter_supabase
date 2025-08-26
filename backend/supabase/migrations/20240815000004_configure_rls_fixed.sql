-- =====================================================
-- MIGRACIÓN: Configuración de Row Level Security (RLS) - CORREGIDA
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
-- 2. FUNCIONES DE UTILIDAD PARA RLS (ESQUEMA PUBLIC)
-- =====================================================

-- Función para obtener el ID del usuario autenticado
CREATE OR REPLACE FUNCTION public.user_id()
RETURNS INT AS $$
BEGIN
    RETURN (current_setting('request.jwt.claims', true)::json->>'user_id')::INT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener el rol del usuario autenticado
CREATE OR REPLACE FUNCTION public.user_role()
RETURNS user_role AS $$
BEGIN
    RETURN (current_setting('request.jwt.claims', true)::json->>'role')::user_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es administrador
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN public.user_role() = 'admin';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es tutor
CREATE OR REPLACE FUNCTION public.is_tutor()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN public.user_role() = 'tutor';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es estudiante
CREATE OR REPLACE FUNCTION public.is_student()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN public.user_role() = 'student';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es tutor de un proyecto
CREATE OR REPLACE FUNCTION public.is_project_tutor(project_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM projects 
        WHERE id = project_id AND tutor_id = public.user_id()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es estudiante de un proyecto
CREATE OR REPLACE FUNCTION public.is_project_student(project_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM project_students 
        WHERE project_students.project_id = project_id AND student_id = public.user_id()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es tutor de un anteproyecto
CREATE OR REPLACE FUNCTION public.is_anteproject_tutor(anteproject_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM anteprojects 
        WHERE id = anteproject_id AND tutor_id = public.user_id()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si el usuario es autor de un anteproyecto
CREATE OR REPLACE FUNCTION public.is_anteproject_author(anteproject_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM anteproject_students 
        WHERE anteproject_id = anteproject_id AND student_id = public.user_id()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. POLÍTICAS RLS PARA CADA TABLA
-- =====================================================

-- Políticas para users
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (id = public.user_id());

CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (id = public.user_id());

CREATE POLICY "Admins can update any user" ON users
    FOR UPDATE USING (public.is_admin());

-- Políticas para dam_objectives (solo lectura para todos)
CREATE POLICY "Anyone can view DAM objectives" ON dam_objectives
    FOR SELECT USING (true);

-- Políticas para anteprojects
CREATE POLICY "Users can view their own anteprojects" ON anteprojects
    FOR SELECT USING (
        public.user_id() = tutor_id OR 
        EXISTS (SELECT 1 FROM anteproject_students WHERE anteproject_id = anteprojects.id AND student_id = public.user_id())
    );

CREATE POLICY "Admins can view all anteprojects" ON anteprojects
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Students can create anteprojects" ON anteprojects
    FOR INSERT WITH CHECK (public.is_student());

CREATE POLICY "Tutors can update their assigned anteprojects" ON anteprojects
    FOR UPDATE USING (tutor_id = public.user_id());

CREATE POLICY "Admins can update any anteproject" ON anteprojects
    FOR UPDATE USING (public.is_admin());

-- Políticas para anteproject_objectives
CREATE POLICY "Users can view objectives of their anteprojects" ON anteproject_objectives
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM anteprojects a 
            WHERE a.id = anteproject_objectives.anteproject_id 
            AND (a.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM anteproject_students WHERE anteproject_id = a.id AND student_id = public.user_id()))
        )
    );

CREATE POLICY "Admins can view all anteproject objectives" ON anteproject_objectives
    FOR SELECT USING (public.is_admin());

-- Políticas para anteproject_students
CREATE POLICY "Users can view students of their anteprojects" ON anteproject_students
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM anteprojects a 
            WHERE a.id = anteproject_students.anteproject_id 
            AND (a.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM anteproject_students WHERE anteproject_id = a.id AND student_id = public.user_id()))
        )
    );

CREATE POLICY "Admins can view all anteproject students" ON anteproject_students
    FOR SELECT USING (public.is_admin());

-- Políticas para projects
CREATE POLICY "Users can view their own projects" ON projects
    FOR SELECT USING (
        tutor_id = public.user_id() OR 
        EXISTS (SELECT 1 FROM project_students WHERE project_id = projects.id AND student_id = public.user_id())
    );

CREATE POLICY "Admins can view all projects" ON projects
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Tutors can update their projects" ON projects
    FOR UPDATE USING (tutor_id = public.user_id());

CREATE POLICY "Admins can update any project" ON projects
    FOR UPDATE USING (public.is_admin());

-- Políticas para project_students
CREATE POLICY "Users can view students of their projects" ON project_students
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM projects p 
            WHERE p.id = project_students.project_id 
            AND (p.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM project_students WHERE project_id = p.id AND student_id = public.user_id()))
        )
    );

CREATE POLICY "Admins can view all project students" ON project_students
    FOR SELECT USING (public.is_admin());

-- Políticas para milestones
CREATE POLICY "Users can view milestones of their projects" ON milestones
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM projects p 
            WHERE p.id = milestones.project_id 
            AND (p.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM project_students WHERE project_id = p.id AND student_id = public.user_id()))
        )
    );

CREATE POLICY "Admins can view all milestones" ON milestones
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Tutors can update milestones of their projects" ON milestones
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM projects p 
            WHERE p.id = milestones.project_id AND p.tutor_id = public.user_id()
        )
    );

CREATE POLICY "Admins can update any milestone" ON milestones
    FOR UPDATE USING (public.is_admin());

-- Políticas para tasks
CREATE POLICY "Users can view tasks of their projects" ON tasks
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM projects p 
            WHERE p.id = tasks.project_id 
            AND (p.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM project_students WHERE project_id = p.id AND student_id = public.user_id()))
        )
    );

CREATE POLICY "Admins can view all tasks" ON tasks
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Tutors can update tasks of their projects" ON tasks
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM projects p 
            WHERE p.id = tasks.project_id AND p.tutor_id = public.user_id()
        )
    );

CREATE POLICY "Students can update their assigned tasks" ON tasks
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM task_assignees ta 
            WHERE ta.task_id = tasks.id AND ta.user_id = public.user_id()
        )
    );

CREATE POLICY "Admins can update any task" ON tasks
    FOR UPDATE USING (public.is_admin());

-- Políticas para task_assignees
CREATE POLICY "Users can view assignments of their projects" ON task_assignees
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM tasks t 
            JOIN projects p ON t.project_id = p.id
            WHERE t.id = task_assignees.task_id 
            AND (p.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM project_students WHERE project_id = p.id AND student_id = public.user_id()))
        )
    );

CREATE POLICY "Admins can view all task assignments" ON task_assignees
    FOR SELECT USING (public.is_admin());

-- Políticas para comments
CREATE POLICY "Users can view comments of their projects" ON comments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM tasks t 
            JOIN projects p ON t.project_id = p.id
            WHERE t.id = comments.task_id 
            AND (p.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM project_students WHERE project_id = p.id AND student_id = public.user_id()))
        )
    );

CREATE POLICY "Admins can view all comments" ON comments
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Users can create comments in their projects" ON comments
    FOR INSERT WITH CHECK (
        author_id = public.user_id() AND
        EXISTS (
            SELECT 1 FROM tasks t 
            JOIN projects p ON t.project_id = p.id
            WHERE t.id = comments.task_id 
            AND (p.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM project_students WHERE project_id = p.id AND student_id = public.user_id()))
        )
    );

-- Políticas para files
CREATE POLICY "Users can view files of their projects" ON files
    FOR SELECT USING (
        (attachable_type = 'task' AND EXISTS (
            SELECT 1 FROM tasks t 
            JOIN projects p ON t.project_id = p.id
            WHERE t.id = files.attachable_id 
            AND (p.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM project_students WHERE project_id = p.id AND student_id = public.user_id()))
        )) OR
        (attachable_type = 'anteproject' AND EXISTS (
            SELECT 1 FROM anteprojects a 
            WHERE a.id = files.attachable_id 
            AND (a.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM anteproject_students WHERE anteproject_id = a.id AND student_id = public.user_id()))
        ))
    );

CREATE POLICY "Admins can view all files" ON files
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Users can upload files to their projects" ON files
    FOR INSERT WITH CHECK (uploaded_by = public.user_id());

-- Políticas para notifications
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (user_id = public.user_id());

CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (user_id = public.user_id());

-- Políticas para activity_log (solo admins pueden ver)
CREATE POLICY "Admins can view activity log" ON activity_log
    FOR SELECT USING (public.is_admin());

-- Políticas para system_settings (solo admins)
CREATE POLICY "Admins can view system settings" ON system_settings
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can update system settings" ON system_settings
    FOR UPDATE USING (public.is_admin());

-- Políticas para pdf_templates (solo admins)
CREATE POLICY "Admins can view PDF templates" ON pdf_templates
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can update PDF templates" ON pdf_templates
    FOR UPDATE USING (public.is_admin());

-- Políticas para anteproject_evaluation_criteria (solo admins)
CREATE POLICY "Admins can view evaluation criteria" ON anteproject_evaluation_criteria
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can update evaluation criteria" ON anteproject_evaluation_criteria
    FOR UPDATE USING (public.is_admin());

-- Políticas para anteproject_evaluations
CREATE POLICY "Users can view evaluations of their anteprojects" ON anteproject_evaluations
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM anteprojects a 
            WHERE a.id = anteproject_evaluations.anteproject_id 
            AND (a.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM anteproject_students WHERE anteproject_id = a.id AND student_id = public.user_id()))
        )
    );

CREATE POLICY "Admins can view all evaluations" ON anteproject_evaluations
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Tutors can create evaluations for their anteprojects" ON anteproject_evaluations
    FOR INSERT WITH CHECK (
        evaluated_by = public.user_id() AND
        EXISTS (
            SELECT 1 FROM anteprojects a 
            WHERE a.id = anteproject_evaluations.anteproject_id AND a.tutor_id = public.user_id()
        )
    );

-- Políticas para file_versions
CREATE POLICY "Users can view versions of their files" ON file_versions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM files f 
            WHERE f.id = file_versions.original_file_id AND f.uploaded_by = public.user_id()
        )
    );

CREATE POLICY "Admins can view all file versions" ON file_versions
    FOR SELECT USING (public.is_admin());

-- =====================================================
-- 4. VERIFICACIÓN Y DOCUMENTACIÓN
-- =====================================================

-- Comentario final
COMMENT ON FUNCTION public.user_id() IS 'Obtiene el ID del usuario autenticado desde JWT claims';
COMMENT ON FUNCTION public.user_role() IS 'Obtiene el rol del usuario autenticado desde JWT claims';
COMMENT ON FUNCTION public.is_admin() IS 'Verifica si el usuario autenticado es administrador';
COMMENT ON FUNCTION public.is_tutor() IS 'Verifica si el usuario autenticado es tutor';
COMMENT ON FUNCTION public.is_student() IS 'Verifica si el usuario autenticado es estudiante';
COMMENT ON FUNCTION public.is_project_tutor(INT) IS 'Verifica si el usuario es tutor de un proyecto específico';
COMMENT ON FUNCTION public.is_project_student(INT) IS 'Verifica si el usuario es estudiante de un proyecto específico';
COMMENT ON FUNCTION public.is_anteproject_tutor(INT) IS 'Verifica si el usuario es tutor de un anteproyecto específico';
COMMENT ON FUNCTION public.is_anteproject_author(INT) IS 'Verifica si el usuario es autor de un anteproyecto específico';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS configurado exitosamente para todas las tablas del sistema TFG';
    RAISE NOTICE 'Funciones de autenticación creadas en esquema public';
    RAISE NOTICE 'Políticas de seguridad aplicadas según roles y permisos';
END $$;
