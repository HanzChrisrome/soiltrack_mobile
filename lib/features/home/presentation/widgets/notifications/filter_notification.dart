import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/notifications/notifications_provider.dart';

class FilterNotification extends ConsumerWidget {
  const FilterNotification({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notificationProvider.notifier);
    final selectedFilter = ref.watch(notificationProvider).filterType;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filter Notifications',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('All'),
            trailing: selectedFilter == null
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              notifier.setFilter(null);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Informations'),
            trailing: selectedFilter == 'informations'
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              notifier.setFilter('INFO');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Warning'),
            trailing: selectedFilter == 'system'
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              notifier.setFilter('WARNING');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Other'),
            trailing: selectedFilter == 'other'
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              notifier.setFilter('other');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
