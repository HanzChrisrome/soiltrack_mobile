import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_state.dart';
import 'package:soiltrack_mobile/features/user_plots/helper/user_plots_helper.dart';
import 'package:soiltrack_mobile/provider/shared_preferences.dart';

class UserPlotController {
  final SoilDashboardState state;
  final UserPlotsHelper plotHelper;
  final selectedLanguage = LanguagePreferences.getLanguage();

  UserPlotController({
    required this.state,
    required this.plotHelper,
  });

  //MAIN DATA
  Map<String, dynamic> get selectedPlot {
    return state.userPlots.firstWhere(
      (plot) => plot['plot_id'] == state.selectedPlotId,
      orElse: () => {},
    );
  }

  int get plotId => selectedPlot['plot_id'] ?? 0;
  String get plotName => selectedPlot['plot_name'] ?? 'No plot found';
  String get soilType => selectedPlot['soil_type'] ?? 'No soil type';
  String get cropType =>
      selectedPlot['user_crops']?['crop_name'] ?? 'No crop assigned';

  List<LatLng> get selectedPolygon {
    final List<dynamic> polygonData = selectedPlot['polygons'] ?? [];

    return polygonData.map<LatLng>((point) {
      return LatLng(
        (point['lat'] as num).toDouble(),
        (point['lng'] as num).toDouble(),
      );
    }).toList();
  }

  String get assignedMoistureSensor => plotHelper.getSensorName(
      selectedPlot['user_plot_sensors'] ?? [], 'Moisture Sensor');

  String get assignedNutrientSensor => plotHelper.getSensorName(
      selectedPlot['user_plot_sensors'] ?? [], 'NPK Sensor');

  String get today => DateTime.now().toIso8601String().split('T').first;

  Map<String, dynamic> get plotWarnings {
    return state.nutrientWarnings.firstWhere(
      (warning) => warning['plot_id'] == state.selectedPlotId,
      orElse: () => {},
    );
  }

  Map<String, dynamic> get plotSuggestions {
    return state.plotsSuggestion.firstWhere(
      (s) => s['plot_id'] == state.selectedPlotId,
      orElse: () => {},
    );
  }

  Map<String, dynamic> get todayAiAnalysis {
    return state.aiAnalysis.firstWhere(
      (entry) =>
          entry['plot_id'] == plotId &&
          entry['language_type'] == selectedLanguage &&
          entry['analysis_date'] == today &&
          entry['analysis_type'] == 'Daily',
      orElse: () => {},
    );
  }

  Map<String, dynamic> get weeklyAnalysis {
    return state.aiAnalysis.firstWhere(
      (entry) =>
          entry['plot_id'] == plotId &&
          entry['language_type'] == selectedLanguage &&
          entry['analysis_date'] == today &&
          entry['analysis_type'] == 'Weekly',
      orElse: () => {},
    );
  }

  String generateDailyPrompt() {
    if (todayAiAnalysis.isEmpty) {
      final filtered = plotHelper.getFilteredAiReadyData(
        selectedPlotId: state.selectedPlotId,
        rawMoistureData: state.rawPlotMoistureData,
        rawNutrientData: state.rawPlotNutrientData,
      );

      if (filtered != null) {
        return plotHelper.getFormattedAiPrompt(data: filtered);
      }
    }
    return '';
  }

  bool get hasSufficientDailyData {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    final dayBeforeYesterday = DateTime.now().subtract(Duration(days: 2));
    Set<String> moistureDays = {};
    Set<String> nutrientDays = {};

    for (var data in state.rawPlotMoistureData) {
      final date = DateTime.parse(data['read_time']);
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      if (data['plot_id'] == plotId &&
          (formattedDate == DateFormat('yyyy-MM-dd').format(yesterday) ||
              formattedDate ==
                  DateFormat('yyyy-MM-dd').format(dayBeforeYesterday))) {
        moistureDays.add(formattedDate);
      }
    }

    for (var data in state.rawPlotNutrientData) {
      final date = DateTime.parse(data['read_time']);
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      if (data['plot_id'] == plotId &&
          (formattedDate == DateFormat('yyyy-MM-dd').format(yesterday) ||
              formattedDate ==
                  DateFormat('yyyy-MM-dd').format(dayBeforeYesterday))) {
        nutrientDays.add(formattedDate);
      }
    }

    return moistureDays.length >= 2 || nutrientDays.length >= 2;
  }

  bool get hasSufficientWeeklyData {
    final startOfWeek = DateTime.now().subtract(Duration(days: 7));
    Set<String> moistureDays = {};
    Set<String> nutrientDays = {};

    for (var data in state.rawPlotMoistureData) {
      final date = DateTime.parse(data['read_time']);
      if (data['plot_id'] == plotId && date.isAfter(startOfWeek)) {
        moistureDays.add(DateFormat('yyyy-MM-dd').format(date));
      }
    }

    for (var data in state.rawPlotNutrientData) {
      final date = DateTime.parse(data['read_time']);
      if (data['plot_id'] == plotId && date.isAfter(startOfWeek)) {
        nutrientDays.add(DateFormat('yyyy-MM-dd').format(date));
      }
    }

    return moistureDays.length >= 7 || nutrientDays.length >= 7;
  }

  Map<String, dynamic> get latestWeeklyAiAnalysis {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 7));

    final weeklyAnalyses = state.aiAnalysis.where((entry) {
      final entryDate = DateTime.parse(entry['analysis_date']);
      return entry['plot_id'] == plotId &&
          entry['analysis_type'] == 'Weekly' &&
          entryDate.isAfter(sevenDaysAgo);
    }).toList();

    weeklyAnalyses.sort((a, b) => DateTime.parse(b['analysis_date'])
        .compareTo(DateTime.parse(a['analysis_date'])));

    return weeklyAnalyses.isNotEmpty ? weeklyAnalyses.first : {};
  }

  String get currentToggle {
    return state.plotToggles[plotId] ?? 'Daily';
  }

  List<Map<String, dynamic>> get aiHistory {
    return state.filteredAnalysis
        .where(
          (entry) => entry['plot_id'] == plotId,
        )
        .toList();
  }
}
