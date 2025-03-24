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

  String getDateKeyByInterval(DateTime readTime, String interval) {
    if (interval == "hourly") {
      return "${readTime.year}-${readTime.month.toString().padLeft(2, '0')}-${readTime.day.toString().padLeft(2, '0')} ${readTime.hour.toString().padLeft(2, '0')}:00";
    }
    if (interval == "daily") {
      return "${readTime.year}-${readTime.month.toString().padLeft(2, '0')}-${readTime.day.toString().padLeft(2, '0')}";
    }
    if (interval == "weekly") {
      return getStartOfWeek(readTime);
    }
    return "${readTime.year}-${readTime.month.toString().padLeft(2, '0')}-01";
  }

  String determineAggregationInterval(
      String filterType, DateTime startDate, DateTime endDate) {
    if (filterType == "1D") {
      return "hourly";
    } else if (filterType == "1W") {
      return "daily";
    } else if (filterType == "1M") {
      return "weekly";
    } else if (filterType == "3M") {
      return "monthly";
    } else {
      int daysRange = endDate.difference(startDate).inDays;
      if (daysRange <= 7) return "daily";
      if (daysRange <= 30) return "weekly";
      return "monthly";
    }
  }

  String getStartOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - DateTime.monday;
    DateTime weekStart = date.subtract(Duration(days: daysToSubtract));
    return "${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}";
  }

  DateTime getStartDateFromTimeRange(String timeRange) {
    final DateTime now = DateTime.now();
    DateTime startDate;

    switch (timeRange) {
      case '1D':
        startDate = now.subtract(const Duration(days: 1));
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

  DateTime? getLatestTimestamp(List<dynamic> data) {
    if (data.isEmpty) return null;

    List<DateTime> timestamps = data
        .map<DateTime?>((entry) {
          final timestamp = entry['read_time'];
          return timestamp != null
              ? DateTime.tryParse(timestamp.toString())
              : null;
        })
        .whereType<DateTime>() // Remove null values
        .toList();

    return timestamps.isNotEmpty
        ? timestamps.reduce((a, b) => a.isAfter(b) ? a : b)
        : null;
  }
}
