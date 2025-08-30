# 🔐 Guía de Configuración RLS - Sistema TFG

## 📋 Resumen

Esta guía explica cómo configurar Row Level Security (RLS) en el Sistema de Seguimiento de Proyectos TFG para proteger los datos según los roles de usuario.

## 🎯 **Objetivos de RLS**

### **Seguridad por Rol:**
- **Administradores**: Acceso completo a todos los datos
- **Tutores**: Acceso a proyectos y anteproyectos asignados
- **Estudiantes**: Acceso solo a sus propios proyectos y anteproyectos

### **Protección de Datos:**
- Usuarios solo ven sus propios datos
- Tutores solo ven proyectos asignados
- Estudiantes solo ven proyectos donde participan
- Archivos protegidos según permisos de entidad

## 🏗️ **Estructura de RLS**

### **1. Funciones de Autenticación**
```sql
-- Obtener ID del usuario autenticado
auth.user_id()

-- Obtener rol del usuario autenticado  
auth.user_role()

-- Verificar roles específicos
auth.is_admin()
auth.is_tutor()
auth.is_student()

-- Verificar permisos específicos
auth.is_project_tutor(project_id)
auth.is_project_student(project_id)
auth.is_anteproject_tutor(anteproject_id)
auth.is_anteproject_author(anteproject_id)
```

### **2. Políticas por Tabla**

#### **Usuarios (users)**
- Administradores: Ver todos los usuarios
- Usuarios: Ver solo su propio perfil
- Administradores: Gestionar usuarios

#### **Anteproyectos (anteprojects)**
- Administradores: Ver todos los anteproyectos
- Tutores: Ver anteproyectos asignados
- Estudiantes: Ver sus propios anteproyectos
- Estudiantes: Crear anteproyectos
- Estudiantes: Actualizar anteproyectos en borrador

#### **Proyectos (projects)**
- Administradores: Ver todos los proyectos
- Tutores: Ver proyectos asignados
- Estudiantes: Ver proyectos donde participan
- Tutores: Gestionar proyectos asignados
- Estudiantes: Actualizar URL de GitHub

#### **Tareas (tasks)**
- Ver según permisos del proyecto
- Tutores: Gestionar tareas de proyectos asignados
- Estudiantes: Actualizar tareas asignadas

#### **Comentarios (comments)**
- Ver según permisos de la tarea
- Crear en tareas donde participan
- Actualizar comentarios propios

#### **Archivos (files)**
- Ver según permisos de la entidad asociada
- Subir en entidades donde participan
- Eliminar archivos propios

## 🚀 **Pasos para Aplicar RLS**

### **Paso 1: Habilitar RLS en todas las tablas**
```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteprojects ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
-- ... (todas las tablas)
```

### **Paso 2: Crear funciones de autenticación**
```sql
-- Función para obtener ID del usuario
CREATE OR REPLACE FUNCTION auth.user_id()
RETURNS INT AS $$
BEGIN
    RETURN (current_setting('request.jwt.claims', true)::json->>'user_id')::INT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener rol del usuario
CREATE OR REPLACE FUNCTION auth.user_role()
RETURNS user_role AS $$
BEGIN
    RETURN (current_setting('request.jwt.claims', true)::json->>'role')::user_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### **Paso 3: Crear políticas de seguridad**
```sql
-- Ejemplo: Política para usuarios
CREATE POLICY "users_view_own_profile" ON users
    FOR SELECT USING (id = auth.user_id());

-- Ejemplo: Política para anteproyectos
CREATE POLICY "student_view_own_anteprojects" ON anteprojects
    FOR SELECT USING (
        auth.is_student() AND 
        EXISTS (
            SELECT 1 FROM anteproject_students 
            WHERE anteproject_id = anteprojects.id AND student_id = auth.user_id()
        )
    );
```

## 📊 **Políticas Implementadas**

### **Tablas Principales:**
1. **users** - 4 políticas
2. **anteprojects** - 6 políticas
3. **projects** - 5 políticas
4. **tasks** - 3 políticas
5. **comments** - 3 políticas
6. **files** - 3 políticas
7. **milestones** - 2 políticas
8. **notifications** - 2 políticas

### **Tablas de Sistema:**
1. **system_settings** - Solo administradores
2. **pdf_templates** - Solo administradores
3. **activity_log** - Solo administradores
4. **dam_objectives** - Lectura pública, gestión solo admin

## 🔧 **Comandos de Verificación**

### **Verificar RLS habilitado:**
```sql
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('users', 'anteprojects', 'projects', 'tasks');
```

### **Verificar políticas creadas:**
```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

### **Verificar funciones de autenticación:**
```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'auth'
AND routine_name LIKE 'user_%' OR routine_name LIKE 'is_%';
```

## ⚠️ **Consideraciones Importantes**

### **1. Autenticación JWT**
- Las funciones RLS dependen de JWT tokens
- Los tokens deben incluir `user_id` y `role`
- Configurar Supabase Auth correctamente

### **2. Rendimiento**
- Las políticas RLS pueden afectar el rendimiento
- Usar índices apropiados en las consultas
- Evitar subconsultas complejas en políticas

### **3. Testing**
- Probar todas las políticas con diferentes roles
- Verificar que los datos están correctamente protegidos
- Validar que los usuarios pueden acceder a sus datos

## 🐛 **Solución de Problemas**

### **Error: "function auth.user_id() does not exist"**
```sql
-- Verificar que la función existe
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'auth' AND routine_name = 'user_id';

-- Recrear la función si es necesario
CREATE OR REPLACE FUNCTION auth.user_id() ...
```

### **Error: "policy already exists"**
```sql
-- Eliminar política existente
DROP POLICY IF EXISTS "policy_name" ON table_name;

-- Crear nueva política
CREATE POLICY "policy_name" ON table_name ...
```

### **Error: "RLS is not enabled"**
```sql
-- Habilitar RLS en la tabla
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
```

## 📝 **Próximos Pasos**

1. **Aplicar migración RLS**: Ejecutar `20240815000004_configure_rls.sql`
2. **Configurar Supabase Auth**: Integrar autenticación JWT
3. **Probar políticas**: Verificar que funcionan correctamente
4. **Crear API REST**: Endpoints que respeten las políticas RLS

## 🎯 **Estado Actual**

- ✅ **Migración RLS creada**: `20240815000004_configure_rls.sql`
- ⏳ **Pendiente de aplicación**: Ejecutar migración
- ⏳ **Pendiente de testing**: Verificar políticas
- ⏳ **Pendiente de integración**: Conectar con Supabase Auth

---

**Nota**: Esta configuración RLS proporciona seguridad robusta y escalable para el Sistema TFG, protegiendo los datos según los roles y permisos específicos de cada usuario.
