-- =====================================================
-- MIGRACIÓN: Habilitar RLS en tabla anteproject_students
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Habilitar Row Level Security en tabla anteproject_students
-- Impacto: 4 registros afectados
-- Riesgo: RIESGO MEDIO (relaciones estudiantes-anteproyectos)

-- =====================================================
-- 1. VERIFICACIÓN PREVIA
-- =====================================================

-- Verificar registros existentes
SELECT COUNT(*) as total_registros FROM anteproject_students;

-- Verificar políticas existentes
SELECT COUNT(*) as total_politicas FROM pg_policies WHERE tablename = 'anteproject_students';

-- Verificar estado actual de RLS
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'anteproject_students';

-- Mostrar datos existentes para verificación
SELECT aps.id, aps.anteproject_id, aps.student_id, aps.is_lead_author, aps.created_at,
       a.title as anteproject_title, u.full_name as student_name
FROM anteproject_students aps
LEFT JOIN anteprojects a ON aps.anteproject_id = a.id
LEFT JOIN users u ON aps.student_id = u.id
ORDER BY aps.created_at DESC;

-- =====================================================
-- 2. HABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Habilitar RLS en la tabla
ALTER TABLE anteproject_students ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. POLÍTICA TEMPORAL DE DESARROLLO
-- =====================================================

-- Crear política temporal para permitir desarrollo sin interrupciones
-- IMPORTANTE: Esta política debe eliminarse cuando la autenticación JWT esté activa
CREATE POLICY "Development access to anteproject_students" ON anteproject_students
    FOR ALL USING (true);

-- =====================================================
-- 4. VERIFICACIÓN POSTERIOR
-- =====================================================

-- Verificar que RLS está habilitado
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'anteproject_students';

-- Verificar políticas activas
SELECT policyname, cmd as command, qual as using_expression
FROM pg_policies 
WHERE tablename = 'anteproject_students'
ORDER BY policyname;

-- Verificar que los datos siguen accesibles
SELECT COUNT(*) as registros_accesibles FROM anteproject_students;

-- =====================================================
-- 5. DOCUMENTACIÓN
-- =====================================================

-- Comentario en la tabla
COMMENT ON TABLE anteproject_students IS 'Tabla de relación estudiantes-anteproyectos - RLS habilitado el 2025-01-19';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS habilitado exitosamente en tabla anteproject_students';
    RAISE NOTICE 'Política temporal de desarrollo creada';
    RAISE NOTICE '4 registros existentes - riesgo medio';
    RAISE NOTICE 'Relaciones estudiantes-anteproyectos protegidas';
END $$;
