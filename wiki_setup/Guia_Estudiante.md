# Guía del Estudiante

Esta guía detalla las funcionalidades y el flujo de trabajo dentro del Sistema de Seguimiento de Proyectos TFG para el rol de **Estudiante**.

## 1. Acceso y Dashboard

Al iniciar sesión, el Estudiante accede a un **Dashboard** personalizado que muestra:

*   **Resumen del Proyecto**: Título, tutor asignado y estado general (ej. `En Desarrollo`).
*   **Tareas Pendientes**: Un listado rápido de las tareas asignadas con la fecha límite más próxima.
*   **Notificaciones**: Alertas sobre nuevos comentarios, cambios de estado de tareas o la aprobación/rechazo del anteproyecto.
*   **Mensajes**: Acceso rápido al sistema de mensajería con tu tutor (ícono 💬 en la barra superior).

## 2. Gestión del Anteproyecto

El ciclo de vida del TFG comienza con la propuesta del Anteproyecto.

### 2.1. Creación de la Propuesta

1.  Navegue a la sección **"Anteproyectos"**.
2.  Haga clic en **"Crear Nuevo Anteproyecto"**.
3.  Complete el formulario con la siguiente información:
    *   **Título** y **Descripción/Justificación** del proyecto.
    *   **Tipo de Proyecto** (ej. `Ejecución`, `Investigación`).
    *   **Objetivos**: Seleccione los objetivos académicos que cubre el proyecto (basados en las competencias DAM).
    *   **Resultados Esperados (Hitos)**: Defina los puntos de control clave y las fechas estimadas.
4.  El sistema generará automáticamente un borrador en formato PDF.

### 2.2. Envío para Revisión

Una vez que la propuesta esté completa, cambie el estado a **"Enviar para Revisión"**.

*   El sistema notifica automáticamente al Tutor asignado.
*   El estado del Anteproyecto cambiará a `Enviado` o `En Revisión`.

### 2.3. Resultado de la Revisión

El Tutor puede:

| Resultado | Acción | Consecuencia |
| :--- | :--- | :--- |
| **Aprobado** | El sistema crea automáticamente el **Proyecto** activo. | El Estudiante puede comenzar a gestionar tareas en el tablero Kanban. |
| **Rechazado** | El Tutor proporciona una justificación y comentarios. | El Estudiante debe modificar la propuesta y reenviarla. |

## 3. Gestión de Tareas (Tablero Kanban)

Una vez que el Anteproyecto es aprobado, el Estudiante gestiona el desarrollo a través del **Tablero Kanban** del Proyecto.

### 3.1. Creación de Tareas

Las tareas pueden crearse de dos formas:

1.  **Manual**: El Estudiante define las tareas necesarias para alcanzar los hitos.
2.  **Automática**: El sistema puede generar tareas a partir de plantillas o, si está integrado, a través del **MCP Server** (IA).

### 3.2. Flujo de Trabajo Kanban

El tablero está dividido en columnas que representan el estado de la tarea:

| Columna | Descripción | Acción del Estudiante |
| :--- | :--- | :--- |
| **Pendiente** | Tareas planificadas pero no iniciadas. | Mover a `En Progreso` al comenzar. |
| **En Progreso** | Tareas en las que se está trabajando activamente. | Mantener actualizada la descripción y el progreso. |
| **En Revisión** | Tareas completadas y listas para la revisión del Tutor. | Mover a `Completada` si el Tutor aprueba. |
| **Completada** | Tareas finalizadas y aprobadas. | No requiere más acción. |

**Para cambiar el estado**, simplemente arrastre la tarjeta de la tarea a la columna correspondiente.

### 3.3. Detalle de la Tarea

Al hacer clic en una tarea, el Estudiante puede:

*   **Comentar**: Dejar preguntas o notas para el Tutor.
*   **Subir Archivos**: Adjuntar entregas, código o documentos de apoyo.
*   **Historial**: Ver el registro de actividad y cambios de estado.

**Nota**: También puedes comunicarte con tu tutor mediante el sistema de mensajes (ícono 💬 en la barra superior), que permite crear hilos de conversación organizados por tema dentro de cada proyecto.

## 4. Seguimiento y Finalización

El Estudiante debe monitorear el progreso del proyecto y el cumplimiento de los hitos.

*   **Hitos**: Consulte la sección de Hitos para asegurarse de que las tareas se alinean con las fechas de entrega clave.
*   **Entrega Final**: Una vez que todas las tareas y hitos estén completados, el Tutor puede marcar el Proyecto como **Finalizado**.

---
*Esta guía se basa en la Especificación Funcional del proyecto TFG.*
