-- =====================================================
-- MIGRACIÓN: Habilitar RLS en tabla notifications
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- Fecha: 2025-01-19
-- Propósito: Habilitar Row Level Security en tabla notifications
-- Impacto: 2 registros afectados
-- Riesgo: BAJO RIESGO (pocos datos)

-- =====================================================
-- 1. VERIFICACIÓN PREVIA
-- =====================================================

-- Verificar registros existentes
SELECT COUNT(*) as total_registros FROM notifications;

-- Verificar políticas existentes
SELECT COUNT(*) as total_politicas FROM pg_policies WHERE tablename = 'notifications';

-- Verificar estado actual de RLS
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'notifications';

-- Mostrar datos existentes para verificación
SELECT id, user_id, type, title, created_at 
FROM notifications 
ORDER BY created_at;

-- =====================================================
-- 2. HABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Habilitar RLS en la tabla
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. POLÍTICA TEMPORAL DE DESARROLLO
-- =====================================================

-- Crear política temporal para permitir desarrollo sin interrupciones
-- IMPORTANTE: Esta política debe eliminarse cuando la autenticación JWT esté activa
CREATE POLICY "Development access to notifications" ON notifications
    FOR ALL USING (true);

-- =====================================================
-- 4. VERIFICACIÓN POSTERIOR
-- =====================================================

-- Verificar que RLS está habilitado
SELECT relname, relrowsecurity as rls_enabled 
FROM pg_class 
WHERE relname = 'notifications';

-- Verificar políticas activas
SELECT policyname, cmd as command, qual as using_expression
FROM pg_policies 
WHERE tablename = 'notifications'
ORDER BY policyname;

-- Verificar que los datos siguen accesibles
SELECT COUNT(*) as registros_accesibles FROM notifications;

-- =====================================================
-- 5. DOCUMENTACIÓN
-- =====================================================

-- Comentario en la tabla
COMMENT ON TABLE notifications IS 'Tabla de notificaciones de usuarios - RLS habilitado el 2025-01-19';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'RLS habilitado exitosamente en tabla notifications';
    RAISE NOTICE 'Política temporal de desarrollo creada';
    RAISE NOTICE '2 registros existentes - bajo riesgo';
END $$;
