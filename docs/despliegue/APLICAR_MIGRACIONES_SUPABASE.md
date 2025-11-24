# 🗄️ Guía: Aplicar Migraciones en Supabase (Producción)

Esta guía explica cómo aplicar las migraciones de base de datos en Supabase Cloud para sincronizar el esquema entre local y producción.

---

## 🎯 **PROBLEMA COMÚN**

Cuando despliegas el frontend pero la base de datos de producción no está actualizada, puedes encontrar errores como:

- `400 Bad Request` en consultas de archivos
- `attachable_type` no acepta valor 'project'
- Errores de permisos RLS

---

## ✅ **SOLUCIÓN: APLICAR MIGRACIONES**

### **PASO 1: Acceder a Supabase Dashboard**

1. Ir a https://app.supabase.com
2. Iniciar sesión con tu cuenta
3. Seleccionar el proyecto de **producción** (fct.jualas.es)
4. Ir a la sección **SQL Editor** (menú lateral izquierdo)

---

### **PASO 2: Aplicar Migración 1 - Agregar 'project' al enum**

1. **Abrir el archivo de migración**:
   - Ruta local: `docs/base_datos/migraciones/20250129000001_add_project_to_attachable_type.sql`
   - O copiar el siguiente SQL:

```sql
-- =====================================================
-- MIGRACIÓN: Agregar 'project' al enum attachable_type
-- Fecha: 2025-01-29
-- Descripción: Agrega el valor 'project' al enum attachable_type
--              para permitir archivos adjuntos a proyectos
-- =====================================================

-- Agregar 'project' al enum attachable_type
ALTER TYPE attachable_type ADD VALUE IF NOT EXISTS 'project';

-- Comentario de documentación
COMMENT ON TYPE attachable_type IS 'Tipos de entidades a las que se pueden adjuntar archivos: task, comment, anteproject, project';
```

2. **Pegar el SQL en el editor**
3. **Ejecutar** (botón "Run" o `Ctrl+Enter`)
4. **Verificar** que no haya errores (debe mostrar "Success")

---

### **PASO 3: Aplicar Migración 2 - Actualizar Políticas RLS**

1. **Abrir el archivo de migración**:
   - Ruta local: `docs/base_datos/migraciones/20250129000002_update_rls_policies_for_project_files.sql`
   - O copiar el siguiente SQL:

```sql
-- =====================================================
-- MIGRACIÓN: Actualizar políticas RLS para archivos de proyectos
-- Fecha: 2025-01-29
-- Descripción: Actualiza las políticas RLS de la tabla files
--              para incluir soporte para attachable_type = 'project'
-- =====================================================

-- Eliminar políticas existentes que necesitan actualización
DROP POLICY IF EXISTS "view_files_by_entity" ON files;
DROP POLICY IF EXISTS "upload_files_in_participating_entities" ON files;

-- Recrear política de visualización con soporte para 'project'
CREATE POLICY "view_files_by_entity" ON files
    FOR SELECT USING (
        auth.is_admin() OR
        (attachable_type = 'task' AND (
            auth.is_project_tutor((SELECT project_id FROM tasks WHERE id = attachable_id)) OR
            auth.is_project_student((SELECT project_id FROM tasks WHERE id = attachable_id))
        )) OR
        (attachable_type = 'anteproject' AND (
            auth.is_anteproject_tutor(attachable_id) OR
            auth.is_anteproject_author(attachable_id)
        )) OR
        (attachable_type = 'project' AND (
            auth.is_project_tutor(attachable_id) OR
            auth.is_project_student(attachable_id)
        ))
    );

-- Recrear política de inserción con soporte para 'project'
CREATE POLICY "upload_files_in_participating_entities" ON files
    FOR INSERT WITH CHECK (
        auth.is_admin() OR
        (attachable_type = 'task' AND (
            auth.is_project_tutor((SELECT project_id FROM tasks WHERE id = attachable_id)) OR
            auth.is_project_student((SELECT project_id FROM tasks WHERE id = attachable_id))
        )) OR
        (attachable_type = 'anteproject' AND (
            auth.is_anteproject_tutor(attachable_id) OR
            auth.is_anteproject_author(attachable_id)
        )) OR
        (attachable_type = 'project' AND (
            auth.is_project_tutor(attachable_id) OR
            auth.is_project_student(attachable_id)
        ))
    );

-- Comentario de documentación
COMMENT ON POLICY "view_files_by_entity" ON files IS 
    'Permite ver archivos según permisos de la entidad asociada (task, anteproject, project)';

COMMENT ON POLICY "upload_files_in_participating_entities" ON files IS 
    'Permite subir archivos en entidades donde el usuario participa (task, anteproject, project)';
```

2. **Pegar el SQL en el editor**
3. **Ejecutar** (botón "Run" o `Ctrl+Enter`)
4. **Verificar** que no haya errores (debe mostrar "Success")

---

### **PASO 4: Verificar que las Migraciones se Aplicaron Correctamente**

Ejecuta estas consultas en el SQL Editor para verificar:

```sql
-- 1. Verificar que 'project' está en el enum
SELECT unnest(enum_range(NULL::attachable_type));
-- Debe mostrar: task, comment, anteproject, project

-- 2. Verificar las políticas RLS de archivos
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'files';
-- Debe mostrar las políticas actualizadas con soporte para 'project'
```

---

## 🔄 **VERIFICAR EN LA APLICACIÓN**

Después de aplicar las migraciones:

1. **Recargar la aplicación** en producción (fct.jualas.es)
2. **Probar la funcionalidad de archivos** en proyectos
3. **Verificar que no aparezcan errores 400** en la consola del navegador

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Error: "enum value already exists"**
- ✅ **Solución**: El enum ya tiene el valor. Puedes continuar con la siguiente migración.

### **Error: "policy already exists"**
- ✅ **Solución**: Las políticas ya existen. La migración usa `DROP POLICY IF EXISTS`, así que debería funcionar. Si persiste, ejecuta manualmente el `DROP POLICY` primero.

### **Error de permisos**
- ✅ **Solución**: Asegúrate de estar usando una cuenta con permisos de administrador en Supabase.

---

## 📋 **CHECKLIST DE VERIFICACIÓN**

- [ ] Migración 1 aplicada sin errores
- [ ] Migración 2 aplicada sin errores
- [ ] Enum `attachable_type` contiene 'project'
- [ ] Políticas RLS actualizadas correctamente
- [ ] Aplicación en producción funciona sin errores 400
- [ ] Archivos se pueden subir y ver en proyectos

---

**¡Migraciones aplicadas correctamente!** 🎉

