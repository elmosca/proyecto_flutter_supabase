import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/approval_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../services/settings_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_handler_widget.dart';
import '../../widgets/approval/pending_approvals_list.dart';
import '../../widgets/approval/reviewed_anteprojects_list.dart';
import '../../widgets/navigation/app_bar_actions.dart';

class ApprovalScreen extends StatefulWidget {
  final int? selectedTutorId;
  final bool showBackButton;
  /// Si es true, usa Scaffold propio (para Navigator.push desde dashboard)
  /// Si es false, solo retorna el contenido (para usar con PersistentScaffold en router)
  final bool useOwnScaffold;

  const ApprovalScreen({
    super.key,
    this.selectedTutorId,
    this.showBackButton = false,
    this.useOwnScaffold = false,
  });

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _currentUser;
  final SettingsService _settingsService = SettingsService();
  String _selectedAcademicYear = 'all';
  List<String> _academicYears = [];
  
  // Filtro de estado para anteproyectos revisados
  String _selectedReviewedStatus = 'all'; // 'all', 'approved', 'rejected'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    if (widget.useOwnScaffold) {
      _loadCurrentUser();
    }

    // Cargar los datos iniciales
    _loadAcademicYears();
    context.read<ApprovalBloc>().add(
      LoadPendingApprovals(
        tutorId: widget.selectedTutorId,
        academicYear: _selectedAcademicYear == 'all' ? null : _selectedAcademicYear,
      ),
    );
  }

  Future<void> _loadCurrentUser() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _currentUser = authState.user;
      });
    }
  }

  Future<void> _loadAcademicYears() async {
    // Extraer años académicos de los anteproyectos cargados
    // Esto se actualizará cuando se carguen los datos
    final years = <String>{};
    
    // También intentar obtener el año activo del sistema
    try {
      final activeYear = await _settingsService.getStringSetting('academic_year');
      if (activeYear != null && activeYear.isNotEmpty) {
        years.add(activeYear);
      }
    } catch (e) {
      debugPrint('Error cargando año académico activo: $e');
    }
    
    if (mounted) {
      setState(() {
        _academicYears = years.toList()..sort((a, b) => b.compareTo(a));
      });
    }
  }

  void _onAcademicYearChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedAcademicYear = value;
      });
      // Recargar datos con el nuevo filtro
      context.read<ApprovalBloc>().add(
        LoadPendingApprovals(
          tutorId: widget.selectedTutorId,
          academicYear: value == 'all' ? null : value,
        ),
      );
    }
  }

  void _onReviewedStatusChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedReviewedStatus = value;
      });
    }
  }

  /// Filtra los anteproyectos revisados por estado
  List<Map<String, dynamic>> _filterReviewedByStatus(List<Map<String, dynamic>> anteprojects) {
    if (_selectedReviewedStatus == 'all') {
      return anteprojects;
    }
    
    return anteprojects.where((anteprojectData) {
      final status = anteprojectData['status']?.toString();
      return status == _selectedReviewedStatus;
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Si necesita Scaffold propio (acceso desde dashboard)
    if (widget.useOwnScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.approvalWorkflow),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: const Icon(Icons.pending_actions),
                text: l10n.pendingApprovals,
              ),
              Tab(
                icon: const Icon(Icons.history),
                text: l10n.reviewedAnteprojects,
              ),
            ],
          ),
          actions: _currentUser != null
              ? AppBarActions.build(
                  context,
                  _currentUser!,
                  additionalActions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<ApprovalBloc>().add(
                          LoadPendingApprovals(
                            tutorId: widget.selectedTutorId,
                            academicYear: _selectedAcademicYear == 'all' ? null : _selectedAcademicYear,
                          ),
                        );
                      },
                      tooltip: l10n.refresh,
                    ),
                  ],
                )
              : [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<ApprovalBloc>().add(
                        LoadPendingApprovals(
                          tutorId: widget.selectedTutorId,
                          academicYear: _selectedAcademicYear == 'all' ? null : _selectedAcademicYear,
                        ),
                      );
                    },
                    tooltip: l10n.refresh,
                  ),
                ],
        ),
        body: _buildTabBarView(l10n),
      );
    }

    // Si usa PersistentScaffold (acceso desde router/drawer)
    // Retornar solo el contenido sin Scaffold
    return Column(
      children: [
        // TabBar manual integrado en el contenido
        Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: const Icon(Icons.pending_actions),
                text: l10n.pendingApprovals,
              ),
              Tab(
                icon: const Icon(Icons.history),
                text: l10n.reviewedAnteprojects,
              ),
            ],
          ),
        ),
        
        // TabBarView
        Expanded(
          child: _buildTabBarView(l10n),
        ),
      ],
    );
  }

  /// Construye el TabBarView con las dos pestañas
  Widget _buildTabBarView(AppLocalizations l10n) {
    return BlocListener<ApprovalBloc, ApprovalState>(
      listener: (context, state) {
        if (state is ApprovalSuccess) {
          String message;
          switch (state.action) {
            case ApprovalAction.approve:
              message = l10n.approvalSuccess;
              break;
            case ApprovalAction.reject:
              message = l10n.rejectionSuccess;
              break;
            case ApprovalAction.requestChanges:
              message = l10n.changesSuccess;
              break;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ApprovalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ApprovalLoaded) {
          // Extraer años académicos de los datos cargados (en el listener, no en el builder)
          _updateAcademicYearsFromData(state.pendingApprovals, state.reviewedAnteprojects);
        }
      },
      child: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de aprobaciones pendientes
          BlocBuilder<ApprovalBloc, ApprovalState>(
            builder: (context, state) {
              if (state is ApprovalLoading) {
                return const LoadingWidget();
              } else if (state is ApprovalError) {
                return ErrorHandlerWidget(
                  error: state.message,
                  onRetry: () {
                    context.read<ApprovalBloc>().add(
                      const LoadPendingApprovals(),
                    );
                  },
                );
              } else if (state is ApprovalLoaded) {
                return _buildContentWithFilter(
                  l10n,
                  PendingApprovalsList(anteprojects: state.pendingApprovals),
                );
              } else if (state is ApprovalProcessing) {
                return const LoadingWidget();
              }

              return const LoadingWidget();
            },
          ),

          // Pestaña de anteproyectos revisados
          BlocBuilder<ApprovalBloc, ApprovalState>(
            builder: (context, state) {
              if (state is ApprovalLoading) {
                return const LoadingWidget();
              } else if (state is ApprovalError) {
                return ErrorHandlerWidget(
                  error: state.message,
                  onRetry: () {
                    context.read<ApprovalBloc>().add(
                      const LoadReviewedAnteprojects(),
                    );
                  },
                );
              } else if (state is ApprovalLoaded) {
                // Filtrar por estado
                final filteredAnteprojects = _filterReviewedByStatus(state.reviewedAnteprojects);
                return _buildReviewedContentWithFilters(
                  l10n,
                  filteredAnteprojects,
                );
              } else if (state is ApprovalProcessing) {
                return const LoadingWidget();
              }

              return const LoadingWidget();
            },
          ),
        ],
      ),
    );
  }

  /// Construye el contenido con el filtro de año académico (para pendientes)
  Widget _buildContentWithFilter(AppLocalizations l10n, Widget listWidget) {
    return Column(
      children: [
        // Filtro de año académico
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              Text(l10n.year),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedAcademicYear,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem<String>(
                      value: 'all',
                      child: Text(l10n.all),
                    ),
                    ..._academicYears.map((year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }),
                  ],
                  onChanged: _onAcademicYearChanged,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: listWidget),
      ],
    );
  }

  /// Construye el contenido con filtros de año académico y estado (para revisados)
  Widget _buildReviewedContentWithFilters(
    AppLocalizations l10n,
    List<Map<String, dynamic>> filteredAnteprojects,
  ) {
    return Column(
      children: [
        // Filtros: año académico y estado
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Column(
            children: [
              // Filtro de año académico
              Row(
                children: [
                  Text(l10n.year),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedAcademicYear,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String>(
                          value: 'all',
                          child: Text(l10n.all),
                        ),
                        ..._academicYears.map((year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(year),
                          );
                        }),
                      ],
                      onChanged: _onAcademicYearChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Filtro de estado
              Row(
                children: [
                  Text(l10n.filterByStatus),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedReviewedStatus,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String>(
                          value: 'all',
                          child: Text(l10n.all),
                        ),
                        DropdownMenuItem<String>(
                          value: 'approved',
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Text(l10n.approved),
                            ],
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'rejected',
                          child: Row(
                            children: [
                              const Icon(Icons.cancel, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Text(l10n.rejected),
                            ],
                          ),
                        ),
                      ],
                      onChanged: _onReviewedStatusChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ReviewedAnteprojectsList(anteprojects: filteredAnteprojects),
        ),
      ],
    );
  }

  /// Actualiza la lista de años académicos disponibles desde los datos cargados
  void _updateAcademicYearsFromData(
    List<Map<String, dynamic>> pendingApprovals,
    List<Map<String, dynamic>> reviewedAnteprojects,
  ) {
    final years = <String>{};
    
    for (final anteprojectData in pendingApprovals) {
      if (anteprojectData.containsKey('academic_year')) {
        final year = anteprojectData['academic_year']?.toString();
        if (year != null && year.isNotEmpty) {
          years.add(year);
        }
      }
    }
    
    for (final anteprojectData in reviewedAnteprojects) {
      if (anteprojectData.containsKey('academic_year')) {
        final year = anteprojectData['academic_year']?.toString();
        if (year != null && year.isNotEmpty) {
          years.add(year);
        }
      }
    }
    
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    
    // Solo actualizar si hay cambios
    if (sortedYears.join(',') != _academicYears.join(',')) {
      setState(() {
        _academicYears = sortedYears;
      });
    }
  }
}
