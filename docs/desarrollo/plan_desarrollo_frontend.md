# 🚀 PLAN DE DESARROLLO FRONTEND TFG
# Sistema de Seguimiento de Proyectos TFG - Flutter + Supabase

## 📊 **RESUMEN EJECUTIVO**

**Fecha de inicio**: 17 de agosto de 2024  
**Duración estimada**: 26-36 días  
**Estado general**: 🟡 **EN PLANIFICACIÓN**  
**Progreso actual**: 0% completado

---

## 🎯 **OBJETIVOS DEL DESARROLLO**

### **Objetivo Principal**
Desarrollar una aplicación Flutter multiplataforma que permita a estudiantes, tutores y administradores gestionar Trabajos de Fin de Grado (TFG) con funcionalidades de gestión de tareas tipo Kanban.

### **Objetivos Específicos**
- ✅ **Autenticación por roles** (estudiante/tutor/admin)
- ✅ **Gestión de anteproyectos** (crear, editar, enviar para revisión)
- ✅ **Flujo de aprobación** (aprove/reject/request-changes)
- ✅ **Gestión de tareas** (Kanban board con drag & drop)
- ✅ **Sistema de comentarios** en tareas
- ✅ **Subida de archivos** por tarea
- ✅ **Notificaciones** en tiempo real
- ✅ **Dashboard personalizado** por rol

---

## 📋 **FASES DE DESARROLLO**

### **🟡 FASE 1: CONFIGURACIÓN INICIAL**
**Duración**: 1-2 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 1**
- [ ] **1.1** Crear proyecto Flutter
  - [ ] Ejecutar `flutter create frontend`
  - [ ] Configurar estructura de carpetas
  - [ ] Añadir dependencias en `pubspec.yaml`
  - [ ] Configurar Supabase en `main.dart`
  - [ ] **Estimado**: 4 horas

- [ ] **1.2** Configurar dependencias
  - [ ] Instalar `supabase_flutter`
  - [ ] Instalar `flutter_bloc` para gestión de estado
  - [ ] Instalar `go_router` para navegación
  - [ ] Instalar `json_annotation` para modelos
  - [ ] **Estimado**: 2 horas

- [ ] **1.3** Configurar entorno de desarrollo
  - [ ] Configurar VS Code/Cursor con extensiones Flutter
  - [ ] Configurar emuladores/dispositivos de prueba
  - [ ] Configurar Git para el proyecto frontend
  - [ ] **Estimado**: 2 horas

#### **Entregables Fase 1**
- ✅ Proyecto Flutter funcional
- ✅ Dependencias instaladas y configuradas
- ✅ Conexión a Supabase establecida
- ✅ Entorno de desarrollo listo

---

### **🟡 FASE 2: AUTENTICACIÓN Y ESTRUCTURA BASE**
**Duración**: 3-4 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 2**
- [ ] **2.1** Crear modelos de datos
  - [ ] Modelo `User` con roles
  - [ ] Modelo `Anteproject` con estados
  - [ ] Modelo `Task` con estados Kanban
  - [ ] Modelo `Comment` y `File`
  - [ ] **Estimado**: 6 horas

- [ ] **2.2** Implementar servicios base
  - [ ] `AuthService` para autenticación
  - [ ] `AnteprojectsService` para anteproyectos
  - [ ] `TasksService` para tareas
  - [ ] `NotificationsService` para notificaciones
  - [ ] **Estimado**: 8 horas

- [ ] **2.3** Implementar gestión de estado (BLoC)
  - [ ] `AuthBloc` para autenticación
  - [ ] `AnteprojectsBloc` para anteproyectos
  - [ ] `TasksBloc` para tareas
  - [ ] **Estimado**: 10 horas

- [ ] **2.4** Crear pantallas de autenticación
  - [ ] Pantalla de login con validación
  - [ ] Pantalla de registro (opcional)
  - [ ] Pantalla de recuperación de contraseña
  - [ ] **Estimado**: 8 horas

#### **Entregables Fase 2**
- ✅ Modelos de datos implementados
- ✅ Servicios de comunicación con backend
- ✅ Sistema de gestión de estado funcional
- ✅ Autenticación completa

---

### **🟡 FASE 3: INTERFACES PRINCIPALES**
**Duración**: 5-7 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 3**
- [ ] **3.1** Implementar navegación por roles
  - [ ] Configurar `go_router` con rutas protegidas
  - [ ] Navegación automática según rol de usuario
  - [ ] Middleware de autenticación
  - [ ] **Estimado**: 6 horas

- [ ] **3.2** Crear dashboard por rol
  - [ ] Dashboard para estudiantes
  - [ ] Dashboard para tutores
  - [ ] Dashboard para administradores
  - [ ] **Estimado**: 12 horas

- [ ] **3.3** Implementar widgets comunes
  - [ ] Widget de carga (`LoadingWidget`)
  - [ ] Widget de error (`ErrorWidget`)
  - [ ] Widget de confirmación (`ConfirmDialog`)
  - [ ] **Estimado**: 6 horas

- [ ] **3.4** Crear pantallas de perfil
  - [ ] Pantalla de perfil de usuario
  - [ ] Edición de información personal
  - [ ] Cambio de contraseña
  - [ ] **Estimado**: 8 horas

#### **Entregables Fase 3**
- ✅ Navegación por roles implementada
- ✅ Dashboards funcionales por rol
- ✅ Widgets comunes reutilizables
- ✅ Gestión de perfiles de usuario

---

### **🟡 FASE 4: GESTIÓN DE ANTEPROYECTOS**
**Duración**: 4-5 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 4**
- [ ] **4.1** Crear formulario de anteproyecto
  - [ ] Formulario completo con validación
  - [ ] Selección de tipo de proyecto
  - [ ] Definición de objetivos y resultados
  - [ ] **Estimado**: 10 horas

- [ ] **4.2** Implementar lista de anteproyectos
  - [ ] Lista con filtros por estado
  - [ ] Búsqueda y ordenamiento
  - [ ] Acciones rápidas (editar, enviar, eliminar)
  - [ ] **Estimado**: 8 horas

- [ ] **4.3** Crear vista de detalles
  - [ ] Vista detallada del anteproyecto
  - [ ] Historial de cambios
  - [ ] Comentarios del tutor
  - [ ] **Estimado**: 6 horas

- [ ] **4.4** Implementar flujo de envío
  - [ ] Validación antes del envío
  - [ ] Confirmación de envío
  - [ ] Notificación al tutor
  - [ ] **Estimado**: 4 horas

#### **Entregables Fase 4**
- ✅ Formulario completo de anteproyectos
- ✅ Lista y gestión de anteproyectos
- ✅ Vista detallada con historial
- ✅ Flujo de envío para revisión

---

### **🟡 FASE 5: GESTIÓN DE TAREAS (KANBAN)**
**Duración**: 6-8 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 5**
- [ ] **5.1** Crear tablero Kanban
  - [ ] Columnas por estado (Pendiente, En Progreso, En Revisión, Completada)
  - [ ] Drag & drop de tareas entre columnas
  - [ ] Actualización automática de estado
  - [ ] **Estimado**: 12 horas

- [ ] **5.2** Implementar tarjetas de tarea
  - [ ] Diseño de tarjeta con información esencial
  - [ ] Indicadores de prioridad y complejidad
  - [ ] Asignación de usuarios
  - [ ] **Estimado**: 8 horas

- [ ] **5.3** Crear formulario de tarea
  - [ ] Formulario de creación de tareas
  - [ ] Asignación de usuarios
  - [ ] Definición de fechas límite
  - [ ] **Estimado**: 6 horas

- [ ] **5.4** Implementar vista de tarea
  - [ ] Vista detallada de tarea
  - [ ] Sistema de comentarios
  - [ ] Historial de cambios
  - [ ] **Estimado**: 8 horas

- [ ] **5.5** Añadir funcionalidades avanzadas
  - [ ] Filtros por asignado, prioridad, fecha
  - [ ] Búsqueda de tareas
  - [ ] Exportación de reportes
  - [ ] **Estimado**: 6 horas

#### **Entregables Fase 5**
- ✅ Tablero Kanban funcional con drag & drop
- ✅ Gestión completa de tareas
- ✅ Sistema de comentarios
- ✅ Filtros y búsqueda avanzada

---

### **🟡 FASE 6: FUNCIONALIDADES AVANZADAS**
**Duración**: 4-6 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 6**
- [ ] **6.1** Implementar notificaciones
  - [ ] Notificaciones en tiempo real
  - [ ] Lista de notificaciones
  - [ ] Marcado como leído
  - [ ] **Estimado**: 8 horas

- [ ] **6.2** Sistema de archivos
  - [ ] Subida de archivos por tarea
  - [ ] Visualización de archivos
  - [ ] Descarga de archivos
  - [ ] **Estimado**: 10 horas

- [ ] **6.3** Generación de PDFs
  - [ ] Generación de anteproyecto en PDF
  - [ ] Reportes de progreso
  - [ ] Exportación de datos
  - [ ] **Estimado**: 6 horas

- [ ] **6.4** Funcionalidades de tutor
  - [ ] Panel de revisión de anteproyectos
  - [ ] Aprobación/rechazo con comentarios
  - [ ] Seguimiento de estudiantes
  - [ ] **Estimado**: 8 horas

#### **Entregables Fase 6**
- ✅ Sistema de notificaciones en tiempo real
- ✅ Gestión completa de archivos
- ✅ Generación de PDFs
- ✅ Panel de tutor funcional

---

### **🟡 FASE 7: TESTING Y OPTIMIZACIÓN**
**Duración**: 3-4 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 7**
- [ ] **7.1** Testing unitario
  - [ ] Tests para servicios
  - [ ] Tests para BLoCs
  - [ ] Tests para modelos
  - [ ] **Estimado**: 8 horas

- [ ] **7.2** Testing de widgets
  - [ ] Tests para pantallas principales
  - [ ] Tests para formularios
  - [ ] Tests para navegación
  - [ ] **Estimado**: 6 horas

- [ ] **7.3** Testing de integración
  - [ ] Tests de flujo completo
  - [ ] Tests de autenticación
  - [ ] Tests de APIs
  - [ ] **Estimado**: 8 horas

- [ ] **7.4** Optimización y pulido
  - [ ] Optimización de rendimiento
  - [ ] Mejoras de UX/UI
  - [ ] Corrección de bugs
  - [ ] **Estimado**: 6 horas

#### **Entregables Fase 7**
- ✅ Cobertura de testing completa
- ✅ Aplicación optimizada
- ✅ Documentación de testing
- ✅ Aplicación lista para producción

---

## 📊 **MÉTRICAS DE SEGUIMIENTO**

### **Progreso por Fase**
| Fase | Duración | Progreso | Estado | Fecha Inicio | Fecha Fin |
|------|----------|----------|--------|--------------|-----------|
| **Fase 1** | 1-2 días | 0% | ⏳ Pendiente | - | - |
| **Fase 2** | 3-4 días | 0% | ⏳ Pendiente | - | - |
| **Fase 3** | 5-7 días | 0% | ⏳ Pendiente | - | - |
| **Fase 4** | 4-5 días | 0% | ⏳ Pendiente | - | - |
| **Fase 5** | 6-8 días | 0% | ⏳ Pendiente | - | - |
| **Fase 6** | 4-6 días | 0% | ⏳ Pendiente | - | - |
| **Fase 7** | 3-4 días | 0% | ⏳ Pendiente | - | - |

### **Progreso General**
- **Progreso total**: 0% completado
- **Horas estimadas**: 120-160 horas
- **Días estimados**: 26-36 días
- **Estado**: 🟡 En Planificación

---

## 🎯 **CRITERIOS DE ACEPTACIÓN**

### **Criterios por Fase**

#### **Fase 1 - Configuración**
- ✅ Proyecto Flutter se ejecuta sin errores
- ✅ Conexión a Supabase establecida
- ✅ Dependencias instaladas correctamente

#### **Fase 2 - Autenticación**
- ✅ Login funcional con usuarios de prueba
- ✅ Navegación automática según rol
- ✅ Gestión de estado implementada

#### **Fase 3 - Interfaces**
- ✅ Dashboards visibles por rol
- ✅ Navegación fluida entre pantallas
- ✅ Widgets comunes reutilizables

#### **Fase 4 - Anteproyectos**
- ✅ Formulario completo y funcional
- ✅ Lista de anteproyectos con filtros
- ✅ Flujo de envío para revisión

#### **Fase 5 - Tareas**
- ✅ Tablero Kanban con drag & drop
- ✅ Creación y edición de tareas
- ✅ Sistema de comentarios funcional

#### **Fase 6 - Avanzado**
- ✅ Notificaciones en tiempo real
- ✅ Subida y gestión de archivos
- ✅ Panel de tutor funcional

#### **Fase 7 - Testing**
- ✅ Cobertura de testing > 80%
- ✅ Aplicación optimizada
- ✅ Sin errores críticos

---

## 🚨 **RIESGOS Y MITIGACIONES**

### **Riesgos Identificados**
1. **Complejidad del drag & drop Kanban**
   - **Mitigación**: Usar librerías probadas como `flutter_dnd`

2. **Integración con APIs de Supabase**
   - **Mitigación**: Testing exhaustivo de endpoints

3. **Gestión de estado compleja**
   - **Mitigación**: Usar BLoC pattern con documentación clara

4. **Rendimiento en dispositivos móviles**
   - **Mitigación**: Optimización continua y testing en dispositivos reales

---

## 📞 **COMUNICACIÓN Y COORDINACIÓN**

### **Reuniones Semanales**
- **Día**: Viernes a las 10:00
- **Duración**: 1 hora
- **Objetivo**: Revisar progreso y planificar siguiente semana

### **Canales de Comunicación**
- **Desarrollo**: GitHub Issues y Pull Requests
- **Coordinación**: Documentos compartidos
- **Soporte**: Backend team disponible

---

**Fecha de creación**: 17 de agosto de 2024  
**Responsable**: Equipo Frontend  
**Estado**: 🟡 **EN PLANIFICACIÓN**
