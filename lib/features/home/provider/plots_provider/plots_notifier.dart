import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/home/helper/soilDashboardHelper.dart';
import 'package:soiltrack_mobile/features/home/service/soil_dashboard_service.dart';

part 'plots_notifier.freezed.dart';

@freezed
class PlotsState with _$PlotsState {
  factory PlotsState({
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
    @Default({}) Map<int, String> plotConditions,
    @Default({}) Map<int, String> plotToggles,
    @Default(false) bool isFetchingUserPlots,
    @Default(false) bool isFetchingUserPlotData,
    @Default(false) bool isFetchingHistoryData,
    @Default(0) int selectedPlotId,
    @Default(0) int selectedPlotHistoryId,
    @Default(0) int loadedPlotId,
    @Default("1D") String selectedTimeRangeFilter,
    @Default("1D") String selectedTimeRangeFilterGeneral,
    @Default("1W") String selectedHistoryFilter,
    @Default("en") String selectedLanguage,
    DateTime? customStartDate,
    DateTime? customEndDate,
    DateTime? lastReadingTime,
    String? overallCondition,
  }) = _PlotsState;
}

class PlotsNotifier extends Notifier<PlotsState> {
  late final SoilDashboardService service;
  late final SoilDashboardHelper helper;
  late final userId;

  @override
  PlotsState build() {
    service = SoilDashboardService();
    helper = SoilDashboardHelper();
    userId = ref.watch(authProvider).userId ?? '';
    return PlotsState();
  }

  Future<void> fetchUserPlots() async {
    if (state.isFetchingUserPlots) return;
    state = state.copyWith(isFetchingUserPlots: true);

    try {
      if (userId.isEmpty) {
        NotifierHelper.logError('User ID is empty');
        return;
      }
      final userPlots = await service.userPlots(userId);
      state = state.copyWith(userPlots: userPlots);
    } catch (e) {
      NotifierHelper.logError('Error fetching user plots: $e');
    } finally {
      state = state.copyWith(isFetchingUserPlots: false);
    }
  }

  Future<void> fetchUserPlotData(
      {DateTime? customStartDate, DateTime? customEndDate}) async {
    if (state.isFetchingUserPlotData) return;
    state = state.copyWith(isFetchingUserPlotData: true);

    try {
      final List<String> plotIds =
          state.userPlots.map((plot) => plot['id'].toString()).toList();

      if (plotIds.isEmpty) {
        NotifierHelper.logError('No plot IDs found for the user');
        return;
      }

      final DateTime startDate =
          customStartDate ?? DateTime.now().subtract(const Duration(days: 90));
      final DateTime endDate = customEndDate ?? DateTime.now();

      final results = await Future.wait([
        service.userPlotMoistureData(plotIds, startDate, endDate),
        service.userPlotNutrientData(plotIds, startDate, endDate),
      ]);

      final rawMoistureData = results[0];
      final rawNutrientData = results[1];

      if (state.selectedTimeRangeFilter != 'Custom') {
        state = state.copyWith(
          rawPlotMoistureData: rawMoistureData,
          rawPlotNutrientData: rawNutrientData,
        );
      }
    } catch (e) {
      NotifierHelper.logError('Error fetching user plot data: $e');
    } finally {
      state = state.copyWith(isFetchingUserPlotData: false);
    }
  }

  Future<void> fetchLatestData() async {
    try {
      final List<String> plotIds =
          state.userPlots.map((plot) => plot['id'].toString()).toList();

      if (plotIds.isEmpty) {
        NotifierHelper.logError('No plot IDs found for the user');
        return;
      }

      final data = await Future.wait([
        service.fetchLatestMoistureReadings(plotIds),
        service.fetchLatestNutrientsReadings(plotIds),
      ]);

      final latestMoistureData = data[0];
      final latestNutrientData = data[1];

      DateTime? latestMoistureTimestamp =
          helper.getLatestTimestamp(latestMoistureData);
      DateTime? latestNutrientTimestamp =
          helper.getLatestTimestamp(latestNutrientData);

      DateTime? latestReadingDate;
      if (latestMoistureTimestamp != null && latestNutrientTimestamp != null) {
        latestReadingDate =
            latestMoistureTimestamp.isAfter(latestNutrientTimestamp)
                ? latestMoistureTimestamp
                : latestNutrientTimestamp;
      } else {
        latestReadingDate = latestMoistureTimestamp ?? latestNutrientTimestamp;
      }

      final messages = service.generateNutrientWarnings(
          state.userPlots, latestMoistureData, latestNutrientData);

      final nutrientWarnings =
          helper.extractMessagesByType(messages, 'Warning');

      final plotsSuggestions =
          helper.extractMessagesByType(messages, 'Suggestion');
      final deviceWarnings =
          helper.extractMessagesByType(messages, 'Device Warning');

      Map<int, String> plotConditions = {};
      for (var plot in state.userPlots) {
        int plotId = plot['plot_id'];
        plotConditions[plotId] =
            helper.generatePlotCondition(plotId, nutrientWarnings);
      }

      final summary = helper.generateOverallCondition(
          nutrientWarnings, state.userPlots.length);

      state = state.copyWith(
        latestPlotMoistureData: latestMoistureData,
        latestPlotNutrientData: latestNutrientData,
        overallCondition: summary,
        plotConditions: plotConditions,
        lastReadingTime: latestReadingDate,
        nutrientWarnings: nutrientWarnings,
        plotsSuggestion: plotsSuggestions,
        deviceWarnings: deviceWarnings,
      );
    } catch (e) {
      NotifierHelper.logError('Error fetching latest data: $e');
    }
  }

  Future<void> filterPlotData() async {
    DateTime startDate =
        helper.getStartDateFromTimeRange(state.selectedTimeRangeFilter);

    DateTime endDate =
        DateTime.now().add(Duration(days: 1)).subtract(Duration(seconds: 1));

    if (state.selectedTimeRangeFilter == 'Custom' &&
        state.customStartDate != null &&
        state.customEndDate != null) {
      startDate = state.customStartDate!;
      endDate = state.customEndDate!;
    }

    final String aggregationInterval = state.selectedTimeRangeFilter == 'Custom'
        ? helper.determineAggregationInterval(
            state.selectedTimeRangeFilter, startDate, endDate)
        : state.selectedTimeRangeFilter;

    List<Map<String, dynamic>> filteredMoistureData = state.rawPlotMoistureData;
    List<Map<String, dynamic>> filteredNutrientData = state.rawPlotNutrientData;

    if (state.selectedTimeRangeFilter != 'Custom') {
      filteredMoistureData = state.rawPlotMoistureData.where((reading) {
        DateTime readTime = DateTime.parse(reading['read_time']).toLocal();
        return readTime.isAfter(startDate) && readTime.isBefore(endDate);
      }).toList();

      filteredNutrientData = state.rawPlotNutrientData.where((reading) {
        DateTime readTime = DateTime.parse(reading['read_time']).toLocal();
        return readTime.isAfter(startDate) && readTime.isBefore(endDate);
      }).toList();
    }

    state = state.copyWith(
      userPlotMoistureData: helper.aggregatedDataByInterval(
          filteredMoistureData, aggregationInterval, 'soil_moisture'),
      userPlotNutrientData: helper.aggregatedDataByInterval(
          filteredNutrientData,
          aggregationInterval,
          'readed_nitrogen',
          'readed_phosphorus',
          'readed_potassium'),
      selectedTimeRangeFilter: aggregationInterval,
    );
  }
}
