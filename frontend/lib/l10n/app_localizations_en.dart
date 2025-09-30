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
  String get anteprojectCreateButton => 'Create anteproyecto';

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
  String get unknownUser => 'Unknown User';

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
  String get viewAll => 'View all';

  @override
  String get pendingAnteprojects => 'Pending Anteprojects';

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
  String get taskStatusUnderReview => 'Under Review';

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
  String get kanbanColumnUnderReview => 'Under Review';

  @override
  String get kanbanColumnCompleted => 'Completed';

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
  String get approveAnteproject => 'Approve';

  @override
  String get rejectAnteproject => 'Reject';

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
  String get reviewed => 'Reviewed';

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
  String get editStudent => 'Edit Student';

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
    return 'No anteproyectos found matching \"$query\"';
  }

  @override
  String noAnteprojectsWithStatus(String status) {
    return 'No anteproyectos with status \"$status\"';
  }

  @override
  String get noAssignedAnteprojects =>
      'You have no anteproyectos assigned for review';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get year => 'Year:';

  @override
  String get created => 'Created:';

  @override
  String get submitted => 'Submitted';

  @override
  String get comments => 'Comments';

  @override
  String get approveAnteprojectTitle => 'Approve Anteproject';

  @override
  String get rejectAnteprojectTitle => 'Reject Anteproject';

  @override
  String get confirmApproveAnteproject =>
      'Are you sure you want to approve this anteproyecto?';

  @override
  String get confirmRejectAnteproject =>
      'Are you sure you want to reject this anteproyecto?';

  @override
  String get approvalCommentsOptional => 'Comments (optional)';

  @override
  String get anteprojectApprovedSuccess => 'Anteproject approved successfully';

  @override
  String get anteprojectRejectedSuccess => 'Anteproject rejected';

  @override
  String errorApprovingAnteproject(String error) {
    return 'Error approving anteproject: $error';
  }

  @override
  String errorRejectingAnteproject(String error) {
    return 'Error rejecting anteproject: $error';
  }

  @override
  String get pending => 'Pending';

  @override
  String get underReview => 'Under Review';

  @override
  String get approved => 'APPROVED';

  @override
  String get rejected => 'Rejected';

  @override
  String get status => 'Status';

  @override
  String get anteprojectTitleLabel => 'Anteproject Title';

  @override
  String get logoutTooltip => 'Logout';

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
  String get anteprojectApprovedMessage =>
      'Your anteproyecto has been approved. You can start development!';

  @override
  String academicYearLabel(String year) {
    return 'Year: $year';
  }

  @override
  String statusLabel(String status) {
    return 'Status: $status';
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
  String get phoneOptional => '• phone (optional)';

  @override
  String get biographyOptional => '• biography (optional)';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get emailRequired => '• email (required)';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get nreRequired => '• nre (required)';

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
    return 'Are you sure you want to delete the anteproject \"$title\"?\n\nThis action cannot be undone.';
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
  String get loadTemplate => 'Load Template';

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
    return 'Comments - $title';
  }

  @override
  String copied(String text) {
    return 'Copied: $text';
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
    return '${hours}h';
  }

  @override
  String confirmDeleteTask(String title) {
    return 'Are you sure you want to delete the task \"$title\"?';
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
}
