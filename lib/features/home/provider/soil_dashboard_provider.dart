// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/loading_toast.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/home/service/soil_dashboard_service.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:toastification/toastification.dart';

class SoilDashboardState {
  final List<Map<String, dynamic>> userPlots;
  final List<Map<String, dynamic>> userPlotMoistureData;
  final List<Map<String, dynamic>> userPlotNutrientData;
  final bool isFetchingUserPlots;
  final bool isFetchingUserPlotData;
  final int selectedPlotId;
  final int loadedPlotId;
  final String? error;
  final String? userPlotDataError;

  //For editing user plots state
  final bool isEditingUserPlot;
  final bool isSavingNewCrop;
  final bool isSavingNewSoilType;
  final bool isSavingNewSoilMoistureSensor;
  final bool isSavingNewSoilNutrientSensor;

  SoilDashboardState({
    this.userPlots = const [],
    this.userPlotMoistureData = const [],
    this.userPlotNutrientData = const [],
    this.isFetchingUserPlots = false,
    this.isFetchingUserPlotData = false,
    this.selectedPlotId = 0,
    this.loadedPlotId = 0,
    this.error,
    this.userPlotDataError,

    //For editing user plots state
    this.isEditingUserPlot = false,
    this.isSavingNewCrop = false,
    this.isSavingNewSoilType = false,
    this.isSavingNewSoilMoistureSensor = false,
    this.isSavingNewSoilNutrientSensor = false,
  });

  SoilDashboardState copyWith({
    List<Map<String, dynamic>>? userPlots,
    List<Map<String, dynamic>>? userPlotMoistureData,
    List<Map<String, dynamic>>? userPlotNutrientData,
    bool? isFetchingUserPlots,
    bool? isFetchingUserPlotData,
    int? selectedPlotId,
    int? loadedPlotId,
    String? error,
    String? userPlotDataError,

    //For editing user plots state
    bool? isEditingUserPlot,
    bool? isSavingNewCrop,
    bool? isSavingNewSoilType,
    bool? isSavingNewSoilMoistureSensor,
    bool? isSavingNewSoilNutrientSensor,
  }) {
    return SoilDashboardState(
      userPlots: userPlots ?? this.userPlots,
      userPlotMoistureData: userPlotMoistureData ?? this.userPlotMoistureData,
      userPlotNutrientData: userPlotNutrientData ?? this.userPlotNutrientData,
      isFetchingUserPlots: isFetchingUserPlots ?? this.isFetchingUserPlots,
      isFetchingUserPlotData:
          isFetchingUserPlotData ?? this.isFetchingUserPlotData,
      selectedPlotId: selectedPlotId ?? this.selectedPlotId,
      loadedPlotId: loadedPlotId ?? this.loadedPlotId,
      error: error ?? this.error,
      userPlotDataError: userPlotDataError ?? this.userPlotDataError,

      //For editing user plots state
      isEditingUserPlot: isEditingUserPlot ?? this.isEditingUserPlot,
      isSavingNewCrop: isSavingNewCrop ?? this.isSavingNewCrop,
      isSavingNewSoilType: isSavingNewSoilType ?? this.isSavingNewSoilType,
      isSavingNewSoilMoistureSensor:
          isSavingNewSoilMoistureSensor ?? this.isSavingNewSoilMoistureSensor,
      isSavingNewSoilNutrientSensor:
          isSavingNewSoilNutrientSensor ?? this.isSavingNewSoilNutrientSensor,
    );
  }
}

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
      final prefs = await SharedPreferences.getInstance();
      final macAddress = prefs.getString('mac_address') ?? '';
      final String userId = supabase.auth.currentUser!.id;

      final userPlots = await soilDashboardService.userPlots(userId);
      // print('User Plots $userPlots');

      if (macAddress.isEmpty) {
        print('No device registered');
        state = state.copyWith(error: 'No device registered');
        return;
      }

      if (userPlots.isEmpty) {
        print('No plots available');
        state = state.copyWith(
            error: 'No plots available', isFetchingUserPlots: false);
      }

      state = state.copyWith(userPlots: userPlots, isFetchingUserPlots: false);
    } catch (e) {
      print(e);
      state = state.copyWith(error: e.toString(), isFetchingUserPlots: false);
    }
  }

  void setSelectedPlotId(BuildContext context, plotId) async {
    print('Selected plot ID: $plotId');
    state = state.copyWith(selectedPlotId: plotId);
    context.pushNamed('user-plot');
  }

  void setPlodId(plotId) {
    print('Selected plot id: $plotId');
    state = state.copyWith(selectedPlotId: plotId);
  }

  void setNutrientSensorId(npkSensorId) {
    print('Selected sensor id $npkSensorId');
  }

  Future<void> fetchUserPlotData() async {
    if (state.isFetchingUserPlotData) return;
    state = state.copyWith(isFetchingUserPlotData: true);
    await Future.delayed(const Duration(seconds: 1));

    try {
      final List<String> plotIds =
          state.userPlots.map((plot) => plot['plot_id'].toString()).toList();

      final moistureData =
          await soilDashboardService.userPlotMoistureData(plotIds);

      if (moistureData.isEmpty) {
        state = state.copyWith(
            userPlotDataError: 'No data available',
            isFetchingUserPlotData: false);
      }

      final nutrientData =
          await soilDashboardService.userPlotNutrientData(plotIds);

      if (nutrientData.isEmpty) {
        state = state.copyWith(
            userPlotDataError: 'No data available',
            isFetchingUserPlotData: false);
      }

      print('User moisture plots data: $moistureData');
      state = state.copyWith(
        userPlotMoistureData: moistureData,
        userPlotNutrientData: nutrientData,
        loadedPlotId: state.selectedPlotId,
        isFetchingUserPlotData: false,
      );
    } catch (e) {
      print(e);
      state =
          state.copyWith(error: e.toString(), isFetchingUserPlotData: false);
    } finally {
      state = state.copyWith(isFetchingUserPlotData: false);
    }
  }

  //For editing user plots
  void setEditingUserPlot(bool isEditing) {
    state = state.copyWith(isEditingUserPlot: isEditing);
  }

  Future<void> saveNewCrop(BuildContext context) async {
    final cropState = ref.watch(cropProvider);

    ToastLoadingService.showLoadingToast(context,
        message: 'Assigning new crop');
    try {
      await soilDashboardService.cropId(cropState.selectedCrop!);

      ToastLoadingService.dismissLoadingToast(
          context, 'Crop assigned successfully', ToastificationType.success);

      state = state.copyWith(isEditingUserPlot: false);
      fetchUserPlots();
      await Future.delayed(const Duration(seconds: 2));
      context.pushNamed('user-plot');
    } catch (e) {
      print('Error assigning crop: $e');
      ToastLoadingService.dismissLoadingToast(
          context, 'Error assigning crop', ToastificationType.error);
      state = state.copyWith(isSavingNewCrop: false);
    }
  }

  Future<void> editPlotName(BuildContext context, String newPlotName) async {
    ToastLoadingService.showLoadingToast(context,
        message: 'Changing plot name');

    try {
      await soilDashboardService.editPlotName(
          newPlotName, state.selectedPlotId);
      fetchUserPlots();
      ToastLoadingService.dismissLoadingToast(context,
          'Plot name updated successfully', ToastificationType.success);
    } catch (e) {
      print('Error updating plot name: $e');
      ToastLoadingService.dismissLoadingToast(
          context, 'Error updating plot name', ToastificationType.error);
    }
  }

  Future<void> saveNewThreshold(BuildContext context, String thresholdType,
      Map<String, int> updatedValues) async {
    ToastLoadingService.showLoadingToast(context,
        message: 'Changing $thresholdType threshold');

    try {
      await soilDashboardService.saveNewThreshold(
          state.selectedPlotId, updatedValues);
      await fetchUserPlots();

      ToastLoadingService.dismissLoadingToast(
          context, 'Threshold updated', ToastificationType.success);
    } catch (e) {
      print('Error updating threshold: $e');
      ToastLoadingService.dismissLoadingToast(
          context, 'Error updating threshold', ToastificationType.error);
    }
  }

  Future<void> assignNutrientSensor(BuildContext context, selectedNpkId) async {
    ToastLoadingService.showLoadingToast(context,
        message: 'Assigning NPK Sensor');
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
      await fetchUserPlotData();
      await sensorNotifier.fetchSensors();

      ToastLoadingService.dismissLoadingToast(
          context, 'Sensor assigned successfully', ToastificationType.success);
    } catch (e) {
      print('Error assigning $e');
      ToastLoadingService.dismissLoadingToast(
          context, 'Error assigning NPK', ToastificationType.error);
    }
  }

  Future<void> deletePlot(BuildContext context) async {}
}

final soilDashboardProvider =
    NotifierProvider<SoilDashboardNotifier, SoilDashboardState>(
        () => SoilDashboardNotifier());
