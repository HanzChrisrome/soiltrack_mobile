// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
part of '../soil_dashboard_provider.dart';

extension DashboardFilterExtension on SoilDashboardNotifier {
  void updateHistoryFilterSelection(String selectedWeek,
      {DateTime? customStartDate, DateTime? customEndDate}) {
    final bool wasCustom = state.selectedHistoryFilter == 'Custom';
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    if (selectedWeek == 'Custom' && customStartDate != null) {
      fetchUserAnalytics(
          customStartDate: customStartDate, customEndDate: customEndDate);
      startDate = customStartDate;
      endDate = customEndDate;
    } else {
      if (wasCustom) {
        fetchUserAnalytics();
        state = state.copyWith(
          customStartDate: null,
          customEndDate: null,
        );
      } else {
        final match = RegExp(r'^(\d+)W$').firstMatch(selectedWeek);
        if (match != null) {
          final weekNumber = int.parse(match.group(1)!);
          endDate = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: 7 * (weekNumber - 1)));
          startDate = endDate.subtract(const Duration(days: 7));
        }
      }
    }

    state = state.copyWith(
      selectedHistoryFilter: selectedWeek,
      historyDateStartFilter: startDate,
      historyDateEndFilter: endDate,
    );
  }

  void updateTimeSelection(String selectedTimeRange,
      {DateTime? customStartDate, DateTime? customEndDate}) {
    final bool wasCustom = state.selectedTimeRangeFilter == 'Custom';

    state = state.copyWith(
      selectedTimeRangeFilterGeneral: selectedTimeRange,
      selectedTimeRangeFilter: selectedTimeRange,
      customStartDate: selectedTimeRange == 'Custom' ? customStartDate : null,
      customEndDate: selectedTimeRange == 'Custom' ? customEndDate : null,
    );

    if (selectedTimeRange == 'Custom' &&
        customStartDate != null &&
        customEndDate != null) {
      fetchUserPlotData(
          customStartDate: customStartDate, customEndDate: customEndDate);
    } else {
      if (wasCustom) {
        fetchUserPlotData();
        state = state.copyWith(customStartDate: null, customEndDate: null);
      } else {
        filterPlotData(state.rawPlotMoistureData, state.rawPlotNutrientData);
      }
    }
  }

  void setSelectedPlotId(BuildContext context, plotId) async {
    state = state.copyWith(selectedPlotId: plotId);
    // String warnings = soilDashboardHelper.generatePlotCondition(
    //     state.selectedPlotId, state.nutrientWarnings);

    context.push('/user-plot');
  }

  void setSelectedAnalysisId(BuildContext context, analysisId) {
    state = state.copyWith(selectedAnalysisId: analysisId);
    context.push('/ai-analytics');
  }

  void setPlotId(plotId) {
    state = state.copyWith(selectedPlotId: plotId);
  }

  void setNutrientSensorId(npkSensorId) {}

  void setEditingUserPlot(bool isEditing) {
    state = state.copyWith(isEditingUserPlot: isEditing);
  }

  void setCurrentCardToggled(int plotId, String toggleType) {
    final updatedToggles = Map<int, String>.from(state.plotToggles);
    updatedToggles[plotId] = toggleType;

    state = state.copyWith(plotToggles: updatedToggles);
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
