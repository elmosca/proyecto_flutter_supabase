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

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'TFG Management System'**
  String get appTitle;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Login error message with details
  ///
  /// In en, this message translates to:
  /// **'❌ Error: {error}'**
  String loginError(String error);

  /// Dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Projects section title
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// Tasks section title
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Profile section title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Student role label
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// Tutor role label
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get tutor;

  /// Administrator role label
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get admin;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Success message when creating a task
  ///
  /// In en, this message translates to:
  /// **'Task created successfully'**
  String get taskCreatedSuccess;

  /// Success message when updating a task
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully'**
  String get taskUpdatedSuccess;

  /// Success message when updating task status
  ///
  /// In en, this message translates to:
  /// **'Task status updated'**
  String get taskStatusUpdatedSuccess;

  /// Success message when deleting a task
  ///
  /// In en, this message translates to:
  /// **'Task deleted successfully'**
  String get taskDeletedSuccess;

  /// Error message when task is not found
  ///
  /// In en, this message translates to:
  /// **'Task not found'**
  String get taskNotFound;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Message when no data is available
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please check your internet connection.'**
  String get connectionError;

  /// Server information title
  ///
  /// In en, this message translates to:
  /// **'Server Information'**
  String get serverInfo;

  /// Server URL label
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// Platform label
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Test credentials title
  ///
  /// In en, this message translates to:
  /// **'Test Credentials'**
  String get testCredentials;

  /// Student test email
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get studentEmail;

  /// Tutor test email
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get tutorEmail;

  /// Administrator test email
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get adminEmail;

  /// Test password
  ///
  /// In en, this message translates to:
  /// **'Test password'**
  String get testPassword;

  /// Copy to clipboard tooltip
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copyToClipboard;

  /// Successful copy message
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// Language label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Spanish language name
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Theme selection label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Student dashboard title
  ///
  /// In en, this message translates to:
  /// **'Student Dashboard'**
  String get dashboardStudent;

  /// Welcome message with user email
  ///
  /// In en, this message translates to:
  /// **'Welcome, {email}'**
  String welcomeUser(String email);

  /// User anteprojects section title
  ///
  /// In en, this message translates to:
  /// **'My Anteprojects'**
  String get myAnteprojects;

  /// Button to view all items
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// Message when there are no anteprojects
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any anteprojects created. Create your first anteproject!'**
  String get noAnteprojects;

  /// Pending tasks section title
  ///
  /// In en, this message translates to:
  /// **'Pending Tasks'**
  String get pendingTasks;

  /// Button to view all tasks
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAllTasks;

  /// Message when there are no pending tasks
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any pending tasks. Excellent work!'**
  String get noPendingTasks;

  /// System information section title
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get systemInfo;

  /// Server connection status message
  ///
  /// In en, this message translates to:
  /// **'Status: Connected to network server'**
  String get connectedToServer;

  /// Development functionality message
  ///
  /// In en, this message translates to:
  /// **'Anteproject creation functionality in development'**
  String get anteprojectsDev;

  /// List development message
  ///
  /// In en, this message translates to:
  /// **'Anteprojects list in development'**
  String get anteprojectsListDev;

  /// Tasks list development message
  ///
  /// In en, this message translates to:
  /// **'Tasks list in development'**
  String get tasksListDev;

  /// Platform label with value
  ///
  /// In en, this message translates to:
  /// **'Platform: {platform}'**
  String platformLabel(String platform);

  /// Version label with value
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String versionLabel(String version);

  /// Backend label with URL
  ///
  /// In en, this message translates to:
  /// **'Backend: {url}'**
  String backendLabel(String url);

  /// Supabase Studio label
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get studio;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Successful login message with platform
  ///
  /// In en, this message translates to:
  /// **'✅ Login successful on {platform}!'**
  String loginSuccess(String platform);

  /// Successful login dialog title
  ///
  /// In en, this message translates to:
  /// **'✅ Login Successful'**
  String get loginSuccessTitle;

  /// Email information with value
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String emailInfo(String email);

  /// ID information with value
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String idInfo(String id);

  /// Role information with value
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String roleInfo(String role);

  /// Creation date information
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdInfo(String date);

  /// Next steps section title
  ///
  /// In en, this message translates to:
  /// **'Next steps:'**
  String get nextSteps;

  /// Role navigation step
  ///
  /// In en, this message translates to:
  /// **'• Role-based navigation'**
  String get navigationRoles;

  /// Personal dashboard step
  ///
  /// In en, this message translates to:
  /// **'• Personal dashboard'**
  String get personalDashboard;

  /// Anteprojects management step
  ///
  /// In en, this message translates to:
  /// **'• Anteprojects management'**
  String get anteprojectsManagement;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Tutor dashboard development message
  ///
  /// In en, this message translates to:
  /// **'Tutor dashboard in development'**
  String get tutorDashboardDev;

  /// Admin dashboard development message
  ///
  /// In en, this message translates to:
  /// **'Admin dashboard in development'**
  String get adminDashboardDev;

  /// Message when role is not specified
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get roleNotSpecified;

  /// Administrator dashboard title
  ///
  /// In en, this message translates to:
  /// **'Administration Panel'**
  String get dashboardAdminTitle;

  /// User management section title
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get dashboardAdminUsersManagement;

  /// Anteprojects management section title
  ///
  /// In en, this message translates to:
  /// **'Anteprojects Management'**
  String get dashboardAdminAnteprojectsManagement;

  /// System statistics section title
  ///
  /// In en, this message translates to:
  /// **'System Statistics'**
  String get dashboardAdminSystemStats;

  /// Active users statistics title
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get dashboardAdminActiveUsers;

  /// Pending anteproyectos statistics title
  ///
  /// In en, this message translates to:
  /// **'Pending Anteprojects'**
  String get dashboardAdminPendingAnteproyectos;

  /// Ongoing projects statistics title
  ///
  /// In en, this message translates to:
  /// **'Ongoing Projects'**
  String get dashboardAdminOngoingProjects;

  /// Completed tasks statistics title
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get dashboardAdminCompletedTasks;

  /// Tutor dashboard title
  ///
  /// In en, this message translates to:
  /// **'Tutor Panel'**
  String get dashboardTutorTitle;

  /// My anteproyectos section title
  ///
  /// In en, this message translates to:
  /// **'My Anteprojects'**
  String get dashboardTutorMyAnteprojects;

  /// Active projects section title
  ///
  /// In en, this message translates to:
  /// **'Active Projects'**
  String get dashboardTutorActiveProjects;

  /// Pending tasks section title
  ///
  /// In en, this message translates to:
  /// **'Pending Tasks'**
  String get dashboardTutorPendingTasks;

  /// Personal statistics section title
  ///
  /// In en, this message translates to:
  /// **'Personal Statistics'**
  String get dashboardTutorPersonalStats;

  /// Authentication error message
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get errorAuthentication;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get errorConnection;

  /// Unknown error message
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get errorUnknown;

  /// Error dialog title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Text for unavailable values
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;
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
