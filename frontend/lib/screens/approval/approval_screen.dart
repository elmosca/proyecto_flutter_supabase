import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/approval_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_handler_widget.dart';
import '../../widgets/approval/pending_approvals_list.dart';
import '../../widgets/approval/reviewed_anteprojects_list.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Cargar los datos iniciales
    context.read<ApprovalBloc>().add(const LoadPendingApprovals());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ApprovalBloc>().add(const RefreshApprovals());
            },
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: BlocListener<ApprovalBloc, ApprovalState>(
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
                      context.read<ApprovalBloc>().add(const LoadPendingApprovals());
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
                      context.read<ApprovalBloc>().add(const LoadReviewedAnteprojects());
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
      ),
    );
  }
}
