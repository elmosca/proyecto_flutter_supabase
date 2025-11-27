import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/user_management_service.dart';
import '../../utils/validators.dart';

// No necesitamos dart:io porque usamos bytes directamente desde file_picker

class ImportStudentsCSVScreen extends StatefulWidget {
  final int? tutorId;

  const ImportStudentsCSVScreen({super.key, this.tutorId});

  @override
  State<ImportStudentsCSVScreen> createState() =>
      _ImportStudentsCSVScreenState();
}

/// Resultado de validación de una fila del CSV
class _CsvRowValidation {
  final int lineNumber;
  final Map<String, dynamic> data;
  final bool isValid;
  final String? errorMessage;
  final bool emailValid;

  _CsvRowValidation({
    required this.lineNumber,
    required this.data,
    required this.isValid,
    this.errorMessage,
    this.emailValid = false,
  });
}

class _ImportStudentsCSVScreenState extends State<ImportStudentsCSVScreen> {
  bool _isLoading = false;
  String? _selectedFileName;
  List<Map<String, dynamic>> _csvData = [];
  List<String> _errors = [];
  List<_CsvRowValidation> _rowValidations = [];

  Future<void> _pickCSVFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFileName = file.name;
        });

        // Usar bytes directamente (disponible en todas las plataformas)
        if (file.bytes != null) {
          await _parseCSVFromBytes(file.bytes!);
        } else {
          throw Exception(
            'No se pudieron leer los bytes del archivo. Por favor, intenta de nuevo.',
          );
        }
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

  /// Parsea una línea CSV respetando comas dentro de valores
  /// Maneja valores con comas si están entre comillas
  /// También maneja valores sin comillas pero con comas (heurística)
  List<String> _parseCSVLine(String line) {
    final List<String> result = [];
    String current = '';
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        // Toggle quotes
        inQuotes = !inQuotes;
        // No añadir las comillas al resultado
      } else if (char == ',' && !inQuotes) {
        // Coma fuera de comillas = separador de campo
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }

    // Añadir el último campo
    result.add(current.trim());

    return result;
  }

  Future<void> _parseCSVFromBytes(List<int> bytes) async {
    try {
      final contents = utf8.decode(bytes);
      await _processCSVContent(contents);
    } catch (e) {
      setState(() {
        _errors = ['Error al procesar archivo: $e'];
      });
    }
  }

  Future<void> _processCSVContent(String contents) async {
    try {
      final lines = contents.split('\n');

      if (lines.isEmpty) {
        setState(() {
          _errors = ['El archivo CSV está vacío'];
        });
        return;
      }

      // Obtener headers usando parser CSV robusto
      final headers = _parseCSVLine(lines[0]);

      // Validar headers requeridos
      final requiredHeaders = ['full_name', 'email', 'nre'];
      final missingHeaders = requiredHeaders
          .where((h) => !headers.contains(h))
          .toList();

      if (missingHeaders.isNotEmpty) {
        setState(() {
          _errors = [
            'Headers faltantes: ${missingHeaders.join(', ')}',
            'Headers encontrados: ${headers.join(', ')}',
            'Headers requeridos: ${requiredHeaders.join(', ')}',
          ];
        });
        return;
      }

      // Parsear y validar datos
      final List<Map<String, dynamic>> data = [];
      final List<String> errors = [];
      final List<_CsvRowValidation> validations = [];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // Usar parser CSV robusto que maneja comas dentro de valores
        final values = _parseCSVLine(line);

        // Validar número de columnas
        if (values.length != headers.length) {
          errors.add('Línea ${i + 1}: Número de columnas incorrecto');
          validations.add(
            _CsvRowValidation(
              lineNumber: i + 1,
              data: {},
              isValid: false,
              errorMessage: 'Número de columnas incorrecto',
            ),
          );
          continue;
        }

        final row = <String, dynamic>{};
        for (int j = 0; j < headers.length; j++) {
          row[headers[j]] = values[j];
        }

        // Validar datos requeridos y email
        String? validationError;
        bool emailValid = false;

        // Validar nombre completo
        if (row['full_name']?.toString().trim().isEmpty ?? true) {
          validationError = 'Nombre completo es obligatorio';
        }
        // Validar email
        else if (row['email']?.toString().trim().isEmpty ?? true) {
          validationError = 'Email es obligatorio';
        }
        // Validar formato de email
        else {
          final emailValue = row['email']?.toString().trim() ?? '';
          final emailError = Validators.email(emailValue);
          if (emailError != null) {
            validationError = 'Email inválido: $emailError';
          } else {
            emailValid = true;
          }
        }
        // Validar NRE
        if (validationError == null &&
            (row['nre']?.toString().trim().isEmpty ?? true)) {
          validationError = 'NRE es obligatorio';
        }

        // Crear validación de fila
        final validation = _CsvRowValidation(
          lineNumber: i + 1,
          data: row,
          isValid: validationError == null,
          errorMessage: validationError,
          emailValid: emailValid,
        );

        validations.add(validation);

        if (validationError != null) {
          errors.add('Línea ${i + 1}: $validationError');
        } else {
          data.add(row);
        }
      }

      setState(() {
        _csvData = data;
        _errors = errors;
        _rowValidations = validations;
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

    // Mostrar mensaje informativo
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Importando ${_csvData.length} estudiantes... Esto puede tardar unos momentos.',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.blue,
        ),
      );
    }

    try {
      final userManagementService = UserManagementService();

      // Preparar datos para creación masiva
      // Generar contraseñas para todos los estudiantes
      final List<Map<String, dynamic>> studentsData = [];
      final Map<String, String> generatedPasswords = {}; // email -> password

      for (final row in _csvData) {
        final email = row['email']?.toString().trim() ?? '';
        final generatedPassword = _generateTempPassword();
        generatedPasswords[email] = generatedPassword;

        final academicYearStr = row['academic_year']?.toString().trim();
        final phoneStr = row['phone']?.toString().trim();
        final nreStr = row['nre']?.toString().trim();
        final specialtyStr = row['specialty']?.toString().trim();
        final biographyStr = row['biography']?.toString().trim();

        studentsData.add({
          'email': email,
          'password': generatedPassword,
          'full_name': row['full_name']?.toString().trim() ?? '',
          'academic_year': (academicYearStr == null || academicYearStr.isEmpty)
              ? null
              : academicYearStr,
          'phone': (phoneStr == null || phoneStr.isEmpty) ? null : phoneStr,
          'nre': (nreStr == null || nreStr.isEmpty) ? null : nreStr,
          'specialty': (specialtyStr == null || specialtyStr.isEmpty)
              ? null
              : specialtyStr,
          'biography': (biographyStr == null || biographyStr.isEmpty)
              ? null
              : biographyStr,
        });
      }

      // Usar creación masiva mediante Edge Function
      // Esto evita los límites de rate limiting del cliente
      final bulkResult = await userManagementService.bulkCreateStudents(
        students: studentsData,
        tutorId: widget.tutorId,
      );

      // Procesar resultados
      final List<Map<String, dynamic>> results = bulkResult['results'] ?? [];
      final List<Map<String, dynamic>> errors = bulkResult['errors'] ?? [];
      final summary = bulkResult['summary'] ?? {};

      int successCount = summary['successful'] ?? results.length;
      int errorCount = summary['failed'] ?? errors.length;
      final List<Map<String, dynamic>> importResults = [];

      // Añadir resultados exitosos
      for (final result in results) {
        importResults.add({
          'email': result['email'],
          'name': result['name'],
          'password': result['password'],
          'status': 'success',
          'message': 'Usuario creado en Auth. Email de bienvenida enviado.',
        });
      }

      // Añadir errores
      for (final error in errors) {
        importResults.add({
          'email': error['email'],
          'name': error['name'],
          'status': 'error',
          'message': error['error'] ?? 'Error al crear usuario',
        });
      }

      if (mounted) {
        // Mostrar diálogo con resumen detallado (incluye contraseñas generadas)
        await _showImportResultsDialog(successCount, errorCount, importResults);
        // Devolver 'imported' para indicar que se completó la importación
        Navigator.of(context).pop('imported');
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

  /// Genera una contraseña temporal segura
  String _generateTempPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    return List.generate(
      12,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Muestra un diálogo con el resumen detallado de la importación
  Future<void> _showImportResultsDialog(
    int successCount,
    int errorCount,
    List<Map<String, dynamic>> results,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                errorCount == 0 ? Icons.check_circle : Icons.warning,
                color: errorCount == 0 ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                errorCount == 0
                    ? 'Importación Exitosa'
                    : 'Importación Completada',
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen general
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: errorCount == 0
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: errorCount == 0
                          ? Colors.green.shade200
                          : Colors.orange.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$successCount usuarios creados exitosamente',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      if (errorCount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$errorCount errores',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Nota informativa sobre emails
                if (successCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Usuarios creados en Supabase Auth',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cada estudiante recibirá un email de bienvenida con su información de acceso. Las contraseñas mostradas abajo son temporales y se pueden usar para el primer acceso.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Lista de resultados
                if (results.isNotEmpty) ...[
                  const Text(
                    'Detalle por usuario:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        final isSuccess = result['status'] == 'success';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isSuccess ? Icons.check_circle : Icons.error,
                                color: isSuccess ? Colors.green : Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result['name'] ?? 'Sin nombre',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: isSuccess
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                    Text(
                                      result['email'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (isSuccess &&
                                        result['password'] != null) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Contraseña: ${result['password']}',
                                                style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.copy,
                                                size: 16,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              tooltip: 'Copiar contraseña',
                                              onPressed: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: result['password'],
                                                  ),
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Contraseña copiada',
                                                    ),
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        result['message'] ??
                                            'Usuario creado exitosamente',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ] else if (!isSuccess)
                                      Text(
                                        result['message'] ?? '',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.red.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tutorId != null
              ? 'Importar Estudiantes CSV'
              : 'Importar Estudiantes CSV (Admin)',
        ),
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
                    if (widget.tutorId == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Nota: Los estudiantes se importarán sin tutor asignado. Puedes asignar tutores después desde la lista.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
            if (_selectedFileName != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.file_present, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFileName!,
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

            // Mostrar resumen de validación
            if (_rowValidations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _errors.isEmpty
                                ? Icons.check_circle
                                : Icons.warning,
                            color: _errors.isEmpty
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Resumen de Validación',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _errors.isEmpty
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_csvData.length} filas válidas',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.error, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${_errors.length} errores',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Mostrar vista previa detallada con validación
            if (_rowValidations.isNotEmpty) ...[
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
                            'Validación por Fila (${_rowValidations.length} filas)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _rowValidations.length > 10
                              ? 10
                              : _rowValidations.length,
                          itemBuilder: (context, index) {
                            final validation = _rowValidations[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    validation.isValid
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: validation.isValid
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Línea ${validation.lineNumber}: ${validation.data['full_name'] ?? 'Sin nombre'}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: validation.isValid
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                        ),
                                        if (validation.data['email'] != null)
                                          Text(
                                            'Email: ${validation.data['email']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: validation.emailValid
                                                  ? Colors.green.shade600
                                                  : Colors.red.shade600,
                                            ),
                                          ),
                                        if (!validation.isValid &&
                                            validation.errorMessage != null)
                                          Text(
                                            'Error: ${validation.errorMessage}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red.shade700,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (_rowValidations.length > 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '... y ${_rowValidations.length - 10} filas más',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],

            // Botón de importación
            if (_csvData.isNotEmpty) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _importStudents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _errors.isEmpty
                        ? Colors.green
                        : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _errors.isEmpty
                              ? 'Importar ${_csvData.length} Estudiantes'
                              : 'Importar ${_csvData.length} Estudiantes (${_errors.length} con errores se omitirán)',
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
