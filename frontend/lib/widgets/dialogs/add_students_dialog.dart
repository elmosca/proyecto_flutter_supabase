import 'package:flutter/material.dart';
import '../../screens/forms/add_student_form.dart';
import '../../screens/forms/import_students_csv_screen.dart';

class AddStudentsDialog extends StatelessWidget {
  final int tutorId;

  const AddStudentsDialog({super.key, required this.tutorId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.person_add, color: Colors.blue),
          SizedBox(width: 8),
          Text('Añadir Estudiantes'),
        ],
      ),
      content: const Text(
        'Selecciona cómo quieres añadir estudiantes:',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        // Botón para añadir individualmente
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToAddIndividual(context);
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Añadir Individualmente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Botón para importar CSV
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToImportCSV(context);
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Importar desde CSV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Botón para cancelar
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }

  void _navigateToAddIndividual(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddStudentForm(tutorId: tutorId),
      ),
    );
  }

  void _navigateToImportCSV(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImportStudentsCSVScreen(tutorId: tutorId),
      ),
    );
  }
}
