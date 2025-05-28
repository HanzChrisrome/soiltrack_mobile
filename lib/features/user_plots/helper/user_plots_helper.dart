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
    final threeDaysAgo = now.subtract(const Duration(days: 3));

    final moistureForDailyAnalysis = _filterDataByDate(
      rawMoistureData,
      selectedPlotId,
      DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );

    final nutrientsForDailyAnalysis = _filterDataByDate(
      rawNutrientData,
      selectedPlotId,
      DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );

    if (moistureForDailyAnalysis.isEmpty || nutrientsForDailyAnalysis.isEmpty) {
      return null;
    }

    bool hasDataForEachDay(List<Map<String, dynamic>> data) {
      for (int i = 1; i <= 3; i++) {
        final dateToCheck = now.subtract(Duration(days: i));
        final hasDataForDay = data.any((entry) {
          final readTime = DateTime.tryParse(entry['read_time'] ?? '');
          return readTime != null && isSameDay(readTime, dateToCheck);
        });
        if (!hasDataForDay) return false;
      }
      return true;
    }

    if (!hasDataForEachDay(moistureForDailyAnalysis) ||
        !hasDataForEachDay(nutrientsForDailyAnalysis)) {
      return null;
    }

    return {
      'moistureForDaily': moistureForDailyAnalysis,
      'nutrientsForDaily': nutrientsForDailyAnalysis,
    };
  }

  Map<String, List<Map<String, dynamic>>>? getFilteredAiReadyWeeklyData({
    required int selectedPlotId,
    required List<Map<String, dynamic>> rawMoistureData,
    required List<Map<String, dynamic>> rawNutrientData,
  }) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final sevenDaysAgo = yesterday.subtract(const Duration(days: 6));

    final startOfWeek =
        DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);
    final endOfWeek =
        DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);

    final moistureForWeeklyAnalysis = _filterDataByDate(
      rawMoistureData,
      selectedPlotId,
      startOfWeek,
      endOfWeek,
    );

    final nutrientsForWeeklyAnalysis = _filterDataByDate(
      rawNutrientData,
      selectedPlotId,
      startOfWeek,
      endOfWeek,
    );

    if (moistureForWeeklyAnalysis.isEmpty ||
        nutrientsForWeeklyAnalysis.isEmpty) {
      return null;
    }

    bool hasDataForEachDay(List<Map<String, dynamic>> data) {
      for (int i = 1; i <= 7; i++) {
        final dateToCheck = now.subtract(Duration(days: i)); // skips today
        final hasDataForDay = data.any((entry) {
          final readTime = DateTime.tryParse(entry['read_time'] ?? '');
          return readTime != null && isSameDay(readTime, dateToCheck);
        });
        if (!hasDataForDay) return false;
      }
      return true;
    }

    if (!hasDataForEachDay(moistureForWeeklyAnalysis) ||
        !hasDataForEachDay(nutrientsForWeeklyAnalysis)) {
      return null;
    }

    return {
      'moistureForWeekly': moistureForWeeklyAnalysis,
      'nutrientsForWeekly': nutrientsForWeeklyAnalysis,
    };
  }

  Map<String, List<Map<String, dynamic>>>? getDataForSummary(
      {required List<Map<String, dynamic>> rawMoistureData,
      required List<Map<String, dynamic>> rawNutrientData}) {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    final moistureForSummary = _filterDataOnly(
      rawMoistureData,
      DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );

    final nutrientsForSummary = _filterDataOnly(
      rawNutrientData,
      DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );

    final hasIncompleteData = (DateTime date) {
      final moistureDataForDate = moistureForSummary.where((entry) {
        final readTimeString = entry['read_time'];
        if (readTimeString == null) return false;
        final readTime = DateTime.tryParse(readTimeString);
        return readTime != null && isSameDay(readTime, date);
      }).toList();

      final nutrientDataForDate = nutrientsForSummary.where((entry) {
        final readTime = DateTime.tryParse(entry['read_time'] ?? '');
        return readTime != null && isSameDay(readTime, date);
      }).toList();

      return moistureDataForDate.isEmpty || nutrientDataForDate.isEmpty;
    };

    if (hasIncompleteData(yesterday) || hasIncompleteData(twoDaysAgo)) {
      return null;
    }

    return {
      'moistureForSummary': moistureForSummary,
      'nutrientsForSummary': nutrientsForSummary,
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

  List<Map<String, dynamic>> _filterDataOnly(
    List<Map<String, dynamic>> data,
    DateTime start,
    DateTime end,
  ) {
    return data.where((entry) {
      final readTime = DateTime.tryParse(entry['read_time'] ?? '');
      return readTime != null &&
          !readTime.isBefore(start) &&
          !readTime.isAfter(end);
    }).toList();
  }

  String getFormattedAiPrompt({
    required Map<String, List<Map<String, dynamic>>> data,
  }) {
    final dayStart = DateTime.now().subtract(const Duration(days: 3));
    final dayEnd = DateTime.now().subtract(const Duration(days: 1));

    String rangeLabel =
        "${dayStart.year}-${dayStart.month.toString().padLeft(2, '0')}-${dayStart.day.toString().padLeft(2, '0')} to "
        "${dayEnd.year}-${dayEnd.month.toString().padLeft(2, '0')}-${dayEnd.day.toString().padLeft(2, '0')}";

    final buffer = StringBuffer();
    buffer.writeln("📅 Daily Moisture & Nutrient Report ($rangeLabel):\n");
    buffer.writeln("💧 Moisture Data:");
    buffer.writeln(
      formatter
          .formatWeeklyMoistureDataForPrompt(data['moistureForDaily'] ?? []),
    );

    // Add nutrient data
    buffer.writeln("\n🌱 Nutrient Data (NPK):");
    buffer.writeln(
      formatter
          .formatWeeklyNutrientDataForPrompt(data['nutrientsForDaily'] ?? []),
    );

    return buffer.toString();
  }

  String getFormattedAiWeeklyPrompt({
    required Map<String, List<Map<String, dynamic>>> data,
  }) {
    final today = DateTime.now();
    final weekEnd = today.subtract(const Duration(days: 1)); // yesterday
    final weekStart = weekEnd.subtract(const Duration(days: 6)); // 7-day window

    String rangeLabel =
        "${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')} to "
        "${weekEnd.year}-${weekEnd.month.toString().padLeft(2, '0')}-${weekEnd.day.toString().padLeft(2, '0')}";

    final buffer = StringBuffer();
    buffer.writeln("📅 Weekly Moisture & Nutrient Report ($rangeLabel):\n");
    buffer.writeln("💧 Moisture Data:");
    buffer.writeln(
      formatter.formatWeeklyMoistureDataForPrompt(
        data['moistureForWeekly'] ?? [],
      ),
    );

    buffer.writeln("\n🌱 Nutrient Data (NPK):");
    buffer.writeln(
      formatter.formatWeeklyNutrientDataForPrompt(
        data['nutrientsForWeekly'] ?? [],
      ),
    );

    return buffer.toString();
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

  String getFormattedSummaryPrompt({
    required Map<String, List<Map<String, dynamic>>> data,
    required Map<int, Map<String, dynamic>> plotMetadata,
  }) {
    final weekStart = DateTime.now().subtract(const Duration(days: 3));
    final weekEnd = DateTime.now().subtract(const Duration(days: 1));

    String rangeLabel =
        "${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')} to "
        "${weekEnd.year}-${weekEnd.month.toString().padLeft(2, '0')}-${weekEnd.day.toString().padLeft(2, '0')}";

    final buffer = StringBuffer();
    buffer.writeln("📅 Daily Moisture & Nutrient Report ($rangeLabel):\n");

    buffer.writeln("📋 Plot Details:");
    plotMetadata.forEach((plotId, meta) {
      final name = meta['plotName'] ?? 'Plot $plotId';
      final crop = meta['crop'] ?? 'Not Planted';
      final soil = meta['soil'] ?? 'Unknown';

      buffer.writeln("$name (ID: $plotId)");
      buffer.writeln("Crop: $crop");
      buffer.writeln("Soil Type: $soil\n");
    });

    // Add moisture data
    buffer.writeln("💧 Moisture Data:");
    buffer.writeln(
      formatter
          .formatWeeklyMoistureDataForPrompt(data['moistureForSummary'] ?? []),
    );

    // Add nutrient data
    buffer.writeln("\n🌱 Nutrient Data (NPK):");
    buffer.writeln(
      formatter
          .formatWeeklyNutrientDataForPrompt(data['nutrientsForSummary'] ?? []),
    );

    return buffer.toString();
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
