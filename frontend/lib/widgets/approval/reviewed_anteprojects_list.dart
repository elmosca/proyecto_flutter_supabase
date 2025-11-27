import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/approval_bloc.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import 'anteproject_approval_card.dart';

class ReviewedAnteprojectsList extends StatelessWidget {
  final List<Map<String, dynamic>> anteprojects;

  const ReviewedAnteprojectsList({
    super.key,
    required this.anteprojects,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (anteprojects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noReviewedAnteprojects,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noDataDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ApprovalBloc>().add(const RefreshApprovals());
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.reviewedAnteprojects,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${anteprojects.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: anteprojects.length,
                itemBuilder: (context, index) {
                  final anteprojectData = anteprojects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnteprojectApprovalCard(
                      anteprojectData: anteprojectData,
                      showActions: false, // No mostrar acciones para anteproyectos ya revisados
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
