import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String notificationType;
  final DateTime time;

  NotificationItem({
    super.key,
    required this.title,
    required this.notificationType,
    required this.time,
  });

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'INFO':
        return Icons.info;
      case 'WARNING':
        return Icons.warning;
      case 'ERROR':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inHours < 1)
        return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
      if (difference.inHours < 24)
        return '${difference.inHours} hr${difference.inHours > 1 ? 's' : ''} ago';
    }

    return DateFormat.yMMMMd().add_jm().format(time);
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForType(notificationType);
    final formattedTime = _formatTime(context, time);

    return DynamicContainer(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.onSecondary.withOpacity(0.1),
            child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
            radius: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
