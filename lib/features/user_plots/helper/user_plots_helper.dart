import 'package:intl/intl.dart';

class UserPlotsHelper {
  List<Map<String, dynamic>> filterData(
    List<Map<String, dynamic>> data,
    int plotId,
    String key,
  ) {
    return data
        .where((item) => item['plot_id'] as int == plotId)
        .map((item) => {
              'plot_id': item['plot_id'],
              'read_time': item['read_time'],
              'value': item[key]
            })
        .toList();
  }

  int extractLatestValue(List<Map<String, dynamic>> data) {
    return data.isNotEmpty ? (data.last['value'] as num).toInt() : 0;
  }

  String getLatestTimestamp(
    List<Map<String, dynamic>> nitrogenData,
    List<Map<String, dynamic>> phosphorusData,
    List<Map<String, dynamic>> potassiumData,
    List<Map<String, dynamic>> moistureData,
  ) {
    List<dynamic> timestamps = [
      if (nitrogenData.isNotEmpty) nitrogenData.last['read_time'],
      if (phosphorusData.isNotEmpty) phosphorusData.last['read_time'],
      if (potassiumData.isNotEmpty) potassiumData.last['read_time'],
      if (moistureData.isNotEmpty) moistureData.last['read_time'],
    ];

    if (timestamps.isEmpty) return "No data available";

    DateTime? latestTimestamp;
    for (var timestamp in timestamps) {
      DateTime? parsedDate = _parseTimestamp(timestamp);
      if (parsedDate != null &&
          (latestTimestamp == null || parsedDate.isAfter(latestTimestamp))) {
        latestTimestamp = parsedDate;
      }
    }

    if (latestTimestamp == null) return "Invalid date";

    return DateFormat('MMM dd, yyyy hh:mm a').format(latestTimestamp);
  }

  DateTime? _parseTimestamp(dynamic timestamp) {
    try {
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  //FOR USER PLOTS SCREEN
  String getSensorName(List<dynamic> sensors, String category) {
    final sensor = sensors.firstWhere(
        (s) => s['soil_sensors']['sensor_category'] == category,
        orElse: () => {});

    return sensor?['soil_sensors']?['sensor_name'] ?? 'No sensor';
  }

  String formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Invalid date';
    try {
      DateTime dateTime = DateTime.parse(timestamp).toLocal();
      return DateFormat('hh:mm a').format(dateTime);
    } catch (_) {
      return 'Invalid date';
    }
  }
}
