import 'package:flutter/material.dart';
import '../../models/notification.dart' as notif;
import '../../l10n/app_localizations.dart';

/// Widget para mostrar un elemento individual de notificación
class NotificationItemWidget extends StatelessWidget {
  final notif.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final extension = notification.getTypeDisplayName(l10n);
    final icon = notification.icon;
    final iconColor = notification.iconColor;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: notification.isRead ? Colors.grey.shade50 : Colors.white,
      elevation: notification.isRead ? 1 : 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  extension,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(context, notification.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.grey.shade600,
                onPressed: onDelete,
                tooltip: AppLocalizations.of(context)!.delete,
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      return difference.inDays == 1
          ? l10n.agoDays(difference.inDays)
          : l10n.agoDaysPlural(difference.inDays);
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? l10n.agoHours(difference.inHours)
          : l10n.agoHoursPlural(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? l10n.agoMinutes(difference.inMinutes)
          : l10n.agoMinutesPlural(difference.inMinutes);
    } else {
      return l10n.now;
    }
  }
}
