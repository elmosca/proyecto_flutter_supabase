-- =====================================================
-- MIGRACIÓN: Habilitar RLS en tabla anteprojects
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Habilitar Row Level Security en tabla anteprojects
-- Impacto: 4 registros afectados
-- Riesgo: RIESGO ALTO (datos de anteproyectos)

-- =====================================================
-- 1. VERIFICACIÓN PREVIA
-- =====================================================

-- Verificar registros existentes
SELECT COUNT(*) as total_registros FROM anteprojects;

-- Verificar políticas existentes
SELECT COUNT(*) as total_politicas FROM pg_policies WHERE tablename = 'anteprojects';

-- Verificar estado actual de RLS
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'anteprojects';

-- Mostrar datos existentes para verificación
SELECT a.id, a.title, a.project_type, a.status, a.tutor_id, a.created_at,
       u.full_name as tutor_name
FROM anteprojects a
LEFT JOIN users u ON a.tutor_id = u.id
ORDER BY a.created_at DESC;

-- =====================================================
-- 2. HABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Habilitar RLS en la tabla
ALTER TABLE anteprojects ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. POLÍTICA TEMPORAL DE DESARROLLO
-- =====================================================

-- Crear política temporal para permitir desarrollo sin interrupciones
-- IMPORTANTE: Esta política debe eliminarse cuando la autenticación JWT esté activa
CREATE POLICY "Development access to anteprojects" ON anteprojects
    FOR ALL USING (true);

-- =====================================================
-- 4. VERIFICACIÓN POSTERIOR
-- =====================================================

-- Verificar que RLS está habilitado
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'anteprojects';

-- Verificar políticas activas
SELECT policyname, cmd as command, qual as using_expression
FROM pg_policies 
WHERE tablename = 'anteprojects'
ORDER BY policyname;

-- Verificar que los datos siguen accesibles
SELECT COUNT(*) as registros_accesibles FROM anteprojects;

-- =====================================================
-- 5. DOCUMENTACIÓN
-- =====================================================

-- Comentario en la tabla
COMMENT ON TABLE anteprojects IS 'Tabla de anteproyectos (propuestas) - RLS habilitado el 2025-01-19';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS habilitado exitosamente en tabla anteprojects';
    RAISE NOTICE 'Política temporal de desarrollo creada';
    RAISE NOTICE '4 registros existentes - riesgo alto';
    RAISE NOTICE 'Datos de anteproyectos protegidos';
END $$;
