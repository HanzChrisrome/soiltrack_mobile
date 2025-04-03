import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';

class SoilDashboardHelper {
  List<Map<String, dynamic>> aggregatedDataByInterval(
      List<Map<String, dynamic>> data, String interval, String key1,
      [String? key2, String? key3]) {
    Map<int, Map<String, Map<String, List<int>>>> aggregatedValues = {};

    for (var reading in data) {
      int plotId = reading['plot_id'];
      String dateKey = getDateKeyByInterval(
          DateTime.parse(reading['read_time']).toUtc(), interval);

      aggregatedValues.putIfAbsent(plotId, () => {});
      aggregatedValues[plotId]!.putIfAbsent(dateKey, () => {});

      aggregatedValues[plotId]![dateKey]!.putIfAbsent(key1, () => []);
      aggregatedValues[plotId]![dateKey]![key1]!
          .add(int.tryParse(reading[key1].toString()) ?? 0);

      if (key2 != null) {
        aggregatedValues[plotId]![dateKey]!.putIfAbsent(key2, () => []);
        aggregatedValues[plotId]![dateKey]![key2]!
            .add(int.tryParse(reading[key2].toString()) ?? 0);
      }

      if (key3 != null) {
        aggregatedValues[plotId]![dateKey]!.putIfAbsent(key3, () => []);
        aggregatedValues[plotId]![dateKey]![key3]!
            .add(int.tryParse(reading[key3].toString()) ?? 0);
      }
    }

    List<Map<String, dynamic>> aggregatedData = [];

    aggregatedValues.forEach((plotId, dateMap) {
      dateMap.forEach((dateKey, valuesMap) {
        Map<String, dynamic> aggregatedEntry = {
          'plot_id': plotId,
          'read_time': dateKey,
        };

        valuesMap.forEach((key, values) {
          aggregatedEntry[key] =
              (values.reduce((a, b) => a + b) / values.length).round();
        });

        aggregatedData.add(aggregatedEntry);
      });
    });

    return aggregatedData;
  }

  String getDateKeyByInterval(DateTime readTime, String interval) {
    if (interval == "1D") {
      return "${readTime.year}-${readTime.month.toString().padLeft(2, '0')}-${readTime.day.toString().padLeft(2, '0')} ${readTime.hour.toString().padLeft(2, '0')}:00";
    }
    if (interval == "1M") {
      return "${readTime.year}-${readTime.month.toString().padLeft(2, '0')}-${readTime.day.toString().padLeft(2, '0')}";
    }
    if (interval == "1W") {
      return getLatestDateInWeek(readTime);
    }
    return "${readTime.year}-${readTime.month.toString().padLeft(2, '0')}-01";
  }

  String determineAggregationInterval(
      String filterType, DateTime startDate, DateTime endDate) {
    int daysRange = endDate.difference(startDate).inDays;

    if (daysRange == 0) return "1D";
    if (daysRange == 1) return "1W";
    if (daysRange <= 7) return "1W";
    if (daysRange <= 30) return "1M";
    return "3M";
  }

  String getLatestDateInWeek(DateTime readTime) {
    DateTime latestDate = readTime;
    return "${latestDate.year}-${latestDate.month.toString().padLeft(2, '0')}-${latestDate.day.toString().padLeft(2, '0')}";
  }

  DateTime getStartDateFromTimeRange(String timeRange) {
    final DateTime now = DateTime.now();
    DateTime startDate;

    switch (timeRange) {
      case '1D':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case '1W':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '1M':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3M':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 1));
    }

    return startDate;
  }

  List<Map<String, dynamic>> extractMessagesByType(
      List<Map<String, dynamic>> messages, String type) {
    return messages
        .map((plot) {
          final filteredMessages = (plot['messages'] as List)
              .where((message) => message['type'] == type)
              .map((msg) => msg['message'])
              .toList();

          if (filteredMessages.isEmpty) return null;

          return {
            'plot_id': plot['plot_id'],
            'plot_name': plot['plot_name'],
            if (type == 'Suggestion')
              'suggestions': filteredMessages
            else if (type == 'Device Warning')
              'device_warnings': filteredMessages
            else
              'warnings': filteredMessages,
          };
        })
        .where((plot) => plot != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  String generateOverallCondition(
      List<Map<String, dynamic>> warningsList, int totalPlots) {
    if (warningsList.isEmpty) {
      return "Optimal Condtion";
    }

    int warningsCount = warningsList.fold(0, (sum, plot) {
      List messages = plot['warnings'] ?? [];
      return sum + messages.length;
    });

    NotifierHelper.logMessage('Warnings count: $warningsCount');

    double averageWarnings = warningsCount / totalPlots;

    if (averageWarnings < 1) {
      return "in optimal condition";
    } else if (averageWarnings < 3) {
      return "showing signs that need attention";
    } else {
      return "in critical conditions";
    }
  }

  String generatePlotCondition(
      int plotId, List<Map<String, dynamic>> warningsList) {
    final specificPlot = warningsList.firstWhere(
      (plot) => plot['plot_id'] == plotId,
      orElse: () => {},
    );

    List warnings =
        specificPlot.isNotEmpty ? (specificPlot['warnings'] ?? []) : [];

    int warningsCount = warnings.length;

    if (warningsCount < 1) {
      return "in optimal condition";
    } else if (warningsCount < 3) {
      return "showing signs that need attention";
    } else {
      return "in critical conditions";
    }
  }

  DateTime? getLatestTimestamp(List<dynamic> data) {
    if (data.isEmpty) return null;

    List<DateTime> timestamps = data
        .map<DateTime?>((entry) {
          final timestamp = entry['read_time'];
          return timestamp != null
              ? DateTime.tryParse(timestamp.toString())
              : null;
        })
        .whereType<DateTime>()
        .toList();

    return timestamps.isNotEmpty
        ? timestamps.reduce((a, b) => a.isAfter(b) ? a : b)
        : null;
  }

  DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  String formatMoistureDataForPrompt(List<Map<String, dynamic>> moistureData) {
    Map<int, List<int>> formattedData = {};

    for (var entry in moistureData) {
      int plotId = entry['plot_id'];
      int moisture = entry['soil_moisture'] ?? 0;

      if (!formattedData.containsKey(plotId)) {
        formattedData[plotId] = [];
      }

      formattedData[plotId]!.add(moisture);
    }

    List<String> summaries = [];

    formattedData.forEach((plotId, readings) {
      int minMoisture = readings.reduce((a, b) => a < b ? a : b);
      int maxMoisture = readings.reduce((a, b) => a > b ? a : b);
      double avgMoisture =
          readings.reduce((a, b) => a + b) / readings.length.toDouble();

      String summary =
          "Plot ID: $plotId | Moisture (Min: $minMoisture, Max: $maxMoisture, Avg: ${avgMoisture.toStringAsFixed(1)})";

      summaries.add(summary);
    });

    return summaries.join("\n");
  }

  String formatNutrientDataForPrompt(List<Map<String, dynamic>> nutrientData) {
    Map<int, List<Map<String, dynamic>>> formattedData = {};

    for (var entry in nutrientData) {
      int plotId = entry['plot_id'];
      Map<String, dynamic> nutrientReading = {
        'timestamp': entry['read_time'],
        'nitrogen': entry['readed_nitrogen'] ?? 0,
        'phosphorus': entry['readed_phosphorus'] ?? 0,
        'potassium': entry['readed_potassium'] ?? 0,
      };

      if (!formattedData.containsKey(plotId)) {
        formattedData[plotId] = [];
      }

      formattedData[plotId]!.add(nutrientReading);
    }

    List<String> summaries = [];

    formattedData.forEach((plotId, readings) {
      List<int> nitrogen = readings.map((e) => e['nitrogen'] as int).toList();
      List<int> phosphorus =
          readings.map((e) => e['phosphorus'] as int).toList();
      List<int> potassium = readings.map((e) => e['potassium'] as int).toList();

      String summary =
          "Plot ID: $plotId | N (Min: ${nitrogen.reduce((a, b) => a < b ? a : b)}, Max: ${nitrogen.reduce((a, b) => a > b ? a : b)}, Avg: ${(nitrogen.reduce((a, b) => a + b) / nitrogen.length).toStringAsFixed(1)}) | "
          "P (Min: ${phosphorus.reduce((a, b) => a < b ? a : b)}, Max: ${phosphorus.reduce((a, b) => a > b ? a : b)}, Avg: ${(phosphorus.reduce((a, b) => a + b) / phosphorus.length).toStringAsFixed(1)}) | "
          "K (Min: ${potassium.reduce((a, b) => a < b ? a : b)}, Max: ${potassium.reduce((a, b) => a > b ? a : b)}, Avg: ${(potassium.reduce((a, b) => a + b) / potassium.length).toStringAsFixed(1)})";

      summaries.add(summary);
    });

    return summaries.join("\n");
  }
}
