import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget para capturar errores globales y mostrar una pantalla de error amigable
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  String? errorMessage;
  String? errorDetails;

  @override
  void initState() {
    super.initState();
    
    // Capturar errores de Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
      
      setState(() {
        hasError = true;
        errorMessage = details.exception.toString();
        errorDetails = details.stack?.toString();
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return ErrorScreen(
        errorMessage: errorMessage ?? 'Error desconocido',
        errorDetails: errorDetails,
        onRetry: () {
          setState(() {
            hasError = false;
            errorMessage = null;
            errorDetails = null;
          });
        },
      );
    }

    return widget.child;
  }
}

/// Pantalla de error personalizada
class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final String? errorDetails;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.errorMessage,
    this.errorDetails,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[600],
              ),
              const SizedBox(height: 24),
              Text(
                'Error de Aplicación',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (kDebugMode && errorDetails != null) ...[
                ExpansionTile(
                  title: const Text('Detalles del Error'),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        errorDetails!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Recargar la página
                  if (kIsWeb) {
                    // En web, recargar la página
                    // ignore: avoid_web_libraries_in_flutter
                    // html.window.location.reload();
                  }
                },
                child: const Text('Recargar Página'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
