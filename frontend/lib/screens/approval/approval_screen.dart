import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/approval_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    if (widget.useOwnScaffold) {
      _loadCurrentUser();
    }

    // Cargar los datos iniciales
    context.read<ApprovalBloc>().add(
      LoadPendingApprovals(tutorId: widget.selectedTutorId),
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
                        context.read<ApprovalBloc>().add(const RefreshApprovals());
                      },
                      tooltip: l10n.refresh,
                    ),
                  ],
                )
              : [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<ApprovalBloc>().add(const RefreshApprovals());
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
                return PendingApprovalsList(
                  anteprojects: state.pendingApprovals,
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
                return ReviewedAnteprojectsList(
                  anteprojects: state.reviewedAnteprojects,
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
}
