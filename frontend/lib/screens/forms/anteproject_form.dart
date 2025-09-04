import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/anteprojects_bloc.dart';
import '../../models/anteproject.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/form_validators.dart';
import '../../widgets/common/error_handler_widget.dart';
import '../../widgets/common/loading_widget.dart';

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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.anteprojectInvalidTutorId)),
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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.anteprojectCreatedSuccess)),
          );
          _formKey.currentState!.reset();
        }

        if (state is AnteprojectsFailure) {
          ErrorSnackBar.show(
            context,
            error: state.message,
          );
        }
      },
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.anteprojectFormTitle),
            ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.anteprojectTitle,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? value) => FormValidators.anteprojectTitle(value, context),
                ),
                const SizedBox(height: 16),
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
                  onChanged: (ProjectType? value) => setState(() => _projectType = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: l10n.anteprojectDescription,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? value) => FormValidators.anteprojectDescription(value, context),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _academicYearController,
                  decoration: InputDecoration(
                    labelText: l10n.anteprojectAcademicYear,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? value) => FormValidators.academicYear(value, context),
                ),
                const SizedBox(height: 16),
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
                TextFormField(
                  controller: _tutorIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.anteprojectTutorId,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? value) => FormValidators.tutorId(value, context),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: LoadingButton(
                    text: l10n.anteprojectCreateButton,
                    onPressed: _submit,
                    isLoading: _isSubmitting,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
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
}


