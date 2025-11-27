import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../models/anteproject.dart';
import '../../models/schedule.dart';
import '../../models/user.dart';
import '../../services/schedule_service.dart';
import '../../services/anteprojects_service.dart';
import '../../widgets/navigation/app_bar_actions.dart';

class ScheduleManagementScreen extends StatefulWidget {
  final Anteproject anteproject;
  final int tutorId;

  const ScheduleManagementScreen({
    super.key,
    required this.anteproject,
    required this.tutorId,
  });

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  final List<ReviewDate> _reviewDates = [];
  
  DateTime _startDate = DateTime.now();
  DateTime _finalDate = DateTime.now().add(const Duration(days: 90));
  bool _isLoading = false;
  bool _isEditing = false;
  User? _student;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadExistingSchedule();
    _loadStudent();
  }

  Future<void> _loadCurrentUser() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _currentUser = authState.user;
      });
    }
  }

  Future<void> _loadStudent() async {
    try {
      final student = await _anteprojectsService.getAnteprojectStudent(widget.anteproject.id);
      if (mounted) {
        setState(() {
          _student = student;
        });
      }
    } catch (e) {
      // Error al cargar estudiante, pero no interrumpir el flujo
      debugPrint('Error al cargar estudiante: $e');
    }
  }

  Future<void> _loadExistingSchedule() async {
    setState(() => _isLoading = true);
    
    try {
      final existingSchedule = await _scheduleService.getScheduleByAnteproject(widget.anteproject.id);
      
      if (existingSchedule != null) {
        setState(() {
          _startDate = existingSchedule.startDate;
          _finalDate = existingSchedule.finalDate;
          _reviewDates.clear();
          _reviewDates.addAll(existingSchedule.reviewDates);
          _isEditing = true;
        });
      } else {
        // Generar fechas por defecto basadas en los hitos
        _generateDefaultSchedule();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLoadingSchedule(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _generateDefaultSchedule() {
    final generatedDates = _scheduleService.generateReviewDatesFromMilestones(
      anteproject: widget.anteproject,
      startDate: _startDate,
      finalDate: _finalDate,
    );
    
    setState(() {
      _reviewDates.clear();
      _reviewDates.addAll(generatedDates);
    });
  }

  Future<void> _saveSchedule() async {
    if (_reviewDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.mustConfigureReviewDate),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // Actualizar cronograma existente
        final existingSchedule = await _scheduleService.getScheduleByAnteproject(widget.anteproject.id);
        if (existingSchedule != null) {
          await _scheduleService.updateSchedule(
            scheduleId: existingSchedule.id,
            startDate: _startDate,
            finalDate: _finalDate,
            reviewDates: _reviewDates,
          );
        }
      } else {
        // Crear nuevo cronograma
        await _scheduleService.createSchedule(
          anteprojectId: widget.anteproject.id,
          tutorId: widget.tutorId,
          startDate: _startDate,
          finalDate: _finalDate,
          reviewDates: _reviewDates,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.scheduleSavedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retornar true para indicar que se guardó
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSavingSchedule(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addReviewDate() {
    showDialog(
      context: context,
      builder: (context) => _AddReviewDateDialog(
        onAdd: (date, description) {
          setState(() {
            _reviewDates.add(ReviewDate(
              id: 0,
              scheduleId: 0,
              date: date,
              description: description,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
            _sortReviewDates();
          });
        },
      ),
    );
  }

  void _editReviewDate(int index) {
    final reviewDate = _reviewDates[index];
    showDialog(
      context: context,
      builder: (context) => _AddReviewDateDialog(
        initialDate: reviewDate.date,
        initialDescription: reviewDate.description,
        onAdd: (date, description) {
          setState(() {
            _reviewDates[index] = ReviewDate(
              id: reviewDate.id,
              scheduleId: reviewDate.scheduleId,
              date: date,
              description: description,
              milestoneReference: reviewDate.milestoneReference,
              createdAt: reviewDate.createdAt,
              updatedAt: DateTime.now(),
            );
            _sortReviewDates();
          });
        },
      ),
    );
  }

  void _removeReviewDate(int index) {
    setState(() {
      _reviewDates.removeAt(index);
    });
  }

  void _sortReviewDates() {
    _reviewDates.sort((a, b) => a.date.compareTo(b.date));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scheduleManagement),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: _currentUser != null
            ? AppBarActions.build(
                context,
                _currentUser!,
                additionalActions: [
                  if (!_isLoading)
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveSchedule,
                      tooltip: 'Guardar cronograma',
                    ),
                ],
              )
            : [
                if (!_isLoading)
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveSchedule,
                    tooltip: 'Guardar cronograma',
                  ),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProjectInfo(),
                  const SizedBox(height: 24),
                  _buildDateRangeSection(),
                  const SizedBox(height: 24),
                  _buildReviewDatesSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildProjectInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Proyecto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Título: ${widget.anteproject.title}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Estudiante: ${_student?.fullName ?? 'Cargando...'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Hitos definidos: ${widget.anteproject.timeline.length}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rango de Fechas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Fecha de Inicio',
                    date: _startDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                          _generateDefaultSchedule();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    label: 'Fecha Final',
                    date: _finalDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _finalDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _finalDate = date;
                          _generateDefaultSchedule();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateDefaultSchedule,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.regenerateDatesBasedOnMilestones),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(date),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewDatesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fechas de Revisión',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addReviewDate,
                  tooltip: 'Añadir fecha de revisión',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_reviewDates.isEmpty)
              const Center(
                child: Text(
                  'No hay fechas de revisión configuradas',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ..._reviewDates.asMap().entries.map((entry) {
                final index = entry.key;
                final reviewDate = entry.value;
                return _buildReviewDateItem(index, reviewDate);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewDateItem(int index, ReviewDate reviewDate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(_formatDate(reviewDate.date)),
        subtitle: Text(reviewDate.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editReviewDate(index),
              tooltip: 'Editar fecha',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _removeReviewDate(index),
              tooltip: 'Eliminar fecha',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveSchedule,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isEditing ? 'Actualizar Cronograma' : 'Crear Cronograma'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel),
            label: Text(AppLocalizations.of(context)!.cancel),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddReviewDateDialog extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialDescription;
  final Function(DateTime date, String description) onAdd;

  const _AddReviewDateDialog({
    this.initialDate,
    this.initialDescription,
    required this.onAdd,
  });

  @override
  State<_AddReviewDateDialog> createState() => _AddReviewDateDialogState();
}

class _AddReviewDateDialogState extends State<_AddReviewDateDialog> {
  late DateTime _selectedDate;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialDate != null ? 'Editar Fecha de Revisión' : 'Añadir Fecha de Revisión'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción de la revisión',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_descriptionController.text.trim().isNotEmpty) {
              widget.onAdd(_selectedDate, _descriptionController.text.trim());
              Navigator.of(context).pop();
            }
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
