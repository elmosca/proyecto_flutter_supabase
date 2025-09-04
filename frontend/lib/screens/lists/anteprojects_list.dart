import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/anteprojects_bloc.dart';
import '../../models/anteproject.dart';
import '../../services/anteprojects_service.dart';
import '../forms/anteproject_edit_form.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Anteproyectos'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AnteprojectsBloc>().add(AnteprojectsLoadRequested());
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: BlocBuilder<AnteprojectsBloc, AnteprojectsState>(
        builder: (BuildContext context, AnteprojectsState state) {
          if (state is AnteprojectsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AnteprojectsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar anteproyectos',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AnteprojectsBloc>().add(AnteprojectsLoadRequested());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
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
                      'No tienes anteproyectos',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu primer anteproyecto para comenzar',
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
                return _buildAnteprojectCard(anteproject);
              },
            );
          }

          return const Center(child: Text('Estado no reconocido'));
        },
      ),
    );
  }

  Widget _buildAnteprojectCard(Anteproject anteproject) {
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

              // Información adicional
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
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Editar',
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
    Color textColor = Colors.white;

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
        style: TextStyle(
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
        builder: (BuildContext context) => BlocProvider<AnteprojectsBloc>(
          create: (_) => AnteprojectsBloc(
            anteprojectsService: AnteprojectsService(),
          ),
          child: AnteprojectEditForm(anteproject: anteproject),
        ),
      ),
    );
  }
}
