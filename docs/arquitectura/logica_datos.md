# 🧠 Lógica del Modelo de Datos
Este documento explica la lógica del modelo de datos del Sistema de Seguimiento de Proyectos TFG (Ciclo DAM). Aporta el razonamiento detrás del diseño de entidades, relaciones, restricciones y optimizaciones.

## 1. 👥 Usuarios (users)
Contiene toda la información de los usuarios del sistema. Se distinguen tres roles:

- **admin**: gestiona el sistema completo.
- **tutor**: guía académicamente a los alumnos.
- **student**: desarrolla el TFG.

El campo `nre` se asigna solo a estudiantes. Se controla el estado del usuario (`active/inactive`) y se registra el `email_verified_at` para gestión de acceso.

## 2. 📑 Anteproyectos (anteprojects) y Evaluación
El anteproyecto recoge el diseño inicial del TFG y sirve como base para su aprobación. Incluye:

- Título, tipo, descripción, cronograma y resultados esperados.
- Relación con tutor (`tutor_id`) y autores (`anteproject_students`).
- Relación con objetivos (`anteproject_objectives`) usando los objetivos del ciclo DAM.
- Evaluaciones mediante criterios establecidos (`anteproject_evaluations`).

Este diseño permite validar la coherencia académica del proyecto antes de iniciar su ejecución.

## 3. 🚧 Proyecto Final (projects)
Es el proyecto activo tras la aprobación del anteproyecto. Incluye:

- Referencia al anteproyecto (`anteproject_id`)
- Estado (`draft`, `planning`, `development`, `review`, `completed`)
- Tutor, fechas clave, y URL de repositorio GitHub para seguimiento técnico.
- Relación con estudiantes (`project_students`) y sus tareas.

## 4. 🧱 Tareas y Hitos

### milestones
Representan etapas clave del proyecto durante su ejecución. Tienen tipo (`planning`, `execution`, `review`, `final`) y se vinculan únicamente a `projects`. Incluyen estados (`pending`, `in_progress`, `completed`, `delayed`). Los anteproyectos no tienen milestones, solo definen resultados esperados en formato JSON.

### tasks
Representan el trabajo granular del proyecto. Se pueden generar de múltiples formas:
- **MCP Server**: IA analiza el anteproyecto y propone tareas automáticamente
- **Definición manual**: El alumno define las tareas para su proyecto
- **Plantillas**: Tareas predefinidas de buenas prácticas para desarrollo de software

Relación con `milestones`, incluyen estado (`pending`, `in_progress`, `under_review`, `completed`), fechas, horas estimadas, complejidad, y etiquetas (`tags`).

### task_assignees
Relaciona tareas con usuarios responsables, facilitando la trazabilidad del progreso.

## 5. 💬 Comentarios y Archivos

### comments
Permiten discusión en cada tarea. `is_internal` permite comentarios privados del tutor.

### files
Relación polimórfica única para asociar archivos a tareas, comentarios o anteproyectos. Se incluye versión de archivos (`file_versions`) para trazabilidad. La relación se establece mediante `attachable_type` y `attachable_id`.

## 6. 🔔 Notificaciones (notifications)
Mecanismo para avisos automáticos: asignación de tareas, comentarios nuevos, cambios de estado, etc. Pueden extenderse a notificaciones por email.

## 7. 📜 Registro de Actividad (activity_log)
Permite auditar todas las acciones importantes: quién modificó qué, cuándo, desde qué IP y navegador. Clave para trazabilidad y seguridad.

## 8. ⚙️ Configuración del Sistema (system_settings)
Define valores globales (nombre de la institución, límites de archivo, duración máxima de proyectos…). Editable solo por administradores.

## 9. 🧩 Plantillas PDF (pdf_templates)
Permite personalizar documentos exportables del sistema: memoria de anteproyecto, informes de proyecto, etc. Define versiones y tipos.

## 🔐 Validaciones y Triggers
- Validación de roles y campos (por ejemplo, solo alumnos con `nre`).
- Triggers automáticos para mantener consistencia y notificaciones (como cambios en GitHub, actualización de actividad).
- Validación de URLs, incremento automático de versiones y registro de acciones.

## ✅ Conclusión
Este modelo de datos soporta todo el flujo de trabajo del TFG: desde el anteproyecto, pasando por el desarrollo y evaluación, hasta la documentación final. Su estructura modular y relacional permite escalar fácilmente, auditar acciones, y asegurar una trazabilidad completa del proceso.
