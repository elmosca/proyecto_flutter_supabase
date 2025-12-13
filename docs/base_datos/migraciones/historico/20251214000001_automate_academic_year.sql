-- =====================================================
-- MIGRACIÓN: Automatización del Año Académico
-- Fecha: 2025-12-14
-- Descripción: Automatiza la actualización del año académico el 1 de septiembre
-- =====================================================

-- 1. Habilitar extensión pg_cron (necesario para tareas programadas)
-- Nota: Requiere permisos de superusuario o habilitación desde dashboard de Supabase
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 2. Función para actualizar el año académico automáticamente
CREATE OR REPLACE FUNCTION public.update_academic_year_automatically()
RETURNS void AS $$
DECLARE
    current_year INTEGER;
    next_year INTEGER;
    new_academic_year TEXT;
    admin_id INTEGER;
BEGIN
    -- Calcular el nuevo año académico (ej: 1 sept 2025 -> "2025-2026")
    current_year := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
    next_year := current_year + 1;
    new_academic_year := current_year || '-' || next_year;

    -- Obtener un ID de admin para el log (para satisfacer la clave foránea user_id NOT NULL)
    -- Si no hay admins, esto podría fallar si user_id es estricto, pero asumimos que siempre hay al menos uno.
    SELECT id INTO admin_id FROM users WHERE role = 'admin' LIMIT 1;

    -- Actualizar la configuración del sistema
    UPDATE system_settings
    SET 
        setting_value = new_academic_year,
        updated_at = NOW(),
        updated_by = admin_id -- Atribuimos el cambio al sistema (representado por un admin)
    WHERE setting_key = 'academic_year';

    -- Registrar la actividad en el log
    IF admin_id IS NOT NULL THEN
        INSERT INTO activity_log (user_id, action, entity_type, entity_id, new_values, created_at)
        VALUES (
            admin_id,
            'system_auto_update', 
            'system_setting', 
            (SELECT id FROM system_settings WHERE setting_key = 'academic_year'),
            json_build_object('academic_year', new_academic_year, 'source', 'pg_cron'),
            NOW()
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 3. Programar la tarea con pg_cron
-- Se ejecuta el 1 de septiembre a las 00:00
-- Sintaxis Cron: min hour day month day_of_week
-- Nota: Si ya existe un job con el mismo nombre, esto podría duplicarlo o fallar dependiendo de la versión.
-- Usamos unschedule primero por seguridad si se re-ejecuta.
SELECT cron.unschedule('auto_update_academic_year');

SELECT cron.schedule(
    'auto_update_academic_year', -- Nombre único de la tarea
    '0 0 1 9 *',                 -- Cron expression: 00:00 del 1 de Septiembre
    $$SELECT public.update_academic_year_automatically()$$
);

-- Comentario de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Automatización del año académico configurada para el 1 de septiembre';
END $$;

