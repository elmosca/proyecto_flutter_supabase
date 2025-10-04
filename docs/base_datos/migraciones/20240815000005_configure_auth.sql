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
