import 'package:freezed_annotation/freezed_annotation.dart';

part 'soil_dashboard_state.freezed.dart';

@freezed
class SoilDashboardState with _$SoilDashboardState {
  factory SoilDashboardState({
    @Default([]) List<Map<String, dynamic>> userPlots,
    @Default([]) List<Map<String, dynamic>> rawPlotMoistureData,
    @Default([]) List<Map<String, dynamic>> rawPlotNutrientData,
    @Default([]) List<Map<String, dynamic>> latestPlotMoistureData,
    @Default([]) List<Map<String, dynamic>> latestPlotNutrientData,
    @Default([]) List<Map<String, dynamic>> userPlotMoistureData,
    @Default([]) List<Map<String, dynamic>> userPlotNutrientData,
    @Default([]) List<Map<String, dynamic>> nutrientWarnings,
    @Default([]) List<Map<String, dynamic>> plotsSuggestion,
    @Default([]) List<Map<String, dynamic>> deviceWarnings,
    @Default(false) bool isFetchingUserPlots,
    @Default(false) bool isFetchingUserPlotData,
    @Default(0) int selectedPlotId,
    @Default(0) int loadedPlotId,
    @Default({}) Map<int, String> plotConditions,
    String? error,
    String? userPlotDataError,
    String? overallCondition,
    DateTime? selectedTimeRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    DateTime? lastReadingTime,
    @Default("1D") String selectedTimeRangeFilter,
    @Default("1D") String customTimeRangeFilter,
    @Default(false) bool isEditingUserPlot,
    @Default(false) bool isSavingNewCrop,
    @Default(false) bool isSavingNewSoilType,
    @Default(false) bool isSavingNewSoilMoistureSensor,
    @Default(false) bool isSavingNewSoilNutrientSensor,
    @Default(false) bool isAiAnalysisReady,
  }) = _SoilDashboardState;
}
