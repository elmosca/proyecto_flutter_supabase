-- Función de login corregida para verificar contraseñas hasheadas
CREATE OR REPLACE FUNCTION public.login_user(user_email TEXT, user_password TEXT)
RETURNS JSON AS $$
DECLARE
    user_record RECORD;
BEGIN
    -- Buscar usuario por email
    SELECT id, email, role, full_name, password_hash, status 
    INTO user_record
    FROM users 
    WHERE email = user_email;
    
    -- Verificar si el usuario existe
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false, 
            'error', 'Usuario no encontrado'
        );
    END IF;
    
    -- Verificar si el usuario está activo
    IF user_record.status != 'active' THEN
        RETURN json_build_object(
            'success', false, 
            'error', 'Usuario inactivo'
        );
    END IF;
    
    -- Verificar contraseña usando crypt
    IF crypt(user_password, user_record.password_hash) = user_record.password_hash THEN
        RETURN json_build_object(
            'success', true,
            'user', json_build_object(
                'id', user_record.id,
                'email', user_record.email,
                'role', user_record.role,
                'full_name', user_record.full_name
            )
        );
    ELSE
        RETURN json_build_object(
            'success', false, 
            'error', 'Contraseña incorrecta'
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
