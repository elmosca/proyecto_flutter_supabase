# 2. BASE DE DATOS (SUPABASE/POSTGRESQL)

Este documento consolida la información esencial sobre el modelo de datos, las migraciones y la seguridad del backend, necesaria para cualquier desarrollador que trabaje con Supabase.

## 2.1. Modelo de Datos

El modelo de datos se basa en **PostgreSQL** y está diseñado para soportar la gestión académica de TFG.

### Entidades Clave

| Entidad | Descripción | Campos Destacados |
| :--- | :--- | :--- |
| `users` | Perfiles de usuario. | `full_name`, `email`, `nre` (solo estudiantes), `role` (`admin`, `tutor`, `student`). |
| `anteprojects` | Propuestas de TFG. | `title`, `project_type`, `status` (`draft`, `submitted`, `under_review`, `approved`, `rejected`), `tutor_id`. |
| `projects` | Proyectos activos. | `title`, `status`, `tutor_id`, `anteproject_id` (FK). |
| `tasks` | Tareas del proyecto. | `project_id`, `status` (`pending`, `in_progress`, `under_review`, `completed`), `kanban_position`. |
| `milestones` | Hitos del proyecto. | `project_id`, `planned_date`, `status`. |
| `files` | Archivos subidos. | `file_path`, `uploaded_by`, `task_id` (polimórfico). |

### Relaciones Clave

*   **1:1** entre `anteprojects` y `projects` (un anteproyecto aprobado se convierte en un proyecto).
*   **1:N** entre `users` (tutor) y `projects`.
*   **N:M** entre `users` (estudiantes) y `projects` (a través de `project_students`).

## 2.2. Migraciones SQL

Todas las migraciones se encuentran en el directorio `docs/base_datos/migraciones/`.

*   **Archivo principal**: `schema_completo.sql` contiene el estado final consolidado de todas las migraciones. Este es el archivo recomendado para instalación inicial.
*   **Propósito**: Definir el esquema, triggers, funciones y políticas de seguridad.
*   **Uso**: Ejecutar `schema_completo.sql` en el **SQL Editor de Supabase Cloud** para crear el esquema completo.
*   **Contenido**: Incluye la creación de tablas, la configuración de RLS, la inserción de datos iniciales (`seed data`) y la configuración de autenticación.
*   **Migraciones históricas**: Las migraciones originales se encuentran en `historico/` para referencia y desarrollo.

## 2.3. Seguridad (Row Level Security - RLS)

La seguridad de los datos es crítica y se implementa mediante **RLS** en PostgreSQL.

*   **Estado**: RLS está habilitado en todas las tablas sensibles.
*   **Políticas**: Las políticas son granulares y aseguran que:
    *   **Estudiantes** solo pueden ver y modificar sus propios proyectos y tareas.
    *   **Tutores** solo pueden acceder a los proyectos que les han sido asignados.
    *   **Administradores** tienen acceso completo.

---
*Este documento consolida la información esencial sobre el modelo de datos y las migraciones del sistema.*
