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

  /// Campo título del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get anteprojectTitle;

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

  /// Campo estado del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get anteprojectStatus;

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

  /// Mensaje temporal para lista de tareas en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Lista de tareas en desarrollo'**
  String get tasksListDev;

  /// Mensaje temporal para dashboard de admin en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Dashboard de admin en desarrollo'**
  String get adminDashboardDev;

  /// Sección de gestión de usuarios en dashboard de admin
  ///
  /// In es, this message translates to:
  /// **'Gestión de Usuarios'**
  String get dashboardAdminUsersManagement;

  /// Mensaje temporal para dashboard de tutor en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Dashboard de tutor en desarrollo'**
  String get tutorDashboardDev;

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

  /// Mensaje de confirmación de copiado
  ///
  /// In es, this message translates to:
  /// **'¡Copiado!'**
  String get copied;

  /// Botón para ver detalles
  ///
  /// In es, this message translates to:
  /// **'Ver detalles'**
  String get viewDetails;

  /// Mensaje de funcionalidad en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Lista de anteproyectos en desarrollo'**
  String get anteprojectsListInDevelopment;

  /// Mensaje de funcionalidad en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Lista de estudiantes en desarrollo'**
  String get studentsListInDevelopment;

  /// Mensaje de funcionalidad en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Panel de gestión de usuarios en desarrollo'**
  String get userManagementInDevelopment;

  /// Mensaje de funcionalidad en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Estado detallado del sistema en desarrollo'**
  String get systemStatusInDevelopment;

  /// Mensaje de funcionalidad en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Lista de usuarios en desarrollo'**
  String get usersListInDevelopment;

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

  /// Botón para reintentar una operación
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// Botón para cerrar
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

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

  /// Texto para seleccionar fecha
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha'**
  String get selectDate;
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
