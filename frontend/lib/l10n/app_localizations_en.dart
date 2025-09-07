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
  String get loginError => 'Login error. Please verify your credentials.';

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
  String get student => 'Estudiante';

  @override
  String get tutor => 'Tutor';

  @override
  String get admin => 'Administrador';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get edit => 'Editar';

  @override
  String get taskCreatedSuccess => 'Tarea creada exitosamente';

  @override
  String get taskUpdatedSuccess => 'Tarea actualizada exitosamente';

  @override
  String get taskStatusUpdatedSuccess => 'Estado de tarea actualizado';

  @override
  String get taskDeletedSuccess => 'Tarea eliminada exitosamente';

  @override
  String get taskNotFound => 'Tarea no encontrada';

  @override
  String get delete => 'Eliminar';

  @override
  String get create => 'Crear';

  @override
  String get search => 'Buscar';

  @override
  String get noData => 'No hay datos disponibles';

  @override
  String get connectionError =>
      'Error de conexión. Por favor, verifica tu conexión a internet.';

  @override
  String get anteprojectFormTitle => 'Create Anteproject';

  @override
  String get anteprojectEditFormTitle => 'Edit Anteproject';

  @override
  String get anteprojectTitle => 'Title';

  @override
  String get anteprojectType => 'Project Type';

  @override
  String get anteprojectDescription => 'Description';

  @override
  String get anteprojectAcademicYear => 'Año académico (e.g., 2024-2025)';

  @override
  String get anteprojectExpectedResults => 'Resultados esperados (JSON)';

  @override
  String get anteprojectTimeline => 'Temporalización (JSON)';

  @override
  String get anteprojectTutorId => 'Tutor ID';

  @override
  String get anteprojectStatus => 'Status';

  @override
  String get anteprojectCreateButton => 'Create Anteproject';

  @override
  String get anteprojectUpdateButton => 'Update Anteproject';

  @override
  String get anteprojectDeleteButton => 'Delete';

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
  String get anteprojectsListTitle => 'My Anteprojects';

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
  String get commentsTitle => 'Comentarios';

  @override
  String get commentsAddComment => 'Añadir comentario';

  @override
  String get commentsWriteComment => 'Escribe tu comentario...';

  @override
  String get commentsSend => 'Enviar';

  @override
  String get commentsCancel => 'Cancelar';

  @override
  String get commentsInternal => 'Comentario interno';

  @override
  String get commentsPublic => 'Comentario público';

  @override
  String get commentsNoComments => 'No hay comentarios';

  @override
  String get commentsAddFirst => 'Sé el primero en comentar';

  @override
  String get commentsError => 'Error al cargar comentarios';

  @override
  String get commentsErrorAdd => 'Error al añadir comentario';

  @override
  String get commentsSuccess => 'Comentario añadido correctamente';

  @override
  String get commentsDelete => 'Eliminar comentario';

  @override
  String get commentsDeleteConfirm =>
      '¿Estás seguro de que quieres eliminar este comentario?';

  @override
  String get commentsEdit => 'Editar comentario';

  @override
  String get commentsSave => 'Guardar cambios';

  @override
  String get commentsAuthor => 'Autor';

  @override
  String get commentsDate => 'Fecha';

  @override
  String get commentsContent => 'Contenido';

  @override
  String get commentsContentRequired =>
      'El contenido del comentario es obligatorio';

  @override
  String get commentsContentMinLength =>
      'El comentario debe tener al menos 3 caracteres';

  @override
  String get commentsContentMaxLength =>
      'El comentario no puede exceder 1000 caracteres';

  @override
  String get retry => 'Retry';

  @override
  String get unknownUser => 'Usuario desconocido';

  @override
  String get justNow => 'Ahora';

  @override
  String anteprojectStatusLabel(String status) {
    return 'Estado: $status';
  }

  @override
  String get anteprojectExpectedResultsHint => 'Ejemplo milestone1 Descripción';

  @override
  String get anteprojectTimelineHint => 'Ejemplo phase1 Descripción';

  @override
  String get dashboardStudent => 'Dashboard Estudiante';

  @override
  String get myAnteprojects => 'Mis Anteproyectos';

  @override
  String get viewAll => 'View all';

  @override
  String get pendingAnteprojects => 'Pending Anteprojects';

  @override
  String get assignedStudents => 'Assigned Students';

  @override
  String get noAnteprojects =>
      'You don\'t have any anteprojects created. Create your first anteproject!';

  @override
  String get pendingTasks => 'Pending Tasks';

  @override
  String get viewAllTasks => 'View all';

  @override
  String get noPendingTasks => 'You don\'t have any pending tasks. Great job!';

  @override
  String get systemInfo => 'System Information';

  @override
  String backendLabel(String url) {
    return 'Backend: $url';
  }

  @override
  String platformLabel(String platform) {
    return 'Platform: $platform';
  }

  @override
  String versionLabel(String version) {
    return 'Version: $version';
  }

  @override
  String get emailLabel => 'Email';

  @override
  String get connectedToServer => 'Status: Connected to network server';

  @override
  String get tasksListDev => 'Tasks list in development';

  @override
  String get adminDashboardDev => 'Admin dashboard in development';

  @override
  String get dashboardAdminUsersManagement => 'User Management';

  @override
  String get tutorDashboardDev => 'Tutor dashboard in development';

  @override
  String get dashboardTutorMyAnteprojects => 'My Anteprojects';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get serverInfo => 'Server Information';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get version => 'Version';

  @override
  String get testCredentials => 'Test Credentials';

  @override
  String get studentEmail => 'Student Email';

  @override
  String get tutorEmail => 'Tutor Email';

  @override
  String get adminEmail => 'Admin Email';

  @override
  String get testPassword => 'Test Password';

  @override
  String get studio => 'Studio';

  @override
  String get loginSuccessTitle => '✅ Login Successful';

  @override
  String get copyToClipboard => 'Copy to clipboard';

  @override
  String get copied => 'Copied!';

  @override
  String get viewDetails => 'View details';

  @override
  String get anteprojectsListInDevelopment =>
      'Anteprojects list in development';

  @override
  String get studentsListInDevelopment => 'Students list in development';

  @override
  String get userManagementInDevelopment =>
      'User management panel in development';

  @override
  String get systemStatusInDevelopment =>
      'Detailed system status in development';

  @override
  String get usersListInDevelopment => 'Users list in development';

  @override
  String get validationError => 'Validation Error';

  @override
  String get formValidationError => 'Please correct the errors in the form';

  @override
  String get networkError => 'Network Error';

  @override
  String get networkErrorMessage =>
      'Could not connect to server. Check your internet connection.';

  @override
  String get serverError => 'Server Error';

  @override
  String get serverErrorMessage =>
      'The server could not process the request. Please try again later.';

  @override
  String get unknownError => 'Unknown Error';

  @override
  String get unknownErrorMessage =>
      'An unexpected error occurred. Please try again.';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get fieldTooShort => 'This field is too short';

  @override
  String get fieldTooLong => 'This field is too long';

  @override
  String get invalidEmail => 'The email format is not valid';

  @override
  String get invalidUrl => 'The URL format is not valid';

  @override
  String get invalidNumber => 'The value must be a valid number';

  @override
  String get invalidJson => 'The JSON format is not valid';

  @override
  String get operationInProgress => 'Operation in progress...';

  @override
  String get operationCompleted => 'Operation completed';

  @override
  String get operationFailed => 'The operation failed';

  @override
  String get taskFormTitle => 'Formulario de Tarea';

  @override
  String get taskEditFormTitle => 'Editar Tarea';

  @override
  String get taskTitle => 'Título';

  @override
  String get taskDescription => 'Descripción';

  @override
  String get taskStatus => 'Estado';

  @override
  String get taskComplexity => 'Complejidad';

  @override
  String get taskDueDate => 'Fecha de Vencimiento';

  @override
  String get taskEstimatedHours => 'Horas Estimadas';

  @override
  String get taskTags => 'Etiquetas';

  @override
  String get taskCreateButton => 'Crear Tarea';

  @override
  String get taskUpdateButton => 'Actualizar Tarea';

  @override
  String get taskTitleRequired => 'El título es obligatorio';

  @override
  String get taskDescriptionRequired => 'La descripción es obligatoria';

  @override
  String get taskStatusPending => 'Pendiente';

  @override
  String get taskStatusInProgress => 'En Progreso';

  @override
  String get taskStatusUnderReview => 'En Revisión';

  @override
  String get taskStatusCompleted => 'Completada';

  @override
  String get taskComplexitySimple => 'Simple';

  @override
  String get taskComplexityMedium => 'Media';

  @override
  String get taskComplexityComplex => 'Compleja';

  @override
  String get tasksListTitle => 'Lista de Tareas';

  @override
  String get tasksListEmpty => 'No hay tareas disponibles';

  @override
  String get tasksListRefresh => 'Actualizar';

  @override
  String get kanbanBoardTitle => 'Tablero Kanban';

  @override
  String get kanbanColumnPending => 'Pendientes';

  @override
  String get kanbanColumnInProgress => 'En Progreso';

  @override
  String get kanbanColumnUnderReview => 'En Revisión';

  @override
  String get kanbanColumnCompleted => 'Completadas';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get createTask => 'Crear Tarea';
}
