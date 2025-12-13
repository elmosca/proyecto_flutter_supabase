# Ciclo de Vida del Proyecto

Aquí explico cómo funciona el ciclo de vida de un proyecto, desde que se crea automáticamente hasta que el estudiante lo completa.

> Si necesitas más contexto sobre la arquitectura, echa un vistazo a [Arquitectura del Sistema](01-Arquitectura).

## Índice

1.  ¿Qué es un proyecto?
2.  Estados del proyecto
3.  Creación automática del proyecto
4.  Gestión del proyecto
5.  Relación con tareas

---

## 1. ¿Qué es un Proyecto?

Un proyecto es el TFG en sí. Se crea automáticamente cuando el tutor aprueba un anteproyecto. A partir de ese momento, el estudiante puede empezar a trabajar en él.

---

## 2. Estados del Proyecto

Un proyecto puede estar en uno de estos estados:

| Estado | Valor en BD | Descripción |
| :--- | :--- | :--- |
| **Borrador** | `draft` | Estado inicial (puede no usarse activamente). |
| **Planificación** | `planning` | El estudiante define tareas y hitos. Es el estado inicial cuando se crea desde un anteproyecto aprobado. |
| **Desarrollo** | `development` | El estudiante trabaja en las tareas. |
| **Revisión** | `review` | El proyecto está en revisión por el tutor. |
| **Completado** | `completed` | El proyecto ha sido finalizado y entregado. |

El enum en el código está en `frontend/lib/models/project.dart` (líneas 91-102).

---

## 3. Creación Automática del Proyecto

### Cuándo se crea

Cuando el tutor aprueba un anteproyecto, el sistema crea automáticamente un proyecto asociado. Esto se hace en el método `_createProjectFromAnteproject()` del servicio `AnteprojectsService` (ver `frontend/lib/services/anteprojects_service.dart`, líneas 1329-1428).

### Datos del proyecto

El proyecto se crea con estos datos:

- **Título:** El mismo que el anteproyecto.
- **Descripción:** La misma que el anteproyecto.
- **Tutor:** El mismo que el anteproyecto.
- **Estado:** `planning` (planificación).
- **Anteproyecto:** Se vincula al anteproyecto mediante `anteproject_id`.

### Relación con el anteproyecto

El proyecto y el anteproyecto están vinculados de forma bidireccional:

- El proyecto tiene `anteproject_id` que referencia al anteproyecto.
- El anteproyecto tiene `project_id` que referencia al proyecto creado.

Esto permite navegar fácilmente entre el anteproyecto y el proyecto.

---

## 4. Gestión del Proyecto

### Ver proyectos

El estudiante puede ver sus proyectos desde el dashboard o desde la sección "Proyectos". La app carga los proyectos con el método `getStudentProjects()` del servicio `ProjectsService`.

El tutor puede ver los proyectos de sus estudiantes con el método `getTutorProjects()`.

### Actualizar el estado

El estado del proyecto se puede actualizar mediante el servicio `ProjectsService`. Por ejemplo, cuando el estudiante empieza a trabajar, el estado cambia de `planning` a `development`.

---

## 5. Relación con Tareas

Las tareas se asocian a proyectos mediante el campo `project_id`. Esto permite que el estudiante divida el proyecto en tareas más pequeñas y haga un seguimiento más detallado del progreso.

El progreso del proyecto se puede calcular en función del estado de las tareas. Por ejemplo, si el 80% de las tareas están completadas, el proyecto está al 80%.
