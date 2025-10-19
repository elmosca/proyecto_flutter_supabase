import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Título principal de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Sistema de Gestión TFG'**
  String get appTitle;

  /// Botón o acción de iniciar sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// Campo de email
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get email;

  /// Campo de contraseña
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// Mensaje de error al fallar el login
  ///
  /// In es, this message translates to:
  /// **'Error de inicio de sesión. Por favor, verifica tus credenciales.'**
  String get loginError;

  /// Pantalla principal del usuario
  ///
  /// In es, this message translates to:
  /// **'Panel Principal'**
  String get dashboard;

  /// Sección de proyectos
  ///
  /// In es, this message translates to:
  /// **'Proyectos'**
  String get projects;

  /// Sección de tareas
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get tasks;

  /// Sección de perfil de usuario
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// Acción de cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// Rol de estudiante
  ///
  /// In es, this message translates to:
  /// **'Estudiante'**
  String get student;

  /// Rol de tutor
  ///
  /// In es, this message translates to:
  /// **'Tutor'**
  String get tutor;

  /// Rol de administrador
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get admin;

  /// Mensaje de bienvenida
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get welcome;

  /// Mensaje de carga
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// Mensaje de error genérico
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// Mensaje de éxito genérico
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get success;

  /// Botón de cancelar
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Botón de guardar
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Botón de editar
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// Mensaje de éxito al crear tarea
  ///
  /// In es, this message translates to:
  /// **'Tarea creada exitosamente'**
  String get taskCreatedSuccess;

  /// Mensaje de éxito al actualizar tarea
  ///
  /// In es, this message translates to:
  /// **'Tarea actualizada exitosamente'**
  String get taskUpdatedSuccess;

  /// Mensaje de éxito al actualizar estado de tarea
  ///
  /// In es, this message translates to:
  /// **'Estado de tarea actualizado'**
  String get taskStatusUpdatedSuccess;

  /// Mensaje de éxito al eliminar tarea
  ///
  /// In es, this message translates to:
  /// **'Tarea eliminada exitosamente'**
  String get taskDeletedSuccess;

  /// Mensaje de error cuando no se encuentra la tarea
  ///
  /// In es, this message translates to:
  /// **'Tarea no encontrada'**
  String get taskNotFound;

  /// Título de la sección con credenciales de prueba
  ///
  /// In es, this message translates to:
  /// **'Credenciales de prueba'**
  String get testCredentialsTitle;

  /// Etiqueta para las credenciales de administrador
  ///
  /// In es, this message translates to:
  /// **'👨‍💼 Administrador'**
  String get testCredentialsAdmin;

  /// Etiqueta para las credenciales de tutor
  ///
  /// In es, this message translates to:
  /// **'👨‍🏫 Tutor'**
  String get testCredentialsTutor;

  /// Etiqueta para las credenciales de estudiante
  ///
  /// In es, this message translates to:
  /// **'👨‍🎓 Estudiante'**
  String get testCredentialsStudent;

  /// Texto para la acción de copiar
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get copy;

  /// Mensaje mostrado cuando se copia un valor
  ///
  /// In es, this message translates to:
  /// **'Copiado al portapapeles: {value}'**
  String copiedToClipboard(String value);

  /// Botón de eliminar
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// Botón de crear
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// Campo o acción de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// Mensaje cuando no hay datos
  ///
  /// In es, this message translates to:
  /// **'No hay datos disponibles'**
  String get noData;

  /// Mensaje de error de conexión
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Por favor, verifica tu conexión a internet.'**
  String get connectionError;

  /// Título del formulario de creación de anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Crear Anteproyecto'**
  String get anteprojectFormTitle;

  /// Título del formulario de edición de anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Editar Anteproyecto'**
  String get anteprojectEditFormTitle;

  /// Campo tipo de proyecto del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Tipo de proyecto'**
  String get anteprojectType;

  /// Campo descripción del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get anteprojectDescription;

  /// Campo año académico del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Año académico (e.g., 2024-2025)'**
  String get anteprojectAcademicYear;

  /// Campo resultados esperados del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Resultados esperados (JSON)'**
  String get anteprojectExpectedResults;

  /// Campo temporalización del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Temporalización (JSON)'**
  String get anteprojectTimeline;

  /// Campo ID del tutor del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Tutor ID'**
  String get anteprojectTutorId;

  /// Botón para crear anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Crear anteproyecto'**
  String get anteprojectCreateButton;

  /// Botón para actualizar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Actualizar anteproyecto'**
  String get anteprojectUpdateButton;

  /// Botón para eliminar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get anteprojectDeleteButton;

  /// Título del diálogo de eliminación de anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Eliminar Anteproyecto'**
  String get anteprojectDeleteTitle;

  /// Mensaje del diálogo de eliminación de anteproyecto
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar este anteproyecto? Esta acción no se puede deshacer.'**
  String get anteprojectDeleteMessage;

  /// Mensaje de éxito al crear anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto creado exitosamente'**
  String get anteprojectCreatedSuccess;

  /// Mensaje de éxito al actualizar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto actualizado exitosamente'**
  String get anteprojectUpdatedSuccess;

  /// Mensaje de error para ID de tutor inválido
  ///
  /// In es, this message translates to:
  /// **'Tutor ID inválido'**
  String get anteprojectInvalidTutorId;

  /// Mensaje de validación para título requerido
  ///
  /// In es, this message translates to:
  /// **'El título es obligatorio'**
  String get anteprojectTitleRequired;

  /// Mensaje de validación para descripción requerida
  ///
  /// In es, this message translates to:
  /// **'La descripción es obligatoria'**
  String get anteprojectDescriptionRequired;

  /// Mensaje de validación para año académico requerido
  ///
  /// In es, this message translates to:
  /// **'El año académico es obligatorio'**
  String get anteprojectAcademicYearRequired;

  /// Mensaje de validación para ID de tutor requerido
  ///
  /// In es, this message translates to:
  /// **'El Tutor ID es obligatorio'**
  String get anteprojectTutorIdRequired;

  /// Mensaje de validación para ID de tutor numérico
  ///
  /// In es, this message translates to:
  /// **'El Tutor ID debe ser numérico'**
  String get anteprojectTutorIdNumeric;

  /// Título de la lista de anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Mis Anteproyectos'**
  String get anteprojectsListTitle;

  /// Botón para actualizar la lista de anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Actualizar lista'**
  String get anteprojectsListRefresh;

  /// Mensaje de error al cargar la lista de anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Error al cargar anteproyectos'**
  String get anteprojectsListError;

  /// Botón para reintentar cargar la lista
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get anteprojectsListRetry;

  /// Mensaje cuando la lista de anteproyectos está vacía
  ///
  /// In es, this message translates to:
  /// **'No tienes anteproyectos'**
  String get anteprojectsListEmpty;

  /// Subtítulo cuando la lista de anteproyectos está vacía
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer anteproyecto para comenzar'**
  String get anteprojectsListEmptySubtitle;

  /// Mensaje para estado desconocido en la lista
  ///
  /// In es, this message translates to:
  /// **'Estado no reconocido'**
  String get anteprojectsListUnknownState;

  /// Botón para editar en la lista de anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get anteprojectsListEdit;

  /// Tooltip para el botón de eliminar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Eliminar anteproyecto'**
  String get anteprojectDeleteTooltip;

  /// Botón para añadir un nuevo comentario
  ///
  /// In es, this message translates to:
  /// **'Añadir comentario'**
  String get commentsAddComment;

  /// Placeholder para el campo de comentario
  ///
  /// In es, this message translates to:
  /// **'Escribe tu comentario...'**
  String get commentsWriteComment;

  /// Botón para enviar comentario
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get commentsSend;

  /// Botón para cancelar comentario
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commentsCancel;

  /// Etiqueta para comentarios internos
  ///
  /// In es, this message translates to:
  /// **'Comentario interno'**
  String get commentsInternal;

  /// Etiqueta para comentarios públicos
  ///
  /// In es, this message translates to:
  /// **'Comentario público'**
  String get commentsPublic;

  /// Mensaje cuando no hay comentarios
  ///
  /// In es, this message translates to:
  /// **'No hay comentarios'**
  String get commentsNoComments;

  /// Mensaje para animar a comentar cuando no hay comentarios
  ///
  /// In es, this message translates to:
  /// **'Sé el primero en comentar'**
  String get commentsAddFirst;

  /// Mensaje de error al cargar comentarios
  ///
  /// In es, this message translates to:
  /// **'Error al cargar comentarios'**
  String get commentsError;

  /// Mensaje de error al añadir comentario
  ///
  /// In es, this message translates to:
  /// **'Error al añadir comentario'**
  String get commentsErrorAdd;

  /// Mensaje de éxito al añadir comentario
  ///
  /// In es, this message translates to:
  /// **'Comentario añadido correctamente'**
  String get commentsSuccess;

  /// Botón para eliminar comentario
  ///
  /// In es, this message translates to:
  /// **'Eliminar comentario'**
  String get commentsDelete;

  /// Mensaje de confirmación para eliminar comentario
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar este comentario?'**
  String get commentsDeleteConfirm;

  /// Botón para editar comentario
  ///
  /// In es, this message translates to:
  /// **'Editar comentario'**
  String get commentsEdit;

  /// Botón para guardar cambios en comentario
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get commentsSave;

  /// Etiqueta para el autor del comentario
  ///
  /// In es, this message translates to:
  /// **'Autor'**
  String get commentsAuthor;

  /// Etiqueta para la fecha del comentario
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get commentsDate;

  /// Etiqueta para el contenido del comentario
  ///
  /// In es, this message translates to:
  /// **'Contenido'**
  String get commentsContent;

  /// Mensaje de validación para contenido requerido
  ///
  /// In es, this message translates to:
  /// **'El contenido del comentario es obligatorio'**
  String get commentsContentRequired;

  /// Mensaje de validación para longitud mínima
  ///
  /// In es, this message translates to:
  /// **'El comentario debe tener al menos 3 caracteres'**
  String get commentsContentMinLength;

  /// Mensaje de validación para longitud máxima
  ///
  /// In es, this message translates to:
  /// **'El comentario no puede exceder 1000 caracteres'**
  String get commentsContentMaxLength;

  /// Texto para usuario desconocido
  ///
  /// In es, this message translates to:
  /// **'Usuario desconocido'**
  String get unknownUser;

  /// Texto para tiempo reciente
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get justNow;

  /// Etiqueta de estado con valor
  ///
  /// In es, this message translates to:
  /// **'Estado: {status}'**
  String anteprojectStatusLabel(String status);

  /// Hint para el campo de resultados esperados
  ///
  /// In es, this message translates to:
  /// **'Ejemplo milestone1 Descripción'**
  String get anteprojectExpectedResultsHint;

  /// Hint para el campo de temporalización
  ///
  /// In es, this message translates to:
  /// **'Ejemplo phase1 Descripción'**
  String get anteprojectTimelineHint;

  /// Título del dashboard de estudiante
  ///
  /// In es, this message translates to:
  /// **'Dashboard Estudiante'**
  String get dashboardStudent;

  /// Sección de anteproyectos del usuario
  ///
  /// In es, this message translates to:
  /// **'Mis Anteproyectos'**
  String get myAnteprojects;

  /// Enlace para ver todos los elementos
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get viewAll;

  /// Título de sección para anteproyectos pendientes
  ///
  /// In es, this message translates to:
  /// **'Anteproyectos Pendientes'**
  String get pendingAnteprojects;

  /// Título de sección para estudiantes asignados
  ///
  /// In es, this message translates to:
  /// **'Estudiantes Asignados'**
  String get assignedStudents;

  /// Mensaje cuando no hay anteproyectos
  ///
  /// In es, this message translates to:
  /// **'No tienes anteproyectos creados. ¡Crea tu primer anteproyecto!'**
  String get noAnteprojects;

  /// Sección de tareas pendientes
  ///
  /// In es, this message translates to:
  /// **'Tareas Pendientes'**
  String get pendingTasks;

  /// Enlace para ver todas las tareas
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get viewAllTasks;

  /// Mensaje cuando no hay tareas pendientes
  ///
  /// In es, this message translates to:
  /// **'No tienes tareas pendientes. ¡Excelente trabajo!'**
  String get noPendingTasks;

  /// Sección de información del sistema
  ///
  /// In es, this message translates to:
  /// **'Información del Sistema'**
  String get systemInfo;

  /// Etiqueta de backend con URL
  ///
  /// In es, this message translates to:
  /// **'Backend: {url}'**
  String backendLabel(String url);

  /// Etiqueta de plataforma con valor
  ///
  /// In es, this message translates to:
  /// **'Plataforma: {platform}'**
  String platformLabel(String platform);

  /// Etiqueta de versión con valor
  ///
  /// In es, this message translates to:
  /// **'Versión: {version}'**
  String versionLabel(String version);

  /// Etiqueta de email
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Mensaje de estado de conexión al servidor
  ///
  /// In es, this message translates to:
  /// **'Estado: Conectado al servidor de red'**
  String get connectedToServer;

  /// Sección de gestión de usuarios en dashboard de admin
  ///
  /// In es, this message translates to:
  /// **'Gestión de Usuarios'**
  String get dashboardAdminUsersManagement;

  /// Título del dashboard de tutor
  ///
  /// In es, this message translates to:
  /// **'Dashboard de Tutor'**
  String get dashboardTutor;

  /// Título del dashboard de administrador
  ///
  /// In es, this message translates to:
  /// **'Dashboard de Administrador'**
  String get dashboardAdmin;

  /// Mensaje para funcionalidades que estarán disponibles pronto
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get comingSoon;

  /// Mensaje cuando no hay proyectos disponibles para crear tareas
  ///
  /// In es, this message translates to:
  /// **'No hay proyectos disponibles para crear tareas. Asegúrate de que tu anteproyecto esté aprobado.'**
  String get noProjectsAvailableForTasks;

  /// Mensaje cuando no se ha seleccionado un proyecto para la tarea
  ///
  /// In es, this message translates to:
  /// **'Debe seleccionar un proyecto para crear la tarea'**
  String get mustSelectProjectForTask;

  /// Título de la sección de proyectos del estudiante
  ///
  /// In es, this message translates to:
  /// **'Mis Proyectos'**
  String get myProjects;

  /// Mensaje cuando el estudiante no tiene proyectos asignados
  ///
  /// In es, this message translates to:
  /// **'No tienes proyectos asignados. Contacta con tu tutor.'**
  String get noProjectsAssigned;

  /// Título para acceso a Supabase Studio
  ///
  /// In es, this message translates to:
  /// **'Supabase Studio'**
  String get supabaseStudio;

  /// Botón para abrir Supabase Studio
  ///
  /// In es, this message translates to:
  /// **'Abrir Supabase Studio'**
  String get openSupabaseStudio;

  /// Descripción del acceso a Supabase Studio
  ///
  /// In es, this message translates to:
  /// **'Acceso directo al panel de administración de la base de datos'**
  String get supabaseStudioDescription;

  /// Botón para abrir Inbucket (gestión de emails)
  ///
  /// In es, this message translates to:
  /// **'Abrir Inbucket'**
  String get openInbucket;

  /// Título para estadística de usuarios totales
  ///
  /// In es, this message translates to:
  /// **'Usuarios Totales'**
  String get totalUsers;

  /// Título para estadística de proyectos activos
  ///
  /// In es, this message translates to:
  /// **'Proyectos Activos'**
  String get activeProjects;

  /// Título para estadística de tutores
  ///
  /// In es, this message translates to:
  /// **'Tutores'**
  String get tutors;

  /// Mensaje cuando no hay usuarios
  ///
  /// In es, this message translates to:
  /// **'No hay usuarios'**
  String get noUsers;

  /// Título para el estado del sistema
  ///
  /// In es, this message translates to:
  /// **'Estado del Sistema'**
  String get systemStatus;

  /// Botón para cerrar diálogos
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// Sección de anteproyectos en dashboard de tutor
  ///
  /// In es, this message translates to:
  /// **'Mis Anteproyectos'**
  String get dashboardTutorMyAnteprojects;

  /// Configuración de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// Idioma español
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// Idioma inglés
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// Sección de información del servidor
  ///
  /// In es, this message translates to:
  /// **'Información del Servidor'**
  String get serverInfo;

  /// URL del servidor
  ///
  /// In es, this message translates to:
  /// **'URL del Servidor'**
  String get serverUrl;

  /// Versión de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// Sección de credenciales de prueba
  ///
  /// In es, this message translates to:
  /// **'Credenciales de Prueba'**
  String get testCredentials;

  /// Email de estudiante de prueba
  ///
  /// In es, this message translates to:
  /// **'Correo del Estudiante'**
  String get studentEmail;

  /// Email de tutor de prueba
  ///
  /// In es, this message translates to:
  /// **'Correo del Tutor'**
  String get tutorEmail;

  /// Email de administrador de prueba
  ///
  /// In es, this message translates to:
  /// **'Correo del Administrador'**
  String get adminEmail;

  /// Contraseña de prueba
  ///
  /// In es, this message translates to:
  /// **'Contraseña de Prueba'**
  String get testPassword;

  /// Enlace a Supabase Studio
  ///
  /// In es, this message translates to:
  /// **'Studio'**
  String get studio;

  /// Título de login exitoso
  ///
  /// In es, this message translates to:
  /// **'✅ Login Exitoso'**
  String get loginSuccessTitle;

  /// Acción de copiar al portapapeles
  ///
  /// In es, this message translates to:
  /// **'Copiar al portapapeles'**
  String get copyToClipboard;

  /// Título de error de validación
  ///
  /// In es, this message translates to:
  /// **'Error de validación'**
  String get validationError;

  /// Mensaje de error de validación de formulario
  ///
  /// In es, this message translates to:
  /// **'Por favor, corrige los errores en el formulario'**
  String get formValidationError;

  /// Título de error de red
  ///
  /// In es, this message translates to:
  /// **'Error de red'**
  String get networkError;

  /// Mensaje de error de red
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar al servidor. Verifica tu conexión a internet.'**
  String get networkErrorMessage;

  /// Título de error del servidor
  ///
  /// In es, this message translates to:
  /// **'Error del servidor'**
  String get serverError;

  /// Mensaje de error del servidor
  ///
  /// In es, this message translates to:
  /// **'El servidor no pudo procesar la solicitud. Inténtalo de nuevo más tarde.'**
  String get serverErrorMessage;

  /// Título de error desconocido
  ///
  /// In es, this message translates to:
  /// **'Error desconocido'**
  String get unknownError;

  /// Mensaje de error desconocido
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.'**
  String get unknownErrorMessage;

  /// Botón para confirmar
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// Respuesta afirmativa
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yes;

  /// Respuesta negativa
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// Botón de confirmación
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get ok;

  /// Mensaje de campo obligatorio genérico
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get fieldRequired;

  /// Mensaje de campo demasiado corto
  ///
  /// In es, this message translates to:
  /// **'Este campo es demasiado corto'**
  String get fieldTooShort;

  /// Mensaje de campo demasiado largo
  ///
  /// In es, this message translates to:
  /// **'Este campo es demasiado largo'**
  String get fieldTooLong;

  /// Mensaje de email inválido
  ///
  /// In es, this message translates to:
  /// **'El formato del email no es válido'**
  String get invalidEmail;

  /// Mensaje de URL inválida
  ///
  /// In es, this message translates to:
  /// **'La URL no tiene un formato válido'**
  String get invalidUrl;

  /// Mensaje de número inválido
  ///
  /// In es, this message translates to:
  /// **'El valor debe ser un número válido'**
  String get invalidNumber;

  /// Mensaje de JSON inválido
  ///
  /// In es, this message translates to:
  /// **'El formato JSON no es válido'**
  String get invalidJson;

  /// Mensaje de operación en progreso
  ///
  /// In es, this message translates to:
  /// **'Operación en progreso...'**
  String get operationInProgress;

  /// Mensaje de operación completada
  ///
  /// In es, this message translates to:
  /// **'Operación completada'**
  String get operationCompleted;

  /// Mensaje de operación fallida
  ///
  /// In es, this message translates to:
  /// **'La operación falló'**
  String get operationFailed;

  /// Título del formulario de tarea
  ///
  /// In es, this message translates to:
  /// **'Formulario de Tarea'**
  String get taskFormTitle;

  /// Título del formulario de edición de tarea
  ///
  /// In es, this message translates to:
  /// **'Editar Tarea'**
  String get taskEditFormTitle;

  /// Campo de título de tarea
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get taskTitle;

  /// Campo de descripción de tarea
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get taskDescription;

  /// Campo de estado de tarea
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get taskStatus;

  /// Campo de complejidad de tarea
  ///
  /// In es, this message translates to:
  /// **'Complejidad'**
  String get taskComplexity;

  /// Campo de fecha de vencimiento de tarea
  ///
  /// In es, this message translates to:
  /// **'Fecha de Vencimiento'**
  String get taskDueDate;

  /// Campo de horas estimadas de tarea
  ///
  /// In es, this message translates to:
  /// **'Horas Estimadas'**
  String get taskEstimatedHours;

  /// Campo de etiquetas de tarea
  ///
  /// In es, this message translates to:
  /// **'Etiquetas'**
  String get taskTags;

  /// Botón para crear tarea
  ///
  /// In es, this message translates to:
  /// **'Crear Tarea'**
  String get taskCreateButton;

  /// Botón para actualizar tarea
  ///
  /// In es, this message translates to:
  /// **'Actualizar Tarea'**
  String get taskUpdateButton;

  /// Mensaje de error cuando el título es requerido
  ///
  /// In es, this message translates to:
  /// **'El título es obligatorio'**
  String get taskTitleRequired;

  /// Mensaje de error cuando la descripción es requerida
  ///
  /// In es, this message translates to:
  /// **'La descripción es obligatoria'**
  String get taskDescriptionRequired;

  /// Estado de tarea pendiente
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get taskStatusPending;

  /// Estado de tarea en progreso
  ///
  /// In es, this message translates to:
  /// **'En Progreso'**
  String get taskStatusInProgress;

  /// Estado de tarea en revisión
  ///
  /// In es, this message translates to:
  /// **'En Revisión'**
  String get taskStatusUnderReview;

  /// Estado de tarea completada
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get taskStatusCompleted;

  /// Complejidad simple de tarea
  ///
  /// In es, this message translates to:
  /// **'Simple'**
  String get taskComplexitySimple;

  /// Complejidad media de tarea
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get taskComplexityMedium;

  /// Complejidad compleja de tarea
  ///
  /// In es, this message translates to:
  /// **'Compleja'**
  String get taskComplexityComplex;

  /// Título de la lista de tareas
  ///
  /// In es, this message translates to:
  /// **'Lista de Tareas'**
  String get tasksListTitle;

  /// Mensaje cuando no hay tareas en la lista
  ///
  /// In es, this message translates to:
  /// **'No hay tareas disponibles'**
  String get tasksListEmpty;

  /// Botón para actualizar la lista de tareas
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get tasksListRefresh;

  /// Título del tablero Kanban
  ///
  /// In es, this message translates to:
  /// **'Tablero Kanban'**
  String get kanbanBoardTitle;

  /// Columna de tareas pendientes en Kanban
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get kanbanColumnPending;

  /// Columna de tareas en progreso en Kanban
  ///
  /// In es, this message translates to:
  /// **'En Progreso'**
  String get kanbanColumnInProgress;

  /// Columna de tareas en revisión en Kanban
  ///
  /// In es, this message translates to:
  /// **'En Revisión'**
  String get kanbanColumnUnderReview;

  /// Columna de tareas completadas en Kanban
  ///
  /// In es, this message translates to:
  /// **'Completadas'**
  String get kanbanColumnCompleted;

  /// Mensaje de éxito al reordenar tarea en Kanban
  ///
  /// In es, this message translates to:
  /// **'Tarea reordenada exitosamente'**
  String get taskReorderedSuccess;

  /// Mensaje de éxito al actualizar posición de tarea
  ///
  /// In es, this message translates to:
  /// **'Posición de tarea actualizada'**
  String get taskPositionUpdatedSuccess;

  /// Texto mostrado mientras se mueve una tarea
  ///
  /// In es, this message translates to:
  /// **'Moviendo...'**
  String get movingTask;

  /// Título de notificación cuando se actualiza el estado de una tarea
  ///
  /// In es, this message translates to:
  /// **'Estado de tarea actualizado'**
  String get taskStatusUpdatedNotification;

  /// Mensaje de notificación cuando cambia el estado de una tarea
  ///
  /// In es, this message translates to:
  /// **'La tarea \"{taskTitle}\" cambió a estado: {status}'**
  String taskStatusChangedMessage(String taskTitle, String status);

  /// Título de notificación cuando se asigna una tarea
  ///
  /// In es, this message translates to:
  /// **'Tarea asignada'**
  String get taskAssignedNotification;

  /// Mensaje de notificación cuando se asigna una tarea
  ///
  /// In es, this message translates to:
  /// **'Se te ha asignado la tarea: \"{taskTitle}\"'**
  String taskAssignedMessage(String taskTitle);

  /// Título de notificación cuando se añade un comentario a una tarea
  ///
  /// In es, this message translates to:
  /// **'Nuevo comentario en tarea'**
  String get newCommentNotification;

  /// Mensaje de notificación cuando se añade un comentario
  ///
  /// In es, this message translates to:
  /// **'Nuevo comentario en \"{taskTitle}\": {commentPreview}'**
  String newCommentMessage(String taskTitle, String commentPreview);

  /// Texto para seleccionar fecha
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha'**
  String get selectDate;

  /// Botón para crear una nueva tarea
  ///
  /// In es, this message translates to:
  /// **'Crear Tarea'**
  String get createTask;

  /// Título del flujo de aprobación
  ///
  /// In es, this message translates to:
  /// **'Flujo de Aprobación'**
  String get approvalWorkflow;

  /// Sección de aprobaciones pendientes
  ///
  /// In es, this message translates to:
  /// **'Aprobaciones Pendientes'**
  String get pendingApprovals;

  /// Sección de anteproyectos ya revisados
  ///
  /// In es, this message translates to:
  /// **'Anteproyectos Revisados'**
  String get reviewedAnteprojects;

  /// Botón para aprobar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get approveAnteproject;

  /// Botón para rechazar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get rejectAnteproject;

  /// Acción de solicitar cambios en un anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Solicitar Cambios'**
  String get requestChanges;

  /// Campo para comentarios en el proceso de aprobación
  ///
  /// In es, this message translates to:
  /// **'Comentarios de Aprobación'**
  String get approvalComments;

  /// Placeholder para comentarios de aprobación
  ///
  /// In es, this message translates to:
  /// **'Comentarios sobre la aprobación...'**
  String get approvalCommentsHint;

  /// Campo para comentarios en el proceso de rechazo
  ///
  /// In es, this message translates to:
  /// **'Comentarios de Rechazo'**
  String get rejectionComments;

  /// Placeholder para comentarios de rechazo
  ///
  /// In es, this message translates to:
  /// **'Motivo del rechazo...'**
  String get rejectionCommentsHint;

  /// Campo para comentarios sobre cambios solicitados
  ///
  /// In es, this message translates to:
  /// **'Comentarios sobre Cambios'**
  String get changesComments;

  /// Texto de ayuda para el campo de comentarios de cambios
  ///
  /// In es, this message translates to:
  /// **'Especifica los cambios necesarios (obligatorio)'**
  String get changesCommentsHint;

  /// Título del diálogo de confirmación de aprobación
  ///
  /// In es, this message translates to:
  /// **'Confirmar Aprobación'**
  String get confirmApproval;

  /// Título del diálogo de confirmación de rechazo
  ///
  /// In es, this message translates to:
  /// **'Confirmar Rechazo'**
  String get confirmRejection;

  /// Título del diálogo de confirmación de solicitud de cambios
  ///
  /// In es, this message translates to:
  /// **'Confirmar Solicitud de Cambios'**
  String get confirmChanges;

  /// Mensaje de confirmación para aprobar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres aprobar este anteproyecto?'**
  String get approvalConfirmMessage;

  /// Mensaje de confirmación para rechazar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres rechazar este anteproyecto?'**
  String get rejectionConfirmMessage;

  /// Mensaje de confirmación para solicitar cambios
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres solicitar cambios en este anteproyecto?'**
  String get changesConfirmMessage;

  /// Mensaje de éxito al aprobar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto aprobado exitosamente'**
  String get approvalSuccess;

  /// Mensaje de éxito al rechazar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto rechazado exitosamente'**
  String get rejectionSuccess;

  /// Mensaje de éxito al solicitar cambios
  ///
  /// In es, this message translates to:
  /// **'Cambios solicitados exitosamente'**
  String get changesSuccess;

  /// Mensaje de error en el proceso de aprobación
  ///
  /// In es, this message translates to:
  /// **'Error al procesar la aprobación'**
  String get approvalError;

  /// Mensaje cuando no hay anteproyectos pendientes de revisión
  ///
  /// In es, this message translates to:
  /// **'No hay anteproyectos para revisar'**
  String get noAnteprojectsToReview;

  /// Mensaje cuando no hay anteproyectos ya revisados
  ///
  /// In es, this message translates to:
  /// **'No hay anteproyectos revisados'**
  String get noReviewedAnteprojects;

  /// Fecha de envío del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Enviado el'**
  String get submittedOn;

  /// Fecha de revisión del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Revisado el'**
  String get reviewedOn;

  /// Comentarios dejados por el tutor
  ///
  /// In es, this message translates to:
  /// **'Comentarios del Tutor'**
  String get tutorComments;

  /// Estado actual del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Estado del Anteproyecto'**
  String get anteprojectStatus;

  /// Acción para ver detalles de un elemento
  ///
  /// In es, this message translates to:
  /// **'Ver detalles'**
  String get viewDetails;

  /// Mensaje de procesamiento en curso
  ///
  /// In es, this message translates to:
  /// **'Procesando...'**
  String get processing;

  /// Mensaje de validación cuando los comentarios son requeridos
  ///
  /// In es, this message translates to:
  /// **'Los comentarios son obligatorios'**
  String get commentsRequired;

  /// Acción de aprobar
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get approve;

  /// Acción de rechazar
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get reject;

  /// Acción de actualizar o refrescar
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get refresh;

  /// Botón para reintentar una operación
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// Año académico del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Año Académico'**
  String get academicYear;

  /// Descripción cuando no hay datos para mostrar
  ///
  /// In es, this message translates to:
  /// **'No hay información para mostrar en este momento'**
  String get noDataDescription;

  /// Botón para subir un archivo
  ///
  /// In es, this message translates to:
  /// **'Subir Archivo'**
  String get uploadFile;

  /// Texto mostrado mientras se sube un archivo
  ///
  /// In es, this message translates to:
  /// **'Subiendo...'**
  String get uploading;

  /// Botón de acción para subir
  ///
  /// In es, this message translates to:
  /// **'Subir'**
  String get upload;

  /// Mensaje de éxito al subir archivo
  ///
  /// In es, this message translates to:
  /// **'Archivo subido correctamente'**
  String get fileUploadedSuccessfully;

  /// Mensaje de éxito al eliminar archivo
  ///
  /// In es, this message translates to:
  /// **'Archivo eliminado correctamente'**
  String get fileDeletedSuccessfully;

  /// Título del diálogo de confirmación para eliminar archivo
  ///
  /// In es, this message translates to:
  /// **'Confirmar Eliminación'**
  String get confirmDeleteFile;

  /// Mensaje de confirmación para eliminar archivo
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar el archivo {fileName}?'**
  String confirmDeleteFileMessage(String fileName);

  /// Tooltip para abrir archivo
  ///
  /// In es, this message translates to:
  /// **'Abrir Archivo'**
  String get openFile;

  /// Tooltip para eliminar archivo
  ///
  /// In es, this message translates to:
  /// **'Eliminar Archivo'**
  String get deleteFile;

  /// Mensaje cuando no hay archivos adjuntos
  ///
  /// In es, this message translates to:
  /// **'No hay archivos adjuntos'**
  String get noFilesAttached;

  /// Mensaje cuando no hay archivos todavía
  ///
  /// In es, this message translates to:
  /// **'Aún no hay archivos'**
  String get noFilesYet;

  /// Etiqueta para mostrar quién subió el archivo
  ///
  /// In es, this message translates to:
  /// **'Subido por'**
  String get uploadedBy;

  /// Instrucción para seleccionar archivo
  ///
  /// In es, this message translates to:
  /// **'Haz clic para seleccionar un archivo'**
  String get clickToSelectFile;

  /// Lista de tipos de archivo permitidos
  ///
  /// In es, this message translates to:
  /// **'Tipos permitidos: PDF, Word, TXT, Imágenes (JPG, PNG, GIF), ZIP, RAR'**
  String get allowedFileTypes;

  /// Tamaño máximo permitido para archivos
  ///
  /// In es, this message translates to:
  /// **'Tamaño máximo: {size}'**
  String maxFileSize(String size);

  /// Título de la sección de archivos adjuntos
  ///
  /// In es, this message translates to:
  /// **'Archivos Adjuntos'**
  String get filesAttached;

  /// Botón para adjuntar un archivo
  ///
  /// In es, this message translates to:
  /// **'Adjuntar Archivo'**
  String get attachFile;

  /// Título de la pantalla de detalles de tarea
  ///
  /// In es, this message translates to:
  /// **'Detalles de la Tarea'**
  String get taskDetails;

  /// Pestaña de detalles
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get details;

  /// Rol de tutor
  ///
  /// In es, this message translates to:
  /// **'Tutor'**
  String get tutorRole;

  /// Título de sección para elementos revisados
  ///
  /// In es, this message translates to:
  /// **'Revisados'**
  String get reviewed;

  /// Botón para añadir estudiantes
  ///
  /// In es, this message translates to:
  /// **'Añadir Estudiantes'**
  String get addStudents;

  /// Información de estudiantes asignados
  ///
  /// In es, this message translates to:
  /// **'Tienes {count} estudiante{plural} asignado{plural} para {year}'**
  String studentsAssignedInfo(int count, String plural, String year);

  /// Título de la pantalla de lista de estudiantes del tutor
  ///
  /// In es, this message translates to:
  /// **'Mis Estudiantes'**
  String get myStudents;

  /// Placeholder para buscar estudiantes
  ///
  /// In es, this message translates to:
  /// **'Buscar estudiantes...'**
  String get searchStudents;

  /// Mensaje cuando no hay estudiantes asignados
  ///
  /// In es, this message translates to:
  /// **'No tienes estudiantes asignados'**
  String get noStudentsAssigned;

  /// Mensaje cuando no se encuentran estudiantes en la búsqueda
  ///
  /// In es, this message translates to:
  /// **'No se encontraron estudiantes'**
  String get noStudentsFound;

  /// Instrucción para añadir estudiantes desde el dashboard
  ///
  /// In es, this message translates to:
  /// **'Usa los botones del dashboard para añadir estudiantes'**
  String get useDashboardButtons;

  /// Acción para editar estudiante
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get editStudent;

  /// Acción para eliminar estudiante
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get deleteStudent;

  /// Etiqueta para NRE del estudiante
  ///
  /// In es, this message translates to:
  /// **'NRE'**
  String get nre;

  /// Etiqueta para teléfono
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phone;

  /// Etiqueta para especialidad
  ///
  /// In es, this message translates to:
  /// **'Especialidad'**
  String get specialty;

  /// Etiqueta para biografía
  ///
  /// In es, this message translates to:
  /// **'Biografía'**
  String get biography;

  /// Etiqueta para fecha de creación
  ///
  /// In es, this message translates to:
  /// **'Fecha de creación'**
  String get creationDate;

  /// Mensaje de éxito al eliminar estudiante
  ///
  /// In es, this message translates to:
  /// **'Estudiante eliminado exitosamente'**
  String get studentDeletedSuccess;

  /// Mensaje de error al eliminar estudiante
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar estudiante: {error}'**
  String errorDeletingStudent(String error);

  /// Título del diálogo de confirmación de eliminación
  ///
  /// In es, this message translates to:
  /// **'Confirmar eliminación'**
  String get confirmDeletion;

  /// Mensaje de confirmación para eliminar estudiante
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar a {name}?'**
  String confirmDeleteStudent(String name);

  /// Título de la pantalla de revisión de anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Revisión de Anteproyectos'**
  String get anteprojectsReview;

  /// Título para anteproyectos pendientes
  ///
  /// In es, this message translates to:
  /// **'Anteproyectos Pendientes'**
  String get pendingAnteprojectsTitle;

  /// Título para anteproyectos revisados
  ///
  /// In es, this message translates to:
  /// **'Anteproyectos Revisados'**
  String get reviewedAnteprojectsTitle;

  /// Título para anteproyectos enviados
  ///
  /// In es, this message translates to:
  /// **'Anteproyectos Enviados'**
  String get submittedAnteprojects;

  /// Título para anteproyectos en revisión
  ///
  /// In es, this message translates to:
  /// **'Anteproyectos En Revisión'**
  String get underReviewAnteprojects;

  /// Título para anteproyectos aprobados
  ///
  /// In es, this message translates to:
  /// **'Anteproyectos Aprobados'**
  String get approvedAnteprojects;

  /// Título para anteproyectos rechazados
  ///
  /// In es, this message translates to:
  /// **'Anteproyectos Rechazados'**
  String get rejectedAnteprojects;

  /// Filtro para mostrar todos los elementos
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get all;

  /// Placeholder para buscar anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Buscar anteproyectos...'**
  String get searchAnteprojects;

  /// Etiqueta para filtro por estado
  ///
  /// In es, this message translates to:
  /// **'Filtrar por estado:'**
  String get filterByStatus;

  /// Mensaje de error al cargar anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Error al cargar anteproyectos: {error}'**
  String errorLoadingAnteprojects(String error);

  /// Mensaje cuando no se encuentran anteproyectos en la búsqueda
  ///
  /// In es, this message translates to:
  /// **'No se encontraron anteproyectos que coincidan con \"{query}\"'**
  String noAnteprojectsFound(String query);

  /// Mensaje cuando no hay anteproyectos con un estado específico
  ///
  /// In es, this message translates to:
  /// **'No hay anteproyectos con estado \"{status}\"'**
  String noAnteprojectsWithStatus(String status);

  /// Mensaje cuando no hay anteproyectos asignados
  ///
  /// In es, this message translates to:
  /// **'No tienes anteproyectos asignados para revisar'**
  String get noAssignedAnteprojects;

  /// Botón para limpiar filtros
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get clearFilters;

  /// Etiqueta para año académico
  ///
  /// In es, this message translates to:
  /// **'Año:'**
  String get year;

  /// Etiqueta para fecha de creación
  ///
  /// In es, this message translates to:
  /// **'Creado:'**
  String get created;

  /// Etiqueta para fecha de envío
  ///
  /// In es, this message translates to:
  /// **'Enviado:'**
  String get submitted;

  /// Botón para ver comentarios
  ///
  /// In es, this message translates to:
  /// **'Comentarios'**
  String get comments;

  /// Título del diálogo de aprobación
  ///
  /// In es, this message translates to:
  /// **'Aprobar Anteproyecto'**
  String get approveAnteprojectTitle;

  /// Título del diálogo de rechazo
  ///
  /// In es, this message translates to:
  /// **'Rechazar Anteproyecto'**
  String get rejectAnteprojectTitle;

  /// Mensaje de confirmación para aprobar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres aprobar este anteproyecto?'**
  String get confirmApproveAnteproject;

  /// Mensaje de confirmación para rechazar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres rechazar este anteproyecto?'**
  String get confirmRejectAnteproject;

  /// Etiqueta para comentarios de aprobación opcionales
  ///
  /// In es, this message translates to:
  /// **'Comentarios (opcional)'**
  String get approvalCommentsOptional;

  /// Mensaje de éxito al aprobar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto aprobado exitosamente'**
  String get anteprojectApprovedSuccess;

  /// Mensaje de éxito al rechazar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto rechazado'**
  String get anteprojectRejectedSuccess;

  /// Mensaje de error al aprobar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Error al aprobar anteproyecto: {error}'**
  String errorApprovingAnteproject(String error);

  /// Mensaje de error al rechazar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Error al rechazar anteproyecto: {error}'**
  String errorRejectingAnteproject(String error);

  /// Estado pendiente
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pending;

  /// Estado en revisión
  ///
  /// In es, this message translates to:
  /// **'En Revisión'**
  String get underReview;

  /// Estado aprobado
  ///
  /// In es, this message translates to:
  /// **'Aprobado'**
  String get approved;

  /// Estado rechazado
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get rejected;

  /// Etiqueta para estado
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get status;

  /// Etiqueta para el campo de título del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Título del Anteproyecto'**
  String get anteprojectTitleLabel;

  /// Tooltip para el botón de cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logoutTooltip;

  /// Tooltip para el botón de crear anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Crear anteproyecto'**
  String get createAnteprojectTooltip;

  /// Etiqueta para ID de usuario
  ///
  /// In es, this message translates to:
  /// **'ID: {id}'**
  String userId(String id);

  /// Rol de estudiante
  ///
  /// In es, this message translates to:
  /// **'Estudiante'**
  String get studentRole;

  /// Título de sección de anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Anteproyectos'**
  String get anteprojects;

  /// Título de sección de tareas completadas
  ///
  /// In es, this message translates to:
  /// **'Completadas'**
  String get completed;

  /// Mensaje cuando el anteproyecto es aprobado
  ///
  /// In es, this message translates to:
  /// **'Tu anteproyecto ha sido aprobado. ¡Puedes comenzar con el desarrollo!'**
  String get anteprojectApprovedMessage;

  /// Etiqueta para año académico
  ///
  /// In es, this message translates to:
  /// **'Año: {year}'**
  String academicYearLabel(String year);

  /// Etiqueta para estado
  ///
  /// In es, this message translates to:
  /// **'Estado: {status}'**
  String statusLabel(String status);

  /// Estado borrador
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get draft;

  /// Estado aprobado
  ///
  /// In es, this message translates to:
  /// **'Aprobado'**
  String get approvedStatus;

  /// Estado rechazado
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get rejectedStatus;

  /// Estado desconocido
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get unknown;

  /// Estado en progreso
  ///
  /// In es, this message translates to:
  /// **'En Progreso'**
  String get inProgress;

  /// Estado completada
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get completedStatus;

  /// Estado desconocido
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get unknownStatus;

  /// Mensaje de éxito al crear estudiante
  ///
  /// In es, this message translates to:
  /// **'Estudiante creado exitosamente'**
  String get studentCreatedSuccess;

  /// Mensaje de error al crear estudiante
  ///
  /// In es, this message translates to:
  /// **'Error al crear estudiante: {error}'**
  String errorCreatingStudent(String error);

  /// Título del formulario de añadir estudiante
  ///
  /// In es, this message translates to:
  /// **'Añadir Estudiante'**
  String get addStudent;

  /// Etiqueta para nombre completo
  ///
  /// In es, this message translates to:
  /// **'Nombre Completo'**
  String get fullName;

  /// Etiqueta para NRE
  ///
  /// In es, this message translates to:
  /// **'NRE (Número de Registro de Estudiante)'**
  String get nreLabel;

  /// Etiqueta para teléfono opcional
  ///
  /// In es, this message translates to:
  /// **'Teléfono (Opcional)'**
  String get phoneOptional;

  /// Etiqueta para biografía opcional
  ///
  /// In es, this message translates to:
  /// **'Biografía (Opcional)'**
  String get biographyOptional;

  /// Mensaje de validación para nombre requerido
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get nameRequired;

  /// Mensaje de validación para email requerido
  ///
  /// In es, this message translates to:
  /// **'El email es obligatorio'**
  String get emailRequired;

  /// Mensaje de validación para email inválido
  ///
  /// In es, this message translates to:
  /// **'Email inválido'**
  String get emailInvalid;

  /// Mensaje de validación para NRE requerido
  ///
  /// In es, this message translates to:
  /// **'El NRE es obligatorio'**
  String get nreRequired;

  /// Botón para crear estudiante
  ///
  /// In es, this message translates to:
  /// **'Crear Estudiante'**
  String get createStudent;

  /// Mensaje de éxito al actualizar estudiante
  ///
  /// In es, this message translates to:
  /// **'Estudiante actualizado exitosamente'**
  String get studentUpdatedSuccess;

  /// Mensaje de error al actualizar estudiante
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar estudiante: {error}'**
  String errorUpdatingStudent(String error);

  /// Botón para actualizar estudiante
  ///
  /// In es, this message translates to:
  /// **'Actualizar Estudiante'**
  String get updateStudent;

  /// Etiqueta para rol
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get role;

  /// Mensaje cuando no hay proyecto asignado
  ///
  /// In es, this message translates to:
  /// **'No tienes un proyecto o anteproyecto asignado. Contacta con tu tutor.'**
  String get noProjectAssigned;

  /// Mensaje de error al obtener proyecto
  ///
  /// In es, this message translates to:
  /// **'Error al obtener proyecto: {error}'**
  String errorGettingProject(String error);

  /// Título del diálogo de eliminación de anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Eliminar Anteproyecto'**
  String get deleteAnteproject;

  /// Mensaje de confirmación para eliminar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar el anteproyecto \"{title}\"?\n\nEsta acción no se puede deshacer.'**
  String confirmDeleteAnteproject(String title);

  /// Mensaje de éxito al eliminar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto eliminado exitosamente'**
  String get anteprojectDeletedSuccess;

  /// Mensaje de error al eliminar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar anteproyecto: {error}'**
  String errorDeletingAnteproject(String error);

  /// Mensaje de éxito al cargar plantilla
  ///
  /// In es, this message translates to:
  /// **'✅ Plantilla cargada correctamente. Los 4 hitos de ejemplo han sido añadidos.'**
  String get templateLoadedSuccess;

  /// Mensaje de error al generar PDF
  ///
  /// In es, this message translates to:
  /// **'Error al generar PDF: {error}'**
  String errorGeneratingPDF(String error);

  /// Título del diálogo de descarga de ejemplo
  ///
  /// In es, this message translates to:
  /// **'Descargar Ejemplo de Anteproyecto'**
  String get downloadExampleTitle;

  /// Mensaje del diálogo de descarga de ejemplo
  ///
  /// In es, this message translates to:
  /// **'¿Cómo deseas descargar el ejemplo de anteproyecto?'**
  String get downloadExampleMessage;

  /// Botón para imprimir
  ///
  /// In es, this message translates to:
  /// **'Imprimir'**
  String get print;

  /// Mensaje de éxito al guardar PDF
  ///
  /// In es, this message translates to:
  /// **'PDF guardado en: {path}'**
  String pdfSavedAt(String path);

  /// Mensaje de error al guardar
  ///
  /// In es, this message translates to:
  /// **'Error al guardar: {error}'**
  String errorSaving(String error);

  /// Botón para descargar ejemplo PDF
  ///
  /// In es, this message translates to:
  /// **'Descargar Ejemplo PDF'**
  String get downloadExamplePDF;

  /// Botón para cargar plantilla
  ///
  /// In es, this message translates to:
  /// **'Cargar Plantilla'**
  String get loadTemplate;

  /// Mensaje de error al cargar cronograma
  ///
  /// In es, this message translates to:
  /// **'Error al cargar cronograma: {error}'**
  String errorLoadingSchedule(String error);

  /// Mensaje de validación para fecha de revisión
  ///
  /// In es, this message translates to:
  /// **'Debe configurar al menos una fecha de revisión'**
  String get mustConfigureReviewDate;

  /// Mensaje de éxito al guardar cronograma
  ///
  /// In es, this message translates to:
  /// **'Cronograma guardado exitosamente'**
  String get scheduleSavedSuccess;

  /// Mensaje de error al guardar cronograma
  ///
  /// In es, this message translates to:
  /// **'Error al guardar cronograma: {error}'**
  String errorSavingSchedule(String error);

  /// Título de gestión de cronograma
  ///
  /// In es, this message translates to:
  /// **'Gestión de Cronograma'**
  String get scheduleManagement;

  /// Botón para regenerar fechas
  ///
  /// In es, this message translates to:
  /// **'Regenerar Fechas Basadas en Hitos'**
  String get regenerateDatesBasedOnMilestones;

  /// Título de detalles del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Detalles del Anteproyecto'**
  String get anteprojectDetails;

  /// Botón para editar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Editar Anteproyecto'**
  String get editAnteproject;

  /// Mensaje de anteproyecto rechazado
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto rechazado'**
  String get anteprojectRejected;

  /// Botón para enviar para aprobación
  ///
  /// In es, this message translates to:
  /// **'Enviar para Aprobación'**
  String get sendForApproval;

  /// Título del diálogo de envío para aprobación
  ///
  /// In es, this message translates to:
  /// **'Enviar para Aprobación'**
  String get sendForApprovalTitle;

  /// Mensaje de confirmación para envío
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres enviar este anteproyecto para aprobación? Una vez enviado, no podrás editarlo hasta que sea revisado.'**
  String get sendForApprovalMessage;

  /// Botón para enviar
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get send;

  /// Mensaje de éxito al enviar para aprobación
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto enviado para aprobación exitosamente'**
  String get anteprojectSentForApproval;

  /// Mensaje de error al enviar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Error al enviar anteproyecto: {error}'**
  String errorSendingAnteproject(String error);

  /// Título del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto: {title}'**
  String anteprojectTitle(String title);

  /// Mensaje de error al cargar comentarios
  ///
  /// In es, this message translates to:
  /// **'Error al cargar comentarios: {error}'**
  String errorLoadingComments(String error);

  /// Mensaje de validación para comentario
  ///
  /// In es, this message translates to:
  /// **'Por favor, escribe un comentario'**
  String get pleaseWriteComment;

  /// Mensaje de éxito al agregar comentario
  ///
  /// In es, this message translates to:
  /// **'Comentario agregado exitosamente'**
  String get commentAddedSuccess;

  /// Mensaje de error al agregar comentario
  ///
  /// In es, this message translates to:
  /// **'Error al agregar comentario: {error}'**
  String errorAddingComment(String error);

  /// Título de comentarios
  ///
  /// In es, this message translates to:
  /// **'Comentarios - {title}'**
  String commentsTitle(String title);

  /// Mensaje de copiado
  ///
  /// In es, this message translates to:
  /// **'Copiado: {text}'**
  String copied(String text);

  /// Botón para añadir individualmente
  ///
  /// In es, this message translates to:
  /// **'Añadir Individualmente'**
  String get addIndividually;

  /// Botón para importar desde CSV
  ///
  /// In es, this message translates to:
  /// **'Importar desde CSV'**
  String get importFromCSV;

  /// Mensaje de error al cargar notificaciones
  ///
  /// In es, this message translates to:
  /// **'Error al cargar notificaciones: {error}'**
  String errorLoadingNotifications(String error);

  /// Mensaje de error al marcar como leída
  ///
  /// In es, this message translates to:
  /// **'Error al marcar como leída: {error}'**
  String errorMarkingAsRead(String error);

  /// Mensaje de éxito al marcar todas como leídas
  ///
  /// In es, this message translates to:
  /// **'Todas las notificaciones marcadas como leídas'**
  String get allNotificationsMarkedAsRead;

  /// Mensaje de error al marcar todas como leídas
  ///
  /// In es, this message translates to:
  /// **'Error al marcar todas como leídas: {error}'**
  String errorMarkingAllAsRead(String error);

  /// Mensaje de error al eliminar notificación
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar notificación: {error}'**
  String errorDeletingNotification(String error);

  /// Título de notificaciones
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// Mensaje de error al cargar estudiantes
  ///
  /// In es, this message translates to:
  /// **'Error al cargar estudiantes: {error}'**
  String errorLoadingStudents(String error);

  /// Título del dashboard
  ///
  /// In es, this message translates to:
  /// **'Dashboard - {name}'**
  String dashboardTitle(String name);

  /// Opción para todos los años
  ///
  /// In es, this message translates to:
  /// **'Todos los años'**
  String get allYears;

  /// Mensaje de error al seleccionar archivo
  ///
  /// In es, this message translates to:
  /// **'Error al seleccionar archivo: {error}'**
  String errorSelectingFile(String error);

  /// Mensaje cuando no hay datos válidos
  ///
  /// In es, this message translates to:
  /// **'No hay datos válidos para importar'**
  String get noValidDataToImport;

  /// Mensaje de importación completada
  ///
  /// In es, this message translates to:
  /// **'Importación completada: {success} exitosos, {error} errores'**
  String importCompleted(int success, int error);

  /// Mensaje de error durante importación
  ///
  /// In es, this message translates to:
  /// **'Error durante la importación: {error}'**
  String errorDuringImport(String error);

  /// Título de importar estudiantes CSV
  ///
  /// In es, this message translates to:
  /// **'Importar Estudiantes CSV'**
  String get importStudentsCSV;

  /// Campo obligatorio full_name
  ///
  /// In es, this message translates to:
  /// **'• full_name (obligatorio)'**
  String get fullNameRequired;

  /// Campo opcional specialty
  ///
  /// In es, this message translates to:
  /// **'• specialty (opcional)'**
  String get specialtyOptional;

  /// Campo opcional academic_year
  ///
  /// In es, this message translates to:
  /// **'• academic_year (opcional)'**
  String get academicYearOptional;

  /// Botón para seleccionar archivo CSV
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Archivo CSV'**
  String get selectCSVFile;

  /// Botón para importar estudiantes
  ///
  /// In es, this message translates to:
  /// **'Importar {count} Estudiantes'**
  String importStudents(int count);

  /// Mensaje de importación en progreso
  ///
  /// In es, this message translates to:
  /// **'Importando...'**
  String get importing;

  /// Mensaje de éxito al importar estudiantes
  ///
  /// In es, this message translates to:
  /// **'Estudiantes importados exitosamente'**
  String get studentsImportedSuccess;

  /// Mensaje de creación en progreso
  ///
  /// In es, this message translates to:
  /// **'Creando...'**
  String get creating;

  /// Botón para crear tutor
  ///
  /// In es, this message translates to:
  /// **'Crear Tutor'**
  String get createTutor;

  /// Mensaje de éxito al crear tutor
  ///
  /// In es, this message translates to:
  /// **'Tutor creado exitosamente'**
  String get tutorCreatedSuccess;

  /// Mensaje de error al subir archivo
  ///
  /// In es, this message translates to:
  /// **'Error al subir archivo: {error}'**
  String errorUploadingFile(String error);

  /// Mensaje de error al cargar archivos
  ///
  /// In es, this message translates to:
  /// **'Error al cargar archivos: {error}'**
  String errorLoadingFiles(String error);

  /// Mensaje de error al eliminar archivo
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar archivo: {error}'**
  String errorDeletingFile(String error);

  /// Mensaje de error al abrir archivo
  ///
  /// In es, this message translates to:
  /// **'Error al abrir archivo: {error}'**
  String errorOpeningFile(String error);

  /// Horas estimadas
  ///
  /// In es, this message translates to:
  /// **'{hours}h'**
  String estimatedHours(int hours);

  /// Mensaje de confirmación para eliminar tarea
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar la tarea \"{title}\"?'**
  String confirmDeleteTask(String title);

  /// Mensaje para iniciar sesión
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión para ver los comentarios'**
  String get mustLoginToViewComments;

  /// Título del diálogo de permisos
  ///
  /// In es, this message translates to:
  /// **'Permisos Requeridos'**
  String get permissionRequired;

  /// Mensaje explicativo sobre por qué se necesitan los permisos
  ///
  /// In es, this message translates to:
  /// **'Esta aplicación necesita acceso al almacenamiento para seleccionar archivos. Por favor, concede los permisos necesarios.'**
  String get permissionRequiredMessage;

  /// Botón para abrir la configuración de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Abrir Configuración'**
  String get openSettings;

  /// Botón para intentar solicitar permisos nuevamente
  ///
  /// In es, this message translates to:
  /// **'Intentar de Nuevo'**
  String get tryAgain;

  /// Mensaje de éxito al guardar archivo
  ///
  /// In es, this message translates to:
  /// **'Archivo guardado con éxito'**
  String get fileSavedSuccessfully;

  /// Mensaje de error al imprimir
  ///
  /// In es, this message translates to:
  /// **'Error al imprimir: {error}'**
  String errorPrinting(String error);

  /// Título del diálogo para elegir proyecto para trabajar con tareas
  ///
  /// In es, this message translates to:
  /// **'Selecciona el proyecto'**
  String get selectProjectForTasks;

  /// Título de la pantalla de detalles del proyecto
  ///
  /// In es, this message translates to:
  /// **'Detalles del Proyecto'**
  String get projectDetails;

  /// Sección de comentarios históricos del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Comentarios del Anteproyecto (Histórico)'**
  String get anteprojectHistoryComments;

  /// Sección de comentarios actuales del proyecto
  ///
  /// In es, this message translates to:
  /// **'Comentarios del Proyecto'**
  String get projectComments;

  /// Pestaña de archivos adjuntos
  ///
  /// In es, this message translates to:
  /// **'Archivos Adjuntos'**
  String get attachedFiles;

  /// Pestaña del tablero Kanban
  ///
  /// In es, this message translates to:
  /// **'Tablero Kanban'**
  String get kanbanBoard;

  /// Mensaje cuando se intenta ver el Kanban sin proyecto
  ///
  /// In es, this message translates to:
  /// **'El tablero Kanban solo está disponible para proyectos aprobados'**
  String get kanbanOnlyForProjects;

  /// Error cuando no existe el anteproyecto del proyecto
  ///
  /// In es, this message translates to:
  /// **'No se encontró el anteproyecto asociado al proyecto'**
  String get anteprojectNotFound;

  /// Pestaña de lista de tareas
  ///
  /// In es, this message translates to:
  /// **'Lista de Tareas'**
  String get tasksList;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
