import 'package:flutter/material.dart';
import '../../services/notifications_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationsService? _notificationsService;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    _notificationsService = NotificationsService.maybeCreate();
    if (_notificationsService == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_notificationsService == null) return;
    try {
      setState(() {
        _isLoading = true;
      });
      final notifications = await _notificationsService!.getAllNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar notificaciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    if (_notificationsService == null) return;
    try {
      await _notificationsService!.markAsRead(notificationId);
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al marcar como leída: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    if (_notificationsService == null) return;
    try {
      await _notificationsService!.markAllAsRead();
      _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las notificaciones marcadas como leídas'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al marcar todas como leídas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    if (_notificationsService == null) return;
    try {
      await _notificationsService!.deleteNotification(notificationId);
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar notificación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'anteproject_comment':
        return Icons.chat;
      case 'anteproject_approved':
        return Icons.check_circle;
      case 'anteproject_rejected':
        return Icons.cancel;
      case 'task_assigned':
        return Icons.assignment;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'anteproject_comment':
        return Colors.blue;
      case 'anteproject_approved':
        return Colors.green;
      case 'anteproject_rejected':
        return Colors.red;
      case 'task_assigned':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_notifications.any((n) => n['read_at'] == null))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Marcar todas',
                style: TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No tienes notificaciones',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Te notificaremos cuando haya novedades',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['read_at'] != null;
    final type = notification['type'] as String;
    final title = notification['title'] as String;
    final message = notification['message'] as String;
    final createdAt = DateTime.parse(notification['created_at'] as String);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isRead ? Colors.white : Colors.blue.shade50,
      child: InkWell(
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id'] as int);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono de la notificación
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(type),
                  color: _getNotificationColor(type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Contenido de la notificación
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Indicador de no leída y botón de eliminar
              Column(
                children: [
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () =>
                        _deleteNotification(notification['id'] as int),
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}
