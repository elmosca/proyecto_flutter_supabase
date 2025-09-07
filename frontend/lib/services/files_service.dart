import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class FilesService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;
  static const String _bucketName = 'task-files';

  /// Sube un archivo a Supabase Storage
  Future<FileUploadResult> uploadFile({
    required String fileName,
    required Uint8List fileBytes,
    required String attachableType,
    required int attachableId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const FilesException('Usuario no autenticado');
      }

      // Generar un nombre único para el archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${user.id}/$attachableType/$attachableId/${timestamp}_$fileName';

      // Subir archivo a Supabase Storage
      final uploadResponse = await _supabase.storage
          .from(_bucketName)
          .uploadBinary(uniqueFileName, fileBytes);

      if (uploadResponse.isEmpty) {
        throw const FilesException('Error al subir el archivo');
      }

      // Obtener URL pública del archivo
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(uniqueFileName);

      // Guardar metadata en la base de datos
      final fileData = {
        'filename': uniqueFileName,
        'original_filename': fileName,
        'file_path': publicUrl,
        'file_size': fileBytes.length,
        'mime_type': _getMimeType(fileName),
        'uploaded_by': user.id,
        'attachable_type': attachableType,
        'attachable_id': attachableId,
      };

      final response = await _supabase
          .from('files')
          .insert(fileData)
          .select()
          .single();

      return FileUploadResult(
        id: response['id'] as int,
        fileName: fileName,
        filePath: publicUrl,
        fileSize: fileBytes.length,
      );
    } catch (e) {
      throw FilesException('Error al subir archivo: $e');
    }
  }

  /// Obtiene los archivos de una entidad (task, comment, anteproject)
  Future<List<FileAttachment>> getEntityFiles({
    required String attachableType,
    required int attachableId,
  }) async {
    try {
      final response = await _supabase
          .from('files')
          .select('''
            *,
            uploader:uploaded_by (
              id,
              full_name,
              email
            )
          ''')
          .eq('attachable_type', attachableType)
          .eq('attachable_id', attachableId)
          .order('uploaded_at', ascending: false);

      return response.map<FileAttachment>(FileAttachment.fromJson).toList();
    } catch (e) {
      throw FilesException('Error al obtener archivos: $e');
    }
  }

  /// Elimina un archivo
  Future<void> deleteFile(int fileId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const FilesException('Usuario no autenticado');
      }

      // Obtener información del archivo
      final fileResponse = await _supabase
          .from('files')
          .select('filename, uploaded_by')
          .eq('id', fileId)
          .single();

      // Verificar que el usuario puede eliminar el archivo
      if (fileResponse['uploaded_by'] != user.id) {
        throw const FilesException('No tienes permisos para eliminar este archivo');
      }

      // Eliminar de Storage
      await _supabase.storage
          .from(_bucketName)
          .remove([fileResponse['filename']]);

      // Eliminar de la base de datos
      await _supabase
          .from('files')
          .delete()
          .eq('id', fileId);
    } catch (e) {
      throw FilesException('Error al eliminar archivo: $e');
    }
  }

  /// Descarga un archivo
  Future<Uint8List> downloadFile(String filePath) async {
    try {
      // Extraer el nombre del archivo del path completo
      final fileName = filePath.split('/').last;
      
      final response = await _supabase.storage
          .from(_bucketName)
          .download(fileName);

      return response;
    } catch (e) {
      throw FilesException('Error al descargar archivo: $e');
    }
  }

  /// Obtiene el tipo MIME basado en la extensión del archivo
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      default:
        return 'application/octet-stream';
    }
  }

  /// Valida si el archivo es de un tipo permitido
  bool isValidFileType(String fileName) {
    final allowedExtensions = [
      'pdf', 'doc', 'docx', 'txt', 
      'jpg', 'jpeg', 'png', 'gif',
      'zip', 'rar'
    ];
    
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Valida el tamaño del archivo (máximo 50MB por defecto)
  bool isValidFileSize(int sizeInBytes, {int maxSizeMB = 50}) {
    final maxSizeInBytes = maxSizeMB * 1024 * 1024;
    return sizeInBytes <= maxSizeInBytes;
  }
}

/// Excepción personalizada para errores de archivos
class FilesException implements Exception {
  final String message;
  const FilesException(this.message);
  
  @override
  String toString() => message;
}

/// Resultado de la subida de archivo
class FileUploadResult {
  final int id;
  final String fileName;
  final String filePath;
  final int fileSize;

  FileUploadResult({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
  });
}

/// Modelo para archivos adjuntos
class FileAttachment {
  final int id;
  final String filename;
  final String originalFilename;
  final String filePath;
  final int fileSize;
  final String mimeType;
  final DateTime uploadedAt;
  final Map<String, dynamic>? uploader;

  FileAttachment({
    required this.id,
    required this.filename,
    required this.originalFilename,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedAt,
    this.uploader,
  });

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      id: json['id'] as int,
      filename: json['filename'] as String,
      originalFilename: json['original_filename'] as String,
      filePath: json['file_path'] as String,
      fileSize: json['file_size'] as int,
      mimeType: json['mime_type'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      uploader: json['uploader'] as Map<String, dynamic>?,
    );
  }

  String get uploaderName => uploader?['full_name'] ?? 'Desconocido';
  
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
