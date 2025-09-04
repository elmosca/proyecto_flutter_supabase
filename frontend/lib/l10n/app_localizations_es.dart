// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Sistema de Gestión TFG';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get dashboard => 'Panel Principal';

  @override
  String get projects => 'Proyectos';

  @override
  String get tasks => 'Tareas';

  @override
  String get profile => 'Perfil';

  @override
  String get logout => 'Cerrar Sesión';

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
  String get anteprojectExpectedResultsHint => 'Ejemplo milestone1 Descripción';

  @override
  String get anteprojectTimelineHint => 'Ejemplo phase1 Descripción';

  @override
  String get dashboardStudent => 'Dashboard Estudiante';

  @override
  String get myAnteprojects => 'Mis Anteproyectos';

  @override
  String get viewAll => 'Ver todos';

  @override
  String get noAnteprojects =>
      'No tienes anteproyectos creados. ¡Crea tu primer anteproyecto!';

  @override
  String get pendingTasks => 'Tareas Pendientes';

  @override
  String get viewAllTasks => 'Ver todas';

  @override
  String get noPendingTasks =>
      'No tienes tareas pendientes. ¡Excelente trabajo!';

  @override
  String get systemInfo => 'Información del Sistema';

  @override
  String backendLabel(String url) {
    return 'Backend: $url';
  }

  @override
  String platformLabel(String platform) {
    return 'Plataforma: $platform';
  }

  @override
  String versionLabel(String version) {
    return 'Versión: $version';
  }

  @override
  String get emailLabel => 'Email';

  @override
  String get connectedToServer => 'Estado: Conectado al servidor de red';

  @override
  String get tasksListDev => 'Lista de tareas en desarrollo';

  @override
  String get adminDashboardDev => 'Dashboard de admin en desarrollo';

  @override
  String get dashboardAdminUsersManagement => 'Gestión de Usuarios';

  @override
  String get tutorDashboardDev => 'Dashboard de tutor en desarrollo';

  @override
  String get dashboardTutorMyAnteprojects => 'Mis Anteproyectos';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get serverInfo => 'Información del Servidor';

  @override
  String get serverUrl => 'URL del Servidor';

  @override
  String get version => 'Versión';

  @override
  String get testCredentials => 'Credenciales de Prueba';

  @override
  String get studentEmail => 'Correo del Estudiante';

  @override
  String get tutorEmail => 'Correo del Tutor';

  @override
  String get adminEmail => 'Correo del Administrador';

  @override
  String get testPassword => 'Contraseña de Prueba';

  @override
  String get studio => 'Studio';

  @override
  String get loginSuccessTitle => '✅ Login Exitoso';

  @override
  String get copyToClipboard => 'Copiar al portapapeles';

  @override
  String get copied => '¡Copiado!';
}
