import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/anteprojects_bloc.dart';
import '../../models/anteproject.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/anteprojects_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/form_validators.dart';
import '../../widgets/common/error_handler_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/forms/hitos_list_widget.dart';
import '../schedule/schedule_management_screen.dart';

class AnteprojectEditForm extends StatefulWidget {
  final Anteproject anteproject;

  const AnteprojectEditForm({super.key, required this.anteproject});

  @override
  State<AnteprojectEditForm> createState() => _AnteprojectEditFormState();
}

class _AnteprojectEditFormState extends State<AnteprojectEditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final AnteprojectsService _anteprojectsService = AnteprojectsService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _academicYearController;
  late final TextEditingController _objectivesController;
  late final TextEditingController _timelineController;
  late final TextEditingController _tutorIdController;
  late final TextEditingController _githubRepositoryController;
  late List<Hito> _hitos;

  late ProjectType _projectType;
  late AnteprojectStatus _status;

  bool _isSubmitting = false;
  bool _isLoading = true;
  bool? _hasApprovedAnteproject; // null = cargando, true/false = resultado
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCurrentUser();
    _checkApprovedAnteproject();
  }

  Future<void> _checkApprovedAnteproject() async {
    try {
      final hasApproved = await _anteprojectsService.hasApprovedAnteproject();
      if (mounted) {
        setState(() {
          _hasApprovedAnteproject = hasApproved;
        });
        if (hasApproved) {
          final l10n = AppLocalizations.of(context)!;
          // Mostrar diálogo informativo
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(l10n.cannotEditAnteprojectWithApprovedTitle),
              content: Text(l10n.cannotEditAnteprojectWithApproved),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.close),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al verificar anteproyecto aprobado: $e');
      if (mounted) {
        setState(() {
          _hasApprovedAnteproject = false; // En caso de error, permitir intentar
        });
      }
    }
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.anteproject.title);
    _descriptionController = TextEditingController(
      text: widget.anteproject.description,
    );
    _academicYearController = TextEditingController(
      text: widget.anteproject.academicYear,
    );
    _objectivesController = TextEditingController(
      text: widget.anteproject.objectives ?? '',
    );
    _timelineController = TextEditingController(
      text: jsonEncode(widget.anteproject.timeline),
    );
    _tutorIdController = TextEditingController(
      text: widget.anteproject.tutorId.toString(),
    );
    _githubRepositoryController = TextEditingController(
      text: widget.anteproject.githubRepositoryUrl ?? '',
    );

    // Convertir expectedResults a lista de hitos
    _hitos = _convertExpectedResultsToHitos(widget.anteproject.expectedResults);

    _projectType = widget.anteproject.projectType;
    _status = widget.anteproject.status;
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _canEditTimeline() {
    // Solo los tutores pueden editar la temporalización
    return _currentUser?.role == UserRole.tutor;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _academicYearController.dispose();
    _objectivesController.dispose();
    _timelineController.dispose();
    _tutorIdController.dispose();
    _githubRepositoryController.dispose();
    super.dispose();
  }

  List<Hito> _convertExpectedResultsToHitos(
    Map<String, dynamic> expectedResults,
  ) {
    if (expectedResults.isEmpty) {
      return [const Hito(id: 'hito1', title: '', description: '')];
    }

    final List<Hito> hitos = [];

    // Verificar si tiene el formato con array de hitos (formato de base de datos)
    if (expectedResults.containsKey('hitos') &&
        expectedResults['hitos'] is List) {
      // Formato de BD: {hitos: [{numero: 1, nombre: "...", descripcion: "..."}, ...]}
      final hitosArray = expectedResults['hitos'] as List;
      for (int i = 0; i < hitosArray.length; i++) {
        final hitoData = hitosArray[i];
        if (hitoData is Map<String, dynamic>) {
          hitos.add(
            Hito(
              id: 'hito${i + 1}',
              title: hitoData['nombre'] ?? hitoData['title'] ?? '',
              description:
                  hitoData['descripcion'] ?? hitoData['description'] ?? '',
            ),
          );
        } else if (hitoData is Map) {
          // Manejar objetos minificados de Supabase
          final hitoMap = <String, dynamic>{};
          for (final key in hitoData.keys) {
            hitoMap[key.toString()] = hitoData[key];
          }
          hitos.add(
            Hito(
              id: 'hito${i + 1}',
              title: hitoMap['nombre'] ?? hitoMap['title'] ?? '',
              description:
                  hitoMap['descripcion'] ?? hitoMap['description'] ?? '',
            ),
          );
        }
      }
    } else {
      // Formato nuevo del formulario: {hito1: {title: "...", description: "..."}}
      expectedResults.forEach((key, value) {
        // Ignorar la clave 'objetivos' si existe
        if (key == 'objetivos') return;

        if (value is Map<String, dynamic>) {
          hitos.add(
            Hito(
              id: key,
              title: value['title'] ?? '',
              description: value['description'] ?? '',
            ),
          );
        } else if (value is Map) {
          // Manejar objetos minificados de Supabase
          final hitoMap = <String, dynamic>{};
          for (final k in value.keys) {
            hitoMap[k.toString()] = value[k];
          }
          hitos.add(
            Hito(
              id: key,
              title: hitoMap['title'] ?? '',
              description: hitoMap['description'] ?? '',
            ),
          );
        } else if (value is String) {
          // Formato legacy: {hito1: "texto"}
          hitos.add(Hito(id: key, title: value, description: ''));
        }
      });
    }

    // Si no hay hitos, crear uno por defecto
    if (hitos.isEmpty) {
      hitos.add(const Hito(id: 'hito1', title: '', description: ''));
    }

    return hitos;
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

  void _openScheduleManagement() async {
    if (_currentUser == null || widget.anteproject.tutorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se puede gestionar el cronograma sin tutor asignado',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ScheduleManagementScreen(
          anteproject: widget.anteproject,
          tutorId: widget.anteproject.tutorId!,
        ),
      ),
    );

    // Si se guardó el cronograma, actualizar el timeline en el controlador
    if (result == true) {
      // Recargar el anteproyecto para obtener el timeline actualizado
      try {
        final updatedAnteproject = await _anteprojectsService.getAnteproject(
          widget.anteproject.id,
        );
        if (updatedAnteproject != null && mounted) {
          setState(() {
            _timelineController.text = jsonEncode(updatedAnteproject.timeline);
          });
        }
      } catch (e) {
        debugPrint(
          'Error al recargar anteproyecto después de guardar cronograma: $e',
        );
      }
    }
  }

  void _submit() {
    // Verificar si hay anteproyecto aprobado antes de permitir enviar
    if (_hasApprovedAnteproject == true) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotEditAnteprojectWithApproved),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Convertir hitos a formato JSON para el backend
    final Map<String, dynamic> expectedResults = {};
    for (final hito in _hitos) {
      expectedResults[hito.id] = {
        'title': hito.title,
        'description': hito.description,
      };
    }

    // Timeline solo puede ser editado por tutores
    // Si el usuario no es tutor, mantener el timeline original
    final Map<String, dynamic> timeline = _canEditTimeline()
        ? _tryParseJsonOrEmpty(_timelineController.text)
        : widget.anteproject.timeline;

    final int? tutorId = int.tryParse(_tutorIdController.text.trim());
    if (tutorId == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.anteprojectInvalidTutorId)));
      return;
    }

    final DateTime now = DateTime.now();

    // Crear un nuevo anteproyecto con los datos actualizados usando copyWith
    final Anteproject updatedAnteproject = widget.anteproject.copyWith(
      title: _titleController.text.trim(),
      projectType: _projectType,
      description: _descriptionController.text.trim(),
      academicYear: _academicYearController.text.trim(),
      expectedResults: expectedResults,
      timeline: timeline, // Solo se actualiza si el tutor lo edita
      status: _status,
      tutorId: tutorId,
      githubRepositoryUrl: _githubRepositoryController.text.trim().isEmpty
          ? null
          : _githubRepositoryController.text.trim(),
      updatedAt: now,
    );

    setState(() {
      _isSubmitting = true;
    });

    context.read<AnteprojectsBloc>().add(
      AnteprojectUpdateRequested(updatedAnteproject),
    );
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
                context.read<AnteprojectsBloc>().add(
                  AnteprojectDeleteRequested(widget.anteproject.id),
                );
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
          final message = state.message.isNotEmpty
              ? state.message
              : l10n.anteprojectUpdatedSuccess;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
          // Si se eliminó, volver a la pantalla anterior (lista de anteproyectos)
          if (message.contains('eliminado')) {
            // Cerrar el formulario de edición y volver a la lista
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop();
          }
        }

        if (state is AnteprojectsFailure) {
          ErrorSnackBar.show(context, error: state.message);
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
                      color: _getStatusColor().withValues(alpha: 0.1),
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
                        labelText: AppLocalizations.of(
                          context,
                        )!.anteprojectTitleLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (String? value) =>
                          FormValidators.anteprojectTitle(value, context),
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
                      onChanged: (ProjectType? value) =>
                          setState(() => _projectType = value!),
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
                        items:
                            [
                                  AnteprojectStatus.draft,
                                  AnteprojectStatus.submitted,
                                ]
                                .map(
                                  (AnteprojectStatus status) =>
                                      DropdownMenuItem<AnteprojectStatus>(
                                        value: status,
                                        child: Text(status.displayName),
                                      ),
                                )
                                .toList(),
                        onChanged: (AnteprojectStatus? value) =>
                            setState(() => _status = value!),
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
                          FormValidators.anteprojectDescription(value, context),
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
                          FormValidators.academicYear(value, context),
                    ),
                    const SizedBox(height: 16),

                    // Campo de repositorio de GitHub
                    TextFormField(
                      controller: _githubRepositoryController,
                      decoration: const InputDecoration(
                        labelText: 'URL del Repositorio de GitHub',
                        hintText: 'https://github.com/usuario/repositorio',
                        border: OutlineInputBorder(),
                        helperText: 'Ejemplo: https://github.com/usuario/mi-proyecto',
                      ),
                      validator: (String? value) =>
                          FormValidators.githubRepositoryUrl(value, context),
                    ),
                    const SizedBox(height: 16),

                    // Widget de lista de hitos en lugar de JSON
                    HitosListWidget(
                      initialHitos: _hitos,
                      onHitosChanged: (hitos) {
                        setState(() {
                          _hitos = hitos;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Temporalización (solo para tutores)
                    // Si no es tutor, ocultar el campo completamente o mostrarlo como solo lectura
                    if (_canEditTimeline()) ...[
                      // Botón para abrir el calendario de gestión de timeline
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.scheduleManagement,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.timelineWillBeEstablishedByTutor,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _openScheduleManagement,
                                icon: const Icon(Icons.calendar_month),
                                label: Text(l10n.scheduleManagement),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // Para estudiantes: mostrar información de que el tutor establecerá el timeline
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.timelineWillBeEstablishedByTutor,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Tutor ID (solo para tutores)
                    TextFormField(
                      controller: _tutorIdController,
                      keyboardType: TextInputType.number,
                      enabled: _canEditTimeline(),
                      decoration: InputDecoration(
                        labelText: l10n.anteprojectTutorId,
                        hintText: _canEditTimeline()
                            ? null
                            : 'Solo los tutores pueden editar el ID del tutor',
                        border: const OutlineInputBorder(),
                        suffixIcon: _canEditTimeline()
                            ? null
                            : const Icon(Icons.lock, color: Colors.grey),
                      ),
                      validator: _canEditTimeline()
                          ? (String? value) =>
                                FormValidators.tutorId(value, context)
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: LoadingButton(
                              text: l10n.anteprojectUpdateButton,
                              onPressed: (_hasApprovedAnteproject == true) ? null : _submit,
                              isLoading: _isSubmitting,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
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
