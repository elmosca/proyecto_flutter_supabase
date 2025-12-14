# Guía del Administrador

Esta guía detalla las funcionalidades y el flujo de trabajo dentro del Sistema de Seguimiento de Proyectos TFG para el rol de **Administrador**. El Administrador tiene control total sobre el sistema, la gestión de usuarios y la configuración global.

## 1. Acceso y Dashboard

El Dashboard del Administrador proporciona una visión global del sistema:

*   **Estadísticas Globales**: Número total de usuarios, proyectos activos, anteproyectos pendientes y tareas completadas.
*   **Filtro de Proyectos**: Acceso a un listado completo de **todos** los proyectos, con opciones de filtrado por Tutor, Estudiante, Estado y Año Académico.
*   **Alertas del Sistema**: Notificaciones sobre posibles problemas de configuración o *logs* de errores.

### 1.1. Navegación con Menú Hamburguesa

La aplicación cuenta con un **menú hamburguesa persistente** (ícono ☰ en la esquina superior izquierda) que proporciona acceso rápido a todas las secciones principales:

*   **Panel Principal**: Dashboard con estadísticas globales del sistema
*   **Notificaciones**: Alertas y notificaciones del sistema
*   **Gestionar Usuarios**: Administración de usuarios y roles
*   **Flujo de Aprobación**: Gestión del flujo de aprobación de anteproyectos
*   **Configuración del Sistema**: Configuración global del sistema
*   **Ayuda**: Guía de uso del sistema

El menú está siempre disponible en todas las pantallas de la aplicación, proporcionando navegación consistente y rápida.

## 2. Gestión de Usuarios y Roles

El Administrador es el único rol con capacidad para gestionar la base de usuarios.

### 2.1. Creación de Usuarios

1.  Navegue a la sección **"Gestionar Usuarios"** desde el menú hamburguesa.
2.  Haga clic en **"Crear Nuevo Usuario"**.
3.  Complete los campos obligatorios:
    *   **Nombre Completo** y **Email**.
    *   **Rol**: Asigne el rol correcto (`Administrador`, `Tutor` o `Estudiante`).
    *   **NRE**: Campo obligatorio para los Estudiantes.
4.  El sistema enviará automáticamente un correo de bienvenida o de configuración de contraseña al nuevo usuario.

### 2.2. Asignación y Modificación de Roles

*   **Modificación**: Puede cambiar el rol de cualquier usuario en cualquier momento (ej. un Tutor que pasa a ser Administrador).
*   **Activación/Desactivación**: Puede cambiar el estado de un usuario a `Activo` o `Inactivo` para revocar el acceso sin eliminar la cuenta.

## 3. Supervisión Global de Proyectos

El Administrador tiene acceso de lectura a todos los datos del sistema.

### 3.1. Visión General de Proyectos

*   **Listado Completo**: Acceda al listado de proyectos para ver el estado de cada TFG en la institución.
*   **Auditoría**: Puede acceder al detalle de cualquier Anteproyecto o Proyecto para auditar el proceso de revisión del Tutor o el progreso del Estudiante.

### 3.2. Informes y Exportación

*   **Generación de Informes**: El sistema permite generar informes de actividad y progreso.
    *   **Informe de Proyectos**: Exportación a CSV o PDF de todos los proyectos, incluyendo estado y fechas clave.
    *   **Informe de Usuarios**: Listado de usuarios por rol y estado.
*   **Exportación de Datos**: Acceso a la funcionalidad de exportación de datos completos del sistema para fines de *backup* o análisis externo.

## 4. Configuración del Sistema

El Administrador gestiona los parámetros globales del sistema.

### 4.1. Gestión de Objetivos Académicos

*   **Objetivos DAM**: Puede añadir, editar o desactivar los objetivos académicos que se muestran en el formulario de Anteproyecto.

### 4.2. Plantillas de Documentos

*   **Plantillas PDF**: Gestión de las plantillas utilizadas para la generación automática de documentos (ej. el formato oficial del Anteproyecto).

### 4.3. Configuración de Notificaciones

*   **Parámetros de Email**: Revisión y ajuste de la configuración de envío de correos electrónicos (ej. plantillas de bienvenida, restablecimiento de contraseña).

### 4.4. Automatización del Año Académico

*   **Gestión Automática**: El sistema crea y gestiona automáticamente los años académicos en la base de datos, eliminando la necesidad de configuración manual al inicio de cada curso.

---
*Esta guía se basa en la Especificación Funcional del proyecto TFG.*
