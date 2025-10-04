# 📊 Migraciones de Base de Datos - Supabase Cloud

## 🎯 Propósito

Este directorio contiene todas las migraciones SQL que definen el modelo de datos del proyecto. Estas migraciones están diseñadas para ejecutarse en **Supabase Cloud**.

## 📁 Contenido

Las migraciones están organizadas cronológicamente y definen:

1. **Schema inicial** - Estructura base de tablas
2. **Triggers y funciones** - Lógica de negocio en BD
3. **Datos iniciales** - Seed data para desarrollo
4. **RLS (Row Level Security)** - Políticas de seguridad
5. **Autenticación** - Configuración de auth
6. **Extensiones** - Funcionalidades adicionales

## 🚀 Uso con Supabase Cloud

### **Aplicar Migraciones**

1. **Acceder a Supabase Dashboard**
   - Ir a https://app.supabase.com
   - Seleccionar tu proyecto
   - Ir a `SQL Editor`

2. **Ejecutar Migraciones en Orden**
   ```sql
   -- Copiar y pegar cada archivo .sql en orden cronológico
   -- Ejecutar uno por uno
   ```

3. **Verificar Estado**
   ```sql
   -- Verificar tablas creadas
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public';
   
   -- Verificar políticas RLS
   SELECT schemaname, tablename, policyname 
   FROM pg_policies;
   ```

## 📋 Lista de Migraciones

### **Schema Base**
- `20240815000001_create_initial_schema.sql` - Tablas principales
- `20240815000002_create_triggers_and_functions.sql` - Lógica de BD
- `20240815000003_seed_initial_data.sql` - Datos de ejemplo

### **Seguridad**
- `20240815000004_configure_rls_fixed.sql` - RLS inicial
- `20240815000005_configure_auth.sql` - Configuración de auth
- `20240815000006_configure_rls.sql` - RLS completo

### **Funcionalidades Adicionales**
- `20240914000001_add_objectives_column.sql` - Campo de objetivos
- `20241004T120000_update_tasks_kanban_position.sql` - Posición Kanban
- `20241215000001_create_schedule_tables.sql` - Tablas de horarios
- `20250127000001_create_profiles_table.sql` - Perfiles de usuario

## 🔒 Seguridad

Todas las tablas tienen **Row Level Security (RLS)** habilitado con políticas granulares por rol:
- **Estudiantes**: Solo acceso a sus propios datos
- **Tutores**: Acceso a proyectos asignados
- **Administradores**: Acceso completo

## 🔄 Sincronización

Para mantener la base de datos local sincronizada con Cloud:

1. **Exportar desde Cloud**
   ```bash
   # En Supabase Dashboard > SQL Editor
   # Ejecutar: pg_dump para exportar schema
   ```

2. **Comparar con Migraciones Locales**
   ```bash
   # Revisar diferencias manualmente
   # Actualizar archivos de migración si es necesario
   ```

## 📞 Documentación Relacionada

- [Modelo de Datos Completo](../modelo_datos.md)
- [Especificación Funcional](../../arquitectura/especificacion_funcional.md)
- [Guía de Supabase Cloud](../../desarrollo/03-guias-tecnicas/supabase-cloud.md)

## ⚠️ Importante

- **NO** modificar migraciones ya aplicadas
- **SIEMPRE** crear nuevas migraciones para cambios
- **VERIFICAR** que RLS esté habilitado en todas las tablas
- **PROBAR** en entorno de staging antes de producción

---

**Última actualización**: 4 de octubre de 2025  
**Estado**: Migraciones preservadas desde configuración local

