# 📋 Especificación API de Proyectos (Futuro Desarrollo)

## 🎯 Estado: DOCUMENTACIÓN PARA DESARROLLO FUTURO
Esta API **NO está implementada** pero se documenta para cuando sea necesaria en el desarrollo de la aplicación.

Para el MVP, la gestión de proyectos es básica (solo visualización) según el plan del proyecto.

---

## 📖 API Básica de Proyectos (projects-api)

### 🔍 **Endpoints de Solo Lectura (MVP)**

#### **GET /projects**
Lista proyectos del usuario según su rol:
- **Estudiantes**: Sus proyectos asignados
- **Tutores**: Proyectos que supervisan  
- **Admins**: Todos los proyectos

**Respuesta:**
```json
[
  {
    "id": 1,
    "title": "Sistema de Gestión de Inventario",
    "description": "Aplicación web para gestión de inventario",
    "status": "development",
    "start_date": "2024-09-01",
    "estimated_end_date": "2024-12-15",
    "actual_end_date": null,
    "tutor": {
      "id": 2,
      "full_name": "María García",
      "email": "maria.garcia@cifpcarlos3.es"
    },
    "students": [
      {
        "id": "uuid",
        "full_name": "Juan Pérez",
        "email": "juan.perez@alumno.cifpcarlos3.es",
        "is_lead": true
      }
    ],
    "anteproject": {
      "id": 1,
      "title": "Sistema de Gestión de Inventario"
    },
    "stats": {
      "total_tasks": 15,
      "completed_tasks": 8,
      "progress_percentage": 53,
      "total_milestones": 4,
      "completed_milestones": 2
    }
  }
]
```

#### **GET /projects/:id**
Obtiene detalles completos de un proyecto específico:

**Respuesta:**
```json
{
  "id": 1,
  "title": "Sistema de Gestión de Inventario",
  "description": "Aplicación web para gestión de inventario",
  "status": "development",
  "start_date": "2024-09-01", 
  "estimated_end_date": "2024-12-15",
  "actual_end_date": null,
  "github_repository_url": "https://github.com/usuario/inventario-app",
  "github_main_branch": "main",
  "last_activity_at": "2024-08-17T10:30:00Z",
  "tutor": {
    "id": 2,
    "full_name": "María García",
    "email": "maria.garcia@cifpcarlos3.es"
  },
  "students": [
    {
      "id": "uuid",
      "full_name": "Juan Pérez", 
      "email": "juan.perez@alumno.cifpcarlos3.es",
      "is_lead": true,
      "joined_at": "2024-08-15T09:00:00Z"
    }
  ],
  "anteproject": {
    "id": 1,
    "title": "Sistema de Gestión de Inventario",
    "project_type": "execution",
    "status": "approved"
  },
  "milestones": [
    {
      "id": 1,
      "milestone_number": 1,
      "title": "Análisis y Diseño",
      "status": "completed",
      "planned_date": "2024-09-15",
      "completed_date": "2024-09-14"
    }
  ],
  "recent_tasks": [
    {
      "id": 1,
      "title": "Crear modelo de datos",
      "status": "completed",
      "completed_at": "2024-08-16T15:30:00Z"
    }
  ],
  "stats": {
    "total_tasks": 15,
    "pending_tasks": 3,
    "in_progress_tasks": 4,
    "under_review_tasks": 2,
    "completed_tasks": 6,
    "progress_percentage": 40,
    "total_milestones": 4,
    "completed_milestones": 1,
    "overdue_tasks": 1
  }
}
```

#### **GET /projects/:id/stats**
Obtiene estadísticas específicas del proyecto:

**Respuesta:**
```json
{
  "project_id": 1,
  "tasks": {
    "total": 15,
    "by_status": {
      "pending": 3,
      "in_progress": 4,
      "under_review": 2,
      "completed": 6
    },
    "overdue": 1,
    "due_this_week": 3
  },
  "milestones": {
    "total": 4,
    "completed": 1,
    "in_progress": 1,
    "pending": 2,
    "overdue": 0
  },
  "progress": {
    "percentage": 40,
    "estimated_completion": "2024-12-15",
    "days_remaining": 120
  },
  "activity": {
    "last_update": "2024-08-17T10:30:00Z",
    "updates_this_week": 8
  }
}
```

---

## 🔧 **Endpoints de Gestión (POST-MVP)**

> **Nota**: Estos endpoints se implementarían solo si se necesitan funcionalidades avanzadas de gestión de proyectos.

### **PUT /projects/:id** 
Actualizar información del proyecto:
```json
{
  "title": "Nuevo título",
  "description": "Nueva descripción",
  "estimated_end_date": "2024-12-20",
  "github_repository_url": "https://github.com/usuario/nuevo-repo"
}
```

### **PUT /projects/:id/status**
Cambiar estado del proyecto:
```json
{
  "status": "review",
  "notes": "Proyecto listo para revisión final"
}
```

### **POST /projects/:id/students**
Añadir estudiante al proyecto:
```json
{
  "student_id": "uuid",
  "is_lead": false
}
```

### **DELETE /projects/:id/students/:student_id**
Quitar estudiante del proyecto.

---

## 🔐 **Autorización y Permisos**

### **Lectura (GET):**
- **Estudiantes**: Solo sus proyectos asignados
- **Tutores**: Solo proyectos que supervisan
- **Admins**: Todos los proyectos

### **Escritura (PUT/POST/DELETE):**
- **Estudiantes**: Solo datos básicos de sus proyectos
- **Tutores**: Gestión completa de proyectos asignados
- **Admins**: Gestión completa de todos los proyectos

---

## 📝 **Notas de Implementación**

### **Dependencias:**
- Requiere `tasks-api` (ya implementada)
- Usa las mismas políticas RLS que las tablas existentes
- Se beneficia de las notificaciones automáticas ya configuradas

### **Base de Datos:**
- Todas las tablas necesarias ya están creadas
- RLS ya configurado y funcionando
- Triggers automáticos ya implementados

### **Cuándo Implementar:**
1. **Inmediatamente**: Solo endpoints GET para MVP
2. **Fase 2**: Endpoints de gestión si se necesitan
3. **Futuro**: Funcionalidades avanzadas como analytics

---

## 🎯 **Prioridades de Implementación**

### **Alta (para MVP):**
- `GET /projects` - Lista de proyectos
- `GET /projects/:id` - Detalle de proyecto

### **Media (post-MVP):**
- `GET /projects/:id/stats` - Estadísticas
- `PUT /projects/:id` - Actualización básica

### **Baja (futuro):**
- Gestión de estudiantes
- Cambios de estado avanzados
- Analytics y reportes

---

**Fecha de especificación**: 17 de agosto de 2024  
**Estado**: Documentación para desarrollo futuro  
**Prioridad actual**: Implementar `tasks-api` primero
