import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/model/notification_model.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;

  NotificationState({
    required this.notifications,
    required this.isLoading,
  });

  factory NotificationState.initial() => NotificationState(
        notifications: [],
        isLoading: true,
      );

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this._userId) : super(NotificationState.initial()) {
    _init();
  }

  final String _userId;
  RealtimeChannel? _channel;

  Future<void> _init() async {
    await _fetchInitialNotifications();
    _subscribeToNotificationInserts();
  }

  Future<void> _fetchInitialNotifications() async {
    final response = await supabase
        .from('notifications')
        .select('*')
        .eq('user_id', _userId)
        .order('notification_time', ascending: false);

    final List data = response as List;

    final notifications = data
        .map((item) => NotificationModel.fromMap(item as Map<String, dynamic>))
        .toList();

    state = state.copyWith(notifications: notifications, isLoading: false);
  }

  void _subscribeToNotificationInserts() {
    _channel = supabase.channel('public:notifications_user')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: _userId,
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

  @override
  void dispose() {
    if (_channel != null) {
      supabase.removeChannel(_channel!);
    }
    super.dispose();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.userId ?? '';

  return NotificationNotifier(userId);
});
