// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/loading_toast.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:soiltrack_mobile/features/crops_registration/models/crop_model.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
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
    final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);
    final sensorNotifier = ref.read(sensorsProvider.notifier);

    state = state.copyWith(isSaving: true);
    ToastLoadingService.showLoadingToast(context, message: 'Assigning Crop');
    print('Selected Sensor: ${state.selectedSensor}');

    try {
      final String userId = supabase.auth.currentUser!.id;

      print('Selected Crop: ${state.selectedCrop}');
      final getCropId = await supabase
          .from('crops')
          .select('*')
          .eq('crop_name', state.selectedCrop!)
          .single();

      if (state.selectedSensor != null) {
        final existingPlot = await supabase
            .from('user_plots')
            .select('plot_id')
            .eq('soil_moisture_sensor_id', state.selectedSensor!)
            .maybeSingle();

        if (existingPlot != null) {
          print('Existing Plot: $existingPlot');
          await supabase.from('user_plots').update({
            'soil_moisture_sensor_id': null,
          }).eq('plot_id', existingPlot['plot_id']);
        }
      }

      final insertUserCrop = await supabase
          .from('user_crops')
          .insert({
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
            'user_id': userId,
          })
          .select()
          .single();

      final insertedPlot = await supabase
          .from('user_plots')
          .insert({
            'user_crop_id': insertUserCrop['user_crop_id'],
            'user_id': userId,
            'plot_name': state.plotName,
            'soil_type': state.soilType,
            'soil_moisture_sensor_id': state.selectedSensor,
            'soil_nutrient_sensor_id': null,
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

      soilDashboardNotifier.fetchUserPlots();
      sensorNotifier.fetchSensors();

      ToastLoadingService.dismissLoadingToast();
      state = state.copyWith(isSaving: false);
      ToastService.showToast(
          context: context,
          message: 'Crop assigned successfully',
          type: ToastificationType.success);
    } catch (e) {
      print('Error assigning crop: $e');
      ToastLoadingService.dismissLoadingToast();
      ToastService.showToast(
          context: context,
          message: 'Error assigning crop',
          type: ToastificationType.error);
      state = state.copyWith(isSaving: false);
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

  void setSoilType(String soilType, BuildContext context) {
    print('Soil Type: $soilType');
    state = state.copyWith(soilType: soilType);
    context.pushNamed('select-category');
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
    ToastLoadingService.showLoadingToast(context, message: 'Saving Crop');

    try {
      final saveNewCropResponse = await supabase
          .from('user_crops')
          .insert({
            'crop_name': cropName,
            'category': state.selectedCategory,
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
        ToastLoadingService.dismissLoadingToast();
        ToastService.showToast(
            context: context,
            message: 'Error saving crop',
            type: ToastificationType.error);
        return;
      }

      final insertedPlot = await supabase
          .from('user_plots')
          .insert({
            'user_crop_id': saveNewCropResponse['user_crop_id'],
            'user_id': supabase.auth.currentUser!.id,
            'plot_name': state.plotName,
            'soil_type': state.soilType,
            'soil_moisture_sensor_id': state.selectedSensor,
            'soil_nutrient_sensor_id': null,
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

      ToastLoadingService.dismissLoadingToast();
      ToastService.showToast(
          context: context,
          message: 'Crop saved successfully',
          type: ToastificationType.success);
    } catch (e) {
      print('Error saving crop: $e');
      ToastLoadingService.dismissLoadingToast();
      ToastService.showToast(
          context: context,
          message: 'Error saving crop',
          type: ToastificationType.error);
    }
  }
}

final cropProvider =
    NotifierProvider<CropNotifer, CropState>(() => CropNotifer());
