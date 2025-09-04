import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/anteprojects_bloc.dart';
import '../../models/anteproject.dart';
import '../../l10n/app_localizations.dart';

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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.anteprojectInvalidTutorId)),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.anteprojectDeleteTitle),
          content: Text(l10n.anteprojectDeleteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AnteprojectsBloc>().add(AnteprojectDeleteRequested(widget.anteproject.id));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.anteprojectDeleteButton),
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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.anteprojectUpdatedSuccess)),
          );
          Navigator.of(context).pop();
        }

        if (state is AnteprojectsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.anteprojectEditFormTitle),
              actions: [
                if (widget.anteproject.status == AnteprojectStatus.draft)
                  IconButton(
                    onPressed: _deleteAnteproject,
                    icon: const Icon(Icons.delete),
                    tooltip: l10n.anteprojectDeleteTooltip,
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
                          l10n.anteprojectStatusLabel(_status.displayName),
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
                  decoration: InputDecoration(
                    labelText: l10n.anteprojectTitle,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? value) =>
                      (value == null || value.trim().isEmpty) ? l10n.anteprojectTitleRequired : null,
                ),
                const SizedBox(height: 16),

                // Tipo de proyecto
                DropdownButtonFormField<ProjectType>(
                  value: _projectType,
                  decoration: InputDecoration(
                    labelText: l10n.anteprojectType,
                    border: const OutlineInputBorder(),
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
                    decoration: InputDecoration(
                      labelText: l10n.anteprojectStatus,
                      border: const OutlineInputBorder(),
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
                  decoration: InputDecoration(
                    labelText: l10n.anteprojectDescription,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? value) =>
                      (value == null || value.trim().isEmpty) ? l10n.anteprojectDescriptionRequired : null,
                ),
                const SizedBox(height: 16),

                // Año académico
                TextFormField(
                  controller: _academicYearController,
                  decoration: InputDecoration(
                    labelText: l10n.anteprojectAcademicYear,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? value) =>
                      (value == null || value.trim().isEmpty) ? l10n.anteprojectAcademicYearRequired : null,
                ),
                const SizedBox(height: 16),

                // Resultados esperados
                TextFormField(
                  controller: _expectedResultsController,
                  minLines: 3,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: l10n.anteprojectExpectedResults,
                    hintText: l10n.anteprojectExpectedResultsHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Temporalización
                TextFormField(
                  controller: _timelineController,
                  minLines: 3,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: l10n.anteprojectTimeline,
                    hintText: l10n.anteprojectTimelineHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Tutor ID
                TextFormField(
                  controller: _tutorIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.anteprojectTutorId,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.anteprojectTutorIdRequired;
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return l10n.anteprojectTutorIdNumeric;
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
                        child: Text(l10n.cancel),
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
                              : Text(l10n.anteprojectUpdateButton),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
          );
        },
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
