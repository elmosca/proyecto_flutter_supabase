// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TFG Management System';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String loginError(String error) {
    return '❌ Error: $error';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get projects => 'Projects';

  @override
  String get tasks => 'Tasks';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get student => 'Student';

  @override
  String get tutor => 'Tutor';

  @override
  String get admin => 'Administrator';

  @override
  String get welcome => 'Welcome';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get taskCreatedSuccess => 'Task created successfully';

  @override
  String get taskUpdatedSuccess => 'Task updated successfully';

  @override
  String get taskStatusUpdatedSuccess => 'Task status updated';

  @override
  String get taskDeletedSuccess => 'Task deleted successfully';

  @override
  String get taskNotFound => 'Task not found';

  @override
  String get delete => 'Delete';

  @override
  String get create => 'Create';

  @override
  String get search => 'Search';

  @override
  String get noData => 'No data available';

  @override
  String get connectionError =>
      'Connection error. Please check your internet connection.';

  @override
  String get serverInfo => 'Server Information';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get platform => 'Platform';

  @override
  String get version => 'Version';

  @override
  String get testCredentials => 'Test Credentials';

  @override
  String get studentEmail => 'Student';

  @override
  String get tutorEmail => 'Tutor';

  @override
  String get adminEmail => 'Administrator';

  @override
  String get testPassword => 'Test password';

  @override
  String get copyToClipboard => 'Copy to clipboard';

  @override
  String get copied => 'Copied';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get dashboardStudent => 'Student Dashboard';

  @override
  String welcomeUser(String email) {
    return 'Welcome, $email';
  }

  @override
  String get myAnteprojects => 'My Anteprojects';

  @override
  String get viewAll => 'View all';

  @override
  String get noAnteprojects =>
      'You don\'t have any anteprojects created. Create your first anteproject!';

  @override
  String get pendingTasks => 'Pending Tasks';

  @override
  String get viewAllTasks => 'View all';

  @override
  String get noPendingTasks =>
      'You don\'t have any pending tasks. Excellent work!';

  @override
  String get systemInfo => 'System Information';

  @override
  String get connectedToServer => 'Status: Connected to network server';

  @override
  String get anteprojectsDev =>
      'Anteproject creation functionality in development';

  @override
  String get anteprojectsListDev => 'Anteprojects list in development';

  @override
  String get tasksListDev => 'Tasks list in development';

  @override
  String platformLabel(String platform) {
    return 'Platform: $platform';
  }

  @override
  String versionLabel(String version) {
    return 'Version: $version';
  }

  @override
  String backendLabel(String url) {
    return 'Backend: $url';
  }

  @override
  String get studio => 'Studio';

  @override
  String get emailLabel => 'Email';

  @override
  String loginSuccess(String platform) {
    return '✅ Login successful on $platform!';
  }

  @override
  String get loginSuccessTitle => '✅ Login Successful';

  @override
  String emailInfo(String email) {
    return 'Email: $email';
  }

  @override
  String idInfo(String id) {
    return 'ID: $id';
  }

  @override
  String roleInfo(String role) {
    return 'Role: $role';
  }

  @override
  String createdInfo(String date) {
    return 'Created: $date';
  }

  @override
  String get nextSteps => 'Next steps:';

  @override
  String get navigationRoles => '• Role-based navigation';

  @override
  String get personalDashboard => '• Personal dashboard';

  @override
  String get anteprojectsManagement => '• Anteprojects management';

  @override
  String get continueButton => 'Continue';

  @override
  String get tutorDashboardDev => 'Tutor dashboard in development';

  @override
  String get adminDashboardDev => 'Admin dashboard in development';

  @override
  String get roleNotSpecified => 'Not specified';

  @override
  String get dashboardAdminTitle => 'Administration Panel';

  @override
  String get dashboardAdminUsersManagement => 'User Management';

  @override
  String get dashboardAdminAnteprojectsManagement => 'Anteprojects Management';

  @override
  String get dashboardAdminSystemStats => 'System Statistics';

  @override
  String get dashboardAdminActiveUsers => 'Active Users';

  @override
  String get dashboardAdminPendingAnteproyectos => 'Pending Anteprojects';

  @override
  String get dashboardAdminOngoingProjects => 'Ongoing Projects';

  @override
  String get dashboardAdminCompletedTasks => 'Completed Tasks';

  @override
  String get dashboardTutorTitle => 'Tutor Panel';

  @override
  String get dashboardTutorMyAnteprojects => 'My Anteprojects';

  @override
  String get dashboardTutorActiveProjects => 'Active Projects';

  @override
  String get dashboardTutorPendingTasks => 'Pending Tasks';

  @override
  String get dashboardTutorPersonalStats => 'Personal Statistics';

  @override
  String get errorAuthentication => 'Authentication Error';

  @override
  String get errorConnection => 'Connection Error';

  @override
  String get errorUnknown => 'Unknown Error';

  @override
  String get errorTitle => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get notAvailable => 'Not Available';

  @override
  String get anteprojectFormTitle => 'Crear Anteproyecto';

  @override
  String get anteprojectEditFormTitle => 'Editar Anteproyecto';

  @override
  String get anteprojectTitle => 'Título';

  @override
  String get anteprojectType => 'Tipo de proyecto';

  @override
  String get anteprojectDescription => 'Descripción';

  @override
  String get anteprojectAcademicYear => 'Año académico (e.g., 2024-2025)';

  @override
  String get anteprojectExpectedResults => 'Resultados esperados (JSON)';

  @override
  String get anteprojectTimeline => 'Temporalización (JSON)';

  @override
  String get anteprojectTutorId => 'Tutor ID';

  @override
  String get anteprojectStatus => 'Estado';

  @override
  String get anteprojectCreateButton => 'Crear anteproyecto';

  @override
  String get anteprojectUpdateButton => 'Actualizar anteproyecto';

  @override
  String get anteprojectDeleteButton => 'Eliminar';

  @override
  String get anteprojectDeleteTitle => 'Eliminar Anteproyecto';

  @override
  String get anteprojectDeleteMessage =>
      '¿Estás seguro de que quieres eliminar este anteproyecto? Esta acción no se puede deshacer.';

  @override
  String get anteprojectCreatedSuccess => 'Anteproyecto creado exitosamente';

  @override
  String get anteprojectUpdatedSuccess =>
      'Anteproyecto actualizado exitosamente';

  @override
  String get anteprojectInvalidTutorId => 'Tutor ID inválido';

  @override
  String get anteprojectTitleRequired => 'El título es obligatorio';

  @override
  String get anteprojectDescriptionRequired => 'La descripción es obligatoria';

  @override
  String get anteprojectAcademicYearRequired =>
      'El año académico es obligatorio';

  @override
  String get anteprojectTutorIdRequired => 'El Tutor ID es obligatorio';

  @override
  String get anteprojectTutorIdNumeric => 'El Tutor ID debe ser numérico';

  @override
  String get anteprojectsListTitle => 'Mis Anteproyectos';

  @override
  String get anteprojectsListRefresh => 'Actualizar lista';

  @override
  String get anteprojectsListError => 'Error al cargar anteproyectos';

  @override
  String get anteprojectsListRetry => 'Reintentar';

  @override
  String get anteprojectsListEmpty => 'No tienes anteproyectos';

  @override
  String get anteprojectsListEmptySubtitle =>
      'Crea tu primer anteproyecto para comenzar';

  @override
  String get anteprojectsListUnknownState => 'Estado no reconocido';

  @override
  String get anteprojectsListEdit => 'Editar';

  @override
  String get anteprojectDeleteTooltip => 'Eliminar anteproyecto';

  @override
  String anteprojectStatusLabel(String status) {
    return 'Estado: $status';
  }

  @override
  String get anteprojectExpectedResultsHint => 'milestone1: Descripción';

  @override
  String get anteprojectTimelineHint => 'phase1: Descripción';
}
