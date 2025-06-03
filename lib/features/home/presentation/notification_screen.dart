import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/notifications/notification_empty.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/notifications/notification_item.dart';
import 'package:soiltrack_mobile/features/home/provider/notifications/notifications_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_navigation_bar.dart';
import 'package:soiltrack_mobile/widgets/collapsible_appbar.dart';
import 'package:soiltrack_mobile/widgets/collapsible_scaffold.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;
    final isLoading = notificationState.isLoading;

    Widget? overlay;
    if (isLoading) {
      overlay = Center(
        child: LoadingAnimationWidget.progressiveDots(
            color: Theme.of(context).colorScheme.onPrimary, size: 70),
      );
    } else if (notifications.isEmpty) {
      overlay = const NotificationEmpty();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          CollapsibleSliverScaffold(
            headerBuilder: (context, isCollapsed) {
              return CollapsibleSliverAppBar(
                isCollapsed: isCollapsed,
                collapsedTitle: 'Notifications',
                title: 'Notifications',
                backgroundColor: Theme.of(context).colorScheme.surface,
                showCollapsedBack: false,
              );
            },
            bodySlivers: [
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    for (var notification in notifications)
                      NotificationItem(
                          title: notification.message,
                          notificationType: notification.type,
                          time: notification.time)
                  ]),
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
}
