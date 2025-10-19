-- =====================================================
-- SCRIPT DE VERIFICACIÓN: RLS Habilitado en Todas las Tablas
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Verificar que RLS está habilitado en todas las tablas críticas
-- Uso: Ejecutar después de aplicar todas las migraciones de RLS

-- =====================================================
-- 1. VERIFICACIÓN DE RLS HABILITADO
-- =====================================================

-- Verificar que RLS está habilitado en todas las tablas críticas
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled,
    CASE 
        WHEN rowsecurity = true THEN '✅ RLS HABILITADO'
        ELSE '❌ RLS DESHABILITADO'
    END as estado
FROM pg_tables 
WHERE schemaname = 'public'
    AND tablename IN (
        'users', 'anteprojects', 'anteproject_students',
        'projects', 'project_students', 'milestones',
        'tasks', 'task_assignees', 'comments',
        'files', 'notifications'
    )
ORDER BY tablename;

-- =====================================================
-- 2. VERIFICACIÓN DE POLÍTICAS ACTIVAS
-- =====================================================

-- Verificar políticas activas por tabla
SELECT 
    tablename,
    COUNT(*) as total_politicas,
    STRING_AGG(policyname, ', ' ORDER BY policyname) as politicas
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename IN (
        'users', 'anteprojects', 'anteproject_students',
        'projects', 'project_students', 'milestones',
        'tasks', 'task_assignees', 'comments',
        'files', 'notifications'
    )
GROUP BY tablename
ORDER BY tablename;

-- =====================================================
-- 3. VERIFICACIÓN DE POLÍTICAS TEMPORALES
-- =====================================================

-- Verificar que las políticas temporales de desarrollo están activas
SELECT 
    tablename,
    policyname,
    cmd as command,
    CASE 
        WHEN policyname LIKE 'Development access%' THEN '⚠️ TEMPORAL'
        ELSE '✅ PERMANENTE'
    END as tipo_politica
FROM pg_policies
WHERE schemaname = 'public'
    AND policyname LIKE 'Development access%'
ORDER BY tablename;

-- =====================================================
-- 4. VERIFICACIÓN DE ACCESO A DATOS
-- =====================================================

-- Verificar que los datos siguen siendo accesibles
SELECT 
    'users' as tabla, COUNT(*) as registros_accesibles FROM users
UNION ALL
SELECT 'anteprojects', COUNT(*) FROM anteprojects
UNION ALL
SELECT 'anteproject_students', COUNT(*) FROM anteproject_students
UNION ALL
SELECT 'projects', COUNT(*) FROM projects
UNION ALL
SELECT 'project_students', COUNT(*) FROM project_students
UNION ALL
SELECT 'milestones', COUNT(*) FROM milestones
UNION ALL
SELECT 'tasks', COUNT(*) FROM tasks
UNION ALL
SELECT 'task_assignees', COUNT(*) FROM task_assignees
UNION ALL
SELECT 'comments', COUNT(*) FROM comments
UNION ALL
SELECT 'files', COUNT(*) FROM files
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications
ORDER BY tabla;

-- =====================================================
-- 5. RESUMEN DE ESTADO
-- =====================================================

-- Contar tablas con RLS habilitado
SELECT 
    COUNT(*) as total_tablas_criticas,
    SUM(CASE WHEN rowsecurity = true THEN 1 ELSE 0 END) as tablas_con_rls,
    SUM(CASE WHEN rowsecurity = false THEN 1 ELSE 0 END) as tablas_sin_rls
FROM pg_tables 
WHERE schemaname = 'public'
    AND tablename IN (
        'users', 'anteprojects', 'anteproject_students',
        'projects', 'project_students', 'milestones',
        'tasks', 'task_assignees', 'comments',
        'files', 'notifications'
    );

-- =====================================================
-- 6. VERIFICACIÓN DE FUNCIONES DE AUTENTICACIÓN
-- =====================================================

-- Verificar que las funciones de autenticación existen
SELECT 
    routine_name as funcion,
    routine_type as tipo,
    CASE 
        WHEN routine_name IS NOT NULL THEN '✅ DISPONIBLE'
        ELSE '❌ NO ENCONTRADA'
    END as estado
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND routine_name IN (
        'user_id', 'user_role', 'is_admin', 
        'is_tutor', 'is_student', 'is_project_tutor',
        'is_project_student', 'is_anteproject_tutor', 'is_anteproject_author'
    )
ORDER BY routine_name;

-- =====================================================
-- 7. MENSAJE FINAL
-- =====================================================

DO $$
DECLARE
    tablas_con_rls INTEGER;
    total_tablas INTEGER;
BEGIN
    -- Contar tablas con RLS habilitado
    SELECT 
        COUNT(*),
        SUM(CASE WHEN rowsecurity = true THEN 1 ELSE 0 END)
    INTO total_tablas, tablas_con_rls
    FROM pg_tables 
    WHERE schemaname = 'public'
        AND tablename IN (
            'users', 'anteprojects', 'anteproject_students',
            'projects', 'project_students', 'milestones',
            'tasks', 'task_assignees', 'comments',
            'files', 'notifications'
        );
    
    -- Mostrar resultado
    IF tablas_con_rls = total_tablas THEN
        RAISE NOTICE '🎉 VERIFICACIÓN EXITOSA: Todas las % tablas tienen RLS habilitado', total_tablas;
        RAISE NOTICE '✅ 22 errores críticos de Supabase deberían estar resueltos';
        RAISE NOTICE '⚠️  Recordar eliminar políticas temporales cuando JWT esté activo';
    ELSE
        RAISE NOTICE '❌ VERIFICACIÓN FALLIDA: % de % tablas tienen RLS habilitado', tablas_con_rls, total_tablas;
        RAISE NOTICE '🔍 Revisar las tablas sin RLS en el resultado anterior';
    END IF;
END $$;
