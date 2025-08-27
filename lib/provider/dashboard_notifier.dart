import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';

part 'dashboard_notifier.freezed.dart';

@freezed
class DashboardState with _$DashboardState {
  factory DashboardState({
    // Plot selection
    @Default(0) int selectedPlotId,
    @Default(0) int selectedPlotHistoryId,
    @Default(0) int selectedAnalysisId,
    @Default(0) int loadedPlotId,

    // Filters
    @Default("1D") String selectedTimeRangeFilter,
    @Default("1D") String selectedTimeRangeFilterGeneral,
    @Default("1W") String selectedHistoryFilter,
    @Default("en") String selectedLanguage,
    @Default('Daily') String currentCardToggled,
    @Default('Moisture') String currentDeviceToggled,
    @Default('Controller') String mainDeviceToggled,

    // Date ranges (for custom filtering)
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) = _DashboardState;
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return DashboardState();
  }

  void setSelectedPlotId(BuildContext context, int plotId) {
    state = state.copyWith(selectedPlotId: plotId);
    context.push('/user-plot');
  }

  void setPlotId(plotId) {
    state = state.copyWith(selectedPlotId: plotId);
  }

  void setSelectedPlotHistoryId(int plotHistoryId) {
    state = state.copyWith(selectedPlotHistoryId: plotHistoryId);
  }

  void setSelectedAnalysisId(BuildContext context, analysisId) {
    state = state.copyWith(selectedAnalysisId: analysisId);
    context.push('/ai-analytics');
  }

  void setDeviceToggled(String toggleType) {
    state = state.copyWith(currentDeviceToggled: toggleType);
  }

  void setMainDeviceToggle(String toggleType) {
    state = state.copyWith(mainDeviceToggled: toggleType);
  }

  void setSelectedLanguage(String language) {
    state = state.copyWith(selectedLanguage: language);
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
    () => DashboardNotifier());
