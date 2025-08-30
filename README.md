# Proyecto TFG DAM – Plataforma colaborativa (Flutter + Supabase)

## 1. 🎯 Objetivo del Proyecto
Desarrollar una plataforma colaborativa **multiplataforma** con Flutter (frontend) y Supabase (backend) para gestionar Trabajos de Fin de Grado (TFG) del ciclo DAM. La plataforma permitirá a estudiantes, tutores y administradores planificar y dar seguimiento al TFG con enfoque en gestión de tareas y metodología Kanban, disponible en **Web, Android, iOS y Escritorio**.

- **Roles**: estudiantes, tutores, administradores
- **Plataformas**: Web, Android, iOS, Windows, macOS, Linux
- **Funcionalidades**: Tableros Kanban, tareas, estados, prioridades
- **Seguimiento**: Entregas, comentarios y rúbricas de evaluación
- **Comunicación**: Notificaciones y actividad reciente
- **Archivos**: Adjuntos y versiones por tarea
- **Tiempo real**: Eventos (actualizaciones de tablero, chat/comentarios)

## 2. 🧱 Tecnologías Elegidas
- **Frontend**: Flutter **multiplataforma** (iOS, Android, web, escritorio) desde una única base de código
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Edge Functions, Realtime, CLI)

### **Plataformas Soportadas**
| Plataforma | Prioridad | Estado | Descripción |
|------------|-----------|--------|-------------|
| **🌐 Web** | ALTA | ⏳ Pendiente | Acceso universal desde navegadores |
| **📱 Android** | ALTA | ⏳ Pendiente | Aplicación nativa en Google Play |
| **🍎 iOS** | MEDIA | ⏳ Pendiente | Aplicación nativa en App Store |
| **🖥️ Windows** | MEDIA | ⏳ Pendiente | Aplicación de escritorio |
| **🍎 macOS** | BAJA | ⏳ Pendiente | Aplicación de escritorio |
| **🐧 Linux** | BAJA | ⏳ Pendiente | Aplicación de escritorio |

## 3. 🚀 Funcionalidades previstas
- **Kanban por TFG** (listas/estados y tarjetas/tareas)
- **Asignación de tareas** y fechas límite
- **Entrega de archivos** por tarea (Storage)
- **Comentarios y menciones**
- **Rúbricas y calificaciones** por tutor
- **Notificaciones y actividad**
- **Realtime** para colaboración (movimientos en tablero, chat)
- **Políticas de seguridad** (RLS) por rol/propiedad de datos
- **Experiencia multiplataforma** optimizada para cada plataforma

## 4. 📁 Estructura del repositorio
- `backend/supabase/`: proyecto Supabase (migraciones, funciones, seed, config)
- `frontend/`: proyecto Flutter **multiplataforma** (creado por el equipo de frontend)
- `scripts/`: utilidades de desarrollo
- `.cursorrules`: reglas de mejores prácticas para Supabase y Cursor

## 5. 🛠️ Puesta en marcha

### Backend (Supabase)
Requisitos: Supabase CLI, Docker.

1) Instalar CLI (Linux)
```bash
curl -fsSL https://cli.supabase.com/install | sh
```

2) Inicializar y levantar entorno local
```bash
cd backend/supabase
supabase init
cp .env.example .env
supabase start
```

3) Migraciones y DB
```bash
supabase migration new init_schema
supabase db push
```

4) Edge Functions (opcional)
```bash
supabase functions new hello
supabase functions serve
```

Buenas prácticas:
- Habilitar RLS en tablas sensibles y definir políticas mínimas necesarias.
- Usar vistas con `security_invoker = true` cuando apliquen.
- No exponer `service_role` en cliente; usar `anon` en cliente y `service_role` sólo en backend.
- Optimizar consultas con índices y validar con `EXPLAIN`.
- Preferir paginación por cursores sobre `OFFSET/LIMIT` cuando haya muchas filas.

Referencias:
- Optimización de consultas: [Guía oficial](https://supabase.com/docs/guides/database/query-optimization?utm_source=openai)
- Reglas para editores AI (formato de reglas): [Referencia](https://supabase.com/ui/docs/ai-editors-rules/prompts?utm_source=openai)
- Paginación por cursores (contexto): [restack.io](https://www.restack.io/docs/supabase-knowledge-supabase-pagination-guide?utm_source=openai)
- RLS (conceptos y ejemplos): [supabase.wordpress.com – RLS](https://supabase.wordpress.com/2023/05/13/protegiendo-tus-datos-con-rls-como-definir-politicas-de-seguridad-en-supabase/?utm_source=openai)
- Vistas y `security_invoker`: [supabase.wordpress.com – vistas](https://supabase.wordpress.com/2023/05/17/administracion-tablas-y-vistas-en-supabase/?utm_source=openai)
- Claves `anon` vs `service_role`: [apidog.com](https://apidog.com/es/blog/supabase-api-2/?utm_source=openai)

### Frontend (Flutter Multiplataforma)
Requisitos: Flutter SDK.

1) Crear proyecto **multiplataforma** (equipo frontend)
```bash
cd frontend
flutter create app --platforms=web,android,ios,windows,macos,linux
cd app
flutter pub add supabase_flutter
```

2) Configurar Supabase en `lib/main.dart` (URL y `anon key` del proyecto).

3) Ejecutar en diferentes plataformas
```bash
# Web (más rápido para desarrollo)
flutter run -d chrome

# Android
flutter run -d android

# iOS (requiere macOS)
flutter run -d ios

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## 6. 📋 Seguimiento del Proyecto

### Checklists de Desarrollo
- [📋 Checklist Detallado MVP](docs/desarrollo/checklist_mvp_detallado.md) - Seguimiento completo del plan MVP
- [📅 Checklist Semanal](docs/desarrollo/checklist_seguimiento_semanal.md) - Seguimiento semanal del progreso
- [📊 Estado Actual](docs/desarrollo/estado_actual_completo.md) - Estado completo del proyecto
- [🎉 Logros de la Sesión](docs/desarrollo/logros_sesion_17_agosto.md) - Logros de la sesión del 17 de agosto

### Documentación Técnica
- [🗄️ Backend Supabase](backend/supabase/README.md) - Guía completa del backend
- [🔐 Configuración RLS](backend/supabase/rls_setup_guide.md) - Guía de configuración de seguridad
- [✅ Verificación Migraciones](backend/supabase/verificacion_migraciones.md) - Estado de las migraciones
- [🚀 Opciones de Despliegue](docs/despliegue/opciones_backend.md) - Guía completa de opciones de backend (Local, Cloud, Servidor Independiente)
- [🏠 Configuración Servidor Doméstico](docs/despliegue/configuracion_servidor_domestico.md) - Guía específica para tu servidor de red doméstica

### Documentación Frontend Multiplataforma
- [🚀 Plan de Desarrollo Frontend](docs/desarrollo/plan_desarrollo_frontend.md) - Plan completo de desarrollo del frontend **multiplataforma**
- [📅 Checklist Frontend Semanal](docs/desarrollo/checklist_frontend_semanal.md) - Seguimiento semanal del frontend **multiplataforma**
- [⚡ Guía de Inicio Frontend](docs/desarrollo/guia_inicio_frontend.md) - Guía rápida para comenzar con Flutter **multiplataforma**
- [📦 Entrega Backend para Frontend](backend/supabase/ENTREGA_BACKEND_FRONTEND.md) - Documentación de entrega del backend

## 7. 🌐 Estrategia Multiplataforma

### **Enfoque de Desarrollo**
- **Código compartido**: 90% del código será común entre plataformas
- **Adaptaciones específicas**: 10% del código será específico por plataforma
- **Diseño responsive**: Adaptación automática según tamaño de pantalla
- **Patrones de navegación**: Adaptados a cada plataforma (hamburger menu, bottom navigation, etc.)

### **Configuración por Plataforma**
```dart
// Ejemplo de configuración multiplataforma
if (kIsWeb) {
  // Configuraciones específicas para web
  // Optimizaciones para navegador
  // Configuración de PWA
} else if (Platform.isAndroid) {
  // Configuraciones específicas para Android
  // Permisos específicos de Android
  // Integración con servicios de Google
} else if (Platform.isIOS) {
  // Configuraciones específicas para iOS
  // Adaptaciones de Cupertino Design
  // Integración con servicios de Apple
} else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
  // Configuraciones específicas para escritorio
  // Adaptaciones para mouse y teclado
  // Ventanas y menús nativos
}
```

### **Build Multiplataforma**
```bash
# Build para Web
flutter build web --release

# Build para Android
flutter build apk --release
flutter build appbundle --release

# Build para iOS
flutter build ios --release

# Build para Windows
flutter build windows --release

# Build para macOS
flutter build macos --release

# Build para Linux
flutter build linux --release
```

## 8. 🔐 Seguridad y cumplimiento
- RLS habilitado y políticas por rol/propiedad (p. ej., `auth.uid() = user_id`).
- Datos sensibles protegidos y acceso a Storage controlado por políticas.
- `.env` locales (no se suben); usar `.env.example` como plantilla.
- Revisión de migraciones y políticas en PR antes de desplegar.

## 9. 🧪 Calidad y convenciones
- Commits: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`…).
- Revisión de PR con checklist (.cursorrules).
- Generación de tipos desde DB cuando aplique.
- Documentar endpoints, funciones y políticas relevantes.
- **Testing multiplataforma**: Tests unitarios, de widgets y de integración por plataforma.

## 10. 📦 Entornos y Opciones de Despliegue

### **Opciones de Backend Disponibles**

#### **Opción 1: Supabase Local (Recomendado para Desarrollo)**
- **Ubicación**: Servidor local o red doméstica
- **Ventajas**: Control total, sin costos, sin límites de uso
- **Configuración**: Supabase CLI con Docker
- **Uso**: Desarrollo, testing, producción interna

```bash
# Configuración local
cd backend/supabase
supabase start
supabase status
```

#### **Opción 2: Supabase Cloud (Alternativa a Firebase)**
- **Ubicación**: Servidores de Supabase (AWS)
- **Ventajas**: Sin mantenimiento, escalabilidad automática, backups automáticos
- **Configuración**: Proyecto en [supabase.com](https://supabase.com)
- **Uso**: Producción, aplicaciones públicas, cuando se requiere alta disponibilidad

```bash
# Configuración cloud
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
supabase functions deploy
```

#### **Opción 3: Servidor Independiente (Tu Red Doméstica)**
- **Ubicación**: Tu servidor local/doméstico
- **Ventajas**: Control total, sin dependencias externas, costos mínimos
- **Configuración**: PostgreSQL + Supabase en tu infraestructura
- **Uso**: Producción interna, aplicaciones corporativas

### **Comparación de Opciones**

| Aspecto | Local | Cloud | Servidor Independiente |
|---------|-------|-------|----------------------|
| **Costo** | Gratis | Freemium/Paid | Mínimo (electricidad) |
| **Mantenimiento** | Manual | Automático | Manual |
| **Escalabilidad** | Limitada | Automática | Manual |
| **Backups** | Manual | Automático | Manual |
| **Uptime** | Depende de tu infra | 99.9%+ | Depende de tu infra |
| **Control** | Total | Limitado | Total |
| **Configuración** | Compleja | Simple | Compleja |

### **Configuración por Entorno**

#### **Desarrollo Local**
```bash
# Variables de entorno para desarrollo
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### **Supabase Cloud**
```bash
# Variables de entorno para cloud
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

#### **Servidor Independiente**
```bash
# Variables de entorno para servidor propio
SUPABASE_URL=https://your-server.com:54321
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### **Migración Entre Entornos**

#### **De Local a Cloud**
```bash
# 1. Crear proyecto en Supabase Cloud
# 2. Vincular proyecto local con cloud
supabase link --project-ref YOUR_PROJECT_REF

# 3. Subir migraciones
supabase db push

# 4. Desplegar funciones
supabase functions deploy

# 5. Actualizar variables de entorno en frontend
```

#### **De Local a Servidor Independiente**
```bash
# 1. Configurar PostgreSQL en tu servidor
# 2. Instalar Supabase en tu servidor
# 3. Exportar datos locales
supabase db dump

# 4. Importar en servidor independiente
psql -h your-server -U postgres -d postgres -f dump.sql

# 5. Configurar variables de entorno
```

### **Recomendaciones por Caso de Uso**

#### **Desarrollo y Testing**
- **Recomendado**: Supabase Local
- **Razón**: Control total, sin costos, desarrollo rápido

#### **Producción Interna/Corporativa**
- **Recomendado**: Servidor Independiente
- **Razón**: Control de datos, sin dependencias externas

#### **Aplicaciones Públicas/Startups**
- **Recomendado**: Supabase Cloud
- **Razón**: Escalabilidad, mantenimiento automático, alta disponibilidad

#### **MVP y Prototipos**
- **Recomendado**: Supabase Cloud (Plan Gratuito)
- **Razón**: Configuración rápida, sin mantenimiento

### **Variables por Entorno**
- Desarrollo local: Supabase CLI (`start/stop/status`) dentro de `backend/supabase`.
- Variables por entorno (dev/staging/prod) via `.env` y secretos de Supabase (para Edge Functions).
- **Desarrollo multiplataforma**: Configuración específica por plataforma durante desarrollo.

## 11. 📜 Licencia
Este repositorio se distribuye bajo licencia CC0-1.0 (ver `LICENSE`).

---

## 🚀 **¡LISTO PARA DESARROLLO MULTIPLATAFORMA!**

**Estado del proyecto**: Backend 100% completado, Frontend en planificación  
**Próximo hito**: Inicio del desarrollo frontend multiplataforma  
**Confianza**: Alta - Proyecto técnicamente sólido con estrategia multiplataforma definida