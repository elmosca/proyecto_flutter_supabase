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
Desarrollar una aplicación Flutter **multiplataforma** que permita a estudiantes, tutores y administradores gestionar Trabajos de Fin de Grado (TFG) con funcionalidades de gestión de tareas tipo Kanban, disponible en **Web, Android, iOS y Escritorio**.

### **Objetivos Específicos**
- ✅ **Autenticación por roles** (estudiante/tutor/admin)
- ✅ **Gestión de anteproyectos** (crear, editar, enviar para revisión)
- ✅ **Flujo de aprobación** (aprove/reject/request-changes)
- ✅ **Gestión de tareas** (Kanban board con drag & drop)
- ✅ **Sistema de comentarios** en tareas
- ✅ **Subida de archivos** por tarea
- ✅ **Notificaciones** en tiempo real
- ✅ **Dashboard personalizado** por rol
- ✅ **Experiencia multiplataforma** optimizada para cada plataforma

---

## 🌐 **ESTRATEGIA MULTIPLATAFORMA**

### **Plataformas Objetivo**
1. **🌐 Web** (Prioridad ALTA) - Acceso universal desde navegadores
2. **📱 Android** (Prioridad ALTA) - Aplicación nativa en Google Play
3. **🍎 iOS** (Prioridad MEDIA) - Aplicación nativa en App Store
4. **🖥️ Windows** (Prioridad MEDIA) - Aplicación de escritorio
5. **🍎 macOS** (Prioridad BAJA) - Aplicación de escritorio
6. **🐧 Linux** (Prioridad BAJA) - Aplicación de escritorio

### **Enfoque de Desarrollo**
- **Código compartido**: 90% del código será común entre plataformas
- **Adaptaciones específicas**: 10% del código será específico por plataforma
- **Diseño responsive**: Adaptación automática según tamaño de pantalla
- **Patrones de navegación**: Adaptados a cada plataforma (hamburger menu, bottom navigation, etc.)

### **Configuración por Plataforma**

#### **Web (Prioridad ALTA)**
```dart
// Configuración específica para web
if (kIsWeb) {
  // Optimizaciones para navegador
  // Configuración de PWA
  // Adaptaciones de UI para mouse/touch
}
```

#### **Android (Prioridad ALTA)**
```dart
// Configuración específica para Android
if (Platform.isAndroid) {
  // Permisos específicos de Android
  // Integración con servicios de Google
  // Adaptaciones de Material Design
}
```

#### **iOS (Prioridad MEDIA)**
```dart
// Configuración específica para iOS
if (Platform.isIOS) {
  // Adaptaciones de Cupertino Design
  // Integración con servicios de Apple
  // Configuraciones específicas de iOS
}
```

#### **Escritorio (Prioridad MEDIA-BAJA)**
```dart
// Configuración específica para escritorio
if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
  // Adaptaciones para mouse y teclado
  // Ventanas y menús nativos
  // Integración con sistema operativo
}
```

---

## 📋 **FASES DE DESARROLLO**

### **🟡 FASE 1: CONFIGURACIÓN INICIAL Y MULTIPLATAFORMA**
**Duración**: 2-3 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 1**
- [ ] **1.1** Crear proyecto Flutter multiplataforma
  - [ ] Ejecutar `flutter create frontend --platforms=web,android,ios,windows,macos,linux`
  - [ ] Configurar estructura de carpetas multiplataforma
  - [ ] Añadir dependencias en `pubspec.yaml`
  - [ ] Configurar Supabase en `main.dart`
  - [ ] **Estimado**: 6 horas

- [ ] **1.2** Configurar dependencias multiplataforma
  - [ ] Instalar `supabase_flutter` (compatible con todas las plataformas)
  - [ ] Instalar `flutter_bloc` para gestión de estado
  - [ ] Instalar `go_router` para navegación
  - [ ] Instalar `json_annotation` para modelos
  - [ ] Instalar `universal_platform` para detección de plataforma
  - [ ] **Estimado**: 3 horas

- [ ] **1.3** Configurar entorno de desarrollo multiplataforma
  - [ ] Configurar VS Code/Cursor con extensiones Flutter
  - [ ] Configurar emuladores/dispositivos para cada plataforma
  - [ ] Configurar Git para el proyecto frontend
  - [ ] Configurar herramientas de build para cada plataforma
  - [ ] **Estimado**: 4 horas

- [ ] **1.4** Configurar adaptaciones por plataforma
  - [ ] Crear utilidades de detección de plataforma
  - [ ] Configurar temas adaptativos por plataforma
  - [ ] Configurar navegación específica por plataforma
  - [ ] Configurar assets específicos por plataforma
  - [ ] **Estimado**: 6 horas

#### **Entregables Fase 1**
- ✅ Proyecto Flutter multiplataforma funcional
- ✅ Dependencias instaladas y configuradas para todas las plataformas
- ✅ Conexión a Supabase establecida
- ✅ Entorno de desarrollo multiplataforma listo
- ✅ Configuración de adaptaciones por plataforma

---

### **🟡 FASE 2: AUTENTICACIÓN Y ESTRUCTURA BASE MULTIPLATAFORMA**
**Duración**: 4-5 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 2**
- [ ] **2.1** Crear modelos de datos multiplataforma
  - [ ] Modelo `User` con roles
  - [ ] Modelo `Anteproject` con estados
  - [ ] Modelo `Task` con estados Kanban
  - [ ] Modelo `Comment` y `File`
  - [ ] Configurar serialización JSON multiplataforma
  - [ ] **Estimado**: 8 horas

- [ ] **2.2** Implementar servicios base multiplataforma
  - [ ] `AuthService` para autenticación (compatible con todas las plataformas)
  - [ ] `AnteprojectsService` para anteproyectos
  - [ ] `TasksService` para tareas
  - [ ] `NotificationsService` para notificaciones
  - [ ] `PlatformService` para adaptaciones por plataforma
  - [ ] **Estimado**: 10 horas

- [ ] **2.3** Implementar gestión de estado (BLoC) multiplataforma
  - [ ] `AuthBloc` para autenticación
  - [ ] `AnteprojectsBloc` para anteproyectos
  - [ ] `TasksBloc` para tareas
  - [ ] `PlatformBloc` para gestión de plataforma
  - [ ] **Estimado**: 12 horas

- [ ] **2.4** Crear pantallas de autenticación multiplataforma
  - [ ] Pantalla de login con validación (adaptada por plataforma)
  - [ ] Pantalla de registro (opcional)
  - [ ] Pantalla de recuperación de contraseña
  - [ ] Adaptaciones de UI según plataforma
  - [ ] **Estimado**: 10 horas

#### **Entregables Fase 2**
- ✅ Modelos de datos implementados para todas las plataformas
- ✅ Servicios de comunicación con backend multiplataforma
- ✅ Sistema de gestión de estado funcional
- ✅ Autenticación completa multiplataforma

---

### **🟡 FASE 3: INTERFACES PRINCIPALES MULTIPLATAFORMA**
**Duración**: 6-8 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 3**
- [ ] **3.1** Implementar navegación multiplataforma
  - [ ] Configurar `go_router` con rutas protegidas
  - [ ] Navegación automática según rol de usuario
  - [ ] Middleware de autenticación
  - [ ] Adaptaciones de navegación por plataforma (bottom nav, drawer, etc.)
  - [ ] **Estimado**: 8 horas

- [ ] **3.2** Crear dashboard multiplataforma por rol
  - [ ] Dashboard para estudiantes (adaptado por plataforma)
  - [ ] Dashboard para tutores (adaptado por plataforma)
  - [ ] Dashboard para administradores (adaptado por plataforma)
  - [ ] Responsive design para diferentes tamaños de pantalla
  - [ ] **Estimado**: 16 horas

- [ ] **3.3** Implementar widgets comunes multiplataforma
  - [ ] Widget de carga (`LoadingWidget`) adaptativo
  - [ ] Widget de error (`ErrorWidget`) adaptativo
  - [ ] Widget de confirmación (`ConfirmDialog`) adaptativo
  - [ ] Widgets específicos por plataforma
  - [ ] **Estimado**: 8 horas

- [ ] **3.4** Crear pantallas de perfil multiplataforma
  - [ ] Pantalla de perfil de usuario (adaptada por plataforma)
  - [ ] Edición de información personal
  - [ ] Cambio de contraseña
  - [ ] Configuraciones específicas por plataforma
  - [ ] **Estimado**: 10 horas

#### **Entregables Fase 3**
- ✅ Navegación multiplataforma implementada
- ✅ Dashboards funcionales por rol y plataforma
- ✅ Widgets comunes reutilizables y adaptativos
- ✅ Gestión de perfiles de usuario multiplataforma

---

### **🟡 FASE 4: GESTIÓN DE ANTEPROYECTOS MULTIPLATAFORMA**
**Duración**: 5-6 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 4**
- [ ] **4.1** Crear formulario de anteproyecto multiplataforma
  - [ ] Formulario completo con validación (adaptado por plataforma)
  - [ ] Selección de tipo de proyecto
  - [ ] Definición de objetivos y resultados
  - [ ] Adaptaciones de UI según plataforma (formularios nativos)
  - [ ] **Estimado**: 12 horas

- [ ] **4.2** Implementar lista de anteproyectos multiplataforma
  - [ ] Lista con filtros por estado (adaptada por plataforma)
  - [ ] Búsqueda y ordenamiento
  - [ ] Acciones rápidas (editar, enviar, eliminar)
  - [ ] Adaptaciones de lista según plataforma (grid, list, cards)
  - [ ] **Estimado**: 10 horas

- [ ] **4.3** Crear vista de detalles multiplataforma
  - [ ] Vista detallada del anteproyecto (adaptada por plataforma)
  - [ ] Historial de cambios
  - [ ] Comentarios del tutor
  - [ ] Adaptaciones de layout según plataforma
  - [ ] **Estimado**: 8 horas

- [ ] **4.4** Implementar flujo de envío multiplataforma
  - [ ] Validación antes del envío
  - [ ] Confirmación de envío (adaptada por plataforma)
  - [ ] Notificación al tutor
  - [ ] **Estimado**: 6 horas

#### **Entregables Fase 4**
- ✅ Formulario completo de anteproyectos multiplataforma
- ✅ Lista y gestión de anteproyectos adaptada por plataforma
- ✅ Vista detallada con historial multiplataforma
- ✅ Flujo de envío para revisión multiplataforma

---

### **🟡 FASE 5: GESTIÓN DE TAREAS (KANBAN) MULTIPLATAFORMA**
**Duración**: 8-10 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 5**
- [ ] **5.1** Crear tablero Kanban multiplataforma
  - [ ] Columnas por estado (Pendiente, En Progreso, En Revisión, Completada)
  - [ ] Drag & drop de tareas entre columnas (adaptado por plataforma)
  - [ ] Actualización automática de estado
  - [ ] Adaptaciones de drag & drop según plataforma (touch, mouse, touchpad)
  - [ ] **Estimado**: 16 horas

- [ ] **5.2** Implementar tarjetas de tarea multiplataforma
  - [ ] Diseño de tarjeta con información esencial (adaptado por plataforma)
  - [ ] Indicadores de prioridad y complejidad
  - [ ] Asignación de usuarios
  - [ ] Adaptaciones de tarjeta según plataforma (tamaño, layout, interacciones)
  - [ ] **Estimado**: 10 horas

- [ ] **5.3** Crear formulario de tarea multiplataforma
  - [ ] Formulario de creación de tareas (adaptado por plataforma)
  - [ ] Asignación de usuarios
  - [ ] Definición de fechas límite
  - [ ] Adaptaciones de formulario según plataforma
  - [ ] **Estimado**: 8 horas

- [ ] **5.4** Implementar vista de tarea multiplataforma
  - [ ] Vista detallada de tarea (adaptada por plataforma)
  - [ ] Sistema de comentarios
  - [ ] Historial de cambios
  - [ ] Adaptaciones de vista según plataforma
  - [ ] **Estimado**: 10 horas

- [ ] **5.5** Añadir funcionalidades avanzadas multiplataforma
  - [ ] Filtros por asignado, prioridad, fecha (adaptados por plataforma)
  - [ ] Búsqueda de tareas
  - [ ] Exportación de reportes
  - [ ] Adaptaciones de funcionalidades según plataforma
  - [ ] **Estimado**: 8 horas

#### **Entregables Fase 5**
- ✅ Tablero Kanban funcional con drag & drop multiplataforma
- ✅ Gestión completa de tareas adaptada por plataforma
- ✅ Sistema de comentarios multiplataforma
- ✅ Filtros y búsqueda avanzada multiplataforma

---

### **🟡 FASE 6: FUNCIONALIDADES AVANZADAS MULTIPLATAFORMA**
**Duración**: 6-8 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 6**
- [ ] **6.1** Implementar notificaciones multiplataforma
  - [ ] Notificaciones en tiempo real (adaptadas por plataforma)
  - [ ] Lista de notificaciones
  - [ ] Marcado como leído
  - [ ] Notificaciones push nativas (Android/iOS)
  - [ ] **Estimado**: 12 horas

- [ ] **6.2** Sistema de archivos multiplataforma
  - [ ] Subida de archivos por tarea (adaptada por plataforma)
  - [ ] Visualización de archivos
  - [ ] Descarga de archivos
  - [ ] Integración con sistema de archivos nativo
  - [ ] **Estimado**: 12 horas

- [ ] **6.3** Generación de PDFs multiplataforma
  - [ ] Generación de anteproyecto en PDF
  - [ ] Reportes de progreso
  - [ ] Exportación de datos
  - [ ] Adaptaciones de generación según plataforma
  - [ ] **Estimado**: 8 horas

- [ ] **6.4** Funcionalidades de tutor multiplataforma
  - [ ] Panel de revisión de anteproyectos (adaptado por plataforma)
  - [ ] Aprobación/rechazo con comentarios
  - [ ] Seguimiento de estudiantes
  - [ ] Adaptaciones de panel según plataforma
  - [ ] **Estimado**: 10 horas

#### **Entregables Fase 6**
- ✅ Sistema de notificaciones en tiempo real multiplataforma
- ✅ Gestión completa de archivos multiplataforma
- ✅ Generación de PDFs multiplataforma
- ✅ Panel de tutor funcional multiplataforma

---

### **🟡 FASE 7: TESTING Y OPTIMIZACIÓN MULTIPLATAFORMA**
**Duración**: 4-5 días  
**Estado**: ⏳ **PENDIENTE**  
**Responsable**: Equipo Frontend

#### **Tareas de la Fase 7**
- [ ] **7.1** Testing unitario multiplataforma
  - [ ] Tests para servicios (comunes a todas las plataformas)
  - [ ] Tests para BLoCs
  - [ ] Tests para modelos
  - [ ] Tests específicos por plataforma
  - [ ] **Estimado**: 10 horas

- [ ] **7.2** Testing de widgets multiplataforma
  - [ ] Tests para pantallas principales (por plataforma)
  - [ ] Tests para formularios
  - [ ] Tests para navegación
  - [ ] Tests de adaptaciones por plataforma
  - [ ] **Estimado**: 8 horas

- [ ] **7.3** Testing de integración multiplataforma
  - [ ] Tests de flujo completo (por plataforma)
  - [ ] Tests de autenticación
  - [ ] Tests de APIs
  - [ ] Tests de funcionalidades específicas por plataforma
  - [ ] **Estimado**: 10 horas

- [ ] **7.4** Optimización y pulido multiplataforma
  - [ ] Optimización de rendimiento por plataforma
  - [ ] Mejoras de UX/UI específicas por plataforma
  - [ ] Corrección de bugs
  - [ ] Optimización de tamaño de aplicación por plataforma
  - [ ] **Estimado**: 8 horas

#### **Entregables Fase 7**
- ✅ Cobertura de testing completa multiplataforma
- ✅ Aplicación optimizada para cada plataforma
- ✅ Documentación de testing multiplataforma
- ✅ Aplicación lista para producción en todas las plataformas

---

## 🚀 **ESTRATEGIA DE DESPLIEGUE MULTIPLATAFORMA**

### **Web (Prioridad ALTA)**
```bash
# Build para producción web
flutter build web --release --web-renderer html
flutter build web --release --web-renderer canvaskit

# Despliegue en Vercel/Netlify
# Configuración PWA para instalación como app
```

### **Android (Prioridad ALTA)**
```bash
# Build APK de release
flutter build apk --release

# Build App Bundle para Google Play
flutter build appbundle --release

# Configuración de signing para Google Play Store
```

### **iOS (Prioridad MEDIA)**
```bash
# Build para iOS
flutter build ios --release

# Configuración de signing para App Store
# Requiere certificados de Apple Developer
```

### **Escritorio (Prioridad MEDIA-BAJA)**
```bash
# Build para Windows
flutter build windows --release

# Build para macOS
flutter build macos --release

# Build para Linux
flutter build linux --release
```

---

## 📊 **MÉTRICAS DE SEGUIMIENTO**

### **Progreso por Fase**
| Fase | Duración | Progreso | Estado | Fecha Inicio | Fecha Fin |
|------|----------|----------|--------|--------------|-----------|
| **Fase 1** | 2-3 días | 0% | ⏳ Pendiente | - | - |
| **Fase 2** | 4-5 días | 0% | ⏳ Pendiente | - | - |
| **Fase 3** | 6-8 días | 0% | ⏳ Pendiente | - | - |
| **Fase 4** | 5-6 días | 0% | ⏳ Pendiente | - | - |
| **Fase 5** | 8-10 días | 0% | ⏳ Pendiente | - | - |
| **Fase 6** | 6-8 días | 0% | ⏳ Pendiente | - | - |
| **Fase 7** | 4-5 días | 0% | ⏳ Pendiente | - | - |

### **Progreso General**
- **Progreso total**: 0% completado
- **Horas estimadas**: 140-180 horas (incluye adaptaciones multiplataforma)
- **Días estimados**: 35-45 días (incluye testing multiplataforma)
- **Estado**: 🟡 En Planificación

### **Progreso por Plataforma**
- **Web**: 0% completado
- **Android**: 0% completado
- **iOS**: 0% completado
- **Windows**: 0% completado
- **macOS**: 0% completado
- **Linux**: 0% completado

---

## 🎯 **CRITERIOS DE ACEPTACIÓN MULTIPLATAFORMA**

### **Criterios por Fase**

#### **Fase 1 - Configuración Multiplataforma**
- ✅ Proyecto Flutter se ejecuta sin errores en todas las plataformas
- ✅ Conexión a Supabase establecida en todas las plataformas
- ✅ Dependencias instaladas correctamente para todas las plataformas
- ✅ Configuración de adaptaciones por plataforma implementada

#### **Fase 2 - Autenticación Multiplataforma**
- ✅ Login funcional con usuarios de prueba en todas las plataformas
- ✅ Navegación automática según rol en todas las plataformas
- ✅ Gestión de estado implementada multiplataforma

#### **Fase 3 - Interfaces Multiplataforma**
- ✅ Dashboards visibles por rol y adaptados por plataforma
- ✅ Navegación fluida entre pantallas en todas las plataformas
- ✅ Widgets comunes reutilizables y adaptativos

#### **Fase 4 - Anteproyectos Multiplataforma**
- ✅ Formulario completo y funcional en todas las plataformas
- ✅ Lista de anteproyectos con filtros adaptados por plataforma
- ✅ Flujo de envío para revisión multiplataforma

#### **Fase 5 - Tareas Multiplataforma**
- ✅ Tablero Kanban con drag & drop adaptado por plataforma
- ✅ Creación y edición de tareas multiplataforma
- ✅ Sistema de comentarios funcional en todas las plataformas

#### **Fase 6 - Avanzado Multiplataforma**
- ✅ Notificaciones en tiempo real multiplataforma
- ✅ Subida y gestión de archivos multiplataforma
- ✅ Panel de tutor funcional multiplataforma

#### **Fase 7 - Testing Multiplataforma**
- ✅ Cobertura de testing > 80% en todas las plataformas
- ✅ Aplicación optimizada para cada plataforma
- ✅ Sin errores críticos en ninguna plataforma

---

## 🚨 **RIESGOS Y MITIGACIONES MULTIPLATAFORMA**

### **Riesgos Identificados**
1. **Complejidad del drag & drop multiplataforma**
   - **Mitigación**: Usar librerías probadas como `flutter_dnd` con adaptaciones por plataforma

2. **Integración con APIs de Supabase multiplataforma**
   - **Mitigación**: Testing exhaustivo de endpoints en todas las plataformas

3. **Gestión de estado compleja multiplataforma**
   - **Mitigación**: Usar BLoC pattern con documentación clara y adaptaciones por plataforma

4. **Rendimiento en diferentes plataformas**
   - **Mitigación**: Optimización continua y testing en dispositivos reales de cada plataforma

5. **Diferencias de UI/UX entre plataformas**
   - **Mitigación**: Seguir guidelines de diseño de cada plataforma (Material, Cupertino, etc.)

6. **Configuración de build para múltiples plataformas**
   - **Mitigación**: Automatizar procesos de build con CI/CD multiplataforma

---

## 📞 **COMUNICACIÓN Y COORDINACIÓN**

### **Reuniones Semanales**
- **Día**: Viernes a las 10:00
- **Duración**: 1 hora
- **Objetivo**: Revisar progreso multiplataforma y planificar siguiente semana

### **Canales de Comunicación**
- **Desarrollo**: GitHub Issues y Pull Requests
- **Coordinación**: Documentos compartidos
- **Soporte**: Backend team disponible

---

**Fecha de creación**: 17 de agosto de 2024  
**Responsable**: Equipo Frontend  
**Estado**: 🟡 **EN PLANIFICACIÓN**
