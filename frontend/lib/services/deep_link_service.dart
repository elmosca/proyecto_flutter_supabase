import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';

/// Servicio para manejar deep links (tfgapp://)
/// 
/// Escucha enlaces entrantes desde el sistema operativo y
/// permite a la aplicación responder a ellos.
/// 
/// Ejemplos de deep links:
/// - tfgapp://reset-password?code=abc123&type=reset
/// - tfgapp://login
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  
  /// Callback para cuando se recibe un deep link
  Function(Uri)? onLinkReceived;

  /// Inicializa el servicio y comienza a escuchar deep links
  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('🌐 Deep links no disponibles en web');
      return;
    }

    try {
      // Obtener el link inicial (si la app se abrió desde un link)
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        debugPrint('🔗 Deep link inicial detectado: $initialLink');
        _handleLink(initialLink);
      }

      // Escuchar links entrantes mientras la app está corriendo
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          debugPrint('🔗 Deep link recibido: $uri');
          _handleLink(uri);
        },
        onError: (err) {
          debugPrint('❌ Error al recibir deep link: $err');
        },
      );

      debugPrint('✅ Servicio de deep links inicializado');
    } catch (e) {
      debugPrint('❌ Error al inicializar deep links: $e');
    }
  }

  /// Maneja un deep link recibido
  void _handleLink(Uri uri) {
    debugPrint('📨 Procesando deep link:');
    debugPrint('   Scheme: ${uri.scheme}');
    debugPrint('   Host: ${uri.host}');
    debugPrint('   Path: ${uri.path}');
    debugPrint('   Query: ${uri.query}');
    debugPrint('   QueryParameters: ${uri.queryParameters}');

    // Verificar que sea nuestro esquema
    if (uri.scheme != 'tfgapp') {
      debugPrint('⚠️  Esquema no reconocido: ${uri.scheme}');
      return;
    }

    // Notificar al callback si está registrado
    if (onLinkReceived != null) {
      onLinkReceived!(uri);
    } else {
      debugPrint('⚠️  No hay callback registrado para manejar el link');
    }
  }

  /// Limpia los recursos del servicio
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    debugPrint('🧹 Servicio de deep links finalizado');
  }
}

