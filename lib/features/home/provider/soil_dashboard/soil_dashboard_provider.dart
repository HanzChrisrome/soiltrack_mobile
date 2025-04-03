import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/home/helper/soilDashboardHelper.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_state.dart';
import 'package:soiltrack_mobile/features/home/service/ai_service.dart';
import 'package:soiltrack_mobile/features/home/service/soil_dashboard_service.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';

class SoilDashboardNotifier extends Notifier<SoilDashboardState> {
  final SoilDashboardService soilDashboardService = SoilDashboardService();
  final SoilDashboardHelper soilDashboardHelper = SoilDashboardHelper();
  final AiService aiService = AiService();

  @override
  SoilDashboardState build() {
    return SoilDashboardState();
  }

  Future<void> fetchUserPlots() async {
    if (state.isFetchingUserPlots) return;
    state = state.copyWith(isFetchingUserPlots: true);

    try {
      final String userId = supabase.auth.currentUser!.id;
      final userPlots = await soilDashboardService.userPlots(userId);
      state = state.copyWith(
        userPlots: userPlots,
        error: userPlots.isEmpty ? 'No plots found' : null,
      );

      await fetchUserPlotData();
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      state = state.copyWith(isFetchingUserPlots: false);
    }
  }

  Future<void> fetchUserPlotData(
      {DateTime? customStartDate, DateTime? customEndDate}) async {
    if (state.isFetchingUserPlotData) return;
    state = state.copyWith(isFetchingUserPlotData: true);

    try {
      final List<String> plotIds =
          state.userPlots.map((plot) => plot['plot_id'].toString()).toList();

      final DateTime startDate =
          customStartDate ?? DateTime.now().subtract(const Duration(days: 90));
      final DateTime endDate = customEndDate ?? DateTime.now();

      //FETCH DATA
      final results = await Future.wait([
        soilDashboardService.userPlotMoistureData(plotIds, startDate, endDate),
        soilDashboardService.userPlotNutrientData(plotIds, startDate, endDate),
      ]);

      final rawMoistureData = results[0];
      final rawNutrientData = results[1];

      state = state.copyWith(
        rawPlotMoistureData: rawMoistureData,
        rawPlotNutrientData: rawNutrientData,
      );

      await fetchLatestData(plotIds);
      await filterPlotData();
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      state = state.copyWith(isFetchingUserPlotData: false);
    }
  }

  Future<void> fetchLatestData(List<String> plotIds) async {
    final DateTime now = DateTime.now();

    final DateTime yesterdayStart =
        soilDashboardHelper.getStartOfDay(now.subtract(Duration(days: 1)));

    final DateTime dayBeforeYesterdayStart =
        soilDashboardHelper.getStartOfDay(now.subtract(Duration(days: 2)));

    try {
      final data = await Future.wait([
        soilDashboardService.fetchLatestMoistureReadings(plotIds),
        soilDashboardService.fetchLatestNutrientsReadings(plotIds),
        soilDashboardService.userPlotMoistureData(
            plotIds, yesterdayStart, yesterdayStart),
        soilDashboardService.userPlotMoistureData(
            plotIds, dayBeforeYesterdayStart, dayBeforeYesterdayStart),
        soilDashboardService.userPlotNutrientData(
            plotIds, yesterdayStart, yesterdayStart),
        soilDashboardService.userPlotNutrientData(
            plotIds, dayBeforeYesterdayStart, dayBeforeYesterdayStart),
      ]);

      final latestMoistureData = data[0];
      final latestNutrientData = data[1];
      final yesterdayMoistureData = data[2];
      final dayBeforeYesterdayMoistureData = data[3];
      final yesterdayNutrientData = data[4];
      final dayBeforeYesterdayNutrientData = data[5];

      final yesterdayNutrientFormatted = soilDashboardHelper
          .formatNutrientDataForPrompt(yesterdayNutrientData);

      final dayBeforeYesterdayNutrientFormatted = soilDashboardHelper
          .formatNutrientDataForPrompt(dayBeforeYesterdayNutrientData);

      final yesterdayMoistureFormatted = soilDashboardHelper
          .formatMoistureDataForPrompt(yesterdayMoistureData);
      final dayBeforeYesterdayMoistureFormatted = soilDashboardHelper
          .formatMoistureDataForPrompt(dayBeforeYesterdayMoistureData);

      NotifierHelper.logMessage(
          'Yesterday moisture data: $yesterdayMoistureFormatted');
      NotifierHelper.logMessage(
          'Day before yesterday moisture data: $dayBeforeYesterdayMoistureFormatted');

      NotifierHelper.logMessage(
          'Yesterday nutrient data: $yesterdayNutrientFormatted');
      NotifierHelper.logMessage(
          'Day before yesterday nutrient data: $dayBeforeYesterdayNutrientFormatted');

      DateTime? latestMoistureTimestamp =
          soilDashboardHelper.getLatestTimestamp(latestMoistureData);
      DateTime? latestNutrientTimestamp =
          soilDashboardHelper.getLatestTimestamp(latestNutrientData);

      DateTime? latestReadingDate;
      if (latestMoistureTimestamp != null && latestNutrientTimestamp != null) {
        latestReadingDate =
            latestMoistureTimestamp.isAfter(latestNutrientTimestamp)
                ? latestMoistureTimestamp
                : latestNutrientTimestamp;
      } else {
        latestReadingDate = latestMoistureTimestamp ?? latestNutrientTimestamp;
      }

      final messages = soilDashboardService.generateNutrientWarnings(
          state.userPlots, latestMoistureData, latestNutrientData);

      final nutrientWarnings =
          soilDashboardHelper.extractMessagesByType(messages, 'Warning');

      Map<int, String> plotConditions = {};
      for (var plot in state.userPlots) {
        int plotId = plot['plot_id'];
        plotConditions[plotId] =
            soilDashboardHelper.generatePlotCondition(plotId, nutrientWarnings);
      }

      final summary = soilDashboardHelper.generateOverallCondition(
          nutrientWarnings, state.userPlots.length);

      state = state.copyWith(
        latestPlotMoistureData: latestMoistureData,
        latestPlotNutrientData: latestNutrientData,
        overallCondition: summary,
        plotConditions: plotConditions,
        lastReadingTime: latestReadingDate,
        nutrientWarnings: nutrientWarnings,
        plotsSuggestion:
            soilDashboardHelper.extractMessagesByType(messages, 'Suggestion'),
        deviceWarnings: soilDashboardHelper.extractMessagesByType(
            messages, 'Device Warning'),
      );
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  Future<void> filterPlotData() async {
    DateTime startDate = soilDashboardHelper
        .getStartDateFromTimeRange(state.selectedTimeRangeFilter);

    DateTime endDate =
        DateTime.now().add(Duration(days: 1)).subtract(Duration(seconds: 1));

    if (state.selectedTimeRangeFilter == 'Custom' &&
        state.customStartDate != null &&
        state.customEndDate != null) {
      startDate = state.customStartDate!;
      endDate = state.customEndDate!;
    }

    final String aggregationInterval = state.selectedTimeRangeFilter == 'Custom'
        ? soilDashboardHelper.determineAggregationInterval(
            state.selectedTimeRangeFilter, startDate, endDate)
        : state.selectedTimeRangeFilter;

    List<Map<String, dynamic>> filteredMoistureData = state.rawPlotMoistureData;
    List<Map<String, dynamic>> filteredNutrientData = state.rawPlotNutrientData;

    if (state.selectedTimeRangeFilter != 'Custom') {
      filteredMoistureData = state.rawPlotMoistureData.where((reading) {
        DateTime readTime = DateTime.parse(reading['read_time']).toUtc();
        return readTime.isAfter(startDate) && readTime.isBefore(endDate);
      }).toList();

      filteredNutrientData = state.rawPlotNutrientData.where((reading) {
        DateTime readTime = DateTime.parse(reading['read_time']).toUtc();
        return readTime.isAfter(startDate) && readTime.isBefore(endDate);
      }).toList();
    }

    state = state.copyWith(
      userPlotMoistureData: soilDashboardHelper.aggregatedDataByInterval(
          filteredMoistureData, aggregationInterval, 'soil_moisture'),
      userPlotNutrientData: soilDashboardHelper.aggregatedDataByInterval(
          filteredNutrientData,
          aggregationInterval,
          'readed_nitrogen',
          'readed_phosphorus',
          'readed_potassium'),
      customTimeRangeFilter: aggregationInterval,
    );
  }

  void updateTimeSelection(String selectedTimeRange,
      {DateTime? customStartDate, DateTime? customEndDate}) {
    final bool wasCustom = state.selectedTimeRangeFilter == 'Custom';

    state = state.copyWith(
      selectedTimeRangeFilter: selectedTimeRange,
      customStartDate: selectedTimeRange == 'Custom' ? customStartDate : null,
      customEndDate: selectedTimeRange == 'Custom' ? customEndDate : null,
    );

    if (selectedTimeRange == 'Custom' &&
        customStartDate != null &&
        customEndDate != null) {
      fetchUserPlotData(
          customStartDate: customStartDate, customEndDate: customEndDate);
    } else {
      if (wasCustom) {
        fetchUserPlotData();
        state = state.copyWith(customStartDate: null, customEndDate: null);
      } else {
        filterPlotData();
      }
    }
  }

  Future<void> saveNewCrop(BuildContext context) async {
    final cropState = ref.watch(cropProvider);
    NotifierHelper.showLoadingToast(context, 'Assigning crop to plot');
    try {
      await soilDashboardService.cropId(cropState.selectedCrop!);

      NotifierHelper.showSuccessToast(context, 'Crop assigned successfully');
      await fetchUserPlots();
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error assigning crop');
    } finally {
      state = state.copyWith(isSavingNewCrop: false);
    }
  }

  Future<void> editPlotName(BuildContext context, String newPlotName) async {
    NotifierHelper.showLoadingToast(context, 'Updating plot name');

    try {
      await soilDashboardService.editPlotName(
          newPlotName, state.selectedPlotId);
      fetchUserPlots();
      NotifierHelper.showSuccessToast(context, 'Plot name updated');
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error updating plot name');
    }
  }

  Future<void> saveNewThreshold(BuildContext context, String thresholdType,
      Map<String, int> updatedValues) async {
    NotifierHelper.showLoadingToast(context, 'Updating threshold');

    try {
      await soilDashboardService.saveNewThreshold(
          state.selectedPlotId, updatedValues);
      await fetchUserPlots();

      NotifierHelper.showSuccessToast(context, 'Threshold updated');
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error updating threshold');
    }
  }

  Future<void> assignNutrientSensor(BuildContext context, selectedNpkId) async {
    NotifierHelper.showLoadingToast(context, 'Assigning NPK sensor');
    final sensorNotifier = ref.read(sensorsProvider.notifier);
    final selectedPlotID = state.selectedPlotId;

    try {
      await supabase.from('user_plot_sensors').insert({
        'plot_id': selectedPlotID,
        'sensor_id': selectedNpkId,
      });

      await supabase.from('soil_sensors').update({
        'is_assigned': true,
      }).eq('sensor_id', selectedNpkId);

      await fetchUserPlots();
      await sensorNotifier.fetchSensors();

      NotifierHelper.showSuccessToast(context, 'NPK sensor assigned');
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error assigning NPK sensor');
    }
  }

  Future<void> fetchAi() async {
    try {
      // await aiService.fetchAndAnalyze();
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  void setSelectedPlotId(BuildContext context, plotId) async {
    NotifierHelper.logMessage('Selected plot id: $plotId');
    state = state.copyWith(selectedPlotId: plotId);
    String warnings = soilDashboardHelper.generatePlotCondition(
        state.selectedPlotId, state.nutrientWarnings);

    NotifierHelper.logMessage('Plot warnings: $warnings');
    context.pushNamed('user-plot');
  }

  void setPlotId(plotId) {
    NotifierHelper.logMessage('Selected plot id: $plotId');
    state = state.copyWith(selectedPlotId: plotId);
  }

  void setNutrientSensorId(npkSensorId) {
    NotifierHelper.logMessage('Selected NPK sensor id: $npkSensorId');
  }

  void setEditingUserPlot(bool isEditing) {
    state = state.copyWith(isEditingUserPlot: isEditing);
  }
}

final soilDashboardProvider =
    NotifierProvider<SoilDashboardNotifier, SoilDashboardState>(
        () => SoilDashboardNotifier());
