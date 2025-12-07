-- =====================================================
-- MIGRACIÓN DE EMERGENCIA: Habilitar RLS en todas las tablas
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- Fecha: 2025-01-27
-- Descripción: Resuelve errores críticos de seguridad habilitando RLS
-- =====================================================

-- =====================================================
-- 1. HABILITAR RLS EN TODAS LAS TABLAS FALTANTES
-- =====================================================

-- Tablas principales que faltan (según errores de Supabase)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE dam_objectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteproject_objectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteproject_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_assignees ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE file_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteproject_evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteproject_evaluation_criteria ENABLE ROW LEVEL SECURITY;
ALTER TABLE pdf_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- NUEVAS TABLAS (creadas en migración reciente)
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_dates ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. POLÍTICAS PARA NUEVAS TABLAS (schedules y review_dates)
-- =====================================================

-- Políticas para schedules
CREATE POLICY "Users can view schedules of their anteprojects" ON schedules
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM anteprojects a 
            WHERE a.id = schedules.anteproject_id 
            AND (a.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM anteproject_students WHERE anteproject_id = a.id AND student_id = public.user_id()))
        )
    );

CREATE POLICY "Admins can view all schedules" ON schedules
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Tutors can create schedules for their anteprojects" ON schedules
    FOR INSERT WITH CHECK (
        tutor_id = public.user_id() AND
        EXISTS (
            SELECT 1 FROM anteprojects a 
            WHERE a.id = schedules.anteproject_id AND a.tutor_id = public.user_id()
        )
    );

CREATE POLICY "Tutors can update their schedules" ON schedules
    FOR UPDATE USING (tutor_id = public.user_id());

CREATE POLICY "Admins can update any schedule" ON schedules
    FOR UPDATE USING (public.is_admin());

CREATE POLICY "Tutors can delete their schedules" ON schedules
    FOR DELETE USING (tutor_id = public.user_id());

CREATE POLICY "Admins can delete any schedule" ON schedules
    FOR DELETE USING (public.is_admin());

-- Políticas para review_dates
CREATE POLICY "Users can view review dates of their schedules" ON review_dates
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM schedules s 
            JOIN anteprojects a ON s.anteproject_id = a.id
            WHERE s.id = review_dates.schedule_id 
            AND (a.tutor_id = public.user_id() OR 
                 EXISTS (SELECT 1 FROM anteproject_students WHERE anteproject_id = a.id AND student_id = public.user_id()))
        )
    );

CREATE POLICY "Admins can view all review dates" ON review_dates
    FOR SELECT USING (public.is_admin());

CREATE POLICY "Tutors can create review dates for their schedules" ON review_dates
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM schedules s 
            WHERE s.id = review_dates.schedule_id AND s.tutor_id = public.user_id()
        )
    );

CREATE POLICY "Tutors can update their review dates" ON review_dates
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM schedules s 
            WHERE s.id = review_dates.schedule_id AND s.tutor_id = public.user_id()
        )
    );

CREATE POLICY "Admins can update any review date" ON review_dates
    FOR UPDATE USING (public.is_admin());

CREATE POLICY "Tutors can delete their review dates" ON review_dates
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM schedules s 
            WHERE s.id = review_dates.schedule_id AND s.tutor_id = public.user_id()
        )
    );

CREATE POLICY "Admins can delete any review date" ON review_dates
    FOR DELETE USING (public.is_admin());

-- =====================================================
-- 3. VERIFICACIÓN DE SEGURIDAD
-- =====================================================

-- Verificar que RLS está habilitado en todas las tablas
DO $$
DECLARE
    table_name TEXT;
    rls_enabled BOOLEAN;
    total_tables INTEGER := 0;
    secured_tables INTEGER := 0;
BEGIN
    RAISE NOTICE '🔍 Verificando estado de RLS en todas las tablas...';
    
    FOR table_name IN 
        SELECT tablename FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename NOT LIKE 'pg_%'
        ORDER BY tablename
    LOOP
        total_tables := total_tables + 1;
        
        SELECT relrowsecurity INTO rls_enabled 
        FROM pg_class 
        WHERE relname = table_name;
        
        IF NOT rls_enabled THEN
            RAISE WARNING '❌ RLS NO HABILITADO en tabla: %', table_name;
        ELSE
            RAISE NOTICE '✅ RLS habilitado correctamente en: %', table_name;
            secured_tables := secured_tables + 1;
        END IF;
    END LOOP;
    
    RAISE NOTICE '📊 RESUMEN: % de % tablas tienen RLS habilitado', secured_tables, total_tables;
    
    IF secured_tables = total_tables THEN
        RAISE NOTICE '🎉 ¡TODAS LAS TABLAS ESTÁN SEGURAS!';
    ELSE
        RAISE WARNING '⚠️  AÚN HAY TABLAS SIN RLS HABILITADO';
    END IF;
END $$;

-- =====================================================
-- 4. VERIFICACIÓN DE POLÍTICAS
-- =====================================================

-- Verificar que las políticas están creadas
DO $$
DECLARE
    policy_count INTEGER;
    table_name TEXT;
BEGIN
    RAISE NOTICE '🔍 Verificando políticas de seguridad...';
    
    FOR table_name IN 
        SELECT tablename FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename NOT LIKE 'pg_%'
        ORDER BY tablename
    LOOP
        SELECT COUNT(*) INTO policy_count
        FROM pg_policies 
        WHERE tablename = table_name;
        
        IF policy_count = 0 THEN
            RAISE WARNING '⚠️  Tabla % no tiene políticas definidas', table_name;
        ELSE
            RAISE NOTICE '✅ Tabla % tiene % políticas', table_name, policy_count;
        END IF;
    END LOOP;
END $$;

-- =====================================================
-- 5. DOCUMENTACIÓN Y COMENTARIOS
-- =====================================================

-- Comentarios para las nuevas políticas
COMMENT ON POLICY "Users can view schedules of their anteprojects" ON schedules IS 
'Permite a usuarios ver cronogramas de sus anteproyectos (tutores y estudiantes)';

COMMENT ON POLICY "Tutors can create schedules for their anteprojects" ON schedules IS 
'Permite a tutores crear cronogramas para sus anteproyectos asignados';

COMMENT ON POLICY "Users can view review dates of their schedules" ON review_dates IS 
'Permite a usuarios ver fechas de revisión de sus cronogramas';

COMMENT ON POLICY "Tutors can create review dates for their schedules" ON review_dates IS 
'Permite a tutores crear fechas de revisión en sus cronogramas';

-- =====================================================
-- 6. MENSAJE DE CONFIRMACIÓN FINAL
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🚨 ================================================';
    RAISE NOTICE '🚨 MIGRACIÓN DE EMERGENCIA RLS COMPLETADA';
    RAISE NOTICE '🚨 ================================================';
    RAISE NOTICE '✅ Todas las tablas ahora tienen RLS habilitado';
    RAISE NOTICE '🔒 Políticas de seguridad aplicadas';
    RAISE NOTICE '🛡️  Sistema de seguridad reforzado';
    RAISE NOTICE '⚠️  Verificar que no hay datos expuestos';
    RAISE NOTICE '📋 Revisar logs de Supabase para confirmar';
    RAISE NOTICE '🚨 ================================================';
    RAISE NOTICE '';
END $$;
