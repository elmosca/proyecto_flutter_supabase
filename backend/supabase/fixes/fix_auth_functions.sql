-- =====================================================
-- CORRECCIÓN: Funciones de Autenticación
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- Corregir función simulate_login con variables ambiguas
CREATE OR REPLACE FUNCTION public.simulate_login(user_email TEXT, user_password TEXT)
RETURNS JSON AS $$
DECLARE
    user_record RECORD;
    jwt_claims JSON;
BEGIN
    -- Verificar credenciales (en producción, verificar hash)
    SELECT id, email, role, full_name INTO user_record
    FROM users 
    WHERE email = user_email 
    AND password_hash = user_password  -- En producción, verificar hash
    AND status = 'active';
    
    IF NOT FOUND THEN
        RETURN json_build_object('error', 'Invalid credentials');
    END IF;
    
    -- Generar JWT claims
    jwt_claims := public.generate_jwt_claims(user_email);
    
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

-- Corregir función is_project_student con variable ambigua
CREATE OR REPLACE FUNCTION public.is_project_student(project_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM project_students 
        WHERE project_students.project_id = project_id AND student_id = public.user_id()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Funciones de autenticación corregidas exitosamente';
    RAISE NOTICE 'Variables ambiguas resueltas';
END $$;
