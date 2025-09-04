import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/anteprojects_bloc.dart';
import '../../models/anteproject.dart';

class AnteprojectForm extends StatefulWidget {
  const AnteprojectForm({super.key});

  @override
  State<AnteprojectForm> createState() => _AnteprojectFormState();
}

class _AnteprojectFormState extends State<AnteprojectForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController(text: '2024-2025');
  final TextEditingController _expectedResultsController = TextEditingController(text: '{"milestone1":"Definir alcance"}');
  final TextEditingController _timelineController = TextEditingController(text: '{"phase1":"Planificación"}');
  final TextEditingController _tutorIdController = TextEditingController();

  ProjectType? _projectType = ProjectType.execution;

  bool _isSubmitting = false;

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

    final Anteproject anteproject = Anteproject(
      id: 0, // ID temporal, el backend asignará el definitivo
      title: _titleController.text.trim(),
      projectType: _projectType ?? ProjectType.execution,
      description: _descriptionController.text.trim(),
      academicYear: _academicYearController.text.trim(),
      expectedResults: expectedResults,
      timeline: timeline,
      status: AnteprojectStatus.draft,
      tutorId: tutorId,
      submittedAt: null,
      reviewedAt: null,
      projectId: null,
      tutorComments: null,
      createdAt: now,
      updatedAt: now,
    );

    setState(() {
      _isSubmitting = true;
    });

    context.read<AnteprojectsBloc>().add(AnteprojectCreateRequested(anteproject));
  }

  @override
  Widget build(BuildContext context) {
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
            const SnackBar(content: Text('Anteproyecto creado exitosamente')),
          );
          _formKey.currentState!.reset();
        }

        if (state is AnteprojectsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Anteproyecto'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
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
                  onChanged: (ProjectType? value) => setState(() => _projectType = value),
                ),
                const SizedBox(height: 16),
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
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Crear anteproyecto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


