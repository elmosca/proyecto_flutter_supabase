# Proyecto TFG DAM – Plataforma colaborativa (Flutter + Supabase)

## 1. 🎯 Objetivo del Proyecto
Desarrollar una plataforma colaborativa multiplataforma con Flutter (frontend) y Supabase (backend) para gestionar Trabajos de Fin de Grado (TFG) del ciclo DAM. La plataforma permitirá a estudiantes, tutores y administradores planificar y dar seguimiento al TFG con enfoque en gestión de tareas y metodología Kanban.

- Roles: estudiantes, tutores, administradores
- Tableros Kanban, tareas, estados, prioridades
- Seguimiento de entregas, comentarios y rúbricas de evaluación
- Notificaciones y actividad reciente
- Archivos adjuntos y versiones por tarea
- Eventos en tiempo real (p. ej., actualizaciones de tablero, chat/comentarios)

## 2. 🧱 Tecnologías Elegidas
- Frontend: Flutter (iOS, Android, web, escritorio) desde una única base de código.
- Backend: Supabase (PostgreSQL, Auth, Storage, Edge Functions, Realtime, CLI).

## 3. 🚀 Funcionalidades previstas
- Kanban por TFG (listas/estados y tarjetas/tareas)
- Asignación de tareas y fechas límite
- Entrega de archivos por tarea (Storage)
- Comentarios y menciones
- Rúbricas y calificaciones por tutor
- Notificaciones y actividad
- Realtime para colaboración (movimientos en tablero, chat)
- Políticas de seguridad (RLS) por rol/propiedad de datos

## 4. 📁 Estructura del repositorio
- `backend/supabase/`: proyecto Supabase (migraciones, funciones, seed, config)
- `frontend/`: proyecto Flutter (creado por el equipo de frontend)
- `scripts/`: utilidades de desarrollo
- `.cursorrules`: reglas de mejores prácticas para Supabase y Cursor

## 5. 🛠️ Puesta en marcha

### Backend (Supabase)
Requisitos: Supabase CLI, Docker.

1) Instalar CLI (Linux)
```bash
curl -fsSL https://cli.supabase.com/install | sh
```

2) Inicializar y levantar entorno local
```bash
cd backend/supabase
supabase init
cp .env.example .env
supabase start
```

3) Migraciones y DB
```bash
supabase migration new init_schema
supabase db push
```

4) Edge Functions (opcional)
```bash
supabase functions new hello
supabase functions serve
```

Buenas prácticas:
- Habilitar RLS en tablas sensibles y definir políticas mínimas necesarias.
- Usar vistas con `security_invoker = true` cuando apliquen.
- No exponer `service_role` en cliente; usar `anon` en cliente y `service_role` sólo en backend.
- Optimizar consultas con índices y validar con `EXPLAIN`.
- Preferir paginación por cursores sobre `OFFSET/LIMIT` cuando haya muchas filas.

Referencias:
- Optimización de consultas: [Guía oficial](https://supabase.com/docs/guides/database/query-optimization?utm_source=openai)
- Reglas para editores AI (formato de reglas): [Referencia](https://supabase.com/ui/docs/ai-editors-rules/prompts?utm_source=openai)
- Paginación por cursores (contexto): [restack.io](https://www.restack.io/docs/supabase-knowledge-supabase-pagination-guide?utm_source=openai)
- RLS (conceptos y ejemplos): [supabase.wordpress.com – RLS](https://supabase.wordpress.com/2023/05/13/protegiendo-tus-datos-con-rls-como-definir-politicas-de-seguridad-en-supabase/?utm_source=openai)
- Vistas y `security_invoker`: [supabase.wordpress.com – vistas](https://supabase.wordpress.com/2023/05/17/administracion-tablas-y-vistas-en-supabase/?utm_source=openai)
- Claves `anon` vs `service_role`: [apidog.com](https://apidog.com/es/blog/supabase-api-2/?utm_source=openai)

### Frontend (Flutter)
Requisitos: Flutter SDK.

1) Crear proyecto (equipo frontend)
```bash
cd frontend
flutter create app
cd app
flutter pub add supabase_flutter
```

2) Configurar Supabase en `lib/main.dart` (URL y `anon key` del proyecto).

3) Ejecutar
```bash
flutter run
```

## 6. 📋 Seguimiento del Proyecto

### Checklists de Desarrollo
- [📋 Checklist Detallado MVP](docs/desarrollo/checklist_mvp_detallado.md) - Seguimiento completo del plan MVP
- [📅 Checklist Semanal](docs/desarrollo/checklist_seguimiento_semanal.md) - Seguimiento semanal del progreso
- [📊 Estado Actual](docs/desarrollo/estado_actual_completo.md) - Estado completo del proyecto
- [🎉 Logros de la Sesión](docs/desarrollo/logros_sesion_17_agosto.md) - Logros de la sesión del 17 de agosto

### Documentación Técnica
- [🗄️ Backend Supabase](backend/supabase/README.md) - Guía completa del backend
- [🔐 Configuración RLS](backend/supabase/rls_setup_guide.md) - Guía de configuración de seguridad
- [✅ Verificación Migraciones](backend/supabase/verificacion_migraciones.md) - Estado de las migraciones

## 7. 🔐 Seguridad y cumplimiento
- RLS habilitado y políticas por rol/propiedad (p. ej., `auth.uid() = user_id`).
- Datos sensibles protegidos y acceso a Storage controlado por políticas.
- `.env` locales (no se suben); usar `.env.example` como plantilla.
- Revisión de migraciones y políticas en PR antes de desplegar.

## 7. 🧪 Calidad y convenciones
- Commits: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`…).
- Revisión de PR con checklist (.cursorrules).
- Generación de tipos desde DB cuando aplique.
- Documentar endpoints, funciones y políticas relevantes.

## 8. 📦 Entornos
- Desarrollo local: Supabase CLI (`start/stop/status`) dentro de `backend/supabase`.
- Variables por entorno (dev/staging/prod) via `.env` y secretos de Supabase (para Edge Functions).

## 9. 📜 Licencia
Este repositorio se distribuye bajo licencia CC0-1.0 (ver `LICENSE`).