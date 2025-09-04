import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/anteprojects_bloc.dart';
import '../../models/anteproject.dart';

class AnteprojectEditForm extends StatefulWidget {
  final Anteproject anteproject;

  const AnteprojectEditForm({
    super.key,
    required this.anteproject,
  });

  @override
  State<AnteprojectEditForm> createState() => _AnteprojectEditFormState();
}

class _AnteprojectEditFormState extends State<AnteprojectEditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _academicYearController;
  late final TextEditingController _expectedResultsController;
  late final TextEditingController _timelineController;
  late final TextEditingController _tutorIdController;

  late ProjectType _projectType;
  late AnteprojectStatus _status;

  bool _isSubmitting = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.anteproject.title);
    _descriptionController = TextEditingController(text: widget.anteproject.description);
    _academicYearController = TextEditingController(text: widget.anteproject.academicYear);
    _expectedResultsController = TextEditingController(
      text: jsonEncode(widget.anteproject.expectedResults),
    );
    _timelineController = TextEditingController(
      text: jsonEncode(widget.anteproject.timeline),
    );
    _tutorIdController = TextEditingController(text: widget.anteproject.tutorId.toString());

    _projectType = widget.anteproject.projectType;
    _status = widget.anteproject.status;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _academicYearController.dispose();
    _expectedResultsController.dispose();
    _timelineController.dispose();
    _tutorIdController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _tryParseJsonOrEmpty(String input) {
    if (input.trim().isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final dynamic parsed = jsonDecode(input);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> expectedResults = _tryParseJsonOrEmpty(_expectedResultsController.text);
    final Map<String, dynamic> timeline = _tryParseJsonOrEmpty(_timelineController.text);

    final int? tutorId = int.tryParse(_tutorIdController.text.trim());
    if (tutorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutor ID inválido')),
      );
      return;
    }

    final DateTime now = DateTime.now();

    final Anteproject updatedAnteproject = widget.anteproject.copyWith(
      title: _titleController.text.trim(),
      projectType: _projectType,
      description: _descriptionController.text.trim(),
      academicYear: _academicYearController.text.trim(),
      expectedResults: expectedResults,
      timeline: timeline,
      status: _status,
      tutorId: tutorId,
      updatedAt: now,
    );

    setState(() {
      _isSubmitting = true;
    });

    context.read<AnteprojectsBloc>().add(AnteprojectUpdateRequested(updatedAnteproject));
  }

  void _deleteAnteproject() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Anteproyecto'),
          content: const Text('¿Estás seguro de que quieres eliminar este anteproyecto? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AnteprojectsBloc>().add(AnteprojectDeleteRequested(widget.anteproject.id));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocListener<AnteprojectsBloc, AnteprojectsState>(
      listener: (BuildContext context, AnteprojectsState state) {
        if (state is AnteprojectsLoading) {
          setState(() {
            _isSubmitting = true;
          });
        } else {
          setState(() {
            _isSubmitting = false;
          });
        }

        if (state is AnteprojectOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anteproyecto actualizado exitosamente')),
          );
          Navigator.of(context).pop();
        }

        if (state is AnteprojectsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Anteproyecto'),
          actions: [
            if (widget.anteproject.status == AnteprojectStatus.draft)
              IconButton(
                onPressed: _deleteAnteproject,
                icon: const Icon(Icons.delete),
                tooltip: 'Eliminar anteproyecto',
              ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                // Información del estado actual
                Card(
                  color: _getStatusColor().withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(_getStatusIcon(), color: _getStatusColor()),
                        const SizedBox(width: 8),
                        Text(
                          'Estado: ${_status.displayName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de título
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) =>
                      (value == null || value.trim().isEmpty) ? 'El título es obligatorio' : null,
                ),
                const SizedBox(height: 16),

                // Tipo de proyecto
                DropdownButtonFormField<ProjectType>(
                  value: _projectType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de proyecto',
                    border: OutlineInputBorder(),
                  ),
                  items: ProjectType.values
                      .map(
                        (ProjectType type) => DropdownMenuItem<ProjectType>(
                          value: type,
                          child: Text(type.shortName),
                        ),
                      )
                      .toList(),
                  onChanged: (ProjectType? value) => setState(() => _projectType = value!),
                ),
                const SizedBox(height: 16),

                // Estado del anteproyecto (solo si es borrador)
                if (widget.anteproject.status == AnteprojectStatus.draft)
                  DropdownButtonFormField<AnteprojectStatus>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      AnteprojectStatus.draft,
                      AnteprojectStatus.submitted,
                    ]
                        .map(
                          (AnteprojectStatus status) => DropdownMenuItem<AnteprojectStatus>(
                            value: status,
                            child: Text(status.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (AnteprojectStatus? value) => setState(() => _status = value!),
                  ),
                if (widget.anteproject.status == AnteprojectStatus.draft)
                  const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) =>
                      (value == null || value.trim().isEmpty) ? 'La descripción es obligatoria' : null,
                ),
                const SizedBox(height: 16),

                // Año académico
                TextFormField(
                  controller: _academicYearController,
                  decoration: const InputDecoration(
                    labelText: 'Año académico (e.g., 2024-2025)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) =>
                      (value == null || value.trim().isEmpty) ? 'El año académico es obligatorio' : null,
                ),
                const SizedBox(height: 16),

                // Resultados esperados
                TextFormField(
                  controller: _expectedResultsController,
                  minLines: 3,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Resultados esperados (JSON)',
                    hintText: '{"milestone1":"Descripción"}',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Temporalización
                TextFormField(
                  controller: _timelineController,
                  minLines: 3,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Temporalización (JSON)',
                    hintText: '{"phase1":"Descripción"}',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Tutor ID
                TextFormField(
                  controller: _tutorIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tutor ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El Tutor ID es obligatorio';
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return 'El Tutor ID debe ser numérico';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Actualizar anteproyecto'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case AnteprojectStatus.draft:
        return Colors.grey;
      case AnteprojectStatus.submitted:
        return Colors.blue;
      case AnteprojectStatus.underReview:
        return Colors.orange;
      case AnteprojectStatus.approved:
        return Colors.green;
      case AnteprojectStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
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
}
