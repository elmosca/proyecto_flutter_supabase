import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/forms/add_student_form.dart';
import '../../screens/forms/import_students_csv_screen.dart';

class AddStudentsDialog extends StatelessWidget {
  final int tutorId;
  final VoidCallback? onStudentAdded;
  final VoidCallback? onImportCompleted;

  const AddStudentsDialog({
    super.key,
    required this.tutorId,
    this.onStudentAdded,
    this.onImportCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person_add, color: Colors.blue),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.addStudents),
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
            onPressed: () async {
              Navigator.of(context).pop(); // Cerrar el diálogo primero
              await _navigateToAddIndividual(context);
            },
            icon: const Icon(Icons.person_add),
            label: Text(AppLocalizations.of(context)!.addIndividually),
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
            onPressed: () async {
              Navigator.of(context).pop(); // Cerrar el diálogo primero
              await _navigateToImportCSV(context);
            },
            icon: const Icon(Icons.upload_file),
            label: Text(AppLocalizations.of(context)!.importFromCSV),
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
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ),
      ],
    );
  }

  Future<bool?> _navigateToAddIndividual(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddStudentForm(tutorId: tutorId)),
    );
    // Si se creó un estudiante, notificar al padre para recargar
    if (result == true && onStudentAdded != null) {
      onStudentAdded!();
    }
    return result;
  }

  Future<String?> _navigateToImportCSV(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImportStudentsCSVScreen(tutorId: tutorId),
      ),
    );
    // Si se completó la importación, el resultado será 'imported'
    if (result == 'imported' && onImportCompleted != null) {
      onImportCompleted!();
    }
    return result;
  }

  // Método estático para navegar directamente a importación CSV (sin diálogo)
  static void navigateToImportCSV(BuildContext context, {int? tutorId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImportStudentsCSVScreen(tutorId: tutorId),
      ),
    );
  }
}
