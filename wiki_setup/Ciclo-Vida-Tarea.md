# Ciclo de Vida de la Tarea

Aquí explico cómo funcionan las tareas, desde que el estudiante las crea hasta que las completa. Las tareas son las unidades de trabajo más pequeñas dentro de un proyecto y son gestionadas de forma autónoma por el estudiante.

> Si necesitas más contexto sobre la arquitectura, echa un vistazo a [Arquitectura del Sistema](01-Arquitectura).

## Índice

1.  ¿Qué son las tareas?
2.  Estados de la tarea
3.  Crear una tarea
4.  Tablero Kanban
5.  Mover tareas (Drag and Drop)

---

## 1. ¿Qué son las Tareas?

Las tareas son las unidades de trabajo más pequeñas del proyecto. El estudiante divide el proyecto en tareas para hacer un seguimiento más detallado de su progreso.

**Importante:** Las tareas son una herramienta de organización personal del estudiante. El tutor no tiene acceso a las tareas ni al tablero Kanban. Es el estudiante quien decide cómo dividir su trabajo.

Por ejemplo, si el proyecto es "Desarrollar una app móvil", las tareas podrían ser: "Diseñar la interfaz", "Implementar el login", "Crear la base de datos", etc.

---

## 2. Estados de la Tarea

Una tarea puede estar en uno de estos estados:

| Estado | Valor en BD | Descripción |
| :--- | :--- | :--- |
| **Pendiente** | `pending` | La tarea está pendiente de iniciar. Es el estado inicial. |
| **En Progreso** | `in_progress` | La tarea está siendo trabajada actualmente. |
| **Completada** | `completed` | La tarea ha sido completada. |

El enum en el código está en `frontend/lib/models/task.dart` (líneas 158-175).

---

## 3. Crear una Tarea

### Acceso al formulario

Desde el dashboard o desde la sección "Tareas", el estudiante puede crear una nueva tarea con el formulario `TaskForm`.

### Campos del formulario

El formulario tiene estos campos:

- **Título:** Nombre de la tarea.
- **Descripción:** Qué hay que hacer.
- **Proyecto:** A qué proyecto pertenece.
- **Fecha de vencimiento:** Cuándo tiene que estar lista (opcional).
- **Complejidad:** Simple, media o compleja.
- **Horas estimadas:** Cuánto tiempo va a llevar.
- **Etiquetas:** Para categorizar la tarea.

### Estado inicial

Cuando se crea una tarea, su estado inicial es `pending` (pendiente) y se asigna automáticamente al estudiante que la crea.

---

## 4. Tablero Kanban

### ¿Qué es el tablero Kanban?

El tablero Kanban es una forma visual de organizar las tareas. Es una herramienta personal del estudiante para gestionar su trabajo de forma autónoma.

Tiene tres columnas, una para cada estado:

- **Pendiente (`pending`):** Tareas que todavía no se han empezado.
- **En Progreso (`in_progress`):** Tareas en las que se está trabajando.
- **Completada (`completed`):** Tareas terminadas.

El estudiante puede ver todas sus tareas de un vistazo y saber en qué estado está cada una.

### Posición Kanban

Cada tarea tiene un campo `kanban_position` que guarda su posición dentro de su columna. Esto permite mantener el orden de las tareas cuando el estudiante las mueve.

---

## 5. Mover Tareas (Drag and Drop)

### Cómo funciona

El estudiante puede arrastrar y soltar las tareas entre columnas para cambiar su estado. Por ejemplo, si arrastra una tarea de "Pendiente" a "En Progreso", el estado de la tarea cambia automáticamente a `in_progress`.

Esto se hace con drag and drop, y cuando se suelta una tarea en otra columna, se ejecuta el método `_handleTaskDrop()` que actualiza el estado en la base de datos.

### Actualización optimista

El UI se actualiza inmediatamente cuando el estudiante mueve una tarea, sin esperar a que el servidor confirme el cambio. Esto hace que la interfaz sea más rápida y fluida. Si hay un error, el UI se revierte al estado anterior.

---

## Conclusión

Las tareas son la forma de dividir el trabajo del proyecto en partes manejables. El estudiante las gestiona de forma autónoma, sin intervención del tutor. El tablero Kanban permite visualizar el progreso de forma clara y sencilla, y el drag and drop hace que sea muy fácil actualizar el estado de las tareas.
