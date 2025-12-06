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
  String get loginError =>
      'Error de inicio de sesión. Por favor, verifica tus credenciales.';

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
  String get testCredentialsTitle => 'Credenciales de prueba';

  @override
  String get testCredentialsAdmin => '👨‍💼 Administrador';

  @override
  String get testCredentialsTutor => '👨‍🏫 Tutor';

  @override
  String get testCredentialsStudent => '👨‍🎓 Estudiante';

  @override
  String get copy => 'Copiar';

  @override
  String copiedToClipboard(String value) {
    return 'Copiado al portapapeles: $value';
  }

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
  String get timelineWillBeEstablishedByTutor =>
      'La temporalización será establecida por tu tutor asignado usando una herramienta de calendario.';

  @override
  String get downloadExamplePdf => 'Descargar ejemplo PDF';

  @override
  String get loadTemplate => 'Cargar Plantilla';

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
  String get viewAll => 'Ver todos';

  @override
  String get pendingAnteprojects => 'Anteproyectos Pendientes';

  @override
  String get assignedStudents => 'Estudiantes Asignados';

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
  String get dashboardAdminUsersManagement => 'Gestión de Usuarios';

  @override
  String get dashboardTutor => 'Dashboard de Tutor';

  @override
  String get dashboardAdmin => 'Dashboard de Administrador';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get noProjectsAvailableForTasks =>
      'No hay proyectos disponibles para crear tareas. Asegúrate de que tu anteproyecto esté aprobado.';

  @override
  String get mustSelectProjectForTask =>
      'Debe seleccionar un proyecto para crear la tarea';

  @override
  String get myProjects => 'Mis Proyectos';

  @override
  String get noProjectsAssigned =>
      'No tienes proyectos asignados. Contacta con tu tutor.';

  @override
  String get supabaseStudio => 'Supabase Studio';

  @override
  String get openSupabaseStudio => 'Abrir Supabase Studio';

  @override
  String get supabaseStudioDescription =>
      'Acceso directo al panel de administración de la base de datos';

  @override
  String get openInbucket => 'Abrir Inbucket';

  @override
  String get totalUsers => 'Usuarios Totales';

  @override
  String get activeProjects => 'Proyectos Activos';

  @override
  String get tutors => 'Tutores';

  @override
  String get noUsers => 'No hay usuarios';

  @override
  String get systemStatus => 'Estado del Sistema';

  @override
  String get close => 'Cerrar';

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
  String get validationError => 'Error de validación';

  @override
  String get formValidationError =>
      'Por favor, corrige los errores en el formulario';

  @override
  String get networkError => 'Error de red';

  @override
  String get networkErrorMessage =>
      'No se pudo conectar al servidor. Verifica tu conexión a internet.';

  @override
  String get serverError => 'Error del servidor';

  @override
  String get serverErrorMessage =>
      'El servidor no pudo procesar la solicitud. Inténtalo de nuevo más tarde.';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get unknownErrorMessage =>
      'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get fieldTooShort => 'Este campo es demasiado corto';

  @override
  String get fieldTooLong => 'Este campo es demasiado largo';

  @override
  String get invalidEmail => 'El formato del email no es válido';

  @override
  String get invalidUrl => 'La URL no tiene un formato válido';

  @override
  String get invalidNumber => 'El valor debe ser un número válido';

  @override
  String get invalidJson => 'El formato JSON no es válido';

  @override
  String get operationInProgress => 'Operación en progreso...';

  @override
  String get operationCompleted => 'Operación completada';

  @override
  String get operationFailed => 'La operación falló';

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
  String get taskReorderedSuccess => 'Tarea reordenada exitosamente';

  @override
  String get taskPositionUpdatedSuccess => 'Posición de tarea actualizada';

  @override
  String get movingTask => 'Moviendo...';

  @override
  String get taskStatusUpdatedNotification => 'Estado de tarea actualizado';

  @override
  String taskStatusChangedMessage(String taskTitle, String status) {
    return 'La tarea \"$taskTitle\" cambió a estado: $status';
  }

  @override
  String get taskAssignedNotification => 'Tarea asignada';

  @override
  String taskAssignedMessage(String taskTitle) {
    return 'Se te ha asignado la tarea: \"$taskTitle\"';
  }

  @override
  String get newCommentNotification => 'Nuevo comentario en tarea';

  @override
  String newCommentMessage(String taskTitle, String commentPreview) {
    return 'Nuevo comentario en \"$taskTitle\": $commentPreview';
  }

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get createTask => 'Crear Tarea';

  @override
  String get approvalWorkflow => 'Flujo de Aprobación';

  @override
  String get pendingApprovals => 'Aprobaciones Pendientes';

  @override
  String get reviewedAnteprojects => 'Anteproyectos Revisados';

  @override
  String get approveAnteproject => 'Aprobar Anteproyecto';

  @override
  String get rejectAnteproject => 'Rechazar Anteproyecto';

  @override
  String get requestChanges => 'Solicitar Cambios';

  @override
  String get approvalComments => 'Comentarios de Aprobación';

  @override
  String get approvalCommentsHint => 'Comentarios sobre la aprobación...';

  @override
  String get rejectionComments => 'Comentarios de Rechazo';

  @override
  String get rejectionCommentsHint => 'Motivo del rechazo...';

  @override
  String get changesComments => 'Comentarios sobre Cambios';

  @override
  String get changesCommentsHint =>
      'Especifica los cambios necesarios (obligatorio)';

  @override
  String get confirmApproval => 'Confirmar Aprobación';

  @override
  String get confirmRejection => 'Confirmar Rechazo';

  @override
  String get confirmChanges => 'Confirmar Solicitud de Cambios';

  @override
  String get approvalConfirmMessage =>
      '¿Estás seguro de que quieres aprobar este anteproyecto?';

  @override
  String get rejectionConfirmMessage =>
      '¿Estás seguro de que quieres rechazar este anteproyecto?';

  @override
  String get changesConfirmMessage =>
      '¿Estás seguro de que quieres solicitar cambios en este anteproyecto?';

  @override
  String get approvalSuccess => 'Anteproyecto aprobado exitosamente';

  @override
  String get rejectionSuccess => 'Anteproyecto rechazado exitosamente';

  @override
  String get changesSuccess => 'Cambios solicitados exitosamente';

  @override
  String get approvalError => 'Error al procesar la aprobación';

  @override
  String get noAnteprojectsToReview => 'No hay anteproyectos para revisar';

  @override
  String get noReviewedAnteprojects => 'No hay anteproyectos revisados';

  @override
  String get submittedOn => 'Enviado el';

  @override
  String get reviewedOn => 'Revisado el';

  @override
  String get tutorComments => 'Comentarios del Tutor';

  @override
  String get anteprojectStatus => 'Estado del Anteproyecto';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get processing => 'Procesando...';

  @override
  String get commentsRequired => 'Los comentarios son obligatorios';

  @override
  String get approve => 'Aprobar';

  @override
  String get reject => 'Rechazar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get retry => 'Reintentar';

  @override
  String get academicYear => 'Año Académico';

  @override
  String get noDataDescription =>
      'No hay información para mostrar en este momento';

  @override
  String get uploadFile => 'Subir Archivo';

  @override
  String get uploading => 'Subiendo...';

  @override
  String get upload => 'Subir';

  @override
  String get fileUploadedSuccessfully => 'Archivo subido correctamente';

  @override
  String get fileDeletedSuccessfully => 'Archivo eliminado correctamente';

  @override
  String get confirmDeleteFile => 'Confirmar Eliminación';

  @override
  String confirmDeleteFileMessage(String fileName) {
    return '¿Estás seguro de que deseas eliminar el archivo $fileName?';
  }

  @override
  String get openFile => 'Abrir Archivo';

  @override
  String get deleteFile => 'Eliminar Archivo';

  @override
  String get noFilesAttached => 'No hay archivos adjuntos';

  @override
  String get noFilesYet => 'Aún no hay archivos';

  @override
  String get uploadedBy => 'Subido por';

  @override
  String get clickToSelectFile => 'Haz clic para seleccionar un archivo';

  @override
  String get allowedFileTypes =>
      'Tipos permitidos: PDF, Word, TXT, Imágenes (JPG, PNG, GIF), ZIP, RAR';

  @override
  String maxFileSize(String size) {
    return 'Tamaño máximo: $size';
  }

  @override
  String get filesAttached => 'Archivos Adjuntos';

  @override
  String get attachFile => 'Adjuntar Archivo';

  @override
  String get taskDetails => 'Detalles de la Tarea';

  @override
  String get details => 'Detalles';

  @override
  String get tutorRole => 'Tutor';

  @override
  String get reviewed => 'Revisado:';

  @override
  String get addStudents => 'Añadir Estudiantes';

  @override
  String studentsAssignedInfo(int count, String plural, String year) {
    return 'Tienes $count estudiante$plural asignado$plural para $year';
  }

  @override
  String get myStudents => 'Mis Estudiantes';

  @override
  String get searchStudents => 'Buscar estudiantes...';

  @override
  String get noStudentsAssigned => 'No tienes estudiantes asignados';

  @override
  String get noStudentsFound => 'No se encontraron estudiantes';

  @override
  String get useDashboardButtons =>
      'Usa los botones del dashboard para añadir estudiantes';

  @override
  String get editStudent => 'Editar';

  @override
  String get deleteStudent => 'Eliminar';

  @override
  String get nre => 'NRE';

  @override
  String get phone => 'Teléfono';

  @override
  String get specialty => 'Especialidad';

  @override
  String get biography => 'Biografía';

  @override
  String get creationDate => 'Fecha de creación';

  @override
  String get studentDeletedSuccess => 'Estudiante eliminado exitosamente';

  @override
  String errorDeletingStudent(String error) {
    return 'Error al eliminar estudiante: $error';
  }

  @override
  String get confirmDeletion => 'Confirmar eliminación';

  @override
  String confirmDeleteStudent(String name) {
    return '¿Estás seguro de que quieres eliminar a $name?';
  }

  @override
  String get anteprojectsReview => 'Revisión de Anteproyectos';

  @override
  String get pendingAnteprojectsTitle => 'Anteproyectos Pendientes';

  @override
  String get reviewedAnteprojectsTitle => 'Anteproyectos Revisados';

  @override
  String get submittedAnteprojects => 'Anteproyectos Enviados';

  @override
  String get underReviewAnteprojects => 'Anteproyectos En Revisión';

  @override
  String get approvedAnteprojects => 'Anteproyectos Aprobados';

  @override
  String get rejectedAnteprojects => 'Anteproyectos Rechazados';

  @override
  String get all => 'Todos';

  @override
  String get searchAnteprojects => 'Buscar anteproyectos...';

  @override
  String get filterByStatus => 'Filtrar por estado:';

  @override
  String errorLoadingAnteprojects(String error) {
    return 'Error al cargar anteproyectos: $error';
  }

  @override
  String noAnteprojectsFound(String query) {
    return 'No se encontraron anteproyectos que coincidan con \"$query\"';
  }

  @override
  String noAnteprojectsWithStatus(String status) {
    return 'No hay anteproyectos con estado \"$status\"';
  }

  @override
  String get noAssignedAnteprojects =>
      'No tienes anteproyectos asignados para revisar';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get year => 'Año:';

  @override
  String get created => 'Creado:';

  @override
  String get submitted => 'Enviado:';

  @override
  String get lastUpdate => 'Última actualización:';

  @override
  String get dates => 'Fechas';

  @override
  String get reviewDates => 'Fechas de Revisión';

  @override
  String get projectMilestones => 'Hitos del Proyecto';

  @override
  String get comments => 'Comentarios';

  @override
  String get approveAnteprojectTitle => 'Aprobar Anteproyecto';

  @override
  String get rejectAnteprojectTitle => 'Rechazar Anteproyecto';

  @override
  String get confirmApproveAnteproject =>
      '¿Estás seguro de que quieres aprobar este anteproyecto?';

  @override
  String get confirmRejectAnteproject =>
      '¿Estás seguro de que quieres rechazar este anteproyecto?';

  @override
  String get approvalCommentsOptional => 'Comentarios (opcional)';

  @override
  String get anteprojectApprovedSuccess => 'Anteproyecto aprobado exitosamente';

  @override
  String get cannotCreateAnteprojectWithApprovedTitle =>
      'No puedes crear un nuevo anteproyecto';

  @override
  String get cannotCreateAnteprojectWithApproved =>
      'No puedes crear un nuevo anteproyecto porque ya tienes uno aprobado. Debes desarrollar el proyecto asociado.';

  @override
  String get goToProject => 'Ir al Proyecto';

  @override
  String get cannotSubmitAnteprojectWithApprovedTitle =>
      'No puedes enviar este anteproyecto';

  @override
  String get cannotSubmitAnteprojectWithApproved =>
      'No puedes enviar este anteproyecto porque ya tienes uno aprobado. Debes desarrollar el proyecto asociado.';

  @override
  String get anteprojectRejectedSuccess => 'Anteproyecto rechazado';

  @override
  String errorApprovingAnteproject(String error) {
    return 'Error al aprobar anteproyecto: $error';
  }

  @override
  String errorRejectingAnteproject(String error) {
    return 'Error al rechazar anteproyecto: $error';
  }

  @override
  String get pending => 'Pendiente';

  @override
  String get underReview => 'En Revisión';

  @override
  String get approved => 'Aprobado';

  @override
  String get rejected => 'Rechazado';

  @override
  String get status => 'Estado';

  @override
  String get anteprojectTitleLabel => 'Título del Anteproyecto';

  @override
  String get logoutTooltip => 'Cerrar sesión';

  @override
  String get quickAccess => 'Acceso Rápido';

  @override
  String get files => 'Archivos';

  @override
  String get recentActivity => 'Actividad Reciente';

  @override
  String get welcomeMessage => '¡Bienvenido!';

  @override
  String get welcomeDescription => 'Has iniciado sesión correctamente';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get getStartedDescription => 'Usa el menú lateral para navegar';

  @override
  String get createAnteprojectTooltip => 'Crear anteproyecto';

  @override
  String userId(String id) {
    return 'ID: $id';
  }

  @override
  String get studentRole => 'Estudiante';

  @override
  String get anteprojects => 'Anteproyectos';

  @override
  String get completed => 'Completadas';

  @override
  String get anteprojectApprovedMessage =>
      'Tu anteproyecto ha sido aprobado. ¡Puedes comenzar con el desarrollo!';

  @override
  String academicYearLabel(String year) {
    return 'Año: $year';
  }

  @override
  String statusLabel(String status) {
    return 'Estado: $status';
  }

  @override
  String get draft => 'Borrador';

  @override
  String get approvedStatus => 'Aprobado';

  @override
  String get rejectedStatus => 'Rechazado';

  @override
  String get unknown => 'Desconocido';

  @override
  String get inProgress => 'En Progreso';

  @override
  String get completedStatus => 'Completada';

  @override
  String get unknownStatus => 'Desconocido';

  @override
  String get studentCreatedSuccess => 'Alumno creado exitosamente';

  @override
  String errorCreatingStudent(String error) {
    return 'Error al crear estudiante: $error';
  }

  @override
  String get addStudent => 'Añadir Estudiante';

  @override
  String get fullName => 'Nombre Completo';

  @override
  String get nreLabel => 'NRE (Número de Registro de Estudiante)';

  @override
  String get phoneOptional => 'Teléfono (Opcional)';

  @override
  String get biographyOptional => 'Biografía (Opcional)';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get emailRequired => 'El email es obligatorio';

  @override
  String get emailInvalid => 'Email inválido';

  @override
  String get nreRequired => 'El NRE es obligatorio';

  @override
  String get createStudent => 'Crear Estudiante';

  @override
  String get studentUpdatedSuccess => 'Estudiante actualizado exitosamente';

  @override
  String errorUpdatingStudent(String error) {
    return 'Error al actualizar estudiante: $error';
  }

  @override
  String get updateStudent => 'Actualizar Estudiante';

  @override
  String get role => 'Rol';

  @override
  String get noProjectAssigned =>
      'No tienes un proyecto o anteproyecto asignado. Contacta con tu tutor.';

  @override
  String errorGettingProject(String error) {
    return 'Error al obtener proyecto: $error';
  }

  @override
  String get deleteAnteproject => 'Eliminar Anteproyecto';

  @override
  String confirmDeleteAnteproject(String title) {
    return '¿Estás seguro de que quieres eliminar el anteproyecto \"$title\"?\n\nEsta acción no se puede deshacer.';
  }

  @override
  String get anteprojectDeletedSuccess => 'Anteproyecto eliminado exitosamente';

  @override
  String errorDeletingAnteproject(String error) {
    return 'Error al eliminar anteproyecto: $error';
  }

  @override
  String get templateLoadedSuccess =>
      '✅ Plantilla cargada correctamente. Los 4 hitos de ejemplo han sido añadidos.';

  @override
  String errorGeneratingPDF(String error) {
    return 'Error al generar PDF: $error';
  }

  @override
  String get downloadExampleTitle => 'Descargar Ejemplo de Anteproyecto';

  @override
  String get downloadExampleMessage =>
      '¿Cómo deseas descargar el ejemplo de anteproyecto?';

  @override
  String get print => 'Imprimir';

  @override
  String pdfSavedAt(String path) {
    return 'PDF guardado en: $path';
  }

  @override
  String errorSaving(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get downloadExamplePDF => 'Descargar Ejemplo PDF';

  @override
  String errorLoadingSchedule(String error) {
    return 'Error al cargar cronograma: $error';
  }

  @override
  String get mustConfigureReviewDate =>
      'Debe configurar al menos una fecha de revisión';

  @override
  String get scheduleSavedSuccess => 'Cronograma guardado exitosamente';

  @override
  String errorSavingSchedule(String error) {
    return 'Error al guardar cronograma: $error';
  }

  @override
  String get scheduleManagement => 'Gestión de Cronograma';

  @override
  String get regenerateDatesBasedOnMilestones =>
      'Regenerar Fechas Basadas en Hitos';

  @override
  String get noMilestonesDefined => 'No se han definido hitos';

  @override
  String get anteprojectDetails => 'Detalles del Anteproyecto';

  @override
  String get editAnteproject => 'Editar Anteproyecto';

  @override
  String get anteprojectRejected => 'Anteproyecto rechazado';

  @override
  String get sendForApproval => 'Enviar para Aprobación';

  @override
  String get sendForApprovalTitle => 'Enviar para Aprobación';

  @override
  String get sendForApprovalMessage =>
      '¿Estás seguro de que quieres enviar este anteproyecto para aprobación? Una vez enviado, no podrás editarlo hasta que sea revisado.';

  @override
  String get send => 'Enviar';

  @override
  String get anteprojectSentForApproval =>
      'Anteproyecto enviado para aprobación exitosamente';

  @override
  String errorSendingAnteproject(String error) {
    return 'Error al enviar anteproyecto: $error';
  }

  @override
  String anteprojectTitle(String title) {
    return 'Anteproyecto: $title';
  }

  @override
  String errorLoadingComments(String error) {
    return 'Error al cargar comentarios: $error';
  }

  @override
  String get pleaseWriteComment => 'Por favor, escribe un comentario';

  @override
  String get commentAddedSuccess => 'Comentario agregado exitosamente';

  @override
  String errorAddingComment(String error) {
    return 'Error al agregar comentario: $error';
  }

  @override
  String commentsTitle(String title) {
    return 'Comentarios - $title';
  }

  @override
  String copied(String text) {
    return 'Copiado: $text';
  }

  @override
  String get addIndividually => 'Añadir Individualmente';

  @override
  String get importFromCSV => 'Importar desde CSV';

  @override
  String errorLoadingNotifications(String error) {
    return 'Error al cargar notificaciones: $error';
  }

  @override
  String errorMarkingAsRead(String error) {
    return 'Error marcando como leída: $error';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Todas las notificaciones marcadas como leídas';

  @override
  String errorMarkingAllAsRead(String error) {
    return 'Error al marcar todas como leídas: $error';
  }

  @override
  String errorDeletingNotification(String error) {
    return 'Error al eliminar notificación: $error';
  }

  @override
  String get notifications => 'Notificaciones';

  @override
  String errorLoadingStudents(String error) {
    return 'Error al cargar estudiantes: $error';
  }

  @override
  String dashboardTitle(String name) {
    return 'Dashboard - $name';
  }

  @override
  String get allYears => 'Todos los años';

  @override
  String errorSelectingFile(String error) {
    return 'Error al seleccionar archivo: $error';
  }

  @override
  String get noValidDataToImport => 'No hay datos válidos para importar';

  @override
  String importCompleted(int success, int error) {
    return 'Importación completada: $success exitosos, $error errores';
  }

  @override
  String errorDuringImport(String error) {
    return 'Error durante la importación: $error';
  }

  @override
  String get importStudentsCSV => 'Importar Estudiantes CSV';

  @override
  String get fullNameRequired => '• full_name (obligatorio)';

  @override
  String get specialtyOptional => '• specialty (opcional)';

  @override
  String get academicYearOptional => '• academic_year (opcional)';

  @override
  String get selectCSVFile => 'Seleccionar Archivo CSV';

  @override
  String importStudents(int count) {
    return 'Importar $count Estudiantes';
  }

  @override
  String get importing => 'Importando...';

  @override
  String get studentsImportedSuccess => 'Estudiantes importados exitosamente';

  @override
  String get creating => 'Creando...';

  @override
  String get createTutor => 'Crear Tutor';

  @override
  String get tutorCreatedSuccess => 'Tutor creado exitosamente';

  @override
  String errorUploadingFile(String error) {
    return 'Error al subir archivo: $error';
  }

  @override
  String errorLoadingFiles(String error) {
    return 'Error al cargar archivos: $error';
  }

  @override
  String errorDeletingFile(String error) {
    return 'Error al eliminar archivo: $error';
  }

  @override
  String errorOpeningFile(String error) {
    return 'Error al abrir archivo: $error';
  }

  @override
  String estimatedHours(int hours) {
    return '${hours}h';
  }

  @override
  String confirmDeleteTask(String title) {
    return '¿Estás seguro de que quieres eliminar la tarea \"$title\"?';
  }

  @override
  String get mustLoginToViewComments =>
      'Debes iniciar sesión para ver los comentarios';

  @override
  String get permissionRequired => 'Permisos Requeridos';

  @override
  String get permissionRequiredMessage =>
      'Esta aplicación necesita acceso al almacenamiento para seleccionar archivos. Por favor, concede los permisos necesarios.';

  @override
  String get openSettings => 'Abrir Configuración';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get fileSavedSuccessfully => 'Archivo guardado con éxito';

  @override
  String errorPrinting(String error) {
    return 'Error al imprimir: $error';
  }

  @override
  String get selectProjectForTasks => 'Selecciona el proyecto';

  @override
  String get projectDetails => 'Detalles del Proyecto';

  @override
  String get anteprojectHistoryComments =>
      'Comentarios del Anteproyecto (Histórico)';

  @override
  String get projectComments => 'Comentarios del Proyecto';

  @override
  String get attachedFiles => 'Archivos Adjuntos';

  @override
  String get kanbanBoard => 'Tablero Kanban';

  @override
  String get kanbanOnlyForProjects =>
      'El tablero Kanban solo está disponible para proyectos aprobados';

  @override
  String get anteprojectNotFound =>
      'No se encontró el anteproyecto asociado al proyecto';

  @override
  String get tasksList => 'Lista de Tareas';

  @override
  String get errorNetworkTimeout =>
      'La conexión tardó demasiado. Por favor, verifica tu conexión a internet e inténtalo de nuevo.';

  @override
  String get errorNetworkNoInternet =>
      'No hay conexión a internet. Por favor, verifica tu conexión e inténtalo de nuevo.';

  @override
  String get errorNetworkServerUnavailable =>
      'El servidor no está disponible en este momento. Por favor, inténtalo más tarde.';

  @override
  String get errorNetworkDnsError =>
      'No se pudo resolver la dirección del servidor. Verifica tu conexión a internet.';

  @override
  String get errorNetworkConnectionLost =>
      'Se perdió la conexión. Por favor, verifica tu conexión a internet.';

  @override
  String get errorNetworkRequestFailed =>
      'La solicitud falló. Por favor, inténtalo de nuevo.';

  @override
  String get errorNotAuthenticated =>
      'Debes iniciar sesión para realizar esta acción.';

  @override
  String get errorInvalidCredentials =>
      'Las credenciales son incorrectas. Por favor, verifica tu email y contraseña.';

  @override
  String get errorSessionExpired =>
      'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';

  @override
  String get errorProfileNotFound =>
      'No se pudo encontrar tu perfil de usuario. Por favor, contacta con soporte.';

  @override
  String get errorAccountDisabled =>
      'Tu cuenta está deshabilitada. Por favor, contacta con el administrador.';

  @override
  String get errorEmailNotVerified =>
      'Tu email no ha sido verificado. Por favor, revisa tu bandeja de entrada.';

  @override
  String get errorPasswordTooWeak =>
      'La contraseña es demasiado débil. Debe tener al menos 8 caracteres.';

  @override
  String get errorLoginAttemptsExceeded =>
      'Demasiados intentos de inicio de sesión. Inténtalo más tarde.';

  @override
  String get errorRateLimitExceeded =>
      'Demasiadas solicitudes. Por seguridad, debes esperar unos segundos antes de intentar crear otro usuario. Por favor, espera un momento e inténtalo de nuevo.';

  @override
  String get errorRateLimitEmailSent =>
      'Se ha alcanzado el límite de solicitudes. Si se envió un email de verificación pero el usuario no se creó completamente, el administrador deberá limpiar manualmente el usuario desde Supabase Dashboard.';

  @override
  String get errorEmailAlreadyRegistered =>
      'Este correo electrónico ya está registrado. Si acabas de eliminar un usuario con este correo, por favor espera unos minutos antes de intentar crear otro usuario con el mismo email. Supabase requiere un período de espera antes de permitir reutilizar un email.';

  @override
  String get errorFieldRequired => 'Este campo es obligatorio.';

  @override
  String get errorFieldTooShort => 'Este campo es demasiado corto.';

  @override
  String get errorFieldTooLong => 'Este campo es demasiado largo.';

  @override
  String get errorInvalidEmail => 'El formato del email no es válido.';

  @override
  String get errorInvalidUrl => 'La URL no tiene un formato válido.';

  @override
  String get errorInvalidNumber => 'El valor debe ser un número válido.';

  @override
  String get errorInvalidJson => 'El formato JSON no es válido.';

  @override
  String get errorInvalidDate => 'La fecha no tiene un formato válido.';

  @override
  String get errorInvalidFileType => 'El tipo de archivo no está permitido.';

  @override
  String get errorInvalidFileSize => 'El archivo es demasiado grande.';

  @override
  String get errorMissingTaskContext =>
      'Debe seleccionar un proyecto para crear la tarea.';

  @override
  String get errorInvalidProjectRelation =>
      'La relación con el proyecto no es válida.';

  @override
  String get errorAccessDenied =>
      'No tienes permisos para realizar esta acción.';

  @override
  String get errorInsufficientPermissions =>
      'No tienes suficientes permisos para realizar esta acción.';

  @override
  String get errorOperationNotAllowed => 'Esta operación no está permitida.';

  @override
  String get errorResourceNotFound =>
      'El recurso solicitado no fue encontrado.';

  @override
  String get errorCannotDeleteCompletedTask =>
      'No se puede eliminar una tarea completada.';

  @override
  String get errorCannotEditApprovedAnteproject =>
      'No se puede editar un anteproyecto aprobado.';

  @override
  String get errorDatabaseConnectionFailed =>
      'No se pudo conectar a la base de datos. Inténtalo más tarde.';

  @override
  String get errorDatabaseQueryFailed =>
      'La consulta a la base de datos falló. Inténtalo de nuevo.';

  @override
  String get errorDatabaseConstraintViolation =>
      'Los datos no cumplen con las reglas de la base de datos.';

  @override
  String get errorDatabaseDuplicateEntry =>
      'Ya existe un registro con estos datos.';

  @override
  String get errorDatabaseForeignKeyViolation =>
      'No se puede realizar la operación debido a dependencias de datos.';

  @override
  String get errorDatabaseUnknownError =>
      'Ocurrió un error en la base de datos. Inténtalo más tarde.';

  @override
  String get errorDatabaseTimeout =>
      'La operación tardó demasiado. Inténtalo de nuevo.';

  @override
  String get errorFileUploadFailed =>
      'No se pudo subir el archivo. Inténtalo de nuevo.';

  @override
  String get errorFileDownloadFailed =>
      'No se pudo descargar el archivo. Inténtalo de nuevo.';

  @override
  String get errorFileDeleteFailed =>
      'No se pudo eliminar el archivo. Inténtalo de nuevo.';

  @override
  String get errorFileNotFound => 'El archivo no fue encontrado.';

  @override
  String errorFileSizeExceeded(String maxSize) {
    return 'El archivo es demasiado grande. El tamaño máximo es $maxSize.';
  }

  @override
  String errorFileTypeNotAllowed(String allowedTypes) {
    return 'El tipo de archivo no está permitido. Tipos permitidos: $allowedTypes.';
  }

  @override
  String get errorFileCorrupted => 'El archivo está corrupto o dañado.';

  @override
  String get errorFilePermissionDenied =>
      'No tienes permisos para acceder a este archivo.';

  @override
  String get errorInvalidState =>
      'El estado actual no permite realizar esta operación.';

  @override
  String get errorOperationNotSupported => 'Esta operación no está soportada.';

  @override
  String get errorResourceAlreadyExists =>
      'Ya existe un recurso con estos datos.';

  @override
  String get errorResourceInUse =>
      'El recurso está siendo utilizado y no se puede modificar.';

  @override
  String get errorWorkflowViolation =>
      'Esta operación no está permitida en el flujo actual.';

  @override
  String get errorBusinessRuleViolation =>
      'La operación viola una regla de negocio.';

  @override
  String get errorQuotaExceeded => 'Has excedido el límite permitido.';

  @override
  String get errorDeadlineExceeded => 'Se ha excedido el plazo límite.';

  @override
  String get errorConfigurationMissing =>
      'Falta configuración requerida. Contacta con soporte.';

  @override
  String get errorConfigurationInvalid =>
      'La configuración no es válida. Contacta con soporte.';

  @override
  String get errorServiceUnavailable =>
      'El servicio no está disponible. Inténtalo más tarde.';

  @override
  String get errorMaintenanceMode =>
      'El sistema está en mantenimiento. Inténtalo más tarde.';

  @override
  String get errorExternalServiceTimeout =>
      'El servicio externo tardó demasiado en responder.';

  @override
  String get errorExternalServiceError =>
      'El servicio externo no está funcionando correctamente.';

  @override
  String get errorEmailServiceUnavailable =>
      'El servicio de email no está disponible.';

  @override
  String get errorNotificationServiceUnavailable =>
      'El servicio de notificaciones no está disponible.';

  @override
  String get errorUnknown =>
      'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.';

  @override
  String get errorUnexpected =>
      'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.';

  @override
  String get errorInternal =>
      'Ha ocurrido un error interno. Por favor, contacta con soporte.';

  @override
  String get errorNetworkGeneric =>
      'Error de conexión. Por favor, verifica tu conexión a internet.';

  @override
  String get errorAuthenticationGeneric =>
      'Error de autenticación. Por favor, inicia sesión nuevamente.';

  @override
  String get errorValidationGeneric =>
      'Error de validación. Por favor, revisa los datos ingresados.';

  @override
  String get errorPermissionGeneric =>
      'No tienes permisos para realizar esta acción.';

  @override
  String get errorDatabaseGeneric =>
      'Error de base de datos. Inténtalo más tarde.';

  @override
  String get errorFileGeneric => 'Error de archivo. Inténtalo de nuevo.';

  @override
  String get errorBusinessLogicGeneric =>
      'Error de lógica de negocio. La operación no se puede completar.';

  @override
  String get errorConfigurationGeneric =>
      'Error de configuración. Contacta con soporte.';

  @override
  String get errorExternalServiceGeneric =>
      'Error de servicio externo. Inténtalo más tarde.';

  @override
  String get errorTitleNetwork => 'Error de Conexión';

  @override
  String get errorTitleAuthentication => 'Error de Autenticación';

  @override
  String get errorTitleValidation => 'Error de Validación';

  @override
  String get errorTitlePermission => 'Error de Permisos';

  @override
  String get errorTitleDatabase => 'Error de Base de Datos';

  @override
  String get errorTitleFile => 'Error de Archivo';

  @override
  String get errorTitleBusinessLogic => 'Error de Lógica de Negocio';

  @override
  String get errorTitleConfiguration => 'Error de Configuración';

  @override
  String get errorTitleExternalService => 'Error de Servicio Externo';

  @override
  String get errorTitleUnknown => 'Error Desconocido';

  @override
  String get errorActionNetwork => 'Verificar conexión a internet';

  @override
  String get errorActionAuthentication => 'Iniciar sesión nuevamente';

  @override
  String get errorActionValidation => 'Revisar los datos ingresados';

  @override
  String get errorActionPermission => 'Contactar con el administrador';

  @override
  String get errorActionDatabase => 'Intentar más tarde';

  @override
  String get errorActionFile => 'Seleccionar otro archivo';

  @override
  String get errorActionBusinessLogic => 'Verificar el estado del recurso';

  @override
  String get errorActionConfiguration => 'Contactar con soporte técnico';

  @override
  String get errorActionExternalService => 'Intentar más tarde';

  @override
  String get errorActionUnknown => 'Intentar de nuevo o contactar soporte';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get resetPassword => 'Restablecer Contraseña';

  @override
  String get resetPasswordInstructions =>
      'Ingresa tu nueva contraseña para restablecer el acceso a tu cuenta.';

  @override
  String get resetPasswordRequestSent => 'Solicitud enviada a tu tutor';

  @override
  String resetPasswordRequestSentDescription(String tutorName) {
    return 'Tu tutor $tutorName recibirá una notificación para generar una nueva contraseña temporal. Te enviaremos un email con la nueva contraseña una vez que tu tutor la haya generado.';
  }

  @override
  String get userNotFound => 'No se encontró un usuario con ese email';

  @override
  String get setupPassword => 'Establecer Contraseña';

  @override
  String get setupPasswordInstructions =>
      'Establece tu contraseña personal para acceder al sistema. Esta será tu contraseña de acceso.';

  @override
  String get sendResetLink => 'Enviar Enlace de Recuperación';

  @override
  String get resetLinkSent =>
      'Se ha enviado un enlace de recuperación a tu correo electrónico.';

  @override
  String get newPassword => 'Nueva Contraseña';

  @override
  String get confirmNewPassword => 'Confirmar Nueva Contraseña';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get passwordChanged => 'Contraseña actualizada exitosamente';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get passwordRequired => 'La contraseña es obligatoria';

  @override
  String get userCreatedSuccess =>
      'Usuario creado exitosamente. Se ha enviado un email de verificación.';

  @override
  String get userCreatedInstructions =>
      'El usuario recibirá un email de verificación. Después de verificar su email, deberá usar la opción \'¿Olvidaste tu contraseña?\' para establecer su contraseña personal.';

  @override
  String resetPasswordForStudent(String studentName) {
    return 'Restablecer contraseña para $studentName';
  }

  @override
  String get generatePasswordAutomatically =>
      'Generar contraseña automáticamente';

  @override
  String get regeneratePassword => 'Regenerar';

  @override
  String get passwordResetSuccess => 'Contraseña restablecida exitosamente';

  @override
  String get passwordResetNotificationSent =>
      'Se ha enviado una notificación al estudiante con la nueva contraseña.';

  @override
  String passwordResetError(String error) {
    return 'Error al resetear contraseña: $error';
  }

  @override
  String get studentCreatedWithPassword =>
      'El estudiante ha sido creado con la contraseña establecida. Puede iniciar sesión inmediatamente.';

  @override
  String get messages => 'Mensajes';

  @override
  String get tutorMessages => 'Mensajes de Estudiantes';

  @override
  String get studentMessages => 'Mensajes con el Tutor';

  @override
  String get helpGuide => 'Guía de Uso';

  @override
  String get systemSettings => 'Configuración del Sistema';

  @override
  String get settings => 'Configuración';

  @override
  String get selectProjectOrAnteprojectMessage =>
      'Selecciona un proyecto o anteproyecto para ver o responder mensajes de tus estudiantes';

  @override
  String get waitForStudentsAssignment =>
      'Espera a que te asignen estudiantes\ncon proyectos o anteproyectos';

  @override
  String get allTypes => 'Todos los tipos';

  @override
  String get filterByType => 'Filtrar por tipo';

  @override
  String get markAllAsRead => 'Marcar todas como leídas';

  @override
  String get myNotifications => 'Mis Notificaciones';

  @override
  String get system => 'Sistema';

  @override
  String get notificationDeleted => 'Notificación eliminada';

  @override
  String errorDeleting(String error) {
    return 'Error eliminando: $error';
  }

  @override
  String get noNotifications => 'No hay notificaciones';

  @override
  String get noNotificationsOfThisType => 'No hay notificaciones de este tipo';

  @override
  String get privateCommunicationsPrivacy =>
      'Las comunicaciones privadas entre usuarios no se muestran por protección de datos.';

  @override
  String get viewMessages => 'Ver mensajes';

  @override
  String get update => 'Actualizar';

  @override
  String get updateList => 'Actualizar lista';

  @override
  String get updateMessages => 'Actualizar mensajes';

  @override
  String get updateComments => 'Actualizar comentarios';

  @override
  String get now => 'Ahora';

  @override
  String agoDays(num days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    return 'Hace $daysString día';
  }

  @override
  String agoDaysPlural(num days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    return 'Hace $daysString días';
  }

  @override
  String agoHours(num hours) {
    final intl.NumberFormat hoursNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String hoursString = hoursNumberFormat.format(hours);

    return 'Hace $hoursString hora';
  }

  @override
  String agoHoursPlural(num hours) {
    final intl.NumberFormat hoursNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String hoursString = hoursNumberFormat.format(hours);

    return 'Hace $hoursString horas';
  }

  @override
  String agoMinutes(num minutes) {
    final intl.NumberFormat minutesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'Hace $minutesString minuto';
  }

  @override
  String agoMinutesPlural(num minutes) {
    final intl.NumberFormat minutesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'Hace $minutesString minutos';
  }

  @override
  String agoDaysShort(num days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    return 'Hace ${daysString}d';
  }

  @override
  String agoHoursShort(num hours) {
    final intl.NumberFormat hoursNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String hoursString = hoursNumberFormat.format(hours);

    return 'Hace ${hoursString}h';
  }

  @override
  String agoMinutesShort(num minutes) {
    final intl.NumberFormat minutesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'Hace ${minutesString}m';
  }

  @override
  String get projectQueriesMessage =>
      'Aquí puedes hacer consultas sobre tu proyecto';

  @override
  String get anteprojectQueriesMessage =>
      'Aquí puedes hacer consultas sobre tu anteproyecto';

  @override
  String get selectProjectOrAnteprojectToStartConversation =>
      'Selecciona un proyecto o anteproyecto para iniciar o continuar una conversación con tu tutor';

  @override
  String get noActiveProjects => 'No tienes proyectos activos';

  @override
  String get createAnteprojectToChat =>
      'Crea un anteproyecto para poder\nconversar con tu tutor';

  @override
  String get approvedProjects => 'Proyectos Aprobados';

  @override
  String get projectInDevelopment => 'Proyecto en desarrollo';

  @override
  String get viewComments => 'Ver comentarios';

  @override
  String get manageSchedule => 'Gestionar Cronograma';

  @override
  String get newUser => 'Nuevo Usuario';

  @override
  String get userDeleted => 'Usuario Eliminado';

  @override
  String get systemError => 'Error del Sistema';

  @override
  String get securityAlert => 'Alerta de Seguridad';

  @override
  String get settingsChanged => 'Configuración Cambiada';

  @override
  String get backupCompleted => 'Copia de Seguridad';

  @override
  String get bulkOperation => 'Operación Masiva';

  @override
  String get systemMaintenance => 'Mantenimiento';

  @override
  String get announcement => 'Anuncio';

  @override
  String get systemNotification => 'Notificación del Sistema';

  @override
  String get comment => 'Comentario';

  @override
  String get messageInAnteproject => 'Mensaje en Anteproyecto';

  @override
  String get messageInProject => 'Mensaje en Proyecto';

  @override
  String get passwordResetRequest => 'Solicitud de Restablecimiento';

  @override
  String get taskAssigned => 'Tarea Asignada';

  @override
  String get statusChanged => 'Estado Cambiado';

  @override
  String get conversations => 'Conversaciones';

  @override
  String get newTopic => 'Nuevo tema';

  @override
  String get writeMessage => 'Escribe un mensaje...';

  @override
  String get noConversationsYet => 'No hay conversaciones aún';

  @override
  String get createNewTopicToStart =>
      'Crea un nuevo tema para empezar\na conversar con tu tutor';

  @override
  String get useButtonBelow => '👇 Usa el botón de abajo 👇';

  @override
  String errorLoadingConversations(String error) {
    return 'Error al cargar conversaciones: $error';
  }

  @override
  String get newConversationTopic => 'Nuevo tema de conversación';

  @override
  String get createNewTopicToOrganize =>
      'Crea un nuevo tema para organizar tu conversación con el tutor.';

  @override
  String get topicTitle => 'Título del tema';

  @override
  String get topicTitleHint => 'Ej: Dudas sobre la metodología';

  @override
  String get topicTitleHelper => 'Describe brevemente el tema a tratar';

  @override
  String get pleaseEnterTitle => 'Por favor ingresa un título';

  @override
  String get titleMinLength => 'El título debe tener al menos 3 caracteres';

  @override
  String get topicTitleTip =>
      'Tip: Usa títulos descriptivos como \"Dudas Cap. 3\" o \"Revisión de código\"';

  @override
  String get createTopic => 'Crear tema';

  @override
  String errorSendingMessage(String error) {
    return 'Error al enviar mensaje: $error';
  }

  @override
  String get noCommentsYet => 'No hay comentarios aún';

  @override
  String get beFirstToComment => 'Sé el primero en comentar este anteproyecto';

  @override
  String get commentsWillAppearHere =>
      'Los comentarios aparecerán aquí cuando el tutor los agregue';

  @override
  String viewMoreComments(int count) {
    return 'Ver $count comentarios más';
  }

  @override
  String get internal => 'Interno';

  @override
  String editedOn(String date) {
    return 'Editado el $date';
  }

  @override
  String get section => 'Sección:';

  @override
  String get internalCommentLabel =>
      'Comentario interno (solo visible para tutores)';

  @override
  String get commentAddedSuccessfully => 'Comentario agregado exitosamente';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionDescription => 'Descripción';

  @override
  String get sectionObjectives => 'Objetivos';

  @override
  String get sectionExpectedResults => 'Resultados Esperados';

  @override
  String get sectionTimeline => 'Temporalización';

  @override
  String get sectionMethodology => 'Metodología';

  @override
  String get sectionResources => 'Recursos';

  @override
  String get sectionOther => 'Otros';

  @override
  String get generalInformation => 'Información General';
}
