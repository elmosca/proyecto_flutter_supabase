import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user.dart';
import '../../widgets/navigation/persistent_scaffold.dart';
import '../../config/app_config.dart';

/// Pantalla de ayuda que muestra información y guías según el rol del usuario
class HelpScreen extends StatefulWidget {
  final User user;

  const HelpScreen({super.key, required this.user});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String? _guideText;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadGuide();
  }

  String _getWikiUrl() {
    switch (widget.user.role) {
      case UserRole.student:
        return AppConfig.githubWikiStudentGuide;
      case UserRole.tutor:
        return AppConfig.githubWikiTutorGuide;
      case UserRole.admin:
        return AppConfig.githubWikiAdminGuide;
    }
  }

  Future<void> _openWikiInBrowser() async {
    final url = Uri.parse(_getWikiUrl());
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir la wiki: ${url.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getWikiRawUrl() {
    switch (widget.user.role) {
      case UserRole.student:
        return AppConfig.githubWikiRawStudentGuide;
      case UserRole.tutor:
        return AppConfig.githubWikiRawTutorGuide;
      case UserRole.admin:
        return AppConfig.githubWikiRawAdminGuide;
    }
  }

  Future<void> _loadGuide() async {
    // Cargar directamente desde la wiki de GitHub (raw content)
    final url = _getWikiRawUrl();
    
    debugPrint('📥 Cargando guía desde la wiki de GitHub: $url');

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Accept': 'text/plain, text/markdown, */*',
              'User-Agent': 'Flutter-App/1.0',
            },
          )
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        String content = response.body;
        
        // Verificar que no sea HTML (página de error o redirección)
        final trimmedContent = content.trim();
        if (trimmedContent.startsWith('<!DOCTYPE') || 
            trimmedContent.startsWith('<html') ||
            trimmedContent.startsWith('<?xml')) {
          debugPrint('⚠️ GitHub devolvió HTML en lugar de Markdown');
          debugPrint('Primeros 500 caracteres recibidos:');
          debugPrint(trimmedContent.substring(0, trimmedContent.length > 500 ? 500 : trimmedContent.length));
          debugPrint('Content-Type: ${response.headers['content-type']}');
          throw Exception('GitHub devolvió HTML en lugar de Markdown. Verifica la URL: $url');
        }
        
        // Verificar que comience con Markdown (normalmente # o texto)
        if (!trimmedContent.startsWith('#') && 
            !trimmedContent.startsWith('*') &&
            !trimmedContent.startsWith('-') &&
            !trimmedContent.startsWith('[') &&
            trimmedContent.length > 10) {
          debugPrint('⚠️ El contenido no parece ser Markdown válido');
          debugPrint('Primeros 200 caracteres: ${trimmedContent.substring(0, trimmedContent.length > 200 ? 200 : trimmedContent.length)}');
        }
        
        // Verificar que sea Markdown válido
        if (content.trim().isEmpty) {
          throw Exception('El contenido está vacío');
        }
        
        debugPrint('✅ Guía cargada correctamente desde GitHub (${content.length} caracteres)');
        
        if (mounted) {
          setState(() {
            _guideText = content;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('❌ Error cargando guía desde GitHub: $e');
      debugPrint('URL intentada: $url');
      if (mounted) {
        setState(() {
          _guideText = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PersistentScaffold(
      title: 'Guía de Uso',
      titleKey: 'help',
      user: widget.user,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _guideText == null
              ? _buildErrorView(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 16),
                      _buildWikiLinkCard(context),
                      const SizedBox(height: 16),
                      _buildMarkdownContent(context),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar la guía',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'La guía se carga desde GitHub. Verifica tu conexión a internet o contacta al administrador del sistema.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadGuide(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openWikiInBrowser,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir Guía en la Wiki de GitHub'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[700],
                side: BorderSide(color: Colors.blue[300]!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdownContent(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MarkdownBody(
          data: _guideText!,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(fontSize: 14, height: 1.6),
            h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            h4: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            code: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              backgroundColor: Colors.grey[200],
            ),
            codeblockDecoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            blockquote: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
            listBullet: const TextStyle(fontSize: 14),
            strong: const TextStyle(fontWeight: FontWeight.bold),
            em: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    String roleEmoji;
    String roleTitle;
    String roleDescription;

    switch (widget.user.role) {
      case UserRole.student:
        roleEmoji = '📚';
        roleTitle = 'Guía para Estudiantes';
        roleDescription =
            'Aprende cómo gestionar tus anteproyectos, tareas y proyectos';
        break;
      case UserRole.tutor:
        roleEmoji = '👨‍🏫';
        roleTitle = 'Guía para Tutores';
        roleDescription =
            'Aprende cómo supervisar estudiantes, revisar anteproyectos y gestionar el sistema';
        break;
      case UserRole.admin:
        roleEmoji = '👨‍💼';
        roleTitle = 'Guía para Administradores';
        roleDescription =
            'Aprende cómo gestionar el sistema, usuarios y configuración';
        break;
    }

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(
              roleEmoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roleDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWikiLinkCard(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue[700],
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Esta guía se carga directamente desde la wiki oficial de GitHub',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _openWikiInBrowser,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Abrir en GitHub'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
