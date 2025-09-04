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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Título principal de la aplicación
  ///
  /// In en, this message translates to:
  /// **'TFG Management System'**
  String get appTitle;

  /// Botón o acción de iniciar sesión
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Campo de email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Campo de contraseña
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Mensaje de error al fallar el login
  ///
  /// In en, this message translates to:
  /// **'Login error. Please verify your credentials.'**
  String get loginError;

  /// Pantalla principal del usuario
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Sección de proyectos
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// Sección de tareas
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Sección de perfil de usuario
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Acción de cerrar sesión
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Rol de estudiante
  ///
  /// In en, this message translates to:
  /// **'Estudiante'**
  String get student;

  /// Rol de tutor
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get tutor;

  /// Rol de administrador
  ///
  /// In en, this message translates to:
  /// **'Administrador'**
  String get admin;

  /// Mensaje de bienvenida
  ///
  /// In en, this message translates to:
  /// **'Bienvenido'**
  String get welcome;

  /// Mensaje de carga
  ///
  /// In en, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// Mensaje de error genérico
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Mensaje de éxito genérico
  ///
  /// In en, this message translates to:
  /// **'Éxito'**
  String get success;

  /// Botón de cancelar
  ///
  /// In en, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Botón de guardar
  ///
  /// In en, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Botón de editar
  ///
  /// In en, this message translates to:
  /// **'Editar'**
  String get edit;

  /// Mensaje de éxito al crear tarea
  ///
  /// In en, this message translates to:
  /// **'Tarea creada exitosamente'**
  String get taskCreatedSuccess;

  /// Mensaje de éxito al actualizar tarea
  ///
  /// In en, this message translates to:
  /// **'Tarea actualizada exitosamente'**
  String get taskUpdatedSuccess;

  /// Mensaje de éxito al actualizar estado de tarea
  ///
  /// In en, this message translates to:
  /// **'Estado de tarea actualizado'**
  String get taskStatusUpdatedSuccess;

  /// Mensaje de éxito al eliminar tarea
  ///
  /// In en, this message translates to:
  /// **'Tarea eliminada exitosamente'**
  String get taskDeletedSuccess;

  /// Mensaje de error cuando no se encuentra la tarea
  ///
  /// In en, this message translates to:
  /// **'Tarea no encontrada'**
  String get taskNotFound;

  /// Botón de eliminar
  ///
  /// In en, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// Botón de crear
  ///
  /// In en, this message translates to:
  /// **'Crear'**
  String get create;

  /// Campo o acción de búsqueda
  ///
  /// In en, this message translates to:
  /// **'Buscar'**
  String get search;

  /// Mensaje cuando no hay datos
  ///
  /// In en, this message translates to:
  /// **'No hay datos disponibles'**
  String get noData;

  /// Mensaje de error de conexión
  ///
  /// In en, this message translates to:
  /// **'Error de conexión. Por favor, verifica tu conexión a internet.'**
  String get connectionError;

  /// Título del formulario de creación de anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Create Anteproject'**
  String get anteprojectFormTitle;

  /// Título del formulario de edición de anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Edit Anteproject'**
  String get anteprojectEditFormTitle;

  /// Campo título del anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get anteprojectTitle;

  /// Campo tipo de proyecto del anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Project Type'**
  String get anteprojectType;

  /// Campo descripción del anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get anteprojectDescription;

  /// Campo año académico del anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Año académico (e.g., 2024-2025)'**
  String get anteprojectAcademicYear;

  /// Campo resultados esperados del anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Resultados esperados (JSON)'**
  String get anteprojectExpectedResults;

  /// Campo temporalización del anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Temporalización (JSON)'**
  String get anteprojectTimeline;

  /// Campo ID del tutor del anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Tutor ID'**
  String get anteprojectTutorId;

  /// Campo estado del anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get anteprojectStatus;

  /// Botón para crear anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Create Anteproject'**
  String get anteprojectCreateButton;

  /// Botón para actualizar anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Update Anteproject'**
  String get anteprojectUpdateButton;

  /// Botón para eliminar anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get anteprojectDeleteButton;

  /// Título del diálogo de eliminación de anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Eliminar Anteproyecto'**
  String get anteprojectDeleteTitle;

  /// Mensaje del diálogo de eliminación de anteproyecto
  ///
  /// In en, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar este anteproyecto? Esta acción no se puede deshacer.'**
  String get anteprojectDeleteMessage;

  /// Mensaje de éxito al crear anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Anteproyecto creado exitosamente'**
  String get anteprojectCreatedSuccess;

  /// Mensaje de éxito al actualizar anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Anteproyecto actualizado exitosamente'**
  String get anteprojectUpdatedSuccess;

  /// Mensaje de error para ID de tutor inválido
  ///
  /// In en, this message translates to:
  /// **'Tutor ID inválido'**
  String get anteprojectInvalidTutorId;

  /// Mensaje de validación para título requerido
  ///
  /// In en, this message translates to:
  /// **'El título es obligatorio'**
  String get anteprojectTitleRequired;

  /// Mensaje de validación para descripción requerida
  ///
  /// In en, this message translates to:
  /// **'La descripción es obligatoria'**
  String get anteprojectDescriptionRequired;

  /// Mensaje de validación para año académico requerido
  ///
  /// In en, this message translates to:
  /// **'El año académico es obligatorio'**
  String get anteprojectAcademicYearRequired;

  /// Mensaje de validación para ID de tutor requerido
  ///
  /// In en, this message translates to:
  /// **'El Tutor ID es obligatorio'**
  String get anteprojectTutorIdRequired;

  /// Mensaje de validación para ID de tutor numérico
  ///
  /// In en, this message translates to:
  /// **'El Tutor ID debe ser numérico'**
  String get anteprojectTutorIdNumeric;

  /// Título de la lista de anteproyectos
  ///
  /// In en, this message translates to:
  /// **'My Anteprojects'**
  String get anteprojectsListTitle;

  /// Botón para actualizar la lista de anteproyectos
  ///
  /// In en, this message translates to:
  /// **'Actualizar lista'**
  String get anteprojectsListRefresh;

  /// Mensaje de error al cargar la lista de anteproyectos
  ///
  /// In en, this message translates to:
  /// **'Error al cargar anteproyectos'**
  String get anteprojectsListError;

  /// Botón para reintentar cargar la lista
  ///
  /// In en, this message translates to:
  /// **'Reintentar'**
  String get anteprojectsListRetry;

  /// Mensaje cuando la lista de anteproyectos está vacía
  ///
  /// In en, this message translates to:
  /// **'No tienes anteproyectos'**
  String get anteprojectsListEmpty;

  /// Subtítulo cuando la lista de anteproyectos está vacía
  ///
  /// In en, this message translates to:
  /// **'Crea tu primer anteproyecto para comenzar'**
  String get anteprojectsListEmptySubtitle;

  /// Mensaje para estado desconocido en la lista
  ///
  /// In en, this message translates to:
  /// **'Estado no reconocido'**
  String get anteprojectsListUnknownState;

  /// Botón para editar en la lista de anteproyectos
  ///
  /// In en, this message translates to:
  /// **'Editar'**
  String get anteprojectsListEdit;

  /// Tooltip para el botón de eliminar anteproyecto
  ///
  /// In en, this message translates to:
  /// **'Eliminar anteproyecto'**
  String get anteprojectDeleteTooltip;

  /// Etiqueta de estado con valor
  ///
  /// In en, this message translates to:
  /// **'Estado: {status}'**
  String anteprojectStatusLabel(String status);

  /// Hint para el campo de resultados esperados
  ///
  /// In en, this message translates to:
  /// **'Ejemplo milestone1 Descripción'**
  String get anteprojectExpectedResultsHint;

  /// Hint para el campo de temporalización
  ///
  /// In en, this message translates to:
  /// **'Ejemplo phase1 Descripción'**
  String get anteprojectTimelineHint;

  /// Título del dashboard de estudiante
  ///
  /// In en, this message translates to:
  /// **'Dashboard Estudiante'**
  String get dashboardStudent;

  /// Sección de anteproyectos del usuario
  ///
  /// In en, this message translates to:
  /// **'Mis Anteproyectos'**
  String get myAnteprojects;

  /// Button to view all items
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// Mensaje cuando no hay anteproyectos
  ///
  /// In en, this message translates to:
  /// **'No tienes anteproyectos creados. ¡Crea tu primer anteproyecto!'**
  String get noAnteprojects;

  /// Sección de tareas pendientes
  ///
  /// In en, this message translates to:
  /// **'Tareas Pendientes'**
  String get pendingTasks;

  /// Enlace para ver todas las tareas
  ///
  /// In en, this message translates to:
  /// **'Ver todas'**
  String get viewAllTasks;

  /// Mensaje cuando no hay tareas pendientes
  ///
  /// In en, this message translates to:
  /// **'No tienes tareas pendientes. ¡Excelente trabajo!'**
  String get noPendingTasks;

  /// Sección de información del sistema
  ///
  /// In en, this message translates to:
  /// **'Información del Sistema'**
  String get systemInfo;

  /// Etiqueta de backend con URL
  ///
  /// In en, this message translates to:
  /// **'Backend: {url}'**
  String backendLabel(String url);

  /// Etiqueta de plataforma con valor
  ///
  /// In en, this message translates to:
  /// **'Plataforma: {platform}'**
  String platformLabel(String platform);

  /// Etiqueta de versión con valor
  ///
  /// In en, this message translates to:
  /// **'Versión: {version}'**
  String versionLabel(String version);

  /// Etiqueta de email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Mensaje de estado de conexión al servidor
  ///
  /// In en, this message translates to:
  /// **'Estado: Conectado al servidor de red'**
  String get connectedToServer;

  /// Mensaje temporal para lista de tareas en desarrollo
  ///
  /// In en, this message translates to:
  /// **'Lista de tareas en desarrollo'**
  String get tasksListDev;

  /// Mensaje temporal para dashboard de admin en desarrollo
  ///
  /// In en, this message translates to:
  /// **'Dashboard de admin en desarrollo'**
  String get adminDashboardDev;

  /// Sección de gestión de usuarios en dashboard de admin
  ///
  /// In en, this message translates to:
  /// **'Gestión de Usuarios'**
  String get dashboardAdminUsersManagement;

  /// Mensaje temporal para dashboard de tutor en desarrollo
  ///
  /// In en, this message translates to:
  /// **'Dashboard de tutor en desarrollo'**
  String get tutorDashboardDev;

  /// Sección de anteproyectos en dashboard de tutor
  ///
  /// In en, this message translates to:
  /// **'Mis Anteproyectos'**
  String get dashboardTutorMyAnteprojects;

  /// Configuración de idioma
  ///
  /// In en, this message translates to:
  /// **'Idioma'**
  String get language;

  /// Idioma español
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// Idioma inglés
  ///
  /// In en, this message translates to:
  /// **'Inglés'**
  String get english;

  /// Sección de información del servidor
  ///
  /// In en, this message translates to:
  /// **'Información del Servidor'**
  String get serverInfo;

  /// URL del servidor
  ///
  /// In en, this message translates to:
  /// **'URL del Servidor'**
  String get serverUrl;

  /// Versión de la aplicación
  ///
  /// In en, this message translates to:
  /// **'Versión'**
  String get version;

  /// Sección de credenciales de prueba
  ///
  /// In en, this message translates to:
  /// **'Credenciales de Prueba'**
  String get testCredentials;

  /// Email de estudiante de prueba
  ///
  /// In en, this message translates to:
  /// **'Correo del Estudiante'**
  String get studentEmail;

  /// Email de tutor de prueba
  ///
  /// In en, this message translates to:
  /// **'Correo del Tutor'**
  String get tutorEmail;

  /// Email de administrador de prueba
  ///
  /// In en, this message translates to:
  /// **'Correo del Administrador'**
  String get adminEmail;

  /// Contraseña de prueba
  ///
  /// In en, this message translates to:
  /// **'Contraseña de Prueba'**
  String get testPassword;

  /// Enlace a Supabase Studio
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get studio;

  /// Título de login exitoso
  ///
  /// In en, this message translates to:
  /// **'✅ Login Exitoso'**
  String get loginSuccessTitle;

  /// Copy to clipboard action
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copyToClipboard;

  /// Copy confirmation message
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// Button to view details
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// Development feature message
  ///
  /// In en, this message translates to:
  /// **'Anteprojects list in development'**
  String get anteprojectsListInDevelopment;

  /// Development feature message
  ///
  /// In en, this message translates to:
  /// **'Students list in development'**
  String get studentsListInDevelopment;

  /// Development feature message
  ///
  /// In en, this message translates to:
  /// **'User management panel in development'**
  String get userManagementInDevelopment;

  /// Development feature message
  ///
  /// In en, this message translates to:
  /// **'Detailed system status in development'**
  String get systemStatusInDevelopment;

  /// Development feature message
  ///
  /// In en, this message translates to:
  /// **'Users list in development'**
  String get usersListInDevelopment;

  /// Validation error title
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get validationError;

  /// Form validation error message
  ///
  /// In en, this message translates to:
  /// **'Please correct the errors in the form'**
  String get formValidationError;

  /// Network error title
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Could not connect to server. Check your internet connection.'**
  String get networkErrorMessage;

  /// Server error title
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'The server could not process the request. Please try again later.'**
  String get serverErrorMessage;

  /// Unknown error title
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get unknownError;

  /// Unknown error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unknownErrorMessage;

  /// Retry operation button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Affirmative response
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Negative response
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Confirmation button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Generic required field message
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// Field too short message
  ///
  /// In en, this message translates to:
  /// **'This field is too short'**
  String get fieldTooShort;

  /// Field too long message
  ///
  /// In en, this message translates to:
  /// **'This field is too long'**
  String get fieldTooLong;

  /// Invalid email message
  ///
  /// In en, this message translates to:
  /// **'The email format is not valid'**
  String get invalidEmail;

  /// Invalid URL message
  ///
  /// In en, this message translates to:
  /// **'The URL format is not valid'**
  String get invalidUrl;

  /// Invalid number message
  ///
  /// In en, this message translates to:
  /// **'The value must be a valid number'**
  String get invalidNumber;

  /// Invalid JSON message
  ///
  /// In en, this message translates to:
  /// **'The JSON format is not valid'**
  String get invalidJson;

  /// Operation in progress message
  ///
  /// In en, this message translates to:
  /// **'Operation in progress...'**
  String get operationInProgress;

  /// Operation completed message
  ///
  /// In en, this message translates to:
  /// **'Operation completed'**
  String get operationCompleted;

  /// Operation failed message
  ///
  /// In en, this message translates to:
  /// **'The operation failed'**
  String get operationFailed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
