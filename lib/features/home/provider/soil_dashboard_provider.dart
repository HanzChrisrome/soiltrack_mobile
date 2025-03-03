// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_state.dart';
import 'package:soiltrack_mobile/features/home/service/soil_dashboard_service.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';

class SoilDashboardNotifier extends Notifier<SoilDashboardState> {
  final SoilDashboardService soilDashboardService = SoilDashboardService();

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

  Future<void> fetchUserPlotData() async {
    final List<String> plotIds =
        state.userPlots.map((plot) => plot['plot_id'].toString()).toList();

    final moistureData =
        await soilDashboardService.userPlotMoistureData(plotIds);

    final nutrientData =
        await soilDashboardService.userPlotNutrientData(plotIds);

    final messages = soilDashboardService.generateNutrientWarnings(
        state.userPlots, moistureData, nutrientData);

    final warningsOnly = messages.map((plot) {
      final filteredMessages = (plot['messages'] as List)
          .where((message) => message['type'] == 'Warning')
          .toList();

      return {
        'plot_id': plot['plot_id'],
        'plot_name': plot['plot_name'],
        'warnings': filteredMessages.map((msg) => msg['message']).toList(),
      };
    }).toList();

    final suggestionsOnly = messages.map((plot) {
      final filteredMessages = (plot['messages'] as List)
          .where((message) => message['type'] == 'Suggestion')
          .toList();

      return {
        'plot_id': plot['plot_id'],
        'plot_name': plot['plot_name'],
        'suggestions': filteredMessages.map((msg) => msg['message']).toList(),
      };
    }).toList();

    final deviceWarningsOnly = messages.map((plot) {
      final filteredMessages = (plot['messages'] as List)
          .where((message) => message['type'] == 'Device Warning')
          .toList();

      return {
        'plot_id': plot['plot_id'],
        'plot_name': plot['plot_name'],
        'warnings': filteredMessages.map((msg) => msg['message']).toList(),
      };
    }).toList();

    state = state.copyWith(
      userPlotMoistureData: moistureData,
      userPlotNutrientData: nutrientData,
      nutrientWarnings: warningsOnly,
      plotsSuggestion: suggestionsOnly,
      deviceWarnings: deviceWarningsOnly,
    );
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

  void updateTimeSelection(String selectedTimeRange) {
    final DateTime now = DateTime.now();
    DateTime startDate;

    switch (selectedTimeRange) {
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

    state = state.copyWith(selectedTimeRange: startDate);
  }

  void setSelectedPlotId(BuildContext context, plotId) async {
    NotifierHelper.logMessage('Selected plot id: $plotId');
    state = state.copyWith(selectedPlotId: plotId);
    context.pushNamed('user-plot');
  }

  void setPlodId(plotId) {
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
