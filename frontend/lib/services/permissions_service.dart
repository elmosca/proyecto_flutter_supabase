import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Servicio para manejar permisos de la aplicación
class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;
  PermissionsService._internal();

  static PermissionsService get instance => _instance;

  /// Verifica si la plataforma es Android
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Verifica si la plataforma es iOS
  bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Verifica si la plataforma es Web
  bool get isWeb => kIsWeb;

  /// Solicita permisos de almacenamiento según la versión de Android
  Future<PermissionStatus> requestStoragePermission() async {
    if (isWeb) {
      // En web no se necesitan permisos de almacenamiento
      return PermissionStatus.granted;
    }

    if (isIOS) {
      // En iOS, file_picker maneja los permisos automáticamente
      return PermissionStatus.granted;
    }

    if (isAndroid) {
      // Para Android 13+ (API 33+), usar permisos granulares
      if (await _isAndroid13OrHigher()) {
        return _requestAndroid13StoragePermissions();
      } else {
        // Para Android < 13, usar permisos tradicionales
        return Permission.storage.request();
      }
    }

    return PermissionStatus.granted;
  }

  /// Verifica si el dispositivo es Android 13 o superior
  Future<bool> _isAndroid13OrHigher() async {
    if (!isAndroid) return false;

    try {
      // Verificar versión de Android
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33; // Android 13 (API 33)
    } catch (e) {
      debugPrint('Error checking Android version: $e');
      return false;
    }
  }

  /// Solicita permisos granulares para Android 13+
  Future<PermissionStatus> _requestAndroid13StoragePermissions() async {
    try {
      // Solicitar permisos para imágenes, video y audio
      final permissions = [
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ];

      final statuses = await permissions.request();

      // Verificar si todos los permisos fueron concedidos
      final allGranted = statuses.values.every(
        (status) => status == PermissionStatus.granted,
      );

      return allGranted ? PermissionStatus.granted : PermissionStatus.denied;
    } catch (e) {
      debugPrint('Error requesting Android 13+ permissions: $e');
      return PermissionStatus.denied;
    }
  }

  /// Verifica el estado actual de los permisos de almacenamiento
  Future<PermissionStatus> checkStoragePermission() async {
    if (isWeb) return PermissionStatus.granted;
    if (isIOS) return PermissionStatus.granted;

    if (isAndroid) {
      if (await _isAndroid13OrHigher()) {
        // Para Android 13+, verificar permisos granulares
        final permissions = [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ];

        final statuses = await permissions.request();
        final allGranted = statuses.values.every(
          (status) => status == PermissionStatus.granted,
        );

        return allGranted ? PermissionStatus.granted : PermissionStatus.denied;
      } else {
        // Para Android < 13, verificar permiso tradicional
        return Permission.storage.status;
      }
    }

    return PermissionStatus.granted;
  }

  /// Verifica si los permisos de almacenamiento están concedidos
  Future<bool> hasStoragePermission() async {
    final status = await checkStoragePermission();
    return status == PermissionStatus.granted;
  }

  /// Abre la configuración de la aplicación para que el usuario pueda
  /// conceder permisos manualmente
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }

  /// Verifica permisos de red
  Future<bool> hasNetworkPermission() async {
    if (isWeb) return true;

    try {
      // INTERNET es un permiso automático en Android
      // En realidad, INTERNET es un permiso automático en Android
      // pero podemos verificar conectividad
      return true;
    } catch (e) {
      debugPrint('Error checking network permission: $e');
      return true; // Asumir que está disponible
    }
  }

  /// Obtiene un mensaje descriptivo del estado del permiso
  String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permisos concedidos';
      case PermissionStatus.denied:
        return 'Permisos denegados';
      case PermissionStatus.restricted:
        return 'Permisos restringidos por el sistema';
      case PermissionStatus.limited:
        return 'Permisos limitados';
      case PermissionStatus.permanentlyDenied:
        return 'Permisos permanentemente denegados. Ve a configuración.';
      case PermissionStatus.provisional:
        return 'Permisos provisionales';
    }
  }
}
