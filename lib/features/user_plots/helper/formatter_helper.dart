class FormatterHelper {
  //FOR DAILY FORMATTER
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

  //FOR WEEKLY FORMATTER
  String formatWeeklyMoistureDataForPrompt(
      List<Map<String, dynamic>> moistureData) {
    Map<int, Map<String, List<int>>> moistureByPlotAndDate = {};

    for (var entry in moistureData) {
      int plotId = entry['plot_id'];
      DateTime? timestamp = DateTime.tryParse(entry['read_time'] ?? '');
      if (timestamp == null) continue;

      String date =
          "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
      int moisture = entry['soil_moisture'] ?? 0;

      moistureByPlotAndDate.putIfAbsent(plotId, () => {});
      moistureByPlotAndDate[plotId]!.putIfAbsent(date, () => []);
      moistureByPlotAndDate[plotId]![date]!.add(moisture);
    }

    List<String> summaries = [];

    moistureByPlotAndDate.keys.toList()
      ..sort()
      ..forEach((plotId) {
        summaries.add("Plot ID: $plotId");
        moistureByPlotAndDate[plotId]!.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key))
          ..forEach((entry) {
            final date = entry.key;
            final readings = entry.value;

            double avg = readings.reduce((a, b) => a + b) / readings.length;

            summaries.add("📅 $date | Avg Moisture: ${avg.toStringAsFixed(1)}");
          });
      });

    return summaries.join("\n");
  }

  String formatWeeklyNutrientDataForPrompt(
      List<Map<String, dynamic>> nutrientData) {
    Map<int, Map<String, List<Map<String, dynamic>>>> dataByPlotAndDate = {};

    for (var entry in nutrientData) {
      int plotId = entry['plot_id'];
      DateTime? timestamp = DateTime.tryParse(entry['read_time'] ?? '');
      if (timestamp == null) continue;

      String date =
          "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";

      dataByPlotAndDate.putIfAbsent(plotId, () => {});
      dataByPlotAndDate[plotId]!.putIfAbsent(date, () => []);

      dataByPlotAndDate[plotId]![date]!.add({
        'nitrogen': entry['readed_nitrogen'] ?? 0,
        'phosphorus': entry['readed_phosphorus'] ?? 0,
        'potassium': entry['readed_potassium'] ?? 0,
      });
    }

    List<String> summaries = [];

    dataByPlotAndDate.keys.toList()
      ..sort()
      ..forEach((plotId) {
        summaries.add("Plot ID: $plotId");
        dataByPlotAndDate[plotId]!.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key))
          ..forEach((entry) {
            final date = entry.key;
            final readings = entry.value;

            final nList = readings.map((e) => e['nitrogen'] as int).toList();
            final pList = readings.map((e) => e['phosphorus'] as int).toList();
            final kList = readings.map((e) => e['potassium'] as int).toList();

            String summary =
                "📅 $date | N: ${(nList.reduce((a, b) => a + b) / nList.length).toStringAsFixed(1)}, "
                "P: ${(pList.reduce((a, b) => a + b) / pList.length).toStringAsFixed(1)}, "
                "K: ${(kList.reduce((a, b) => a + b) / kList.length).toStringAsFixed(1)}";

            summaries.add(summary);
          });
      });

    return summaries.join("\n");
  }

  String formatMoistureDataWithoutPlotFilter(
      List<Map<String, dynamic>> moistureData) {
    Map<String, List<int>> moistureByDate = {};

    for (var entry in moistureData) {
      DateTime? timestamp = DateTime.tryParse(entry['read_time'] ?? '');
      if (timestamp == null) continue;

      String date =
          "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
      int moisture = entry['soil_moisture'] ?? 0;

      moistureByDate.putIfAbsent(date, () => []);
      moistureByDate[date]!.add(moisture);
    }

    List<String> summaries = [];

    moistureByDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))
      ..forEach((entry) {
        final date = entry.key;
        final readings = entry.value;

        double avg = readings.reduce((a, b) => a + b) / readings.length;

        summaries.add("📅 $date | Avg Moisture: ${avg.toStringAsFixed(1)}");
      });

    return summaries.join("\n");
  }

  String formatNutrientDataWithoutPlotFilter(
      List<Map<String, dynamic>> nutrientData) {
    Map<String, List<Map<String, dynamic>>> dataByDate = {};

    for (var entry in nutrientData) {
      DateTime? timestamp = DateTime.tryParse(entry['read_time'] ?? '');
      if (timestamp == null) continue;

      String date =
          "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";

      dataByDate.putIfAbsent(date, () => []);

      dataByDate[date]!.add({
        'nitrogen': entry['readed_nitrogen'] ?? 0,
        'phosphorus': entry['readed_phosphorus'] ?? 0,
        'potassium': entry['readed_potassium'] ?? 0,
      });
    }

    List<String> summaries = [];

    dataByDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))
      ..forEach((entry) {
        final date = entry.key;
        final readings = entry.value;

        final nList = readings.map((e) => e['nitrogen'] as int).toList();
        final pList = readings.map((e) => e['phosphorus'] as int).toList();
        final kList = readings.map((e) => e['potassium'] as int).toList();

        String summary =
            "📅 $date | N: ${(nList.reduce((a, b) => a + b) / nList.length).toStringAsFixed(1)}, "
            "P: ${(pList.reduce((a, b) => a + b) / pList.length).toStringAsFixed(1)}, "
            "K: ${(kList.reduce((a, b) => a + b) / kList.length).toStringAsFixed(1)}";

        summaries.add(summary);
      });

    return summaries.join("\n");
  }

  String formatMoistureDataForSummary(
    List<Map<String, dynamic>> data,
  ) {
    final buffer = StringBuffer();
    final groupedByPlot = <int, List<Map<String, dynamic>>>{};

    for (var entry in data) {
      final plotId = entry['plot_id'];
      groupedByPlot.putIfAbsent(plotId, () => []).add(entry);
    }

    groupedByPlot.forEach((plotId, entries) {
      for (var entry in entries) {
        buffer.writeln(
            "  📅 ${entry['date']} | Avg Moisture: ${entry['avg_moisture']}");
      }
    });

    return buffer.toString();
  }
}
