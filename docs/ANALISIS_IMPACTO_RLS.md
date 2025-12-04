# Análisis de Impacto: Habilitación de RLS

## 📋 Resumen Ejecutivo

Este documento analiza el impacto de habilitar Row Level Security (RLS) en las tablas de Supabase que actualmente tienen políticas definidas pero RLS deshabilitado.

**Estado Actual:**
- ✅ Políticas RLS definidas en 10+ tablas
- ❌ RLS deshabilitado en todas las tablas
- ⚠️ Políticas "Development access" con `qual: true` (permiten TODO)

**Riesgo:** Habilitar RLS sin las políticas de desarrollo podría bloquear consultas legítimas.

---

## 🔍 Análisis de Políticas Existentes

### Políticas "Development Access" (CRÍTICO)

**Todas las tablas tienen una política "Development access" con `qual: true`** que permite acceso completo (SELECT, INSERT, UPDATE, DELETE) a todos los usuarios autenticados.

**Tablas afectadas:**
- `anteprojects`
- `anteproject_students`
- `users`
- `projects`
- `project_students`
- `tasks`
- `task_assignees`
- `milestones`
- `files`
- `notifications`
- Y 12 tablas más...

**Impacto:** Si estas políticas están activas cuando se habilite RLS, **NO habrá problemas de funcionalidad**, pero **habrá un riesgo de seguridad** porque permiten acceso total.

---

## 📊 Análisis de Consultas Flutter

### Consultas que DEPENDEN de RLS

#### 1. **AnteprojectsService.getAnteprojects()**
```dart
final response = await _supabase
    .from('anteprojects')
    .select()
    .order('created_at', ascending: false);
```
**Políticas aplicables:**
- ✅ "Students can view their anteprojects" (estudiantes)
- ✅ "Tutors can view assigned anteprojects" (tutores)
- ✅ "Admins can view all anteprojects" (admins)
- ✅ "Development access to anteprojects" (todos)

**Riesgo:** 🟢 BAJO - Las políticas cubren todos los casos de uso.

#### 2. **AnteprojectsService.getAnteprojectsWithStudentInfo()**
```dart
final response = await _supabase
    .from('anteprojects')
    .select('''
      *,
      anteproject_students(...)
    ''')
    .eq('tutor_id', tutorId);
```
**Políticas aplicables:**
- ✅ "Tutors can view assigned anteprojects"
- ✅ "Development access to anteprojects"

**Riesgo:** 🟢 BAJO - Políticas específicas para tutores.

#### 3. **TasksService.getTasks()**
```dart
final response = await _supabase
    .from('task_assignees')
    .select('''
      task_id,
      tasks (...)
    ''')
    .eq('user_id', userId);
```
**Políticas aplicables:**
- ✅ "Users can view assignments of their projects"
- ✅ "Development access to task_assignees"

**Riesgo:** 🟢 BAJO - Políticas específicas para usuarios.

#### 4. **Consultas a tabla `users`**
```dart
final userResponse = await _supabase
    .from('users')
    .select('id')
    .eq('email', user.email!)
    .single();
```
**Políticas aplicables:**
- ✅ "Users can view their own profile" (`id = user_id()`)
- ✅ "Development access to users"

**Riesgo:** 🟡 MEDIO - La política requiere `id = user_id()`, pero la consulta usa `email`. Necesita verificación.

---

## ⚠️ Problemas Identificados

### 1. **Consultas por Email en lugar de ID**

**Problema:** Muchas consultas usan `email` para identificar usuarios, pero las políticas RLS usan `user_id()` que retorna el `id` de la tabla `users`.

**Ejemplo:**
```dart
// Código Flutter
.from('users')
.select('id')
.eq('email', user.email!)
.single();

// Política RLS
"Users can view their own profile" -> qual: "(id = user_id())"
```

**Solución:** Las políticas deben usar `auth.email()` o las consultas deben usar `id` directamente.

### 2. **Políticas "Development Access" con Acceso Total**

**Problema:** Las políticas `qual: true` permiten acceso completo a cualquier usuario autenticado.

**Riesgo de Seguridad:** 🟠 ALTO - Cualquier usuario autenticado puede acceder a todos los datos.

**Recomendación:** 
- **Opción A:** Eliminar políticas de desarrollo en producción
- **Opción B:** Restringir a un rol específico (ej: solo en desarrollo local)

### 3. **Funciones Helper con search_path Mutable**

**Problema:** Funciones como `user_id()`, `is_admin()`, etc. tienen `search_path` mutable.

**Riesgo:** 🟡 MEDIO - Posible vulnerabilidad de seguridad.

**Solución:** Agregar `SET search_path = public, pg_temp` a las funciones.

---

## 🎯 Plan de Migración Seguro

### Fase 1: Preparación (Sin Cambios en Producción)

1. **Verificar funciones helper:**
   ```sql
   -- Verificar que user_id() funcione correctamente
   SELECT user_id();
   SELECT is_admin();
   ```

2. **Auditar consultas Flutter:**
   - Identificar todas las consultas que usan `email` en lugar de `id`
   - Verificar que las políticas cubran todos los casos de uso

3. **Crear entorno de pruebas:**
   - Habilitar RLS en una rama de desarrollo
   - Ejecutar suite completa de tests

### Fase 2: Corrección de Políticas (Recomendado)

**Opción A: Eliminar políticas de desarrollo**
```sql
-- Eliminar políticas "Development access" de todas las tablas
DROP POLICY IF EXISTS "Development access to anteprojects" ON anteprojects;
-- ... repetir para todas las tablas
```

**Opción B: Restringir políticas de desarrollo**
```sql
-- Cambiar política para solo permitir en desarrollo local
DROP POLICY IF EXISTS "Development access to anteprojects" ON anteprojects;
CREATE POLICY "Development access to anteprojects" ON anteprojects
    FOR ALL
    USING (
        current_setting('app.environment', true) = 'development'
        OR is_admin()
    );
```

### Fase 3: Habilitar RLS (Paso a Paso)

**Orden recomendado (de menor a mayor impacto):**

1. **Tablas de solo lectura primero:**
   ```sql
   ALTER TABLE dam_objectives ENABLE ROW LEVEL SECURITY;
   ALTER TABLE anteproject_evaluation_criteria ENABLE ROW LEVEL SECURITY;
   ```

2. **Tablas con políticas bien definidas:**
   ```sql
   ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
   ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
   ```

3. **Tablas críticas (con rollback plan):**
   ```sql
   -- Hacer backup primero
   -- Habilitar RLS
   ALTER TABLE anteprojects ENABLE ROW LEVEL SECURITY;
   ALTER TABLE anteproject_students ENABLE ROW LEVEL SECURITY;
   ALTER TABLE users ENABLE ROW LEVEL SECURITY;
   ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
   ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
   ```

### Fase 4: Verificación Post-Migración

1. **Tests de funcionalidad:**
   - Login como estudiante
   - Login como tutor
   - Login como admin
   - Verificar que cada rol ve solo sus datos

2. **Monitoreo:**
   - Revisar logs de Supabase para errores de permisos
   - Verificar que no hay consultas bloqueadas

3. **Rollback plan:**
   ```sql
   -- Si hay problemas, deshabilitar RLS temporalmente
   ALTER TABLE anteprojects DISABLE ROW LEVEL SECURITY;
   ```

---

## 🚨 Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Consultas bloqueadas | 🟡 Media | 🔴 Alto | Mantener políticas "Development access" temporalmente |
| Políticas incorrectas | 🟡 Media | 🔴 Alto | Testing exhaustivo antes de producción |
| Funciones helper fallan | 🟢 Baja | 🟡 Medio | Verificar funciones antes de habilitar RLS |
| Performance degradado | 🟢 Baja | 🟡 Medio | Monitorear queries lentas |

---

## ✅ Recomendaciones Finales

### Para Desarrollo Local:
1. **Mantener políticas "Development access"** para facilitar desarrollo
2. Habilitar RLS gradualmente para probar políticas específicas

### Para Producción:
1. **Eliminar o restringir políticas "Development access"**
2. Habilitar RLS en todas las tablas
3. Monitorear logs durante las primeras 24-48 horas
4. Tener plan de rollback listo

### Prioridad de Acción:
1. 🔴 **ALTA:** Corregir funciones helper (search_path)
2. 🟠 **MEDIA:** Auditar y corregir políticas de desarrollo
3. 🟡 **BAJA:** Habilitar RLS gradualmente

---

## 📝 Checklist Pre-Migración

- [ ] Verificar que todas las funciones helper funcionan correctamente
- [ ] Auditar todas las consultas Flutter
- [ ] Crear backup de base de datos
- [ ] Probar en entorno de desarrollo/staging
- [ ] Documentar plan de rollback
- [ ] Notificar al equipo sobre la migración
- [ ] Programar ventana de mantenimiento (si es necesario)

---

**Última actualización:** 2025-01-27
**Autor:** Análisis Automático
**Estado:** Pendiente de Aprobación

