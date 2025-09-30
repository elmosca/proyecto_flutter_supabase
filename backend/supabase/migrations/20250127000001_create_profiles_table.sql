-- =====================================================
-- MIGRACIÓN: Crear tabla profiles para compatibilidad
-- Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
-- =====================================================

-- =====================================================
-- 1. CREAR TABLA PROFILES
-- =====================================================

-- Crear tabla profiles que es referenciada por algún código
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'student',
    status TEXT DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. HABILITAR RLS EN PROFILES
-- =====================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. CREAR POLÍTICAS RLS PARA PROFILES
-- =====================================================

-- Política para que los usuarios puedan ver su propio perfil
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

-- Política para que los usuarios puedan actualizar su propio perfil
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Política para que los administradores puedan ver todos los perfiles
CREATE POLICY "Admins can view all profiles" ON public.profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.email = auth.jwt() ->> 'email' 
            AND users.role = 'admin'
        )
    );

-- =====================================================
-- 4. CREAR TRIGGER PARA ACTUALIZAR updated_at
-- =====================================================

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 5. CREAR TRIGGER PARA SINCRONIZAR CON USERS
-- =====================================================

-- Función para sincronizar profiles con users
CREATE OR REPLACE FUNCTION public.sync_profile_with_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertar o actualizar en la tabla users cuando se modifica profiles
    INSERT INTO users (id, email, full_name, role, status, created_at, updated_at)
    VALUES (NEW.id, NEW.email, NEW.full_name, NEW.role::user_role, NEW.status::user_status, NEW.created_at, NEW.updated_at)
    ON CONFLICT (email) 
    DO UPDATE SET
        full_name = EXCLUDED.full_name,
        role = EXCLUDED.role::user_role,
        status = EXCLUDED.status::user_status,
        updated_at = EXCLUDED.updated_at;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para sincronizar profiles con users
CREATE TRIGGER sync_profile_with_user_trigger
    AFTER INSERT OR UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.sync_profile_with_user();

-- =====================================================
-- 6. MIGRAR DATOS EXISTENTES DE USERS A PROFILES
-- =====================================================

-- Insertar datos existentes de users en profiles
INSERT INTO public.profiles (id, email, full_name, role, status, created_at, updated_at)
SELECT 
    gen_random_uuid() as id, -- Generar UUID para cada usuario
    email,
    full_name,
    role::text,
    status::text,
    created_at,
    updated_at
FROM users
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- 7. COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE public.profiles IS 'Tabla de perfiles de usuario para compatibilidad con Supabase Auth';
COMMENT ON FUNCTION public.sync_profile_with_user() IS 'Sincroniza datos entre profiles y users';

-- =====================================================
-- 8. MENSAJE DE CONFIRMACIÓN
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Tabla profiles creada exitosamente';
    RAISE NOTICE 'Políticas RLS aplicadas';
    RAISE NOTICE 'Triggers de sincronización creados';
    RAISE NOTICE 'Datos migrados desde users';
END $$;
