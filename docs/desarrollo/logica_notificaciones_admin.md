# Lógica de Negocio: Notificaciones para Administrador

## 📋 Resumen

Este documento describe el comportamiento actual del sistema de notificaciones para el rol **Administrador** y propone mejoras para una gestión más completa, **respetando las políticas de protección de datos** que impiden el acceso a comunicaciones privadas entre usuarios.

## ⚖️ Principio Fundamental de Privacidad

**IMPORTANTE**: Por políticas de protección de datos, el administrador **NO puede acceder a comunicaciones privadas** entre tutor y alumno. Solo puede ver y gestionar:
- ✅ Notificaciones del sistema (administrativas)
- ✅ Notificaciones que él mismo crea
- ✅ Estadísticas agregadas (sin contenido privado)
- ❌ **NO puede ver**: Comentarios, mensajes privados, detalles de tareas asignadas

---

## 🔍 Estado Actual

### Implementación Actual

#### 1. **Estructura de Datos**

La tabla `notifications` tiene la siguiente estructura:
```sql
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500) NULL,
    metadata JSON NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 2. **Políticas RLS (Row Level Security)**

Según las políticas actuales:
- **Usuarios solo pueden ver sus propias notificaciones**:
  ```sql
  CREATE POLICY "view_own_notifications" ON notifications
      FOR SELECT USING (user_id = auth.user_id());
  ```

- **Usuarios pueden marcar sus notificaciones como leídas**:
  ```sql
  CREATE POLICY "update_own_notifications" ON notifications
      FOR UPDATE USING (user_id = auth.user_id());
  ```

⚠️ **PROBLEMA ACTUAL**: El administrador tiene las mismas restricciones que cualquier usuario. Solo puede ver sus propias notificaciones.

#### 3. **Servicio de Notificaciones**

El `NotificationsService` actual proporciona:
- ✅ `getUnreadNotifications()` - Obtener notificaciones no leídas
- ✅ `getAllNotifications()` - Obtener todas las notificaciones
- ✅ `markAsRead()` - Marcar una como leída
- ✅ `markAllAsRead()` - Marcar todas como leídas
- ✅ `deleteNotification()` - Eliminar una notificación
- ✅ `getUnreadCount()` - Contar notificaciones pendientes

**Limitación**: Todos los métodos filtran por `user_id = usuario actual`, sin diferenciación por rol.

#### 4. **Pantalla de Notificaciones**

La `NotificationsScreen` actual es muy básica:
- Solo muestra un placeholder "No hay notificaciones"
- No implementa funcionalidad real
- No diferencia entre roles

---

## 📊 Tipos de Notificaciones Existentes

Según el código actual, estos son los tipos de notificaciones que se crean:

### 1. **anteproject_comment**
- **Cuándo**: Cuando se añade un comentario a un anteproyecto
- **Para quién**: Estudiante autor del anteproyecto (si el comentario es del tutor)
- **Ejemplo**: "Tu tutor ha añadido un comentario en tu anteproyecto"

### 2. **task_assigned**
- **Cuándo**: Cuando se asigna una tarea a un usuario
- **Para quién**: Usuario asignado
- **Ejemplo**: "Se te ha asignado una nueva tarea: [Título]"

### 3. **task_status_changed**
- **Cuándo**: Cuando cambia el estado de una tarea
- **Para quién**: Usuarios asignados a la tarea
- **Ejemplo**: "El estado de la tarea '[Título]' ha cambiado a [Estado]"

### 4. **Otros tipos mencionados en el código**:
- `comment_notification` - Notificaciones de comentarios (email)
- `welcome` - Notificación de bienvenida (email)
- `reminder` - Notificaciones de recordatorio (email)

---

## 🎯 Funcionalidades Actuales del Administrador

### Lo que el Admin PUEDE hacer actualmente:
1. ✅ Ver sus propias notificaciones (no leídas y todas)
2. ✅ Marcar sus notificaciones como leídas
3. ✅ Eliminar sus propias notificaciones
4. ✅ Ver contador de notificaciones no leídas (solo las suyas)

### Lo que el Admin NO PUEDE hacer actualmente:
1. ❌ Ver notificaciones de otros usuarios
2. ❌ Ver notificaciones del sistema (de todos los usuarios)
3. ❌ Filtrar notificaciones por usuario o tipo
4. ❌ Ver estadísticas de notificaciones
5. ❌ Crear notificaciones manualmente para otros usuarios
6. ❌ Ver notificaciones agrupadas por tipo o fecha

### ⚠️ RESTRICCIÓN POR PROTECCIÓN DE DATOS:
**El administrador NO puede acceder a comunicaciones privadas entre tutor y alumno**:
- ❌ Notificaciones de comentarios en anteproyectos (`anteproject_comment`)
- ❌ Notificaciones de comentarios en tareas
- ❌ Cualquier notificación que involucre comunicación entre usuarios

---

## 💡 Propuesta de Mejoras para el Administrador

### ⚖️ PRINCIPIO DE PROTECCIÓN DE DATOS

**Importante**: El administrador NO puede acceder a comunicaciones privadas entre usuarios. Solo puede ver:
- ✅ Notificaciones del sistema (no privadas)
- ✅ Notificaciones administrativas
- ✅ Sus propias notificaciones personales

### 1. **Notificaciones del Sistema (No Privadas)**

El administrador debería poder ver SOLO notificaciones administrativas:
- ✅ Nuevos usuarios registrados en el sistema
- ✅ Usuarios eliminados del sistema
- ✅ Cambios en configuraciones del sistema
- ✅ Alertas de seguridad o errores del sistema
- ✅ Operaciones masivas completadas
- ✅ Copias de seguridad realizadas
- ✅ Estadísticas agregadas (sin datos personales)

### 2. **Estadísticas Agregadas (Sin Datos Privados)**

Capacidades sugeridas (sin acceder a contenido privado):
- Total de notificaciones por tipo (solo contadores, sin mensajes)
- Notificaciones no leídas agregadas por tipo
- Métricas generales del sistema
- **NO incluir**: Contenido de mensajes, comunicaciones entre usuarios

### 3. **Creación de Notificaciones Administrativas**

El admin debería poder:
- Crear notificaciones para usuarios específicos (solo administrativas)
- Crear notificaciones para grupos (todos los tutores, todos los estudiantes, etc.)
- Crear anuncios generales del sistema
- Programar notificaciones futuras

**Tipos permitidos para creación**:
- ✅ `announcement` - Anuncios generales
- ✅ `system_maintenance` - Avisos de mantenimiento
- ✅ `deadline_reminder` - Recordatorios generales (sin detalles privados)
- ❌ NO puede crear notificaciones que simulen comunicaciones entre usuarios

### 4. **Panel de Administración**

Vista especial para admin con:
- Dashboard de notificaciones del sistema (solo administrativas)
- Métricas agregadas (sin datos personales)
- Gestión de sus propias notificaciones
- Creación de notificaciones administrativas

---

## 🔧 Cambios Necesarios para Implementar Mejoras

### A. Modificar Políticas RLS (Respetando Privacidad)

```sql
-- Permitir a administradores ver SOLO notificaciones del sistema (no privadas)
CREATE POLICY "admins_view_system_notifications" ON notifications
    FOR SELECT USING (
        -- Admin puede ver sus propias notificaciones
        user_id = auth.user_id()
        OR (
            -- Admin puede ver notificaciones del sistema (no privadas)
            auth.user_id() IN (SELECT id FROM users WHERE role = 'admin')
            AND type IN (
                'user_created', 'user_deleted', 'system_error',
                'security_alert', 'backup_completed', 'settings_changed',
                'bulk_operation', 'system_maintenance', 'announcement'
            )
        )
    );

-- Permitir a administradores crear notificaciones administrativas para otros usuarios
CREATE POLICY "admins_create_admin_notifications" ON notifications
    FOR INSERT WITH CHECK (
        auth.user_id() IN (SELECT id FROM users WHERE role = 'admin')
        AND type IN (
            'announcement', 'system_maintenance', 'deadline_reminder',
            'system_notification'
        )
    );
```

**NOTA**: Las notificaciones privadas (`anteproject_comment`, `task_assigned`, etc.) quedan excluidas del acceso del administrador.

### B. Extender NotificationsService

Añadir métodos específicos para admin (respetando privacidad):
```dart
// Obtener notificaciones del sistema (solo administrativas, sin privadas)
Future<List<Map<String, dynamic>>> getSystemNotifications()

// Crear notificación administrativa para otro usuario (solo tipos permitidos)
Future<void> createAdminNotification({
  required int userId,
  required String type, // Solo: announcement, system_maintenance, etc.
  required String title,
  required String message,
  String? actionUrl,
  Map<String, dynamic>? metadata,
})

// Crear notificación para múltiples usuarios (anuncios)
Future<void> createBulkAdminNotification({
  required List<int> userIds,
  required String type,
  required String title,
  required String message,
  String? actionUrl,
})

// Obtener estadísticas agregadas (sin datos privados)
Future<Map<String, dynamic>> getNotificationStatistics() {
  // Retorna solo contadores por tipo, sin contenido de mensajes
  // Excluye tipos privados de las estadísticas
}
```

**Tipos permitidos para creación por admin**:
- `announcement` - Anuncios generales
- `system_maintenance` - Avisos de mantenimiento
- `system_notification` - Notificaciones del sistema
- `deadline_reminder` - Recordatorios generales
- `welcome` - Bienvenida a nuevos usuarios

**Tipos EXCLUIDOS** (comunicaciones privadas):
- ❌ `anteproject_comment`
- ❌ `task_assigned` (puede ser privado)
- ❌ `task_status_changed` (puede contener info privada)
- ❌ Cualquier tipo de comunicación entre usuarios

### C. Mejorar NotificationsScreen

Crear una versión mejorada con:
- Tabs: "Mis Notificaciones" | "Todas las Notificaciones" (solo admin)
- Filtros: Tipo, Usuario, Fecha, Estado
- Acciones masivas: Marcar todas como leídas, Eliminar antiguas
- Estadísticas: Total, No leídas, Por tipo

---

## 📈 Tipos de Notificaciones para Admin

### Notificaciones que el Admin debería RECIBIR (Solo del Sistema):
1. ✅ **user_created** - Nuevo usuario registrado (sin datos sensibles)
2. ✅ **user_deleted** - Usuario eliminado del sistema
3. ✅ **system_error** - Errores críticos del sistema
4. ✅ **security_alert** - Alertas de seguridad (intentos de acceso, etc.)
5. ✅ **backup_completed** - Copias de seguridad completadas
6. ✅ **settings_changed** - Cambios en configuraciones del sistema
7. ✅ **bulk_operation** - Operaciones masivas completadas

### Notificaciones que el Admin debería PODER CREAR (Solo Administrativas):
1. ✅ **announcement** - Anuncios generales para todos los usuarios
2. ✅ **system_maintenance** - Avisos de mantenimiento
3. ✅ **system_notification** - Notificaciones generales del sistema
4. ✅ **deadline_reminder** - Recordatorios generales de fechas límite (sin detalles específicos)
5. ✅ **welcome** - Notificaciones de bienvenida para nuevos usuarios

### ❌ Notificaciones que el Admin NO puede ver/crear (Privadas):
1. ❌ **anteproject_comment** - Comentarios entre tutor y alumno
2. ❌ **task_assigned** - Asignaciones de tareas (contenido privado)
3. ❌ **task_status_changed** - Cambios de estado con detalles privados
4. ❌ Cualquier notificación que contenga comunicación entre usuarios

---

## 🎨 Interfaz Propuesta

### Para Usuario Normal (Estudiante/Tutor):
```
┌─────────────────────────────────────┐
│  Mis Notificaciones                 │
├─────────────────────────────────────┤
│  🔔 Tarea asignada                   │
│     Nueva tarea: "Revisar código"   │
│     Hace 2 horas                    │
│                                      │
│  💬 Nuevo comentario                 │
│     En anteproyecto "Mi TFG"        │
│     Hace 5 horas                    │
└─────────────────────────────────────┘
```

### Para Administrador:
```
┌─────────────────────────────────────┐
│  Notificaciones                     │
│  [Mis Notif.] [Sistema]              │
├─────────────────────────────────────┤
│  🔍 Filtros: [Tipo ▼]                │
│                                      │
│  🔔 Sistema: Nuevo usuario           │
│     Usuario registrado en el sistema│
│     Hace 1 hora                     │
│                                      │
│  ⚙️ Sistema: Configuración cambiada │
│     max_file_size_mb actualizado    │
│     Hace 2 horas                    │
│                                      │
│  📊 Estadísticas:                    │
│     • Total sistema: 15              │
│     • No leídas: 3                   │
│     • Por tipo: [Ver desglose]      │
│                                      │
│  [+ Crear Notificación]              │
│  [Marcar todas como leídas]         │
└─────────────────────────────────────┘

⚠️ Nota: No se muestran comunicaciones privadas
entre usuarios por protección de datos.
```

---

## 📝 Resumen de Necesidades

### Funcionalidades Críticas (Respetando Privacidad):
1. ✅ Ver notificaciones del sistema (solo administrativas, no privadas)
2. ✅ Filtrar notificaciones por tipo (solo tipos permitidos)
3. ✅ Crear notificaciones administrativas para usuarios/grupos
4. ✅ Ver estadísticas agregadas (sin contenido privado)

### Funcionalidades Deseables:
1. ⭐ Panel de notificaciones del sistema
2. ⭐ Gestión masiva de notificaciones administrativas
3. ⭐ Dashboard de estadísticas (contadores sin datos personales)
4. ⭐ Creación de anuncios generales para todos los usuarios

### ⚠️ RESTRICCIONES (Protección de Datos):
1. ❌ NO puede ver contenido de comunicaciones entre usuarios
2. ❌ NO puede ver notificaciones privadas (comentarios, tareas específicas)
3. ❌ NO puede crear notificaciones que simulen comunicaciones privadas
4. ❌ NO puede acceder a mensajes o detalles de interacciones tutor-alumno

---

## 🚀 Próximos Pasos

1. **Revisar y aprobar** esta propuesta
2. **Modificar políticas RLS** para permitir acceso de admin
3. **Extender NotificationsService** con métodos específicos de admin
4. **Rediseñar NotificationsScreen** con funcionalidades avanzadas
5. **Implementar creación de notificaciones** para otros usuarios
6. **Añadir tipos de notificaciones** específicos para admin

---

**Fecha de creación**: 2025-01-28  
**Estado**: 📋 Documentación completada - Pendiente de implementación

