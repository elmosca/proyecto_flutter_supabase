import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_management_service.dart';

/// Diálogo para seleccionar un tutor de una lista.
class TutorSelectorDialog extends StatefulWidget {
  final int? currentTutorId;
  final Function(User) onTutorSelected;

  const TutorSelectorDialog({
    super.key,
    this.currentTutorId,
    required this.onTutorSelected,
  });

  @override
  State<TutorSelectorDialog> createState() => _TutorSelectorDialogState();
}

class _TutorSelectorDialogState extends State<TutorSelectorDialog> {
  final _userManagementService = UserManagementService();
  List<User> _tutors = [];
  bool _loading = true;
  String? _errorMessage;
  User? _selectedTutor;

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  Future<void> _loadTutors() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final tutors = await _userManagementService.getTutors();
      if (mounted) {
        setState(() {
          _tutors = tutors;
          _loading = false;
          // Si hay un tutor actual, seleccionarlo por defecto
          if (widget.currentTutorId != null && tutors.isNotEmpty) {
            try {
              _selectedTutor = tutors.firstWhere(
                (t) => t.id == widget.currentTutorId,
              );
            } catch (e) {
              // Si no se encuentra, dejar null
              _selectedTutor = null;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error cargando tutores: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Tutor'),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700))
            : _tutors.isEmpty
            ? const Text('No hay tutores disponibles')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._tutors.map((tutor) {
                      final isSelected = _selectedTutor?.id == tutor.id;
                      return RadioListTile<User>(
                        title: Text(tutor.fullName),
                        subtitle: Text(tutor.email),
                        value: tutor,
                        groupValue: _selectedTutor,
                        onChanged: (User? value) {
                          setState(() => _selectedTutor = value);
                        },
                        selected: isSelected,
                      );
                    }),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (!_loading && _tutors.isNotEmpty)
          ElevatedButton(
            onPressed: _selectedTutor == null
                ? null
                : () {
                    widget.onTutorSelected(_selectedTutor!);
                    Navigator.of(context).pop();
                  },
            child: const Text('Confirmar'),
          ),
      ],
    );
  }
}
