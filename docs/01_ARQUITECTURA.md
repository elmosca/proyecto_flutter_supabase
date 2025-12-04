# 1. ARQUITECTURA Y ESPECIFICACIÓN FUNCIONAL

Este documento consolida la información esencial sobre la arquitectura del sistema, roles y entidades clave, necesaria para cualquier desarrollador que continúe el proyecto.

## 1.1. Objetivo General

Facilitar la planificación, ejecución, seguimiento y evaluación del Trabajo de Fin de Grado (TFG) del ciclo formativo de Desarrollo de Aplicaciones Multiplataforma (DAM), mediante una plataforma digital colaborativa centrada en la gestión por tareas y el flujo de trabajo tipo Kanban.

## 1.2. Roles del Sistema

El sistema opera con tres roles principales, cada uno con permisos definidos:

| Rol | Descripción | Permisos Clave |
| :--- | :--- | :--- |
| **Administrador** | Control total del sistema. | Gestión de usuarios, configuración global, visualización de todos los proyectos. |
| **Tutor** | Supervisa proyectos asignados. | Revisión y aprobación de anteproyectos, seguimiento de progreso, comentarios. |
| **Estudiante** | Desarrolla el proyecto. | Creación de anteproyectos, gestión de tareas, subida de entregas, respuesta a *feedback*. |

## 1.3. Entidades Principales

Las entidades clave del sistema definen la lógica de negocio y la estructura de la base de datos:

| Entidad | Descripción | Relaciones Clave |
| :--- | :--- | :--- |
| **Usuario** | Perfil de usuario con rol (`admin`, `tutor`, `student`). | Relacionado con `anteprojects`, `projects`, `tasks`. |
| **Anteproyecto** | Propuesta inicial del TFG. | Relación 1:1 con `projects` (una vez aprobado). |
| **Proyecto** | Proyecto de TFG activo y aprobado. | Relacionado con `users` (estudiantes y tutor), `tasks`, `milestones`. |
| **Tarea** | Unidad de trabajo gestionada en el tablero Kanban. | Relacionado con `projects`, `users` (asignados), `comments`, `files`. Estados: `pending`, `in_progress`, `under_review`, `completed`. |
| **Hito (Milestone)** | Puntos de control clave con fechas previstas. | Relacionado con `projects` y `tasks`. |
| **Archivo** | Entregas o documentos asociados a tareas o comentarios. | Almacenado en Supabase Storage. |

## 1.4. Flujo de Trabajo (Ciclo de Vida del TFG)

1.  **Propuesta de Anteproyecto**: El estudiante crea y envía un `Anteproyecto`.
2.  **Revisión y Aprobación**: El Tutor revisa el `Anteproyecto`.
    *   Si es **Aprobado**, se crea automáticamente un `Proyecto` activo.
    *   Si es **Rechazado** o requiere cambios, se notifica al estudiante.
3.  **Desarrollo**: El estudiante gestiona el `Proyecto` a través del tablero **Kanban** de `Tareas` con estados: `pending`, `in_progress`, `under_review`, `completed`.
4.  **Seguimiento**: El Tutor realiza el seguimiento del progreso, comenta las `Tareas` y evalúa los `Hitos`.
5.  **Finalización**: El proyecto se marca como `completed` tras la entrega final.

## 1.5. Arquitectura Técnica

El proyecto utiliza un *stack* moderno y desacoplado:

| Componente | Tecnología | Propósito |
| :--- | :--- | :--- |
| **Frontend** | **Flutter 3.x** (Dart) | Aplicación multiplataforma (Web, Android, Escritorio). |
| **Gestión de Estado** | **BLoC** | Lógica de negocio y gestión de estado. |
| **Backend** | **Supabase** | Backend-as-a-Service (BaaS). |
| **Base de Datos** | **PostgreSQL** | Almacenamiento de datos relacional. |
| **Seguridad** | **Row Level Security (RLS)** | Políticas de acceso a datos a nivel de fila. |
| **Lógica Avanzada** | **Edge Functions** | Servicios *serverless* para flujos complejos (ej. envío de emails, lógica de aprobación). |
| **Navegación** | **go_router** | Manejo de rutas y navegación. |

---
*Este documento consolida la información de `docs/arquitectura/especificacion_funcional.md`, `docs/arquitectura/logica_datos.md` y otros archivos de arquitectura.*
