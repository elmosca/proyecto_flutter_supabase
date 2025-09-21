import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/anteproject.dart';
import '../../services/anteprojects_service.dart';
import 'anteproject_detail_screen.dart';
import 'anteproject_comments_screen.dart';

class AnteprojectsReviewScreen extends StatefulWidget {
  final String? initialFilter;
  
  const AnteprojectsReviewScreen({super.key, this.initialFilter});

  @override
  State<AnteprojectsReviewScreen> createState() => _AnteprojectsReviewScreenState();
}

class _AnteprojectsReviewScreenState extends State<AnteprojectsReviewScreen> {
  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  List<Anteproject> _anteprojects = [];
  List<Anteproject> _filteredAnteprojects = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Map<String, String> _statusFilters = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _selectedStatus = widget.initialFilter!;
    }
    _loadAnteprojects();
  }

  void _initializeStatusFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _statusFilters = {
      'all': l10n.all,
      'pending': l10n.pending,
      'reviewed': l10n.reviewed,
      'submitted': l10n.submitted,
      'under_review': l10n.underReview,
      'approved': l10n.approved,
      'rejected': l10n.rejected,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnteprojects() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final anteprojects = await _anteprojectsService.getTutorAnteprojects();
      
      if (mounted) {
        setState(() {
          _anteprojects = anteprojects;
          _isLoading = false;
        });
        // Aplicar filtros después de cargar los datos
        _filterAnteprojects();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLoadingAnteprojects(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterAnteprojects() {
    setState(() {
      _filteredAnteprojects = _anteprojects.where((anteproject) {
        // Filtro por estado
        bool statusMatch;
        if (_selectedStatus == 'all') {
          statusMatch = true;
        } else if (_selectedStatus == 'pending') {
          // Pendientes: submitted o under_review
          statusMatch = anteproject.status == AnteprojectStatus.submitted || 
                       anteproject.status == AnteprojectStatus.underReview;
        } else if (_selectedStatus == 'reviewed') {
          // Revisados: approved o rejected
          statusMatch = anteproject.status == AnteprojectStatus.approved || 
                       anteproject.status == AnteprojectStatus.rejected;
        } else {
          // Filtro específico por estado
          statusMatch = anteproject.status.name == _selectedStatus;
        }
        
        // Filtro por búsqueda
        final searchMatch = _searchQuery.isEmpty ||
                          anteproject.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          anteproject.description.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return statusMatch && searchMatch;
      }).toList();
    });
  }

  void _onStatusFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedStatus = value;
      });
      _filterAnteprojects();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _filterAnteprojects();
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

  IconData _getStatusIcon(AnteprojectStatus status) {
    switch (status) {
      case AnteprojectStatus.draft:
        return Icons.edit;
      case AnteprojectStatus.submitted:
        return Icons.send;
      case AnteprojectStatus.underReview:
        return Icons.visibility;
      case AnteprojectStatus.approved:
        return Icons.check_circle;
      case AnteprojectStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getScreenTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_selectedStatus) {
      case 'pending':
        return l10n.pendingAnteprojectsTitle;
      case 'reviewed':
        return l10n.reviewedAnteprojectsTitle;
      case 'submitted':
        return l10n.submittedAnteprojects;
      case 'under_review':
        return l10n.underReviewAnteprojects;
      case 'approved':
        return l10n.approvedAnteprojects;
      case 'rejected':
        return l10n.rejectedAnteprojects;
      default:
        return l10n.anteprojectsReview;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _initializeStatusFilters(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle(context)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnteprojects,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros y búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchAnteprojects,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                // Filtro por estado
                Row(
                  children: [
                    Text(l10n.filterByStatus),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        items: _statusFilters.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: _onStatusFilterChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de anteproyectos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAnteprojects.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAnteprojects.length,
                        itemBuilder: (context, index) {
                          final anteproject = _filteredAnteprojects[index];
                          return _buildAnteprojectCard(anteproject);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String message;
    if (_searchQuery.isNotEmpty) {
      message = l10n.noAnteprojectsFound(_searchQuery);
    } else if (_selectedStatus != 'all') {
      message = l10n.noAnteprojectsWithStatus(_statusFilters[_selectedStatus] ?? '');
    } else {
      message = l10n.noAssignedAnteprojects;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty || _selectedStatus != 'all') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedStatus = 'all';
                });
                _filterAnteprojects();
              },
              child: Text(l10n.clearFilters),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnteprojectCard(Anteproject anteproject) {
    final statusColor = _getStatusColor(anteproject.status);
    final statusIcon = _getStatusIcon(anteproject.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewAnteprojectDetails(anteproject),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y estado
              Row(
                children: [
                  Expanded(
                    child: Text(
                      anteproject.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          anteproject.status.displayName,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                anteproject.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Información adicional
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${AppLocalizations.of(context)!.year} ${anteproject.academicYear}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    anteproject.projectType.displayName,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fechas
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${AppLocalizations.of(context)!.created} ${_formatDate(anteproject.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  if (anteproject.submittedAt != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.send, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${AppLocalizations.of(context)!.submitted} ${_formatDate(anteproject.submittedAt!)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),

              // Acciones para anteproyectos
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón de comentarios (siempre visible)
                  TextButton.icon(
                    onPressed: () => _viewComments(anteproject),
                    icon: const Icon(Icons.chat, color: Colors.blue),
                    label: Text(AppLocalizations.of(context)!.comments, style: const TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(width: 8),
                  
                  // Botones de aprobación/rechazo (solo para enviados/en revisión)
                  if (anteproject.status == AnteprojectStatus.submitted ||
                      anteproject.status == AnteprojectStatus.underReview) ...[
                    TextButton.icon(
                      onPressed: () => _rejectAnteproject(anteproject),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: Text(AppLocalizations.of(context)!.rejectAnteproject, style: const TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _approveAnteproject(anteproject),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: Text(AppLocalizations.of(context)!.approveAnteproject, style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewAnteprojectDetails(Anteproject anteproject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnteprojectDetailScreen(anteproject: anteproject),
      ),
    ).then((_) => _loadAnteprojects()); // Recargar al volver
  }

  void _viewComments(Anteproject anteproject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnteprojectCommentsScreen(anteproject: anteproject),
      ),
    );
  }

  void _approveAnteproject(Anteproject anteproject) {
    showDialog(
      context: context,
      builder: (context) => _ApprovalDialog(
        anteproject: anteproject,
        isApproval: true,
        onConfirm: (comments) async {
          // Capturar el context antes de la operación async
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final l10n = AppLocalizations.of(context)!;
          
          try {
            await _anteprojectsService.approveAnteproject(anteproject.id, comments);
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.anteprojectApprovedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
              _loadAnteprojects();
            }
          } catch (e) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.errorApprovingAnteproject(e.toString())),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _rejectAnteproject(Anteproject anteproject) {
    showDialog(
      context: context,
      builder: (context) => _ApprovalDialog(
        anteproject: anteproject,
        isApproval: false,
        onConfirm: (comments) async {
          // Capturar el context antes de la operación async
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final l10n = AppLocalizations.of(context)!;
          
          try {
            await _anteprojectsService.rejectAnteproject(anteproject.id, comments);
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.anteprojectRejectedSuccess),
                  backgroundColor: Colors.orange,
                ),
              );
              _loadAnteprojects();
            }
          } catch (e) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.errorRejectingAnteproject(e.toString())),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
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
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(
        widget.isApproval ? l10n.approveAnteprojectTitle : l10n.rejectAnteprojectTitle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.anteprojectTitle(widget.anteproject.title)),
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
              labelText: l10n.approvalCommentsOptional,
              hintText: widget.isApproval 
                  ? l10n.approvalCommentsHint
                  : l10n.rejectionCommentsHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
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
              : Text(widget.isApproval ? l10n.approveAnteproject : l10n.rejectAnteproject),
        ),
      ],
    );
  }
}
