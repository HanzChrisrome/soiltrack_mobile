// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider_state.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';

class CropNotifer extends Notifier<CropState> {
  @override
  CropState build() {
    return CropState();
  }

  Future<void> fetchAllCrops() async {
    try {
      final crops = await supabase.from('crops').select();
      state = state.copyWith(allCrops: crops);
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  void selectCategory(String category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);

    final filteredCrops =
        state.allCrops.where((crop) => crop['category'] == category).toList();

    state = state.copyWith(cropsList: filteredCrops);
  }

  Future<void> getSelectedCropDetails() async {
    if (state.selectedCrop == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final specificCrop = state.cropsList.firstWhere(
        (crop) => crop['crop_name'] == state.selectedCrop,
        orElse: () => {},
      );

      state = state.copyWith(specificCropDetails: [specificCrop]);
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> assignCrop(BuildContext context) async {
    final soilDashboardState = ref.read(soilDashboardProvider);
    final soilDashboardNotifier = ref.watch(soilDashboardProvider.notifier);

    state = state.copyWith(isSaving: true);
    NotifierHelper.showLoadingToast(context, 'Assigning Crop');

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
      NotifierHelper.showSuccessToast(context, 'Crop assigned successfully');
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error assigning crop');
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<void> setSoilType(String soilType, BuildContext context) async {
    final userPlotState = ref.read(soilDashboardProvider);
    final soilDashboardNotifier = ref.watch(soilDashboardProvider.notifier);
    final plotId = userPlotState.selectedPlotId;

    NotifierHelper.showLoadingToast(context, 'Setting Soil Type');
    try {
      await supabase.from('user_plots').update({
        'soil_type': soilType,
      }).eq('plot_id', plotId);

      soilDashboardNotifier.fetchUserPlots();
      soilDashboardNotifier.fetchUserPlotData();

      NotifierHelper.showSuccessToast(context, 'Soil type set successfully');
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error setting soil type');
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
    NotifierHelper.showLoadingToast(context, 'Saving Crop');

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
        throw 'Error saving crop';
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
      NotifierHelper.showSuccessToast(context, 'Crop saved successfully');
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error saving crop');
    }
  }

  void selectSensor(int sensorId) {
    state = state.copyWith(selectedSensor: sensorId);
  }

  void unselectSensor() {
    state = state.copyWith(selectedSensor: null);
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
}

final cropProvider =
    NotifierProvider<CropNotifer, CropState>(() => CropNotifer());
