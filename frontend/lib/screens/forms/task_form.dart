import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../models/task.dart';
import '../../models/project.dart';
import '../../blocs/tasks_bloc.dart';
import '../../services/projects_service.dart';
import '../../utils/task_localizations.dart';
import '../../utils/validators.dart';

class TaskForm extends StatefulWidget {
  final int? projectId;
  final Task? task; // Si es null, es creación; si no, es edición

  const TaskForm({super.key, this.projectId, this.task});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedHoursController = TextEditingController();
  final _tagsController = TextEditingController();

  TaskStatus _selectedStatus = TaskStatus.pending;
  TaskComplexity _selectedComplexity = TaskComplexity.medium;
  DateTime? _selectedDueDate;

  // Nuevos campos para selección de proyecto
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoadingProjects = true;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    debugPrint('🔍 TaskForm inicializado con projectId: ${widget.projectId}');
    _loadProjects();
    if (_isEditing) {
      _initializeFormWithTask();
    }
  }

  Future<void> _loadProjects() async {
    try {
      debugPrint('🔍 Iniciando carga de proyectos...');
      final projectsService = ProjectsService();
      _projects = await projectsService.getProjects();
      debugPrint('🔍 Proyectos obtenidos: ${_projects.length}');

      for (final project in _projects) {
        debugPrint(
          '🔍 Proyecto: ${project.id} - ${project.title} - ${project.status}',
        );
      }

      // Si hay un projectId específico, seleccionarlo
      if (widget.projectId != null) {
        try {
          _selectedProject = _projects.firstWhere(
            (p) => p.id == widget.projectId,
          );
        } catch (e) {
          debugPrint(
            '⚠️ Proyecto específico no encontrado, usando el primero disponible',
          );
          _selectedProject = _projects.isNotEmpty ? _projects.first : null;
        }
      } else if (_projects.isNotEmpty) {
        _selectedProject = _projects.first;
      }

      setState(() {
        _isLoadingProjects = false;
      });

      debugPrint(
        '🔍 Proyectos cargados: ${_projects.length}, Seleccionado: ${_selectedProject?.id}',
      );
    } catch (e) {
      debugPrint('❌ Error cargando proyectos: $e');
      setState(() {
        _isLoadingProjects = false;
      });
    }
  }

  void _initializeFormWithTask() {
    final task = widget.task!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _estimatedHoursController.text = task.estimatedHours?.toString() ?? '';
    _tagsController.text = task.tags?.join(', ') ?? '';
    _selectedStatus = task.status;
    _selectedComplexity = task.complexity;
    _selectedDueDate = task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedHoursController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 TaskForm build() ejecutándose');
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.taskEditFormTitle : l10n.taskFormTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
            tooltip: _isEditing ? l10n.taskUpdateButton : l10n.taskCreateButton,
          ),
        ],
      ),
      body: BlocListener<TasksBloc, TasksState>(
        listener: (context, state) {
          if (state is TaskOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? l10n.taskUpdatedSuccess
                      : l10n.taskCreatedSuccess,
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is TasksFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.messageKey),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProjectSelector(l10n),
                const SizedBox(height: 16),
                _buildTitleField(l10n),
                const SizedBox(height: 16),
                _buildDescriptionField(l10n),
                const SizedBox(height: 16),
                _buildStatusField(l10n),
                const SizedBox(height: 16),
                _buildComplexityField(l10n),
                const SizedBox(height: 16),
                _buildDueDateField(l10n),
                const SizedBox(height: 16),
                _buildEstimatedHoursField(l10n),
                const SizedBox(height: 16),
                _buildTagsField(l10n),
                const SizedBox(height: 24),
                _buildActionButtons(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField(AppLocalizations l10n) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: l10n.taskTitle,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => Validators.required(value, l10n.taskTitleRequired),
    );
  }

  Widget _buildDescriptionField(AppLocalizations l10n) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: l10n.taskDescription,
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
      validator: (value) =>
          Validators.required(value, l10n.taskDescriptionRequired),
    );
  }

  Widget _buildStatusField(AppLocalizations l10n) {
    return DropdownButtonFormField<TaskStatus>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: l10n.taskStatus,
        border: const OutlineInputBorder(),
      ),
      items: TaskStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(TaskLocalizations.getTaskStatusDisplayName(status, l10n)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
    );
  }

  Widget _buildComplexityField(AppLocalizations l10n) {
    return DropdownButtonFormField<TaskComplexity>(
      value: _selectedComplexity,
      decoration: InputDecoration(
        labelText: l10n.taskComplexity,
        border: const OutlineInputBorder(),
      ),
      items: TaskComplexity.values.map((complexity) {
        return DropdownMenuItem(
          value: complexity,
          child: Text(
            TaskLocalizations.getTaskComplexityDisplayName(complexity, l10n),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedComplexity = value;
            // Actualizar horas estimadas basadas en complejidad
            _estimatedHoursController.text = value.estimatedHours.toString();
          });
        }
      },
    );
  }

  Widget _buildDueDateField(AppLocalizations l10n) {
    return InkWell(
      onTap: _selectDueDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.taskDueDate,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          _selectedDueDate != null
              ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
              : l10n.selectDate,
        ),
      ),
    );
  }

  Widget _buildEstimatedHoursField(AppLocalizations l10n) {
    return TextFormField(
      controller: _estimatedHoursController,
      decoration: InputDecoration(
        labelText: l10n.taskEstimatedHours,
        border: const OutlineInputBorder(),
        suffixText: 'horas',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final hours = int.tryParse(value);
          if (hours == null || hours <= 0) {
            return 'Las horas deben ser un número positivo';
          }
        }
        return null;
      },
    );
  }

  Widget _buildTagsField(AppLocalizations l10n) {
    return TextFormField(
      controller: _tagsController,
      decoration: InputDecoration(
        labelText: l10n.taskTags,
        border: const OutlineInputBorder(),
        hintText: 'Etiqueta1, Etiqueta2, Etiqueta3',
      ),
    );
  }

  Widget _buildProjectSelector(AppLocalizations l10n) {
    debugPrint(
      '🔍 _buildProjectSelector ejecutándose - _isLoadingProjects: $_isLoadingProjects, _projects.length: ${_projects.length}',
    );

    if (_isLoadingProjects) {
      return const ListTile(
        title: Text('Cargando proyectos...'),
        trailing: CircularProgressIndicator(),
      );
    }

    if (_projects.isEmpty) {
      return const ListTile(
        title: Text('No hay proyectos disponibles'),
        subtitle: Text('Contacta con tu tutor para asignarte a un proyecto'),
        leading: Icon(Icons.warning, color: Colors.orange),
      );
    }

    return DropdownButtonFormField<Project>(
      value: _selectedProject,
      decoration: const InputDecoration(
        labelText: 'Seleccionar Proyecto',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.folder),
      ),
      items: _projects.map((project) {
        return DropdownMenuItem<Project>(
          value: project,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280, maxHeight: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  project.status.displayName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: (Project? newValue) {
        setState(() {
          _selectedProject = newValue;
        });
        debugPrint(
          '🔍 Proyecto seleccionado: ${_selectedProject?.id} - ${_selectedProject?.title}',
        );
      },
      validator: (value) {
        if (value == null) {
          return 'Debe seleccionar un proyecto';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveTask,
            child: Text(
              _isEditing ? l10n.taskUpdateButton : l10n.taskCreateButton,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que se haya seleccionado un proyecto
    if (_selectedProject == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _projects.isEmpty
                ? l10n.noProjectsAvailableForTasks
                : l10n.mustSelectProjectForTask,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final estimatedHours = _estimatedHoursController.text.isNotEmpty
        ? int.tryParse(_estimatedHoursController.text)
        : null;

    debugPrint('🔍 Guardando tarea con projectId: ${_selectedProject!.id}');

    if (_isEditing) {
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        status: _selectedStatus,
        complexity: _selectedComplexity,
        projectId: _selectedProject!.id, // Usar el proyecto seleccionado
        dueDate: _selectedDueDate,
        estimatedHours: estimatedHours,
        tags: tags,
        updatedAt: DateTime.now(),
      );

      context.read<TasksBloc>().add(TaskUpdateRequested(updatedTask));
    } else {
      final newTask = Task(
        id: 0, // Se asignará en el backend
        projectId: _selectedProject!.id, // Usar el proyecto seleccionado
        title: _titleController.text,
        description: _descriptionController.text,
        status: _selectedStatus,
        complexity: _selectedComplexity,
        dueDate: _selectedDueDate,
        estimatedHours: estimatedHours,
        actualHours: null, // Inicialmente null
        tags: tags,
        kanbanPosition: 0,
        isAutoGenerated: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<TasksBloc>().add(TaskCreateRequested(newTask));
    }
  }
}
