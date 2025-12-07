-- Script de Verificación: Estado Actual de RLS
-- Este script NO hace cambios, solo muestra el estado actual
-- Ejecutar ANTES de habilitar RLS para entender el impacto

-- ============================================
-- 1. VERIFICAR ESTADO DE RLS EN TABLAS
-- ============================================
SELECT 
    tablename,
    rowsecurity as rls_enabled,
    CASE 
        WHEN rowsecurity THEN '✅ RLS Habilitado'
        ELSE '❌ RLS Deshabilitado'
    END as estado
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename IN (
        'anteprojects', 'anteproject_students', 'users', 
        'projects', 'project_students', 'tasks', 
        'task_assignees', 'milestones', 'files', 
        'notifications', 'comments', 'schedules'
    )
ORDER BY tablename;

-- ============================================
-- 2. CONTAR POLÍTICAS POR TABLA
-- ============================================
SELECT 
    tablename,
    COUNT(*) as total_politicas,
    COUNT(CASE WHEN cmd = 'SELECT' THEN 1 END) as select_policies,
    COUNT(CASE WHEN cmd = 'INSERT' THEN 1 END) as insert_policies,
    COUNT(CASE WHEN cmd = 'UPDATE' THEN 1 END) as update_policies,
    COUNT(CASE WHEN cmd = 'DELETE' THEN 1 END) as delete_policies,
    COUNT(CASE WHEN cmd = 'ALL' THEN 1 END) as all_policies,
    COUNT(CASE WHEN policyname LIKE '%Development%' THEN 1 END) as development_policies
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename IN (
        'anteprojects', 'anteproject_students', 'users', 
        'projects', 'project_students', 'tasks', 
        'task_assignees', 'milestones', 'files', 
        'notifications', 'comments', 'schedules'
    )
GROUP BY tablename
ORDER BY tablename;

-- ============================================
-- 3. IDENTIFICAR POLÍTICAS "DEVELOPMENT ACCESS"
-- ============================================
SELECT 
    tablename,
    policyname,
    cmd,
    qual,
    CASE 
        WHEN qual = 'true' THEN '⚠️ PERMITE TODO - RIESGO ALTO'
        ELSE '✅ Restringida'
    END as riesgo
FROM pg_policies
WHERE schemaname = 'public' 
    AND policyname LIKE '%Development%'
ORDER BY tablename;

-- ============================================
-- 4. VERIFICAR FUNCIONES HELPER
-- ============================================
SELECT 
    proname as function_name,
    CASE 
        WHEN prosecdef THEN '✅ SECURITY DEFINER'
        ELSE '❌ No es SECURITY DEFINER'
    END as security_definer,
    CASE 
        WHEN proconfig IS NULL OR NOT ('{search_path=public,pg_temp}' = ANY(proconfig)) THEN '⚠️ search_path no configurado'
        ELSE '✅ search_path configurado'
    END as search_path_status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
    AND proname IN (
        'user_id', 'user_role', 'is_admin', 
        'is_tutor', 'is_student', 'is_project_tutor',
        'is_project_student', 'is_anteproject_tutor',
        'is_anteproject_author'
    )
ORDER BY proname;

-- ============================================
-- 5. VERIFICAR POLÍTICAS POR ROL
-- ============================================
SELECT 
    tablename,
    policyname,
    cmd,
    roles,
    CASE 
        WHEN 'public' = ANY(roles) THEN '✅ Aplica a todos los usuarios autenticados'
        WHEN 'authenticated' = ANY(roles) THEN '✅ Aplica a usuarios autenticados'
        ELSE '⚠️ Roles específicos'
    END as alcance
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename IN (
        'anteprojects', 'anteproject_students', 'users', 
        'projects', 'tasks'
    )
ORDER BY tablename, cmd, policyname;

-- ============================================
-- 6. RESUMEN DE RIESGOS
-- ============================================
WITH rls_status AS (
    SELECT 
        COUNT(*) FILTER (WHERE rowsecurity) as tablas_con_rls,
        COUNT(*) FILTER (WHERE NOT rowsecurity) as tablas_sin_rls,
        COUNT(*) as total_tablas
    FROM pg_tables 
    WHERE schemaname = 'public' 
        AND tablename IN (
            'anteprojects', 'anteproject_students', 'users', 
            'projects', 'project_students', 'tasks', 
            'task_assignees', 'milestones', 'files', 
            'notifications', 'comments', 'schedules'
        )
),
development_policies AS (
    SELECT COUNT(*) as total_development_policies
    FROM pg_policies
    WHERE schemaname = 'public' 
        AND policyname LIKE '%Development%'
        AND qual = 'true'
),
helper_functions AS (
    SELECT 
        COUNT(*) FILTER (WHERE prosecdef) as funciones_security_definer,
        COUNT(*) FILTER (WHERE proconfig IS NULL OR NOT ('{search_path=public,pg_temp}' = ANY(proconfig))) as funciones_sin_search_path,
        COUNT(*) as total_funciones
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
        AND proname IN (
            'user_id', 'user_role', 'is_admin', 
            'is_tutor', 'is_student'
        )
)
SELECT 
    '📊 RESUMEN DE ESTADO' as seccion,
    rls_status.tablas_sin_rls || ' tablas sin RLS habilitado' as estado_rls,
    development_policies.total_development_policies || ' políticas de desarrollo activas' as politicas_desarrollo,
    helper_functions.funciones_sin_search_path || ' funciones sin search_path configurado' as funciones_riesgo,
    CASE 
        WHEN rls_status.tablas_sin_rls > 0 THEN '🔴 CRÍTICO: RLS deshabilitado en tablas públicas'
        ELSE '✅ RLS habilitado'
    END as riesgo_principal
FROM rls_status, development_policies, helper_functions;

-- ============================================
-- 7. RECOMENDACIONES
-- ============================================
SELECT 
    '📋 RECOMENDACIONES' as tipo,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_tables 
            WHERE schemaname = 'public' 
            AND tablename IN ('anteprojects', 'users', 'projects')
            AND NOT rowsecurity
        ) THEN '1. Habilitar RLS en tablas principales (anteprojects, users, projects)'
        ELSE '✅ RLS ya habilitado en tablas principales'
    END as recomendacion_1,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE schemaname = 'public' 
            AND policyname LIKE '%Development%'
            AND qual = 'true'
        ) THEN '2. Eliminar o restringir políticas "Development access" antes de producción'
        ELSE '✅ Políticas de desarrollo ya restringidas'
    END as recomendacion_2,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'public'
            AND proname IN ('user_id', 'is_admin')
            AND (proconfig IS NULL OR NOT ('{search_path=public,pg_temp}' = ANY(proconfig)))
        ) THEN '3. Corregir search_path en funciones helper (user_id, is_admin, etc.)'
        ELSE '✅ Funciones helper ya corregidas'
    END as recomendacion_3;

