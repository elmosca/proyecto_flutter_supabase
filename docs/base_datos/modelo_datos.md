# 🗄️ Modelo de Datos del Sistema
# Sistema de Seguimiento de Proyectos TFG - Ciclo DAM

## 1. 📋 Diagrama de Entidades

### Entidades Principales:
- `users` (Usuarios)
- `projects` (Proyectos)
- `anteprojects` (Anteproyectos)
- `tasks` (Tareas)
- `comments` (Comentarios)
- `files` (Archivos)
- `milestones` (Hitos)
- `notifications` (Notificaciones)

### Entidades de Relación:
- `project_users` (Relación Proyecto-Usuario)
- `task_users` (Relación Tarea-Usuario)

## 2. 🏗️ Estructura de Tablas

### 2.1. Tabla: users
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    nre VARCHAR(20) UNIQUE NULL, -- Solo para alumnos
    role ENUM('admin', 'tutor', 'student') NOT NULL DEFAULT 'student',
    phone VARCHAR(20) NULL,
    biography TEXT NULL,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    password_hash VARCHAR(255) NOT NULL,
    email_verified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### 2.2. Tabla: anteprojects (MEJORADA)
```sql
CREATE TABLE anteprojects (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    project_type ENUM('execution', 'research', 'bibliographic', 'management') NOT NULL,
    description TEXT NOT NULL,
    -- Campos adicionales para plantilla oficial
    academic_year VARCHAR(20) NOT NULL, -- ej: "2024-2025"
    institution VARCHAR(255) DEFAULT 'CIFP Carlos III de Cartagena',
    modality VARCHAR(100) DEFAULT 'modalidad distancia',
    location VARCHAR(100) DEFAULT 'Cartagena',
    
    expected_results JSON NOT NULL, -- Array de hitos/resultados
    timeline JSON NOT NULL, -- Fechas clave del proyecto
    status ENUM('draft', 'submitted', 'under_review', 'approved', 'rejected') NOT NULL DEFAULT 'draft',
    tutor_id INT NOT NULL,
    
    -- Fechas simplificadas
    submitted_at TIMESTAMP NULL,
    reviewed_at TIMESTAMP NULL,
    
    -- Relación bidireccional con proyecto
    project_id INT UNIQUE NULL,
    
    tutor_comments TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tutor_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL
);
```

### 2.13. Tabla: dam_objectives (NUEVA)
```sql
CREATE TABLE dam_objectives (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2.14. Tabla: anteproject_objectives (NUEVA)
```sql
CREATE TABLE anteproject_objectives (
    id SERIAL PRIMARY KEY,
    anteproject_id INT NOT NULL,
    objective_id INT NOT NULL,
    is_selected BOOLEAN DEFAULT TRUE,
    custom_description TEXT NULL, -- Para objetivos personalizados
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (anteproject_id) REFERENCES anteprojects(id) ON DELETE CASCADE,
    FOREIGN KEY (objective_id) REFERENCES dam_objectives(id) ON DELETE RESTRICT,
    UNIQUE KEY unique_anteproject_objective (anteproject_id, objective_id)
);
```

### 2.3. Tabla: anteproject_students
```sql
CREATE TABLE anteproject_students (
    id SERIAL PRIMARY KEY,
    anteproject_id INT NOT NULL,
    student_id INT NOT NULL,
    is_lead_author BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (anteproject_id) REFERENCES anteprojects(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_anteproject_student (anteproject_id, student_id)
);
```

### 2.4. Tabla: projects (MEJORADA)
```sql
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    status ENUM('draft', 'planning', 'development', 'review', 'completed') NOT NULL DEFAULT 'draft',
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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tutor_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (anteproject_id) REFERENCES anteprojects(id) ON DELETE SET NULL
);
```

### 2.5. Tabla: project_students
```sql
CREATE TABLE project_students (
    id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    student_id INT NOT NULL,
    is_lead BOOLEAN DEFAULT FALSE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_project_student (project_id, student_id)
);
```

### 2.6. Tabla: milestones (MEJORADA)
```sql
CREATE TABLE milestones (
    id SERIAL PRIMARY KEY,
    project_id INT NOT NULL, -- Los milestones solo pertenecen a proyectos
    milestone_number INT NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    planned_date DATE NOT NULL,
    completed_date DATE NULL,
    status ENUM('pending', 'in_progress', 'completed', 'delayed') NOT NULL DEFAULT 'pending',
    
    -- Campos adicionales
    milestone_type ENUM('planning', 'execution', 'review', 'final') DEFAULT 'execution',
    expected_deliverables JSON NULL,
    
    review_comments TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    UNIQUE KEY unique_project_milestone (project_id, milestone_number)
);
```

### 2.15. Tabla: anteproject_evaluation_criteria (NUEVA)
```sql
CREATE TABLE anteproject_evaluation_criteria (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    max_score DECIMAL(3,1) DEFAULT 10.0,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2.16. Tabla: anteproject_evaluations (NUEVA)
```sql
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
    UNIQUE KEY unique_evaluation (anteproject_id, criteria_id)
);
```

### 2.17. Tabla: pdf_templates (NUEVA)
```sql
CREATE TABLE pdf_templates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    template_type ENUM('anteproject', 'project_report', 'task_summary') NOT NULL,
    template_content TEXT NOT NULL, -- HTML/CSS template
    is_active BOOLEAN DEFAULT TRUE,
    version VARCHAR(10) DEFAULT '1.0',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### 2.7. Tabla: tasks (MEJORADA)
```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    milestone_id INT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    status ENUM('pending', 'in_progress', 'under_review', 'completed') NOT NULL DEFAULT 'pending',
    due_date DATE NULL,
    completed_at TIMESTAMP NULL,
    kanban_position INT DEFAULT 0,
    
    -- Campos adicionales
    estimated_hours INT NULL,
    actual_hours INT NULL,
    complexity ENUM('simple', 'medium', 'complex') DEFAULT 'medium',
    tags JSON NULL, -- Para etiquetas personalizadas
    
    -- Campos para generación automática
    is_auto_generated BOOLEAN DEFAULT FALSE, -- Indica si la tarea se generó automáticamente
    generation_source VARCHAR(50) NULL, -- 'mcp_server', 'student_defined', 'template'
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (milestone_id) REFERENCES milestones(id) ON DELETE SET NULL
);
```

### 2.18. Tabla: system_settings (NUEVA)
```sql
CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    setting_type ENUM('string', 'integer', 'boolean', 'json') DEFAULT 'string',
    description TEXT NULL,
    is_editable BOOLEAN DEFAULT TRUE,
    updated_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
```

### 2.19. Tabla: file_versions (NUEVA)
```sql
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
    UNIQUE KEY unique_file_version (original_file_id, version_number)
);
```

### 2.8. Tabla: task_assignees
```sql
CREATE TABLE task_assignees (
    id SERIAL PRIMARY KEY,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INT NOT NULL,
    
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE RESTRICT,
    UNIQUE KEY unique_task_assignee (task_id, user_id)
);
```

### 2.9. Tabla: comments
```sql
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    task_id INT NOT NULL,
    author_id INT NOT NULL,
    content TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT FALSE, -- Para comentarios privados del tutor
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 2.10. Tabla: files
```sql
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
    attachable_type ENUM('task', 'comment', 'anteproject') NOT NULL,
    attachable_id INT NOT NULL,
    
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_attachable (attachable_type, attachable_id)
);
```

### 2.11. Tabla: notifications
```sql
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
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_unread (user_id, read_at),
    INDEX idx_created_at (created_at)
);
```

### 2.12. Tabla: activity_log
```sql
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
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_user_activity (user_id, created_at)
);
```

## 3. 📊 Índices y Optimizaciones (AMPLIADOS)

### Índices Adicionales:
```sql
-- Para búsquedas de anteproyectos
CREATE INDEX idx_anteprojects_status_tutor ON anteprojects(status, tutor_id);
CREATE INDEX idx_anteprojects_academic_year ON anteprojects(academic_year);

-- Para optimizar el Kanban
CREATE INDEX idx_tasks_kanban ON tasks(project_id, status, kanban_position);

-- Para notificaciones por tipo
CREATE INDEX idx_notifications_type_user ON notifications(type, user_id, read_at);

-- Para objetivos y evaluaciones
CREATE INDEX idx_anteproject_objectives_anteproject ON anteproject_objectives(anteproject_id);
CREATE INDEX idx_evaluations_anteproject ON anteproject_evaluations(anteproject_id);

-- Para configuración del sistema
CREATE INDEX idx_system_settings_key ON system_settings(setting_key);

-- Para versiones de archivos
CREATE INDEX idx_file_versions_original ON file_versions(original_file_id, version_number);
```

## 4. 🔐 Restricciones y Validaciones

### Restricciones de Negocio:
- Solo usuarios con rol 'student' pueden tener NRE
- Un anteproyecto debe tener al menos un estudiante autor
- Un proyecto solo puede tener un tutor responsable
- Un anteproyecto puede generar un solo proyecto (relación 1:1)
- Los milestones solo pertenecen a proyectos, no a anteproyectos
- Las tareas se pueden generar de múltiples formas: MCP Server, definición manual del alumno, o plantillas predefinidas
- Los hitos deben estar ordenados secuencialmente dentro de un proyecto
- La URL del repositorio GitHub debe ser válida cuando se proporcione
- Solo los alumnos del proyecto pueden modificar la URL del repositorio GitHub

## 5. 🔄 Triggers Recomendados

### Actualizar last_activity_at cuando hay cambios en tareas
```sql
DELIMITER $$
CREATE TRIGGER update_project_activity 
AFTER UPDATE ON tasks 
FOR EACH ROW 
BEGIN
    UPDATE projects 
    SET last_activity_at = CURRENT_TIMESTAMP 
    WHERE id = NEW.project_id;
END$$
DELIMITER ;
```

### Incrementar automáticamente version_number en file_versions
```sql
DELIMITER $$
CREATE TRIGGER auto_increment_file_version
BEFORE INSERT ON file_versions
FOR EACH ROW
BEGIN
    DECLARE max_version INT DEFAULT 0;
    SELECT COALESCE(MAX(version_number), 0) INTO max_version 
    FROM file_versions 
    WHERE original_file_id = NEW.original_file_id;
    SET NEW.version_number = max_version + 1;
END$$
DELIMITER ;
```

### Validar URL de GitHub
```sql
DELIMITER $$
CREATE TRIGGER validate_github_url
BEFORE INSERT OR UPDATE ON projects
FOR EACH ROW
BEGIN
    IF NEW.github_repository_url IS NOT NULL AND 
        NEW.github_repository_url NOT REGEXP '^https://github\.com/[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+(/)?$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La URL del repositorio GitHub no tiene un formato válido';
    END IF;
END$$
DELIMITER ;
```

### Crear notificación cuando se añade repositorio GitHub
```sql
DELIMITER $$
CREATE TRIGGER notify_github_repository_added
AFTER UPDATE ON projects
FOR EACH ROW
BEGIN
    IF OLD.github_repository_url IS NULL AND NEW.github_repository_url IS NOT NULL THEN
        INSERT INTO notifications (user_id, type, title, message, action_url, metadata)
        SELECT 
            NEW.tutor_id,
            'github_repository_added',
            'Repositorio GitHub añadido',
            CONCAT('Se ha añadido el repositorio GitHub al proyecto: ', NEW.title),
            CONCAT('/projects/', NEW.id),
            JSON_OBJECT('project_id', NEW.id, 'repository_url', NEW.github_repository_url);
    END IF;
END$$
DELIMITER ;
```

### Generar tareas automáticamente al aprobar anteproyecto
```sql
DELIMITER $$
CREATE TRIGGER generate_tasks_from_anteproject
AFTER UPDATE ON anteprojects
FOR EACH ROW
BEGIN
    DECLARE project_id INT;
    
    -- Solo ejecutar cuando el anteproyecto cambia a 'approved'
    IF OLD.status != 'approved' AND NEW.status = 'approved' THEN
        
        -- Obtener el ID del proyecto asociado
        SELECT id INTO project_id FROM projects WHERE anteproject_id = NEW.id;
        
        -- Las tareas se pueden generar de múltiples formas:
        -- 1. MCP Server (IA) analiza el anteproyecto y propone tareas
        -- 2. Alumno define tareas manualmente
        -- 3. Plantilla predefinida de buenas prácticas para desarrollo de software
        
        -- Notificar a los estudiantes del proyecto
        INSERT INTO notifications (user_id, type, title, message, action_url)
        SELECT 
            ps.student_id,
            'project_approved',
            'Proyecto aprobado',
            CONCAT('El anteproyecto ha sido aprobado. Puedes comenzar a definir tareas para el proyecto: ', NEW.title),
            CONCAT('/projects/', project_id, '/tasks')
        FROM project_students ps
        WHERE ps.project_id = project_id;
        
    END IF;
END$$
DELIMITER ;
```

## 6. 🐙 Integración con GitHub

### Funcionalidades de Repositorio GitHub:
- **Configuración de repositorio**: Los alumnos pueden añadir la URL de su repositorio GitHub
- **Validación de URL**: El sistema valida que la URL sea de GitHub y tenga formato correcto
- **Visibilidad para tutor**: El tutor puede ver el repositorio para seguimiento del código
- **Enlace directo**: Acceso rápido al repositorio desde la vista del proyecto
- **Notificaciones**: Se notifica al tutor cuando se configura un repositorio

### Ventajas de esta aproximación:
- **No duplica funcionalidad**: GitHub ya gestiona colaboración, issues, branches
- **Simplicidad**: Un solo campo para la URL del repositorio
- **Flexibilidad**: Los alumnos mantienen control total sobre su repositorio
- **Integración opcional**: No es obligatorio usar GitHub para el proyecto
- **Escalabilidad futura**: Se puede ampliar con webhooks o API si es necesario

### Consideraciones para implementación:
- Validar formato de URL: `https://github.com/username/repository`
- Permitir repositorios públicos y privados
- No almacenar credenciales de GitHub en el sistema
- Opcionalmente mostrar último commit o fecha de actividad (vía API de GitHub)
