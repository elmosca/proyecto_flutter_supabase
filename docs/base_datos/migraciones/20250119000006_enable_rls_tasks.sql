-- =====================================================
-- MIGRACIÓN: Habilitar RLS en tabla tasks
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Habilitar Row Level Security en tabla tasks
-- Impacto: 18 registros afectados
-- Riesgo: RIESGO MEDIO (datos de tareas)

-- =====================================================
-- 1. VERIFICACIÓN PREVIA
-- =====================================================

-- Verificar registros existentes
SELECT COUNT(*) as total_registros FROM tasks;

-- Verificar políticas existentes
SELECT COUNT(*) as total_politicas FROM pg_policies WHERE tablename = 'tasks';

-- Verificar estado actual de RLS
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'tasks';

-- Mostrar datos existentes para verificación
SELECT t.id, t.title, t.status, t.project_id, t.anteproject_id, t.created_at,
       p.title as project_title, a.title as anteproject_title
FROM tasks t
LEFT JOIN projects p ON t.project_id = p.id
LEFT JOIN anteprojects a ON t.anteproject_id = a.id
ORDER BY t.created_at DESC
LIMIT 5;

-- =====================================================
-- 2. HABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Habilitar RLS en la tabla
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. POLÍTICA TEMPORAL DE DESARROLLO
-- =====================================================

-- Crear política temporal para permitir desarrollo sin interrupciones
-- IMPORTANTE: Esta política debe eliminarse cuando la autenticación JWT esté activa
CREATE POLICY "Development access to tasks" ON tasks
    FOR ALL USING (true);

-- =====================================================
-- 4. VERIFICACIÓN POSTERIOR
-- =====================================================

-- Verificar que RLS está habilitado
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'tasks';

-- Verificar políticas activas
SELECT policyname, cmd as command, qual as using_expression
FROM pg_policies 
WHERE tablename = 'tasks'
ORDER BY policyname;

-- Verificar que los datos siguen accesibles
SELECT COUNT(*) as registros_accesibles FROM tasks;

-- =====================================================
-- 5. DOCUMENTACIÓN
-- =====================================================

-- Comentario en la tabla
COMMENT ON TABLE tasks IS 'Tabla de tareas (anteproyectos y proyectos) - RLS habilitado el 2025-01-19';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS habilitado exitosamente en tabla tasks';
    RAISE NOTICE 'Política temporal de desarrollo creada';
    RAISE NOTICE '18 registros existentes - riesgo medio';
END $$;
