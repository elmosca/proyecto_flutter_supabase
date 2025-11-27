import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../services/notifications_service.dart';
import '../../models/user.dart';
import '../../l10n/app_localizations.dart';

class NotificationsBell extends StatefulWidget {
  final VoidCallback? onTap;
  final User? user;

  const NotificationsBell({super.key, this.onTap, this.user});

  @override
  State<NotificationsBell> createState() => _NotificationsBellState();
}

class _NotificationsBellState extends State<NotificationsBell> {
  NotificationsService? _notificationsService;
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      _notificationsService = NotificationsService.maybeCreate();
      if (_notificationsService != null) {
        await _loadUnreadCount();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Notifications disabled: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    if (_notificationsService == null) return;

    try {
      final count = await _notificationsService!.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al cargar notificaciones: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_notificationsService == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        IconButton(
          icon: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.notifications_outlined),
          onPressed: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else if (widget.user != null) {
              context.go('/notifications', extra: widget.user);
            }
          },
          tooltip: l10n.notifications,
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  /// Método público para refrescar el contador
  void refreshCount() {
    _loadUnreadCount();
  }
}
