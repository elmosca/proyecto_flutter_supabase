import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../models/project.dart';
import '../../models/anteproject.dart';
import '../../models/conversation_thread.dart';
import '../../models/user.dart';
import '../../services/conversation_threads_service.dart';
import '../../widgets/navigation/app_bar_actions.dart';
import '../../l10n/app_localizations.dart';
import 'thread_messages_screen.dart';
import 'create_thread_dialog.dart';

/// Pantalla que muestra la lista de hilos/temas de conversación
/// de un proyecto o anteproyecto específico
class ConversationThreadsScreen extends StatefulWidget {
  final Project? project;
  final Anteproject? anteproject;
  /// Si es false, no usa Scaffold propio (para usar con PersistentScaffold)
  final bool useOwnScaffold;

  const ConversationThreadsScreen({
    super.key,
    this.project,
    this.anteproject,
    this.useOwnScaffold = true,
  }) : assert(
          project != null || anteproject != null,
          'Debe proporcionar un proyecto o anteproyecto',
        );

  @override
  State<ConversationThreadsScreen> createState() =>
      _ConversationThreadsScreenState();
}

class _ConversationThreadsScreenState extends State<ConversationThreadsScreen> {
  final ConversationThreadsService _threadsService =
      ConversationThreadsService();

  List<ConversationThread> _threads = [];
  bool _isLoading = true;
  String? _errorMessage;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadThreads();
  }

  Future<void> _loadCurrentUser() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _currentUser = authState.user;
      });
    }
  }

  Future<void> _loadThreads() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<ConversationThread> threads;
      
      if (widget.project != null) {
        threads = await _threadsService.getProjectThreads(widget.project!.id);
      } else {
        threads =
            await _threadsService.getAnteprojectThreads(widget.anteproject!.id);
      }

      if (mounted) {
        setState(() {
          _threads = threads;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar hilos: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = l10n.errorLoadingConversations(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createNewThread() async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => const CreateThreadDialog(),
    );

    if (title != null && title.trim().isNotEmpty) {
      try {
        setState(() => _isLoading = true);

        final thread = await _threadsService.createThread(
          projectId: widget.project?.id,
          anteprojectId: widget.anteproject?.id,
          title: title.trim(),
        );

        if (mounted) {
          // Abrir el nuevo hilo automáticamente
          _openThread(thread);
          // Recargar la lista
          _loadThreads();
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorLoadingConversations(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _openThread(ConversationThread thread) {
    if (_currentUser == null) return;

    // Navegación simplificada: directamente a ThreadMessagesScreen
    // ThreadMessagesScreen gestiona su propio Scaffold cuando useOwnScaffold es true
    // Esto evita el anidamiento de PersistentScaffold que causa AppBars duplicadas
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThreadMessagesScreen(
          thread: thread,
          project: widget.project,
          anteproject: widget.anteproject,
          useOwnScaffold: true, // Esta pantalla ahora gestiona su propio Scaffold
        ),
      ),
    ).then((_) {
      // Recargar al volver para actualizar contadores
      _loadThreads();
    });
  }

  Widget _buildBody() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? _buildErrorState()
            : _threads.isEmpty
                ? _buildEmptyState()
                : _buildThreadsList();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.project != null
        ? widget.project!.title
        : widget.anteproject!.title;

    // Para tutores, siempre usar verde. Para estudiantes, usar verde para proyectos y azul para anteproyectos
    final color = _currentUser?.role == UserRole.tutor 
        ? Colors.green 
        : (widget.project != null ? Colors.green : Colors.blue);

    if (!widget.useOwnScaffold) {
      // Cuando se usa dentro de PersistentScaffold, solo retornar el body
      return Stack(
        children: [
          _buildBody(),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _createNewThread,
              backgroundColor: color,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.newTopic),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.conversations),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: _currentUser != null
            ? AppBarActions.build(
                context,
                _currentUser!,
                additionalActions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadThreads,
                    tooltip: AppLocalizations.of(context)!.update,
                  ),
                ],
              )
            : [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadThreads,
                  tooltip: AppLocalizations.of(context)!.update,
                ),
              ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewThread,
        backgroundColor: color,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo tema'),
      ),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadThreads,
            child: Text(l10n.retry),
          ),
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
            Icons.forum_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noConversationsYet,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createNewTopicToStart,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.useButtonBelow,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _threads.length,
      itemBuilder: (context, index) {
        final thread = _threads[index];
        return _buildThreadCard(thread);
      },
    );
  }

  Widget _buildThreadCard(ConversationThread thread) {
    final hasUnread = (thread.unreadCount ?? 0) > 0;
    // Para tutores, siempre usar verde. Para estudiantes, usar verde para proyectos y azul para anteproyectos
    final color = _currentUser?.role == UserRole.tutor 
        ? Colors.green 
        : (widget.project != null ? Colors.green : Colors.blue);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: hasUnread ? 4 : 2,
      child: InkWell(
        onTap: () => _openThread(thread),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.forum,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      thread.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Fecha último mensaje
                    Text(
                      _formatDate(context, thread.lastMessageAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Badge de no leídos y flecha
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${thread.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return l10n.agoDaysShort(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.agoHoursShort(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.agoMinutesShort(difference.inMinutes);
    } else {
      return l10n.now;
    }
  }
}

