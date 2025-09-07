import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/files_service.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/files/file_upload_screen.dart';

class FileListWidget extends StatefulWidget {
  final String attachableType;
  final int attachableId;
  final bool showUploadButton;
  final Function()? onFileUploaded;

  const FileListWidget({
    super.key,
    required this.attachableType,
    required this.attachableId,
    this.showUploadButton = true,
    this.onFileUploaded,
  });

  @override
  State<FileListWidget> createState() => _FileListWidgetState();
}

class _FileListWidgetState extends State<FileListWidget> {
  final FilesService _filesService = FilesService();
  List<FileAttachment> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      setState(() => _isLoading = true);
      
      final files = await _filesService.getEntityFiles(
        attachableType: widget.attachableType,
        attachableId: widget.attachableId,
      );
      
      if (mounted) {
        setState(() {
          _files = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar archivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteFile(FileAttachment file) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Confirmar eliminación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteFile),
        content: Text('${l10n.confirmDeleteFileMessage} "${file.originalFilename}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _filesService.deleteFile(file.id);
      _loadFiles();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fileDeletedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      final uri = Uri.parse(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se puede abrir el archivo';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _getFileIcon(String mimeType) {
    IconData iconData;
    Color color;

    if (mimeType.startsWith('image/')) {
      iconData = Icons.image;
      color = Colors.blue;
    } else if (mimeType == 'application/pdf') {
      iconData = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (mimeType.contains('word')) {
      iconData = Icons.description;
      color = Colors.blue[700]!;
    } else if (mimeType.contains('zip') || mimeType.contains('rar')) {
      iconData = Icons.folder_zip;
      color = Colors.orange;
    } else {
      iconData = Icons.insert_drive_file;
      color = Colors.grey;
    }

    return Icon(iconData, color: color, size: 40);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_files.isEmpty && !widget.showUploadButton) {
      return Center(
        child: Text(
          l10n.noFilesAttached,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showUploadButton)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                // Navegar a la pantalla de subida
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FileUploadScreen(
                      attachableType: widget.attachableType,
                      attachableId: widget.attachableId,
                    ),
                  ),
                );
                
                if (result == true) {
                  _loadFiles();
                  widget.onFileUploaded?.call();
                }
              },
              icon: const Icon(Icons.upload_file),
              label: Text(l10n.uploadFile),
            ),
          ),
        
        if (_files.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noFilesYet,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _files.length,
            itemBuilder: (context, index) {
              final file = _files[index];
              final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  leading: _getFileIcon(file.mimeType),
                  title: Text(
                    file.originalFilename,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${file.formattedSize} • ${dateFormat.format(file.uploadedAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${l10n.uploadedBy}: ${file.uploaderName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => _openFile(file.filePath),
                        tooltip: l10n.openFile,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteFile(file),
                        tooltip: l10n.deleteFile,
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ),
                  onTap: () => _openFile(file.filePath),
                ),
              );
            },
          ),
      ],
    );
  }
}
