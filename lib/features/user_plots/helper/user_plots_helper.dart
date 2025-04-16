import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/user_plots/helper/formatter_helper.dart';

class UserPlotsHelper {
  final FormatterHelper formatter = FormatterHelper();

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

  Map<String, List<Map<String, dynamic>>>? getFilteredAiReadyData(
      {required int selectedPlotId,
      required List<Map<String, dynamic>> rawMoistureData,
      required List<Map<String, dynamic>> rawNutrientData}) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final dayBefore = now.subtract(const Duration(days: 2));

    final moistureYesterday = _filterDataByDate(
      rawMoistureData,
      selectedPlotId,
      DateTime(yesterday.year, yesterday.month, yesterday.day),
      DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
    );

    final moistureDayBefore = _filterDataByDate(
      rawMoistureData,
      selectedPlotId,
      DateTime(dayBefore.year, dayBefore.month, dayBefore.day),
      DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 23, 59, 59),
    );

    final nutrientYesterday = _filterDataByDate(
      rawNutrientData,
      selectedPlotId,
      DateTime(yesterday.year, yesterday.month, yesterday.day),
      DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
    );

    final nutrientDayBefore = _filterDataByDate(
      rawNutrientData,
      selectedPlotId,
      DateTime(dayBefore.year, dayBefore.month, dayBefore.day),
      DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 23, 59, 59),
    );

    if (moistureYesterday.isEmpty ||
        moistureDayBefore.isEmpty ||
        nutrientYesterday.isEmpty ||
        nutrientDayBefore.isEmpty) {
      return null;
    }

    return {
      'moistureYesterday': moistureYesterday,
      'moistureDayBefore': moistureDayBefore,
      'nutrientYesterday': nutrientYesterday,
      'nutrientDayBefore': nutrientDayBefore,
    };
  }

  Map<String, List<Map<String, dynamic>>>? getWeeklyAiReadyData({
    required int selectedPlotId,
    required List<Map<String, dynamic>> rawMoistureData,
    required List<Map<String, dynamic>> rawNutrientData,
  }) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final weeklyMoisture = _filterDataByDate(
      rawMoistureData,
      selectedPlotId,
      DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );

    final weeklyNutrients = _filterDataByDate(
      rawNutrientData,
      selectedPlotId,
      DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );

    if (weeklyMoisture.isEmpty || weeklyNutrients.isEmpty) {
      return null;
    }

    return {
      'weeklyMoisture': weeklyMoisture,
      'weeklyNutrients': weeklyNutrients,
    };
  }

  List<Map<String, dynamic>> _filterDataByDate(
    List<Map<String, dynamic>> data,
    int plotId,
    DateTime start,
    DateTime end,
  ) {
    return data.where((entry) {
      final readTime = DateTime.tryParse(entry['read_time'] ?? '');
      return entry['plot_id'] == plotId &&
          readTime != null &&
          !readTime.isBefore(start) &&
          !readTime.isAfter(end);
    }).toList();
  }

  String getFormattedAiPrompt({
    required Map<String, List<Map<String, dynamic>>> data,
  }) {
    String getDateLabel(List<Map<String, dynamic>> readings) {
      if (readings.isNotEmpty) {
        final date = DateTime.tryParse(readings.first['read_time'] ?? '');
        if (date != null) {
          return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        }
      }
      return "No data";
    }

    final moistureYDate = getDateLabel(data['moistureYesterday'] ?? []);
    final moistureDBYDate = getDateLabel(data['moistureDayBefore'] ?? []);
    final nutrientYDate = getDateLabel(data['nutrientYesterday'] ?? []);
    final nutrientDBYDate = getDateLabel(data['nutrientDayBefore'] ?? []);

    return '''🗓️ Moisture ($moistureYDate):
    ${formatter.formatMoistureDataForPrompt(data['moistureYesterday'] ?? [])}
    🗓️ Moisture ($moistureDBYDate):
    ${formatter.formatMoistureDataForPrompt(data['moistureDayBefore'] ?? [])}
    🗓️ Nutrients (NPK) ($nutrientYDate):
    ${formatter.formatNutrientDataForPrompt(data['nutrientYesterday'] ?? [])}
    🗓️ Nutrients (NPK) ($nutrientDBYDate):
    ${formatter.formatNutrientDataForPrompt(data['nutrientDayBefore'] ?? [])}''';
  }

  String getFormattedWeeklyPrompt({
    required Map<String, List<Map<String, dynamic>>> data,
  }) {
    final weekStart = DateTime.now().subtract(const Duration(days: 7));
    final weekEnd = DateTime.now().subtract(const Duration(days: 1));

    String rangeLabel =
        "${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')} to "
        "${weekEnd.year}-${weekEnd.month.toString().padLeft(2, '0')}-${weekEnd.day.toString().padLeft(2, '0')}";

    return '''📅 Weekly Moisture & Nutrient Report ($rangeLabel):
      Moisture Data:
      ${formatter.formatWeeklyMoistureDataForPrompt(data['weeklyMoisture'] ?? [])}

      Nutrient Data (NPK):
      ${formatter.formatWeeklyNutrientDataForPrompt(data['weeklyNutrients'] ?? [])}
    ''';
  }

  List<Map<String, dynamic>> getIrrigationLogs(
    Map<String, dynamic> selectedPlot,
    int selectedPlotId,
    UserPlotsHelper plotHelper,
  ) {
    return (selectedPlot['irrigation_log'] as List<dynamic>? ?? [])
        .where((log) => log['plot_id'] == selectedPlotId)
        .map((log) => {
              'mac_address': log['mac_address'],
              'time_started': plotHelper.formatTimestamp(log['time_started']),
              'time_stopped': log['time_stopped'] != null
                  ? plotHelper.formatTimestamp(log['time_stopped'])
                  : 'Ongoing',
            })
        .toList();
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  Map<String, List<Map<String, dynamic>>> groupAnalysesByDate(
      List<Map<String, dynamic>> analyses) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = startOfWeek.subtract(const Duration(days: 7));
    final lastWeekEnd = startOfWeek.subtract(const Duration(seconds: 1));

    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final analysis in analyses) {
      final date = DateTime.parse(analysis['analysis_date']).toLocal();
      String label;

      if (isSameDay(date, now)) {
        label = 'Today';
      } else if (date.isAfter(startOfWeek)) {
        label = 'This Week';
      } else if (date.isAfter(lastWeekStart) && date.isBefore(lastWeekEnd)) {
        label = 'Last Week';
      } else {
        label = '${_monthName(date.month)} ${date.year}';
      }

      grouped.putIfAbsent(label, () => []).add(analysis);
    }

    return grouped;
  }
}
