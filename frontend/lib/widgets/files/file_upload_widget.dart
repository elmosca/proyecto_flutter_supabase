import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/files_service.dart';
import '../../services/permissions_service.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_exception.dart';

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
  final PermissionsService _permissionsService = PermissionsService.instance;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;

  Future<void> _selectFile() async {
    try {
      // Verificar permisos antes de seleccionar archivo
      final hasPermission = await _permissionsService.hasStoragePermission();

      if (!hasPermission) {
        final status = await _permissionsService.requestStoragePermission();

        if (status != PermissionStatus.granted) {
          if (mounted) {
            _showPermissionDialog(status);
          }
          return;
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'zip',
          'rar',
        ],
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

        // Validar tamaño (máximo 10MB)
        if (!_filesService.isValidFileSize(file.size)) {
          final fileSizeMB = (file.size / (1024 * 1024)).toStringAsFixed(2);
          throw Exception(
            'El archivo ($fileSizeMB MB) excede el tamaño máximo permitido de 10MB. '
            'Por favor, comprime el archivo o selecciona uno más pequeño.',
          );
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
            content: Text(
              AppLocalizations.of(context)!.fileUploadedSuccessfully,
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Regresar con resultado exitoso
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        
        // Extraer mensaje de error más amigable
        String errorMessage;
        if (e is FileException) {
          // Si es una FileException, usar el mensaje técnico que ya está formateado
          errorMessage = e.technicalMessage ?? e.debugMessage;
        } else if (e.toString().contains('exceeded') || 
                   e.toString().contains('excede') ||
                   e.toString().contains('too large') ||
                   e.toString().contains('muy grande')) {
          // Detectar errores de tamaño y formatear mensaje
          final fileSizeMB = _selectedFileBytes != null 
              ? (_selectedFileBytes!.length / (1024 * 1024)).toStringAsFixed(2)
              : 'desconocido';
          errorMessage = 'El archivo ($fileSizeMB MB) excede el tamaño máximo permitido de 10MB. '
              'Por favor, comprime el archivo o selecciona uno más pequeño.';
        } else {
          // Para otros errores, mostrar el mensaje original
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Cerrar',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
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

  /// Muestra un diálogo explicando por qué se necesitan los permisos
  void _showPermissionDialog(PermissionStatus status) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionRequired),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.permissionRequiredMessage),
            const SizedBox(height: 16),
            Text(
              _permissionsService.getPermissionStatusMessage(status),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          if (status == PermissionStatus.permanentlyDenied)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _permissionsService.openAppSettings();
              },
              child: Text(l10n.openSettings),
            )
          else
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _selectFile(); // Intentar de nuevo
              },
              child: Text(l10n.tryAgain),
            ),
        ],
      ),
    );
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
            Text(l10n.uploadFile, style: theme.textTheme.headlineSmall),
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
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
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
                        '${l10n.maxFileSize}: 10MB',
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
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
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
                  onPressed: _isUploading
                      ? null
                      : () => Navigator.of(context).pop(),
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
