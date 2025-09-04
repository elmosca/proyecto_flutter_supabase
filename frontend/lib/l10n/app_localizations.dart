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

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Sistema de Gestión TFG'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @dashboard.
  ///
  /// In es, this message translates to:
  /// **'Panel Principal'**
  String get dashboard;

  /// No description provided for @projects.
  ///
  /// In es, this message translates to:
  /// **'Proyectos'**
  String get projects;

  /// No description provided for @tasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get tasks;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @student.
  ///
  /// In es, this message translates to:
  /// **'Estudiante'**
  String get student;

  /// No description provided for @tutor.
  ///
  /// In es, this message translates to:
  /// **'Tutor'**
  String get tutor;

  /// No description provided for @admin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get admin;

  /// No description provided for @welcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get welcome;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get success;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @noData.
  ///
  /// In es, this message translates to:
  /// **'No hay datos disponibles'**
  String get noData;

  /// No description provided for @connectionError.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Por favor, verifica tu conexión a internet.'**
  String get connectionError;

  /// No description provided for @anteprojectFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear Anteproyecto'**
  String get anteprojectFormTitle;

  /// No description provided for @anteprojectEditFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Anteproyecto'**
  String get anteprojectEditFormTitle;

  /// No description provided for @anteprojectTitle.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get anteprojectTitle;

  /// No description provided for @anteprojectType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de proyecto'**
  String get anteprojectType;

  /// No description provided for @anteprojectDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get anteprojectDescription;

  /// No description provided for @anteprojectAcademicYear.
  ///
  /// In es, this message translates to:
  /// **'Año académico (e.g., 2024-2025)'**
  String get anteprojectAcademicYear;

  /// No description provided for @anteprojectExpectedResults.
  ///
  /// In es, this message translates to:
  /// **'Resultados esperados (JSON)'**
  String get anteprojectExpectedResults;

  /// No description provided for @anteprojectTimeline.
  ///
  /// In es, this message translates to:
  /// **'Temporalización (JSON)'**
  String get anteprojectTimeline;

  /// No description provided for @anteprojectTutorId.
  ///
  /// In es, this message translates to:
  /// **'Tutor ID'**
  String get anteprojectTutorId;

  /// No description provided for @anteprojectStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get anteprojectStatus;

  /// No description provided for @anteprojectCreateButton.
  ///
  /// In es, this message translates to:
  /// **'Crear anteproyecto'**
  String get anteprojectCreateButton;

  /// No description provided for @anteprojectUpdateButton.
  ///
  /// In es, this message translates to:
  /// **'Actualizar anteproyecto'**
  String get anteprojectUpdateButton;

  /// No description provided for @anteprojectDeleteButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get anteprojectDeleteButton;

  /// No description provided for @anteprojectDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Anteproyecto'**
  String get anteprojectDeleteTitle;

  /// No description provided for @anteprojectDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar este anteproyecto? Esta acción no se puede deshacer.'**
  String get anteprojectDeleteMessage;

  /// No description provided for @anteprojectCreatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto creado exitosamente'**
  String get anteprojectCreatedSuccess;

  /// No description provided for @anteprojectUpdatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Anteproyecto actualizado exitosamente'**
  String get anteprojectUpdatedSuccess;

  /// No description provided for @anteprojectInvalidTutorId.
  ///
  /// In es, this message translates to:
  /// **'Tutor ID inválido'**
  String get anteprojectInvalidTutorId;

  /// No description provided for @anteprojectTitleRequired.
  ///
  /// In es, this message translates to:
  /// **'El título es obligatorio'**
  String get anteprojectTitleRequired;

  /// No description provided for @anteprojectDescriptionRequired.
  ///
  /// In es, this message translates to:
  /// **'La descripción es obligatoria'**
  String get anteprojectDescriptionRequired;

  /// No description provided for @anteprojectAcademicYearRequired.
  ///
  /// In es, this message translates to:
  /// **'El año académico es obligatorio'**
  String get anteprojectAcademicYearRequired;

  /// No description provided for @anteprojectTutorIdRequired.
  ///
  /// In es, this message translates to:
  /// **'El Tutor ID es obligatorio'**
  String get anteprojectTutorIdRequired;

  /// No description provided for @anteprojectTutorIdNumeric.
  ///
  /// In es, this message translates to:
  /// **'El Tutor ID debe ser numérico'**
  String get anteprojectTutorIdNumeric;

  /// No description provided for @anteprojectsListTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Anteproyectos'**
  String get anteprojectsListTitle;

  /// No description provided for @anteprojectsListRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar lista'**
  String get anteprojectsListRefresh;

  /// No description provided for @anteprojectsListError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar anteproyectos'**
  String get anteprojectsListError;

  /// No description provided for @anteprojectsListRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get anteprojectsListRetry;

  /// No description provided for @anteprojectsListEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes anteproyectos'**
  String get anteprojectsListEmpty;

  /// No description provided for @anteprojectsListEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer anteproyecto para comenzar'**
  String get anteprojectsListEmptySubtitle;

  /// No description provided for @anteprojectsListUnknownState.
  ///
  /// In es, this message translates to:
  /// **'Estado no reconocido'**
  String get anteprojectsListUnknownState;

  /// No description provided for @anteprojectsListEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get anteprojectsListEdit;

  /// No description provided for @anteprojectDeleteTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar anteproyecto'**
  String get anteprojectDeleteTooltip;

  /// Etiqueta de estado con valor
  ///
  /// In es, this message translates to:
  /// **'Estado: {status}'**
  String anteprojectStatusLabel(String status);

  /// No description provided for @anteprojectExpectedResultsHint.
  ///
  /// In es, this message translates to:
  /// **'Ejemplo milestone1 Descripción'**
  String get anteprojectExpectedResultsHint;

  /// No description provided for @anteprojectTimelineHint.
  ///
  /// In es, this message translates to:
  /// **'Ejemplo phase1 Descripción'**
  String get anteprojectTimelineHint;

  /// No description provided for @dashboardStudent.
  ///
  /// In es, this message translates to:
  /// **'Dashboard Estudiante'**
  String get dashboardStudent;

  /// No description provided for @myAnteprojects.
  ///
  /// In es, this message translates to:
  /// **'Mis Anteproyectos'**
  String get myAnteprojects;

  /// No description provided for @viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get viewAll;

  /// No description provided for @noAnteprojects.
  ///
  /// In es, this message translates to:
  /// **'No tienes anteproyectos creados. ¡Crea tu primer anteproyecto!'**
  String get noAnteprojects;

  /// No description provided for @pendingTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas Pendientes'**
  String get pendingTasks;

  /// No description provided for @viewAllTasks.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get viewAllTasks;

  /// No description provided for @noPendingTasks.
  ///
  /// In es, this message translates to:
  /// **'No tienes tareas pendientes. ¡Excelente trabajo!'**
  String get noPendingTasks;

  /// No description provided for @systemInfo.
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

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @connectedToServer.
  ///
  /// In es, this message translates to:
  /// **'Estado: Conectado al servidor de red'**
  String get connectedToServer;

  /// No description provided for @tasksListDev.
  ///
  /// In es, this message translates to:
  /// **'Lista de tareas en desarrollo'**
  String get tasksListDev;

  /// No description provided for @adminDashboardDev.
  ///
  /// In es, this message translates to:
  /// **'Dashboard de admin en desarrollo'**
  String get adminDashboardDev;

  /// No description provided for @dashboardAdminUsersManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Usuarios'**
  String get dashboardAdminUsersManagement;

  /// No description provided for @tutorDashboardDev.
  ///
  /// In es, this message translates to:
  /// **'Dashboard de tutor en desarrollo'**
  String get tutorDashboardDev;

  /// No description provided for @dashboardTutorMyAnteprojects.
  ///
  /// In es, this message translates to:
  /// **'Mis Anteproyectos'**
  String get dashboardTutorMyAnteprojects;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// No description provided for @serverInfo.
  ///
  /// In es, this message translates to:
  /// **'Información del Servidor'**
  String get serverInfo;

  /// No description provided for @serverUrl.
  ///
  /// In es, this message translates to:
  /// **'URL del Servidor'**
  String get serverUrl;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @testCredentials.
  ///
  /// In es, this message translates to:
  /// **'Credenciales de Prueba'**
  String get testCredentials;

  /// No description provided for @studentEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo del Estudiante'**
  String get studentEmail;

  /// No description provided for @tutorEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo del Tutor'**
  String get tutorEmail;

  /// No description provided for @adminEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo del Administrador'**
  String get adminEmail;

  /// No description provided for @testPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña de Prueba'**
  String get testPassword;

  /// No description provided for @studio.
  ///
  /// In es, this message translates to:
  /// **'Studio'**
  String get studio;

  /// No description provided for @loginSuccessTitle.
  ///
  /// In es, this message translates to:
  /// **'✅ Login Exitoso'**
  String get loginSuccessTitle;

  /// No description provided for @copyToClipboard.
  ///
  /// In es, this message translates to:
  /// **'Copiar al portapapeles'**
  String get copyToClipboard;

  /// No description provided for @copied.
  ///
  /// In es, this message translates to:
  /// **'¡Copiado!'**
  String get copied;
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
