import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Widget para manejo consistente de errores en la aplicación
class ErrorHandlerWidget extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;
  final String? customTitle;
  final String? customMessage;

  const ErrorHandlerWidget({
    super.key,
    this.error,
    this.onRetry,
    this.customTitle,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              customTitle ?? l10n.error,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              customMessage ?? _getErrorMessage(l10n, error),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getErrorMessage(AppLocalizations l10n, String? error) {
    if (error == null || error.isEmpty) {
      return l10n.unknownErrorMessage;
    }

    // Detectar tipo de error basado en el mensaje
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('network') || 
        errorLower.contains('connection') || 
        errorLower.contains('timeout')) {
      return l10n.networkErrorMessage;
    }
    
    if (errorLower.contains('server') || 
        errorLower.contains('500') || 
        errorLower.contains('502') || 
        errorLower.contains('503')) {
      return l10n.serverErrorMessage;
    }
    
    if (errorLower.contains('validation') || 
        errorLower.contains('invalid') || 
        errorLower.contains('required')) {
      return l10n.formValidationError;
    }
    
    return error; // Mostrar el error original si no se puede categorizar
  }
}

/// Widget para mostrar errores en un SnackBar
class ErrorSnackBar {
  static void show(
    BuildContext context, {
    String? error,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          customMessage ?? _getErrorMessage(l10n, error),
        ),
        backgroundColor: Colors.red.shade600,
        action: onRetry != null
            ? SnackBarAction(
                label: l10n.retry,
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static String _getErrorMessage(AppLocalizations l10n, String? error) {
    if (error == null || error.isEmpty) {
      return l10n.unknownErrorMessage;
    }

    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('network') || 
        errorLower.contains('connection') || 
        errorLower.contains('timeout')) {
      return l10n.networkErrorMessage;
    }
    
    if (errorLower.contains('server') || 
        errorLower.contains('500') || 
        errorLower.contains('502') || 
        errorLower.contains('503')) {
      return l10n.serverErrorMessage;
    }
    
    if (errorLower.contains('validation') || 
        errorLower.contains('invalid') || 
        errorLower.contains('required')) {
      return l10n.formValidationError;
    }
    
    return error;
  }
}

/// Widget para mostrar diálogos de error
class ErrorDialog {
  static Future<void> show(
    BuildContext context, {
    String? error,
    String? customTitle,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text(customTitle ?? l10n.error),
            ],
          ),
          content: Text(
            customMessage ?? _getErrorMessage(l10n, error),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
            if (onRetry != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: Text(l10n.retry),
              ),
          ],
        );
      },
    );
  }

  static String _getErrorMessage(AppLocalizations l10n, String? error) {
    if (error == null || error.isEmpty) {
      return l10n.unknownErrorMessage;
    }

    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('network') || 
        errorLower.contains('connection') || 
        errorLower.contains('timeout')) {
      return l10n.networkErrorMessage;
    }
    
    if (errorLower.contains('server') || 
        errorLower.contains('500') || 
        errorLower.contains('502') || 
        errorLower.contains('503')) {
      return l10n.serverErrorMessage;
    }
    
    if (errorLower.contains('validation') || 
        errorLower.contains('invalid') || 
        errorLower.contains('required')) {
      return l10n.formValidationError;
    }
    
    return error;
  }
}
