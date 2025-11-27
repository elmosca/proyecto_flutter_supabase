import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../models/conversation_thread.dart';
import '../../models/project.dart';
import '../../models/anteproject.dart';
import '../../models/project_message.dart';
import '../../models/anteproject_message.dart';
import '../../models/user.dart';
import '../../services/project_messages_service.dart';
import '../../services/anteproject_messages_service.dart';
import '../../widgets/navigation/app_bar_actions.dart';
import '../../l10n/app_localizations.dart';

/// Pantalla para ver y enviar mensajes dentro de un hilo específico
class ThreadMessagesScreen extends StatefulWidget {
  final ConversationThread thread;
  final Project? project;
  final Anteproject? anteproject;
  /// Si es false, no usa Scaffold propio (para usar con PersistentScaffold)
  final bool useOwnScaffold;

  const ThreadMessagesScreen({
    super.key,
    required this.thread,
    this.project,
    this.anteproject,
    this.useOwnScaffold = true,
  });

  @override
  State<ThreadMessagesScreen> createState() => _ThreadMessagesScreenState();
}

class _ThreadMessagesScreenState extends State<ThreadMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ProjectMessagesService _projectMessagesService =
      ProjectMessagesService();
  final AnteprojectMessagesService _anteprojectMessagesService =
      AnteprojectMessagesService();

  List<dynamic> _messages = []; // Puede ser ProjectMessage o AnteprojectMessage
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUser = authState.user;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<dynamic> messages;

      if (widget.thread.isProjectThread) {
        messages = await _projectMessagesService.getProjectMessages(
          widget.thread.projectId!,
          threadId: widget.thread.id,
        );
      } else {
        messages = await _anteprojectMessagesService.getAnteprojectMessages(
          widget.thread.anteprojectId!,
          threadId: widget.thread.id,
        );
      }

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
        _markMessagesAsRead();
      }
    } catch (e) {
      debugPrint('❌ Error al cargar mensajes: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = l10n.errorLoadingConversations(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _markMessagesAsRead() async {
    if (_currentUser == null) return;

    try {
      for (final message in _messages) {
        if (message is ProjectMessage) {
          if (!message.isRead && message.senderId != _currentUser!.id) {
            await _projectMessagesService.markAsRead(message.id);
          }
        } else if (message is AnteprojectMessage) {
          if (!message.isRead && message.senderId != _currentUser!.id) {
            await _anteprojectMessagesService.markAsRead(message.id);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error al marcar mensajes como leídos: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      if (widget.thread.isProjectThread) {
        await _projectMessagesService.createMessage(
          projectId: widget.thread.projectId!,
          content: content,
          threadId: widget.thread.id,
        );
      } else {
        await _anteprojectMessagesService.createMessage(
          anteprojectId: widget.thread.anteprojectId!,
          content: content,
          threadId: widget.thread.id,
        );
      }

      await _loadMessages();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSendingMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Widget _buildBody(Color color) {
    return Column(
      children: [
        // Lista de mensajes
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorState()
              : _messages.isEmpty
              ? _buildEmptyState()
              : _buildMessagesList(),
        ),

        // Barra de envío
        _buildMessageInput(color),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Para tutores, siempre usar verde. Para estudiantes, usar verde para proyectos y azul para anteproyectos
    final color = _currentUser?.role == UserRole.tutor 
        ? Colors.green 
        : (widget.thread.isProjectThread ? Colors.green : Colors.blue);

    if (!widget.useOwnScaffold) {
      // Cuando se usa dentro de PersistentScaffold, solo retornar el body
      return _buildBody(color);
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.thread.title, style: const TextStyle(fontSize: 16)),
            Text(
              widget.project?.title ?? widget.anteproject?.title ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
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
                    onPressed: _loadMessages,
                    tooltip: AppLocalizations.of(context)!.update,
                  ),
                ],
              )
            : [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadMessages,
                  tooltip: AppLocalizations.of(context)!.update,
                ),
              ],
      ),
      body: _buildBody(color),
    );
  }

  Widget _buildErrorState() {
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
          ElevatedButton(
            onPressed: _loadMessages,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No hay mensajes aún',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sé el primero en escribir',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMyMessage =
            _currentUser != null &&
            (message is ProjectMessage
                ? message.senderId == _currentUser!.id
                : message is AnteprojectMessage
                ? message.senderId == _currentUser!.id
                : false);

        return _buildMessageBubble(message, isMyMessage);
      },
    );
  }

  Widget _buildMessageBubble(dynamic message, bool isMyMessage) {
    // Para tutores, siempre usar verde. Para estudiantes, usar verde para proyectos y azul para anteproyectos
    final color = _currentUser?.role == UserRole.tutor 
        ? Colors.green 
        : (widget.thread.isProjectThread ? Colors.green : Colors.blue);
    final content = message is ProjectMessage
        ? message.content
        : message is AnteprojectMessage
        ? message.content
        : '';
    final createdAt = message is ProjectMessage
        ? message.createdAt
        : message is AnteprojectMessage
        ? message.createdAt
        : DateTime.now();
    final isRead = message is ProjectMessage
        ? message.isRead
        : message is AnteprojectMessage
        ? message.isRead
        : false;

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMyMessage ? color.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMyMessage ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMyMessage ? Radius.zero : const Radius.circular(16),
          ),
          border: Border.all(
            color: isMyMessage ? color.shade300 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                if (isMyMessage) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: isRead 
                        ? (_currentUser?.role == UserRole.tutor ? Colors.green : Colors.blue)
                        : Colors.grey.shade600,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.writeMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: color,
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    final String time =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    if (messageDate == today) {
      return time;
    } else {
      return '${date.day}/${date.month} $time';
    }
  }
}
