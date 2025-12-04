# Plan de Migración Seguro: Habilitación de RLS

## 🎯 Objetivo

Habilitar Row Level Security (RLS) en todas las tablas de Supabase de forma segura, sin interrumpir la funcionalidad de la aplicación Flutter.

---

## 📋 Pre-requisitos

- [x] Análisis de impacto completado
- [ ] Backup de base de datos creado
- [ ] Entorno de staging disponible
- [ ] Suite de tests lista para ejecutar
- [ ] Plan de rollback documentado

---

## 🔧 Fase 1: Corrección de Funciones Helper (CRÍTICO)

### Problema
Las funciones helper tienen `search_path` mutable, lo que es un riesgo de seguridad.

### Solución
Corregir todas las funciones para usar `SET search_path = public, pg_temp`.

### Script de Migración

```sql
-- Función: user_id()
CREATE OR REPLACE FUNCTION public.user_id()
RETURNS integer
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
STABLE
AS $$
  SELECT id FROM users WHERE email = auth.email();
$$;

-- Función: user_role()
CREATE OR REPLACE FUNCTION public.user_role()
RETURNS user_role
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
STABLE
AS $$
  SELECT role FROM users WHERE email = auth.email();
$$;

-- Función: is_admin()
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM users 
    WHERE email = auth.email() 
    AND role = 'admin'::user_role
  );
$$;

-- Función: is_tutor()
CREATE OR REPLACE FUNCTION public.is_tutor()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM users 
    WHERE email = auth.email() 
    AND role = 'tutor'::user_role
  );
$$;

-- Función: is_student()
CREATE OR REPLACE FUNCTION public.is_student()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM users 
    WHERE email = auth.email() 
    AND role = 'student'::user_role
  );
$$;

-- Repetir para todas las funciones helper restantes
-- (is_project_tutor, is_project_student, is_anteproject_tutor, etc.)
```

**Tiempo estimado:** 30 minutos  
**Riesgo:** 🟢 Bajo (solo mejora seguridad, no cambia funcionalidad)

---

## 🧪 Fase 2: Testing en Desarrollo

### 2.1 Habilitar RLS en Entorno de Desarrollo

```sql
-- Habilitar RLS en tablas de menor impacto primero
ALTER TABLE dam_objectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteproject_evaluation_criteria ENABLE ROW LEVEL SECURITY;
ALTER TABLE pdf_templates ENABLE ROW LEVEL SECURITY;
```

### 2.2 Ejecutar Tests

```bash
# Desde frontend/
flutter test test/integration/
```

### 2.3 Verificar Funcionalidad Manual

- [ ] Login como estudiante
- [ ] Login como tutor  
- [ ] Login como admin
- [ ] Crear anteproyecto
- [ ] Ver anteproyectos
- [ ] Crear tarea
- [ ] Ver tareas asignadas

**Tiempo estimado:** 1-2 horas  
**Riesgo:** 🟡 Medio (puede requerir ajustes)

---

## 🔒 Fase 3: Restringir Políticas de Desarrollo

### Opción A: Eliminar Políticas de Desarrollo (Recomendado para Producción)

```sql
-- Eliminar políticas "Development access" de todas las tablas
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND policyname LIKE '%Development%'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
            r.policyname, 'public', r.tablename);
    END LOOP;
END $$;
```

### Opción B: Restringir a Solo Admins (Alternativa)

```sql
-- Cambiar políticas de desarrollo para solo permitir admins
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND policyname LIKE '%Development%'
    LOOP
        -- Eliminar política antigua
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
            r.policyname, 'public', r.tablename);
        
        -- Crear nueva política restringida
        EXECUTE format('CREATE POLICY %I ON %I.%I FOR ALL USING (is_admin())', 
            r.policyname, 'public', r.tablename);
    END LOOP;
END $$;
```

**Tiempo estimado:** 15 minutos  
**Riesgo:** 🟠 Alto (puede bloquear consultas si las otras políticas no cubren todos los casos)

---

## 🚀 Fase 4: Habilitar RLS en Producción (Paso a Paso)

### 4.1 Preparación

```sql
-- 1. Crear backup
-- (Usar herramienta de backup de Supabase o pg_dump)

-- 2. Verificar estado actual
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN (
    'anteprojects', 'anteproject_students', 'users', 
    'projects', 'tasks', 'task_assignees'
);
```

### 4.2 Habilitar RLS Gradualmente

**Grupo 1: Tablas de Configuración (Bajo Riesgo)**
```sql
ALTER TABLE dam_objectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE anteproject_evaluation_criteria ENABLE ROW LEVEL SECURITY;
ALTER TABLE pdf_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;
```

**Esperar 5 minutos y verificar logs**

**Grupo 2: Tablas de Relación (Riesgo Medio)**
```sql
ALTER TABLE anteproject_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_assignees ENABLE ROW LEVEL SECURITY;
```

**Esperar 10 minutos y verificar logs**

**Grupo 3: Tablas de Contenido (Riesgo Medio)**
```sql
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones ENABLE ROW LEVEL SECURITY;
```

**Esperar 10 minutos y verificar logs**

**Grupo 4: Tablas Principales (Alto Riesgo)**
```sql
-- ⚠️ HACER UNO A LA VEZ Y VERIFICAR

-- 1. Users (crítico - afecta autenticación)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- Verificar login funciona

-- 2. Anteprojects
ALTER TABLE anteprojects ENABLE ROW LEVEL SECURITY;
-- Verificar que estudiantes y tutores pueden ver sus anteproyectos

-- 3. Projects
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
-- Verificar que usuarios pueden ver sus proyectos

-- 4. Tasks
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
-- Verificar que usuarios pueden ver sus tareas
```

**Tiempo estimado:** 1-2 horas (con verificaciones)  
**Riesgo:** 🔴 Alto (requiere monitoreo constante)

---

## 🔄 Fase 5: Plan de Rollback

### Si hay problemas, deshabilitar RLS:

```sql
-- Deshabilitar RLS en orden inverso
ALTER TABLE tasks DISABLE ROW LEVEL SECURITY;
ALTER TABLE projects DISABLE ROW LEVEL SECURITY;
ALTER TABLE anteprojects DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
-- ... continuar con el resto
```

### Restaurar políticas de desarrollo (si se eliminaron):

```sql
-- Recrear políticas de desarrollo para todas las tablas
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        EXECUTE format('CREATE POLICY "Development access to %s" ON %I.%I FOR ALL USING (true)', 
            r.tablename, 'public', r.tablename);
    END LOOP;
END $$;
```

---

## 📊 Monitoreo Post-Migración

### Primeras 24 horas:

1. **Revisar logs de Supabase:**
   ```sql
   -- Ver errores de permisos recientes
   SELECT * FROM postgres_logs 
   WHERE message LIKE '%permission denied%' 
   AND created_at > NOW() - INTERVAL '24 hours';
   ```

2. **Verificar métricas:**
   - Tasa de errores de autenticación
   - Tiempo de respuesta de queries
   - Consultas bloqueadas

3. **Tests de usuario:**
   - Login como cada rol
   - Operaciones CRUD básicas
   - Verificar que cada usuario ve solo sus datos

---

## ✅ Checklist Final

### Pre-Migración
- [ ] Backup de base de datos creado
- [ ] Funciones helper corregidas (search_path)
- [ ] Tests ejecutados en desarrollo
- [ ] Plan de rollback documentado
- [ ] Equipo notificado

### Durante Migración
- [ ] RLS habilitado en tablas de bajo riesgo
- [ ] Verificación de logs sin errores
- [ ] RLS habilitado en tablas de medio riesgo
- [ ] Verificación de funcionalidad
- [ ] RLS habilitado en tablas principales
- [ ] Tests de usuario completados

### Post-Migración
- [ ] Monitoreo activo durante 24 horas
- [ ] Sin errores de permisos en logs
- [ ] Performance dentro de parámetros normales
- [ ] Documentación actualizada

---

## 🆘 Contacto de Emergencia

Si hay problemas críticos durante la migración:

1. **Rollback inmediato:** Ejecutar script de rollback
2. **Revisar logs:** Identificar qué consulta falló
3. **Ajustar políticas:** Corregir política problemática
4. **Reintentar:** Habilitar RLS nuevamente

---

**Última actualización:** 2025-01-27  
**Versión:** 1.0  
**Estado:** Pendiente de Ejecución

