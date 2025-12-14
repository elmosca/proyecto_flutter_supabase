-- =====================================================
-- SCHEMA COMPLETO: Sistema TFG - Estado Final Consolidado
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- Fuente: 20240815000001_create_initial_schema.sql
-- =====================================================
-- MIGRACIÓN INICIAL: Esquema Base del Sistema TFG
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 1. TABLA: users (Usuarios del sistema)
-- =====================================================
CREATE TYPE user_role AS ENUM ('admin', 'tutor', 'student');
CREATE TYPE user_status AS ENUM ('active', 'inactive');

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    nre VARCHAR(20) UNIQUE NULL, -- Solo para alumnos
    role user_role NOT NULL DEFAULT 'student',
    phone VARCHAR(20) NULL,
    biography TEXT NULL,
    status user_status NOT NULL DEFAULT 'active',
    specialty VARCHAR(100) NULL, -- Especialidad del estudiante (ej: DAM, DAW)
    tutor_id INT NULL, -- FK al tutor asignado (solo para estudiantes)
    academic_year VARCHAR(20) NULL, -- Año académico del estudiante (ej: "2025-2026"). Usado para control de permisos.
    password_hash VARCHAR(255) NULL, -- Deprecated: ahora se gestiona con Supabase Auth
    email_verified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tutor_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Índice para optimizar consultas por año académico
CREATE INDEX idx_users_academic_year ON users(academic_year);

-- =====================================================
-- 2. TABLA: dam_objectives (Objetivos del ciclo DAM)
-- =====================================================
CREATE TABLE dam_objectives (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 3. TABLA: anteprojects (Anteproyectos)
-- =====================================================
CREATE TYPE project_type AS ENUM ('execution', 'research', 'bibliographic', 'management');
CREATE TYPE anteproject_status AS ENUM ('draft', 'submitted', 'under_review', 'approved', 'rejected');

CREATE TABLE anteprojects (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    project_type project_type NOT NULL,
    description TEXT NOT NULL,
    
    -- Campos adicionales para plantilla oficial
    academic_year VARCHAR(20) NOT NULL, -- ej: "2024-2025"
    institution VARCHAR(255) DEFAULT 'CIFP Carlos III de Cartagena',
    modality VARCHAR(100) DEFAULT 'modalidad distancia',
    location VARCHAR(100) DEFAULT 'Cartagena',
    
    expected_results JSON NOT NULL, -- Array de hitos/resultados
    timeline JSON NOT NULL, -- Fechas clave del proyecto
    status anteproject_status NOT NULL DEFAULT 'draft',
    tutor_id INT NOT NULL,
    
    -- Fechas simplificadas
    submitted_at TIMESTAMP NULL,
    reviewed_at TIMESTAMP NULL,
    
    -- Relación bidireccional con proyecto
    project_id INT UNIQUE NULL,
    
    tutor_comments TEXT NULL,
    objectives TEXT NULL, -- Objetivos específicos del anteproyecto en formato texto libre
    github_repository_url VARCHAR(500) NULL, -- URL del repositorio de GitHub asociado al anteproyecto
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tutor_id) REFERENCES users(id) ON DELETE RESTRICT
);

-- =====================================================
-- 4. TABLA: anteproject_objectives (Relación Anteproyecto-Objetivos)
-- =====================================================
CREATE TABLE anteproject_objectives (
    id SERIAL PRIMARY KEY,
    anteproject_id INT NOT NULL,
    objective_id INT NOT NULL,
    is_selected BOOLEAN DEFAULT TRUE,
    custom_description TEXT NULL, -- Para objetivos personalizados
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (anteproject_id) REFERENCES anteprojects(id) ON DELETE CASCADE,
    FOREIGN KEY (objective_id) REFERENCES dam_objectives(id) ON DELETE RESTRICT,
    UNIQUE (anteproject_id, objective_id)
);

-- =====================================================
-- 5. TABLA: anteproject_students (Relación Anteproyecto-Estudiantes)
-- =====================================================
CREATE TABLE anteproject_students (
    id SERIAL PRIMARY KEY,
    anteproject_id INT NOT NULL,
    student_id INT NOT NULL,
    is_lead_author BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (anteproject_id) REFERENCES anteprojects(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (anteproject_id, student_id)
);

-- =====================================================
-- 6. TABLA: projects (Proyectos Finales)
-- =====================================================
CREATE TYPE project_status AS ENUM ('draft', 'planning', 'development', 'review', 'completed');

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    status project_status NOT NULL DEFAULT 'draft',
    start_date DATE NULL,
    estimated_end_date DATE NULL,
    actual_end_date DATE NULL,
    tutor_id INT NOT NULL,
    anteproject_id INT UNIQUE NULL, -- Un anteproyecto genera un solo proyecto
    
    -- Campos adicionales
    github_repository_url VARCHAR(500) NULL, -- URL del repositorio GitHub del proyecto
    github_main_branch VARCHAR(100) DEFAULT 'main', -- Rama principal del repositorio
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tutor_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (anteproject_id) REFERENCES anteprojects(id) ON DELETE SET NULL
);

-- Actualizar la referencia en anteprojects
ALTER TABLE anteprojects 
ADD CONSTRAINT fk_anteproject_project 
FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL;

-- =====================================================
-- 7. TABLA: project_students (Relación Proyecto-Estudiantes)
-- =====================================================
CREATE TABLE project_students (
    id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    student_id INT NOT NULL,
    is_lead BOOLEAN DEFAULT FALSE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (project_id, student_id)
);

-- =====================================================
-- 8. TABLA: milestones (Hitos del Proyecto)
-- =====================================================
CREATE TYPE milestone_status AS ENUM ('pending', 'in_progress', 'completed', 'delayed');
CREATE TYPE milestone_type AS ENUM ('planning', 'execution', 'review', 'final');

CREATE TABLE milestones (
    id SERIAL PRIMARY KEY,
    project_id INT NOT NULL, -- Los milestones solo pertenecen a proyectos
    milestone_number INT NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    planned_date DATE NOT NULL,
    completed_date DATE NULL,
    status milestone_status NOT NULL DEFAULT 'pending',
    
    -- Campos adicionales
    milestone_type milestone_type DEFAULT 'execution',
    expected_deliverables JSON NULL,
    
    review_comments TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    UNIQUE (project_id, milestone_number)
);

-- =====================================================
-- 9. TABLA: tasks (Tareas)
-- =====================================================
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'under_review', 'completed');
CREATE TYPE task_complexity AS ENUM ('simple', 'medium', 'complex');

CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    milestone_id INT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    status task_status NOT NULL DEFAULT 'pending',
    due_date DATE NULL,
    completed_at TIMESTAMP NULL,
    kanban_position DOUBLE PRECISION DEFAULT 0,
    
    -- Campos adicionales
    estimated_hours INT NULL,
    actual_hours INT NULL,
    complexity task_complexity DEFAULT 'medium',
    tags JSON NULL, -- Para etiquetas personalizadas
    
    -- Campos para generación automática
    is_auto_generated BOOLEAN DEFAULT FALSE, -- Indica si la tarea se generó automáticamente
    generation_source VARCHAR(50) NULL, -- 'mcp_server', 'student_defined', 'template'
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (milestone_id) REFERENCES milestones(id) ON DELETE SET NULL
);

-- =====================================================
-- 10. TABLA: task_assignees (Relación Tarea-Usuarios)
-- =====================================================
CREATE TABLE task_assignees (
    id SERIAL PRIMARY KEY,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INT NOT NULL,
    
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE RESTRICT,
    UNIQUE (task_id, user_id)
);

-- =====================================================
-- 11. TABLA: comments (Comentarios)
-- =====================================================
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    task_id INT NOT NULL,
    author_id INT NOT NULL,
    content TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT FALSE, -- Para comentarios privados del tutor
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- 12. TABLA: files (Archivos)
-- =====================================================
CREATE TYPE attachable_type AS ENUM ('task', 'comment', 'anteproject', 'project');

CREATE TABLE files (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    uploaded_by INT NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Relación polimórfica única
    attachable_type attachable_type NOT NULL,
    attachable_id INT NOT NULL,
    
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- =====================================================
-- 13. TABLA: file_versions (Versiones de Archivos)
-- =====================================================
CREATE TABLE file_versions (
    id SERIAL PRIMARY KEY,
    original_file_id INT NOT NULL,
    version_number INT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    uploaded_by INT NOT NULL,
    upload_reason VARCHAR(255) NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (original_file_id) REFERENCES files(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE RESTRICT,
    UNIQUE (original_file_id, version_number)
);

-- =====================================================
-- 14. TABLA: notifications (Notificaciones)
-- =====================================================
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    type VARCHAR(50) NOT NULL, -- task_assigned, comment_added, status_changed, etc.
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500) NULL,
    metadata JSON NULL, -- Datos adicionales específicos del tipo
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- 15. TABLA: activity_log (Registro de Actividad)
-- =====================================================
CREATE TABLE activity_log (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    action VARCHAR(100) NOT NULL, -- created, updated, deleted, etc.
    entity_type VARCHAR(50) NOT NULL, -- project, task, comment, etc.
    entity_id INT NOT NULL,
    old_values JSON NULL,
    new_values JSON NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- 16. TABLA: anteproject_evaluation_criteria (Criterios de Evaluación)
-- =====================================================
CREATE TABLE anteproject_evaluation_criteria (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    max_score DECIMAL(3,1) DEFAULT 10.0,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 17. TABLA: anteproject_evaluations (Evaluaciones de Anteproyectos)
-- =====================================================
CREATE TABLE anteproject_evaluations (
    id SERIAL PRIMARY KEY,
    anteproject_id INT NOT NULL,
    criteria_id INT NOT NULL,
    score DECIMAL(3,1) NULL,
    comments TEXT NULL,
    evaluated_by INT NOT NULL,
    evaluated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (anteproject_id) REFERENCES anteprojects(id) ON DELETE CASCADE,
    FOREIGN KEY (criteria_id) REFERENCES anteproject_evaluation_criteria(id) ON DELETE RESTRICT,
    FOREIGN KEY (evaluated_by) REFERENCES users(id) ON DELETE RESTRICT,
    UNIQUE (anteproject_id, criteria_id)
);

-- =====================================================
-- 18. TABLA: pdf_templates (Plantillas PDF)
-- =====================================================
CREATE TYPE template_type AS ENUM ('anteproject', 'project_report', 'task_summary');

CREATE TABLE pdf_templates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    template_type template_type NOT NULL,
    template_content TEXT NOT NULL, -- HTML/CSS template
    is_active BOOLEAN DEFAULT TRUE,
    version VARCHAR(10) DEFAULT '1.0',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 19. TABLA: system_settings (Configuración del Sistema)
-- =====================================================
CREATE TYPE setting_type AS ENUM ('string', 'integer', 'boolean', 'json');

CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    setting_type setting_type DEFAULT 'string',
    description TEXT NULL,
    is_editable BOOLEAN DEFAULT TRUE,
    updated_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);

-- =====================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- Índices para búsquedas de anteproyectos
CREATE INDEX idx_anteprojects_status_tutor ON anteprojects(status, tutor_id);
CREATE INDEX idx_anteprojects_academic_year ON anteprojects(academic_year);

-- Índices para optimizar el Kanban
CREATE INDEX idx_tasks_kanban ON tasks(project_id, status, kanban_position);

-- Índices para notificaciones por tipo
CREATE INDEX idx_notifications_type_user ON notifications(type, user_id, read_at);

-- Índices para objetivos y evaluaciones
CREATE INDEX idx_anteproject_objectives_anteproject ON anteproject_objectives(anteproject_id);
CREATE INDEX idx_evaluations_anteproject ON anteproject_evaluations(anteproject_id);

-- Índices para configuración del sistema
CREATE INDEX idx_system_settings_key ON system_settings(setting_key);

-- Índices para versiones de archivos
CREATE INDEX idx_file_versions_original ON file_versions(original_file_id, version_number);

-- Índices para archivos polimórficos
CREATE INDEX idx_files_attachable ON files(attachable_type, attachable_id);

-- Índices para actividad
CREATE INDEX idx_activity_log_entity ON activity_log(entity_type, entity_id);
CREATE INDEX idx_activity_log_user ON activity_log(user_id, created_at);

-- Índices para usuarios
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_nre ON users(nre);
CREATE INDEX idx_users_role ON users(role, status);

-- Índices para proyectos
CREATE INDEX idx_projects_tutor ON projects(tutor_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_anteproject ON projects(anteproject_id);

-- Índices para milestones
CREATE INDEX idx_milestones_project ON milestones(project_id);
CREATE INDEX idx_milestones_status ON milestones(status);

-- Índices para tareas
CREATE INDEX idx_tasks_project ON tasks(project_id);
CREATE INDEX idx_tasks_milestone ON tasks(milestone_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);

-- Índices para comentarios
CREATE INDEX idx_comments_task ON comments(task_id);
CREATE INDEX idx_comments_author ON comments(author_id);

-- Índices para notificaciones
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, read_at);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE users IS 'Usuarios del sistema con roles: admin, tutor, student';
COMMENT ON TABLE dam_objectives IS 'Objetivos del ciclo DAM que se pueden seleccionar en anteproyectos';
COMMENT ON TABLE anteprojects IS 'Anteproyectos que deben ser aprobados antes de crear proyectos';
COMMENT ON TABLE projects IS 'Proyectos finales activos tras aprobación del anteproyecto';
COMMENT ON TABLE milestones IS 'Hitos clave del proyecto durante su ejecución';
COMMENT ON TABLE tasks IS 'Tareas granular del proyecto, pueden generarse automáticamente o manualmente';
COMMENT ON TABLE files IS 'Archivos asociados a tareas, comentarios o anteproyectos';
COMMENT ON TABLE notifications IS 'Sistema de notificaciones para avisos automáticos';
COMMENT ON TABLE activity_log IS 'Registro de auditoría de todas las acciones importantes';
COMMENT ON TABLE system_settings IS 'Configuración global del sistema editable por administradores';


-- Fuente: 20240815000002_create_triggers_and_functions.sql
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

-- =====================================================
-- FUNCIÓN Y TRIGGER PARA ASIGNAR AÑO ACADÉMICO AUTOMÁTICAMENTE
-- =====================================================

-- Función que asigna el año académico vigente a nuevos estudiantes
CREATE OR REPLACE FUNCTION assign_academic_year_to_student()
RETURNS TRIGGER AS $$
DECLARE
    active_academic_year TEXT;
BEGIN
    -- Solo procesar si es un estudiante y no tiene año académico asignado
    IF NEW.role = 'student' AND (NEW.academic_year IS NULL OR NEW.academic_year = '') THEN
        -- Obtener el año académico activo del sistema
        SELECT setting_value INTO active_academic_year
        FROM system_settings
        WHERE setting_key = 'academic_year'
        LIMIT 1;
        
        -- Si hay año activo, asignarlo al estudiante
        IF active_academic_year IS NOT NULL AND active_academic_year != '' THEN
            NEW.academic_year := active_academic_year;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que se ejecuta antes de insertar un nuevo usuario
CREATE TRIGGER assign_academic_year_trigger
    BEFORE INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION assign_academic_year_to_student();

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


-- Fuente: 20240914000001_add_objectives_column.sql
-- =====================================================
-- MIGRACIÓN: Agregar columna objectives a anteprojects
-- =====================================================

-- Agregar columna objectives a la tabla anteprojects
ALTER TABLE anteprojects ADD COLUMN objectives TEXT;

-- Comentario para documentar la columna
COMMENT ON COLUMN anteprojects.objectives IS 'Objetivos específicos del anteproyecto en formato texto libre';


-- Fuente: 20241004T120000_update_tasks_kanban_position.sql
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




-- Fuente: 20241215000001_create_schedule_tables.sql
-- Crear tabla de cronogramas
CREATE TABLE IF NOT EXISTS schedules (
  id SERIAL PRIMARY KEY,
  anteproject_id INTEGER NOT NULL REFERENCES anteprojects(id) ON DELETE CASCADE,
  tutor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  final_date TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Asegurar que un anteproyecto solo tenga un cronograma
  UNIQUE(anteproject_id)
);

-- Crear tabla de fechas de revisión
CREATE TABLE IF NOT EXISTS review_dates (
  id SERIAL PRIMARY KEY,
  schedule_id INTEGER NOT NULL REFERENCES schedules(id) ON DELETE CASCADE,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  description TEXT NOT NULL,
  milestone_reference TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_schedules_anteproject_id ON schedules(anteproject_id);
CREATE INDEX IF NOT EXISTS idx_schedules_tutor_id ON schedules(tutor_id);
CREATE INDEX IF NOT EXISTS idx_review_dates_schedule_id ON review_dates(schedule_id);
CREATE INDEX IF NOT EXISTS idx_review_dates_date ON review_dates(date);

-- Crear función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Crear triggers para actualizar updated_at
CREATE TRIGGER update_schedules_updated_at 
  BEFORE UPDATE ON schedules 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_review_dates_updated_at 
  BEFORE UPDATE ON review_dates 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE schedules IS 'Cronogramas de revisión para anteproyectos aprobados';
COMMENT ON TABLE review_dates IS 'Fechas específicas de revisión dentro de un cronograma';

COMMENT ON COLUMN schedules.anteproject_id IS 'ID del anteproyecto al que pertenece el cronograma';
COMMENT ON COLUMN schedules.tutor_id IS 'ID del tutor responsable del cronograma';
COMMENT ON COLUMN schedules.start_date IS 'Fecha de inicio del cronograma';
COMMENT ON COLUMN schedules.final_date IS 'Fecha final del cronograma';

COMMENT ON COLUMN review_dates.schedule_id IS 'ID del cronograma al que pertenece esta fecha';
COMMENT ON COLUMN review_dates.date IS 'Fecha específica de revisión';
COMMENT ON COLUMN review_dates.description IS 'Descripción de lo que se revisará en esta fecha';
COMMENT ON COLUMN review_dates.milestone_reference IS 'Referencia al hito del anteproyecto relacionado';


-- Fuente: 20250127000001_create_profiles_table.sql
-- =====================================================
-- MIGRACIÓN: Crear tabla profiles para compatibilidad
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- =====================================================
-- 1. CREAR TABLA PROFILES
-- =====================================================

-- Crear tabla profiles que es referenciada por algún código
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'student',
    status TEXT DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. HABILITAR RLS EN PROFILES
-- =====================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. CREAR POLÍTICAS RLS PARA PROFILES
-- =====================================================

-- Política para que los usuarios puedan ver su propio perfil
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

-- Política para que los usuarios puedan actualizar su propio perfil
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Política para que los administradores puedan ver todos los perfiles
CREATE POLICY "Admins can view all profiles" ON public.profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.email = auth.jwt() ->> 'email' 
            AND users.role = 'admin'
        )
    );

-- =====================================================
-- 4. CREAR TRIGGER PARA ACTUALIZAR updated_at
-- =====================================================

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 5. CREAR TRIGGER PARA SINCRONIZAR CON USERS
-- =====================================================

-- Función para sincronizar profiles con users
CREATE OR REPLACE FUNCTION public.sync_profile_with_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertar o actualizar en la tabla users cuando se modifica profiles
    INSERT INTO users (id, email, full_name, role, status, created_at, updated_at)
    VALUES (NEW.id, NEW.email, NEW.full_name, NEW.role::user_role, NEW.status::user_status, NEW.created_at, NEW.updated_at)
    ON CONFLICT (email) 
    DO UPDATE SET
        full_name = EXCLUDED.full_name,
        role = EXCLUDED.role::user_role,
        status = EXCLUDED.status::user_status,
        updated_at = EXCLUDED.updated_at;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para sincronizar profiles con users
CREATE TRIGGER sync_profile_with_user_trigger
    AFTER INSERT OR UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.sync_profile_with_user();

-- =====================================================
-- 6. MIGRAR DATOS EXISTENTES DE USERS A PROFILES
-- =====================================================

-- Insertar datos existentes de users en profiles
INSERT INTO public.profiles (id, email, full_name, role, status, created_at, updated_at)
SELECT 
    gen_random_uuid() as id, -- Generar UUID para cada usuario
    email,
    full_name,
    role::text,
    status::text,
    created_at,
    updated_at
FROM users
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- 7. COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE public.profiles IS 'Tabla de perfiles de usuario para compatibilidad con Supabase Auth';
COMMENT ON FUNCTION public.sync_profile_with_user() IS 'Sincroniza datos entre profiles y users';

-- =====================================================
-- 8. MENSAJE DE CONFIRMACIÓN
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Tabla profiles creada exitosamente';
    RAISE NOTICE 'Políticas RLS aplicadas';
    RAISE NOTICE 'Triggers de sincronización creados';
    RAISE NOTICE 'Datos migrados desde users';
END $$;


-- Fuente: 20250127000003_make_password_hash_nullable.sql
-- =====================================================
-- MIGRACIÓN: Hacer password_hash nullable en users
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- 
-- Razón: Ahora usamos Supabase Auth para gestionar contraseñas.
-- Las contraseñas se almacenan en auth.users, no en la tabla users.
-- Por lo tanto, password_hash en users ya no es necesario.
--
-- Fecha: 2025-01-27
-- =====================================================

-- Hacer password_hash nullable
ALTER TABLE public.users 
  ALTER COLUMN password_hash DROP NOT NULL;

-- Actualizar registros existentes que tengan valores placeholder
-- a NULL si es necesario (solo para usuarios creados con Supabase Auth)
UPDATE public.users 
SET password_hash = NULL 
WHERE password_hash = 'supabase_auth_managed' 
   OR password_hash = 'temp_password_hash';

-- Comentario en la columna para documentar el cambio
COMMENT ON COLUMN public.users.password_hash IS 
  'Hash de contraseña (deprecated). Las contraseñas ahora se gestionan mediante Supabase Auth en auth.users. Este campo puede ser NULL para usuarios creados con Supabase Auth.';



-- Fuente: 20250129000001_add_project_to_attachable_type.sql
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



-- Fuente: 20251114000001_create_anteproject_messages.sql
-- =====================================================
-- MIGRACIÓN: Crear tabla de mensajería entre estudiantes y tutores
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- 
-- Propósito: Permitir comunicación bidireccional entre estudiantes y tutores
-- mediante un sistema de mensajería interno asociado a cada anteproyecto.
--
-- Fecha: 2025-11-14
-- =====================================================

-- =====================================================
-- 1. CREAR TABLA anteproject_messages
-- =====================================================
CREATE TABLE IF NOT EXISTS anteproject_messages (
    id SERIAL PRIMARY KEY,
    anteproject_id INT NOT NULL,
    sender_id INT NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (anteproject_id) REFERENCES anteprojects(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- 2. CREAR ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- Índice para buscar mensajes por anteproyecto (más común)
CREATE INDEX IF NOT EXISTS idx_anteproject_messages_anteproject_id 
    ON anteproject_messages(anteproject_id);

-- Índice para buscar mensajes por remitente
CREATE INDEX IF NOT EXISTS idx_anteproject_messages_sender_id 
    ON anteproject_messages(sender_id);

-- Índice para buscar mensajes no leídos
CREATE INDEX IF NOT EXISTS idx_anteproject_messages_is_read 
    ON anteproject_messages(is_read) WHERE is_read = FALSE;

-- Índice compuesto para buscar mensajes no leídos por anteproyecto
CREATE INDEX IF NOT EXISTS idx_anteproject_messages_unread_by_anteproject 
    ON anteproject_messages(anteproject_id, is_read) WHERE is_read = FALSE;

-- =====================================================
-- 3. TRIGGER PARA ACTUALIZAR updated_at AUTOMÁTICAMENTE
-- =====================================================
CREATE OR REPLACE FUNCTION update_anteproject_messages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_anteproject_messages_updated_at
    BEFORE UPDATE ON anteproject_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_anteproject_messages_updated_at();

-- =====================================================
-- 4. HABILITAR ROW LEVEL SECURITY (RLS)
-- =====================================================
ALTER TABLE anteproject_messages ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5. POLÍTICAS RLS
-- =====================================================

-- Política: Permitir acceso completo (temporal para desarrollo)
-- IMPORTANTE: Esta política debe ser reemplazada en producción con políticas más restrictivas
CREATE POLICY "Development access to messages" 
    ON anteproject_messages
    FOR ALL 
    USING (true);

-- =====================================================
-- 6. COMENTARIOS EN LA TABLA Y COLUMNAS
-- =====================================================
COMMENT ON TABLE anteproject_messages IS 
    'Mensajes de comunicación bidireccional entre estudiantes y tutores asociados a anteproyectos';

COMMENT ON COLUMN anteproject_messages.id IS 
    'Identificador único del mensaje';

COMMENT ON COLUMN anteproject_messages.anteproject_id IS 
    'ID del anteproyecto al que pertenece el mensaje';

COMMENT ON COLUMN anteproject_messages.sender_id IS 
    'ID del usuario que envió el mensaje (puede ser estudiante o tutor)';

COMMENT ON COLUMN anteproject_messages.content IS 
    'Contenido del mensaje';

COMMENT ON COLUMN anteproject_messages.is_read IS 
    'Indica si el mensaje ha sido leído por el destinatario';

COMMENT ON COLUMN anteproject_messages.read_at IS 
    'Fecha y hora en que el mensaje fue leído';

COMMENT ON COLUMN anteproject_messages.created_at IS 
    'Fecha y hora de creación del mensaje';

COMMENT ON COLUMN anteproject_messages.updated_at IS 
    'Fecha y hora de última actualización del mensaje';

-- =====================================================
-- ✅ MIGRACIÓN COMPLETADA
-- =====================================================



-- Fuente: 20251206121642_add_github_repo_to_anteprojects.sql
-- MIGRACIÓN: Añadir campo para repositorio de GitHub a la tabla de anteproyectos
--

ALTER TABLE public.anteprojects
ADD COLUMN github_repository_url VARCHAR(500) NULL;

COMMENT ON COLUMN public.anteprojects.github_repository_url IS 'URL del repositorio de GitHub asociado al anteproyecto';






-- =====================================================
-- SECCIÓN: CONFIGURACIÓN RLS Y SEGURIDAD
-- =====================================================

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


-- =====================================================
-- SECCIÓN: ACTUALIZACIÓN POLÍTICAS RLS PARA ARCHIVOS DE PROYECTOS
-- =====================================================

-- =====================================================
-- MIGRACIÓN: Actualizar políticas RLS para archivos de proyectos
-- Fecha: 2025-01-29
-- Descripción: Actualiza las políticas RLS de la tabla files
--              para incluir soporte para attachable_type = 'project'
-- =====================================================

-- Eliminar políticas existentes que necesitan actualización
DROP POLICY IF EXISTS "view_files_by_entity" ON files;
DROP POLICY IF EXISTS "upload_files_in_participating_entities" ON files;

-- Recrear política de visualización con soporte para 'project'
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

-- Recrear política de inserción con soporte para 'project'
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

-- Comentario de documentación
COMMENT ON POLICY "view_files_by_entity" ON files IS 
    'Permite ver archivos según permisos de la entidad asociada (task, anteproject, project)';

COMMENT ON POLICY "upload_files_in_participating_entities" ON files IS 
    'Permite subir archivos en entidades donde el usuario participa (task, anteproject, project)';



-- =====================================================
-- SECCIÓN: CONFIGURACIÓN DE AUTENTICACIÓN
-- =====================================================

-- =====================================================
-- MIGRACIÓN: Configuración de Supabase Auth
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- =====================================================
-- 1. CONFIGURACIÓN DE AUTENTICACIÓN
-- =====================================================

-- Habilitar autenticación por email
-- En Supabase, esto se configura automáticamente

-- =====================================================
-- 2. FUNCIÓN PARA CREAR USUARIOS CON ROLES
-- =====================================================

-- Función para crear usuarios con roles específicos
CREATE OR REPLACE FUNCTION public.create_user_with_role(
    email TEXT,
    password TEXT,
    full_name TEXT,
    role user_role DEFAULT 'student',
    nre TEXT DEFAULT NULL,
    phone TEXT DEFAULT NULL,
    biography TEXT DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    user_id INT;
BEGIN
    -- Insertar usuario en la tabla users
    INSERT INTO users (
        email,
        password_hash, -- En producción, esto debería ser hash de la contraseña
        full_name,
        role,
        nre,
        phone,
        biography,
        status,
        email_verified_at
    ) VALUES (
        email,
        password, -- En producción, usar hash
        full_name,
        role,
        nre,
        phone,
        biography,
        'active',
        CURRENT_TIMESTAMP
    ) RETURNING id INTO user_id;
    
    RETURN user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. FUNCIÓN PARA GENERAR JWT CON ROLES
-- =====================================================

-- Función para generar JWT claims con información del usuario
CREATE OR REPLACE FUNCTION public.generate_jwt_claims(user_email TEXT)
RETURNS JSON AS $$
DECLARE
    user_record RECORD;
    jwt_claims JSON;
BEGIN
    -- Obtener información del usuario
    SELECT id, email, role, full_name INTO user_record
    FROM users 
    WHERE email = user_email AND status = 'active';
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;
    
    -- Generar JWT claims
    jwt_claims := json_build_object(
        'user_id', user_record.id,
        'email', user_record.email,
        'role', user_record.role,
        'full_name', user_record.full_name,
        'exp', extract(epoch from (now() + interval '24 hours'))::integer
    );
    
    RETURN jwt_claims;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 4. FUNCIÓN PARA VERIFICAR AUTENTICACIÓN
-- =====================================================

-- Función para verificar si un usuario está autenticado
CREATE OR REPLACE FUNCTION public.is_authenticated()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN public.user_id() IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 5. POLÍTICAS ADICIONALES PARA AUTENTICACIÓN
-- =====================================================

-- Política para permitir registro de usuarios (solo estudiantes)
CREATE POLICY "Allow student registration" ON users
    FOR INSERT WITH CHECK (
        role = 'student' AND 
        nre IS NOT NULL AND
        email LIKE '%@%'
    );

-- Política para permitir login (verificar credenciales)
CREATE POLICY "Allow login verification" ON users
    FOR SELECT USING (
        status = 'active' AND
        email_verified_at IS NOT NULL
    );

-- =====================================================
-- 6. DATOS DE PRUEBA PARA AUTENTICACIÓN
-- =====================================================

-- Crear usuarios de prueba con diferentes roles
-- (Estos usuarios ya existen en seed_initial_data.sql)

-- =====================================================
-- 7. FUNCIÓN DE PRUEBA PARA SIMULAR LOGIN
-- =====================================================

-- Función para simular login y obtener JWT claims
CREATE OR REPLACE FUNCTION public.simulate_login(email TEXT, password TEXT)
RETURNS JSON AS $$
DECLARE
    user_record RECORD;
    jwt_claims JSON;
BEGIN
    -- Verificar credenciales (en producción, verificar hash)
    SELECT id, email, role, full_name INTO user_record
    FROM users 
    WHERE email = email 
    AND password_hash = password  -- En producción, verificar hash
    AND status = 'active';
    
    IF NOT FOUND THEN
        RETURN json_build_object('error', 'Invalid credentials');
    END IF;
    
    -- Generar JWT claims
    jwt_claims := public.generate_jwt_claims(email);
    
    RETURN json_build_object(
        'success', true,
        'user', json_build_object(
            'id', user_record.id,
            'email', user_record.email,
            'role', user_record.role,
            'full_name', user_record.full_name
        ),
        'jwt_claims', jwt_claims
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 8. VERIFICACIÓN Y DOCUMENTACIÓN
-- =====================================================

-- Comentarios en las funciones
COMMENT ON FUNCTION public.create_user_with_role(TEXT, TEXT, TEXT, user_role, TEXT, TEXT, TEXT) IS 'Crea un usuario con rol específico';
COMMENT ON FUNCTION public.generate_jwt_claims(TEXT) IS 'Genera JWT claims para un usuario';
COMMENT ON FUNCTION public.is_authenticated() IS 'Verifica si el usuario está autenticado';
COMMENT ON FUNCTION public.simulate_login(TEXT, TEXT) IS 'Simula login y retorna JWT claims';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Supabase Auth configurado exitosamente';
    RAISE NOTICE 'Funciones de autenticación creadas';
    RAISE NOTICE 'Políticas de autenticación aplicadas';
    RAISE NOTICE 'Sistema listo para integración con frontend';
END $$;


-- =====================================================
-- SECCIÓN: FUNCIONES RPC
-- =====================================================

-- ============================================================================
-- Función RPC para resetear contraseñas de estudiantes
-- ============================================================================
-- Esta función permite a tutores y administradores resetear contraseñas
-- de estudiantes usando una función RPC que llama a la API Admin de Supabase
--
-- IMPORTANTE: 
-- 1. Requiere la extensión pg_net instalada
-- 2. Requiere configurar SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY como secrets
-- 3. El usuario debe tener permisos adecuados (admin o tutor del estudiante)
-- ============================================================================

-- Verificar que pg_net está instalado (requerido para hacer peticiones HTTP)
-- Si no está instalado, ejecutar: CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION reset_student_password(
  p_student_email TEXT,
  p_new_password TEXT,
  p_reset_by_user_id INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_student_id INTEGER;
  v_student_role TEXT;
  v_reset_by_role TEXT;
  v_tutor_id INTEGER;
  v_auth_user_id UUID;
  v_supabase_url TEXT;
  v_service_role_key TEXT;
  v_request_body JSONB;
  v_response JSONB;
  v_http_response RECORD;
BEGIN
  -- Verificar que el usuario que resetea existe y obtener su rol
  SELECT role INTO v_reset_by_role
  FROM users
  WHERE id = p_reset_by_user_id;
  
  IF v_reset_by_role IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuario que resetea no encontrado'
    );
  END IF;
  
  -- Verificar que el usuario es admin o tutor
  IF v_reset_by_role NOT IN ('admin', 'tutor') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Solo administradores y tutores pueden resetear contraseñas'
    );
  END IF;
  
  -- Verificar que el estudiante existe y obtener su información
  SELECT id, role, tutor_id INTO v_student_id, v_student_role, v_tutor_id
  FROM users
  WHERE email = p_student_email AND role = 'student';
  
  IF v_student_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Estudiante no encontrado'
    );
  END IF;
  
  -- Si no es admin, verificar que es tutor del estudiante
  IF v_reset_by_role = 'tutor' AND v_tutor_id != p_reset_by_user_id THEN
    RETURN json_build_object(
      'success', false,
      'error', 'No tienes permisos para resetear la contraseña de este estudiante'
    );
  END IF;
  
  -- Obtener el auth.users.id del estudiante
  SELECT id INTO v_auth_user_id
  FROM auth.users
  WHERE email = p_student_email;
  
  IF v_auth_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuario no encontrado en Supabase Auth. Asegúrate de que el estudiante tenga una cuenta activa.'
    );
  END IF;
  
  -- Obtener configuración de Supabase desde variables de entorno/secrets
  -- Nota: Estas deben estar configuradas en Supabase Dashboard → Settings → Edge Functions → Secrets
  -- O usar current_setting si están configuradas como variables de sesión
  v_supabase_url := current_setting('app.supabase_url', true);
  v_service_role_key := current_setting('app.supabase_service_role_key', true);
  
  -- Si no están configuradas, intentar obtenerlas de vault (Supabase Secrets)
  -- Nota: Esto requiere que estén configuradas en Supabase
  IF v_supabase_url IS NULL OR v_service_role_key IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Configuración de Supabase no encontrada. Por favor, usa la Edge Function super-action en su lugar.'
    );
  END IF;
  
  -- Construir el cuerpo de la petición para la API Admin de Supabase
  v_request_body := jsonb_build_object(
    'password', p_new_password
  );
  
  -- Llamar a la API Admin de Supabase usando pg_net
  SELECT * INTO v_http_response
  FROM net.http_post(
    url := v_supabase_url || '/auth/v1/admin/users/' || v_auth_user_id,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_service_role_key,
      'apikey', v_service_role_key
    ),
    body := v_request_body::text
  );
  
  -- Verificar la respuesta
  IF v_http_response.status_code != 200 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Error al actualizar contraseña en Supabase Auth. Código: ' || v_http_response.status_code
    );
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'message', 'Contraseña actualizada exitosamente',
    'student_id', v_student_id,
    'auth_user_id', v_auth_user_id
  );
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Error inesperado: ' || SQLERRM
    );
END;
$$;

-- Otorgar permisos a los roles necesarios
GRANT EXECUTE ON FUNCTION reset_student_password(TEXT, TEXT, INTEGER) TO authenticated;

-- Comentario de la función
COMMENT ON FUNCTION reset_student_password IS 'Resetea la contraseña de un estudiante. Solo puede ser usado por administradores o tutores del estudiante.';



-- =====================================================
-- SECCIÓN: DATOS INICIALES (SEED DATA)
-- =====================================================

-- =====================================================
-- MIGRACIÓN: Datos Iniciales del Sistema TFG
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- =====================================================
-- 1. OBJETIVOS DEL CICLO DAM
-- =====================================================

INSERT INTO dam_objectives (title, description, display_order) VALUES
-- Objetivos principales del ciclo DAM
('Consolidar conocimientos de desarrollo', 'Consolidar los conocimientos adquiridos durante el ciclo sobre herramientas de desarrollo y técnicas de análisis y diseño de aplicaciones', 1),
('Análisis de requisitos', 'Llevar a cabo el análisis de requisitos previo al desarrollo de software', 2),
('Selección de tecnologías', 'Elegir las herramientas y tecnologías oportunas para implementar la solución', 3),
('Implementación de esquema relacional', 'Implementar el esquema relacional tomando como partida un modelo de datos previamente analizado', 4),
('Explotación de base de datos', 'Explotar una base de datos relacional como soporte no volátil de la información', 5),
('Desarrollo backend', 'Codificar rutinas con lenguajes del lado del servidor (back-end)', 6),
('Desarrollo frontend', 'Codificar rutinas con lenguajes del lado del cliente (front-end)', 7),
('Diseño de interfaz', 'Diseñar la interfaz de una aplicación atendiendo a los requerimientos', 8),
('Documentación técnica', 'Documentar un proyecto elaborando las guías de instalación y memoria técnica', 9);

-- =====================================================
-- 2. CRITERIOS DE EVALUACIÓN DE ANTEPROYECTOS
-- =====================================================

INSERT INTO anteproject_evaluation_criteria (name, description, max_score, display_order) VALUES
('Viabilidad técnica', 'El proyecto es técnicamente viable con las tecnologías y recursos disponibles', 10.0, 1),
('Coherencia de objetivos', 'Los objetivos están bien definidos y son coherentes con las competencias del ciclo DAM', 10.0, 2),
('Claridad en la descripción', 'La descripción del proyecto es clara, completa y comprensible', 10.0, 3),
('Realismo en la temporalización', 'La temporalización propuesta es realista y factible', 10.0, 4),
('Adecuación al tipo de proyecto', 'El proyecto se ajusta adecuadamente al tipo seleccionado', 10.0, 5),
('Calidad de los resultados esperados', 'Los resultados esperados están bien definidos y son medibles', 10.0, 6),
('Innovación y originalidad', 'El proyecto aporta elementos innovadores o originales', 5.0, 7),
('Impacto y utilidad', 'El proyecto tiene un impacto positivo y es útil para su contexto', 5.0, 8);

-- =====================================================
-- 3. PLANTILLAS PDF
-- =====================================================

-- Plantilla para anteproyectos
INSERT INTO pdf_templates (name, template_type, template_content, version) VALUES
('Plantilla Oficial Anteproyecto', 'anteproject', 
'<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Anteproyecto TFG - {{title}}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
        .header { text-align: center; margin-bottom: 30px; }
        .institution { font-weight: bold; font-size: 18px; margin-bottom: 10px; }
        .title { font-size: 16px; margin-bottom: 20px; }
        .student-info { margin-bottom: 30px; }
        .section { margin-bottom: 20px; }
        .section-title { font-weight: bold; margin-bottom: 10px; }
        .footer { margin-top: 40px; text-align: center; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <div class="institution">{{institution}}</div>
        <div class="title">Ciclo Formativo de Grado Superior</div>
        <div class="title">Desarrollo de Aplicaciones Multiplataforma</div>
        <div class="title">{{modality}}</div>
    </div>

    <div class="student-info">
        <p>El alumno <strong>{{student_name}}</strong>, del {{institution}}, matriculado durante el curso académico <strong>{{academic_year}}</strong>, en el módulo de Proyecto del ciclo formativo de grado superior Desarrollo de Aplicaciones Multiplataforma ({{modality}}), propone al tribunal para su aceptación la realización del siguiente proyecto:</p>
    </div>

    <div class="section">
        <div class="section-title">TÍTULO DEL PROYECTO</div>
        <p><strong>{{title}}</strong></p>
    </div>

    <div class="section">
        <div class="section-title">TIPO DE PROYECTO</div>
        <p>{{project_type_description}}</p>
    </div>

    <div class="section">
        <div class="section-title">DESCRIPCIÓN</div>
        <p>{{description}}</p>
    </div>

    <div class="section">
        <div class="section-title">OBJETIVOS</div>
        <ul>
            {{#objectives}}
            <li>{{.}}</li>
            {{/objectives}}
        </ul>
    </div>

    <div class="section">
        <div class="section-title">RESULTADOS ESPERADOS</div>
        <table>
            <thead>
                <tr>
                    <th>Hito</th>
                    <th>Descripción</th>
                    <th>Fecha Prevista</th>
                </tr>
            </thead>
            <tbody>
                {{#expected_results}}
                <tr>
                    <td>{{milestone_number}}</td>
                    <td>{{description}}</td>
                    <td>{{planned_date}}</td>
                </tr>
                {{/expected_results}}
            </tbody>
        </table>
    </div>

    <div class="section">
        <div class="section-title">TEMPORALIZACIÓN INICIAL</div>
        <table>
            <thead>
                <tr>
                    <th>Fecha</th>
                    <th>Actividad</th>
                </tr>
            </thead>
            <tbody>
                {{#timeline}}
                <tr>
                    <td>{{date}}</td>
                    <td>{{activity}}</td>
                </tr>
                {{/timeline}}
            </tbody>
        </table>
    </div>

    <div class="footer">
        <p>En {{location}}, a {{current_date}}</p>
    </div>
</body>
</html>', '1.0'),

-- Plantilla para informes de proyecto
('Plantilla Informe Proyecto', 'project_report',
'<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Informe Proyecto - {{title}}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
        .header { text-align: center; margin-bottom: 30px; }
        .title { font-size: 20px; font-weight: bold; margin-bottom: 20px; }
        .section { margin-bottom: 20px; }
        .section-title { font-weight: bold; margin-bottom: 10px; }
        .stats { display: flex; justify-content: space-around; margin: 20px 0; }
        .stat-box { text-align: center; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .stat-number { font-size: 24px; font-weight: bold; color: #007bff; }
        .stat-label { font-size: 14px; color: #666; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <div class="title">INFORME DE PROYECTO</div>
        <div class="title">{{title}}</div>
    </div>

    <div class="section">
        <div class="section-title">INFORMACIÓN GENERAL</div>
        <p><strong>Estado:</strong> {{status}}</p>
        <p><strong>Fecha de inicio:</strong> {{start_date}}</p>
        <p><strong>Fecha estimada de finalización:</strong> {{estimated_end_date}}</p>
        <p><strong>Tutor:</strong> {{tutor_name}}</p>
        <p><strong>Estudiantes:</strong> {{student_names}}</p>
    </div>

    <div class="section">
        <div class="section-title">ESTADÍSTICAS DEL PROYECTO</div>
        <div class="stats">
            <div class="stat-box">
                <div class="stat-number">{{total_tasks}}</div>
                <div class="stat-label">Total Tareas</div>
            </div>
            <div class="stat-box">
                <div class="stat-number">{{completed_tasks}}</div>
                <div class="stat-label">Tareas Completadas</div>
            </div>
            <div class="stat-box">
                <div class="stat-number">{{completion_percentage}}%</div>
                <div class="stat-label">Progreso</div>
            </div>
            <div class="stat-box">
                <div class="stat-number">{{total_milestones}}</div>
                <div class="stat-label">Hitos</div>
            </div>
        </div>
    </div>

    <div class="section">
        <div class="section-title">TAREAS POR ESTADO</div>
        <table>
            <thead>
                <tr>
                    <th>Estado</th>
                    <th>Cantidad</th>
                    <th>Porcentaje</th>
                </tr>
            </thead>
            <tbody>
                {{#tasks_by_status}}
                <tr>
                    <td>{{status}}</td>
                    <td>{{count}}</td>
                    <td>{{percentage}}%</td>
                </tr>
                {{/tasks_by_status}}
            </tbody>
        </table>
    </div>

    <div class="section">
        <div class="section-title">HITOS DEL PROYECTO</div>
        <table>
            <thead>
                <tr>
                    <th>Hito</th>
                    <th>Descripción</th>
                    <th>Fecha Prevista</th>
                    <th>Estado</th>
                </tr>
            </thead>
            <tbody>
                {{#milestones}}
                <tr>
                    <td>{{milestone_number}}</td>
                    <td>{{title}}</td>
                    <td>{{planned_date}}</td>
                    <td>{{status}}</td>
                </tr>
                {{/milestones}}
            </tbody>
        </table>
    </div>

    <div class="section">
        <div class="section-title">DESCRIPCIÓN</div>
        <p>{{description}}</p>
    </div>

    <div class="footer">
        <p>Informe generado el {{generated_date}}</p>
    </div>
</body>
</html>', '1.0');

-- =====================================================
-- 4. CONFIGURACIÓN DEL SISTEMA
-- =====================================================

INSERT INTO system_settings (setting_key, setting_value, setting_type, description) VALUES
-- Configuración general
('institution_name', 'CIFP Carlos III de Cartagena', 'string', 'Nombre de la institución educativa'),
('institution_address', 'Cartagena, Murcia', 'string', 'Dirección de la institución'),
('academic_year', '2024-2025', 'string', 'Año académico actual'),
('max_file_size_mb', '50', 'integer', 'Tamaño máximo de archivo en MB'),
('allowed_file_types', '["pdf", "doc", "docx", "txt", "zip", "rar", "jpg", "jpeg", "png", "gif"]', 'json', 'Tipos de archivo permitidos'),
('max_project_duration_days', '365', 'integer', 'Duración máxima de un proyecto en días'),
('enable_github_integration', 'true', 'boolean', 'Habilitar integración con GitHub'),
('enable_email_notifications', 'false', 'boolean', 'Habilitar notificaciones por email'),
('enable_auto_task_generation', 'true', 'boolean', 'Habilitar generación automática de tareas'),
('default_task_complexity', 'medium', 'string', 'Complejidad por defecto de las tareas'),
('max_students_per_project', '3', 'integer', 'Máximo número de estudiantes por proyecto'),
('max_tasks_per_project', '100', 'integer', 'Máximo número de tareas por proyecto'),
('enable_activity_logging', 'true', 'boolean', 'Habilitar registro de actividad'),
('session_timeout_minutes', '480', 'integer', 'Tiempo de sesión en minutos'),
('enable_debug_mode', 'false', 'boolean', 'Habilitar modo debug'),
('backup_frequency_hours', '24', 'integer', 'Frecuencia de backup en horas'),
('enable_auto_backup', 'true', 'boolean', 'Habilitar backup automático'),
('max_notifications_per_user', '100', 'integer', 'Máximo número de notificaciones por usuario'),
('notification_retention_days', '30', 'integer', 'Días de retención de notificaciones'),
('enable_project_templates', 'true', 'boolean', 'Habilitar plantillas de proyecto'),
('enable_milestone_templates', 'true', 'boolean', 'Habilitar plantillas de hitos');

-- =====================================================
-- NOTA: Datos de ejemplo eliminados
-- =====================================================
-- Los datos de ejemplo (usuarios, anteproyectos, proyectos, tareas, etc.)
-- han sido eliminados del schema_completo.sql para mantener solo
-- la estructura y datos de configuración del sistema.
-- 
-- Para datos de prueba, consulta las migraciones históricas en historico/
-- o crea tus propios datos de prueba según sea necesario.

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE dam_objectives IS 'Objetivos del ciclo DAM disponibles para selección en anteproyectos';
COMMENT ON TABLE anteproject_evaluation_criteria IS 'Criterios de evaluación estándar para anteproyectos';
COMMENT ON TABLE pdf_templates IS 'Plantillas HTML para generar documentos PDF';
COMMENT ON TABLE system_settings IS 'Configuración inicial del sistema';
COMMENT ON TABLE users IS 'Usuarios del sistema con roles: admin, tutor, student';
COMMENT ON TABLE anteprojects IS 'Anteproyectos que deben ser aprobados antes de crear proyectos';
COMMENT ON TABLE projects IS 'Proyectos finales activos tras aprobación del anteproyecto';
COMMENT ON TABLE tasks IS 'Tareas granular del proyecto, pueden generarse automáticamente o manualmente';
COMMENT ON TABLE comments IS 'Comentarios asociados a tareas del proyecto';
COMMENT ON TABLE notifications IS 'Sistema de notificaciones para avisos automáticos';
COMMENT ON TABLE anteproject_evaluations IS 'Evaluaciones de anteproyectos realizadas por tutores';


-- Fuente: 20251214000001_automate_academic_year.sql
-- =====================================================
-- MIGRACIÓN: Automatización del Año Académico
-- Fecha: 2025-12-14
-- Descripción: Automatiza la actualización del año académico el 1 de septiembre
-- =====================================================

-- 1. Habilitar extensión pg_cron (necesario para tareas programadas)
-- Nota: Requiere permisos de superusuario o habilitación desde dashboard de Supabase
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 2. Función para actualizar el año académico automáticamente
CREATE OR REPLACE FUNCTION public.update_academic_year_automatically()
RETURNS void AS $$
DECLARE
    current_year INTEGER;
    next_year INTEGER;
    new_academic_year TEXT;
    admin_id INTEGER;
BEGIN
    -- Calcular el nuevo año académico (ej: 1 sept 2025 -> "2025-2026")
    current_year := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
    next_year := current_year + 1;
    new_academic_year := current_year || '-' || next_year;

    -- Obtener un ID de admin para el log (para satisfacer la clave foránea user_id NOT NULL)
    -- Si no hay admins, esto podría fallar si user_id es estricto, pero asumimos que siempre hay al menos uno.
    SELECT id INTO admin_id FROM users WHERE role = 'admin' LIMIT 1;

    -- Actualizar la configuración del sistema
    UPDATE system_settings
    SET 
        setting_value = new_academic_year,
        updated_at = NOW(),
        updated_by = admin_id -- Atribuimos el cambio al sistema (representado por un admin)
    WHERE setting_key = 'academic_year';

    -- Registrar la actividad en el log
    IF admin_id IS NOT NULL THEN
        INSERT INTO activity_log (user_id, action, entity_type, entity_id, new_values, created_at)
        VALUES (
            admin_id,
            'system_auto_update', 
            'system_setting', 
            (SELECT id FROM system_settings WHERE setting_key = 'academic_year'),
            json_build_object('academic_year', new_academic_year, 'source', 'pg_cron'),
            NOW()
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 3. Programar la tarea con pg_cron
-- Se ejecuta el 1 de septiembre a las 00:00
-- Sintaxis Cron: min hour day month day_of_week
-- Nota: Si ya existe un job con el mismo nombre, esto podría duplicarlo o fallar dependiendo de la versión.
-- Usamos unschedule primero por seguridad si se re-ejecuta.
SELECT cron.unschedule('auto_update_academic_year');

SELECT cron.schedule(
    'auto_update_academic_year', -- Nombre único de la tarea
    '0 0 1 9 *',                 -- Cron expression: 00:00 del 1 de Septiembre
    $$SELECT public.update_academic_year_automatically()$$
);

-- Comentario de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Automatización del año académico configurada para el 1 de septiembre';
END $$;


-- Fuente: 20251215000001_add_academic_year_to_users.sql
-- =====================================================
-- MIGRACIÓN: Agregar campo academic_year a la tabla users
-- Fecha: 2025-12-15
-- Descripción: Agrega el campo academic_year a la tabla users para
--              permitir el control de permisos de escritura basado
--              en el año académico.
-- =====================================================

-- Nota: La columna, índice, función y trigger ya están incluidos
-- en las secciones anteriores del schema. Esta sección solo actualiza
-- los estudiantes existentes que no tengan año académico asignado.

-- Actualizar estudiantes existentes sin año académico
DO $$
DECLARE
    active_academic_year TEXT;
    updated_count INTEGER;
BEGIN
    -- Obtener el año académico activo del sistema
    SELECT setting_value INTO active_academic_year
    FROM system_settings
    WHERE setting_key = 'academic_year'
    LIMIT 1;
    
    -- Si hay año activo, actualizar estudiantes sin año asignado
    IF active_academic_year IS NOT NULL AND active_academic_year != '' THEN
        UPDATE users
        SET academic_year = active_academic_year,
            updated_at = CURRENT_TIMESTAMP
        WHERE role = 'student' 
          AND (academic_year IS NULL OR academic_year = '');
        
        GET DIAGNOSTICS updated_count = ROW_COUNT;
        
        IF updated_count > 0 THEN
            RAISE NOTICE 'Migración: % estudiantes actualizados con año académico %', 
                updated_count, active_academic_year;
        END IF;
    END IF;
END $$;
