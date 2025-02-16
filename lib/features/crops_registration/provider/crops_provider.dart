// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/loading_toast.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:soiltrack_mobile/features/crops_registration/models/crop_model.dart';
import 'package:toastification/toastification.dart';

class CropState {
  final List<Crop> cropsList;
  final String? selectedCategory;
  final String? selectedCrop;
  final List<dynamic> specificCropDetails;
  final bool isSaving;
  final bool isLoading;
  final int? selectedSensor;

  CropState({
    this.cropsList = const [],
    this.selectedCategory,
    this.selectedCrop,
    this.specificCropDetails = const [],
    this.isSaving = false,
    this.isLoading = false,
    this.selectedSensor,
  });

  CropState copyWith({
    List<Crop>? cropsList,
    String? selectedCategory,
    String? selectedCrop,
    List<dynamic>? specificCropDetails,
    bool? isSaving,
    bool? isLoading,
    int? selectedSensor,
  }) {
    return CropState(
      cropsList: cropsList ?? this.cropsList,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCrop: selectedCrop ?? this.selectedCrop,
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

  void selectCropName(String cropName) {
    if (state.selectedCrop == cropName) return;

    state = state.copyWith(selectedCrop: cropName);
    getSelectedCropDetails();
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

  Future<void> assignCrop(BuildContext context) async {
    try {
      state = state.copyWith(isSaving: true);
      ToastLoadingService.showLoadingToast(context, message: 'Assigning Crop');

      final getCropId = await supabase
          .from('crops')
          .select('crop_id')
          .eq('crop_name', state.selectedCrop!)
          .single();

      final insertedPlot = await supabase
          .from('user_plots')
          .insert({
            'crop_id': getCropId['crop_id'],
          })
          .select()
          .single();

      final plotId = insertedPlot['plot_id'];
      print('Plot ID: $plotId');

      await supabase.from('soil_moisture_sensors').update({
        'is_assigned': true,
        'plot_id': plotId,
      }).eq('soil_moisture_sensor_id', state.selectedSensor!);

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
}

final cropProvider =
    NotifierProvider<CropNotifer, CropState>(() => CropNotifer());
