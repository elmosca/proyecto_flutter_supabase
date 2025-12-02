# 4. ESTRUCTURA DEL CÓDIGO Y ORGANIZACIÓN

Este documento describe la organización del código fuente del frontend, los patrones de arquitectura utilizados y cómo navegar por el proyecto para continuar el desarrollo.

## 4.1. Estructura de Carpetas del Frontend

El proyecto Flutter sigue una arquitectura limpia y modular:

```
frontend/lib/
├── blocs/              # Gestión de estado (BLoC pattern)
├── config/             # Configuración de la aplicación
├── l10n/               # Internacionalización (español/inglés)
├── models/             # Modelos de datos y serialización JSON
├── router/             # Configuración de rutas (go_router)
├── screens/            # Pantallas principales de la aplicación
├── services/           # Lógica de negocio y comunicación con Supabase
├── themes/             # Temas y estilos por rol
├── utils/              # Utilidades y helpers
└── widgets/            # Widgets reutilizables
```

## 4.2. Gestión de Estado (BLoC Pattern)

El proyecto utiliza el patrón **BLoC** (Business Logic Component) para separar la lógica de negocio de la interfaz de usuario.

### BLoCs Disponibles

| BLoC | Responsabilidad | Archivo |
| :--- | :--- | :--- |
| `AuthBloc` | Autenticación y gestión de sesión | `blocs/auth_bloc.dart` |
| `AnteprojectsBloc` | Gestión de anteproyectos (CRUD) | `blocs/anteprojects_bloc.dart` |
| `TasksBloc` | Gestión de tareas y tablero Kanban | `blocs/tasks_bloc.dart` |
| `CommentsBloc` | Sistema de comentarios | `blocs/comments_bloc.dart` |
| `ApprovalBloc` | Flujo de aprobación de anteproyectos | `blocs/approval_bloc.dart` |

### Uso de BLoC

```dart
// Ejemplo: Escuchar cambios de estado
BlocBuilder<AnteprojectsBloc, AnteprojectsState>(
  builder: (context, state) {
    if (state is AnteprojectsLoading) {
      return CircularProgressIndicator();
    }
    if (state is AnteprojectsLoaded) {
      return ListView.builder(...);
    }
    return ErrorWidget();
  },
)
```

## 4.3. Servicios (Services)

Los servicios encapsulan la lógica de negocio y la comunicación con Supabase. Cada servicio es responsable de una entidad o funcionalidad específica.

### Servicios Principales

| Servicio | Responsabilidad | Archivo |
| :--- | :--- | :--- |
| `AuthService` | Autenticación y gestión de usuarios | `services/auth_service.dart` |
| `AnteprojectsService` | CRUD de anteproyectos | `services/anteprojects_service.dart` |
| `TasksService` | CRUD de tareas y Kanban | `services/tasks_service.dart` |
| `CommentsService` | Gestión de comentarios | `services/comments_service.dart` |
| `FilesService` | Gestión de archivos (Supabase Storage) | `services/files_service.dart` |
| `NotificationsService` | Sistema de notificaciones | `services/notifications_service.dart` |
| `ProjectsService` | Gestión de proyectos activos | `services/projects_service.dart` |
| `PermissionsService` | Verificación de permisos por rol | `services/permissions_service.dart` |
| `UserManagementService` | Gestión de usuarios (admin) | `services/user_management_service.dart` |

### Patrón de Servicio

```dart
// Ejemplo: Estructura típica de un servicio
class AnteprojectsService {
  final SupabaseClient _supabase;
  
  AnteprojectsService(this._supabase);
  
  Future<List<Anteproject>> getAnteprojects() async {
    // Lógica de negocio y llamadas a Supabase
  }
  
  Future<Anteproject> createAnteproject(Anteproject anteproject) async {
    // Validaciones y creación
  }
}
```

## 4.4. Modelos de Datos

Los modelos representan las entidades del sistema y utilizan serialización JSON para comunicarse con Supabase.

### Modelos Principales

| Modelo | Entidad | Archivo |
| :--- | :--- | :--- |
| `User` | Usuario del sistema | `models/user.dart` |
| `Anteproject` | Anteproyecto de TFG | `models/anteproject.dart` |
| `Project` | Proyecto activo | `models/project.dart` |
| `Task` | Tarea del proyecto | `models/task.dart` |
| `Comment` | Comentario | `models/comment.dart` |
| `Notification` | Notificación | `models/notification.dart` |

### Generación de Código

Los modelos utilizan `json_serializable` para generar código de serialización:

```bash
# Regenerar código después de modificar modelos
flutter packages pub run build_runner build
```

## 4.5. Pantallas (Screens)

Las pantallas están organizadas por funcionalidad:

```
screens/
├── admin/              # Pantallas de administración
├── anteprojects/       # Gestión de anteproyectos
├── approval/           # Flujo de aprobación
├── auth/               # Autenticación
├── dashboard/          # Dashboards por rol
├── details/            # Pantallas de detalle
├── files/              # Gestión de archivos
├── forms/              # Formularios
├── kanban/             # Tablero Kanban
├── lists/              # Listas de entidades
├── messages/           # Sistema de mensajería
├── notifications/      # Notificaciones
├── projects/           # Gestión de proyectos
├── schedule/           # Calendario y horarios
└── student/            # Funcionalidades de estudiante
```

### Navegación con go_router

El proyecto utiliza `go_router` para la navegación declarativa:

```dart
// Ejemplo: Navegación programática
context.go('/anteprojects/${anteproject.id}');

// Ejemplo: Definición de ruta
GoRoute(
  path: '/anteprojects/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return AnteprojectDetailScreen(anteprojectId: id);
  },
)
```

## 4.6. Widgets Reutilizables

Los widgets están organizados por funcionalidad:

```
widgets/
├── approval/           # Widgets de aprobación
├── calendar/           # Componentes de calendario
├── chat/               # Sistema de chat
├── comments/           # Widgets de comentarios
├── common/             # Widgets comunes
├── dashboard/          # Componentes de dashboard
├── dialogs/            # Diálogos reutilizables
├── files/              # Gestión de archivos
├── forms/              # Componentes de formulario
├── help/               # Ayuda contextual
├── navigation/         # Navegación y menús
├── notifications/      # Notificaciones
└── settings/           # Configuración
```

## 4.7. Internacionalización (i18n)

El proyecto soporta múltiples idiomas mediante el sistema de localización de Flutter.

### Archivos de Traducción

- `l10n/app_es.arb` - Traducciones en español
- `l10n/app_en.arb` - Traducciones en inglés

### Uso en Código

```dart
// Obtener traducción
final l10n = AppLocalizations.of(context)!;
Text(l10n.anteprojectTitle);

// Con parámetros
Text(l10n.welcomeMessage(userName));
```

### Añadir Nuevas Traducciones

1. Añadir clave en `app_es.arb` y `app_en.arb`
2. Ejecutar `flutter gen-l10n` para regenerar
3. Usar en código con `AppLocalizations.of(context)!.tuClave`

## 4.8. Testing

El proyecto incluye tests unitarios y de integración.

### Estructura de Tests

```
test/
├── unit/               # Tests unitarios (BLoCs, Services)
├── integration/        # Tests de integración
└── widget/            # Tests de widgets
```

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Tests específicos
flutter test test/unit/blocs/auth_bloc_test.dart
```

### BLoCs con Tests

- `AuthBloc` - Tests completos
- `TasksBloc` - Tests completos

## 4.9. Edge Functions (Supabase)

El proyecto utiliza **Edge Functions** de Supabase para lógica de negocio avanzada que requiere ejecución en el servidor.

### Funciones Disponibles

| Función | Propósito | Ubicación |
| :--- | :--- | :--- |
| `send-email` | Envío de notificaciones por email | Supabase Dashboard > Edge Functions |

### Uso de Edge Functions

```dart
// Ejemplo: Llamada a Edge Function
final response = await supabase.functions.invoke(
  'send-email',
  body: {
    'to': userEmail,
    'subject': 'Notificación',
    'body': 'Contenido del email',
  },
);
```

## 4.10. Configuración y Variables de Entorno

### Archivos de Configuración

- `config/app_config.dart` - Configuración pública (placeholders)
- `config/app_config_local.dart` - Configuración local (credenciales reales, en `.gitignore`)
- `config/app_config_template.dart` - Plantilla para nuevos desarrolladores

### Variables de Entorno

El proyecto utiliza `dart-define` para inyectar variables en tiempo de ejecución:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu_anon_key
```

## 4.11. Convenciones de Código

### Nomenclatura

- **Archivos**: `snake_case.dart` (ej: `anteproject_service.dart`)
- **Clases**: `PascalCase` (ej: `AnteprojectService`)
- **Variables**: `camelCase` (ej: `anteprojectList`)
- **Constantes**: `SCREAMING_SNAKE_CASE` (ej: `MAX_FILE_SIZE`)

### Estructura de Archivos

```dart
// 1. Imports (paquetes externos, luego internos)
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/anteproject.dart';

// 2. Clase principal
class AnteprojectService {
  // 3. Campos privados
  final SupabaseClient _supabase;
  
  // 4. Constructor
  AnteprojectService(this._supabase);
  
  // 5. Métodos públicos
  Future<List<Anteproject>> getAnteprojects() async {
    // Implementación
  }
  
  // 6. Métodos privados
  void _validateAnteproject(Anteproject anteproject) {
    // Validaciones
  }
}
```

## 4.12. Flujo de Datos Típico

```
Usuario → Widget → BLoC → Service → Supabase → Base de Datos
                ↓
            Estado → Widget (UI actualizada)
```

### Ejemplo Completo

1. **Usuario** hace clic en "Crear Anteproyecto"
2. **Widget** dispara evento: `AnteprojectsEvent.create(anteproject)`
3. **BLoC** recibe evento y llama a `AnteprojectsService.create()`
4. **Service** valida y envía a Supabase
5. **Supabase** inserta en base de datos
6. **BLoC** emite nuevo estado: `AnteprojectsLoaded(anteprojects)`
7. **Widget** se reconstruye con nuevos datos

## 4.13. Recursos Adicionales

- **Documentación Flutter**: https://flutter.dev/docs
- **BLoC Pattern**: https://bloclibrary.dev
- **Supabase Flutter**: https://supabase.com/docs/reference/dart
- **go_router**: https://pub.dev/packages/go_router

---

*Este documento describe la estructura actual del código. Para detalles específicos de implementación, consultar el código fuente y los comentarios inline.*

