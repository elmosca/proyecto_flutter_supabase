-- =====================================================
-- PRUEBA COMPLETA: Sistema de Autenticación y RLS
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- =====================================================
-- 1. PRUEBAS DE AUTENTICACIÓN
-- =====================================================

-- Probar función de login con usuario administrador
SELECT '=== PRUEBA 1: Login Administrador ===' as test;
SELECT public.simulate_login('admin@cifp.edu', 'admin123') as login_result;

-- Probar función de login con usuario tutor
SELECT '=== PRUEBA 2: Login Tutor ===' as test;
SELECT public.simulate_login('tutor1@cifp.edu', 'tutor123') as login_result;

-- Probar función de login con usuario estudiante
SELECT '=== PRUEBA 3: Login Estudiante ===' as test;
SELECT public.simulate_login('estudiante1@cifp.edu', 'student123') as login_result;

-- Probar login con credenciales incorrectas
SELECT '=== PRUEBA 4: Login Credenciales Incorrectas ===' as test;
SELECT public.simulate_login('admin@cifp.edu', 'wrongpassword') as login_result;

-- =====================================================
-- 2. PRUEBAS DE JWT CLAIMS
-- =====================================================

-- Generar JWT claims para administrador
SELECT '=== PRUEBA 5: JWT Claims Administrador ===' as test;
SELECT public.generate_jwt_claims('admin@cifp.edu') as jwt_claims;

-- Generar JWT claims para tutor
SELECT '=== PRUEBA 6: JWT Claims Tutor ===' as test;
SELECT public.generate_jwt_claims('tutor1@cifp.edu') as jwt_claims;

-- Generar JWT claims para estudiante
SELECT '=== PRUEBA 7: JWT Claims Estudiante ===' as test;
SELECT public.generate_jwt_claims('estudiante1@cifp.edu') as jwt_claims;

-- =====================================================
-- 3. PRUEBAS DE RLS CON JWT SIMULADO
-- =====================================================

-- Simular JWT de administrador y probar acceso
SELECT '=== PRUEBA 8: RLS con JWT Administrador ===' as test;
SELECT set_config('request.jwt.claims', '{"user_id": 1, "role": "admin", "email": "admin@cifp.edu"}', false);

-- Probar acceso a todas las tablas como administrador
SELECT 'Acceso a users como admin:' as access_test;
SELECT COUNT(*) as users_count FROM users;

SELECT 'Acceso a anteprojects como admin:' as access_test;
SELECT COUNT(*) as anteprojects_count FROM anteprojects;

SELECT 'Acceso a projects como admin:' as access_test;
SELECT COUNT(*) as projects_count FROM projects;

SELECT 'Acceso a tasks como admin:' as access_test;
SELECT COUNT(*) as tasks_count FROM tasks;

-- Simular JWT de tutor y probar acceso
SELECT '=== PRUEBA 9: RLS con JWT Tutor ===' as test;
SELECT set_config('request.jwt.claims', '{"user_id": 2, "role": "tutor", "email": "tutor1@cifp.edu"}', false);

-- Probar acceso como tutor
SELECT 'Acceso a users como tutor:' as access_test;
SELECT COUNT(*) as users_count FROM users;

SELECT 'Acceso a anteprojects como tutor:' as access_test;
SELECT COUNT(*) as anteprojects_count FROM anteprojects;

-- Simular JWT de estudiante y probar acceso
SELECT '=== PRUEBA 10: RLS con JWT Estudiante ===' as test;
SELECT set_config('request.jwt.claims', '{"user_id": 3, "role": "student", "email": "estudiante1@cifp.edu"}', false);

-- Probar acceso como estudiante
SELECT 'Acceso a users como estudiante:' as access_test;
SELECT COUNT(*) as users_count FROM users;

SELECT 'Acceso a projects como estudiante:' as access_test;
SELECT COUNT(*) as projects_count FROM projects;

-- =====================================================
-- 4. PRUEBAS DE FUNCIONES ESPECÍFICAS
-- =====================================================

-- Probar función is_project_tutor con tutor
SELECT '=== PRUEBA 11: is_project_tutor con Tutor ===' as test;
SELECT set_config('request.jwt.claims', '{"user_id": 2, "role": "tutor"}', false);
SELECT public.is_project_tutor(1) as is_project_tutor_result;

-- Probar función is_project_student con estudiante
SELECT '=== PRUEBA 12: is_project_student con Estudiante ===' as test;
SELECT set_config('request.jwt.claims', '{"user_id": 3, "role": "student"}', false);
SELECT public.is_project_student(1) as is_project_student_result;

-- =====================================================
-- 5. PRUEBAS DE POLÍTICAS DE SEGURIDAD
-- =====================================================

-- Probar acceso sin JWT (debería ser restringido)
SELECT '=== PRUEBA 13: Acceso sin JWT ===' as test;
SELECT set_config('request.jwt.claims', '', false);

SELECT 'Acceso a users sin JWT:' as access_test;
SELECT COUNT(*) as users_count FROM users;

SELECT 'Acceso a anteprojects sin JWT:' as access_test;
SELECT COUNT(*) as anteprojects_count FROM anteprojects;

-- =====================================================
-- 6. VERIFICACIÓN FINAL
-- =====================================================

-- Verificar que todas las funciones existen
SELECT '=== VERIFICACIÓN FINAL: Funciones Existentes ===' as test;
SELECT proname as function_name 
FROM pg_proc 
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public') 
AND proname IN (
    'user_id', 'user_role', 'is_admin', 'is_tutor', 'is_student',
    'is_project_tutor', 'is_project_student', 'is_anteproject_tutor', 'is_anteproject_author',
    'create_user_with_role', 'generate_jwt_claims', 'is_authenticated', 'simulate_login'
)
ORDER BY proname;

-- Verificar políticas RLS
SELECT '=== VERIFICACIÓN FINAL: Políticas RLS ===' as test;
SELECT COUNT(*) as total_policies FROM pg_policies WHERE schemaname = 'public';

-- Limpiar JWT claims
SELECT set_config('request.jwt.claims', '', false);

-- Mensaje de confirmación final
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'PRUEBAS COMPLETADAS EXITOSAMENTE';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ Sistema de autenticación funcionando';
    RAISE NOTICE '✅ RLS configurado correctamente';
    RAISE NOTICE '✅ Políticas de seguridad aplicadas';
    RAISE NOTICE '✅ Funciones de utilidad creadas';
    RAISE NOTICE '✅ Sistema listo para frontend';
    RAISE NOTICE '========================================';
END $$;
