-- =====================================================
-- MIGRACIÓN: Crear tabla de mensajería entre estudiantes y tutores
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================
-- 
-- Propósito: Permitir comunicación bidireccional entre estudiantes y tutores
-- mediante un sistema de mensajería interno asociado a cada anteproyecto.
--
-- Fecha: 2025-11-14
-- =====================================================

-- =====================================================
-- 1. CREAR TABLA anteproject_messages
-- =====================================================
CREATE TABLE IF NOT EXISTS anteproject_messages (
    id SERIAL PRIMARY KEY,
    anteproject_id INT NOT NULL,
    sender_id INT NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (anteproject_id) REFERENCES anteprojects(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- 2. CREAR ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- Índice para buscar mensajes por anteproyecto (más común)
CREATE INDEX IF NOT EXISTS idx_anteproject_messages_anteproject_id 
    ON anteproject_messages(anteproject_id);

-- Índice para buscar mensajes por remitente
CREATE INDEX IF NOT EXISTS idx_anteproject_messages_sender_id 
    ON anteproject_messages(sender_id);

-- Índice para buscar mensajes no leídos
CREATE INDEX IF NOT EXISTS idx_anteproject_messages_is_read 
    ON anteproject_messages(is_read) WHERE is_read = FALSE;

-- Índice compuesto para buscar mensajes no leídos por anteproyecto
CREATE INDEX IF NOT EXISTS idx_anteproject_messages_unread_by_anteproject 
    ON anteproject_messages(anteproject_id, is_read) WHERE is_read = FALSE;

-- =====================================================
-- 3. TRIGGER PARA ACTUALIZAR updated_at AUTOMÁTICAMENTE
-- =====================================================
CREATE OR REPLACE FUNCTION update_anteproject_messages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_anteproject_messages_updated_at
    BEFORE UPDATE ON anteproject_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_anteproject_messages_updated_at();

-- =====================================================
-- 4. HABILITAR ROW LEVEL SECURITY (RLS)
-- =====================================================
ALTER TABLE anteproject_messages ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5. POLÍTICAS RLS
-- =====================================================

-- Política: Permitir acceso completo (temporal para desarrollo)
-- IMPORTANTE: Esta política debe ser reemplazada en producción con políticas más restrictivas
CREATE POLICY "Development access to messages" 
    ON anteproject_messages
    FOR ALL 
    USING (true);

-- =====================================================
-- 6. COMENTARIOS EN LA TABLA Y COLUMNAS
-- =====================================================
COMMENT ON TABLE anteproject_messages IS 
    'Mensajes de comunicación bidireccional entre estudiantes y tutores asociados a anteproyectos';

COMMENT ON COLUMN anteproject_messages.id IS 
    'Identificador único del mensaje';

COMMENT ON COLUMN anteproject_messages.anteproject_id IS 
    'ID del anteproyecto al que pertenece el mensaje';

COMMENT ON COLUMN anteproject_messages.sender_id IS 
    'ID del usuario que envió el mensaje (puede ser estudiante o tutor)';

COMMENT ON COLUMN anteproject_messages.content IS 
    'Contenido del mensaje';

COMMENT ON COLUMN anteproject_messages.is_read IS 
    'Indica si el mensaje ha sido leído por el destinatario';

COMMENT ON COLUMN anteproject_messages.read_at IS 
    'Fecha y hora en que el mensaje fue leído';

COMMENT ON COLUMN anteproject_messages.created_at IS 
    'Fecha y hora de creación del mensaje';

COMMENT ON COLUMN anteproject_messages.updated_at IS 
    'Fecha y hora de última actualización del mensaje';

-- =====================================================
-- ✅ MIGRACIÓN COMPLETADA
-- =====================================================

