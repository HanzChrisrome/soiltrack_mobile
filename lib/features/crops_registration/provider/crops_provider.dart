import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/features/crops_registration/models/crop_model.dart';

class CropState {
  final List<Crop> cropsList;
  final String? selectedCategory;
  final String? selectedCrop;
  final List<dynamic> specificCropDetails;
  final bool isSaving;
  final bool isLoading;
  final String? selectedSensor;

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
    String? selectedSensor,
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

  void selectSensor(String sensorName) {
    state = state.copyWith(selectedSensor: sensorName);
  }

  Future<void> assignCrop() async {
    try {
      state = state.copyWith(isSaving: true);

      final response = await supabase.from('user_plots').insert([
        {
          'user_id': supabase.auth.currentUser!.id,
          'crop_name': state.selectedCrop,
          'sensor_name': state.selectedSensor,
        }
      ]);

      if (response.error != null) {
        state = state.copyWith(isSaving: false);
        return;
      }

      state = state.copyWith(isSaving: false);
    } catch (e) {
      print('Error assigning crop: $e');
      state = state.copyWith(isSaving: false);
    }
  }
}

final cropProvider =
    NotifierProvider<CropNotifer, CropState>(() => CropNotifer());
