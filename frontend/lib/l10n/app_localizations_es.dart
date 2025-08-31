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
  String loginError(String error) {
    return '❌ Error: $error';
  }

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
  String get connectionError => 'Error de conexión. Por favor, verifica tu conexión a internet.';

  @override
  String get serverInfo => 'Información del Servidor';

  @override
  String get serverUrl => 'URL del Servidor';

  @override
  String get platform => 'Plataforma';

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
  String get copyToClipboard => 'Copiar al portapapeles';

  @override
  String get copied => '¡Copiado!';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get settings => 'Configuración';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String get dashboardStudent => 'Dashboard Estudiante';

  @override
  String welcomeUser(String email) {
    return 'Bienvenido, $email';
  }

  @override
  String get myAnteprojects => 'Mis Anteproyectos';

  @override
  String get viewAll => 'Ver todos';

  @override
  String get noAnteprojects => 'No tienes anteproyectos creados. ¡Crea tu primer anteproyecto!';

  @override
  String get pendingTasks => 'Tareas Pendientes';

  @override
  String get viewAllTasks => 'Ver todas';

  @override
  String get noPendingTasks => 'No tienes tareas pendientes. ¡Excelente trabajo!';

  @override
  String get systemInfo => 'Información del Sistema';

  @override
  String get connectedToServer => 'Estado: Conectado al servidor de red';

  @override
  String get anteprojectsDev => 'Funcionalidad de creación de anteproyectos en desarrollo';

  @override
  String get anteprojectsListDev => 'Lista de anteproyectos en desarrollo';

  @override
  String get tasksListDev => 'Lista de tareas en desarrollo';

  @override
  String platformLabel(String platform) {
    return 'Plataforma: $platform';
  }

  @override
  String versionLabel(String version) {
    return 'Versión: $version';
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
    return '✅ Login exitoso en $platform!';
  }

  @override
  String get loginSuccessTitle => '✅ Login Exitoso';

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
    return 'Rol: $role';
  }

  @override
  String createdInfo(String date) {
    return 'Creado: $date';
  }

  @override
  String get nextSteps => 'Próximos pasos:';

  @override
  String get navigationRoles => '• Navegación por roles';

  @override
  String get personalDashboard => '• Dashboard personalizado';

  @override
  String get anteprojectsManagement => '• Gestión de anteproyectos';

  @override
  String get continueButton => 'Continuar';

  @override
  String get tutorDashboardDev => 'Dashboard de tutor en desarrollo';

  @override
  String get adminDashboardDev => 'Dashboard de admin en desarrollo';

  @override
  String get roleNotSpecified => 'No especificado';
}
