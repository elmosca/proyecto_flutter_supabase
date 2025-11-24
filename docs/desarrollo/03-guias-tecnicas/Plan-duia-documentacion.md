# Plan de Documentación Exhaustiva - Aplicación Flutter Supabase

## Objetivo

Documentar exhaustivamente todos los archivos Dart de la aplicación (108 archivos) con comentarios dartdoc que incluyan: descripción de clases/métodos, parámetros, valores de retorno, excepciones, ejemplos de uso, diagramas de flujo cuando sea relevante, y ejemplos JSON para modelos.

## Alcance Total

- **Services**: 20 archivos
- **Blocs**: 6 archivos  
- **Models**: 14 archivos
- **Screens**: 26 archivos
- **Widgets**: 32 archivos
- **Utils**: 6 archivos
- **Router/Config**: 4 archivos

## Estrategia por Funcionalidad Completa

### 1. Funcionalidad de Autenticación (Auth)

**Archivos a documentar**:

- `lib/services/auth_service.dart` - Lógica de login/logout con Supabase
- `lib/blocs/auth_bloc.dart` - Estados y eventos de autenticación
- `lib/screens/auth/login_screen_bloc.dart` - Pantalla de login
- `lib/services/permissions_service.dart` - Verificación de permisos por rol
- `lib/models/user.dart` - Modelo de usuario con roles

**Detalles de documentación**:

- Flujo completo de autenticación (diagrama ASCII)
- Manejo de sesiones y tokens
- Políticas RLS de Supabase
- Ejemplos de login/logout
- Excepciones: `AuthenticationException`, `NetworkException`
- JSON ejemplo del modelo User

### 2. Funcionalidad de Anteproyectos

**Archivos a documentar**:

- `lib/services/anteprojects_service.dart` - CRUD de anteproyectos
- `lib/blocs/anteprojects_bloc.dart` - Gestión de estado
- `lib/models/anteproject.dart` - Modelo con enum `ProjectType` y `AnteprojectStatus`
- `lib/screens/anteprojects/anteproject_detail_screen.dart` - Vista detalle
- `lib/screens/anteprojects/anteprojects_review_screen.dart` - Pantalla de revisión para tutores
- `lib/screens/lists/my_anteprojects_list.dart` - Lista estudiante
- `lib/screens/lists/tutor_anteprojects_list.dart` - Lista tutor
- `lib/screens/lists/anteprojects_list.dart` - Lista general
- `lib/screens/forms/anteproject_form.dart` - Formulario creación
- `lib/screens/forms/anteproject_edit_form.dart` - Formulario edición

**Detalles de documentación**:

- Estados del anteproyecto: draft, submitted, under_review, approved, rejected, changes_requested
- Validaciones del modelo (validators)
- JSON completo de ejemplo con timeline y expectedResults
- Filtrado por rol (estudiante/tutor/admin)
- Manejo de archivos adjuntos
- Excepciones: `ValidationException`, `PermissionException`, `DatabaseException`

### 3. Funcionalidad de Comentarios

**Archivos a documentar**:

- `lib/services/anteproject_comments_service.dart` - Comentarios específicos de anteproyectos
- `lib/services/comments_service.dart` - Comentarios genéricos
- `lib/blocs/comments_bloc.dart` - Estado de comentarios
- `lib/models/anteproject_comment.dart` - Modelo de comentario específico
- `lib/models/comment.dart` - Modelo genérico
- `lib/screens/anteprojects/anteproject_comments_screen.dart` - Pantalla de comentarios
- `lib/widgets/comments/comments_widget.dart` - Widget contenedor
- `lib/widgets/comments/comment_card.dart` - Tarjeta individual
- `lib/widgets/comments/add_comment_form.dart` - Formulario nuevo comentario

**Detalles de documentación**:

- Diferencia entre comentarios genéricos y específicos de anteproyectos
- Permisos por rol para crear/editar comentarios
- Formato Markdown en comentarios
- JSON ejemplo con timestamps y relaciones

### 4. Funcionalidad de Aprobaciones (Approval Flow)

**Archivos a documentar**:

- `lib/services/approval_service.dart` - Lógica de aprobación/rechazo
- `lib/blocs/approval_bloc.dart` - Estados del flujo
- `lib/screens/approval/approval_screen.dart` - Pantalla principal
- `lib/widgets/approval/approval_dialog.dart` - Diálogo de confirmación
- `lib/widgets/approval/approval_actions_widget.dart` - Botones de acción
- `lib/widgets/approval/anteproject_approval_card.dart` - Tarjeta de anteproyecto pendiente
- `lib/widgets/approval/pending_approvals_list.dart` - Lista de pendientes
- `lib/widgets/approval/reviewed_anteprojects_list.dart` - Lista de revisados

**Detalles de documentación**:

- Estados de aprobación: pending, approved, rejected, changes_requested
- Notificaciones automáticas por email
- Validaciones de permisos (solo tutores/admin)
- Flujo de transición de estados
- Excepciones específicas

### 5. Funcionalidad de Tareas (Tasks)

**Archivos a documentar**:

- `lib/services/tasks_service.dart` - CRUD de tareas
- `lib/blocs/tasks_bloc.dart` - Estado de tareas
- `lib/models/task.dart` - Modelo con prioridad y estado
- `lib/screens/lists/tasks_list.dart` - Lista de tareas
- `lib/screens/details/task_detail_screen.dart` - Detalle de tarea
- `lib/screens/forms/task_form.dart` - Formulario
- `lib/screens/kanban/kanban_board.dart` - Tablero Kanban
- `lib/utils/task_localizations.dart` - Traducciones específicas

**Detalles de documentación**:

- Estados: todo, in_progress, in_review, done, blocked
- Prioridad: low, medium, high, urgent
- Paginación y filtrado
- Drag & drop en Kanban
- JSON ejemplo completo
- Validaciones de fechas (due_date)

### 6. Funcionalidad de Archivos (Files)

**Archivos a documentar**:

- `lib/services/files_service.dart` - Upload/download con Supabase Storage
- `lib/services/pdf_service.dart` - Generación de PDFs
- `lib/screens/files/file_upload_screen.dart` - Pantalla de subida
- `lib/widgets/files/file_upload_widget.dart` - Widget de upload
- `lib/widgets/files/file_list_widget.dart` - Lista de archivos

**Detalles de documentación**:

- Tipos de archivo permitidos y validaciones de tamaño
- Estructura de buckets en Supabase Storage
- Generación de PDFs con reportes
- Seguridad y políticas de acceso
- Excepciones: `FileException`, `StorageException`

### 7. Funcionalidad de Proyectos (Projects)

**Archivos a documentar**:

- `lib/services/projects_service.dart` - Gestión de proyectos aprobados
- `lib/models/project.dart` - Modelo de proyecto
- `lib/screens/lists/student_projects_list.dart` - Lista de proyectos

**Detalles de documentación**:

- Relación anteproject → project tras aprobación
- Estados del proyecto vs anteproyecto
- JSON ejemplo
- Hitos y seguimiento

### 8. Funcionalidad de Notificaciones

**Archivos a documentar**:

- `lib/services/notifications_service.dart` - Sistema de notificaciones en app
- `lib/services/email_notification_service.dart` - Envío de emails
- `lib/screens/notifications/notifications_screen.dart` - Pantalla de notificaciones
- `lib/widgets/notifications/notifications_bell.dart` - Icono con contador
- `lib/utils/notification_localizations.dart` - Traducciones

**Detalles de documentación**:

- Tipos de notificaciones (system, approval, task, comment)
- Triggers automáticos
- Integración con Resend/SMTP
- Estado leído/no leído
- Excepciones de envío de email

### 9. Funcionalidad de Gestión de Usuarios

**Archivos a documentar**:

- `lib/services/user_management_service.dart` - CRUD de usuarios (admin)
- `lib/services/user_service.dart` - Operaciones sobre usuario actual
- `lib/screens/student/student_list_screen.dart` - Lista de estudiantes
- `lib/screens/forms/add_student_form.dart` - Crear estudiante
- `lib/screens/forms/edit_student_form.dart` - Editar estudiante
- `lib/screens/forms/tutor_creation_form.dart` - Crear tutor (widget)
- `lib/screens/forms/import_students_csv_screen.dart` - Importación masiva
- `lib/widgets/forms/csv_import_widget.dart` - Widget de importación
- `lib/widgets/dialogs/add_students_dialog.dart` - Diálogo de alta
- `lib/widgets/demo/imported_students_demo.dart` - Demo de importados

**Detalles de documentación**:

- Roles: student, tutor, admin
- Validaciones de email y contraseña
- Importación CSV (formato y validaciones)
- Políticas de acceso por rol
- Excepciones de validación

### 10. Funcionalidad de Calendario/Horarios

**Archivos a documentar**:

- `lib/services/schedule_service.dart` - Gestión de horarios
- `lib/models/schedule.dart` - Modelo de horario
- `lib/screens/schedule/schedule_management_screen.dart` - Pantalla de gestión
- `lib/widgets/calendar/academic_calendar_widget.dart` - Widget de calendario

**Detalles de documentación**:

- Eventos académicos
- Formato de fechas y zonas horarias
- JSON ejemplo
- Validaciones de solapamiento

### 11. Funcionalidad de Dashboards

**Archivos a documentar**:

- `lib/screens/dashboard/student_dashboard_screen.dart` - Dashboard estudiante
- `lib/screens/dashboard/tutor_dashboard.dart` - Dashboard tutor
- `lib/screens/dashboard/admin_dashboard.dart` - Dashboard admin
- `lib/screens/dashboard/components/dashboard_quick_actions.dart` - Componente de acciones rápidas
- `lib/widgets/dashboard/tutor_dashboard_enhanced.dart` - Dashboard mejorado tutor
- `lib/services/admin_stats_service.dart` - Estadísticas para admin

**Detalles de documentación**:

- Widgets específicos por rol
- Métricas y KPIs mostrados
- Navegación a secciones
- Integración con servicios

### 12. Infraestructura y Utilities

**Archivos a documentar**:

- `lib/utils/app_exception.dart` - Sistema de excepciones personalizado
- `lib/utils/error_translator.dart` - Traducción de errores a mensajes usuario
- `lib/utils/network_error_detector.dart` - Detección de errores de red
- `lib/utils/validators.dart` - Validadores de formularios
- `lib/services/supabase_interceptor.dart` - Interceptor de errores Supabase
- `lib/services/logging_service.dart` - Sistema de logging

**Detalles de documentación**:

- Jerarquía de excepciones custom
- Códigos de error y mapeo a mensajes i18n
- Detección de timeout, sin conexión, etc.
- Validadores reutilizables (email, password, etc.)
- Interceptor de PostgrestException
- Niveles de log y almacenamiento

### 13. Navegación y Theming

**Archivos a documentar**:

- `lib/router/app_router.dart` - Rutas con GoRouter
- `lib/widgets/navigation/persistent_scaffold.dart` - Scaffold persistente
- `lib/widgets/navigation/app_side_drawer.dart` - Menú lateral por rol
- `lib/widgets/navigation/app_top_bar.dart` - Barra superior
- `lib/themes/role_themes.dart` - Temas por rol
- `lib/services/theme_service.dart` - Servicio de tema
- `lib/services/language_service.dart` - Servicio de idioma
- `lib/widgets/common/language_selector.dart` - Selector de idioma

**Detalles de documentación**:

- Rutas protegidas por autenticación
- Menú adaptado a rol de usuario
- Temas: student (azul), tutor (verde), admin (púrpura)
- Persistencia de preferencias
- Localización (es/en)

### 14. Widgets Comunes

**Archivos a documentar**:

- `lib/widgets/common/error_handler_widget.dart` - Manejo de errores UI
- `lib/widgets/common/loading_widget.dart` - Indicador de carga
- `lib/widgets/common/form_validators.dart` - Validadores visuales
- `lib/widgets/common/test_credentials_widget.dart` - Widget de credenciales de prueba
- `lib/widgets/error_boundary.dart` - Error boundary para widgets
- `lib/widgets/test_credentials_widget.dart` - Duplicado (revisar)

**Detalles de documentación**:

- Uso y personalización
- Manejo de estados de error
- Reutilización en formularios

### 15. Configuración y Main

**Archivos a documentar**:

- `lib/main.dart` - Punto de entrada de la app
- `lib/config/app_config.dart` - Configuración de Supabase y entorno
- `lib/l10n/app_localizations.dart` - Clase de localizaciones
- `lib/l10n/app_localizations_es.dart` - Traducciones español
- `lib/l10n/app_localizations_en.dart` - Traducciones inglés

**Detalles de documentación**:

- Inicialización de Supabase
- Variables de entorno
- Sistema de localización
- Providers y configuración global

## Configuración dartdoc

Crear archivo `frontend/dartdoc_options.yaml`:

```yaml
dartdoc:
  categoryOrder: ["Services", "Blocs", "Models", "Screens", "Widgets", "Utils"]
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  showUndocumentedCategories: true
  includeExternal: []
  nodoc: []
  
  # Configuración de enlaces
  linkToSource:
    root: "."
    uriTemplate: "https://github.com/tu-usuario/tu-repo/blob/main/%f%#L%l%"
```

## Estándar de Documentación

Cada archivo debe incluir:

### Para Clases/Servicios:

````dart
/// Servicio para gestionar [descripción breve].
///
/// Este servicio proporciona [descripción detallada de responsabilidades].
/// Se integra con [dependencias externas].
///
/// ## Funcionalidades principales:
/// - Funcionalidad 1
/// - Funcionalidad 2
///
/// ## Ejemplo de uso:
/// ```dart
/// final service = MiServicio(supabase);
/// final resultado = await service.metodo();
/// ```
///
/// ## Excepciones:
/// - Lanza [TipoExcepcion] cuando [condición]
///
/// ## Seguridad:
/// - Requiere autenticación: Sí/No
/// - Roles permitidos: [student, tutor, admin]
/// - Políticas RLS aplicadas: [descripción]
///
/// Ver también: [ClaseRelacionada], [OtraClase]
class MiClase {
````

### Para Métodos:

````dart
  /// [Descripción breve del método en una línea].
  ///
  /// [Descripción detallada si es necesario].
  ///
  /// **Parámetros:**
  /// - [param1]: Descripción del parámetro 1
  /// - [param2]: Descripción del parámetro 2 (opcional)
  ///
  /// **Retorna:**
  /// Un [TipoRetorno] que contiene [descripción].
  ///
  /// **Lanza:**
  /// - [ExcepcionTipo1] si [condición]
  /// - [ExcepcionTipo2] cuando [condición]
  ///
  /// **Ejemplo:**
  /// ```dart
  /// final resultado = await metodo(param1: 'valor');
  /// ```
  Future<TipoRetorno> metodo({required String param1}) async {
````

### Para Modelos:

````dart
/// Modelo que representa [entidad].
///
/// Este modelo se mapea a la tabla `nombre_tabla` en Supabase.
///
/// ## Propiedades:
/// - [id]: Identificador único autoincremental
/// - [name]: Nombre del [entidad] (requerido, max 255 caracteres)
/// - [status]: Estado actual, puede ser: [listar valores del enum]
///
/// ## Ejemplo JSON:
/// ```json
/// {
///   "id": 1,
///   "name": "Ejemplo",
///   "status": "active",
///   "created_at": "2025-01-01T00:00:00Z"
/// }
/// ```
///
/// ## Validaciones:
/// - [name] no puede estar vacío
/// - [email] debe ser un email válido
///
/// Ver también: [ModeloRelacionado]
@JsonSerializable()
class MiModelo {
  /// Identificador único del modelo.
  ///
  /// Generado automáticamente por la base de datos.
  final int id;
  
  /// Nombre descriptivo del [entidad].
  ///
  /// Debe tener entre 3 y 255 caracteres.
  /// No puede contener caracteres especiales.
  final String name;
````

### Para Widgets:

````dart
/// Widget para [descripción breve].
///
/// Este widget [descripción de comportamiento y responsabilidad].
///
/// ## Parámetros requeridos:
/// - [param1]: Descripción
///
/// ## Parámetros opcionales:
/// - [param2]: Descripción (por defecto: valor)
///
/// ## Ejemplo de uso:
/// ```dart
/// MiWidget(
///   param1: 'valor',
///   onPressed: () => print('Acción'),
/// )
/// ```
///
/// ## Comportamiento:
/// - Acción 1 cuando [condición]
/// - Acción 2 si [condición]
///
/// Ver también: [WidgetRelacionado]
class MiWidget extends StatelessWidget {
````

### Para Enums:

```dart
/// Estados posibles de [entidad].
///
/// - [draft]: Borrador inicial, editable por el creador
/// - [submitted]: Enviado para revisión, no editable
/// - [approved]: Aprobado por tutor/admin
/// - [rejected]: Rechazado con comentarios
enum MiEnum {
  /// Borrador inicial del [entidad].
  ///
  /// En este estado el usuario puede editar libremente.
  draft,
  
  /// Enviado para revisión.
  ///
  /// Ya no es editable por el estudiante.
  submitted,
}
```

## Orden de Implementación

1. **Autenticación** (5 archivos) - Base crítica
2. **Anteproyectos** (10 archivos) - Funcionalidad core
3. **Comentarios** (9 archivos) - Complemento de anteproyectos
4. **Aprobaciones** (8 archivos) - Flujo crítico
5. **Tareas** (8 archivos) - Funcionalidad paralela
6. **Archivos** (5 archivos) - Soporte
7. **Proyectos** (3 archivos) - Post-aprobación
8. **Notificaciones** (5 archivos) - Sistema transversal
9. **Gestión Usuarios** (10 archivos) - Admin
10. **Calendario** (4 archivos) - Planificación
11. **Dashboards** (6 archivos) - Vistas principales
12. **Infraestructura** (6 archivos) - Utilities
13. **Navegación y Theming** (8 archivos) - UI/UX
14. **Widgets Comunes** (6 archivos) - Componentes base
15. **Configuración** (5 archivos) - Setup

## Validación

Después de documentar cada funcionalidad:

1. Ejecutar `dart doc` para verificar que compila sin errores
2. Revisar HTML generado en `doc/api/`
3. Verificar enlaces internos entre clases
4. Confirmar que ejemplos de código son válidos

## Generación Final

Al terminar toda la documentación:

```bash
cd frontend
dart doc
```

La documentación HTML estará en `frontend/doc/api/index.html` lista para publicar.