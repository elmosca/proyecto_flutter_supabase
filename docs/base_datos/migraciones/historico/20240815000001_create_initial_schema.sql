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
    password_hash VARCHAR(255) NOT NULL,
    email_verified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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
    kanban_position INT DEFAULT 0,
    
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
CREATE TYPE attachable_type AS ENUM ('task', 'comment', 'anteproject');

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
