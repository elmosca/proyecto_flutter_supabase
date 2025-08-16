# 📋 Plan de Proyecto: Sistema de Seguimiento TFG - MVP (3 Meses)

## 1. 🎯 Objetivo del MVP
El objetivo es desarrollar una plataforma funcional y colaborativa que permita a alumnos, tutores y administradores gestionar y dar seguimiento a los TFG del ciclo DAM, con un enfoque en la creación y supervisión de anteproyectos, la planificación de tareas y la comunicación básica. El proyecto deberá ser completado por una sola persona en tres meses, trabajando un promedio de 3 horas diarias.

## 2. 🧱 Tecnologías Clave
- **Frontend:** Flutter para aplicaciones multiplataforma (web, Android, iOS y escritorio).
- **Backend:** Supabase, que incluye PostgreSQL, autenticación, almacenamiento de archivos y funciones serverless.

## 3. 🗓️ Fases del Proyecto y Cronograma Estimado (3 Meses)

### Fase 1: Configuración e Implementación del Backend (Semanas 1-4)

#### Configuración de Supabase
- Crear el proyecto y las tablas, aplicando el modelo de datos detallado que hemos definido.

#### Autenticación y Roles
- Implementar el registro, login y gestión de perfiles de usuario.
- Configurar las políticas de RLS para que los usuarios solo puedan ver sus propios datos o los datos relevantes a su rol.

#### Flujo del Anteproyecto
**Creación del Anteproyecto:**
- Implementar la lógica para que los alumnos puedan rellenar un formulario basado en la plantilla oficial.

**Almacenamiento de Anteproyectos:**
- Guardar la información del anteproyecto en la base de datos (anteprojects, anteproject_objectives, anteproject_students).

**Aprobación/Rechazo:**
- El tutor tendrá una vista para revisar los anteproyectos, añadir comentarios y aprobarlos.

### Fase 2: Desarrollo del Frontend y Flujo Básico (Semanas 5-8)

#### Interfaz de Usuario Básica
- Construir la interfaz de usuario para el login, el dashboard principal y las vistas de anteproyectos.

#### Gestión de Proyectos
- Implementar las funcionalidades básicas para ver los proyectos una vez que el anteproyecto haya sido aprobado.

#### Planificación de Tareas
**Generación Automática de Tareas:**
- Las tareas se generan automáticamente desde los hitos del anteproyecto aprobado.

**Visualización de Tareas:**
- Mostrar una lista simple de tareas generadas automáticamente.

**Cambio de Estado:**
- Permitir a los usuarios cambiar el estado de las tareas (por ejemplo, a través de un menú desplegable, sin necesidad de un tablero Kanban con arrastrar y soltar).

**Comentarios y Archivos:**
- Implementar las funcionalidades para añadir comentarios a las tareas y subir archivos básicos.

### Fase 3: Funcionalidades de Colaboración y Despliegue (Semanas 9-12)

#### Notificaciones Internas
- Utilizar Supabase Realtime para notificar a los usuarios de los cambios de estado en las tareas o la adición de nuevos comentarios.

#### Generación de Documentos
- En el MVP, se podría implementar una vista en HTML/CSS que represente la plantilla del anteproyecto.

#### Despliegue del MVP
- Publicar la aplicación en un entorno web.

#### Pruebas Básicas
- Realizar pruebas funcionales y de usabilidad en la versión web para corregir errores.

## 4. 🔮 Implementaciones Futuras (Post-MVP)
Estas funcionalidades se dejan para una segunda fase o para otro equipo, si fuera el caso, ya que requieren más tiempo y complejidad:

### Tablero Kanban Interactivo
- Implementar la funcionalidad de arrastrar y soltar para mover las tarjetas de tareas entre las columnas del tablero.

### Generación de PDF con Formato Oficial
- Desarrollo de una función serverless o un servicio externo para generar PDFs que cumplan con el formato oficial del CIFP Carlos III.

### Notificaciones Push y por Correo Electrónico
- Ampliar el sistema de notificaciones para enviar alertas fuera de la aplicación.

### Paneles de Control y Estadísticas Avanzadas
- Crear gráficos y métricas detalladas sobre el progreso del proyecto, las tareas por estado y las fechas límite.

### Integración con GitHub
- Conectar el sistema con la API de GitHub para mostrar el último commit o la actividad del repositorio del proyecto.

### Despliegue a Tiendas de Aplicaciones
- Adaptar el proyecto para publicarlo en la App Store (iOS) y Google Play Store (Android).

## 5. 📊 Cronograma Detallado

### Mes 1: Backend y Autenticación
| Semana | Tareas | Entregables |
|--------|--------|-------------|
| **Semana 1** | Configuración Supabase, Modelo de datos | Esquema de BD, Tablas creadas |
| **Semana 2** | Autenticación, RLS Policies | Sistema de login funcional |
| **Semana 3** | API Anteproyectos | Endpoints CRUD anteproyectos |
| **Semana 4** | Flujo de aprobación | Sistema de revisión tutor |

### Mes 2: Frontend Básico
| Semana | Tareas | Entregables |
|--------|--------|-------------|
| **Semana 5** | UI Login, Dashboard | Interfaz básica navegable |
| **Semana 6** | Gestión proyectos | Vista de proyectos |
| **Semana 7** | CRUD Tareas | Sistema de tareas funcional |
| **Semana 8** | Comentarios, Archivos | Comunicación básica |

### Mes 3: Integración y Despliegue
| Semana | Tareas | Entregables |
|--------|--------|-------------|
| **Semana 9** | Notificaciones Realtime | Alertas en tiempo real |
| **Semana 10** | Generación documentos | Vista HTML anteproyecto |
| **Semana 11** | Testing, Correcciones | MVP estable |
| **Semana 12** | Despliegue, Documentación | MVP en producción |

## 6. 🎯 Criterios de Éxito del MVP

### Funcionalidades Core (Obligatorias)
- [ ] Usuarios pueden registrarse y autenticarse
- [ ] Alumnos pueden crear anteproyectos
- [ ] Tutores pueden revisar y aprobar anteproyectos
- [ ] Las tareas se generan automáticamente desde los hitos del anteproyecto
- [ ] Sistema de comentarios funcional
- [ ] Subida de archivos básica
- [ ] Notificaciones en tiempo real
- [ ] Aplicación web desplegada y funcional

### Métricas de Éxito
- **Tiempo de desarrollo:** ≤ 3 meses
- **Horas de trabajo:** ≤ 270 horas (3h/día × 90 días)
- **Funcionalidades core:** 100% implementadas
- **Bugs críticos:** 0 en producción
- **Usabilidad:** Test de usabilidad exitoso con 3 usuarios

## 7. 🛠️ Stack Tecnológico MVP

### Backend (Supabase)
- **Base de datos:** PostgreSQL
- **Autenticación:** Supabase Auth
- **Storage:** Supabase Storage
- **Realtime:** Supabase Realtime
- **API:** Supabase REST API

### Frontend (Flutter)
- **Framework:** Flutter 3.x
- **Estado:** Provider/Riverpod
- **HTTP Client:** Supabase Flutter Client
- **UI:** Material Design 3
- **Plataforma:** Web (prioritario), Android/iOS (futuro)

### Herramientas de Desarrollo
- **IDE:** VS Code / Android Studio
- **Control de versiones:** Git
- **Despliegue:** Vercel/Netlify (web)
- **Testing:** Flutter Test
- **Documentación:** Markdown

## 8. 📋 Checklist de Desarrollo

### Semana 1-4: Backend
- [ ] Configurar proyecto Supabase
- [ ] Crear tablas según modelo de datos
- [ ] Implementar autenticación
- [ ] Configurar políticas RLS
- [ ] Crear API endpoints básicos
- [ ] Implementar flujo anteproyectos

### Semana 5-8: Frontend
- [ ] Configurar proyecto Flutter
- [ ] Implementar autenticación UI
- [ ] Crear dashboard principal
- [ ] Implementar CRUD anteproyectos
- [ ] Crear visualización de tareas generadas automáticamente
- [ ] Implementar comentarios y archivos

### Semana 9-12: Integración
- [ ] Configurar notificaciones Realtime
- [ ] Implementar generación documentos
- [ ] Realizar testing completo
- [ ] Corregir bugs y optimizar
- [ ] Desplegar MVP
- [ ] Documentar código y APIs

## 9. 🚨 Riesgos y Mitigaciones

### Riesgos Técnicos
| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Complejidad Flutter | Media | Alto | Usar patrones simples, documentación oficial |
| Configuración Supabase | Baja | Medio | Seguir guías oficiales, testing temprano |
| Integración Flutter-Supabase | Media | Alto | Usar cliente oficial, ejemplos verificados |

### Riesgos de Tiempo
| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Subestimación de tareas | Alta | Alto | Buffer de 20% en cronograma |
| Problemas técnicos | Media | Medio | Plan de contingencia, recursos alternativos |
| Cambios de requisitos | Baja | Alto | MVP bien definido, cambios post-MVP |

## 10. 📈 Métricas de Seguimiento

### Semanales
- **Progreso:** % de tareas completadas vs planificadas
- **Tiempo:** Horas trabajadas vs estimadas
- **Bugs:** Número de bugs críticos/mayores
- **Funcionalidades:** % de features MVP completadas

### Mensuales
- **Calidad:** Cobertura de tests
- **Performance:** Tiempo de respuesta de la aplicación
- **Usabilidad:** Feedback de usuarios de prueba
- **Documentación:** % de código documentado

Este plan te permite presentar un producto sólido y funcional en el plazo de tres meses, demostrando las capacidades de las tecnologías elegidas y la comprensión del flujo de trabajo, al mismo tiempo que establece una hoja de ruta clara para su evolución.
