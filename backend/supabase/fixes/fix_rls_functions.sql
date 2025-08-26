-- =====================================================
-- CORRECCIÓN: Funciones RLS con errores
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- Corregir función is_project_student con variable ambigua
CREATE OR REPLACE FUNCTION public.is_project_student(project_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM project_students 
        WHERE project_students.project_id = project_id AND student_id = public.user_id()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Corregir función is_anteproject_author con variable ambigua
CREATE OR REPLACE FUNCTION public.is_anteproject_author(anteproject_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM anteproject_students 
        WHERE anteproject_students.anteproject_id = anteproject_id AND student_id = public.user_id()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Funciones RLS corregidas exitosamente';
    RAISE NOTICE 'Variables ambiguas resueltas';
END $$;
