-- ============================================================================
-- Función RPC para resetear contraseñas de estudiantes
-- ============================================================================
-- Esta función permite a tutores y administradores resetear contraseñas
-- de estudiantes usando una función RPC que llama a la API Admin de Supabase
--
-- IMPORTANTE: 
-- 1. Requiere la extensión pg_net instalada
-- 2. Requiere configurar SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY como secrets
-- 3. El usuario debe tener permisos adecuados (admin o tutor del estudiante)
-- ============================================================================

-- Verificar que pg_net está instalado (requerido para hacer peticiones HTTP)
-- Si no está instalado, ejecutar: CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION reset_student_password(
  p_student_email TEXT,
  p_new_password TEXT,
  p_reset_by_user_id INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_student_id INTEGER;
  v_student_role TEXT;
  v_reset_by_role TEXT;
  v_tutor_id INTEGER;
  v_auth_user_id UUID;
  v_supabase_url TEXT;
  v_service_role_key TEXT;
  v_request_body JSONB;
  v_response JSONB;
  v_http_response RECORD;
BEGIN
  -- Verificar que el usuario que resetea existe y obtener su rol
  SELECT role INTO v_reset_by_role
  FROM users
  WHERE id = p_reset_by_user_id;
  
  IF v_reset_by_role IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuario que resetea no encontrado'
    );
  END IF;
  
  -- Verificar que el usuario es admin o tutor
  IF v_reset_by_role NOT IN ('admin', 'tutor') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Solo administradores y tutores pueden resetear contraseñas'
    );
  END IF;
  
  -- Verificar que el estudiante existe y obtener su información
  SELECT id, role, tutor_id INTO v_student_id, v_student_role, v_tutor_id
  FROM users
  WHERE email = p_student_email AND role = 'student';
  
  IF v_student_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Estudiante no encontrado'
    );
  END IF;
  
  -- Si no es admin, verificar que es tutor del estudiante
  IF v_reset_by_role = 'tutor' AND v_tutor_id != p_reset_by_user_id THEN
    RETURN json_build_object(
      'success', false,
      'error', 'No tienes permisos para resetear la contraseña de este estudiante'
    );
  END IF;
  
  -- Obtener el auth.users.id del estudiante
  SELECT id INTO v_auth_user_id
  FROM auth.users
  WHERE email = p_student_email;
  
  IF v_auth_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuario no encontrado en Supabase Auth. Asegúrate de que el estudiante tenga una cuenta activa.'
    );
  END IF;
  
  -- Obtener configuración de Supabase desde variables de entorno/secrets
  -- Nota: Estas deben estar configuradas en Supabase Dashboard → Settings → Edge Functions → Secrets
  -- O usar current_setting si están configuradas como variables de sesión
  v_supabase_url := current_setting('app.supabase_url', true);
  v_service_role_key := current_setting('app.supabase_service_role_key', true);
  
  -- Si no están configuradas, intentar obtenerlas de vault (Supabase Secrets)
  -- Nota: Esto requiere que estén configuradas en Supabase
  IF v_supabase_url IS NULL OR v_service_role_key IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Configuración de Supabase no encontrada. Por favor, usa la Edge Function super-action en su lugar.'
    );
  END IF;
  
  -- Construir el cuerpo de la petición para la API Admin de Supabase
  v_request_body := jsonb_build_object(
    'password', p_new_password
  );
  
  -- Llamar a la API Admin de Supabase usando pg_net
  SELECT * INTO v_http_response
  FROM net.http_post(
    url := v_supabase_url || '/auth/v1/admin/users/' || v_auth_user_id,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_service_role_key,
      'apikey', v_service_role_key
    ),
    body := v_request_body::text
  );
  
  -- Verificar la respuesta
  IF v_http_response.status_code != 200 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Error al actualizar contraseña en Supabase Auth. Código: ' || v_http_response.status_code
    );
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'message', 'Contraseña actualizada exitosamente',
    'student_id', v_student_id,
    'auth_user_id', v_auth_user_id
  );
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Error inesperado: ' || SQLERRM
    );
END;
$$;

-- Otorgar permisos a los roles necesarios
GRANT EXECUTE ON FUNCTION reset_student_password(TEXT, TEXT, INTEGER) TO authenticated;

-- Comentario de la función
COMMENT ON FUNCTION reset_student_password IS 'Resetea la contraseña de un estudiante. Solo puede ser usado por administradores o tutores del estudiante.';

