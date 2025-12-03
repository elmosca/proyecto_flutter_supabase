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

*   **Propósito**: Definir el esquema, triggers, funciones y políticas de seguridad.
*   **Uso**: Deben ejecutarse en orden cronológico en el **SQL Editor de Supabase Cloud**.
*   **Contenido**: Incluyen la creación de tablas, la configuración de RLS, la inserción de datos iniciales (`seed data`) y la configuración de autenticación.

## 2.3. Seguridad (Row Level Security - RLS)

La seguridad de los datos es crítica y se implementa mediante **RLS** en PostgreSQL.

*   **Estado**: RLS está habilitado en todas las tablas sensibles.
*   **Políticas**: Las políticas son granulares y aseguran que:
    *   **Estudiantes** solo pueden ver y modificar sus propios proyectos y tareas.
    *   **Tutores** solo pueden acceder a los proyectos que les han sido asignados.
    *   **Administradores** tienen acceso completo.

## 2.4. Documentación Adicional

*   **Scripts de Migración**: El directorio `docs/base_datos/migraciones/` contiene todos los archivos `.sql` necesarios para replicar la base de datos. Las migraciones deben ejecutarse en orden cronológico según su nombre de archivo.
*   **Índice de Migraciones**: Consulta `docs/base_datos/migraciones/INDICE_MIGRACIONES.md` para ver el orden de ejecución.

---
*Este documento consolida la información de `docs/base_datos/modelo_datos.md` y `docs/base_datos/migraciones/README.md`.*
