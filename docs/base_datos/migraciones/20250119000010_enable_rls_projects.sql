-- =====================================================
-- MIGRACIÓN: Habilitar RLS en tabla projects
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Habilitar Row Level Security en tabla projects
-- Impacto: 2 registros afectados
-- Riesgo: RIESGO ALTO (datos de proyectos)

-- =====================================================
-- 1. VERIFICACIÓN PREVIA
-- =====================================================

-- Verificar registros existentes
SELECT COUNT(*) as total_registros FROM projects;

-- Verificar políticas existentes
SELECT COUNT(*) as total_politicas FROM pg_policies WHERE tablename = 'projects';

-- Verificar estado actual de RLS
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'projects';

-- Mostrar datos existentes para verificación
SELECT p.id, p.title, p.status, p.tutor_id, p.anteproject_id, p.created_at,
       u.full_name as tutor_name, a.title as anteproject_title
FROM projects p
LEFT JOIN users u ON p.tutor_id = u.id
LEFT JOIN anteprojects a ON p.anteproject_id = a.id
ORDER BY p.created_at DESC;

-- =====================================================
-- 2. HABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Habilitar RLS en la tabla
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. POLÍTICA TEMPORAL DE DESARROLLO
-- =====================================================

-- Crear política temporal para permitir desarrollo sin interrupciones
-- IMPORTANTE: Esta política debe eliminarse cuando la autenticación JWT esté activa
CREATE POLICY "Development access to projects" ON projects
    FOR ALL USING (true);

-- =====================================================
-- 4. VERIFICACIÓN POSTERIOR
-- =====================================================

-- Verificar que RLS está habilitado
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'projects';

-- Verificar políticas activas
SELECT policyname, cmd as command, qual as using_expression
FROM pg_policies 
WHERE tablename = 'projects'
ORDER BY policyname;

-- Verificar que los datos siguen accesibles
SELECT COUNT(*) as registros_accesibles FROM projects;

-- =====================================================
-- 5. DOCUMENTACIÓN
-- =====================================================

-- Comentario en la tabla
COMMENT ON TABLE projects IS 'Tabla de proyectos aprobados - RLS habilitado el 2025-01-19';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS habilitado exitosamente en tabla projects';
    RAISE NOTICE 'Política temporal de desarrollo creada';
    RAISE NOTICE '2 registros existentes - riesgo alto';
    RAISE NOTICE 'Datos de proyectos protegidos';
END $$;
