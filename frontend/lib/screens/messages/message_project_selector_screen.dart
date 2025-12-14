import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../models/anteproject.dart';
import '../../models/project.dart';
import '../../models/user.dart';
import '../../services/anteprojects_service.dart';
import '../../services/projects_service.dart';
import '../../widgets/navigation/persistent_scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'conversation_threads_screen.dart';

/// Pantalla para que el estudiante seleccione un proyecto/anteproyecto
/// para iniciar o continuar una conversación con el tutor
class MessageProjectSelectorScreen extends StatefulWidget {
  const MessageProjectSelectorScreen({super.key});

  @override
  State<MessageProjectSelectorScreen> createState() =>
      _MessageProjectSelectorScreenState();
}

class _MessageProjectSelectorScreenState
    extends State<MessageProjectSelectorScreen> {
  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  final ProjectsService _projectsService = ProjectsService();

  List<Project> _projects = [];
  List<Anteproject> _anteprojects = [];
  bool _isLoading = true;
  String? _errorMessage;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadData();
  }

  Future<void> _loadCurrentUser() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _currentUser = authState.user;
      });
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint(
        '🔄 MessageProjectSelector: Cargando proyectos y anteproyectos...',
      );

      // Cargar proyectos y anteproyectos en paralelo
      final results = await Future.wait([
        _projectsService.getStudentProjects(),
        _anteprojectsService.getStudentAnteprojects(),
      ]);

      final projects = results[0] as List<Project>;
      final allAnteprojects = results[1] as List<Anteproject>;

      // Filtrar anteproyectos: excluir los aprobados ya que aparecen como proyectos
      final anteprojects = allAnteprojects
          .where(
            (anteproject) => anteproject.status != AnteprojectStatus.approved,
          )
          .toList();

      debugPrint(
        '✅ MessageProjectSelector: ${projects.length} proyectos encontrados',
      );
      if (projects.isNotEmpty) {
        for (var project in projects) {
          debugPrint('   - Proyecto: ${project.title} (ID: ${project.id})');
        }
      }

      debugPrint(
        '✅ MessageProjectSelector: ${allAnteprojects.length} anteproyectos totales encontrados',
      );
      debugPrint(
        '✅ MessageProjectSelector: ${anteprojects.length} anteproyectos (sin aprobados)',
      );
      if (anteprojects.isNotEmpty) {
        for (var anteproject in anteprojects) {
          debugPrint(
            '   - Anteproyecto: ${anteproject.title} (ID: ${anteproject.id}, Estado: ${anteproject.status})',
          );
        }
      }

      // Mostrar anteproyectos aprobados que no tienen proyecto asociado (por si acaso)
      final approvedWithoutProject = allAnteprojects
          .where(
            (anteproject) => anteproject.status == AnteprojectStatus.approved,
          )
          .toList();
      if (approvedWithoutProject.isNotEmpty) {
        debugPrint(
          'ℹ️ MessageProjectSelector: ${approvedWithoutProject.length} anteproyectos aprobados (deben aparecer como proyectos)',
        );
        for (var anteproject in approvedWithoutProject) {
          debugPrint(
            '   - Anteproyecto aprobado: ${anteproject.title} (ID: ${anteproject.id})',
          );
        }
      }

      if (mounted) {
        setState(() {
          _projects = projects;
          _anteprojects = anteprojects;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cargar proyectos/anteproyectos: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar proyectos: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _openProjectChat(Project project) {
    if (_currentUser == null) return;

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => PersistentScaffold(
              title: project.title,
              titleKey: 'conversations',
              user: _currentUser!,
              body: ConversationThreadsScreen(
                project: project,
                useOwnScaffold: false,
              ),
            ),
          ),
        )
        .then((_) {
          // Recargar datos cuando se vuelve de la pantalla de conversación
          // para mostrar proyectos/anteproyectos actualizados
          _loadData();
        });
  }

  void _openAnteprojectChat(Anteproject anteproject) {
    if (_currentUser == null) return;

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => PersistentScaffold(
              title: anteproject.title,
              titleKey: 'conversations',
              user: _currentUser!,
              body: ConversationThreadsScreen(
                anteproject: anteproject,
                useOwnScaffold: false,
              ),
            ),
          ),
        )
        .then((_) {
          // Recargar datos cuando se vuelve de la pantalla de conversación
          // para mostrar proyectos/anteproyectos actualizados
          _loadData();
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // No usar Scaffold propio porque estamos dentro de PersistentScaffold
    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
        ? _buildErrorState()
        : (_projects.isEmpty && _anteprojects.isEmpty)
        ? _buildEmptyState()
        : _buildProjectsList();

    // Si el contenido es desplazable, usar RefreshIndicator
    if (!_isLoading &&
        _errorMessage == null &&
        (_projects.isNotEmpty || _anteprojects.isNotEmpty)) {
      return Stack(
        children: [
          RefreshIndicator(onRefresh: _loadData, child: content),
          // Botón de recarga flotante
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _loadData,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              tooltip: l10n.updateList,
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      );
    }

    // Para estados que no son desplazables, solo mostrar el contenido
    return content;
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: Text(l10n.retry)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noActiveProjects,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createAnteprojectToChat,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    final l10n = AppLocalizations.of(context)!;
    final hasApprovedProject = _projects.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado informativo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.selectProjectOrAnteprojectToStartConversation,
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Lista de Proyectos Aprobados
          if (_projects.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.approvedProjects,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._projects.map(
              (project) => _buildProjectCard(
                title: project.title,
                subtitle: l10n.projectInDevelopment,
                color: Colors.green,
                icon: Icons.assignment_turned_in,
                onTap: () => _openProjectChat(project),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Lista de Anteproyectos
          if (_anteprojects.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 8),
                Text(
                  l10n.anteprojects,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._anteprojects.map(
              (anteproject) => _buildProjectCard(
                title: anteproject.title,
                subtitle: '${l10n.status}: ${anteproject.status.displayName}',
                color: Colors.blue,
                icon: Icons.description,
                enabled: !hasApprovedProject,
                onTap: hasApprovedProject
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Ya tienes un proyecto aprobado. No puedes crear nuevas conversaciones en anteproyectos.',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    : () => _openAnteprojectChat(anteproject),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final effectiveColor = enabled ? color : Colors.grey;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: effectiveColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: enabled ? null : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chat_bubble, color: effectiveColor, size: 24),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
