-- =====================================================
-- MIGRACIÓN: Triggers y Funciones del Sistema TFG
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- =====================================================
-- FUNCIONES DE UTILIDAD
-- =====================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Función para validar URL de GitHub
CREATE OR REPLACE FUNCTION validate_github_url(url TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    IF url IS NULL THEN
        RETURN TRUE;
    END IF;
    
    -- Validar formato básico de URL de GitHub
    RETURN url ~ '^https://github\.com/[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+(/)?$';
END;
$$ LANGUAGE plpgsql;

-- Función para generar notificaciones
CREATE OR REPLACE FUNCTION create_notification(
    p_user_id INT,
    p_type VARCHAR(50),
    p_title VARCHAR(255),
    p_message TEXT,
    p_action_url VARCHAR(500) DEFAULT NULL,
    p_metadata JSON DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    notification_id INT;
BEGIN
    INSERT INTO notifications (user_id, type, title, message, action_url, metadata)
    VALUES (p_user_id, p_type, p_title, p_message, p_action_url, p_metadata)
    RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ LANGUAGE plpgsql;

-- Función para registrar actividad
CREATE OR REPLACE FUNCTION log_activity(
    p_user_id INT,
    p_action VARCHAR(100),
    p_entity_type VARCHAR(50),
    p_entity_id INT,
    p_old_values JSON DEFAULT NULL,
    p_new_values JSON DEFAULT NULL,
    p_ip_address VARCHAR(45) DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    activity_id INT;
BEGIN
    INSERT INTO activity_log (user_id, action, entity_type, entity_id, old_values, new_values, ip_address, user_agent)
    VALUES (p_user_id, p_action, p_entity_type, p_entity_id, p_old_values, p_new_values, p_ip_address, p_user_agent)
    RETURNING id INTO activity_id;
    
    RETURN activity_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGERS PARA ACTUALIZAR updated_at
-- =====================================================

-- Trigger para users
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para anteprojects
CREATE TRIGGER update_anteprojects_updated_at
    BEFORE UPDATE ON anteprojects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para projects
CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para milestones
CREATE TRIGGER update_milestones_updated_at
    BEFORE UPDATE ON milestones
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para tasks
CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para comments
CREATE TRIGGER update_comments_updated_at
    BEFORE UPDATE ON comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para pdf_templates
CREATE TRIGGER update_pdf_templates_updated_at
    BEFORE UPDATE ON pdf_templates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para system_settings
CREATE TRIGGER update_system_settings_updated_at
    BEFORE UPDATE ON system_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- TRIGGERS PARA VALIDACIONES
-- =====================================================

-- Validar URL de GitHub en projects
CREATE OR REPLACE FUNCTION validate_github_url_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT validate_github_url(NEW.github_repository_url) THEN
        RAISE EXCEPTION 'La URL del repositorio GitHub no tiene un formato válido';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_github_url_trigger
    BEFORE INSERT OR UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION validate_github_url_trigger();

-- Validar que solo estudiantes tengan NRE
CREATE OR REPLACE FUNCTION validate_nre_student_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nre IS NOT NULL AND NEW.role != 'student' THEN
        RAISE EXCEPTION 'Solo los estudiantes pueden tener NRE';
    END IF;
    
    IF NEW.role = 'student' AND NEW.nre IS NULL THEN
        RAISE EXCEPTION 'Los estudiantes deben tener un NRE';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_nre_student_trigger
    BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION validate_nre_student_trigger();

-- =====================================================
-- TRIGGERS PARA ACTUALIZAR last_activity_at EN PROYECTOS
-- =====================================================

-- Actualizar last_activity_at cuando hay cambios en tareas
CREATE OR REPLACE FUNCTION update_project_activity_from_tasks()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE projects 
    SET last_activity_at = CURRENT_TIMESTAMP 
    WHERE id = COALESCE(NEW.project_id, OLD.project_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_project_activity_from_tasks
    AFTER INSERT OR UPDATE OR DELETE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_project_activity_from_tasks();

-- Actualizar last_activity_at cuando hay cambios en milestones
CREATE OR REPLACE FUNCTION update_project_activity_from_milestones()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE projects 
    SET last_activity_at = CURRENT_TIMESTAMP 
    WHERE id = COALESCE(NEW.project_id, OLD.project_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_project_activity_from_milestones
    AFTER INSERT OR UPDATE OR DELETE ON milestones
    FOR EACH ROW
    EXECUTE FUNCTION update_project_activity_from_milestones();

-- =====================================================
-- TRIGGERS PARA VERSIONES DE ARCHIVOS
-- =====================================================

-- Incrementar automáticamente version_number en file_versions
CREATE OR REPLACE FUNCTION auto_increment_file_version()
RETURNS TRIGGER AS $$
DECLARE
    max_version INT DEFAULT 0;
BEGIN
    SELECT COALESCE(MAX(version_number), 0) INTO max_version 
    FROM file_versions 
    WHERE original_file_id = NEW.original_file_id;
    
    NEW.version_number = max_version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_increment_file_version
    BEFORE INSERT ON file_versions
    FOR EACH ROW
    EXECUTE FUNCTION auto_increment_file_version();

-- =====================================================
-- TRIGGERS PARA NOTIFICACIONES
-- =====================================================

-- Notificar cuando se añade repositorio GitHub
CREATE OR REPLACE FUNCTION notify_github_repository_added()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.github_repository_url IS NULL AND NEW.github_repository_url IS NOT NULL THEN
        PERFORM create_notification(
            NEW.tutor_id,
            'github_repository_added',
            'Repositorio GitHub añadido',
            'Se ha añadido el repositorio GitHub al proyecto: ' || NEW.title,
            '/projects/' || NEW.id,
            json_build_object('project_id', NEW.id, 'repository_url', NEW.github_repository_url)
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_github_repository_added
    AFTER UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION notify_github_repository_added();

-- Notificar cuando se aprueba un anteproyecto
CREATE OR REPLACE FUNCTION notify_anteproject_approved()
RETURNS TRIGGER AS $$
DECLARE
    project_id INT;
    student_record RECORD;
BEGIN
    -- Solo ejecutar cuando el anteproyecto cambia a 'approved'
    IF OLD.status != 'approved' AND NEW.status = 'approved' THEN
        
        -- Obtener el ID del proyecto asociado
        SELECT id INTO project_id FROM projects WHERE anteproject_id = NEW.id;
        
        -- Notificar a los estudiantes del proyecto
        FOR student_record IN 
            SELECT ps.student_id 
            FROM project_students ps 
            WHERE ps.project_id = project_id
        LOOP
            PERFORM create_notification(
                student_record.student_id,
                'project_approved',
                'Proyecto aprobado',
                'El anteproyecto ha sido aprobado. Puedes comenzar a definir tareas para el proyecto: ' || NEW.title,
                '/projects/' || project_id || '/tasks'
            );
        END LOOP;
        
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_anteproject_approved
    AFTER UPDATE ON anteprojects
    FOR EACH ROW
    EXECUTE FUNCTION notify_anteproject_approved();

-- Notificar cuando se asigna una tarea
CREATE OR REPLACE FUNCTION notify_task_assigned()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM create_notification(
        NEW.user_id,
        'task_assigned',
        'Nueva tarea asignada',
        'Se te ha asignado una nueva tarea',
        '/tasks/' || NEW.task_id,
        json_build_object('task_id', NEW.task_id, 'assigned_by', NEW.assigned_by)
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_task_assigned
    AFTER INSERT ON task_assignees
    FOR EACH ROW
    EXECUTE FUNCTION notify_task_assigned();

-- Notificar cuando se añade un comentario
CREATE OR REPLACE FUNCTION notify_comment_added()
RETURNS TRIGGER AS $$
DECLARE
    task_record RECORD;
    assignee_record RECORD;
BEGIN
    -- Obtener información de la tarea
    SELECT project_id, title INTO task_record FROM tasks WHERE id = NEW.task_id;
    
    -- Notificar a todos los asignados de la tarea (excepto al autor del comentario)
    FOR assignee_record IN 
        SELECT ta.user_id 
        FROM task_assignees ta 
        WHERE ta.task_id = NEW.task_id AND ta.user_id != NEW.author_id
    LOOP
        PERFORM create_notification(
            assignee_record.user_id,
            'comment_added',
            'Nuevo comentario en tarea',
            'Se ha añadido un nuevo comentario en la tarea: ' || task_record.title,
            '/tasks/' || NEW.task_id,
            json_build_object('task_id', NEW.task_id, 'comment_id', NEW.id, 'author_id', NEW.author_id)
        );
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_comment_added
    AFTER INSERT ON comments
    FOR EACH ROW
    EXECUTE FUNCTION notify_comment_added();

-- =====================================================
-- TRIGGERS PARA REGISTRO DE ACTIVIDAD
-- =====================================================

-- Registrar actividad en users
CREATE OR REPLACE FUNCTION log_user_activity()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM log_activity(NEW.id, 'created', 'user', NEW.id, NULL, to_json(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        PERFORM log_activity(NEW.id, 'updated', 'user', NEW.id, to_json(OLD), to_json(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM log_activity(OLD.id, 'deleted', 'user', OLD.id, to_json(OLD), NULL);
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_user_activity
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW
    EXECUTE FUNCTION log_user_activity();

-- Registrar actividad en projects
CREATE OR REPLACE FUNCTION log_project_activity()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM log_activity(NEW.tutor_id, 'created', 'project', NEW.id, NULL, to_json(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        PERFORM log_activity(NEW.tutor_id, 'updated', 'project', NEW.id, to_json(OLD), to_json(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM log_activity(OLD.tutor_id, 'deleted', 'project', OLD.id, to_json(OLD), NULL);
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_project_activity
    AFTER INSERT OR UPDATE OR DELETE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION log_project_activity();

-- Registrar actividad en tasks
CREATE OR REPLACE FUNCTION log_task_activity()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM log_activity(NEW.id, 'created', 'task', NEW.id, NULL, to_json(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        PERFORM log_activity(NEW.id, 'updated', 'task', NEW.id, to_json(OLD), to_json(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM log_activity(OLD.id, 'deleted', 'task', OLD.id, to_json(OLD), NULL);
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_task_activity
    AFTER INSERT OR UPDATE OR DELETE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION log_task_activity();

-- =====================================================
-- FUNCIONES PARA ESTADÍSTICAS Y REPORTES
-- =====================================================

-- Función para obtener estadísticas de un proyecto
CREATE OR REPLACE FUNCTION get_project_stats(p_project_id INT)
RETURNS JSON AS $$
DECLARE
    stats JSON;
BEGIN
    SELECT json_build_object(
        'total_tasks', COUNT(*),
        'completed_tasks', COUNT(*) FILTER (WHERE status = 'completed'),
        'pending_tasks', COUNT(*) FILTER (WHERE status = 'pending'),
        'in_progress_tasks', COUNT(*) FILTER (WHERE status = 'in_progress'),
        'under_review_tasks', COUNT(*) FILTER (WHERE status = 'under_review'),
        'completion_percentage', ROUND(
            (COUNT(*) FILTER (WHERE status = 'completed')::DECIMAL / COUNT(*)) * 100, 2
        ),
        'total_milestones', (SELECT COUNT(*) FROM milestones WHERE project_id = p_project_id),
        'completed_milestones', (SELECT COUNT(*) FROM milestones WHERE project_id = p_project_id AND status = 'completed')
    ) INTO stats
    FROM tasks
    WHERE project_id = p_project_id;
    
    RETURN stats;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener tareas por estado (para Kanban)
CREATE OR REPLACE FUNCTION get_tasks_by_status(p_project_id INT)
RETURNS TABLE (
    status task_status,
    task_count BIGINT,
    tasks JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.status,
        COUNT(*)::BIGINT as task_count,
        json_agg(
            json_build_object(
                'id', t.id,
                'title', t.title,
                'description', t.description,
                'due_date', t.due_date,
                'kanban_position', t.kanban_position,
                'complexity', t.complexity,
                'assignees', (
                    SELECT json_agg(
                        json_build_object(
                            'id', u.id,
                            'full_name', u.full_name,
                            'email', u.email
                        )
                    )
                    FROM task_assignees ta
                    JOIN users u ON ta.user_id = u.id
                    WHERE ta.task_id = t.id
                )
            ) ORDER BY t.kanban_position
        ) as tasks
    FROM tasks t
    WHERE t.project_id = p_project_id
    GROUP BY t.status
    ORDER BY t.status;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIONES PARA GESTIÓN DE ARCHIVOS
-- =====================================================

-- Función para obtener archivos de una entidad
CREATE OR REPLACE FUNCTION get_entity_files(
    p_attachable_type attachable_type,
    p_attachable_id INT
)
RETURNS TABLE (
    id INT,
    filename VARCHAR(255),
    original_filename VARCHAR(255),
    file_size BIGINT,
    mime_type VARCHAR(100),
    uploaded_at TIMESTAMP,
    uploaded_by_name VARCHAR(255),
    latest_version INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.id,
        f.filename,
        f.original_filename,
        f.file_size,
        f.mime_type,
        f.uploaded_at,
        u.full_name as uploaded_by_name,
        COALESCE(fv.max_version, 1) as latest_version
    FROM files f
    JOIN users u ON f.uploaded_by = u.id
    LEFT JOIN (
        SELECT original_file_id, MAX(version_number) as max_version
        FROM file_versions
        GROUP BY original_file_id
    ) fv ON f.id = fv.original_file_id
    WHERE f.attachable_type = p_attachable_type 
    AND f.attachable_id = p_attachable_id
    ORDER BY f.uploaded_at DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON FUNCTION update_updated_at_column() IS 'Función para actualizar automáticamente el campo updated_at';
COMMENT ON FUNCTION validate_github_url(TEXT) IS 'Valida que una URL tenga el formato correcto de GitHub';
COMMENT ON FUNCTION create_notification(INT, VARCHAR, VARCHAR, TEXT, VARCHAR, JSON) IS 'Crea una notificación para un usuario';
COMMENT ON FUNCTION log_activity(INT, VARCHAR, VARCHAR, INT, JSON, JSON, VARCHAR, TEXT) IS 'Registra una actividad en el log de auditoría';
COMMENT ON FUNCTION get_project_stats(INT) IS 'Obtiene estadísticas completas de un proyecto';
COMMENT ON FUNCTION get_tasks_by_status(INT) IS 'Obtiene tareas agrupadas por estado para el tablero Kanban';
COMMENT ON FUNCTION get_entity_files(attachable_type, INT) IS 'Obtiene todos los archivos asociados a una entidad';
