// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Obtiene la URL actual (solo Web)
String getCurrentUrl() {
  return html.window.location.href;
}

/// Reemplaza el estado del historial (solo Web)
void replaceHistoryState(String url) {
  html.window.history.replaceState(null, '', url);
}

/// Obtiene el pathname actual (solo Web)
String getPathname() {
  return html.window.location.pathname ?? '';
}

/// Obtiene el search (query string) actual (solo Web)
String getSearch() {
  return html.window.location.search ?? '';
}

/// Obtiene el hash actual (solo Web)
String getHash() {
  return html.window.location.hash;
}

