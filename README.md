# 🎓 Sistema de Seguimiento de Proyectos TFG - Ciclo DAM

## 🎯 **PROPÓSITO DEL PROYECTO**

Este proyecto es el **Sistema de Seguimiento de Proyectos de Trabajo de Fin de Grado (TFG)**, desarrollado como parte del Ciclo Formativo de Grado Superior de **Desarrollo de Aplicaciones Multiplataforma (DAM)**.

Su objetivo principal es modernizar y centralizar la gestión del proceso de TFG, proporcionando una plataforma digital única que facilita la colaboración, el seguimiento y la evaluación de los proyectos académicos entre estudiantes, tutores y la administración del centro.

---

## 💡 **PROBLEMA QUE RESUELVE**

Tradicionalmente, la gestión de los Trabajos de Fin de Grado (TFG) en centros educativos se enfrenta a varios desafíos:

1.  **Descentralización de la Información**: La documentación, los avances, las entregas y el *feedback* se dispersan en correos electrónicos, documentos físicos y plataformas variadas, dificultando el seguimiento.
2.  **Falta de Transparencia en el Proceso**: Los estudiantes a menudo carecen de una visión clara de su progreso y de los hitos esperados, mientras que los tutores invierten tiempo excesivo en tareas administrativas.
3.  **Ineficiencia en la Evaluación**: El flujo de aprobación de anteproyectos y la revisión de tareas son procesos manuales y lentos, lo que retrasa el inicio del desarrollo.

**Este sistema resuelve la problemática** al ofrecer una solución unificada que digitaliza el ciclo de vida completo del TFG, desde la propuesta inicial hasta la entrega final.

---

## 🚀 **SOLUCIÓN Y CARACTERÍSTICAS CLAVE**

El Sistema de Seguimiento de Proyectos TFG es una aplicación **multiplataforma** que implementa las mejores prácticas de gestión de proyectos (Kanban) en un entorno académico.

| Característica | Descripción | Beneficio |
| :--- | :--- | :--- |
| **Gestión por Roles** | Acceso y permisos diferenciados para **Administradores**, **Tutores** y **Estudiantes**. | Seguridad y personalización de la experiencia según las necesidades del usuario. |
| **Flujo de Anteproyectos** | Formulario guiado para la propuesta de TFG, con un **flujo de aprobación** formal por parte del tutor. | Estandarización y agilización del proceso de inicio del proyecto. |
| **Tablero Kanban** | Gestión visual de tareas por estado (`Pendiente`, `En Progreso`, `En Revisión`, `Completada`). | Claridad en el progreso, facilita la priorización y el seguimiento. |
| **Multiplataforma** | Desarrollado con **Flutter**, la aplicación funciona de forma nativa en **Web**, **Android**, **iOS** y **Escritorio**. | Accesibilidad total desde cualquier dispositivo sin necesidad de desarrollo separado. |
| **Backend en Tiempo Real** | Utiliza **Supabase** para la base de datos (PostgreSQL), autenticación y suscripciones en tiempo real. | Escalabilidad, seguridad (RLS) y notificaciones instantáneas. |

---

## 🏗️ **ARQUITECTURA TÉCNICA Y TECNOLOGÍAS**

El proyecto sigue una arquitectura moderna y desacoplada, utilizando un *stack* tecnológico robusto:

### **Frontend (Cliente)**
*   **Framework**: **Flutter 3.x** (Dart)
*   **Gestión de Estado**: **BLoC** (Business Logic Component) para una lógica de negocio clara y testeable.
*   **Navegación**: **go_router** para una navegación robusta y compatible con la web.
*   **Internacionalización**: Soporte completo para Español e Inglés.

### **Backend (Servicios)**
*   **Plataforma**: **Supabase** (Backend-as-a-Service)
*   **Base de Datos**: **PostgreSQL** con un modelo de datos relacional completo (19 tablas).
*   **Seguridad**: **Row Level Security (RLS)** implementada para asegurar que cada usuario solo acceda a sus propios datos.
*   **Autenticación**: **Supabase Auth** con tokens JWT.
*   **APIs**: Uso de **Edge Functions** (servicios *serverless*) para lógica de negocio avanzada (ej. flujos de aprobación).

---

## 📚 **DOCUMENTACIÓN Y GUÍAS**

La documentación técnica y de usuario se encuentra en el directorio `docs/`.

| Documento | Descripción |
| :--- | :--- |
| `docs/arquitectura/` | Especificaciones funcionales, lógica de roles y flujo de autenticación. |
| `docs/base_datos/` | Modelo de datos completo y scripts de migración SQL para Supabase. |
| `docs/desarrollo/` | Guías de configuración del entorno, comandos útiles y *troubleshooting*. |
| `docs/guias_usuario/` | Manuales de uso específicos para Administradores, Tutores y Estudiantes. |

---

## 🚀 **INICIO RÁPIDO PARA DESARROLLADORES**

Para poner en marcha el proyecto, consulta la guía detallada en `docs/desarrollo/01-configuracion/guia_inicio_frontend_ACTUALIZADA.md`.

**Comandos Esenciales:**
```bash
# Clonar el repositorio
git clone https://github.com/elmosca/proyecto_flutter_supabase.git
cd proyecto_flutter_supabase/frontend

# Instalar dependencias
flutter pub get

# Generar código (modelos JSON, etc.)
flutter packages pub run build_runner build

# Ejecutar en Web (entorno de desarrollo)
flutter run -d chrome
```

---

## 👥 **ESTADO ACTUAL**

El **Producto Mínimo Viable (MVP)** está **100% completado** y funcional. El proyecto está listo para ser utilizado en un entorno de pruebas o para su presentación final.

**Próximo Paso:** La documentación detallada para el usuario final se está consolidando en la **Wiki del Proyecto**.

---

## 📞 **CONTACTO**

Para cualquier duda o colaboración, contactar con el equipo de desarrollo.
*   **Estudiante/Autor**: [Nombre del Estudiante]
*   **Tutor**: [Nombre del Tutor]
*   **Repositorio**: [URL del Repositorio]
