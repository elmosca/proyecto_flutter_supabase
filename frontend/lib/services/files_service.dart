import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../utils/app_exception.dart';
import '../utils/network_error_detector.dart';
import 'supabase_interceptor.dart';
import 'academic_permissions_service.dart';

/// Servicio para gestión de archivos con Supabase Storage.
///
/// Proporciona operaciones de subida, descarga y gestión de archivos:
/// - Subida de archivos a Supabase Storage con metadatos
/// - Descarga de archivos desde URLs públicas
/// - Gestión de metadatos en la tabla `files`
/// - Validación de tipos de archivo y tamaños
/// - Organización por usuario y entidad adjunta
///
/// ## Funcionalidades principales:
/// - Subir archivos con metadatos completos
/// - Descargar archivos desde URLs públicas
/// - Obtener lista de archivos por entidad
/// - Eliminar archivos y sus metadatos
/// - Validación de tipos MIME y tamaños
///
/// ## Seguridad:
/// - Requiere autenticación: Sí
/// - Roles permitidos: Todos (con restricciones por RLS)
/// - Políticas RLS aplicadas: Los usuarios solo ven archivos de sus entidades
///
/// ## Ejemplo de uso:
/// ```dart
/// final service = FilesService();
/// final result = await service.uploadFile(
///   fileName: 'documento.pdf',
///   fileBytes: bytes,
///   attachableType: 'anteproject',
///   attachableId: 123
/// );
/// ```
///
/// Ver también: [FileUploadResult]
class FilesService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;
  final AcademicPermissionsService _academicPermissionsService = AcademicPermissionsService();
  static const String _bucketName = 'project-files';

  /// Sube un archivo a Supabase Storage con metadatos.
  ///
  /// Parámetros:
  /// - [fileName]: Nombre original del archivo
  /// - [fileBytes]: Contenido del archivo como bytes
  /// - [attachableType]: Tipo de entidad (anteproject, project, task)
  /// - [attachableId]: ID de la entidad a la que se adjunta
  ///
  /// Retorna:
  /// - [FileUploadResult] con información del archivo subido
  ///
  /// Lanza:
  /// - [AuthenticationException] si no hay usuario autenticado
  /// - [FileException] si falla la subida
  Future<FileUploadResult> uploadFile({
    required String fileName,
    required Uint8List fileBytes,
    required String attachableType,
    required int attachableId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id, role, academic_year')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;
      final userRole = userResponse['role'] as String;
      final studentAcademicYear = userResponse['academic_year'] as String?;

      // Verificar permisos de escritura para estudiantes
      if (userRole == 'student') {
        final canWrite = await _academicPermissionsService.canWriteByAcademicYear(studentAcademicYear);
        if (!canWrite) {
          throw ValidationException(
            'read_only_mode',
            technicalMessage:
                'No puedes subir archivos porque tu año académico ya no está activo.',
          );
        }
      }

      // Generar un nombre único para el archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName =
          '$userId/$attachableType/$attachableId/${timestamp}_$fileName';

      // Subir archivo a Supabase Storage
      final uploadResponse = await _supabase.storage
          .from(_bucketName)
          .uploadBinary(uniqueFileName, fileBytes);

      if (uploadResponse.isEmpty) {
        throw FileException(
          'file_upload_failed',
          technicalMessage: 'File upload failed',
        );
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
        'uploaded_by': userId,
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw FileException(
        'file_upload_failed',
        technicalMessage: 'Error uploading file: $e',
        originalError: e,
      );
    }
  }

  /// Obtiene los archivos de una entidad (task, comment, anteproject, project)
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
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw FileException(
        'file_download_failed',
        technicalMessage: 'Error getting files: $e',
        originalError: e,
      );
    }
  }

  /// Elimina un archivo
  Future<void> deleteFile(int fileId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException(
          'not_authenticated',
          technicalMessage: 'User not authenticated',
        );
      }

      // Obtener el ID del usuario desde la tabla users
      final userResponse = await _supabase
          .from('users')
          .select('id, role, academic_year')
          .eq('email', user.email!)
          .single();

      final userId = userResponse['id'] as int;
      final userRole = userResponse['role'] as String;
      final studentAcademicYear = userResponse['academic_year'] as String?;

      // Verificar permisos de escritura para estudiantes
      if (userRole == 'student') {
        final canWrite = await _academicPermissionsService.canWriteByAcademicYear(studentAcademicYear);
        if (!canWrite) {
          throw ValidationException(
            'read_only_mode',
            technicalMessage:
                'No puedes eliminar archivos porque tu año académico ya no está activo.',
          );
        }
      }

      // Obtener información del archivo
      final fileResponse = await _supabase
          .from('files')
          .select('filename, uploaded_by')
          .eq('id', fileId)
          .single();

      // Verificar que el usuario puede eliminar el archivo
      if (fileResponse['uploaded_by'] != userId) {
        throw const FilesException(
          'No tienes permisos para eliminar este archivo',
        );
      }

      // Eliminar de Storage
      await _supabase.storage.from(_bucketName).remove([
        fileResponse['filename'],
      ]);

      // Eliminar de la base de datos
      await _supabase.from('files').delete().eq('id', fileId);
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw FileException(
        'file_delete_failed',
        technicalMessage: 'Error deleting file: $e',
        originalError: e,
      );
    }
  }

  /// Descarga un archivo
  /// 
  /// [filePath] puede ser:
  /// - URL pública completa (https://...)
  /// - Path relativo en el bucket (userId/type/id/filename)
  Future<Uint8List> downloadFile(String filePath) async {
    try {
      String fileName;
      
      // Si es una URL pública, extraer el path del bucket
      if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
        // Extraer el path después del bucket name en la URL
        // Formato: https://xxx.supabase.co/storage/v1/object/public/project-files/path/to/file
        final uri = Uri.parse(filePath);
        final pathSegments = uri.pathSegments;
        
        // Buscar el índice del bucket name
        final bucketIndex = pathSegments.indexOf(_bucketName);
        if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
          // Reconstruir el path desde después del bucket name
          fileName = pathSegments.sublist(bucketIndex + 1).join('/');
        } else {
          // Fallback: usar el último segmento
          fileName = pathSegments.last;
        }
      } else {
        // Ya es un path relativo
        fileName = filePath;
      }

      final response = await _supabase.storage
          .from(_bucketName)
          .download(fileName);

      return response;
    } catch (e) {
      // Interceptar errores de Supabase
      if (SupabaseErrorInterceptor.isSupabaseError(e)) {
        throw SupabaseErrorInterceptor.handleError(e);
      }

      // Interceptar errores de red
      if (NetworkErrorDetector.isNetworkError(e)) {
        throw NetworkErrorDetector.detectNetworkError(e);
      }

      throw FileException(
        'file_download_failed',
        technicalMessage: 'Error downloading file: $e',
        originalError: e,
      );
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
    ];

    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Valida el tamaño del archivo (máximo 10MB por defecto)
  bool isValidFileSize(int sizeInBytes, {int maxSizeMB = 10}) {
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
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
