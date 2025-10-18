-- =====================================================
-- MIGRACIÓN: Habilitar RLS en tabla comments
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Habilitar Row Level Security en tabla comments
-- Impacto: 0 registros afectados (tabla vacía)
-- Riesgo: SIN RIESGO (tabla sin datos)

-- =====================================================
-- 1. VERIFICACIÓN PREVIA
-- =====================================================

-- Verificar registros existentes
SELECT COUNT(*) as total_registros FROM comments;

-- Verificar políticas existentes
SELECT COUNT(*) as total_politicas FROM pg_policies WHERE tablename = 'comments';

-- Verificar estado actual de RLS
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'comments';

-- =====================================================
-- 2. HABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Habilitar RLS en la tabla
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. POLÍTICA TEMPORAL DE DESARROLLO
-- =====================================================

-- Crear política temporal para permitir desarrollo sin interrupciones
-- IMPORTANTE: Esta política debe eliminarse cuando la autenticación JWT esté activa
CREATE POLICY "Development access to comments" ON comments
    FOR ALL USING (true);

-- =====================================================
-- 4. VERIFICACIÓN POSTERIOR
-- =====================================================

-- Verificar que RLS está habilitado
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'comments';

-- Verificar políticas activas
SELECT policyname, cmd as command, qual as using_expression
FROM pg_policies 
WHERE tablename = 'comments'
ORDER BY policyname;

-- =====================================================
-- 5. DOCUMENTACIÓN
-- =====================================================

-- Comentario en la tabla
COMMENT ON TABLE comments IS 'Tabla de comentarios en tareas - RLS habilitado el 2025-01-19';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS habilitado exitosamente en tabla comments';
    RAISE NOTICE 'Política temporal de desarrollo creada';
    RAISE NOTICE 'Tabla sin datos - sin riesgo de interrupción';
END $$;
