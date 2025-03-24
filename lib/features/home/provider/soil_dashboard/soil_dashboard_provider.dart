// ignore_for_file: use_build_context_synchronously, constant_pattern_never_matches_value_type

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/home/helper/soilDashboardHelper.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_state.dart';
import 'package:soiltrack_mobile/features/home/service/soil_dashboard_service.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';

class SoilDashboardNotifier extends Notifier<SoilDashboardState> {
  final SoilDashboardService soilDashboardService = SoilDashboardService();
  final SoilDashboardHelper soilDashboardHelper = SoilDashboardHelper();

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

    final List<String> plotIds =
        state.userPlots.map((plot) => plot['plot_id'].toString()).toList();

    final DateTime startDate =
        customStartDate ?? DateTime.now().subtract(const Duration(days: 90));
    final DateTime endDate = customEndDate ?? DateTime.now();

    try {
      final rawMoistureData = await soilDashboardService.userPlotMoistureData(
          plotIds, startDate, endDate);

      final rawNutrientData = await soilDashboardService.userPlotNutrientData(
          plotIds, startDate, endDate);

      final latestMoistureData =
          await soilDashboardService.fetchLatestMoistureReadings(plotIds);
      final latestNutrientData =
          await soilDashboardService.fetchLatestNutrientsReadings(plotIds);

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

      final summary = soilDashboardHelper.generateOverallCondition(
          nutrientWarnings, state.userPlots.length);

      state = state.copyWith(
        rawPlotMoistureData: rawMoistureData,
        rawPlotNutrientData: rawNutrientData,
        overallCondition: summary,
        nutrientWarnings:
            soilDashboardHelper.extractMessagesByType(messages, 'Warning'),
        plotsSuggestion:
            soilDashboardHelper.extractMessagesByType(messages, 'Suggestion'),
        deviceWarnings: soilDashboardHelper.extractMessagesByType(
            messages, 'Device Warning'),
        lastReadingTime: latestReadingDate,
      );

      NotifierHelper.logMessage('Device warnings: ${state.deviceWarnings}');

      await filterPlotData();
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      state = state.copyWith(isFetchingUserPlotData: false);
    }
  }

  Future<void> filterPlotData() async {
    DateTime startDate = soilDashboardHelper
        .getStartDateFromTimeRange(state.selectedTimeRangeFilter);
    DateTime endDate = DateTime.now();

    if (state.selectedTimeRangeFilter == 'Custom' &&
        state.customStartDate != null &&
        state.customEndDate != null) {
      startDate = state.customStartDate!;
      endDate = state.customEndDate!.add(const Duration(days: 1));
    }

    final aggregationInterval =
        soilDashboardHelper.determineAggregationInterval(
            state.selectedTimeRangeFilter, startDate, endDate);

    NotifierHelper.logMessage('Aggregation interval: $aggregationInterval');

    final filteredMoistureData = state.rawPlotMoistureData.where((reading) {
      DateTime readTime = DateTime.parse(reading['read_time']).toUtc();
      return readTime.isAfter(startDate) && readTime.isBefore(endDate);
    }).toList();

    final filteredNutrientData = state.rawPlotNutrientData.where((reading) {
      DateTime readTime = DateTime.parse(reading['read_time']).toUtc();
      return readTime.isAfter(startDate) && readTime.isBefore(endDate);
    }).toList();

    state = state.copyWith(
      userPlotMoistureData: soilDashboardHelper.aggregatedDataByInterval(
          filteredMoistureData, aggregationInterval, 'soil_moisture'),
      userPlotNutrientData: soilDashboardHelper.aggregatedDataByInterval(
          filteredNutrientData,
          aggregationInterval,
          'readed_nitrogen',
          'readed_phosphorus',
          'readed_potassium'),
    );
  }

  void updateTimeSelection(String selectedTimeRange,
      {DateTime? customStartDate, DateTime? customEndDate}) {
    final bool wasCustom = state.selectedTimeRangeFilter == 'Custom';
    NotifierHelper.logMessage('Is custom: $wasCustom');

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

  void setSelectedPlotId(BuildContext context, plotId) async {
    NotifierHelper.logMessage('Selected plot id: $plotId');
    state = state.copyWith(selectedPlotId: plotId);
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
}

final soilDashboardProvider =
    NotifierProvider<SoilDashboardNotifier, SoilDashboardState>(
        () => SoilDashboardNotifier());
