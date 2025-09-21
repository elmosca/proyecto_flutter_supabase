import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/user.dart' as app_user;
import '../../services/user_service.dart';

class ImportStudentsCSVScreen extends StatefulWidget {
  final int tutorId;

  const ImportStudentsCSVScreen({super.key, required this.tutorId});

  @override
  State<ImportStudentsCSVScreen> createState() => _ImportStudentsCSVScreenState();
}

class _ImportStudentsCSVScreenState extends State<ImportStudentsCSVScreen> {
  bool _isLoading = false;
  String? _selectedFilePath;
  List<Map<String, dynamic>> _csvData = [];
  List<String> _errors = [];

  Future<void> _pickCSVFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFilePath = result.files.first.path;
        });
        await _parseCSVFile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _parseCSVFile() async {
    if (_selectedFilePath == null) return;

    try {
      final file = File(_selectedFilePath!);
      final contents = await file.readAsString();
      final lines = contents.split('\n');
      
      if (lines.isEmpty) {
        setState(() {
          _errors = ['El archivo CSV está vacío'];
        });
        return;
      }

      // Obtener headers
      final headers = lines[0].split(',').map((h) => h.trim()).toList();
      
      // Validar headers requeridos
      final requiredHeaders = ['full_name', 'email', 'nre'];
      final missingHeaders = requiredHeaders.where((h) => !headers.contains(h)).toList();
      
      if (missingHeaders.isNotEmpty) {
        setState(() {
          _errors = [
            'Headers faltantes: ${missingHeaders.join(', ')}',
            'Headers encontrados: ${headers.join(', ')}',
            'Headers requeridos: ${requiredHeaders.join(', ')}'
          ];
        });
        return;
      }

      // Parsear datos
      final List<Map<String, dynamic>> data = [];
      final List<String> errors = [];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final values = line.split(',').map((v) => v.trim()).toList();
        
        if (values.length != headers.length) {
          errors.add('Línea ${i + 1}: Número de columnas incorrecto');
          continue;
        }

        final row = <String, dynamic>{};
        for (int j = 0; j < headers.length; j++) {
          row[headers[j]] = values[j];
        }

        // Validar datos requeridos
        if (row['full_name']?.toString().trim().isEmpty ?? true) {
          errors.add('Línea ${i + 1}: Nombre completo es obligatorio');
          continue;
        }
        
        if (row['email']?.toString().trim().isEmpty ?? true) {
          errors.add('Línea ${i + 1}: Email es obligatorio');
          continue;
        }
        
        if (row['nre']?.toString().trim().isEmpty ?? true) {
          errors.add('Línea ${i + 1}: NRE es obligatorio');
          continue;
        }

        data.add(row);
      }

      setState(() {
        _csvData = data;
        _errors = errors;
      });

    } catch (e) {
      setState(() {
        _errors = ['Error al procesar archivo CSV: $e'];
      });
    }
  }

  Future<void> _importStudents() async {
    if (_csvData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay datos válidos para importar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = UserService();
      int successCount = 0;
      int errorCount = 0;

      for (final row in _csvData) {
        try {
          final newUser = app_user.User(
            id: 0,
            fullName: row['full_name']?.toString().trim() ?? '',
            email: row['email']?.toString().trim() ?? '',
            nre: row['nre']?.toString().trim() ?? '',
            role: app_user.UserRole.student,
            phone: row['phone']?.toString().trim() ?? '',
            biography: row['biography']?.toString().trim() ?? '',
            status: app_user.UserStatus.active,
            specialty: row['specialty']?.toString().trim() ?? 'Desarrollo de Aplicaciones Multiplataforma',
            academicYear: row['academic_year']?.toString().trim() ?? '2024-2025',
            tutorId: widget.tutorId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await userService.createUser(newUser);
          successCount++;
        } catch (e) {
          errorCount++;
          debugPrint('Error al crear usuario ${row['email']}: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Importación completada: $successCount exitosos, $errorCount errores'),
            backgroundColor: errorCount > 0 ? Colors.orange : Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error durante la importación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Estudiantes CSV'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información sobre el formato CSV
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Formato CSV Requerido',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'El archivo CSV debe contener las siguientes columnas:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    const Text('• full_name (obligatorio)'),
                    const Text('• email (obligatorio)'),
                    const Text('• nre (obligatorio)'),
                    const Text('• phone (opcional)'),
                    const Text('• biography (opcional)'),
                    const Text('• specialty (opcional)'),
                    const Text('• academic_year (opcional)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón para seleccionar archivo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickCSVFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Seleccionar Archivo CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mostrar archivo seleccionado
            if (_selectedFilePath != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.file_present, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFilePath!.split('/').last,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Mostrar errores
            if (_errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Errores encontrados',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._errors.map((error) => Text('• $error')),
                    ],
                  ),
                ),
              ),
            ],

            // Mostrar vista previa de datos
            if (_csvData.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.preview, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Vista Previa (${_csvData.length} estudiantes)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._csvData.take(5).map((row) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '• ${row['full_name']} (${row['email']})',
                          style: const TextStyle(fontSize: 14),
                        ),
                      )),
                      if (_csvData.length > 5)
                        Text(
                          '... y ${_csvData.length - 5} más',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],

            // Botón de importación
            if (_csvData.isNotEmpty && _errors.isEmpty) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _importStudents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Importar ${_csvData.length} Estudiantes'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
