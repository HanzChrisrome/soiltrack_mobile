import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:soiltrack_mobile/core/model/notification_model.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/notifications/notification_empty.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/notifications/notification_item.dart';
import 'package:soiltrack_mobile/features/home/provider/notifications/notifications_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_navigation_bar.dart';
import 'package:soiltrack_mobile/widgets/collapsible_appbar.dart';
import 'package:soiltrack_mobile/widgets/collapsible_scaffold.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).userId;
    final notificationState = ref.watch(notificationProvider);
    final allNotifications = notificationState.notifications;
    final filterType = notificationState.filterType;

    final filteredNotifications = filterType == null
        ? allNotifications
        : allNotifications.where((n) => n.type == filterType).toList();

    Widget? overlay;
    if (notificationState.isLoading) {
      overlay = Center(
        child: LoadingAnimationWidget.progressiveDots(
            color: Theme.of(context).colorScheme.onPrimary, size: 70),
      );
    } else if (allNotifications.isEmpty) {
      overlay = const NotificationEmpty();
    }

    final groupedNotifications = _groupNotifications(filteredNotifications);
    final List<Widget> sliverItems = [];

    sliverItems.add(
      DynamicContainer(
        margin: const EdgeInsets.only(bottom: 10),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        borderColor: Colors.transparent,
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(notificationProvider.notifier).setFilter(null);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: filterType != 'WARNING' && filterType != 'INFO'
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: filterType != 'WARNING' && filterType != 'INFO'
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(notificationProvider.notifier).setFilter('WARNING');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: filterType == 'WARNING'
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Warning',
                      style: TextStyle(
                        color: filterType == 'WARNING'
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(notificationProvider.notifier).setFilter('INFO');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: filterType == 'INFO'
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Info',
                      style: TextStyle(
                        color: filterType == 'INFO'
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (filteredNotifications.isEmpty) {
      sliverItems.add(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/elements/no-result.json',
                  width: 300,
                  height: 300,
                  repeat: true, // keep looping
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      groupedNotifications.forEach((label, group) {
        sliverItems.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 8, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
          ),
        );

        sliverItems.addAll(group.map((notification) {
          return NotificationItem(
            title: notification.message,
            notificationType: notification.type,
            time: notification.time,
          );
        }));
      });
    }

    if (notificationState.hasMore &&
        allNotifications.isNotEmpty &&
        filteredNotifications.isNotEmpty) {
      sliverItems.add(
        Column(
          children: [
            Center(
              child: TextButton(
                onPressed: () {
                  ref.read(notificationProvider.notifier).loadMore(userId!);
                },
                child: Column(
                  children: [
                    Text(
                      'Load More',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          CollapsibleSliverScaffold(
            headerBuilder: (context, isCollapsed) {
              return CollapsibleSliverAppBar(
                isCollapsed: isCollapsed,
                collapsedTitle: 'Notifications',
                title: 'Notifications',
                backgroundColor: Theme.of(context).colorScheme.primary,
                showCollapsedBack: false,
              );
            },
            bodySlivers: [
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(sliverItems),
                ),
              ),
            ],
          ),
          if (overlay != null)
            Positioned.fill(
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(1),
                child: overlay,
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: CustomNavBar(selectedIndex: 3),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<NotificationModel>> _groupNotifications(
      List<NotificationModel> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    Map<String, List<NotificationModel>> grouped = {
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    for (var notification in notifications) {
      final date = DateTime(notification.time.year, notification.time.month,
          notification.time.day);
      if (date == today) {
        grouped['Today']!.add(notification);
      } else if (date == yesterday) {
        grouped['Yesterday']!.add(notification);
      } else {
        grouped['Earlier']!.add(notification);
      }
    }

    // Remove empty groups to keep things clean
    grouped.removeWhere((_, list) => list.isEmpty);

    return grouped;
  }
}
