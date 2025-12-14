import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Banner informativo que se muestra cuando el usuario está en modo solo lectura.
///
/// Este banner aparece cuando un estudiante pertenece a un año académico
/// que ya no está activo, indicando que solo puede consultar sus datos
/// históricos pero no puede realizar modificaciones.
class ReadOnlyBanner extends StatelessWidget {
  /// El año académico del estudiante (para mostrar en el mensaje).
  final String academicYear;

  /// Si el banner debe ser descartable (mostrar botón de cerrar).
  final bool dismissible;

  /// Callback cuando se descarta el banner.
  final VoidCallback? onDismiss;

  const ReadOnlyBanner({
    super.key,
    required this.academicYear,
    this.dismissible = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.orange.shade200,
          width: 1,
        ),
          ),
      ),
        child: Row(
          children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
                size: 24,
              ),
          const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.readOnlyModeTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                const SizedBox(height: 2),
                  Text(
                    l10n.readOnlyModeMessage(academicYear),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade800,
                        ),
                  ),
                ],
              ),
            ),
            if (dismissible && onDismiss != null)
              IconButton(
                icon: Icon(
                  Icons.close,
                color: Colors.orange.shade700,
                  size: 20,
                ),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }
}

/// Versión compacta del banner para usar en AppBars o espacios reducidos.
class ReadOnlyChip extends StatelessWidget {
  const ReadOnlyChip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Chip(
      avatar: const Icon(
        Icons.lock_outline,
        size: 16,
        color: Colors.orange,
      ),
      label: Text(
        l10n.readOnlyModeTitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.orange,
        ),
      ),
      backgroundColor: Colors.orange.shade50,
      side: BorderSide(color: Colors.orange.shade200),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
