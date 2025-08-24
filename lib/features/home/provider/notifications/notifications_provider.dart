import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/model/notification_model.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/notifications/notification_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationNotifier extends Notifier<NotificationState> {
  RealtimeChannel? _channel;
  final int _pageSize = 5;
  int _offset = 0;
  bool _isFetchingMore = false;

  NotificationState build() {
    final authState = ref.watch(authProvider);
    final userId = authState.userId ?? '';

    ref.onDispose(() {
      if (_channel != null) {
        supabase.removeChannel(_channel!);
      }
    });

    _init(userId);

    return NotificationState();
  }

  Future<void> _init(String userId) async {
    await _fetchInitialNotifications(userId);
    _subscribeToNotificationInserts(userId);
  }

  Future<void> _fetchInitialNotifications(String userId) async {
    final response = await supabase
        .from('notifications')
        .select('*')
        .eq('user_id', userId)
        .order('notification_time', ascending: false)
        .limit(_pageSize);

    final List data = response as List;

    final notifications = data
        .map((item) => NotificationModel.fromMap(item as Map<String, dynamic>))
        .toList();

    _offset = notifications.length;

    state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        hasMore: notifications.length == _pageSize);
  }

  Future<void> loadMore(String userId) async {
    if (_isFetchingMore || !state.hasMore) return;

    _isFetchingMore = true;

    final response = await supabase
        .from('notifications')
        .select('*')
        .eq('user_id', userId)
        .order('notification_time', ascending: false)
        .range(_offset, _offset + _pageSize - 1);

    if (response.isEmpty) {
      print("Error fetching more notifications: ${response}");
    }

    final List data = response as List;

    final newNotifications = data
        .map((item) => NotificationModel.fromMap(item as Map<String, dynamic>))
        .toList();

    _offset += newNotifications.length;

    state = state.copyWith(
      notifications: [...state.notifications, ...newNotifications],
      hasMore: newNotifications.length == _pageSize,
    );

    _isFetchingMore = false;
  }

  void _subscribeToNotificationInserts(String userId) {
    _channel = supabase.channel('public:notifications_user')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) {
          final newRecord = payload.newRecord;
          if (newRecord.isNotEmpty) {
            final notification = NotificationModel.fromMap(newRecord);
            state = state.copyWith(
              notifications: [notification, ...state.notifications],
            );
          }
        },
      ).subscribe();
  }

  void setFilter(String? type) {
    state = state.copyWith(filterType: type);
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
        () => NotificationNotifier());
