// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/loading_toast.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:toastification/toastification.dart';

class SoilDashboardState {
  final List<Map<String, dynamic>> userPlots;
  final List<Map<String, dynamic>> userPlotData;
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
    this.userPlotData = const [],
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
    List<Map<String, dynamic>>? userPlotData,
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
      userPlotData: userPlotData ?? this.userPlotData,
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

      if (macAddress.isEmpty) {
        print('No device registered');
        state = state.copyWith(error: 'No device registered');
        return;
      }

      // Fetch user plots from Supabase
      final userPlots = await supabase.from('user_plots').select('''
        plot_id,
        plot_name,
        soil_type,
        user_crop_id,
        date_added,
        user_crops (
            crop_name,
            category,
            moisture_min,
            moisture_max,
            nitrogen_min,
            nitrogen_max,
            phosphorus_min,
            phosphorus_max,
            potassium_min,
            potassium_max
        ),
        soil_moisture_sensor_id,
        soil_moisture_sensors (
            soil_moisture_sensor_id,
            soil_moisture_name,
            soil_moisture_status,
            is_assigned
        ),
        soil_nutrient_sensor_id,
        soil_nutrient_sensors (
            soil_nutrient_sensor_id,
            soil_nutrient_name,
            soil_nutrient_status,
            is_assigned
        )
    ''').eq('user_id', userId).order('date_added', ascending: true);

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

  Future<void> fetchUserPlotData() async {
    if (state.isFetchingUserPlotData) return;
    state = state.copyWith(isFetchingUserPlotData: true);
    await Future.delayed(const Duration(seconds: 1));

    try {
      final userPlotsData = await supabase
          .from('soil_moisture_readings')
          .select('''
            plot_id,
            soil_moisture_sensor_id,
            soil_moisture,
            read_time
        ''')
          .eq('plot_id', state.selectedPlotId)
          .order('read_time', ascending: false);

      if (userPlotsData.isEmpty) {
        state = state.copyWith(
            userPlotDataError: 'No data available',
            isFetchingUserPlotData: false);
      }

      print('User plots data: $userPlotsData');
      state = state.copyWith(
        userPlotData: userPlotsData,
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
      print('Selected Crop: ${cropState.selectedCrop}');
      final getCropId = await supabase
          .from('crops')
          .select('crop_id')
          .eq('crop_name', cropState.selectedCrop!)
          .single();

      await supabase.from('user_plots').update({
        'crop_id': getCropId['crop_id'],
      }).eq('plot_id', state.selectedPlotId);

      ToastLoadingService.dismissLoadingToast();
      ToastService.showToast(
          context: context,
          message: 'Crop assigned successfully',
          type: ToastificationType.success);

      state = state.copyWith(isEditingUserPlot: false);
      fetchUserPlots();
      await Future.delayed(const Duration(seconds: 2));
      context.pushNamed('user-plot');
    } catch (e) {
      print('Error assigning crop: $e');
      ToastLoadingService.dismissLoadingToast();
      ToastService.showToast(
          context: context,
          message: 'Error updating crop',
          type: ToastificationType.error);
      state = state.copyWith(isSavingNewCrop: false);
    }
  }

  Future<void> editPlotName(BuildContext context, String newPlotName) async {
    ToastLoadingService.showLoadingToast(context,
        message: 'Changing plot name');

    try {
      await supabase.from('user_plots').update({'plot_name': newPlotName}).eq(
          'plot_id', state.selectedPlotId);

      fetchUserPlots();
      ToastLoadingService.dismissLoadingToast();
      ToastService.showToast(
          context: context,
          message: 'Plot name updated successfully',
          type: ToastificationType.success);
    } catch (e) {
      print('Error updating plot name: $e');
      ToastLoadingService.dismissLoadingToast();
      ToastService.showToast(
          context: context,
          message: 'Error updating crop',
          type: ToastificationType.error);
    }
  }

  Future<void> saveNewThreshold(BuildContext context, String thresholdType,
      Map<String, int> updatedValues) async {
    ToastLoadingService.showLoadingToast(context,
        message: 'Changing $thresholdType threshold');

    try {
      final userCropId = await supabase
          .from('user_plots')
          .select('user_crop_id')
          .eq('plot_id', state.selectedPlotId)
          .single();

      await supabase
          .from('user_crops')
          .update(updatedValues)
          .eq('user_crop_id', userCropId['user_crop_id']);

      await fetchUserPlots();

      ToastLoadingService.dismissLoadingToast();
      ToastService.showToast(
          context: context,
          message: 'Threshold updated successfully',
          type: ToastificationType.success);
    } catch (e) {
      print('Error updating threshold: $e');
      ToastLoadingService.dismissLoadingToast();
      ToastService.showToast(
          context: context,
          message: 'Error updating threshold',
          type: ToastificationType.error);
    }
  }
}

final soilDashboardProvider =
    NotifierProvider<SoilDashboardNotifier, SoilDashboardState>(
        () => SoilDashboardNotifier());
