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
  String get loginError => 'Login error';

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
  String get testCredentialsTitle => 'Test credentials';

  @override
  String get testCredentialsAdmin => '👨‍💼 Admin';

  @override
  String get testCredentialsTutor => '👨‍🏫 Tutor';

  @override
  String get testCredentialsStudent => '👨‍🎓 Student';

  @override
  String get copy => 'Copy';

  @override
  String copiedToClipboard(String value) {
    return 'Copied to clipboard: $value';
  }

  @override
  String get delete => 'Delete';

  @override
  String get create => 'Create';

  @override
  String get search => 'Search';

  @override
  String get noData => 'No data available';

  @override
  String get connectionError => 'Connection error';

  @override
  String get anteprojectFormTitle => 'Create Anteproject';

  @override
  String get anteprojectEditFormTitle => 'Edit Anteproject';

  @override
  String get anteprojectType => 'Project Type';

  @override
  String get anteprojectDescription => 'Description';

  @override
  String get anteprojectAcademicYear => 'Academic Year (e.g., 2024-2025)';

  @override
  String get anteprojectExpectedResults => 'Expected Results (JSON)';

  @override
  String get anteprojectTimeline => 'Timeline (JSON)';

  @override
  String get anteprojectTutorId => 'Tutor ID';

  @override
  String get anteprojectCreateButton => 'Create Anteproject';

  @override
  String get anteprojectUpdateButton => 'Update anteproyecto';

  @override
  String get anteprojectDeleteButton => 'Delete';

  @override
  String get anteprojectDeleteTitle => 'Delete Anteproject';

  @override
  String get anteprojectDeleteMessage =>
      'Are you sure you want to delete this anteproyecto? This action cannot be undone.';

  @override
  String get anteprojectCreatedSuccess => 'Anteproject created successfully';

  @override
  String get timelineWillBeEstablishedByTutor =>
      'The timeline will be established by your assigned tutor using a calendar tool.';

  @override
  String get downloadExamplePdf => 'Download example PDF';

  @override
  String get loadTemplate => 'Load Template';

  @override
  String get anteprojectUpdatedSuccess => 'Anteproject updated successfully';

  @override
  String get anteprojectInvalidTutorId => 'Invalid Tutor ID';

  @override
  String get anteprojectTitleRequired => 'Title is required';

  @override
  String get anteprojectDescriptionRequired => 'Description is required';

  @override
  String get anteprojectAcademicYearRequired => 'Academic year is required';

  @override
  String get anteprojectTutorIdRequired => 'Tutor ID is required';

  @override
  String get anteprojectTutorIdNumeric => 'Tutor ID must be numeric';

  @override
  String get anteprojectsListTitle => 'My Anteprojects';

  @override
  String get anteprojectsListRefresh => 'Refresh list';

  @override
  String get anteprojectsListError => 'Error loading anteproyectos';

  @override
  String get anteprojectsListRetry => 'Retry';

  @override
  String get anteprojectsListEmpty => 'You have no anteproyectos';

  @override
  String get anteprojectsListEmptySubtitle =>
      'Create your first anteproyecto to get started';

  @override
  String get anteprojectsListUnknownState => 'Unknown state';

  @override
  String get anteprojectsListEdit => 'Edit';

  @override
  String get anteprojectDeleteTooltip => 'Delete anteproyecto';

  @override
  String get commentsAddComment => 'Add comment';

  @override
  String get commentsWriteComment => 'Write your comment...';

  @override
  String get commentsSend => 'Send';

  @override
  String get commentsCancel => 'Cancel';

  @override
  String get commentsInternal => 'Internal comment';

  @override
  String get commentsPublic => 'Public comment';

  @override
  String get commentsNoComments => 'No comments';

  @override
  String get commentsAddFirst => 'Be the first to comment';

  @override
  String get commentsError => 'Error loading comments';

  @override
  String get commentsErrorAdd => 'Error adding comment';

  @override
  String get commentsSuccess => 'Comment added successfully';

  @override
  String get commentsDelete => 'Delete comment';

  @override
  String get commentsDeleteConfirm =>
      'Are you sure you want to delete this comment?';

  @override
  String get commentsEdit => 'Edit comment';

  @override
  String get commentsSave => 'Save changes';

  @override
  String get commentsAuthor => 'Author';

  @override
  String get commentsDate => 'Date';

  @override
  String get commentsContent => 'Content';

  @override
  String get commentsContentRequired => 'Comment content is required';

  @override
  String get commentsContentMinLength =>
      'Comment must be at least 3 characters';

  @override
  String get commentsContentMaxLength =>
      'Comment cannot exceed 1000 characters';

  @override
  String get unknownUser => 'Unknown user';

  @override
  String get justNow => 'Just now';

  @override
  String anteprojectStatusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String get anteprojectExpectedResultsHint => 'Example milestone1 Description';

  @override
  String get anteprojectTimelineHint => 'Example phase1 Description';

  @override
  String get dashboardStudent => 'Student Dashboard';

  @override
  String get myAnteprojects => 'My Anteprojects';

  @override
  String get viewAll => 'View All';

  @override
  String get pendingAnteprojects => 'Pending Anteprojects';

  @override
  String get activeAnteprojects => 'Active Anteprojects';

  @override
  String get noActiveAnteprojects => 'No active anteproyectos at this time';

  @override
  String noActiveButApproved(int count, String plural) {
    return 'No active anteproyectos, but you have $count approved anteproyecto$plural';
  }

  @override
  String get assignedStudents => 'Assigned Students';

  @override
  String get noAnteprojects => 'No Anteprojects';

  @override
  String get pendingTasks => 'Pending Tasks';

  @override
  String get viewAllTasks => 'View All Tasks';

  @override
  String get noPendingTasks => 'No Pending Tasks';

  @override
  String get systemInfo => 'System Information';

  @override
  String backendLabel(String url) {
    return 'Backend';
  }

  @override
  String platformLabel(String platform) {
    return 'Platform';
  }

  @override
  String versionLabel(String version) {
    return 'Version';
  }

  @override
  String get emailLabel => 'Email';

  @override
  String get connectedToServer => 'Connected to server';

  @override
  String get dashboardAdminUsersManagement => 'Users Management';

  @override
  String get dashboardTutor => 'Tutor Dashboard';

  @override
  String get dashboardAdmin => 'Admin Dashboard';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get noProjectsAvailableForTasks =>
      'No projects available for creating tasks. Make sure your anteproject is approved.';

  @override
  String get mustSelectProjectForTask =>
      'You must select a project to create the task';

  @override
  String get myProjects => 'My Projects';

  @override
  String get noProjectsAssigned =>
      'You have no projects assigned. Contact your tutor.';

  @override
  String get supabaseStudio => 'Supabase Studio';

  @override
  String get openSupabaseStudio => 'Open Supabase Studio';

  @override
  String get supabaseStudioDescription =>
      'Direct access to database administration panel';

  @override
  String get openInbucket => 'Open Inbucket';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get activeProjects => 'Active Projects';

  @override
  String get tutors => 'Tutors';

  @override
  String get noUsers => 'No users';

  @override
  String get systemStatus => 'System Status';

  @override
  String get close => 'Close';

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
  String get loginSuccessTitle => 'Login Successful';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get validationError => 'Validation Error';

  @override
  String get formValidationError => 'Please correct the errors in the form';

  @override
  String get networkError => 'Network error';

  @override
  String get networkErrorMessage =>
      'Could not connect to server. Check your internet connection.';

  @override
  String get serverError => 'Server error';

  @override
  String get serverErrorMessage =>
      'Server could not process the request. Try again later.';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get unknownErrorMessage =>
      'An unexpected error occurred. Please try again.';

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
  String get invalidEmail => 'Email format is not valid';

  @override
  String get invalidUrl => 'URL does not have a valid format';

  @override
  String get invalidNumber => 'Value must be a valid number';

  @override
  String get invalidJson => 'JSON format is not valid';

  @override
  String get operationInProgress => 'Operation in progress';

  @override
  String get operationCompleted => 'Operation completed';

  @override
  String get operationFailed => 'Operation failed';

  @override
  String get taskFormTitle => 'Task Form';

  @override
  String get taskEditFormTitle => 'Edit Task';

  @override
  String get taskTitle => 'Title';

  @override
  String get taskDescription => 'Description';

  @override
  String get taskStatus => 'Status';

  @override
  String get taskComplexity => 'Complexity';

  @override
  String get taskDueDate => 'Due Date';

  @override
  String get taskEstimatedHours => 'Estimated Hours';

  @override
  String get taskTags => 'Tags';

  @override
  String get taskCreateButton => 'Create Task';

  @override
  String get taskUpdateButton => 'Update Task';

  @override
  String get taskTitleRequired => 'Title is required';

  @override
  String get taskDescriptionRequired => 'Description is required';

  @override
  String get taskStatusPending => 'Pending';

  @override
  String get taskStatusInProgress => 'In Progress';

  @override
  String get taskStatusCompleted => 'Completed';

  @override
  String get taskComplexitySimple => 'Simple';

  @override
  String get taskComplexityMedium => 'Medium';

  @override
  String get taskComplexityComplex => 'Complex';

  @override
  String get tasksListTitle => 'Tasks List';

  @override
  String get tasksListEmpty => 'No tasks available';

  @override
  String get tasksListRefresh => 'Refresh Tasks';

  @override
  String get kanbanBoardTitle => 'Kanban Board';

  @override
  String get kanbanColumnPending => 'Pending';

  @override
  String get kanbanColumnInProgress => 'In Progress';

  @override
  String get kanbanColumnCompleted => 'Completed';

  @override
  String get taskReorderedSuccess => 'Task reordered successfully';

  @override
  String get taskPositionUpdatedSuccess => 'Task position updated';

  @override
  String get movingTask => 'Moving...';

  @override
  String get taskStatusUpdatedNotification => 'Task status updated';

  @override
  String taskStatusChangedMessage(String taskTitle, String status) {
    return 'Task \\';
  }

  @override
  String get taskAssignedNotification => 'Task assigned';

  @override
  String taskAssignedMessage(String taskTitle) {
    return 'You have been assigned the task: \\';
  }

  @override
  String get newCommentNotification => 'New comment on task';

  @override
  String newCommentMessage(String taskTitle, String commentPreview) {
    return 'New comment on \\';
  }

  @override
  String get selectDate => 'Select Date';

  @override
  String get createTask => 'Create Task';

  @override
  String get approvalWorkflow => 'Approval Workflow';

  @override
  String get pendingApprovals => 'Pending Approvals';

  @override
  String get reviewedAnteprojects => 'Reviewed Anteprojects';

  @override
  String get approveAnteproject => 'Approve Anteproject';

  @override
  String get rejectAnteproject => 'Reject Anteproject';

  @override
  String get requestChanges => 'Request Changes';

  @override
  String get approvalComments => 'Approval Comments';

  @override
  String get approvalCommentsHint => 'Comments about the approval...';

  @override
  String get rejectionComments => 'Rejection Comments';

  @override
  String get rejectionCommentsHint => 'Reason for rejection...';

  @override
  String get changesComments => 'Changes Comments';

  @override
  String get changesCommentsHint => 'Enter changes comments';

  @override
  String get confirmApproval => 'Confirm Approval';

  @override
  String get confirmRejection => 'Confirm Rejection';

  @override
  String get confirmChanges => 'Confirm Changes';

  @override
  String get approvalConfirmMessage =>
      'Are you sure you want to approve this anteproyecto?';

  @override
  String get rejectionConfirmMessage =>
      'Are you sure you want to reject this anteproyecto?';

  @override
  String get changesConfirmMessage =>
      'Are you sure you want to request changes for this anteproyecto?';

  @override
  String get approvalSuccess => 'Anteproject approved successfully';

  @override
  String get rejectionSuccess => 'Anteproject rejected successfully';

  @override
  String get changesSuccess => 'Changes requested successfully';

  @override
  String get approvalError => 'Error processing approval';

  @override
  String get noAnteprojectsToReview => 'No anteproyectos to review';

  @override
  String get noReviewedAnteprojects => 'No reviewed anteproyectos';

  @override
  String get submittedOn => 'Submitted on';

  @override
  String get reviewedOn => 'Reviewed on';

  @override
  String get tutorComments => 'Tutor Comments';

  @override
  String get anteprojectStatus => 'Anteproject Status';

  @override
  String get viewDetails => 'View details';

  @override
  String get processing => 'Processing...';

  @override
  String get commentsRequired => 'Comments are required';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

  @override
  String get academicYear => 'Academic Year';

  @override
  String get noDataDescription => 'No data available';

  @override
  String get uploadFile => 'Upload File';

  @override
  String get uploading => 'Uploading...';

  @override
  String get upload => 'Upload';

  @override
  String get fileUploadedSuccessfully => 'File uploaded successfully';

  @override
  String get fileDeletedSuccessfully => 'File deleted successfully';

  @override
  String get confirmDeleteFile => 'Confirm Delete';

  @override
  String confirmDeleteFileMessage(String fileName) {
    return 'Are you sure you want to delete this file?';
  }

  @override
  String get openFile => 'Open File';

  @override
  String get deleteFile => 'Delete File';

  @override
  String get noFilesAttached => 'No files attached';

  @override
  String get noFilesYet => 'No files yet';

  @override
  String get uploadedBy => 'Uploaded by';

  @override
  String get clickToSelectFile => 'Click to select a file';

  @override
  String get allowedFileTypes => 'Allowed file types';

  @override
  String maxFileSize(String size) {
    return 'Maximum file size';
  }

  @override
  String get filesAttached => 'Files Attached';

  @override
  String get attachFile => 'Attach File';

  @override
  String get taskDetails => 'Task Details';

  @override
  String get details => 'Details';

  @override
  String get tutorRole => 'Tutor';

  @override
  String get reviewedPlural => 'Reviewed';

  @override
  String get addStudents => 'Add Students';

  @override
  String studentsAssignedInfo(int count, String plural, String year) {
    return 'You have $count student$plural assigned for $year';
  }

  @override
  String get myStudents => 'My Students';

  @override
  String get searchStudents => 'Search students...';

  @override
  String get noStudentsAssigned => 'You have no students assigned';

  @override
  String get noStudentsFound => 'No students found';

  @override
  String get useDashboardButtons => 'Use the dashboard buttons to add students';

  @override
  String get editStudent => 'Edit';

  @override
  String get deleteStudent => 'Delete';

  @override
  String get nre => 'NRE';

  @override
  String get phone => 'Phone';

  @override
  String get specialty => 'Specialty';

  @override
  String get biography => 'Biography';

  @override
  String get creationDate => 'Creation date';

  @override
  String get studentDeletedSuccess => 'Student deleted successfully';

  @override
  String errorDeletingStudent(String error) {
    return 'Error deleting student: $error';
  }

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String confirmDeleteStudent(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get anteprojectsReview => 'Anteprojects Review';

  @override
  String get pendingAnteprojectsTitle => 'Pending Anteprojects';

  @override
  String get reviewedAnteprojectsTitle => 'Reviewed Anteprojects';

  @override
  String get submittedAnteprojects => 'Submitted Anteprojects';

  @override
  String get underReviewAnteprojects => 'Under Review Anteprojects';

  @override
  String get approvedAnteprojects => 'Approved Anteprojects';

  @override
  String get rejectedAnteprojects => 'Rejected Anteprojects';

  @override
  String get all => 'All';

  @override
  String get searchAnteprojects => 'Search anteproyectos...';

  @override
  String get filterByStatus => 'Filter by status:';

  @override
  String errorLoadingAnteprojects(String error) {
    return 'Error loading anteproyectos: $error';
  }

  @override
  String noAnteprojectsFound(String query) {
    return 'No anteproyectos found matching \\';
  }

  @override
  String noAnteprojectsWithStatus(String status) {
    return 'No anteproyectos with status \\';
  }

  @override
  String get noAssignedAnteprojects =>
      'You have no anteproyectos assigned for review';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get year => 'Year';

  @override
  String get created => 'Created:';

  @override
  String get submittedLabel => 'Submitted:';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get lastUpdate => 'Last update:';

  @override
  String get reviewedLabel => 'Reviewed:';

  @override
  String get statusReviewed => 'Reviewed';

  @override
  String get dates => 'Dates';

  @override
  String get reviewDates => 'Review Dates';

  @override
  String get projectMilestones => 'Project Milestones';

  @override
  String get comments => 'Comments';

  @override
  String get approveAnteprojectTitle => 'Approve Anteproject';

  @override
  String get rejectAnteprojectTitle => 'Reject Anteproject';

  @override
  String get confirmApproveAnteproject =>
      'Are you sure you want to approve this anteproject?';

  @override
  String get confirmRejectAnteproject =>
      'Are you sure you want to reject this anteproject?';

  @override
  String get approvalCommentsOptional => 'Comments (optional)';

  @override
  String get anteprojectApprovedSuccess => 'Anteproject approved successfully';

  @override
  String get cannotCreateAnteprojectWithApprovedTitle =>
      'Cannot create a new anteproject';

  @override
  String get cannotCreateAnteprojectWithApproved =>
      'You cannot create a new anteproject because you already have one approved. You must develop the associated project.';

  @override
  String get goToProject => 'Go to Project';

  @override
  String get goToDraft => 'Go to Draft';

  @override
  String get goBack => 'Go Back';

  @override
  String get readOnlyModeTitle => 'Read-only mode';

  @override
  String readOnlyModeMessage(String year) {
    return 'Your academic year ($year) is no longer active. You can only view your historical data.';
  }

  @override
  String get cannotPerformActionReadOnly =>
      'You cannot perform this action because your academic year is no longer active.';

  @override
  String get cannotCreateAnteprojectWithDraftTitle =>
      'You already have a draft';

  @override
  String get cannotCreateAnteprojectWithDraft =>
      'You already have a draft anteproject. Complete or delete it before creating another one.';

  @override
  String get cannotSubmitAnteprojectWithActive =>
      'You already have an anteproject under review. Wait for it to complete its cycle before submitting another one.';

  @override
  String get cannotCreateAnteprojectWrongAcademicYearTitle =>
      'Wrong academic year';

  @override
  String get cannotCreateAnteprojectWrongAcademicYear =>
      'Only students enrolled in the active academic year can create anteprojects. Contact your tutor or administrator.';

  @override
  String get cannotSubmitAnteprojectWithApprovedTitle =>
      'Cannot submit this anteproject';

  @override
  String get cannotSubmitAnteprojectWithApproved =>
      'You cannot submit this anteproject because you already have one approved. You must develop the associated project.';

  @override
  String get cannotSendMessageWithApprovedAnteproject =>
      'You cannot send messages about anteprojects because you already have one approved. You must communicate through the associated project.';

  @override
  String get cannotEditAnteprojectWithApprovedTitle =>
      'Cannot edit this anteproject';

  @override
  String get cannotEditAnteprojectWithApproved =>
      'You cannot edit anteprojects because you already have one approved. All your anteprojects are frozen and can only be viewed. You must develop the associated project.';

  @override
  String get cannotDeleteAnteprojectWithApproved =>
      'You cannot delete anteprojects because you already have one approved. All your anteprojects are frozen and can only be viewed. You must develop the associated project.';

  @override
  String get cannotCreateThreadWithApprovedAnteproject =>
      'You cannot create conversation threads about anteprojects because you already have one approved. You must communicate through the associated project.';

  @override
  String get anteprojectRejectedSuccess => 'Anteproject rejected';

  @override
  String errorApprovingAnteproject(String error) {
    return 'Error approving anteproyecto: $error';
  }

  @override
  String errorRejectingAnteproject(String error) {
    return 'Error rejecting anteproyecto: $error';
  }

  @override
  String get pending => 'Pending';

  @override
  String get underReview => 'Under Review';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get status => 'Status';

  @override
  String get anteprojectTitleLabel => 'Anteproject Title';

  @override
  String get logoutTooltip => 'Logout';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get files => 'Files';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get welcomeMessage => 'Welcome!';

  @override
  String get welcomeDescription => 'You have logged in successfully';

  @override
  String get getStarted => 'Get Started';

  @override
  String get getStartedDescription => 'Use the side menu to navigate';

  @override
  String get createAnteprojectTooltip => 'Create anteproyecto';

  @override
  String userId(String id) {
    return 'ID: $id';
  }

  @override
  String get studentRole => 'Student';

  @override
  String get anteprojects => 'Anteprojects';

  @override
  String get completed => 'Completed';

  @override
  String get anteprojectApprovedMessage => 'Anteproject approved successfully';

  @override
  String academicYearLabel(String year) {
    return 'Academic Year';
  }

  @override
  String statusLabel(String status) {
    return 'Status';
  }

  @override
  String get draft => 'Draft';

  @override
  String get approvedStatus => 'Approved';

  @override
  String get rejectedStatus => 'Rejected';

  @override
  String get unknown => 'Unknown';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completedStatus => 'Completed';

  @override
  String get unknownStatus => 'Unknown';

  @override
  String get studentCreatedSuccess => 'Student created successfully';

  @override
  String errorCreatingStudent(String error) {
    return 'Error creating student: $error';
  }

  @override
  String get addStudent => 'Add Student';

  @override
  String get fullName => 'Full Name';

  @override
  String get nreLabel => 'NRE (Student Registration Number)';

  @override
  String get phoneOptional => 'Phone (Optional)';

  @override
  String get biographyOptional => 'Biography (Optional)';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get nreRequired => 'NRE is required';

  @override
  String get createStudent => 'Create Student';

  @override
  String get studentUpdatedSuccess => 'Student updated successfully';

  @override
  String errorUpdatingStudent(String error) {
    return 'Error updating student: $error';
  }

  @override
  String get updateStudent => 'Update Student';

  @override
  String get role => 'Role';

  @override
  String get noProjectAssigned =>
      'You don\'t have a project or anteproject assigned. Contact your tutor.';

  @override
  String errorGettingProject(String error) {
    return 'Error getting project: $error';
  }

  @override
  String get deleteAnteproject => 'Delete Anteproject';

  @override
  String confirmDeleteAnteproject(String title) {
    return 'Are you sure you want to delete the anteproject \\';
  }

  @override
  String get anteprojectDeletedSuccess => 'Anteproject deleted successfully';

  @override
  String errorDeletingAnteproject(String error) {
    return 'Error deleting anteproject: $error';
  }

  @override
  String get templateLoadedSuccess =>
      '✅ Template loaded successfully. 4 example milestones have been added.';

  @override
  String errorGeneratingPDF(String error) {
    return 'Error generating PDF: $error';
  }

  @override
  String get downloadExampleTitle => 'Download Anteproject Example';

  @override
  String get downloadExampleMessage =>
      'How would you like to download the anteproject example?';

  @override
  String get print => 'Print';

  @override
  String pdfSavedAt(String path) {
    return 'PDF saved at: $path';
  }

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String get downloadExamplePDF => 'Download Example PDF';

  @override
  String errorLoadingSchedule(String error) {
    return 'Error loading schedule: $error';
  }

  @override
  String get mustConfigureReviewDate =>
      'You must configure at least one review date';

  @override
  String get scheduleSavedSuccess => 'Schedule saved successfully';

  @override
  String errorSavingSchedule(String error) {
    return 'Error saving schedule: $error';
  }

  @override
  String get scheduleManagement => 'Schedule Management';

  @override
  String get regenerateDatesBasedOnMilestones =>
      'Regenerate Dates Based on Milestones';

  @override
  String get noMilestonesDefined => 'No milestones defined';

  @override
  String get anteprojectDetails => 'Anteproject Details';

  @override
  String get editAnteproject => 'Edit Anteproject';

  @override
  String get anteprojectRejected => 'Anteproject rejected';

  @override
  String get sendForApproval => 'Send for Approval';

  @override
  String get sendForApprovalTitle => 'Send for Approval';

  @override
  String get sendForApprovalMessage =>
      'Are you sure you want to send this anteproject for approval? Once sent, you won\'t be able to edit it until it\'s reviewed.';

  @override
  String get send => 'Send';

  @override
  String get anteprojectSentForApproval =>
      'Anteproject sent for approval successfully';

  @override
  String errorSendingAnteproject(String error) {
    return 'Error sending anteproject: $error';
  }

  @override
  String anteprojectTitle(String title) {
    return 'Anteproject';
  }

  @override
  String errorLoadingComments(String error) {
    return 'Error loading comments: $error';
  }

  @override
  String get pleaseWriteComment => 'Please write a comment';

  @override
  String get commentAddedSuccess => 'Comment added successfully';

  @override
  String errorAddingComment(String error) {
    return 'Error adding comment: $error';
  }

  @override
  String commentsTitle(String title) {
    return 'Comments';
  }

  @override
  String copied(String text) {
    return 'Copied';
  }

  @override
  String get addIndividually => 'Add Individually';

  @override
  String get importFromCSV => 'Import from CSV';

  @override
  String errorLoadingNotifications(String error) {
    return 'Error loading notifications: $error';
  }

  @override
  String errorMarkingAsRead(String error) {
    return 'Error marking as read: $error';
  }

  @override
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String errorMarkingAllAsRead(String error) {
    return 'Error marking all as read: $error';
  }

  @override
  String errorDeletingNotification(String error) {
    return 'Error deleting notification: $error';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String errorLoadingStudents(String error) {
    return 'Error loading students: $error';
  }

  @override
  String dashboardTitle(String name) {
    return 'Dashboard - $name';
  }

  @override
  String get allYears => 'All years';

  @override
  String errorSelectingFile(String error) {
    return 'Error selecting file: $error';
  }

  @override
  String get noValidDataToImport => 'No valid data to import';

  @override
  String importCompleted(int success, int error) {
    return 'Import completed: $success successful, $error errors';
  }

  @override
  String errorDuringImport(String error) {
    return 'Error during import: $error';
  }

  @override
  String get importStudentsCSV => 'Import Students CSV';

  @override
  String get fullNameRequired => '• full_name (required)';

  @override
  String get specialtyOptional => '• specialty (optional)';

  @override
  String get academicYearOptional => '• academic_year (optional)';

  @override
  String get selectCSVFile => 'Select CSV File';

  @override
  String importStudents(int count) {
    return 'Import $count Students';
  }

  @override
  String get importing => 'Importing...';

  @override
  String get studentsImportedSuccess => 'Students imported successfully';

  @override
  String get creating => 'Creating...';

  @override
  String get createTutor => 'Create Tutor';

  @override
  String get tutorCreatedSuccess => 'Tutor created successfully';

  @override
  String errorUploadingFile(String error) {
    return 'Error uploading file: $error';
  }

  @override
  String errorLoadingFiles(String error) {
    return 'Error loading files: $error';
  }

  @override
  String errorDeletingFile(String error) {
    return 'Error deleting file: $error';
  }

  @override
  String errorOpeningFile(String error) {
    return 'Error opening file: $error';
  }

  @override
  String estimatedHours(int hours) {
    return 'Estimated Hours';
  }

  @override
  String confirmDeleteTask(String title) {
    return 'Are you sure you want to delete the task \\';
  }

  @override
  String get mustLoginToViewComments => 'You must login to view comments';

  @override
  String get permissionRequired => 'Permissions Required';

  @override
  String get permissionRequiredMessage =>
      'This application needs access to storage to select files. Please grant the necessary permissions.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get fileSavedSuccessfully => 'File saved successfully';

  @override
  String errorPrinting(String error) {
    return 'Error printing: $error';
  }

  @override
  String get selectProjectForTasks => 'Select project';

  @override
  String get projectDetails => 'Project Details';

  @override
  String get anteprojectHistoryComments => 'Anteproject Comments (Historical)';

  @override
  String get projectComments => 'Project Comments';

  @override
  String get attachedFiles => 'Attached Files';

  @override
  String get kanbanBoard => 'Kanban Board';

  @override
  String get kanbanOnlyForProjects =>
      'The Kanban board is only available for approved projects';

  @override
  String get anteprojectNotFound =>
      'The anteproject associated with the project was not found';

  @override
  String get tasksList => 'Tasks List';

  @override
  String get errorNetworkTimeout =>
      'The connection timed out. Please check your internet connection and try again.';

  @override
  String get errorNetworkNoInternet =>
      'No internet connection. Please check your connection and try again.';

  @override
  String get errorNetworkServerUnavailable =>
      'The server is not available at this time. Please try again later.';

  @override
  String get errorNetworkDnsError =>
      'Could not resolve server address. Check your internet connection.';

  @override
  String get errorNetworkConnectionLost =>
      'Connection lost. Please check your internet connection.';

  @override
  String get errorNetworkRequestFailed =>
      'The request failed. Please try again.';

  @override
  String get errorNotAuthenticated =>
      'You must be logged in to perform this action.';

  @override
  String get errorInvalidCredentials =>
      'Invalid credentials. Please check your email and password.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please log in again.';

  @override
  String get errorProfileNotFound =>
      'Could not find your user profile. Please contact support.';

  @override
  String get errorAccountDisabled =>
      'Your account is disabled. Please contact the administrator.';

  @override
  String get errorEmailNotVerified =>
      'Your email has not been verified. Please check your inbox.';

  @override
  String get errorPasswordTooWeak =>
      'Password is too weak. Must be at least 8 characters.';

  @override
  String get errorLoginAttemptsExceeded =>
      'Too many login attempts. Please try again later.';

  @override
  String get errorRateLimitExceeded =>
      'Too many requests. For security purposes, you must wait a few seconds before creating another user. Please wait a moment and try again.';

  @override
  String get errorRateLimitEmailSent =>
      'Rate limit reached. If a verification email was sent but the user was not fully created, the administrator will need to manually clean up the user from Supabase Dashboard.';

  @override
  String get errorEmailAlreadyRegistered =>
      'This email is already registered. If you recently deleted a user with this email, please wait a few minutes before trying to create another user with the same email. Supabase requires a waiting period before allowing email reuse.';

  @override
  String get errorFieldRequired => 'This field is required.';

  @override
  String get errorFieldTooShort => 'This field is too short.';

  @override
  String get errorFieldTooLong => 'This field is too long.';

  @override
  String get errorInvalidEmail => 'Invalid email format.';

  @override
  String get errorInvalidUrl => 'Invalid URL format.';

  @override
  String get errorInvalidNumber => 'Value must be a valid number.';

  @override
  String get errorInvalidJson => 'Invalid JSON format.';

  @override
  String get errorInvalidDate => 'Invalid date format.';

  @override
  String get errorInvalidFileType => 'File type not allowed.';

  @override
  String get errorInvalidFileSize => 'File is too large.';

  @override
  String get errorMissingTaskContext =>
      'Must select a project to create the task.';

  @override
  String get errorInvalidProjectRelation => 'Invalid project relation.';

  @override
  String get errorAccessDenied =>
      'You don\'t have permission to perform this action.';

  @override
  String get errorInsufficientPermissions =>
      'You don\'t have sufficient permissions to perform this action.';

  @override
  String get errorOperationNotAllowed => 'This operation is not allowed.';

  @override
  String get errorResourceNotFound => 'The requested resource was not found.';

  @override
  String get errorCannotDeleteCompletedTask =>
      'Cannot delete a completed task.';

  @override
  String get errorCannotEditApprovedAnteproject =>
      'Cannot edit an approved anteproject.';

  @override
  String get errorDatabaseConnectionFailed =>
      'Could not connect to database. Please try again later.';

  @override
  String get errorDatabaseQueryFailed =>
      'Database query failed. Please try again.';

  @override
  String get errorDatabaseConstraintViolation =>
      'Data does not comply with database rules.';

  @override
  String get errorDatabaseDuplicateEntry =>
      'A record with this data already exists.';

  @override
  String get errorDatabaseForeignKeyViolation =>
      'Cannot perform operation due to data dependencies.';

  @override
  String get errorDatabaseUnknownError =>
      'A database error occurred. Please try again later.';

  @override
  String get errorDatabaseTimeout => 'Operation timed out. Please try again.';

  @override
  String get errorFileUploadFailed =>
      'Could not upload file. Please try again.';

  @override
  String get errorFileDownloadFailed =>
      'Could not download file. Please try again.';

  @override
  String get errorFileDeleteFailed =>
      'Could not delete file. Please try again.';

  @override
  String get errorFileNotFound => 'File not found.';

  @override
  String errorFileSizeExceeded(String maxSize) {
    return 'File is too large. Maximum size is $maxSize.';
  }

  @override
  String errorFileTypeNotAllowed(String allowedTypes) {
    return 'File type not allowed. Allowed types: $allowedTypes.';
  }

  @override
  String get errorFileCorrupted => 'File is corrupted or damaged.';

  @override
  String get errorFilePermissionDenied =>
      'You don\'t have permission to access this file.';

  @override
  String get errorInvalidState =>
      'Current state does not allow this operation.';

  @override
  String get errorOperationNotSupported => 'This operation is not supported.';

  @override
  String get errorResourceAlreadyExists =>
      'A resource with this data already exists.';

  @override
  String get errorResourceInUse =>
      'Resource is being used and cannot be modified.';

  @override
  String get errorWorkflowViolation =>
      'This operation is not allowed in the current workflow.';

  @override
  String get errorBusinessRuleViolation =>
      'Operation violates a business rule.';

  @override
  String get errorQuotaExceeded => 'You have exceeded the allowed limit.';

  @override
  String get errorDeadlineExceeded => 'Deadline has been exceeded.';

  @override
  String get errorConfigurationMissing =>
      'Required configuration is missing. Contact support.';

  @override
  String get errorConfigurationInvalid =>
      'Configuration is invalid. Contact support.';

  @override
  String get errorServiceUnavailable =>
      'Service is not available. Please try again later.';

  @override
  String get errorMaintenanceMode =>
      'System is under maintenance. Please try again later.';

  @override
  String get errorExternalServiceTimeout =>
      'External service took too long to respond.';

  @override
  String get errorExternalServiceError =>
      'External service is not working properly.';

  @override
  String get errorEmailServiceUnavailable => 'Email service is not available.';

  @override
  String get errorNotificationServiceUnavailable =>
      'Notification service is not available.';

  @override
  String get errorUnknown => 'An unexpected error occurred. Please try again.';

  @override
  String get errorUnexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get errorInternal =>
      'An internal error occurred. Please contact support.';

  @override
  String get errorNetworkGeneric =>
      'Connection error. Please check your internet connection.';

  @override
  String get errorAuthenticationGeneric =>
      'Authentication error. Please log in again.';

  @override
  String get errorValidationGeneric =>
      'Validation error. Please check the entered data.';

  @override
  String get errorPermissionGeneric =>
      'You don\'t have permission to perform this action.';

  @override
  String get errorDatabaseGeneric => 'Database error. Please try again later.';

  @override
  String get errorFileGeneric => 'File error. Please try again.';

  @override
  String get errorBusinessLogicGeneric =>
      'Business logic error. Operation cannot be completed.';

  @override
  String get errorConfigurationGeneric =>
      'Configuration error. Contact support.';

  @override
  String get errorExternalServiceGeneric =>
      'External service error. Please try again later.';

  @override
  String get errorTitleNetwork => 'Connection Error';

  @override
  String get errorTitleAuthentication => 'Authentication Error';

  @override
  String get errorTitleValidation => 'Validation Error';

  @override
  String get errorTitlePermission => 'Permission Error';

  @override
  String get errorTitleDatabase => 'Database Error';

  @override
  String get errorTitleFile => 'File Error';

  @override
  String get errorTitleBusinessLogic => 'Business Logic Error';

  @override
  String get errorTitleConfiguration => 'Configuration Error';

  @override
  String get errorTitleExternalService => 'External Service Error';

  @override
  String get errorTitleUnknown => 'Unknown Error';

  @override
  String get errorActionNetwork => 'Check internet connection';

  @override
  String get errorActionAuthentication => 'Log in again';

  @override
  String get errorActionValidation => 'Review entered data';

  @override
  String get errorActionPermission => 'Contact administrator';

  @override
  String get errorActionDatabase => 'Try again later';

  @override
  String get errorActionFile => 'Select another file';

  @override
  String get errorActionBusinessLogic => 'Check resource state';

  @override
  String get errorActionConfiguration => 'Contact technical support';

  @override
  String get errorActionExternalService => 'Try again later';

  @override
  String get errorActionUnknown => 'Try again or contact support';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordInstructions =>
      'Enter your new password to restore access to your account.';

  @override
  String get resetPasswordRequestSent => 'Request sent to your tutor';

  @override
  String resetPasswordRequestSentDescription(String tutorName) {
    return 'Your tutor $tutorName will receive a notification to generate a new temporary password. We will send you an email with the new password once your tutor has generated it.';
  }

  @override
  String get userNotFound => 'No user found with that email';

  @override
  String get setupPassword => 'Set Up Password';

  @override
  String get setupPasswordInstructions =>
      'Set your personal password to access the system. This will be your login password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetLinkSent =>
      'A password reset link has been sent to your email address.';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get passwordChanged => 'Password updated successfully';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get userCreatedSuccess =>
      'User created successfully. A verification email has been sent.';

  @override
  String get userCreatedInstructions =>
      'The user will receive a verification email. After verifying their email, they must use the \'Forgot your password?\' option to set their personal password.';

  @override
  String resetPasswordForStudent(String studentName) {
    return 'Reset password for $studentName';
  }

  @override
  String get generatePasswordAutomatically => 'Generate password automatically';

  @override
  String get regeneratePassword => 'Regenerate';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get passwordResetNotificationSent =>
      'A notification has been sent to the student with the new password.';

  @override
  String passwordResetError(String error) {
    return 'Error resetting password: $error';
  }

  @override
  String get studentCreatedWithPassword =>
      'The student has been created with the password set. They can log in immediately.';

  @override
  String get messages => 'Messages';

  @override
  String get tutorMessages => 'Student Messages';

  @override
  String get studentMessages => 'Messages with Tutor';

  @override
  String get helpGuide => 'User Guide';

  @override
  String get systemSettings => 'System Settings';

  @override
  String get settings => 'Settings';

  @override
  String get selectProjectOrAnteprojectMessage =>
      'Select a project or anteproject to view or respond to messages from your students';

  @override
  String get waitForStudentsAssignment =>
      'Wait for students to be assigned to you\nwith projects or anteprojects';

  @override
  String get allTypes => 'All types';

  @override
  String get filterByType => 'Filter by type';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get myNotifications => 'My Notifications';

  @override
  String get system => 'System';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String errorDeleting(String error) {
    return 'Error deleting: $error';
  }

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsOfThisType => 'No notifications of this type';

  @override
  String get privateCommunicationsPrivacy =>
      'Private communications between users are not shown for data protection.';

  @override
  String get viewMessages => 'View messages';

  @override
  String get update => 'Update';

  @override
  String get updateList => 'Update list';

  @override
  String get updateMessages => 'Update messages';

  @override
  String get updateComments => 'Update comments';

  @override
  String get now => 'Now';

  @override
  String agoDays(num days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    return '$daysString day ago';
  }

  @override
  String agoDaysPlural(num days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    return '$daysString days ago';
  }

  @override
  String agoHours(num hours) {
    final intl.NumberFormat hoursNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String hoursString = hoursNumberFormat.format(hours);

    return '$hoursString hour ago';
  }

  @override
  String agoHoursPlural(num hours) {
    final intl.NumberFormat hoursNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String hoursString = hoursNumberFormat.format(hours);

    return '$hoursString hours ago';
  }

  @override
  String agoMinutes(num minutes) {
    final intl.NumberFormat minutesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString minute ago';
  }

  @override
  String agoMinutesPlural(num minutes) {
    final intl.NumberFormat minutesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString minutes ago';
  }

  @override
  String agoDaysShort(num days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    return '${daysString}d ago';
  }

  @override
  String agoHoursShort(num hours) {
    final intl.NumberFormat hoursNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String hoursString = hoursNumberFormat.format(hours);

    return '${hoursString}h ago';
  }

  @override
  String agoMinutesShort(num minutes) {
    final intl.NumberFormat minutesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String minutesString = minutesNumberFormat.format(minutes);

    return '${minutesString}m ago';
  }

  @override
  String get projectQueriesMessage =>
      'Here you can ask questions about your project';

  @override
  String get anteprojectQueriesMessage =>
      'Here you can ask questions about your anteproject';

  @override
  String get selectProjectOrAnteprojectToStartConversation =>
      'Select a project or anteproject to start or continue a conversation with your tutor';

  @override
  String get noActiveProjects => 'You have no active projects';

  @override
  String get createAnteprojectToChat =>
      'Create an anteproject to\nchat with your tutor';

  @override
  String get approvedProjects => 'Approved Projects';

  @override
  String get projectInDevelopment => 'Project in development';

  @override
  String get viewComments => 'View comments';

  @override
  String get manageSchedule => 'Manage Schedule';

  @override
  String get newUser => 'New User';

  @override
  String get userDeleted => 'User Deleted';

  @override
  String get systemError => 'System Error';

  @override
  String get securityAlert => 'Security Alert';

  @override
  String get settingsChanged => 'Settings Changed';

  @override
  String get backupCompleted => 'Backup Completed';

  @override
  String get bulkOperation => 'Bulk Operation';

  @override
  String get systemMaintenance => 'Maintenance';

  @override
  String get announcement => 'Announcement';

  @override
  String get systemNotification => 'System Notification';

  @override
  String get comment => 'Comment';

  @override
  String get messageInAnteproject => 'Message in Anteproject';

  @override
  String get messageInProject => 'Message in Project';

  @override
  String get passwordResetRequest => 'Password Reset Request';

  @override
  String get taskAssigned => 'Task Assigned';

  @override
  String get statusChanged => 'Status Changed';

  @override
  String get conversations => 'Conversations';

  @override
  String get newTopic => 'New topic';

  @override
  String get writeMessage => 'Write a message...';

  @override
  String get noConversationsYet => 'No conversations yet';

  @override
  String get createNewTopicToStart =>
      'Create a new topic to start\nchatting with your tutor';

  @override
  String get useButtonBelow => '👇 Use the button below 👇';

  @override
  String errorLoadingConversations(String error) {
    return 'Error loading conversations: $error';
  }

  @override
  String get newConversationTopic => 'New conversation topic';

  @override
  String get createNewTopicToOrganize =>
      'Create a new topic to organize your conversation with the tutor.';

  @override
  String get topicTitle => 'Topic title';

  @override
  String get topicTitleHint => 'E.g.: Questions about methodology';

  @override
  String get topicTitleHelper => 'Briefly describe the topic to discuss';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get titleMinLength => 'Title must be at least 3 characters';

  @override
  String get topicTitleTip =>
      'Tip: Use descriptive titles like \"Questions Ch. 3\" or \"Code review\"';

  @override
  String get createTopic => 'Create topic';

  @override
  String errorSendingMessage(String error) {
    return 'Error sending message: $error';
  }

  @override
  String get noCommentsYet => 'No comments yet';

  @override
  String get beFirstToComment => 'Be the first to comment on this anteproject';

  @override
  String get commentsWillAppearHere =>
      'Comments will appear here when the tutor adds them';

  @override
  String viewMoreComments(int count) {
    return 'View $count more comments';
  }

  @override
  String get internal => 'Internal';

  @override
  String editedOn(String date) {
    return 'Edited on $date';
  }

  @override
  String get section => 'Section:';

  @override
  String get internalCommentLabel =>
      'Internal comment (only visible to tutors)';

  @override
  String get commentAddedSuccessfully => 'Comment added successfully';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionDescription => 'Description';

  @override
  String get sectionObjectives => 'Objectives';

  @override
  String get sectionExpectedResults => 'Expected Results';

  @override
  String get sectionTimeline => 'Timeline';

  @override
  String get sectionMethodology => 'Methodology';

  @override
  String get sectionResources => 'Resources';

  @override
  String get sectionOther => 'Other';

  @override
  String get generalInformation => 'General Information';
}
