# 📄 Documento Funcional del Proyecto
# Sistema de Seguimiento de Proyectos TFG - Ciclo DAM

> **Nota importante**: Este documento utiliza términos en español para la interfaz de usuario, pero el modelo de datos utiliza nomenclatura en inglés para mantener estándares de desarrollo. Los estados, roles y tipos se especifican en inglés en la base de datos.

## 1. 🎯 Objetivo General
Facilitar la planificación, ejecución, seguimiento y evaluación del Trabajo de Fin de Grado (TFG) del ciclo formativo de Desarrollo de Aplicaciones Multiplataforma (DAM), mediante una plataforma digital colaborativa centrada en la gestión por tareas y el flujo de trabajo tipo Kanban.

## 2. 👥 Roles del Sistema

| Rol | Descripción |
|-----|-------------|
| **Administrador** | Control total del sistema. Gestiona usuarios, roles, y visualiza todos los proyectos. |
| **Tutor** | Supervisa proyectos asignados. Revisa anteproyectos, comenta y realiza seguimiento del progreso. |
| **Alumno** | Desarrolla el proyecto. Consulta y completa tareas, sube entregas y responde feedback. |

## 3. 📚 Entidades Principales

### 3.1. Usuario
- Nombre completo
- Email (único)
- NRE (Número Regional de Estudiante) - solo para alumnos, único
- Rol (administrador, tutor, alumno)
- Teléfono (opcional)
- Biografía / Observaciones
- Estado (activo / inactivo)

### 3.2. Proyecto
- Título
- Descripción
- Estado (draft, planning, development, review, completed)
- Fecha de inicio
- Fecha límite estimada
- Tutor asignado
- Alumnos asignados (uno o varios)

**Datos del Anteproyecto:**
- Tipo de proyecto (execution, research, bibliographic, management)
- Objetivos específicos
- Resultados esperados (hitos)
- Temporalización inicial
- Estado de aprobación (draft, submitted, under_review, approved, rejected)
- Historial de cambios

### 3.3. Tarea
- Título
- Descripción
- Estado (pending, in_progress, under_review, completed)
- Responsable (usuario)
- Fecha de creación
- Fecha límite
- Entregas asociadas (archivos)
- Comentarios / feedback
- Fecha de finalización (si aplica)

### 3.4. Comentario
- Autor
- Fecha y hora
- Contenido
- Asociado a una tarea

### 3.5. Archivo
- Nombre
- Fecha de subida
- Usuario que lo sube
- Enlace de descarga o previsualización
- Asociado a una tarea o comentario

### 3.6. Anteproyecto
- ID único
- Título del proyecto
- Tipo de proyecto (execution, research, bibliographic, management)
- Descripción/Justificación
- Objetivos (lista de competencias seleccionadas)
- Resultados esperados (hitos)
- Temporalización (fechas clave)
- Estado (draft, submitted, under_review, approved, rejected)
- Alumno/s autor/es
- Tutor asignado
- Fecha de envío
- Fecha de evaluación
- Comentarios del tutor
- Archivo PDF generado
- Proyecto asociado (una vez aprobado)

### 3.7. Notificación
- ID único
- Tipo (tarea_nueva, comentario_nuevo, entrega_recibida, anteproyecto_enviado, etc.)
- Usuario destinatario
- Título
- Mensaje
- Fecha de creación
- Leída (boolean)
- Enlace de acción (opcional)
- Datos adicionales (JSON para información específica)

### 3.8. Hito
- ID único
- Número de hito (1, 2, 3, 4...)
- Descripción
- Fecha prevista
- Fecha real de completado
- Estado (pending, in_progress, completed, delayed)
- Proyecto asociado
- Tareas relacionadas
- Comentarios de revisión

## 4. 📋 Funcionalidades por Rol

### Alumno
- Visualizar su proyecto y tareas asociadas
- Marcar tareas como finalizadas
- Subir archivos de entrega
- Leer y responder comentarios del tutor
- Consultar el tablero Kanban de su proyecto
- Ver estadísticas personales de progreso

### Tutor
- Revisar y aprobar anteproyectos
- Comentar tareas y marcar revisiones
- Visualizar progreso del alumno
- Adjuntar archivos a tareas o comentarios
- Aprobar o cerrar el proyecto
- Supervisar el cumplimiento de hitos y objetivos

### Administrador
- Crear usuarios y asignar roles
- Visualizar y filtrar todos los proyectos
- Acceder a todas las tareas
- Gestionar configuración general (si aplica)
- Exportar informes de proyectos y tareas

### Colaborador
- Ver tareas asignadas
- Comentar en tareas
- Subir archivos de apoyo

## 5. 📌 Flujo General del Usuario

### 5.1. Alumno propone anteproyecto:
- Formulario estructurado con campos obligatorios
- Selección de tipo de proyecto
- Definición de objetivos y resultados esperados
- Propuesta de temporalización
- Generación automática de PDF con formato oficial
- Envío automático al tutor asignado
- Notificación de envío al alumno

### Tutor revisa anteproyecto:
- Recibe notificación de nuevo anteproyecto
- Descarga PDF del anteproyecto
- Evalúa viabilidad y coherencia
- Añade comentarios y sugerencias
- Aprueba, rechaza o solicita modificaciones
- Notifica al alumno el resultado

### 5.2. Dashboard Personalizado
- Listado de tareas activas
- Progreso de proyecto
- Estadísticas semanales
- Últimas actualizaciones

### 5.3. Gestión de Proyectos
Acceso al detalle del proyecto:
- Información general
- Participantes
- Tareas
- Archivos
- Historial de actividades

### 5.4. Vista Kanban
Tablero dividido por estados:
- Tareas pendientes
- En progreso
- En revisión
- Completadas

Arrastrar tareas entre columnas

### 5.5. Gestión de Tareas
- Ficha de tarea que se puede generar de múltiples formas:
  - **MCP Server**: IA analiza el anteproyecto y propone tareas automáticamente
  - **Definición manual**: El alumno define las tareas para su proyecto
  - **Plantillas**: Tareas predefinidas de buenas prácticas para desarrollo de software
- Añadir comentarios, archivos y etiquetas
- Cambiar estado de progreso
- Historial de cambios y actividad

### 5.6. Gestión de Anteproyectos (Tutor/Administrador)
- Lista de anteproyectos pendientes de revisión
- Descarga de anteproyectos en formato PDF
- Formulario de evaluación con criterios específicos
- Sistema de comentarios para feedback
- Aprobación/rechazo con justificación
- Una vez aprobado, se crea un proyecto único asociado

## 6. 📈 Paneles y Estadísticas
- Progreso por porcentaje de tareas completadas
- Número de tareas por estado
- Entregas realizadas vs tareas asignadas
- Vista de calendario con fechas límite
- Historial de tareas completadas

## 7. 🔔 Notificaciones
- Cambios en estado de tarea
- Nuevos comentarios
- Entregas recibidas
- Asignaciones nuevas
- Se podrán recibir por email y/o dentro del sistema

## 8. 🔐 Seguridad y Accesos
- Sistema de autenticación y gestión de sesiones
- Permisos por rol definidos
- Validación de datos en formularios
- Protección de archivos sensibles
- Posibilidad de autenticación social (futuro)

## 9. 📤 Exportación e Informes
Generar informes de:
- Progreso del proyecto
- Actividad por tarea
- Participación del alumno
- Exportación de anteproyectos en PDF con formato oficial
- Exportables en PDF o CSV
- Opcional: resumen visual en HTML para presentación

## 10. 🧱 Restricciones y Consideraciones
- Un proyecto puede tener uno o varios alumnos asignados
- Un proyecto tiene un único tutor responsable
- Todo proyecto debe comenzar con un anteproyecto aprobado
- Un anteproyecto puede generar un solo proyecto (relación 1:1)
- Los anteproyectos deben incluir objetivos SMART y temporalización realista
- Los milestones solo pertenecen a proyectos, no a anteproyectos
- Las tareas se pueden generar de múltiples formas: MCP Server, definición manual del alumno, o plantillas predefinidas
- Cada usuario accede solo a su espacio de trabajo
- No se permite que un usuario cree su propio proyecto sin anteproyecto previo

## 11. 📋 Plantilla de Anteproyecto

### Estructura Obligatoria:

**Encabezado:**
- El alumno [Nombre/s del alumno/s], del CIFP Carlos III de Cartagena
- Matriculado durante el curso académico [año académico]
- Módulo de Proyecto del ciclo formativo de grado superior Desarrollo de Aplicaciones Multiplataforma (modalidad distancia)
- Propone al tribunal para su aceptación la realización del siguiente proyecto:

**Contenido del Anteproyecto:**

- **Título:** "TituloDelProyecto"

- **Tipo de proyecto:** (seleccionar uno)
  - Proyecto de execution o realización de un producto
  - Proyecto de research experimental o innovación
  - Proyecto bibliographic o documental
  - Proyecto de management, análisis de mercado, viabilidad o mercadotecnia

- **Descripción:** Breve descripción o justificación del proyecto

- **Objetivos:** (basados en competencias del ciclo DAM)
  - Consolidar los conocimientos adquiridos durante el ciclo sobre herramientas de desarrollo y técnicas de análisis y diseño de aplicaciones
  - Llevar a cabo el análisis de requisitos previo al desarrollo de software
  - Elegir las herramientas y tecnologías oportunas para implementar la solución
  - Implementar el esquema relacional tomando como partida un modelo de datos previamente analizado
  - Explotar una base de datos relacional como soporte no volátil de la información
  - Codificar rutinas con lenguajes del lado del servidor (back-end)
  - Codificar rutinas con lenguajes del lado del cliente (front-end)
  - Diseñar la interfaz de una aplicación atendiendo a los requerimientos
  - Documentar un proyecto elaborando las guías de instalación y memoria técnica

- **Resultados esperados:** (hitos medibles)
  - Hito 1: [Descripción funcionalidad 1]
  - Hito 2: [Descripción funcionalidad 2]
  - Hito 3: [Descripción funcionalidad 3]
  - Hito 4: [Descripción funcionalidad 4]
  - [Agregar más hitos si procede]

- **Temporalización inicial:**
  - [Fecha intermedia]: Revisión del esquema de datos y primer prototipo
  - [Fecha intermedia]: Revisión de los hitos 1 y 2
  - [Fecha intermedia]: Revisión de los hitos 3 y 4 y correcciones sobre hitos anteriores
  - [Fecha final]: Revisión final e indicaciones para presentación y exposición

**Pie:**
- En Cartagena, a [día] de [mes] de [año]

### Criterios de Evaluación del Anteproyecto:
- Viabilidad técnica y temporal
- Coherencia entre objetivos y resultados esperados
- Adecuación a las competencias del ciclo DAM
- Claridad en la descripción y justificación
- Realismo en la temporalización propuesta
- Cumplimiento de la estructura obligatoria

## 12. 🔧 Funcionalidades Adicionales del Sistema

### 12.1. Generación de PDF del Anteproyecto:
- Plantilla oficial con encabezado del CIFP Carlos III
- Formato estructurado según especificaciones académicas
- Datos del alumno integrados automáticamente
- Fecha y lugar generados automáticamente
- Descarga inmediata tras completar el formulario
- Almacenamiento en el sistema para consultas posteriores

### 12.2. Notificaciones Relacionadas:
- Envío de anteproyecto al tutor
- Confirmación de recepción
- Estado de revisión (pendiente/en proceso/completado)
- Resultado de la evaluación

### 12.3. Gestión de Archivos:
- Subida de múltiples archivos por tarea
- Previsualización de documentos comunes
- Control de versiones de entregas
- Límites de tamaño y tipos de archivo permitidos

### 12.4. Sistema de Backup y Recuperación:
- Backup automático de datos
- Historial de cambios detallado
- Recuperación de versiones anteriores
- Exportación de datos completos
