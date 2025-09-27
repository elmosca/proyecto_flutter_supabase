import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/anteproject.dart';
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

class AnteprojectDetailScreen extends StatefulWidget {
  final Anteproject anteproject;

  const AnteprojectDetailScreen({super.key, required this.anteproject});

  @override
  State<AnteprojectDetailScreen> createState() => _AnteprojectDetailScreenState();
}

class _AnteprojectDetailScreenState extends State<AnteprojectDetailScreen> {
  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();
  final AnteprojectCommentsService _commentsService = AnteprojectCommentsService();
  late Anteproject _anteproject;
  bool _isLoading = false;
  Schedule? _schedule;
  User? _currentUser;
  List<AnteprojectComment> _comments = [];
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    _anteproject = widget.anteproject;
    _loadSchedule();
    _loadCurrentUser();
    _loadComments();
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

  Future<void> _loadComments() async {
    try {
      setState(() {
        _isLoadingComments = true;
      });

      final comments = await _commentsService.getAnteprojectComments(_anteproject.id);
      
      if (mounted) {
        setState(() {
          _comments = comments;
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
      final schedule = await _scheduleService.getScheduleByAnteproject(_anteproject.id);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.anteprojectDetails),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          
          // Botón de comentarios (siempre visible)
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.blue),
            onPressed: _viewComments,
            tooltip: 'Ver comentarios',
          ),
          
          // Botón de cronograma (solo para aprobados y tutores)
          if (_anteproject.status == AnteprojectStatus.approved && _canEditSchedule()) ...[
            IconButton(
              icon: const Icon(Icons.schedule, color: Colors.blue),
              onPressed: _manageSchedule,
              tooltip: 'Gestionar Cronograma',
            ),
          ],
          
          // Botones de aprobación/rechazo (solo para tutores y anteproyectos enviados/en revisión)
          if ((_anteproject.status == AnteprojectStatus.submitted ||
              _anteproject.status == AnteprojectStatus.underReview) &&
              _currentUser?.role == UserRole.tutor) ...[
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: _isLoading ? null : _rejectAnteproject,
              tooltip: 'Rechazar',
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: _isLoading ? null : _approveAnteproject,
              tooltip: 'Aprobar',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  
                  
                  // Botón de enviar para aprobación (solo para anteproyectos en borrador)
                  if (_anteproject.status == AnteprojectStatus.draft) ...[
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
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            const Text(
              'Información General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Año Académico', _anteproject.academicYear),
            _buildInfoRow('Tipo de Proyecto', _anteproject.projectType.displayName),
            _buildInfoRow('Estado', _anteproject.status.displayName),
            if (_anteproject.tutorId != null)
              _buildInfoRow('ID del Tutor', _anteproject.tutorId.toString()),
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
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
            const Text(
              'Resultados Esperados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                const Text(
                  'Cronograma',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_anteproject.status == AnteprojectStatus.approved && _canEditSchedule())
                  TextButton.icon(
                    onPressed: _manageSchedule,
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(_schedule != null ? 'Editar' : 'Crear'),
                  ),
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
            const Text(
              'Hitos del Proyecto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
        const Text(
          'Fechas de Revisión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
    if (_anteproject.timeline.isEmpty) {
      return Text(
        'No se han definido hitos',
        style: TextStyle(
          color: Colors.grey.shade500,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Verificar si el timeline contiene fechas de revisión (formato del cronograma)
    final timelineEntries = _anteproject.timeline.entries.toList();
    final hasRevisionDates = timelineEntries.any((entry) => 
        entry.key.startsWith('revision_') && 
        entry.value.toString().contains(':'));

    if (hasRevisionDates) {
      // Mostrar fechas de revisión formateadas
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: timelineEntries.map((entry) {
          final value = entry.value.toString();
          final parts = value.split(': ');
          final date = parts.isNotEmpty ? parts[0] : '';
          final description = parts.length > 1 ? parts.sublist(1).join(': ') : value;

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
                const Text(
                  'Comentarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_comments.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            'No hay comentarios aún',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Los comentarios aparecerán aquí cuando el tutor los agregue',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
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
                'Ver ${_comments.length - 3} comentarios más',
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentPreview(AnteprojectComment comment) {
    final authorName = comment.author?.fullName ?? 'Usuario desconocido';
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
                  comment.section.displayName,
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
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
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
            const Text(
              'Fechas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Creado', _formatDate(_anteproject.createdAt)),
            _buildInfoRow('Última actualización', _formatDate(_anteproject.updatedAt)),
            if (_anteproject.submittedAt != null)
              _buildInfoRow('Enviado', _formatDate(_anteproject.submittedAt!)),
            if (_anteproject.reviewedAt != null)
              _buildInfoRow('Revisado', _formatDate(_anteproject.reviewedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _viewComments() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnteprojectCommentsScreen(anteproject: _anteproject),
      ),
    ).then((_) {
      // Recargar comentarios al volver
      _loadComments();
    });
  }

  void _editAnteproject() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnteprojectEditForm(anteproject: _anteproject),
      ),
    ).then((_) {
      // Recargar el anteproyecto después de editar
      _reloadAnteproject();
    });
  }

  void _approveAnteproject() {
    showDialog(
      context: context,
      builder: (context) => _ApprovalDialog(
        anteproject: _anteproject,
        isApproval: true,
        onConfirm: (comments) async {
          setState(() {
            _isLoading = true;
          });
          
          // Capturar el context antes de la operación async
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          final localizations = AppLocalizations.of(context)!;
          
          try {
            await _anteprojectsService.approveAnteproject(_anteproject.id, comments);
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
                  content: Text(localizations.errorApprovingAnteproject(e.toString())),
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
        onConfirm: (comments) async {
          setState(() {
            _isLoading = true;
          });
          
          // Capturar el context antes de la operación async
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          final localizations = AppLocalizations.of(context)!;
          
          try {
            await _anteprojectsService.rejectAnteproject(_anteproject.id, comments);
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
                  content: Text(localizations.errorRejectingAnteproject(e.toString())),
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScheduleManagementScreen(
          anteproject: _anteproject,
          tutorId: _anteproject.tutorId ?? 1, // Usar el tutor asignado al anteproyecto
        ),
      ),
    ).then((saved) {
      if (saved == true) {
        // Recargar el cronograma y el anteproyecto si se guardó
        _loadSchedule();
        _reloadAnteproject();
      }
    });
  }

  Future<void> _reloadAnteproject() async {
    try {
      final updatedAnteproject = await _anteprojectsService.getAnteproject(_anteproject.id);
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
    return Card(
      color: Colors.orange.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.send, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Enviar para Aprobación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Una vez que envíes tu anteproyecto para aprobación, no podrás editarlo hasta que el tutor lo revise.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForApproval,
                icon: const Icon(Icons.send),
                label: Text(AppLocalizations.of(context)!.sendForApproval),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
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
    setState(() {
      _isLoading = true;
    });

    try {
      await _anteprojectsService.submitAnteprojectForApproval(_anteproject.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.anteprojectSentForApproval),
            backgroundColor: Colors.green,
          ),
        );
        // Recargar el anteproyecto para actualizar el estado
        _reloadAnteproject();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSendingAnteproject(e.toString())),
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
}

class _ApprovalDialog extends StatefulWidget {
  final Anteproject anteproject;
  final bool isApproval;
  final Function(String) onConfirm;

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
  bool _isLoading = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isApproval ? 'Aprobar Anteproyecto' : 'Rechazar Anteproyecto',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${AppLocalizations.of(context)!.anteprojectTitle}: ${widget.anteproject.title}'),
          const SizedBox(height: 16),
          Text(
            widget.isApproval 
                ? '¿Estás seguro de que quieres aprobar este anteproyecto?'
                : '¿Estás seguro de que quieres rechazar este anteproyecto?',
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            setState(() {
              _isLoading = true;
            });
            
            widget.onConfirm(_commentsController.text.trim());
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
              : Text(widget.isApproval ? 'Aprobar' : 'Rechazar'),
        ),
      ],
    );
  }
}
