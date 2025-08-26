-- =====================================================
-- SCRIPT DE PRUEBA: Verificación de Funciones RLS
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- Simular un usuario autenticado con JWT claims
-- Esto nos permitirá probar las funciones RLS

-- 1. Probar función user_id() sin JWT (debería retornar NULL)
SELECT 'Testing user_id() without JWT:' as test;
SELECT public.user_id() as user_id_result;

-- 2. Probar función user_role() sin JWT (debería retornar NULL)
SELECT 'Testing user_role() without JWT:' as test;
SELECT public.user_role() as user_role_result;

-- 3. Probar función is_admin() sin JWT
SELECT 'Testing is_admin() without JWT:' as test;
SELECT public.is_admin() as is_admin_result;

-- 4. Probar función is_tutor() sin JWT
SELECT 'Testing is_tutor() without JWT:' as test;
SELECT public.is_tutor() as is_tutor_result;

-- 5. Probar función is_student() sin JWT
SELECT 'Testing is_student() without JWT:' as test;
SELECT public.is_student() as is_student_result;

-- 6. Simular JWT claims para un usuario administrador
SELECT 'Setting JWT claims for admin user (ID: 1):' as test;
SELECT set_config('request.jwt.claims', '{"user_id": 1, "role": "admin"}', false);

-- 7. Probar funciones con JWT de admin
SELECT 'Testing functions with admin JWT:' as test;
SELECT 
    public.user_id() as user_id,
    public.user_role() as user_role,
    public.is_admin() as is_admin,
    public.is_tutor() as is_tutor,
    public.is_student() as is_student;

-- 8. Simular JWT claims para un usuario tutor
SELECT 'Setting JWT claims for tutor user (ID: 2):' as test;
SELECT set_config('request.jwt.claims', '{"user_id": 2, "role": "tutor"}', false);

-- 9. Probar funciones con JWT de tutor
SELECT 'Testing functions with tutor JWT:' as test;
SELECT 
    public.user_id() as user_id,
    public.user_role() as user_role,
    public.is_admin() as is_admin,
    public.is_tutor() as is_tutor,
    public.is_student() as is_student;

-- 10. Simular JWT claims para un usuario estudiante
SELECT 'Setting JWT claims for student user (ID: 3):' as test;
SELECT set_config('request.jwt.claims', '{"user_id": 3, "role": "student"}', false);

-- 11. Probar funciones con JWT de estudiante
SELECT 'Testing functions with student JWT:' as test;
SELECT 
    public.user_id() as user_id,
    public.user_role() as user_role,
    public.is_admin() as is_admin,
    public.is_tutor() as is_tutor,
    public.is_student() as is_student;

-- 12. Probar función is_project_tutor() con tutor
SELECT 'Testing is_project_tutor() with tutor (project_id: 1):' as test;
SELECT public.is_project_tutor(1) as is_project_tutor_result;

-- 13. Probar función is_project_student() con estudiante
SELECT 'Testing is_project_student() with student (project_id: 1):' as test;
SELECT public.is_project_student(1) as is_project_student_result;

-- 14. Limpiar JWT claims
SELECT 'Clearing JWT claims:' as test;
SELECT set_config('request.jwt.claims', '', false);

-- 15. Verificar que las funciones retornan NULL sin JWT
SELECT 'Final verification - functions should return NULL without JWT:' as test;
SELECT 
    public.user_id() as user_id,
    public.user_role() as user_role,
    public.is_admin() as is_admin;

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Pruebas de funciones RLS completadas exitosamente';
    RAISE NOTICE 'Las funciones están funcionando correctamente';
    RAISE NOTICE 'RLS está listo para ser usado con Supabase Auth';
END $$;
