import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soiltrack_mobile/core/model/notification_model.dart';

part 'notification_state.freezed.dart';

@freezed
class NotificationState with _$NotificationState {
  factory NotificationState({
    @Default([]) List<NotificationModel> notifications,
    @Default(true) bool isLoading,
    @Default(true) bool hasMore,
    String? filterType,
  }) = _NotificationState;
}
