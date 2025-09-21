import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/user_management_service.dart';

class CsvImportWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onImportComplete;
  
  const CsvImportWidget({
    super.key,
    required this.onImportComplete,
  });

  @override
  State<CsvImportWidget> createState() => _CsvImportWidgetState();
}

class _CsvImportWidgetState extends State<CsvImportWidget> {
  final UserManagementService _userManagementService = UserManagementService();
  
  bool _isImporting = false;
  String? _selectedFileName;
  List<Map<String, dynamic>> _parsedData = [];
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Importar Estudiantes desde CSV',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Información sobre el formato CSV
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Formato CSV requerido:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'email,password,full_name,specialty,academic_year\n'
                    'ejemplo@alumno.cifpcarlos3.es,password123,Juan Pérez,DAM,2024-2025\n'
                    'maria@alumno.cifpcarlos3.es,password456,María García,ASIR,2024-2025',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botón para seleccionar archivo
            ElevatedButton.icon(
              onPressed: _isImporting ? null : _selectFile,
              icon: const Icon(Icons.upload_file),
              label: Text(_selectedFileName ?? 'Seleccionar archivo CSV'),
            ),
            
            if (_selectedFileName != null) ...[
              const SizedBox(height: 16),
              Text(
                'Archivo seleccionado: $_selectedFileName',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            
            if (_parsedData.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '${_parsedData.length} estudiantes encontrados:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _parsedData.length,
                  itemBuilder: (context, index) {
                    final student = _parsedData[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(student['full_name'] ?? 'Sin nombre'),
                      subtitle: Text(student['email'] ?? 'Sin email'),
                      trailing: Text(
                        student['specialty'] ?? 'Sin especialidad',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Botón para importar
            if (_parsedData.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isImporting ? null : _importStudents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isImporting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Importando...'),
                          ],
                        )
                      : const Text('Importar Estudiantes'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFileName = file.name;
          _errorMessage = null;
        });

        await _parseCsvFile(file.bytes!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al seleccionar archivo: $e';
      });
    }
  }

  Future<void> _parseCsvFile(List<int> bytes) async {
    try {
      final content = utf8.decode(bytes);
      final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      if (lines.isEmpty) {
        setState(() {
          _errorMessage = 'El archivo CSV está vacío';
        });
        return;
      }

      // Verificar encabezados
      final headers = lines[0].split(',').map((h) => h.trim().toLowerCase()).toList();
      final requiredHeaders = ['email', 'password', 'full_name', 'specialty', 'academic_year'];
      
      for (final required in requiredHeaders) {
        if (!headers.contains(required)) {
          setState(() {
            _errorMessage = 'Falta el encabezado requerido: $required';
          });
          return;
        }
      }

      // Parsear datos
      final List<Map<String, dynamic>> parsedData = [];
      
      for (int i = 1; i < lines.length; i++) {
        final values = lines[i].split(',').map((v) => v.trim()).toList();
        
        if (values.length >= 5) {
          parsedData.add({
            'email': values[0],
            'password': values[1],
            'full_name': values[2],
            'specialty': values[3],
            'academic_year': values[4],
          });
        }
      }

      setState(() {
        _parsedData = parsedData;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al procesar archivo CSV: $e';
      });
    }
  }

  Future<void> _importStudents() async {
    if (_parsedData.isEmpty) return;

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      final result = await _userManagementService.importStudentsFromCsv(
        studentsData: _parsedData,
      );

      widget.onImportComplete(result);
      
      // Limpiar el formulario
      setState(() {
        _selectedFileName = null;
        _parsedData = [];
        _isImporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estudiantes importados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isImporting = false;
      });
    }
  }
}
