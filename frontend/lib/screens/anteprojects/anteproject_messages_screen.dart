import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../models/anteproject.dart';
import '../../models/anteproject_message.dart';
import '../../models/user.dart';
import '../../services/anteproject_messages_service.dart';
import '../../services/anteprojects_service.dart';
import '../../l10n/app_localizations.dart';

class AnteprojectMessagesScreen extends StatefulWidget {
  final Anteproject anteproject;

  const AnteprojectMessagesScreen({super.key, required this.anteproject});

  @override
  State<AnteprojectMessagesScreen> createState() => _AnteprojectMessagesScreenState();
}

class _AnteprojectMessagesScreenState extends State<AnteprojectMessagesScreen> {
  final AnteprojectMessagesService _messagesService = AnteprojectMessagesService();
  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<AnteprojectMessage> _messages = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool? _hasApprovedAnteproject; // null = cargando, true/false = resultado
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
    _checkApprovedAnteproject();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _currentUser = authState.user;
      });
    }
  }

  Future<void> _checkApprovedAnteproject() async {
    try {
      final hasApproved = await _anteprojectsService.hasApprovedAnteproject();
      if (mounted) {
        setState(() {
          _hasApprovedAnteproject = hasApproved;
        });
      }
    } catch (e) {
      debugPrint('Error al verificar anteproyecto aprobado: $e');
      if (mounted) {
        setState(() {
          _hasApprovedAnteproject = false; // En caso de error, permitir intentar
        });
      }
    }
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final messages = await _messagesService.getAnteprojectMessages(widget.anteproject.id);
      
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
            backgroundColor: Colors.red,
          ),
        );
      }
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
    } catch (e) {
      debugPrint('Error al marcar mensajes como leídos: $e');
    }
  }

  Future<void> _submitMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escribe un mensaje'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar si el estudiante ya tiene un anteproyecto aprobado
    final hasApproved = _hasApprovedAnteproject ?? 
        await _anteprojectsService.hasApprovedAnteproject();
    
    if (hasApproved) {
      final l10n = AppLocalizations.of(context)!;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cannotSendMessageWithApprovedAnteproject),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      final message = await _messagesService.createMessage(
        anteprojectId: widget.anteproject.id,
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
          const SnackBar(
            content: Text('Mensaje enviado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        final l10n = AppLocalizations.of(context)!;
        // Verificar si es el error específico de anteproyecto aprobado
        if (e.toString().contains('cannot_send_message_with_approved_anteproject') ||
            e.toString().contains('cannotSendMessageWithApprovedAnteproject')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotSendMessageWithApprovedAnteproject),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar mensaje: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mensajes con el Tutor'),
            Text(
              widget.anteproject.title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
            tooltip: 'Actualizar mensajes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del anteproyecto
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.chat,
                  color: Colors.blue.shade600,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conversación con el Tutor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Aquí puedes hacer consultas sobre tu anteproyecto',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
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
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia la conversación con tu tutor',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AnteprojectMessage message) {
    final isMyMessage = message.senderId == _currentUser?.id;
    final senderName = message.sender?.fullName ?? 'Usuario desconocido';
    final senderRole = message.sender?.role ?? UserRole.student;

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMyMessage ? Colors.blue.shade100 : Colors.grey.shade200,
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
                    backgroundColor: _getRoleColor(senderRole),
                    child: Text(
                      senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    senderName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(senderRole).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getRoleName(senderRole),
                      style: TextStyle(
                        color: _getRoleColor(senderRole),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 4),

            // Timestamp
            Text(
              _formatDate(message.createdAt),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageForm() {
    final l10n = AppLocalizations.of(context)!;
    final hasApproved = _hasApprovedAnteproject ?? false;
    
    if (hasApproved) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.cannotSendMessageWithApprovedAnteproject,
                style: TextStyle(
                  color: Colors.orange[900],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
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
              enabled: !hasApproved,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje...',
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
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: (_isSubmitting || hasApproved) ? null : _submitMessage,
            backgroundColor: Colors.blue,
            mini: true,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.tutor:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
    }
  }

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

