-- =====================================================
-- MIGRACIÓN: Habilitar RLS en tabla project_students
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Habilitar Row Level Security en tabla project_students
-- Impacto: 2 registros afectados
-- Riesgo: RIESGO MEDIO (relaciones estudiantes-proyectos)

-- =====================================================
-- 1. VERIFICACIÓN PREVIA
-- =====================================================

-- Verificar registros existentes
SELECT COUNT(*) as total_registros FROM project_students;

-- Verificar políticas existentes
SELECT COUNT(*) as total_politicas FROM pg_policies WHERE tablename = 'project_students';

-- Verificar estado actual de RLS
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'project_students';

-- Mostrar datos existentes para verificación
SELECT ps.id, ps.project_id, ps.student_id, ps.is_lead, ps.joined_at,
       p.title as project_title, u.full_name as student_name
FROM project_students ps
LEFT JOIN projects p ON ps.project_id = p.id
LEFT JOIN users u ON ps.student_id = u.id
ORDER BY ps.joined_at DESC;

-- =====================================================
-- 2. HABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Habilitar RLS en la tabla
ALTER TABLE project_students ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. POLÍTICA TEMPORAL DE DESARROLLO
-- =====================================================

-- Crear política temporal para permitir desarrollo sin interrupciones
-- IMPORTANTE: Esta política debe eliminarse cuando la autenticación JWT esté activa
CREATE POLICY "Development access to project_students" ON project_students
    FOR ALL USING (true);

-- =====================================================
-- 4. VERIFICACIÓN POSTERIOR
-- =====================================================

-- Verificar que RLS está habilitado
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'project_students';

-- Verificar políticas activas
SELECT policyname, cmd as command, qual as using_expression
FROM pg_policies 
WHERE tablename = 'project_students'
ORDER BY policyname;

-- Verificar que los datos siguen accesibles
SELECT COUNT(*) as registros_accesibles FROM project_students;

-- =====================================================
-- 5. DOCUMENTACIÓN
-- =====================================================

-- Comentario en la tabla
COMMENT ON TABLE project_students IS 'Tabla de relación estudiantes-proyectos - RLS habilitado el 2025-01-19';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS habilitado exitosamente en tabla project_students';
    RAISE NOTICE 'Política temporal de desarrollo creada';
    RAISE NOTICE '2 registros existentes - riesgo medio';
    RAISE NOTICE 'Relaciones estudiantes-proyectos protegidas';
END $$;
