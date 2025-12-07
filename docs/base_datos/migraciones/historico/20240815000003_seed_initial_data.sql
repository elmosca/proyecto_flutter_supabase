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
-- 5. USUARIO ADMINISTRADOR POR DEFECTO
-- =====================================================

-- Insertar usuario administrador (password: admin123)
INSERT INTO users (full_name, email, role, status, password_hash) VALUES
('Administrador del Sistema', 'admin@cifpcarlos3.es', 'admin', 'active', 
 crypt('admin123', gen_salt('bf')));

-- =====================================================
-- 6. TUTORES DE EJEMPLO
-- =====================================================

-- Insertar tutores de ejemplo (password: tutor123)
INSERT INTO users (full_name, email, role, status, password_hash, phone, biography) VALUES
('María García López', 'maria.garcia@cifpcarlos3.es', 'tutor', 'active', 
 crypt('tutor123', gen_salt('bf')), '+34 968 123 456', 'Tutora especializada en desarrollo web y aplicaciones móviles'),
('Carlos Rodríguez Martín', 'carlos.rodriguez@cifpcarlos3.es', 'tutor', 'active', 
 crypt('tutor123', gen_salt('bf')), '+34 968 123 457', 'Tutor experto en bases de datos y desarrollo backend'),
('Ana Martínez Sánchez', 'ana.martinez@cifpcarlos3.es', 'tutor', 'active', 
 crypt('tutor123', gen_salt('bf')), '+34 968 123 458', 'Tutora especializada en metodologías ágiles y gestión de proyectos');

-- =====================================================
-- 7. ESTUDIANTES DE EJEMPLO
-- =====================================================

-- Insertar estudiantes de ejemplo (password: student123)
INSERT INTO users (full_name, email, nre, role, status, password_hash, phone, biography) VALUES
('Juan Pérez González', 'juan.perez@alumno.cifpcarlos3.es', 'NRE001', 'student', 'active', 
 crypt('student123', gen_salt('bf')), '+34 600 123 456', 'Estudiante interesado en desarrollo de aplicaciones móviles'),
('Laura Fernández Ruiz', 'laura.fernandez@alumno.cifpcarlos3.es', 'NRE002', 'student', 'active', 
 crypt('student123', gen_salt('bf')), '+34 600 123 457', 'Estudiante especializada en desarrollo web frontend'),
('Miguel López Torres', 'miguel.lopez@alumno.cifpcarlos3.es', 'NRE003', 'student', 'active', 
 crypt('student123', gen_salt('bf')), '+34 600 123 458', 'Estudiante con experiencia en bases de datos y backend'),
('Sofía Jiménez Moreno', 'sofia.jimenez@alumno.cifpcarlos3.es', 'NRE004', 'student', 'active', 
 crypt('student123', gen_salt('bf')), '+34 600 123 459', 'Estudiante interesada en desarrollo full-stack'),
('David Sánchez García', 'david.sanchez@alumno.cifpcarlos3.es', 'NRE005', 'student', 'active', 
 crypt('student123', gen_salt('bf')), '+34 600 123 460', 'Estudiante especializado en desarrollo de APIs');

-- =====================================================
-- 8. ANTEPROYECTOS DE EJEMPLO
-- =====================================================

-- Anteproyecto 1: Aplicación móvil
INSERT INTO anteprojects (
    title, project_type, description, academic_year, 
    expected_results, timeline, status, tutor_id
) VALUES (
    'Desarrollo de una aplicación móvil para gestión de tareas académicas',
    'execution',
    'Se desarrollará una aplicación móvil multiplataforma que permita a los estudiantes gestionar sus tareas académicas, con funcionalidades como creación de tareas, recordatorios, seguimiento de progreso y sincronización con calendario académico.',
    '2024-2025',
    '[
        {"milestone_number": 1, "description": "Análisis de requisitos y diseño de la arquitectura", "planned_date": "2024-10-15"},
        {"milestone_number": 2, "description": "Desarrollo del backend y API REST", "planned_date": "2024-11-30"},
        {"milestone_number": 3, "description": "Desarrollo de la aplicación móvil", "planned_date": "2025-01-15"},
        {"milestone_number": 4, "description": "Pruebas, documentación y despliegue", "planned_date": "2025-02-28"}
    ]',
    '[
        {"date": "2024-10-15", "activity": "Revisión del esquema de datos y primer prototipo"},
        {"date": "2024-11-30", "activity": "Revisión de los hitos 1 y 2"},
        {"date": "2025-01-15", "activity": "Revisión de los hitos 3 y 4 y correcciones sobre hitos anteriores"},
        {"date": "2025-02-28", "activity": "Revisión final e indicaciones para presentación y exposición"}
    ]',
    'submitted',
    2
);

-- Asignar estudiantes al anteproyecto 1
INSERT INTO anteproject_students (anteproject_id, student_id, is_lead_author) VALUES
(1, 4, true),  -- Sofía como autor principal
(1, 5, false); -- David como colaborador

-- Asignar objetivos al anteproyecto 1
INSERT INTO anteproject_objectives (anteproject_id, objective_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 6), (1, 7), (1, 8), (1, 9);

-- Anteproyecto 2: Sistema web
INSERT INTO anteprojects (
    title, project_type, description, academic_year, 
    expected_results, timeline, status, tutor_id
) VALUES (
    'Sistema web de gestión de inventario para pequeñas empresas',
    'execution',
    'Se desarrollará un sistema web completo para la gestión de inventario que permita a las pequeñas empresas controlar stock, realizar pedidos, generar reportes y gestionar proveedores de manera eficiente.',
    '2024-2025',
    '[
        {"milestone_number": 1, "description": "Análisis de requisitos y diseño de la base de datos", "planned_date": "2024-10-20"},
        {"milestone_number": 2, "description": "Desarrollo del sistema de autenticación y módulo de usuarios", "planned_date": "2024-11-15"},
        {"milestone_number": 3, "description": "Desarrollo de módulos de inventario y proveedores", "planned_date": "2025-01-10"},
        {"milestone_number": 4, "description": "Desarrollo de reportes y sistema de alertas", "planned_date": "2025-02-15"}
    ]',
    '[
        {"date": "2024-10-20", "activity": "Revisión del esquema de datos y primer prototipo"},
        {"date": "2024-11-15", "activity": "Revisión de los hitos 1 y 2"},
        {"date": "2025-01-10", "activity": "Revisión de los hitos 3 y 4 y correcciones sobre hitos anteriores"},
        {"date": "2025-02-15", "activity": "Revisión final e indicaciones para presentación y exposición"}
    ]',
    'draft',
    3
);

-- Asignar estudiantes al anteproyecto 2
INSERT INTO anteproject_students (anteproject_id, student_id, is_lead_author) VALUES
(2, 6, true);  -- Juan como autor principal

-- Asignar objetivos al anteproyecto 2
INSERT INTO anteproject_objectives (anteproject_id, objective_id) VALUES
(2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9);

-- =====================================================
-- 9. PROYECTO APROBADO DE EJEMPLO
-- =====================================================

-- Crear proyecto para el anteproyecto 1 (aprobado)
INSERT INTO projects (
    title, description, status, start_date, estimated_end_date, tutor_id, anteproject_id,
    github_repository_url
) VALUES (
    'Desarrollo de una aplicación móvil para gestión de tareas académicas',
    'Aplicación móvil multiplataforma para gestión de tareas académicas con funcionalidades avanzadas de organización y seguimiento.',
    'development',
    '2024-10-01',
    '2025-02-28',
    2,
    1,
    'https://github.com/sofia-jimenez/task-manager-app'
);

-- Actualizar el anteproyecto para marcar que tiene proyecto asociado
UPDATE anteprojects SET project_id = 1, status = 'approved' WHERE id = 1;

-- Asignar estudiantes al proyecto
INSERT INTO project_students (project_id, student_id, is_lead) VALUES
(1, 4, true),  -- Sofía como líder
(1, 5, false); -- David como colaborador

-- Crear milestones para el proyecto
INSERT INTO milestones (project_id, milestone_number, title, description, planned_date, status, milestone_type) VALUES
(1, 1, 'Análisis y Diseño', 'Análisis de requisitos y diseño de la arquitectura de la aplicación', '2024-10-15', 'completed', 'planning'),
(1, 2, 'Desarrollo Backend', 'Desarrollo del backend y API REST para la aplicación', '2024-11-30', 'in_progress', 'execution'),
(1, 3, 'Desarrollo Frontend', 'Desarrollo de la aplicación móvil multiplataforma', '2025-01-15', 'pending', 'execution'),
(1, 4, 'Pruebas y Despliegue', 'Pruebas exhaustivas, documentación y despliegue final', '2025-02-28', 'pending', 'final');

-- Crear tareas de ejemplo para el proyecto
INSERT INTO tasks (project_id, milestone_id, title, description, status, due_date, complexity, is_auto_generated, generation_source) VALUES
-- Milestone 1 (completado)
(1, 1, 'Análisis de requisitos funcionales', 'Identificar y documentar todos los requisitos funcionales de la aplicación', 'completed', '2024-10-10', 'medium', true, 'template'),
(1, 1, 'Diseño de la arquitectura del sistema', 'Diseñar la arquitectura general del sistema y sus componentes', 'completed', '2024-10-15', 'complex', true, 'template'),
(1, 1, 'Diseño de la base de datos', 'Crear el esquema de la base de datos y las relaciones entre entidades', 'completed', '2024-10-20', 'medium', true, 'template'),

-- Milestone 2 (en progreso)
(1, 2, 'Configuración del entorno de desarrollo', 'Configurar el entorno de desarrollo backend con las tecnologías seleccionadas', 'completed', '2024-11-05', 'simple', true, 'template'),
(1, 2, 'Desarrollo de la API REST', 'Implementar los endpoints de la API REST para todas las funcionalidades', 'in_progress', '2024-11-25', 'complex', true, 'template'),
(1, 2, 'Implementación de autenticación', 'Desarrollar el sistema de autenticación y autorización', 'pending', '2024-11-30', 'medium', true, 'template'),

-- Milestone 3 (pendiente)
(1, 3, 'Configuración del proyecto móvil', 'Configurar el proyecto de desarrollo móvil multiplataforma', 'pending', '2025-01-05', 'simple', true, 'template'),
(1, 3, 'Desarrollo de la interfaz de usuario', 'Crear las pantallas principales de la aplicación móvil', 'pending', '2025-01-10', 'medium', true, 'template'),
(1, 3, 'Integración con la API', 'Conectar la aplicación móvil con el backend desarrollado', 'pending', '2025-01-15', 'complex', true, 'template'),

-- Milestone 4 (pendiente)
(1, 4, 'Pruebas unitarias', 'Desarrollar y ejecutar pruebas unitarias para todos los componentes', 'pending', '2025-02-15', 'medium', true, 'template'),
(1, 4, 'Pruebas de integración', 'Realizar pruebas de integración entre frontend y backend', 'pending', '2025-02-20', 'medium', true, 'template'),
(1, 4, 'Documentación técnica', 'Elaborar la documentación técnica completa del proyecto', 'pending', '2025-02-25', 'simple', true, 'template'),
(1, 4, 'Despliegue y configuración', 'Desplegar la aplicación en producción y configurar el entorno', 'pending', '2025-02-28', 'medium', true, 'template');

-- Asignar tareas a estudiantes
INSERT INTO task_assignees (task_id, user_id, assigned_by) VALUES
-- Tareas asignadas a Sofía (líder del proyecto)
(1, 4, 2), (2, 4, 2), (3, 4, 2), (4, 4, 2), (5, 4, 2), (6, 4, 2),
-- Tareas asignadas a David (colaborador)
(7, 5, 2), (8, 5, 2), (9, 5, 2), (10, 5, 2), (11, 5, 2), (12, 5, 2), (13, 5, 2);

-- =====================================================
-- 10. COMENTARIOS DE EJEMPLO
-- =====================================================

-- Comentarios en tareas
INSERT INTO comments (task_id, author_id, content) VALUES
(1, 2, 'Excelente trabajo en el análisis de requisitos. Los casos de uso están bien definidos.'),
(1, 4, 'Gracias por la retroalimentación. He actualizado la documentación con los casos de uso adicionales.'),
(5, 2, 'El progreso en la API REST es muy bueno. Recuerda implementar validaciones robustas.'),
(5, 4, 'Perfecto, estoy trabajando en las validaciones y el manejo de errores.'),
(8, 2, 'Para la interfaz móvil, considera usar un diseño material design para mejor usabilidad.');

-- Comentario interno del tutor
INSERT INTO comments (task_id, author_id, content, is_internal) VALUES
(5, 2, 'Nota interna: El estudiante está progresando bien, pero necesita más práctica con las validaciones de entrada.', true);

-- =====================================================
-- 11. NOTIFICACIONES DE EJEMPLO
-- =====================================================

-- Notificaciones para Sofía
INSERT INTO notifications (user_id, type, title, message, action_url, read_at) VALUES
(4, 'project_approved', 'Proyecto aprobado', 'El anteproyecto ha sido aprobado. Puedes comenzar a definir tareas para el proyecto: Desarrollo de una aplicación móvil para gestión de tareas académicas', '/projects/1/tasks', NULL),
(4, 'task_assigned', 'Nueva tarea asignada', 'Se te ha asignado una nueva tarea: Análisis de requisitos funcionales', '/tasks/1', NULL),
(4, 'comment_added', 'Nuevo comentario en tarea', 'Se ha añadido un nuevo comentario en la tarea: Análisis de requisitos funcionales', '/tasks/1', CURRENT_TIMESTAMP);

-- Notificaciones para David
INSERT INTO notifications (user_id, type, title, message, action_url, read_at) VALUES
(5, 'project_approved', 'Proyecto aprobado', 'El anteproyecto ha sido aprobado. Puedes comenzar a definir tareas para el proyecto: Desarrollo de una aplicación móvil para gestión de tareas académicas', '/projects/1/tasks', NULL),
(5, 'task_assigned', 'Nueva tarea asignada', 'Se te ha asignado una nueva tarea: Configuración del proyecto móvil', '/tasks/7', NULL);

-- =====================================================
-- 12. EVALUACIONES DE ANTEPROYECTO DE EJEMPLO
-- =====================================================

-- Evaluación del anteproyecto 1 por el tutor
INSERT INTO anteproject_evaluations (anteproject_id, criteria_id, score, comments, evaluated_by) VALUES
(1, 1, 9.0, 'El proyecto es técnicamente viable con las tecnologías propuestas', 2),
(1, 2, 9.5, 'Los objetivos están muy bien alineados con las competencias del ciclo', 2),
(1, 3, 8.5, 'La descripción es clara y completa, aunque podría ser más específica en algunos aspectos', 2),
(1, 4, 9.0, 'La temporalización es realista y bien planificada', 2),
(1, 5, 9.0, 'Se ajusta perfectamente al tipo de proyecto de ejecución', 2),
(1, 6, 8.5, 'Los resultados esperados están bien definidos y son medibles', 2),
(1, 7, 7.5, 'El proyecto tiene elementos innovadores en la gestión de tareas académicas', 2),
(1, 8, 9.0, 'La aplicación será muy útil para la comunidad estudiantil', 2);

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE dam_objectives IS 'Objetivos del ciclo DAM cargados como datos iniciales';
COMMENT ON TABLE anteproject_evaluation_criteria IS 'Criterios de evaluación estándar para anteproyectos';
COMMENT ON TABLE pdf_templates IS 'Plantillas HTML para generar documentos PDF';
COMMENT ON TABLE system_settings IS 'Configuración inicial del sistema';
COMMENT ON TABLE users IS 'Usuarios de ejemplo: administrador, tutores y estudiantes';
COMMENT ON TABLE anteprojects IS 'Anteproyectos de ejemplo para demostración del sistema';
COMMENT ON TABLE projects IS 'Proyecto de ejemplo aprobado y en desarrollo';
COMMENT ON TABLE tasks IS 'Tareas de ejemplo generadas automáticamente para el proyecto';
COMMENT ON TABLE comments IS 'Comentarios de ejemplo para demostrar la funcionalidad';
COMMENT ON TABLE notifications IS 'Notificaciones de ejemplo para mostrar el sistema de alertas';
COMMENT ON TABLE anteproject_evaluations IS 'Evaluaciones de ejemplo del anteproyecto aprobado';
