import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../models/project.dart';
import '../../models/project_message.dart';
import '../../models/user.dart';
import '../../services/project_messages_service.dart';
import '../../services/academic_permissions_service.dart';

class ProjectMessagesScreen extends StatefulWidget {
  final Project project;

  const ProjectMessagesScreen({super.key, required this.project});

  @override
  State<ProjectMessagesScreen> createState() => _ProjectMessagesScreenState();
}

class _ProjectMessagesScreenState extends State<ProjectMessagesScreen> {
  final ProjectMessagesService _messagesService = ProjectMessagesService();
  final AcademicPermissionsService _academicPermissionsService = AcademicPermissionsService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ProjectMessage> _messages = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isReadOnly = false; // Modo solo lectura para años académicos anteriores
  User? _currentUser;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
    _loadUnreadCount();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      // Verificar modo solo lectura
      final isReadOnly = await _academicPermissionsService.isReadOnly(user);
      if (mounted) {
      setState(() {
          _currentUser = user;
          _isReadOnly = isReadOnly;
      });
      }
    }
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final messages = await _messagesService.getProjectMessages(widget.project.id);
      
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        
        // Marcar mensajes como leídos (sin esperar)
        _markMessagesAsRead();
        
        // Scroll to bottom after loading
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar mensajes: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _messagesService.getUnreadCount(widget.project.id);
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar conteo de no leídos: $e');
    }
  }

  Future<void> _markMessagesAsRead() async {
    if (_currentUser == null) return;

    try {
      for (final message in _messages) {
        // Marcar como leído solo los mensajes que no son propios y no están leídos
        if (message.senderId != _currentUser!.id && !message.isRead) {
          await _messagesService.markAsRead(message.id);
        }
      }
      _loadUnreadCount();
    } catch (e) {
      debugPrint('Error al marcar mensajes como leídos: $e');
    }
  }

  Future<void> _submitMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, escribe un mensaje'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      final message = await _messagesService.createMessage(
        projectId: widget.project.id,
        content: _messageController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _messages.add(message);
          _messageController.clear();
          _isSubmitting = false;
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mensaje enviado exitosamente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar mensaje: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mensajes con el Tutor'),
            Text(
              widget.project.title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        // Los colores del AppBar ya se manejan en el tema
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text(
                  '$_unreadCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: theme.colorScheme.error,
                padding: EdgeInsets.zero,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadMessages();
              _loadUnreadCount();
            },
            tooltip: 'Actualizar mensajes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del proyecto
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainer,
            child: Row(
              children: [
                Icon(
                  Icons.chat,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversación con el Tutor',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Aquí puedes hacer consultas sobre tu proyecto',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de mensajes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
          ),

          // Formulario de nuevo mensaje
          _buildMessageForm(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay mensajes aún',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia la conversación con tu tutor',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ProjectMessage message) {
    final isMyMessage = message.senderId == _currentUser?.id;
    final senderName = message.sender?.fullName ?? 'Usuario desconocido';
    final senderRole = message.sender?.role ?? UserRole.student;
    final theme = Theme.of(context);

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMyMessage 
              ? theme.colorScheme.primaryContainer 
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMyMessage ? 12 : 0),
            bottomRight: Radius.circular(isMyMessage ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y rol
            if (!isMyMessage) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    senderName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getRoleName(senderRole),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Contenido del mensaje
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMyMessage 
                    ? theme.colorScheme.onPrimaryContainer 
                    : theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 4),

            // Timestamp y estado de lectura
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDate(message.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isMyMessage 
                        ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isMyMessage) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageForm() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isReadOnly,
              decoration: InputDecoration(
                hintText: _isReadOnly
                    ? 'Modo solo lectura - No puedes enviar mensajes'
                    : 'Escribe tu mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: _isReadOnly ? null : (_) => _submitMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: (_isSubmitting || _isReadOnly) ? null : _submitMessage,
            backgroundColor: theme.colorScheme.primary,
            mini: true,
            child: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Icon(Icons.send, color: theme.colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }

  // Helper colors removed as we now use theme
  
  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.tutor:
        return 'Tutor';
      case UserRole.student:
        return 'Estudiante';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}
