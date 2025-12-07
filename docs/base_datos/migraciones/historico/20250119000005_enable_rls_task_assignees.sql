-- =====================================================
-- MIGRACIÓN: Habilitar RLS en tabla task_assignees
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Habilitar Row Level Security en tabla task_assignees
-- Impacto: 16 registros afectados
-- Riesgo: RIESGO MEDIO (datos de asignaciones)

-- =====================================================
-- 1. VERIFICACIÓN PREVIA
-- =====================================================

-- Verificar registros existentes
SELECT COUNT(*) as total_registros FROM task_assignees;

-- Verificar políticas existentes
SELECT COUNT(*) as total_politicas FROM pg_policies WHERE tablename = 'task_assignees';

-- Verificar estado actual de RLS
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'task_assignees';

-- Mostrar datos existentes para verificación
SELECT ta.id, ta.task_id, ta.user_id, ta.assigned_by, ta.assigned_at,
       t.title as task_title, u1.full_name as assigned_to, u2.full_name as assigned_by_name
FROM task_assignees ta
LEFT JOIN tasks t ON ta.task_id = t.id
LEFT JOIN users u1 ON ta.user_id = u1.id
LEFT JOIN users u2 ON ta.assigned_by = u2.id
ORDER BY ta.assigned_at DESC
LIMIT 5;

-- =====================================================
-- 2. HABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Habilitar RLS en la tabla
ALTER TABLE task_assignees ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. POLÍTICA TEMPORAL DE DESARROLLO
-- =====================================================

-- Crear política temporal para permitir desarrollo sin interrupciones
-- IMPORTANTE: Esta política debe eliminarse cuando la autenticación JWT esté activa
CREATE POLICY "Development access to task_assignees" ON task_assignees
    FOR ALL USING (true);

-- =====================================================
-- 4. VERIFICACIÓN POSTERIOR
-- =====================================================

-- Verificar que RLS está habilitado
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'task_assignees';

-- Verificar políticas activas
SELECT policyname, cmd as command, qual as using_expression
FROM pg_policies 
WHERE tablename = 'task_assignees'
ORDER BY policyname;

-- Verificar que los datos siguen accesibles
SELECT COUNT(*) as registros_accesibles FROM task_assignees;

-- =====================================================
-- 5. DOCUMENTACIÓN
-- =====================================================

-- Comentario en la tabla
COMMENT ON TABLE task_assignees IS 'Tabla de asignaciones de tareas - RLS habilitado el 2025-01-19';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS habilitado exitosamente en tabla task_assignees';
    RAISE NOTICE 'Política temporal de desarrollo creada';
    RAISE NOTICE '16 registros existentes - riesgo medio';
END $$;
