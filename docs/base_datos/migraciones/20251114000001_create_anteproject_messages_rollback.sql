-- =====================================================
-- ROLLBACK: Eliminar tabla de mensajería
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- 
-- Propósito: Revertir la creación de la tabla anteproject_messages
--
-- Fecha: 2025-11-14
-- =====================================================

-- Eliminar políticas RLS
DROP POLICY IF EXISTS "Students can view messages from their anteprojects" ON anteproject_messages;
DROP POLICY IF EXISTS "Tutors can view messages from their supervised anteprojects" ON anteproject_messages;
DROP POLICY IF EXISTS "Admins can view all messages" ON anteproject_messages;
DROP POLICY IF EXISTS "Students can create messages in their anteprojects" ON anteproject_messages;
DROP POLICY IF EXISTS "Tutors can create messages in their supervised anteprojects" ON anteproject_messages;
DROP POLICY IF EXISTS "Users can mark messages as read" ON anteproject_messages;
DROP POLICY IF EXISTS "Admins can update any message" ON anteproject_messages;
DROP POLICY IF EXISTS "Users can delete their own messages" ON anteproject_messages;
DROP POLICY IF EXISTS "Admins can delete any message" ON anteproject_messages;

-- Eliminar trigger
DROP TRIGGER IF EXISTS trigger_update_anteproject_messages_updated_at ON anteproject_messages;
DROP FUNCTION IF EXISTS update_anteproject_messages_updated_at();

-- Eliminar índices
DROP INDEX IF EXISTS idx_anteproject_messages_anteproject_id;
DROP INDEX IF EXISTS idx_anteproject_messages_sender_id;
DROP INDEX IF EXISTS idx_anteproject_messages_is_read;
DROP INDEX IF EXISTS idx_anteproject_messages_unread_by_anteproject;

-- Eliminar tabla
DROP TABLE IF EXISTS anteproject_messages;

-- =====================================================
-- ✅ ROLLBACK COMPLETADO
-- =====================================================

