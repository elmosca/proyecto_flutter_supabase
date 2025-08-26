-- Script para verificar las tablas del sistema TFG
-- Ejecutar: psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f verify_tables.sql

-- Verificar tablas principales
SELECT 'users' as table_name, COUNT(*) as record_count FROM users
UNION ALL
SELECT 'dam_objectives', COUNT(*) FROM dam_objectives
UNION ALL
SELECT 'anteprojects', COUNT(*) FROM anteprojects
UNION ALL
SELECT 'projects', COUNT(*) FROM projects
UNION ALL
SELECT 'milestones', COUNT(*) FROM milestones
UNION ALL
SELECT 'tasks', COUNT(*) FROM tasks
UNION ALL
SELECT 'comments', COUNT(*) FROM comments
UNION ALL
SELECT 'files', COUNT(*) FROM files
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL
SELECT 'system_settings', COUNT(*) FROM system_settings
UNION ALL
SELECT 'pdf_templates', COUNT(*) FROM pdf_templates
ORDER BY table_name;

-- Verificar tipos ENUM
SELECT typname as enum_type, enumlabel as enum_value
FROM pg_enum e
JOIN pg_type t ON e.enumtypid = t.oid
WHERE t.typname IN ('user_role', 'project_type', 'task_status', 'milestone_status')
ORDER BY typname, enumsortorder;

-- Verificar funciones
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('update_updated_at_column', 'validate_github_url', 'create_notification', 'get_project_stats')
ORDER BY routine_name;

-- Verificar triggers
SELECT trigger_name, event_object_table, event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;
