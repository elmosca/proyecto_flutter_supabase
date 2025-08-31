import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar el idioma de la aplicación
class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('es'); // Español por defecto
  
  /// Obtiene el idioma actual
  Locale get currentLocale => _currentLocale;
  
  /// Lista de idiomas soportados
  static const List<Locale> supportedLocales = [
    Locale('es'), // Español
    Locale('en'), // Inglés
  ];
  
  /// Constructor
  LanguageService() {
    _loadSavedLanguage();
  }
  
  /// Carga el idioma guardado en las preferencias
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        _currentLocale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
    }
  }
  
  /// Cambia el idioma de la aplicación
  Future<void> changeLanguage(Locale newLocale) async {
    if (_currentLocale == newLocale) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, newLocale.languageCode);
      
      _currentLocale = newLocale;
      notifyListeners();
      
      debugPrint('Language changed to: ${newLocale.languageCode}');
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }
  
  /// Cambia al idioma español
  Future<void> changeToSpanish() async {
    await changeLanguage(const Locale('es'));
  }
  
  /// Cambia al idioma inglés
  Future<void> changeToEnglish() async {
    await changeLanguage(const Locale('en'));
  }
  
  /// Obtiene el nombre del idioma actual
  String getCurrentLanguageName() {
    switch (_currentLocale.languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return 'Español';
    }
  }
  
  /// Verifica si el idioma actual es español
  bool get isSpanish => _currentLocale.languageCode == 'es';
  
  /// Verifica si el idioma actual es inglés
  bool get isEnglish => _currentLocale.languageCode == 'en';
}
