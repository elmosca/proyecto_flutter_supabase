/// Helper para manejar operaciones de URL de forma multiplataforma
/// 
/// Usa implementaciones específicas para web y stubs para otras plataformas
export 'url_helper_stub.dart'
    if (dart.library.html) 'url_helper_web.dart';

