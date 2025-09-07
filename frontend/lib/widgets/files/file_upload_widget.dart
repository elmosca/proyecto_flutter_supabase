import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/files_service.dart';
import '../../l10n/app_localizations.dart';

class FileUploadWidget extends StatefulWidget {
  final String attachableType;
  final int attachableId;

  const FileUploadWidget({
    super.key,
    required this.attachableType,
    required this.attachableId,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final FilesService _filesService = FilesService();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png', 'gif', 'zip', 'rar'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (file.bytes == null) {
          throw Exception('No se pudo leer el archivo');
        }

        // Validar tipo de archivo
        if (!_filesService.isValidFileType(file.name)) {
          throw Exception('Tipo de archivo no permitido');
        }

        // Validar tamaño (máximo 50MB)
        if (!_filesService.isValidFileSize(file.size)) {
          throw Exception('El archivo excede el tamaño máximo de 50MB');
        }

        setState(() {
          _selectedFileName = file.name;
          _selectedFileBytes = file.bytes;
        });
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

  Future<void> _uploadFile() async {
    if (_selectedFileBytes == null || _selectedFileName == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Simular progreso de subida
      _startProgressSimulation();

      await _filesService.uploadFile(
        fileName: _selectedFileName!,
        fileBytes: _selectedFileBytes!,
        attachableType: widget.attachableType,
        attachableId: widget.attachableId,
      );

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.fileUploadedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        
        // Regresar con resultado exitoso
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startProgressSimulation() {
    // Simular progreso de subida
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted || _uploadProgress >= 0.9) return false;
      
      setState(() {
        _uploadProgress += 0.05;
        if (_uploadProgress > 0.9) _uploadProgress = 0.9;
      });
      
      return _isUploading && _uploadProgress < 0.9;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFileName = null;
      _selectedFileBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              l10n.uploadFile,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Área de selección de archivo
            if (_selectedFileName == null)
              InkWell(
                onTap: _selectFile,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.clickToSelectFile,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.allowedFileTypes,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${l10n.maxFileSize}: 50MB',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedFileName!,
                              style: theme.textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!_isUploading)
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _clearSelection,
                            ),
                        ],
                      ),
                      if (_isUploading) ...[
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_uploadProgress * 100).toInt()}%',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _selectedFileName != null && !_isUploading
                      ? _uploadFile
                      : null,
                  icon: const Icon(Icons.upload),
                  label: Text(_isUploading ? l10n.uploading : l10n.upload),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
