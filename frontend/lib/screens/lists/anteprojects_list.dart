import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/anteprojects_bloc.dart';
import '../../models/anteproject.dart';
import '../../services/anteprojects_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/error_handler_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../anteprojects/anteproject_detail_screen.dart';

class AnteprojectsList extends StatefulWidget {
  const AnteprojectsList({super.key});

  @override
  State<AnteprojectsList> createState() => _AnteprojectsListState();
}

class _AnteprojectsListState extends State<AnteprojectsList> {
  @override
  void initState() {
    super.initState();
    // Cargar anteproyectos al inicializar
    context.read<AnteprojectsBloc>().add(AnteprojectsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.anteprojectsListTitle),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AnteprojectsBloc>().add(AnteprojectsLoadRequested());
            },
            icon: const Icon(Icons.refresh),
            tooltip: l10n.anteprojectsListRefresh,
          ),
        ],
      ),
      body: BlocBuilder<AnteprojectsBloc, AnteprojectsState>(
        builder: (BuildContext context, AnteprojectsState state) {
          if (state is AnteprojectsLoading) {
            return const LoadingWidget();
          }

          if (state is AnteprojectsFailure) {
            return ErrorHandlerWidget(
              error: state.message,
              customTitle: l10n.anteprojectsListError,
              onRetry: () {
                context.read<AnteprojectsBloc>().add(AnteprojectsLoadRequested());
              },
            );
          }

          if (state is AnteprojectsLoaded) {
            if (state.anteprojects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.anteprojectsListEmpty,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.anteprojectsListEmptySubtitle,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.anteprojects.length,
              itemBuilder: (BuildContext context, int index) {
                final Anteproject anteproject = state.anteprojects[index];
                return _buildAnteprojectCard(context, anteproject);
              },
            );
          }

          return Center(child: Text(l10n.anteprojectsListUnknownState));
        },
      ),
    );
  }

  Widget _buildAnteprojectCard(BuildContext context, Anteproject anteproject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToEdit(anteproject),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y estado
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
                  _buildStatusChip(anteproject.status),
                ],
              ),
              const SizedBox(height: 8),

              // Tipo de proyecto
              Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    anteproject.projectType.shortName,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Descripción (truncada)
              Text(
                anteproject.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Información adicional y acciones
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    anteproject.academicYear,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  // Botón de eliminar (solo para borradores)
                  if (anteproject.status == AnteprojectStatus.draft) ...[
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _showDeleteDialog(anteproject),
                      tooltip: 'Eliminar anteproyecto',
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    Icons.visibility,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ver detalles',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(AnteprojectStatus status) {
    Color backgroundColor;
    const Color textColor = Colors.white;

    switch (status) {
      case AnteprojectStatus.draft:
        backgroundColor = Colors.grey;
        break;
      case AnteprojectStatus.submitted:
        backgroundColor = Colors.blue;
        break;
      case AnteprojectStatus.underReview:
        backgroundColor = Colors.orange;
        break;
      case AnteprojectStatus.approved:
        backgroundColor = Colors.green;
        break;
      case AnteprojectStatus.rejected:
        backgroundColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: const TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _navigateToEdit(Anteproject anteproject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnteprojectDetailScreen(anteproject: anteproject),
      ),
    );
  }

  void _showDeleteDialog(Anteproject anteproject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteAnteproject),
          content: Text(
            AppLocalizations.of(context)!.confirmDeleteAnteproject(anteproject.title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAnteproject(anteproject);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAnteproject(Anteproject anteproject) async {
    try {
      final anteprojectsService = AnteprojectsService();
      await anteprojectsService.deleteAnteproject(anteproject.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.anteprojectDeletedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        
        // Recargar la lista
        context.read<AnteprojectsBloc>().add(AnteprojectsLoadRequested());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorDeletingAnteproject(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
