import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../models/anteproject.dart';
import '../../models/project.dart';
import '../../models/schedule.dart';
import '../../models/user.dart';
import '../../models/anteproject_comment.dart';
import '../../services/anteprojects_service.dart';
import '../../services/schedule_service.dart';
import '../../services/auth_service.dart';
import '../../services/anteproject_comments_service.dart';
import 'anteproject_comments_screen.dart';
import '../schedule/schedule_management_screen.dart';
import '../forms/anteproject_edit_form.dart';
import '../kanban/kanban_board.dart';
import '../forms/task_form.dart';
import '../details/task_detail_screen.dart';
import '../../models/task.dart';
import '../../blocs/tasks_bloc.dart';
import '../../services/tasks_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/navigation/persistent_scaffold.dart';
import '../../widgets/files/file_list_widget.dart';

class AnteprojectDetailScreen extends StatefulWidget {
  final Anteproject anteproject;
  final Project? project; // NUEVO: para modo proyecto

  const AnteprojectDetailScreen({
    super.key,
    required this.anteproject,
    this.project, // NUEVO
  });

  @override
  State<AnteprojectDetailScreen> createState() =>
      _AnteprojectDetailScreenState();
}

class _AnteprojectDetailScreenState extends State<AnteprojectDetailScreen>
    with SingleTickerProviderStateMixin {
  // MODIFICADO: añadir mixin
  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();
  final AnteprojectCommentsService _commentsService =
      AnteprojectCommentsService();
  late Anteproject _anteproject;
  TabController? _tabController; // NUEVO
  bool _isLoading = false;
  Schedule? _schedule;
  User? _currentUser;
  List<AnteprojectComment> _comments = [];
  bool _isLoadingComments = false;
  bool? _hasApprovedAnteproject; // null = cargando, true/false = resultado

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _tabController = TabController(length: 5, vsync: this); // NUEVO
    }
    _anteproject = widget.anteproject;
    _loadSchedule();
    _loadCurrentUser();
    _loadComments();
    _checkApprovedAnteproject();
  }

  @override
  void dispose() {
    _tabController?.dispose(); // NUEVO
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      // Error al cargar usuario, pero no interrumpir el flujo
      debugPrint('Error al cargar usuario actual: $e');
    }
  }

  Future<void> _checkApprovedAnteproject() async {
    try {
      final hasApproved = await _anteprojectsService.hasApprovedAnteproject();
      if (mounted) {
        setState(() {
          _hasApprovedAnteproject = hasApproved;
        });
      }
    } catch (e) {
      debugPrint('Error al verificar anteproyecto aprobado: $e');
      if (mounted) {
        setState(() {
          _hasApprovedAnteproject = false; // En caso de error, permitir intentar
        });
      }
    }
  }

  Future<void> _loadComments() async {
    try {
      setState(() {
        _isLoadingComments = true;
      });

      final comments = await _commentsService.getAnteprojectComments(
        _anteproject.id,
      );

      if (mounted) {
        // Filtrar comentarios internos si el usuario es estudiante
        List<AnteprojectComment> filteredComments = comments;
        if (_currentUser?.role == UserRole.student) {
          filteredComments = comments
              .where((comment) => !comment.isInternal)
              .toList();
        }

        setState(() {
          _comments = filteredComments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
        debugPrint('Error al cargar comentarios: $e');
      }
    }
  }

  bool _canEditSchedule() {
    // Solo los tutores pueden editar el cronograma
    return _currentUser?.role == UserRole.tutor;
  }

  Future<void> _loadSchedule() async {
    try {
      final schedule = await _scheduleService.getScheduleByAnteproject(
        _anteproject.id,
      );
      if (mounted) {
        setState(() {
          _schedule = schedule;
        });
      }
    } catch (e) {
      // El cronograma puede no existir aún
    }
  }

  Color _getStatusColor(AnteprojectStatus status) {
    switch (status) {
      case AnteprojectStatus.draft:
        return Colors.grey;
      case AnteprojectStatus.submitted:
        return Colors.orange;
      case AnteprojectStatus.underReview:
        return Colors.blue;
      case AnteprojectStatus.approved:
        return Colors.green;
      case AnteprojectStatus.rejected:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Mientras cargamos el usuario, mostramos loading para poder montar la barra unificada
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isProjectMode = widget.project != null;
    final l10n = AppLocalizations.of(context)!;

    // Acciones específicas cuando NO es modo proyecto (acciones históricas del anteproyecto)
    final List<Widget> topBarActions = !isProjectMode
        ? [
            // Botón para comentarios oficiales (solo tutor)
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return IconButton(
                  icon: const Icon(Icons.chat, color: Colors.white),
                  tooltip: l10n.viewComments,
                  onPressed: _viewComments,
                );
              },
            ),
            // Permitir gestionar cronograma en todo el ciclo de vida del anteproyecto (solo tutores)
            if (_canEditSchedule())
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return IconButton(
                    icon: const Icon(Icons.schedule, color: Colors.white),
                    tooltip: l10n.manageSchedule,
                    onPressed: _manageSchedule,
                  );
                },
              ),
            if ((_anteproject.status == AnteprojectStatus.submitted ||
                    _anteproject.status == AnteprojectStatus.underReview) &&
                _currentUser?.role == UserRole.tutor) ...[
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    tooltip: l10n.reject,
                    onPressed: _isLoading ? null : _rejectAnteproject,
                  );
                },
              ),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    tooltip: l10n.approve,
                    onPressed: _isLoading ? null : _approveAnteproject,
                  );
                },
              ),
            ],
          ]
        : const [];

    final PreferredSizeWidget? bottom = isProjectMode
        ? TabBar(
            controller: _tabController!,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: l10n.details),
              Tab(text: l10n.comments),
              Tab(text: l10n.attachedFiles),
              Tab(text: l10n.kanbanBoard),
              Tab(text: l10n.tasksList),
            ],
          )
        : null;

    final Widget bodyContent = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : isProjectMode
        ? TabBarView(
            controller: _tabController!,
            children: [
              _buildDetailsTab(),
              _buildCommentsTab(),
              _buildFilesTab(),
              _buildKanbanTab(),
              _buildTasksListTab(),
            ],
          )
        : _buildAnteprojectDetails();

    return PersistentScaffold(
      title: isProjectMode ? 'Proyecto' : 'Anteproyecto',
      titleKey: isProjectMode ? 'projects' : 'anteprojects',
      user: _currentUser!,
      actions: topBarActions,
      bottom: bottom,
      body: bodyContent,
    );
  }

  Widget _buildHeaderCard() {
    final statusColor = _getStatusColor(_anteproject.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _anteproject.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    _anteproject.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _anteproject.projectType.displayName,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Botón de editar (solo para anteproyectos en borrador)
            if (_anteproject.status == AnteprojectStatus.draft) ...[
              Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Editar',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _editAnteproject,
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(AppLocalizations.of(context)!.editAnteproject),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Botón de eliminar (solo para anteproyectos en borrador)
              Row(
                children: [
                  Icon(Icons.delete, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Eliminar',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _deleteAnteproject,
                    icon: const Icon(Icons.delete, size: 18),
                    label: Text(
                      AppLocalizations.of(context)!.anteprojectDeleteButton,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.generalInformation,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Año Académico', _anteproject.academicYear),
            _buildInfoRow(
              'Tipo de Proyecto',
              _anteproject.projectType.displayName,
            ),
            _buildInfoRow('Estado', _anteproject.status.displayName),
            if (_anteproject.tutorId != null)
              _buildInfoRow('ID del Tutor', _anteproject.tutorId.toString()),
            if (_anteproject.githubRepositoryUrl != null)
              _buildInfoRow(
                'Repositorio de GitHub',
                _anteproject.githubRepositoryUrl!,
                isUrl: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.sectionDescription,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _anteproject.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpectedResultsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.sectionExpectedResults,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_anteproject.expectedResults.isNotEmpty)
              ..._anteproject.expectedResults.entries.map((entry) {
                // Verificar si el valor es un Map (estructura de hito) o String
                if (entry.value is Map<String, dynamic>) {
                  final hitoData = entry.value as Map<String, dynamic>;
                  final title = hitoData['title'] ?? entry.key;
                  final description = hitoData['description'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Formato legacy: solo texto
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              })
            else
              Text(
                'No se han definido resultados esperados',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.sectionTimeline,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Las tareas solo están disponibles para proyectos, no para anteproyectos
              ],
            ),
            const SizedBox(height: 12),

            // Mostrar cronograma de fechas de revisión si existe
            if (_schedule != null) ...[
              _buildScheduleSection(),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Mostrar hitos del anteproyecto o timeline formateado
            Text(
              AppLocalizations.of(context)!.projectMilestones,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildTimelineContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.reviewDates,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ..._schedule!.reviewDates.map((reviewDate) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(reviewDate.date),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        reviewDate.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimelineContent() {
    // Verificar si el timeline contiene fechas de revisión (formato del cronograma)
    final timelineEntries = _anteproject.timeline.entries.toList();
    final hasRevisionDates =
        timelineEntries.isNotEmpty &&
        timelineEntries.any(
          (entry) =>
              entry.key.startsWith('revision_') &&
              entry.value.toString().contains(':'),
        );

    // Si el timeline está vacío pero hay hitos en expectedResults, mostrarlos
    if (_anteproject.timeline.isEmpty &&
        _anteproject.expectedResults.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _anteproject.expectedResults.entries.map((entry) {
          // Verificar si el valor es un Map (estructura de hito) o String
          String title;
          String description;

          if (entry.value is Map<String, dynamic>) {
            final hitoData = entry.value as Map<String, dynamic>;
            title = hitoData['title'] ?? entry.key;
            description = hitoData['description'] ?? '';
          } else if (entry.value is Map) {
            // Manejar objetos minificados de Supabase
            final hitoMap = <String, dynamic>{};
            for (final key in (entry.value as Map).keys) {
              hitoMap[key.toString()] = (entry.value as Map)[key];
            }
            title = hitoMap['title'] ?? entry.key;
            description = hitoMap['description'] ?? '';
          } else {
            title = entry.key;
            description = entry.value.toString();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Si el timeline está vacío y no hay hitos, mostrar mensaje
    if (_anteproject.timeline.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Text(
        l10n.noMilestonesDefined,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (hasRevisionDates) {
      // Mostrar fechas de revisión formateadas
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: timelineEntries.map((entry) {
          final value = entry.value.toString();
          final parts = value.split(': ');
          final date = parts.isNotEmpty ? parts[0] : '';
          final description = parts.length > 1
              ? parts.sublist(1).join(': ')
              : value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    } else {
      // Mostrar hitos tradicionales
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: timelineEntries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (entry.value is String && entry.value.isNotEmpty)
                        Text(
                          entry.value,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildCommentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chat, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.comments,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_comments.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_comments.length}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _viewComments,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(AppLocalizations.of(context)!.viewAll),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Mostrar comentarios recientes (máximo 3)
            if (_isLoadingComments)
              const Center(child: CircularProgressIndicator())
            else if (_comments.isEmpty)
              _buildEmptyCommentsState()
            else
              _buildRecentComments(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCommentsState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 32,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noCommentsYet,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.commentsWillAppearHere,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentComments() {
    // Mostrar los 3 comentarios más recientes
    final recentComments = _comments.take(3).toList();

    return Column(
      children: [
        ...recentComments.map(_buildCommentPreview),
        if (_comments.length > 3) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _viewComments,
              child: Text(
                AppLocalizations.of(
                  context,
                )!.viewMoreComments(_comments.length - 3),
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentPreview(AnteprojectComment comment) {
    final l10n = AppLocalizations.of(context)!;
    final authorName = comment.author?.fullName ?? l10n.unknownUser;
    final authorRole = comment.author?.role ?? UserRole.student;
    final isTutor = authorRole == UserRole.tutor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTutor ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTutor ? Colors.blue.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isTutor ? Icons.school : Icons.person,
                size: 16,
                color: isTutor ? Colors.blue.shade600 : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                authorName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isTutor ? Colors.blue.shade700 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200, width: 0.5),
                ),
                child: Text(
                  comment.section.getDisplayName(context),
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(comment.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.dates,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              AppLocalizations.of(context)!.created,
              _formatDate(_anteproject.createdAt),
            ),
            _buildInfoRow(
              AppLocalizations.of(context)!.lastUpdate,
              _formatDate(_anteproject.updatedAt),
            ),
            if (_anteproject.submittedAt != null)
              _buildInfoRow(
                AppLocalizations.of(context)!.submitted,
                _formatDate(_anteproject.submittedAt!),
              ),
            if (_anteproject.reviewedAt != null)
              _buildInfoRow(
                AppLocalizations.of(context)!.reviewed,
                _formatDate(_anteproject.reviewedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: isUrl
                ? InkWell(
                    onTap: () async {
                      final uri = Uri.parse(value);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.invalidUrl,
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Colors.blue[700],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Icon(Icons.open_in_new, size: 16, color: Colors.blue[700]),
                      ],
                    ),
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }

  void _viewComments() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                AnteprojectCommentsScreen(anteproject: _anteproject),
          ),
        )
        .then((_) {
          // Recargar comentarios al volver
          _loadComments();
        });
  }

  void _editAnteproject() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                AnteprojectEditForm(anteproject: _anteproject),
          ),
        )
        .then((_) {
          // Recargar el anteproyecto después de editar
          _reloadAnteproject();
        });
  }

  void _deleteAnteproject() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.anteprojectDeleteTitle),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este anteproyecto? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performDeleteAnteproject();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.anteprojectDeleteButton),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAnteproject() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _anteprojectsService.deleteAnteproject(_anteproject.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.anteprojectDeletedSuccess,
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Volver a la lista de anteproyectos
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.errorDeletingAnteproject(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _approveAnteproject() {
    showDialog(
      context: context,
      builder: (context) => _ApprovalDialog(
        anteproject: _anteproject,
        isApproval: true,
        onConfirm: (comments, timeline) async {
          setState(() {
            _isLoading = true;
          });

          // Capturar el context antes de la operación async
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          final localizations = AppLocalizations.of(context)!;

          try {
            await _anteprojectsService.approveAnteproject(
              _anteproject.id,
              comments,
              timeline: timeline,
            );
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(localizations.anteprojectApprovedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
              navigator.pop();
            }
          } catch (e) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    localizations.errorApprovingAnteproject(e.toString()),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
      ),
    );
  }

  void _rejectAnteproject() {
    showDialog(
      context: context,
      builder: (context) => _ApprovalDialog(
        anteproject: _anteproject,
        isApproval: false,
        onConfirm: (comments, timeline) async {
          setState(() {
            _isLoading = true;
          });

          // Capturar el context antes de la operación async
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          final localizations = AppLocalizations.of(context)!;

          try {
            await _anteprojectsService.rejectAnteproject(
              _anteproject.id,
              comments,
            );
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(localizations.anteprojectRejected),
                  backgroundColor: Colors.orange,
                ),
              );
              navigator.pop();
            }
          } catch (e) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    localizations.errorRejectingAnteproject(e.toString()),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
      ),
    );
  }

  void _manageSchedule() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ScheduleManagementScreen(
              anteproject: _anteproject,
              tutorId:
                  _anteproject.tutorId ??
                  1, // Usar el tutor asignado al anteproyecto
            ),
          ),
        )
        .then((saved) {
          if (saved == true) {
            // Recargar el cronograma y el anteproyecto si se guardó
            _loadSchedule();
            _reloadAnteproject();
          }
        });
  }

  Future<void> _reloadAnteproject() async {
    try {
      final updatedAnteproject = await _anteprojectsService.getAnteproject(
        _anteproject.id,
      );
      if (mounted && updatedAnteproject != null) {
        setState(() {
          _anteproject = updatedAnteproject;
        });
      }
    } catch (e) {
      // Error al recargar, pero no interrumpir el flujo
      debugPrint('Error al recargar anteproyecto: $e');
    }
  }

  Widget _buildSubmitForApprovalCard() {
    final l10n = AppLocalizations.of(context)!;
    final hasApproved = _hasApprovedAnteproject ?? false;
    
    return Card(
      color: hasApproved 
          ? Colors.grey.withValues(alpha: 0.1)
          : Colors.orange.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasApproved ? Icons.info_outline : Icons.send,
                  color: hasApproved ? Colors.grey[700] : Colors.orange[700],
                ),
                const SizedBox(width: 8),
                Text(
                  hasApproved 
                      ? l10n.cannotSubmitAnteprojectWithApprovedTitle
                      : 'Enviar para Aprobación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: hasApproved ? Colors.grey[700] : Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hasApproved
                  ? l10n.cannotSubmitAnteprojectWithApproved
                  : 'Una vez que envíes tu anteproyecto para aprobación, no podrás editarlo hasta que el tutor lo revise.',
              style: const TextStyle(fontSize: 14),
            ),
            if (!hasApproved) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitForApproval,
                  icon: const Icon(Icons.send),
                  label: Text(l10n.sendForApproval),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _submitForApproval() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.sendForApprovalTitle),
        content: const Text(
          '¿Estás seguro de que quieres enviar este anteproyecto para aprobación? '
          'Una vez enviado, no podrás editarlo hasta que el tutor lo revise.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performSubmitForApproval();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.send),
          ),
        ],
      ),
    );
  }

  Future<void> _performSubmitForApproval() async {
    // Verificar si el estudiante ya tiene un anteproyecto aprobado
    final hasApproved = _hasApprovedAnteproject ?? 
        await _anteprojectsService.hasApprovedAnteproject();
    
    if (hasApproved) {
      final l10n = AppLocalizations.of(context)!;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cannotSubmitAnteprojectWithApproved),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _anteprojectsService.submitAnteprojectForApproval(_anteproject.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.anteprojectSentForApproval,
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Recargar el anteproyecto para actualizar el estado
        _reloadAnteproject();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        // Verificar si es el error específico de anteproyecto aprobado
        if (e.toString().contains('cannot_submit_anteproject_with_approved') ||
            e.toString().contains('cannotSubmitAnteprojectWithApproved')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotSubmitAnteprojectWithApproved),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.errorSendingAnteproject(e.toString()),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Las tareas solo están disponibles para proyectos, no para anteproyectos

  // NUEVOS MÉTODOS PARA PESTAÑAS
  Widget _buildDetailsTab() {
    return _buildAnteprojectDetails();
  }

  Widget _buildAnteprojectDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),

          // Botón de enviar para aprobación (solo para anteproyectos en borrador)
          // Ocultar si hay anteproyecto aprobado o si está cargando la verificación
          if (_anteproject.status == AnteprojectStatus.draft &&
              _hasApprovedAnteproject != null) ...[
            _buildSubmitForApprovalCard(),
            const SizedBox(height: 16),
          ],

          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildDescriptionCard(),
          const SizedBox(height: 16),
          _buildExpectedResultsCard(),
          const SizedBox(height: 16),
          _buildTimelineCard(),
          const SizedBox(height: 16),
          _buildCommentsSection(),
          const SizedBox(height: 16),
          _buildDatesCard(),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comentarios del anteproyecto (siempre visible)
          _buildAnteprojectCommentsSection(),

          // Comentarios del proyecto (solo si está en modo proyecto)
          if (widget.project != null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildProjectCommentsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildAnteprojectCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              widget.project != null
                  ? AppLocalizations.of(context)!.anteprojectHistoryComments
                  : AppLocalizations.of(context)!.comments,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingComments)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          _buildEmptyCommentsState()
        else
          ..._comments.map(_buildCommentPreview),
      ],
    );
  }

  Widget _buildProjectCommentsSection() {
    // TODO: Implementar cuando exista ProjectCommentsService
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.chat, color: Colors.green.shade600),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.projectComments,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Función en desarrollo...'),
      ],
    );
  }

  Widget _buildFilesTab() {
    // Si hay un proyecto asociado, usar 'project', sino usar 'anteproject'
    final attachableType = widget.project != null ? 'project' : 'anteproject';
    final attachableId = widget.project != null ? widget.project!.id : widget.anteproject.id;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.attachedFiles,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          FileListWidget(
            attachableType: attachableType,
            attachableId: attachableId,
            showUploadButton: true,
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanTab() {
    if (widget.project == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.kanbanOnlyForProjects,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return KanbanBoard(projectId: widget.project!.id, isEmbedded: true);
  }

  Widget _buildTasksListTab() {
    if (widget.project == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.kanbanOnlyForProjects,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Envolver con BlocProvider para TasksBloc
    return BlocProvider<TasksBloc>(
      create: (context) =>
          TasksBloc(tasksService: TasksService())
            ..add(TasksLoadRequested(projectId: widget.project!.id)),
      child: _buildTasksListContent(),
    );
  }

  Widget _buildTasksListContent() {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        if (state is TasksLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TasksFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  state.messageKey,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<TasksBloc>().add(
                    TasksLoadRequested(projectId: widget.project!.id),
                  ),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        } else if (state is TasksLoaded) {
          final tasks = state.tasks;

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    l10n.tasksListEmpty,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _createTask,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.taskCreateButton),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TasksBloc>().add(
                TasksLoadRequested(projectId: widget.project!.id),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskCard(task, l10n);
              },
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildTaskCard(Task task, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.status.isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(task.status, l10n),
                const SizedBox(width: 8),
                _buildComplexityChip(task.complexity, l10n),
              ],
            ),
            if (task.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.taskDueDate}: ${_formatDate(task.dueDate!)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTaskAction(value, task),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  const Icon(Icons.visibility),
                  const SizedBox(width: 8),
                  Text(l10n.viewDetails),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(l10n.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _viewTaskDetails(task),
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status, AppLocalizations l10n) {
    Color color;
    String statusText;
    switch (status) {
      case TaskStatus.pending:
        color = Colors.orange;
        statusText = l10n.taskStatusPending;
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        statusText = l10n.taskStatusInProgress;
        break;
      case TaskStatus.underReview:
        color = Colors.purple;
        statusText = l10n.taskStatusUnderReview;
        break;
      case TaskStatus.completed:
        color = Colors.green;
        statusText = l10n.taskStatusCompleted;
        break;
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildComplexityChip(
    TaskComplexity complexity,
    AppLocalizations l10n,
  ) {
    Color color;
    String complexityText;
    switch (complexity) {
      case TaskComplexity.simple:
        color = Colors.green;
        complexityText = l10n.taskComplexitySimple;
        break;
      case TaskComplexity.medium:
        color = Colors.orange;
        complexityText = l10n.taskComplexityMedium;
        break;
      case TaskComplexity.complex:
        color = Colors.red;
        complexityText = l10n.taskComplexityComplex;
        break;
    }

    return Chip(
      label: Text(
        complexityText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _createTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskForm(projectId: widget.project!.id),
      ),
    );
  }

  void _viewTaskDetails(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
  }

  void _handleTaskAction(String action, Task task) {
    switch (action) {
      case 'view':
        _viewTaskDetails(task);
        break;
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                TaskForm(task: task, projectId: widget.project!.id),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(task);
        break;
    }
  }

  void _showDeleteConfirmation(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta tarea?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TasksBloc>().add(TaskDeleteRequested(task.id));
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}

class _ApprovalDialog extends StatefulWidget {
  final Anteproject anteproject;
  final bool isApproval;
  final Function(String, Map<String, dynamic>?) onConfirm;

  const _ApprovalDialog({
    required this.anteproject,
    required this.isApproval,
    required this.onConfirm,
  });

  @override
  State<_ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<_ApprovalDialog> {
  final TextEditingController _commentsController = TextEditingController();
  final List<MapEntry<DateTime, String>> _timelineDates = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _addTimelineDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null) return;

    final descriptionController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descripción de la fecha'),
        content: TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'Ej: Inicio, Revisión final, Presentación...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Añadir'),
          ),
        ],
      ),
    );

    if (confirmed == true && descriptionController.text.trim().isNotEmpty) {
      setState(() {
        _timelineDates.add(MapEntry(date, descriptionController.text.trim()));
        // Ordenar por fecha
        _timelineDates.sort((a, b) => a.key.compareTo(b.key));
      });
    }
  }

  void _removeTimelineDate(int index) {
    setState(() {
      _timelineDates.removeAt(index);
    });
  }

  Map<String, dynamic> _buildTimelineMap() {
    if (_timelineDates.isEmpty) return {};

    final timeline = <String, String>{};
    for (final entry in _timelineDates) {
      final dateStr =
          '${entry.key.day.toString().padLeft(2, '0')}/'
          '${entry.key.month.toString().padLeft(2, '0')}/'
          '${entry.key.year}';
      timeline[dateStr] = entry.value;
    }
    return {'fechas': timeline};
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.isApproval ? l10n.approveAnteproject : l10n.rejectAnteproject,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.anteprojectTitle}: ${widget.anteproject.title}'),
            const SizedBox(height: 16),
            Text(
              widget.isApproval
                  ? l10n.confirmApproveAnteproject
                  : l10n.confirmRejectAnteproject,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentsController,
              decoration: InputDecoration(
                labelText: 'Comentarios (opcional)',
                hintText: widget.isApproval
                    ? 'Comentarios sobre la aprobación...'
                    : 'Motivo del rechazo...',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            // Selector de temporalización (solo para aprobación)
            if (widget.isApproval) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Temporalización',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: Colors.blue,
                    onPressed: _addTimelineDate,
                    tooltip: 'Añadir fecha',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_timelineDates.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Añade fechas importantes del proyecto usando el botón +',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...List.generate(_timelineDates.length, (index) {
                  final entry = _timelineDates[index];
                  final dateStr =
                      '${entry.key.day.toString().padLeft(2, '0')}/'
                      '${entry.key.month.toString().padLeft(2, '0')}/'
                      '${entry.key.year}';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, size: 20),
                      title: Text(
                        '● $dateStr: ${entry.value}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.red,
                        onPressed: () => _removeTimelineDate(index),
                      ),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });

                  final timeline = widget.isApproval
                      ? _buildTimelineMap()
                      : null;
                  widget.onConfirm(_commentsController.text.trim(), timeline);
                  Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isApproval ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.isApproval ? l10n.approve : l10n.reject),
        ),
      ],
    );
  }
}
