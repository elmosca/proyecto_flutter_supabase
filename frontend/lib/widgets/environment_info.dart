import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Widget que muestra información del entorno (solo en modo debug)
class EnvironmentInfo extends StatelessWidget {
  const EnvironmentInfo({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔧 Información del Entorno (Debug)',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 4),
          Text('Red Interna: ${AppConfig.isInternalNetwork ? "✅" : "❌"}'),
          Text('Dominio Externo: ${AppConfig.isExternalDomain ? "✅" : "❌"}'),
          const Text('Modo Debug: ${kDebugMode ? "✅" : "❌"}'),
          const Text('Plataforma Web: ${kIsWeb ? "✅" : "❌"}'),
          Text('Entorno: ${AppConfig.environment}'),
        ],
      ),
    );
  }
}
