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
  String get email => 'Email';

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
  String anteprojectTitle(String title) {
    return 'Anteproyecto: $title';
  }

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

  @override
  String get anteprojectsListInDevelopment =>
      'Lista de anteproyectos en desarrollo';

  @override
  String get studentsListInDevelopment => 'Lista de estudiantes en desarrollo';

  @override
  String get userManagementInDevelopment =>
      'Panel de gestión de usuarios en desarrollo';

  @override
  String get systemStatusInDevelopment =>
      'Estado detallado del sistema en desarrollo';

  @override
  String get usersListInDevelopment => 'Lista de usuarios en desarrollo';

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
  String get close => 'Cerrar';

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
  String get approveAnteproject => 'Aprobar';

  @override
  String get rejectAnteproject => 'Rechazar';

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
  String get reviewed => 'Revisados';

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
  String get editStudent => 'Editar Estudiante';

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
  String get submitted => 'Enviado';

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
  String get approved => 'APROBADO';

  @override
  String get rejected => 'Rechazado';

  @override
  String get status => 'Estado';

  @override
  String get anteprojectTitleLabel => 'Título del Anteproyecto';

  @override
  String get logoutTooltip => 'Cerrar sesión';

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
  String get studentCreatedSuccess => 'Estudiante creado exitosamente';

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
}
