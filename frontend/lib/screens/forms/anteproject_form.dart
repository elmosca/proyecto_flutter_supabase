import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/anteprojects_bloc.dart';
import '../../models/anteproject.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/form_validators.dart';
import '../../widgets/common/error_handler_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/forms/hitos_list_widget.dart';
import '../../services/pdf_service.dart';
import '../../services/auth_service.dart';
import '../../services/anteprojects_service.dart';
import '../../services/projects_service.dart';
import '../../services/settings_service.dart';
import '../../models/user.dart';

class AnteprojectForm extends StatefulWidget {
  const AnteprojectForm({super.key});

  @override
  State<AnteprojectForm> createState() => _AnteprojectFormState();
}

class _AnteprojectFormState extends State<AnteprojectForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  final ProjectsService _projectsService = ProjectsService();
  final SettingsService _settingsService = SettingsService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();
  final TextEditingController _objectivesController = TextEditingController();
  final TextEditingController _githubRepositoryController = TextEditingController();
  // Eliminado: los tutores se asignan por parte del admin, no por el alumno
  // Eliminado: timeline - lo gestiona el tutor con herramienta de calendario

  ProjectType? _projectType = ProjectType.execution;
  List<Hito> _hitos = [];

  bool _isSubmitting = false;
  bool _isLoadingUser = true;
  bool _hasApprovedAnteproject = false;
  bool _hasDraftAnteproject = false;
  bool _isWrongAcademicYear = false;
  bool _isCheckingRestrictions = true;
  User? _currentUser; // Usuario actual para obtener año académico del tutor

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _checkIfCanCreateAnteproject();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _academicYearController.dispose();
    _objectivesController.dispose();
    _githubRepositoryController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoadingUser = false;

          // Asignar automáticamente el año académico del tutor
          if (user?.academicYear != null) {
            _academicYearController.text = user!.academicYear!;
          } else {
            // Fallback si no tiene año académico asignado
            _loadSystemAcademicYear();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
          _loadSystemAcademicYear(); // Fallback
        });
      }
    }
  }

  Future<void> _loadSystemAcademicYear() async {
    try {
      final year = await _settingsService.getStringSetting('academic_year');
      if (year != null && year.isNotEmpty && mounted) {
        // Solo actualizar si el campo está vacío para no sobrescribir entradas manuales previas si las hubiera
        if (_academicYearController.text.isEmpty) {
          setState(() {
            _academicYearController.text = year;
          });
        }
      } else if (mounted && _academicYearController.text.isEmpty) {
        // Último recurso si no hay configuración
        final now = DateTime.now();
        final currentYear = now.year;
        final nextYear = currentYear + 1;
        setState(() {
          _academicYearController.text = '$currentYear-$nextYear';
        });
      }
    } catch (e) {
      debugPrint('Error loading system academic year: $e');
    }
  }

  Future<void> _checkIfCanCreateAnteproject() async {
    try {
      // Verificar restricciones en paralelo
      final results = await Future.wait([
        _anteprojectsService.hasApprovedAnteproject(),
        _anteprojectsService.hasDraftAnteproject(),
        _settingsService.getStringSetting('academic_year'),
      ]);
      
      final hasApproved = results[0] as bool;
      final hasDraft = results[1] as bool;
      final activeAcademicYear = results[2] as String?;
      
      // Verificar año académico
      bool wrongAcademicYear = false;
      if (activeAcademicYear != null && 
          activeAcademicYear.isNotEmpty &&
          _currentUser?.academicYear != activeAcademicYear) {
        wrongAcademicYear = true;
      }
      
      if (mounted) {
        setState(() {
          _hasApprovedAnteproject = hasApproved;
          _hasDraftAnteproject = hasDraft;
          _isWrongAcademicYear = wrongAcademicYear;
          _isCheckingRestrictions = false;
        });

          final l10n = AppLocalizations.of(context)!;

        if (wrongAcademicYear) {
          // Mostrar diálogo informativo para año académico incorrecto
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.cannotCreateAnteprojectWrongAcademicYearTitle),
                content: Text(l10n.cannotCreateAnteprojectWrongAcademicYear),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Volver a la pantalla anterior
                    },
                    child: Text(l10n.close),
                  ),
                ],
              ),
            );
          }
        } else if (hasApproved) {
          // Mostrar diálogo informativo para anteproyecto aprobado
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.cannotCreateAnteprojectWithApprovedTitle),
                content: Text(l10n.cannotCreateAnteprojectWithApproved),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.close),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      // Intentar navegar al proyecto aprobado
                      try {
                        final anteprojects =
                            await _anteprojectsService.getStudentAnteprojects();
                        final approvedAnteproject = anteprojects.firstWhere(
                          (ap) => ap.status == AnteprojectStatus.approved,
                        );
                        if (approvedAnteproject.projectId != null) {
                          final project = await _projectsService
                              .getProject(approvedAnteproject.projectId!);
                          if (mounted && project != null) {
                            Navigator.of(context).pushReplacementNamed(
                              '/projects/${project.id}',
                            );
                          }
                        } else {
                          // Si no hay proyecto, mostrar el anteproyecto
                          if (mounted) {
                            Navigator.of(context).pushReplacementNamed(
                              '/anteprojects/${approvedAnteproject.id}',
                            );
                          }
                        }
                      } catch (e) {
                        // Si hay error, solo cerrar el diálogo
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Text(l10n.goToProject),
                  ),
                ],
              ),
            );
          }
        } else if (hasDraft) {
          // Mostrar diálogo informativo para borrador existente
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.cannotCreateAnteprojectWithDraftTitle),
                content: Text(l10n.cannotCreateAnteprojectWithDraft),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.close),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      // Navegar al borrador existente
                      try {
                        final anteprojects =
                            await _anteprojectsService.getStudentAnteprojects();
                        final draftAnteproject = anteprojects.firstWhere(
                          (ap) => ap.status == AnteprojectStatus.draft,
                        );
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed(
                            '/anteprojects/${draftAnteproject.id}',
                          );
                        }
                      } catch (e) {
                        // Si hay error, solo cerrar el diálogo
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Text(l10n.goToDraft),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingRestrictions = false;
        });
        // No mostrar error, permitir que el usuario intente crear
        // El servicio lanzará la excepción si realmente hay restricciones
      }
    }
  }

  void _loadTemplate() {
    setState(() {
      _titleController.text =
          'Sistema de Seguimiento de Proyectos TFCGS - Ciclo DAM';
      _descriptionController.text =
          'El proyecto consiste en el desarrollo de una plataforma digital colaborativa para la planificación, seguimiento y evaluación de los Trabajos de Fin de Grado Ciclo Superior (TFGCS) en ciclos formativos de DAM. Utiliza un enfoque Kanban para la gestión de tareas, permitiendo la interacción entre administradores, tutores y alumnos.';
      _objectivesController.text =
          '• Consolidar los conocimientos adquiridos durante el ciclo\n• Llevar a cabo el análisis de requisitos previo al desarrollo\n• Elegir herramientas modernas para una solución fullstack\n• Implementar el esquema relacional del proyecto\n• Codificar servicios backend en Java con Spring Boot\n• Codificar el frontend en Flutter\n• Diseñar interfaces adaptadas al rol\n• Documentar el proyecto con guía de instalación';

      // Cargar hitos de ejemplo
      _hitos = [
        const Hito(
          id: 'hito1',
          title: 'Análisis y Diseño + Infraestructura Base',
          description:
              'Análisis de requisitos y diseño funcional\nMontaje de infraestructura Dockerizada\nEsquema relacional inicial de PostgreSQL',
        ),
        const Hito(
          id: 'hito2',
          title: 'Sistema de Autenticación y Gestión de Usuarios',
          description:
              'Backend completo de autenticación\nControl de acceso por roles\nAPI Gateway configurado',
        ),
        const Hito(
          id: 'hito3',
          title: 'Gestión de Proyectos y Tareas',
          description:
              'Backend de proyectos/tareas/anteproyectos\nPrimer prototipo funcional en Flutter\nVista Kanban básica',
        ),
        const Hito(
          id: 'hito4',
          title: 'Funcionalidades Colaborativas y Finalización',
          description:
              'Comentarios, archivos y notificaciones\nDashboard personalizado\nDocumentación técnica y pruebas\nPreparación para defensa',
        ),
      ];
    });

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.templateLoadedSuccess),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _downloadExamplePdf() async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Generar PDF de ejemplo
      final pdfBytes = await PdfService.generateAnteprojectExamplePdf();

      // Cerrar indicador de carga
      if (mounted) {
        Navigator.of(context).pop();

        // Mostrar opciones de descarga
        _showDownloadOptions(pdfBytes);
      }
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorGeneratingPDF(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDownloadOptions(Uint8List pdfBytes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.downloadExampleTitle),
        content: Text(AppLocalizations.of(context)!.downloadExampleMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _printPdf(pdfBytes);
            },
            child: Text(AppLocalizations.of(context)!.print),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _savePdf(pdfBytes);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _printPdf(Uint8List pdfBytes) async {
    try {
      await PdfService.printOrSavePdf(
        pdfBytes,
        fileName: 'anteproyecto_ejemplo.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorPrinting(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePdf(Uint8List pdfBytes) async {
    try {
      final filePath = await PdfService.savePdfToDevice(
        pdfBytes,
        'anteproyecto_ejemplo.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pdfSavedAt(filePath)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorSaving(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Convertir hitos a formato JSON para el backend
    final Map<String, dynamic> expectedResults = {};
    for (final hito in _hitos) {
      expectedResults[hito.id] = {
        'title': hito.title,
        'description': hito.description,
      };
    }

    // Los tutores se asignan por parte del admin, no por el alumno
    // El anteproyecto se crea sin tutor asignado inicialmente
    // La temporalización la gestiona el tutor con herramienta de calendario

    final DateTime now = DateTime.now();

    final Anteproject anteproject = Anteproject(
      id: 0, // ID temporal, el backend asignará el definitivo
      title: _titleController.text.trim(),
      projectType: _projectType ?? ProjectType.execution,
      description: _descriptionController.text.trim(),
      academicYear: _academicYearController.text.trim(),
      objectives: _objectivesController.text.trim(),
      expectedResults: expectedResults,
      timeline: {}, // Vacío - lo gestiona el tutor
      status: AnteprojectStatus.draft,
      tutorId: null, // Se asignará posteriormente por el admin
      submittedAt: null,
      reviewedAt: null,
      projectId: null,
      tutorComments: null,
      githubRepositoryUrl: _githubRepositoryController.text.trim().isEmpty
          ? null
          : _githubRepositoryController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    setState(() {
      _isSubmitting = true;
    });

    context.read<AnteprojectsBloc>().add(
      AnteprojectCreateRequested(anteproject),
    );
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
          ErrorSnackBar.show(context, error: state.message);
        }
      },
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.anteprojectFormTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadExamplePdf,
                  tooltip: l10n.downloadExamplePdf,
                ),
                IconButton(
                  icon: const Icon(Icons.content_copy),
                  onPressed: _loadTemplate,
                  tooltip: l10n.loadTemplate,
                ),
              ],
            ),
            body: _isLoadingUser || _isCheckingRestrictions
                ? const Center(child: CircularProgressIndicator())
                : _isWrongAcademicYear
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 64,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.cannotCreateAnteprojectWrongAcademicYearTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.cannotCreateAnteprojectWrongAcademicYear,
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back),
                                label: Text(l10n.goBack),
                              ),
                            ],
                          ),
                        ),
                      )
                : _hasApprovedAnteproject
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 64,
                                color: Colors.orange[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.cannotCreateAnteprojectWithApprovedTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.cannotCreateAnteprojectWithApproved,
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    final anteprojects = await _anteprojectsService
                                        .getStudentAnteprojects();
                                    final approvedAnteproject = anteprojects.firstWhere(
                                      (ap) => ap.status == AnteprojectStatus.approved,
                                    );
                                    if (approvedAnteproject.projectId != null) {
                                      final project = await _projectsService
                                          .getProject(approvedAnteproject.projectId!);
                                      if (mounted && project != null) {
                                        Navigator.of(context).pushReplacementNamed(
                                          '/projects/${project.id}',
                                        );
                                      }
                                    } else {
                                      if (mounted) {
                                        Navigator.of(context).pushReplacementNamed(
                                          '/anteprojects/${approvedAnteproject.id}',
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error: ${e.toString()}',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.arrow_forward),
                                label: Text(l10n.goToProject),
                              ),
                            ],
                          ),
                        ),
                      )
                        : _hasDraftAnteproject
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    size: 64,
                                    color: Colors.blue[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.cannotCreateAnteprojectWithDraftTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.cannotCreateAnteprojectWithDraft,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      try {
                                        final anteprojects = await _anteprojectsService
                                            .getStudentAnteprojects();
                                        final draftAnteproject = anteprojects.firstWhere(
                                          (ap) => ap.status == AnteprojectStatus.draft,
                                        );
                                        if (mounted) {
                                          Navigator.of(context).pushReplacementNamed(
                                            '/anteprojects/${draftAnteproject.id}',
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error: ${e.toString()}',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.arrow_forward),
                                    label: Text(l10n.goToDraft),
                                  ),
                                ],
                              ),
                            ),
                          )
                    : SafeArea(
                        child: Form(
                          key: _formKey,
                          child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: <Widget>[
                          // Botones de ayuda
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ayuda para completar el anteproyecto',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Usa estos botones para obtener ayuda:',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _downloadExamplePdf,
                                          icon: const Icon(
                                            Icons.picture_as_pdf,
                                          ),
                                          label: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.downloadExamplePDF,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[50],
                                            foregroundColor: Colors.red[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _loadTemplate,
                                          icon: const Icon(Icons.content_copy),
                                          label: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.loadTemplate,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue[50],
                                            foregroundColor: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                          DropdownButtonFormField<ProjectType>(
                            value: _projectType,
                            decoration: InputDecoration(
                              labelText: l10n.anteprojectType,
                              border: const OutlineInputBorder(),
                            ),
                            items: ProjectType.values
                                .map(
                                  (ProjectType type) =>
                                      DropdownMenuItem<ProjectType>(
                                        value: type,
                                        child: Text(type.shortName),
                                      ),
                                )
                                .toList(),
                            onChanged: (ProjectType? value) =>
                                setState(() => _projectType = value),
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
                            validator: (String? value) =>
                                FormValidators.anteprojectDescription(
                                  value,
                                  context,
                                ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _objectivesController,
                            minLines: 4,
                            maxLines: 8,
                            decoration: const InputDecoration(
                              labelText: 'Objetivos',
                              hintText:
                                  'Lista los objetivos específicos del proyecto (uno por línea)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Los objetivos son obligatorios';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Campo de año académico (asignado automáticamente por el tutor)
                          TextFormField(
                            controller: _academicYearController,
                            enabled: false, // No editable por el estudiante
                            decoration: InputDecoration(
                              labelText: l10n.anteprojectAcademicYear,
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              suffixIcon: const Icon(
                                Icons.lock,
                                color: Colors.grey,
                              ),
                              helperText: _currentUser?.academicYear != null
                                  ? 'Asignado automáticamente por tu tutor (${_currentUser!.fullName})'
                                  : 'Asignado automáticamente por tu tutor',
                              helperStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
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
                            key: ValueKey(
                              _hitos.length.toString() +
                                  _hitos.map((h) => h.id).join(),
                            ),
                            initialHitos: _hitos,
                            onHitosChanged: (hitos) {
                              setState(() {
                                _hitos = hitos;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Información sobre temporalización
                          Card(
                            color: Colors.blue.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n.timelineWillBeEstablishedByTutor,
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Eliminado: Campo Tutor ID - Los tutores se asignan por el admin
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
