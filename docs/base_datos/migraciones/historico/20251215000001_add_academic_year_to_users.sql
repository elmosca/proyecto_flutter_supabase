-- =====================================================
-- MIGRACIÓN: Agregar campo academic_year a la tabla users
-- Fecha: 2025-12-15
-- Descripción: Agrega el campo academic_year a la tabla users para
--              permitir el control de permisos de escritura basado
--              en el año académico. Incluye trigger para asignación
--              automática a nuevos estudiantes.
-- =====================================================

-- =====================================================
-- 1. AGREGAR COLUMNA academic_year A LA TABLA users
-- =====================================================

-- Agregar la columna (nullable para compatibilidad con tutores y admins)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS academic_year VARCHAR(20) NULL;

-- Agregar comentario descriptivo
COMMENT ON COLUMN users.academic_year IS 
    'Año académico del estudiante (ej: "2025-2026"). Usado para control de permisos de escritura. NULL para tutores y administradores.';

-- Crear índice para optimizar consultas por año académico
CREATE INDEX IF NOT EXISTS idx_users_academic_year ON users(academic_year);

-- =====================================================
-- 2. CREAR FUNCIÓN PARA ASIGNAR AÑO ACADÉMICO AUTOMÁTICAMENTE
-- =====================================================

-- Función que asigna el año académico vigente a nuevos estudiantes
CREATE OR REPLACE FUNCTION assign_academic_year_to_student()
RETURNS TRIGGER AS $$
DECLARE
    active_academic_year TEXT;
BEGIN
    -- Solo procesar si es un estudiante y no tiene año académico asignado
    IF NEW.role = 'student' AND (NEW.academic_year IS NULL OR NEW.academic_year = '') THEN
        -- Obtener el año académico activo del sistema
        SELECT setting_value INTO active_academic_year
        FROM system_settings
        WHERE setting_key = 'academic_year'
        LIMIT 1;
        
        -- Si hay año activo, asignarlo al estudiante
        IF active_academic_year IS NOT NULL AND active_academic_year != '' THEN
            NEW.academic_year := active_academic_year;
            RAISE NOTICE 'Año académico % asignado automáticamente al estudiante %', 
                active_academic_year, NEW.email;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Comentario para la función
COMMENT ON FUNCTION assign_academic_year_to_student() IS 
    'Asigna automáticamente el año académico vigente del sistema a nuevos estudiantes que no tengan año asignado.';

-- =====================================================
-- 3. CREAR TRIGGER PARA ASIGNACIÓN AUTOMÁTICA
-- =====================================================

-- Eliminar trigger si existe (para poder recrearlo)
DROP TRIGGER IF EXISTS assign_academic_year_trigger ON users;

-- Crear trigger que se ejecuta antes de insertar un nuevo usuario
CREATE TRIGGER assign_academic_year_trigger
    BEFORE INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION assign_academic_year_to_student();

-- =====================================================
-- 4. ACTUALIZAR ESTUDIANTES EXISTENTES SIN AÑO ACADÉMICO
-- =====================================================

-- Actualizar todos los estudiantes que no tienen año académico asignado
-- con el año académico vigente del sistema
DO $$
DECLARE
    active_academic_year TEXT;
    updated_count INTEGER;
BEGIN
    -- Obtener el año académico activo del sistema
    SELECT setting_value INTO active_academic_year
    FROM system_settings
    WHERE setting_key = 'academic_year'
    LIMIT 1;
    
    -- Si hay año activo, actualizar estudiantes sin año asignado
    IF active_academic_year IS NOT NULL AND active_academic_year != '' THEN
        UPDATE users
        SET academic_year = active_academic_year,
            updated_at = CURRENT_TIMESTAMP
        WHERE role = 'student' 
          AND (academic_year IS NULL OR academic_year = '');
        
        GET DIAGNOSTICS updated_count = ROW_COUNT;
        
        RAISE NOTICE 'Migración completada: % estudiantes actualizados con año académico %', 
            updated_count, active_academic_year;
    ELSE
        RAISE NOTICE 'No se encontró año académico activo en system_settings. Los estudiantes existentes no fueron actualizados.';
    END IF;
END $$;

-- =====================================================
-- 5. VERIFICACIÓN DE LA MIGRACIÓN
-- =====================================================

-- Consulta de verificación (comentada, ejecutar manualmente si se desea)
-- SELECT 
--     role,
--     academic_year,
--     COUNT(*) as total
-- FROM users
-- GROUP BY role, academic_year
-- ORDER BY role, academic_year;

-- =====================================================
-- FIN DE LA MIGRACIÓN
-- =====================================================
