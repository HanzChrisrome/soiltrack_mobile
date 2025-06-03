class NotificationModel {
  final int id;
  final String message;
  final String type;
  final DateTime time;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.time,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['notification_id'] as int,
      message: map['message'] as String,
      type: map['notification_type'] as String,
      time: DateTime.parse(map['notification_time']),
    );
  }
}
