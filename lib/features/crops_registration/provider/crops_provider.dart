// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/loading_toast.dart';
import 'package:soiltrack_mobile/features/crops_registration/models/crop_model.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:toastification/toastification.dart';

class CropState {
  final List<Crop> cropsList;
  final String? selectedCategory;
  final String? selectedCrop;
  final String? plotName;
  final String? soilType;
  final List<dynamic> specificCropDetails;
  final bool isSaving;
  final bool isLoading;
  final int? selectedSensor;

  CropState({
    this.cropsList = const [],
    this.selectedCategory,
    this.selectedCrop,
    this.plotName,
    this.soilType,
    this.specificCropDetails = const [],
    this.isSaving = false,
    this.isLoading = false,
    this.selectedSensor,
  });

  CropState copyWith({
    List<Crop>? cropsList,
    String? selectedCategory,
    String? selectedCrop,
    String? plotName,
    String? soilType,
    List<dynamic>? specificCropDetails,
    bool? isSaving,
    bool? isLoading,
    int? selectedSensor,
  }) {
    return CropState(
      cropsList: cropsList ?? this.cropsList,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCrop: selectedCrop ?? this.selectedCrop,
      plotName: plotName ?? this.plotName,
      soilType: soilType ?? this.soilType,
      specificCropDetails: specificCropDetails ?? this.specificCropDetails,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      selectedSensor: selectedSensor ?? this.selectedSensor,
    );
  }
}

class CropNotifer extends Notifier<CropState> {
  @override
  CropState build() {
    return CropState();
  }

  void selectCategory(String category) {
    if (state.selectedCategory == category) return;

    state = state.copyWith(selectedCategory: category);
    getSelectedCropsCategory();
  }

  Future<void> getSelectedCropsCategory() async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await supabase
          .from('crops')
          .select()
          .eq('category', state.selectedCategory!);

      List<Crop> crops = response.map((json) => Crop.fromJson(json)).toList();

      state = state.copyWith(cropsList: crops, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> getSelectedCropDetails() async {
    try {
      state = state.copyWith(isLoading: true);

      final specificCrop = await supabase
          .from('crops')
          .select()
          .eq('crop_name', state.selectedCrop!)
          .single();

      state =
          state.copyWith(specificCropDetails: [specificCrop], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectSensor(int sensorId) {
    state = state.copyWith(selectedSensor: sensorId);
  }

  void unselectSensor() {
    state = state.copyWith(selectedSensor: null);
  }

  Future<void> assignCrop(BuildContext context) async {
    final soilDashboardState = ref.read(soilDashboardProvider);
    final soilDashboardNotifier = ref.watch(soilDashboardProvider.notifier);

    state = state.copyWith(isSaving: true);
    ToastLoadingService.showLoadingToast(context, message: 'Assigning Crop');
    print('Selected Sensor: ${state.selectedSensor}');

    try {
      final String userId = supabase.auth.currentUser!.id;
      int plotId = soilDashboardState.selectedPlotId;

      final getCropId = await supabase
          .from('crops')
          .select('*')
          .eq('crop_name', state.selectedCrop!)
          .single();

      if (soilDashboardState.isEditingUserPlot == false) {
        final insertedPlot = await supabase
            .from('user_plots')
            .insert({
              'user_id': userId,
              'plot_name': state.plotName,
              'soil_type': state.soilType,
            })
            .select()
            .single();

        plotId = insertedPlot['plot_id'];
      }

      await supabase.from('user_crops').upsert({
        'crop_name': getCropId['crop_name'],
        'category': getCropId['category'],
        'moisture_min': getCropId['moisture_min'],
        'moisture_max': getCropId['moisture_max'],
        'nitrogen_min': getCropId['nitrogen_min'],
        'nitrogen_max': getCropId['nitrogen_max'],
        'phosphorus_min': getCropId['phosphorus_min'],
        'phosphorus_max': getCropId['phosphorus_max'],
        'potassium_min': getCropId['potassium_min'],
        'potassium_max': getCropId['potassium_max'],
        'plot_id': plotId,
      }, onConflict: 'plot_id');

      if (state.selectedSensor != null) {
        await supabase.from('soil_sensors').update({
          'is_assigned': true,
        }).eq('sensor_id', state.selectedSensor!);
      }

      if (state.selectedSensor != null) {
        await supabase.from('user_plot_sensors').insert({
          'plot_id': plotId,
          'sensor_id': state.selectedSensor,
        });
      }

      soilDashboardNotifier.fetchUserPlots();
      ToastLoadingService.dismissLoadingToast(
          context, 'Crop assigned successfully', ToastificationType.success);
      state = state.copyWith(isSaving: false);
    } catch (e) {
      print('Error assigning crop: $e');
      ToastLoadingService.dismissLoadingToast(
          context, 'Error assigning crop', ToastificationType.error);
    }
  }

  void selectCropName(String cropName) {
    final userPlot = ref.read(soilDashboardProvider);
    if (state.selectedCrop == cropName) return;

    state = state.copyWith(selectedCrop: cropName);

    if (userPlot.isEditingUserPlot != true) {
      getSelectedCropDetails();
    }
  }

  void setPlotName(String plotName, BuildContext context) {
    print('Plot Name: $plotName');
    state = state.copyWith(plotName: plotName);
    context.pushNamed('soil-assigning');
  }

  Future<void> setSoilType(String soilType, BuildContext context) async {
    final userPlotState = ref.read(soilDashboardProvider);
    final soilDashboardNotifier = ref.watch(soilDashboardProvider.notifier);
    final plotId = userPlotState.selectedPlotId;

    ToastLoadingService.showLoadingToast(context, message: 'Setting Soil Type');
    try {
      await supabase.from('user_plots').update({
        'soil_type': soilType,
      }).eq('plot_id', plotId);

      soilDashboardNotifier.fetchUserPlots();
      soilDashboardNotifier.fetchUserPlotData();

      ToastLoadingService.dismissLoadingToast(
          context, 'Soil type set successfully', ToastificationType.success);
    } catch (e) {
      print('Error setting soil type: $e');
      ToastLoadingService.dismissLoadingToast(
          context, 'Error setting soil type', ToastificationType.error);
    }
  }

  Future<void> saveNewCrop(
    BuildContext context,
    String cropName,
    int minMoisture,
    int maxMoisture,
    int minNitrogen,
    int maxNitrogen,
    int minPhosphorus,
    int maxPhosphorus,
    int minPotassium,
    int maxPotassium,
  ) async {
    final userPlotNotifier = ref.read(soilDashboardProvider.notifier);
    ToastLoadingService.showLoadingToast(context, message: 'Saving Crop');

    try {
      final saveNewCropResponse = await supabase
          .from('user_crops')
          .insert({
            'crop_name': cropName,
            'category': 'Custom Crop',
            'moisture_min': minMoisture,
            'moisture_max': maxMoisture,
            'nitrogen_min': minNitrogen,
            'nitrogen_max': maxNitrogen,
            'phosphorus_min': minPhosphorus,
            'phosphorus_max': maxPhosphorus,
            'potassium_min': minPotassium,
            'potassium_max': maxPotassium,
            'user_id': supabase.auth.currentUser!.id,
          })
          .select()
          .single();

      if (saveNewCropResponse.isEmpty) {
        ToastLoadingService.dismissLoadingToast(
            context, 'Error saving crop', ToastificationType.error);
        return;
      }

      final insertedPlot = await supabase
          .from('user_plots')
          .insert({
            'user_crop_id': saveNewCropResponse['user_crop_id'],
            'user_id': supabase.auth.currentUser!.id,
            'plot_name': state.plotName,
            'soil_type': state.soilType,
          })
          .select()
          .single();

      final plotId = insertedPlot['plot_id'];
      print('Plot ID: $plotId');

      if (state.selectedSensor != null) {
        await supabase.from('soil_moisture_sensors').update({
          'is_assigned': true,
        }).eq('soil_moisture_sensor_id', state.selectedSensor!);
      }

      userPlotNotifier.fetchUserPlots();
      ToastLoadingService.dismissLoadingToast(
          context, 'Crop saved successfully', ToastificationType.success);
    } catch (e) {
      print('Error saving crop: $e');
      ToastLoadingService.dismissLoadingToast(
          context, 'Error saving crop', ToastificationType.error);
    }
  }
}

final cropProvider =
    NotifierProvider<CropNotifer, CropState>(() => CropNotifer());
