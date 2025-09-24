import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/language_service.dart';

/// Widget selector de idioma para usar en cualquier pantalla
class LanguageSelector extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;

  const LanguageSelector({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Usar ListenableBuilder para escuchar cambios del LanguageService
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, child) {
        final languageService = LanguageService.instance;
        
        if (isCompact) {
          return _buildCompactSelector(context, l10n, languageService);
        } else {
          return _buildFullSelector(context, l10n, languageService);
        }
      },
    );
  }

  /// Selector compacto (solo iconos)
  Widget _buildCompactSelector(
    BuildContext context,
    AppLocalizations l10n,
    LanguageService languageService,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: l10n.language,
      onSelected: (String languageCode) {
        _changeLanguage(languageService, languageCode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'es',
          child: Row(
            children: [
              const Text('🇪🇸'),
              const SizedBox(width: 8),
              Text(l10n.spanish),
              if (languageService.isSpanish) ...[
                const Spacer(),
                const Icon(Icons.check, color: Colors.green),
              ],
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              const Text('🇺🇸'),
              const SizedBox(width: 8),
              Text(l10n.english),
              if (languageService.isEnglish) ...[
                const Spacer(),
                const Icon(Icons.check, color: Colors.green),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Selector completo (con etiqueta)
  Widget _buildFullSelector(
    BuildContext context,
    AppLocalizations l10n,
    LanguageService languageService,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel) ...[
              Row(
                children: [
                  const Icon(Icons.language),
                  const SizedBox(width: 8),
                  Text(
                    l10n.language,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: _buildLanguageButton(
                    context: context,
                    languageService: languageService,
                    languageCode: 'es',
                    flag: '🇪🇸',
                    name: l10n.spanish,
                    isSelected: languageService.isSpanish,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLanguageButton(
                    context: context,
                    languageService: languageService,
                    languageCode: 'en',
                    flag: '🇺🇸',
                    name: l10n.english,
                    isSelected: languageService.isEnglish,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Botón de idioma individual
  Widget _buildLanguageButton({
    required BuildContext context,
    required LanguageService languageService,
    required String languageCode,
    required String flag,
    required String name,
    required bool isSelected,
  }) {
    return OutlinedButton(
      onPressed: () => _changeLanguage(languageService, languageCode),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected 
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : null,
        side: BorderSide(
          color: isSelected 
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            flag,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Cambia el idioma de la aplicación
  void _changeLanguage(LanguageService languageService, String languageCode) {
    switch (languageCode) {
      case 'es':
        languageService.changeToSpanish();
        break;
      case 'en':
        languageService.changeToEnglish();
        break;
    }
  }
}

/// Widget selector de idioma para AppBar
class LanguageSelectorAppBar extends StatelessWidget {
  const LanguageSelectorAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const LanguageSelector(
      showLabel: false,
      isCompact: true,
    );
  }
}
