import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/notifications_service.dart';
import '../../models/notification.dart' as notif;
import '../../widgets/navigation/persistent_scaffold.dart';
import '../../utils/app_exception.dart';
import '../../utils/error_translator.dart';
import '../../widgets/notifications/notification_item_widget.dart';
import '../../l10n/app_localizations.dart';

/// Pantalla de notificaciones con restricciones de privacidad para administradores
class NotificationsScreen extends StatefulWidget {
  final User user;

  const NotificationsScreen({super.key, required this.user});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final NotificationsService? _service;
  late TabController _tabController;
  bool _loading = true;
  String? _errorMessage;

  List<notif.Notification> _allNotifications = [];
  List<notif.Notification> _systemNotifications = [];
  String? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    _service = NotificationsService.maybeCreate();
    final isAdmin = widget.user.role == UserRole.admin;
    _tabController = TabController(length: isAdmin ? 2 : 1, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (_service == null) {
      setState(() {
        _errorMessage = 'Servicio de notificaciones no disponible';
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final all = await _service.getAllNotifications();

      if (widget.user.role == UserRole.admin) {
        // Para admin: separar notificaciones personales y del sistema
        final personal = all.where((n) => n.userId == widget.user.id).toList();
        final system = await _service.getSystemNotifications();

        if (mounted) {
          setState(() {
            _allNotifications = personal;
            _systemNotifications = system;
            _loading = false;
          });
        }
      } else {
        // Para otros roles: todas sus notificaciones
        if (mounted) {
          setState(() {
            _allNotifications = all;
            _systemNotifications = [];
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e is AppException
            ? ErrorTranslator.getFallbackMessage(e)
            : 'Error cargando notificaciones: $e';
        setState(() {
          _errorMessage = message;
          _loading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(notif.Notification notification) async {
    final service = _service;
    if (service == null) return;
    try {
      await service.markAsRead(notification.id);
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMarkingAsRead(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final service = _service;
    if (service == null) return;
    try {
      await service.markAllAsRead();
      await _loadNotifications();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.allNotificationsMarkedAsRead),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeleting(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(notif.Notification notification) async {
    final service = _service;
    if (service == null) return;
    try {
      await service.deleteNotification(notification.id);
      await _loadNotifications();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error eliminando: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<notif.Notification> _getFilteredNotifications() {
    final isAdmin = widget.user.role == UserRole.admin;
    final currentTab = _tabController.index;

    List<notif.Notification> notifications;
    if (isAdmin && currentTab == 1) {
      // Tab "Sistema" para admin
      notifications = _systemNotifications;
    } else {
      // Tab "Mis Notificaciones"
      notifications = _allNotifications;
    }

    // Aplicar filtro por tipo si está seleccionado
    if (_selectedTypeFilter != null && _selectedTypeFilter!.isNotEmpty) {
      notifications = notifications
          .where((n) => n.type == _selectedTypeFilter)
          .toList();
    }

    return notifications;
  }

  List<String> _getAvailableTypes() {
    final notifications =
        widget.user.role == UserRole.admin && _tabController.index == 1
        ? _systemNotifications
        : _allNotifications;

    return notifications.map((n) => n.type).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PersistentScaffold(
      title: l10n.notifications,
      titleKey: 'notifications',
      user: widget.user,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
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
                    onPressed: _loadNotifications,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Tabs (solo para admin)
                if (widget.user.role == UserRole.admin)
                  TabBar(
                    controller: _tabController,
                    onTap: (_) => setState(() {}),
                    tabs: [
                      Tab(icon: const Icon(Icons.person), text: l10n.myNotifications),
                      Tab(icon: const Icon(Icons.settings), text: l10n.system),
                    ],
                  ),

                // Filtros
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedTypeFilter,
                          hint: Text(l10n.filterByType),
                          isExpanded: true,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(l10n.allTypes),
                            ),
                            ..._getAvailableTypes().map(
                              (type) {
                                // Obtener el nombre de visualización del tipo
                                final notifications = widget.user.role == UserRole.admin && _tabController.index == 1
                                    ? _systemNotifications
                                    : _allNotifications;
                                final notification = notifications.firstWhere(
                                  (n) => n.type == type,
                                  orElse: () => notif.Notification(
                                    id: 0,
                                    type: type,
                                    title: '',
                                    message: '',
                                    userId: widget.user.id,
                                    readAt: null,
                                    createdAt: DateTime.now(),
                                  ),
                                );
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(notification.getTypeDisplayName(l10n)),
                                );
                              },
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedTypeFilter = value;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: l10n.refresh,
                        onPressed: _loadNotifications,
                      ),
                      if (_getFilteredNotifications().any((n) => !n.isRead))
                        IconButton(
                          icon: const Icon(Icons.done_all),
                          tooltip: l10n.markAllAsRead,
                          onPressed: _markAllAsRead,
                        ),
                    ],
                  ),
                ),

                // Lista de notificaciones
                Expanded(child: _buildNotificationsList()),

                // Información de privacidad para admin
                if (widget.user.role == UserRole.admin)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue.shade50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.privateCommunicationsPrivacy,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildNotificationsList() {
    final l10n = AppLocalizations.of(context)!;
    final notifications = _getFilteredNotifications();

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTypeFilter != null
                  ? l10n.noNotificationsOfThisType
                  : l10n.noNotifications,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationItemWidget(
          notification: notification,
          onTap: () => _markAsRead(notification),
          onDelete: () => _deleteNotification(notification),
        );
      },
    );
  }
}
