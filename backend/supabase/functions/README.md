# 🚀 Supabase Edge Functions - Sistema TFG

## 📋 Funciones Disponibles

### 1. `approval-api` - API de Aprobación de Anteproyectos

Gestiona el flujo de aprobación, rechazo y solicitud de cambios de anteproyectos.

#### Endpoints:

- **POST** `/functions/v1/approval-api?action=approve`
  - Aprueba un anteproyecto y crea el proyecto asociado
  - Body: `{ "anteproject_id": number, "comments": string? }`

- **POST** `/functions/v1/approval-api?action=reject`
  - Rechaza un anteproyecto
  - Body: `{ "anteproject_id": number, "comments": string }`

- **POST** `/functions/v1/approval-api?action=request-changes`
  - Solicita cambios en un anteproyecto (vuelve a estado draft)
  - Body: `{ "anteproject_id": number, "comments": string }`

### 2. `anteprojects-api` - API CRUD de Anteproyectos

Gestiona las operaciones CRUD de anteproyectos.

### 3. `tasks-api` - API de Gestión de Tareas ✅ **IMPLEMENTADA**

Gestiona el CRUD completo de tareas, asignaciones y comentarios.

#### Endpoints:

**Anteproyectos:**
- **GET** `/functions/v1/anteprojects-api/`
  - Lista anteproyectos según el rol del usuario
- **GET** `/functions/v1/anteprojects-api/:id`
  - Obtiene un anteproyecto específico con detalles completos
- **POST** `/functions/v1/anteprojects-api/`
  - Crea un nuevo anteproyecto
- **PUT** `/functions/v1/anteprojects-api/:id`
  - Actualiza un anteproyecto existente
- **POST** `/functions/v1/anteprojects-api/:id/submit`
  - Envía un anteproyecto para revisión (draft → submitted)

**Tareas:**
- **GET** `/functions/v1/tasks-api/?project_id=:id`
  - Lista tareas de un proyecto específico
- **GET** `/functions/v1/tasks-api/`
  - Lista tareas asignadas al usuario actual
- **GET** `/functions/v1/tasks-api/:id`
  - Obtiene una tarea específica con detalles completos
- **POST** `/functions/v1/tasks-api/`
  - Crea una nueva tarea
- **PUT** `/functions/v1/tasks-api/:id`
  - Actualiza una tarea existente
- **PUT** `/functions/v1/tasks-api/:id/status`
  - Actualiza el estado de una tarea
- **POST** `/functions/v1/tasks-api/:id/assign`
  - Asigna un usuario a la tarea
- **POST** `/functions/v1/tasks-api/:id/comments`
  - Añade un comentario a la tarea

## 🔐 Autenticación

Todas las funciones requieren autenticación. Incluir el header:
```
Authorization: Bearer <JWT_TOKEN>
```

## 🧪 Testing

Para probar las funciones localmente:

```bash
# Iniciar Supabase
supabase start

# Las funciones estarán disponibles en:
# http://localhost:54321/functions/v1/approval-api
# http://localhost:54321/functions/v1/anteprojects-api
```

### Ejemplos de uso:

```bash
# Aprobar anteproyecto
curl -X POST 'http://localhost:54321/functions/v1/approval-api?action=approve' \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"anteproject_id": 1, "comments": "Excelente propuesta"}'

# Listar anteproyectos
curl -X GET 'http://localhost:54321/functions/v1/anteprojects-api/' \
  -H "Authorization: Bearer $JWT_TOKEN"

# Crear anteproyecto
curl -X POST 'http://localhost:54321/functions/v1/anteprojects-api/' \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Sistema de Gestión",
    "project_type": "execution",
    "description": "Descripción del proyecto",
    "academic_year": "2024-2025",
    "expected_results": ["Resultado 1", "Resultado 2"],
    "timeline": {"fecha1": "2024-09-01", "fecha2": "2024-12-15"},
    "tutor_id": 2,
    "student_ids": ["uuid-student-1"],
    "objectives": [{"objective_id": 1, "is_selected": true}]
  }'

# Listar tareas de un proyecto
curl -X GET 'http://localhost:54321/functions/v1/tasks-api/?project_id=1' \
  -H "Authorization: Bearer $JWT_TOKEN"

# Crear nueva tarea
curl -X POST 'http://localhost:54321/functions/v1/tasks-api/' \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "milestone_id": 1,
    "title": "Implementar autenticación",
    "description": "Desarrollar sistema de login y registro",
    "due_date": "2024-09-15",
    "estimated_hours": 8,
    "complexity": "medium",
    "assignees": ["uuid-student-1"]
  }'

# Actualizar estado de tarea
curl -X PUT 'http://localhost:54321/functions/v1/tasks-api/1/status' \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}'

# Añadir comentario a tarea
curl -X POST 'http://localhost:54321/functions/v1/tasks-api/1/comments' \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Tarea completada exitosamente", "is_internal": false}'
```

## 📁 Estructura de Archivos

```
functions/
├── approval-api/
│   └── index.ts           # Lógica de aprobación
├── anteprojects-api/
│   └── index.ts           # CRUD de anteproyectos
├── tasks-api/
│   └── index.ts           # CRUD de tareas ✅ IMPLEMENTADA
├── projects-api-spec.md   # Especificación para desarrollo futuro
└── README.md              # Esta documentación
```

## 🚀 Despliegue

Para desplegar las funciones:

```bash
# Desplegar todas las funciones
supabase functions deploy

# Desplegar función específica
supabase functions deploy approval-api
supabase functions deploy anteprojects-api
supabase functions deploy tasks-api
```

## 🔧 Variables de Entorno

Las funciones usan automáticamente:
- `SUPABASE_URL`: URL del proyecto Supabase
- `SUPABASE_ANON_KEY`: Clave anónima de Supabase

Estas variables están disponibles automáticamente en el entorno de ejecución.
