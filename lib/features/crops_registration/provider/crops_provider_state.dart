import 'package:freezed_annotation/freezed_annotation.dart';

part 'crops_provider_state.freezed.dart';

@freezed
class CropState with _$CropState {
  factory CropState({
    @Default([]) List<Map<String, dynamic>> allCrops,
    @Default([]) List<Map<String, dynamic>> cropsList,
    String? selectedCategory,
    String? selectedCrop,
    String? plotName,
    String? soilType,
    @Default([]) List<dynamic> specificCropDetails,
    @Default(false) bool isSaving,
    @Default(false) bool isLoading,
    int? selectedSensor,
  }) = _CropState;
}
