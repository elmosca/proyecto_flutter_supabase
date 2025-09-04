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

  /// El título de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Sistema de Gestión TFG'**
  String get appTitle;

  /// Texto del botón de inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// Etiqueta del campo de correo electrónico
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get email;

  /// Etiqueta del campo de contraseña
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// Mensaje de error de login con detalles
  ///
  /// In es, this message translates to:
  /// **'❌ Error: {error}'**
  String loginError(String error);

  /// Título de la pantalla del panel principal
  ///
  /// In es, this message translates to:
  /// **'Panel Principal'**
  String get dashboard;

  /// Título de la sección de proyectos
  ///
  /// In es, this message translates to:
  /// **'Proyectos'**
  String get projects;

  /// Título de la sección de tareas
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get tasks;

  /// Título de la sección de perfil
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// Texto del botón de cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// Etiqueta del rol de estudiante
  ///
  /// In es, this message translates to:
  /// **'Estudiante'**
  String get student;

  /// Etiqueta del rol de tutor
  ///
  /// In es, this message translates to:
  /// **'Tutor'**
  String get tutor;

  /// Etiqueta del rol de administrador
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

  /// Mensaje de error
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// Mensaje de éxito
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get success;

  /// Texto del botón cancelar
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Texto del botón guardar
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Texto del botón editar
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// Mensaje de éxito al crear una tarea
  ///
  /// In es, this message translates to:
  /// **'Tarea creada exitosamente'**
  String get taskCreatedSuccess;

  /// Mensaje de éxito al actualizar una tarea
  ///
  /// In es, this message translates to:
  /// **'Tarea actualizada exitosamente'**
  String get taskUpdatedSuccess;

  /// Mensaje de éxito al actualizar el estado de una tarea
  ///
  /// In es, this message translates to:
  /// **'Estado de tarea actualizado'**
  String get taskStatusUpdatedSuccess;

  /// Mensaje de éxito al eliminar una tarea
  ///
  /// In es, this message translates to:
  /// **'Tarea eliminada exitosamente'**
  String get taskDeletedSuccess;

  /// Mensaje de error cuando no se encuentra una tarea
  ///
  /// In es, this message translates to:
  /// **'Tarea no encontrada'**
  String get taskNotFound;

  /// Texto del botón eliminar
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// Texto del botón crear
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// Placeholder del campo de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// Mensaje cuando no hay datos disponibles
  ///
  /// In es, this message translates to:
  /// **'No hay datos disponibles'**
  String get noData;

  /// Mensaje de error de conexión
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Por favor, verifica tu conexión a internet.'**
  String get connectionError;

  /// Título de información del servidor
  ///
  /// In es, this message translates to:
  /// **'Información del Servidor'**
  String get serverInfo;

  /// Etiqueta de URL del servidor
  ///
  /// In es, this message translates to:
  /// **'URL del Servidor'**
  String get serverUrl;

  /// Etiqueta de plataforma
  ///
  /// In es, this message translates to:
  /// **'Plataforma'**
  String get platform;

  /// Etiqueta de versión
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// Título de credenciales de prueba
  ///
  /// In es, this message translates to:
  /// **'Credenciales de Prueba'**
  String get testCredentials;

  /// Email de estudiante de prueba
  ///
  /// In es, this message translates to:
  /// **'Estudiante'**
  String get studentEmail;

  /// Email de tutor de prueba
  ///
  /// In es, this message translates to:
  /// **'Tutor'**
  String get tutorEmail;

  /// Email de administrador de prueba
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get adminEmail;

  /// Contraseña de prueba
  ///
  /// In es, this message translates to:
  /// **'Contraseña de prueba'**
  String get testPassword;

  /// Tooltip para copiar al portapapeles
  ///
  /// In es, this message translates to:
  /// **'Copiar al portapapeles'**
  String get copyToClipboard;

  /// Mensaje de copiado exitoso
  ///
  /// In es, this message translates to:
  /// **'Copiado'**
  String get copied;

  /// Etiqueta de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// Nombre del idioma inglés
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// Nombre del idioma español
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// Título de la pantalla de configuración
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// Etiqueta de selección de tema
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// Opción de tema claro
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get light;

  /// Opción de tema oscuro
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get dark;

  /// Opción de tema del sistema
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get system;

  /// Título del dashboard de estudiante
  ///
  /// In es, this message translates to:
  /// **'Dashboard Estudiante'**
  String get dashboardStudent;

  /// Mensaje de bienvenida con email del usuario
  ///
  /// In es, this message translates to:
  /// **'Bienvenido, {email}'**
  String welcomeUser(String email);

  /// Título de la sección de anteproyectos del usuario
  ///
  /// In es, this message translates to:
  /// **'Mis Anteproyectos'**
  String get myAnteprojects;

  /// Botón para ver todos los elementos
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get viewAll;

  /// Mensaje cuando no hay anteproyectos
  ///
  /// In es, this message translates to:
  /// **'No tienes anteproyectos creados. ¡Crea tu primer anteproyecto!'**
  String get noAnteprojects;

  /// Título de la sección de tareas pendientes
  ///
  /// In es, this message translates to:
  /// **'Tareas Pendientes'**
  String get pendingTasks;

  /// Botón para ver todas las tareas
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get viewAllTasks;

  /// Mensaje cuando no hay tareas pendientes
  ///
  /// In es, this message translates to:
  /// **'No tienes tareas pendientes. ¡Excelente trabajo!'**
  String get noPendingTasks;

  /// Título de la sección de información del sistema
  ///
  /// In es, this message translates to:
  /// **'Información del Sistema'**
  String get systemInfo;

  /// Mensaje de estado de conexión al servidor
  ///
  /// In es, this message translates to:
  /// **'Estado: Conectado al servidor de red'**
  String get connectedToServer;

  /// Mensaje de funcionalidad en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Funcionalidad de creación de anteproyectos en desarrollo'**
  String get anteprojectsDev;

  /// Mensaje de lista en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Lista de anteproyectos en desarrollo'**
  String get anteprojectsListDev;

  /// Mensaje de lista de tareas en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Lista de tareas en desarrollo'**
  String get tasksListDev;

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

  /// Etiqueta de backend con URL
  ///
  /// In es, this message translates to:
  /// **'Backend: {url}'**
  String backendLabel(String url);

  /// Etiqueta para Supabase Studio
  ///
  /// In es, this message translates to:
  /// **'Studio'**
  String get studio;

  /// Etiqueta de email
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Mensaje de login exitoso con plataforma
  ///
  /// In es, this message translates to:
  /// **'✅ Login exitoso en {platform}!'**
  String loginSuccess(String platform);

  /// Título de diálogo de login exitoso
  ///
  /// In es, this message translates to:
  /// **'✅ Login Exitoso'**
  String get loginSuccessTitle;

  /// Información de email con valor
  ///
  /// In es, this message translates to:
  /// **'Email: {email}'**
  String emailInfo(String email);

  /// Información de ID con valor
  ///
  /// In es, this message translates to:
  /// **'ID: {id}'**
  String idInfo(String id);

  /// Información de rol con valor
  ///
  /// In es, this message translates to:
  /// **'Rol: {role}'**
  String roleInfo(String role);

  /// Información de fecha de creación
  ///
  /// In es, this message translates to:
  /// **'Creado: {date}'**
  String createdInfo(String date);

  /// Título de sección de próximos pasos
  ///
  /// In es, this message translates to:
  /// **'Próximos pasos:'**
  String get nextSteps;

  /// Paso de navegación por roles
  ///
  /// In es, this message translates to:
  /// **'• Navegación por roles'**
  String get navigationRoles;

  /// Paso de dashboard personalizado
  ///
  /// In es, this message translates to:
  /// **'• Dashboard personalizado'**
  String get personalDashboard;

  /// Paso de gestión de anteproyectos
  ///
  /// In es, this message translates to:
  /// **'• Gestión de anteproyectos'**
  String get anteprojectsManagement;

  /// Botón de continuar
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueButton;

  /// Mensaje de dashboard de tutor en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Dashboard de tutor en desarrollo'**
  String get tutorDashboardDev;

  /// Mensaje de dashboard de admin en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Dashboard de admin en desarrollo'**
  String get adminDashboardDev;

  /// Mensaje cuando el rol no está especificado
  ///
  /// In es, this message translates to:
  /// **'No especificado'**
  String get roleNotSpecified;

  /// Título del dashboard de administrador
  ///
  /// In es, this message translates to:
  /// **'Panel de Administración'**
  String get dashboardAdminTitle;

  /// Título de la sección de gestión de usuarios
  ///
  /// In es, this message translates to:
  /// **'Gestión de Usuarios'**
  String get dashboardAdminUsersManagement;

  /// Título de la sección de gestión de anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Gestión de Anteproyectos'**
  String get dashboardAdminAnteprojectsManagement;

  /// Título de la sección de estadísticas del sistema
  ///
  /// In es, this message translates to:
  /// **'Estadísticas del Sistema'**
  String get dashboardAdminSystemStats;

  /// Título de la estadística de usuarios activos
  ///
  /// In es, this message translates to:
  /// **'Usuarios Activos'**
  String get dashboardAdminActiveUsers;

  /// Título de la estadística de anteproyectos pendientes
  ///
  /// In es, this message translates to:
  /// **'Anteproyectos Pendientes'**
  String get dashboardAdminPendingAnteproyectos;

  /// Título de la estadística de proyectos en curso
  ///
  /// In es, this message translates to:
  /// **'Proyectos en Curso'**
  String get dashboardAdminOngoingProjects;

  /// Título de la estadística de tareas completadas
  ///
  /// In es, this message translates to:
  /// **'Tareas Completadas'**
  String get dashboardAdminCompletedTasks;

  /// Título del dashboard de tutor
  ///
  /// In es, this message translates to:
  /// **'Panel de Tutor'**
  String get dashboardTutorTitle;

  /// Título de la sección de mis anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Mis Anteproyectos'**
  String get dashboardTutorMyAnteprojects;

  /// Título de la sección de proyectos activos
  ///
  /// In es, this message translates to:
  /// **'Proyectos Activos'**
  String get dashboardTutorActiveProjects;

  /// Título de la sección de tareas pendientes
  ///
  /// In es, this message translates to:
  /// **'Tareas Pendientes'**
  String get dashboardTutorPendingTasks;

  /// Título de la sección de estadísticas personales
  ///
  /// In es, this message translates to:
  /// **'Estadísticas Personales'**
  String get dashboardTutorPersonalStats;

  /// Mensaje de error de autenticación
  ///
  /// In es, this message translates to:
  /// **'Error de Autenticación'**
  String get errorAuthentication;

  /// Mensaje de error de conexión
  ///
  /// In es, this message translates to:
  /// **'Error de Conexión'**
  String get errorConnection;

  /// Mensaje de error desconocido
  ///
  /// In es, this message translates to:
  /// **'Error Desconocido'**
  String get errorUnknown;

  /// Título del diálogo de error
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// Texto del botón aceptar
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get ok;

  /// Texto para valores no disponibles
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get notAvailable;

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

  /// Etiqueta del campo título del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get anteprojectTitle;

  /// Etiqueta del campo tipo de proyecto
  ///
  /// In es, this message translates to:
  /// **'Tipo de proyecto'**
  String get anteprojectType;

  /// Etiqueta del campo descripción del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get anteprojectDescription;

  /// Etiqueta del campo año académico
  ///
  /// In es, this message translates to:
  /// **'Año académico (e.g., 2024-2025)'**
  String get anteprojectAcademicYear;

  /// Etiqueta del campo resultados esperados
  ///
  /// In es, this message translates to:
  /// **'Resultados esperados (JSON)'**
  String get anteprojectExpectedResults;

  /// Etiqueta del campo temporalización
  ///
  /// In es, this message translates to:
  /// **'Temporalización (JSON)'**
  String get anteprojectTimeline;

  /// Etiqueta del campo ID del tutor
  ///
  /// In es, this message translates to:
  /// **'Tutor ID'**
  String get anteprojectTutorId;

  /// Etiqueta del campo estado del anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get anteprojectStatus;

  /// Texto del botón crear anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Crear anteproyecto'**
  String get anteprojectCreateButton;

  /// Texto del botón actualizar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Actualizar anteproyecto'**
  String get anteprojectUpdateButton;

  /// Texto del botón eliminar anteproyecto
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get anteprojectDeleteButton;

  /// Título del diálogo de eliminación
  ///
  /// In es, this message translates to:
  /// **'Eliminar Anteproyecto'**
  String get anteprojectDeleteTitle;

  /// Mensaje de confirmación de eliminación
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

  /// Tooltip del botón actualizar lista
  ///
  /// In es, this message translates to:
  /// **'Actualizar lista'**
  String get anteprojectsListRefresh;

  /// Mensaje de error al cargar anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Error al cargar anteproyectos'**
  String get anteprojectsListError;

  /// Texto del botón reintentar
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get anteprojectsListRetry;

  /// Mensaje cuando no hay anteproyectos
  ///
  /// In es, this message translates to:
  /// **'No tienes anteproyectos'**
  String get anteprojectsListEmpty;

  /// Subtítulo cuando no hay anteproyectos
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer anteproyecto para comenzar'**
  String get anteprojectsListEmptySubtitle;

  /// Mensaje para estado no reconocido
  ///
  /// In es, this message translates to:
  /// **'Estado no reconocido'**
  String get anteprojectsListUnknownState;

  /// Texto del botón editar en la lista
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get anteprojectsListEdit;

  /// Tooltip del botón eliminar anteproyecto
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
  /// **'milestone1: Descripción'**
  String get anteprojectExpectedResultsHint;

  /// Hint para el campo de temporalización
  ///
  /// In es, this message translates to:
  /// **'phase1: Descripción'**
  String get anteprojectTimelineHint;
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
