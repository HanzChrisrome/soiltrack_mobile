// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

part of '../soil_dashboard_provider.dart';

extension PlotsProviderExtension on SoilDashboardNotifier {
  //REAL TIME
  Future<void> initRealtimeListeners() async {
    await Future.delayed(Duration(seconds: 5));

    moistureChannel = supabase.channel('public:moisture_readings')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'moisture_readings',
        callback: (payload) async {
          state.userPlots.map((plot) => plot['plot_id'].toString()).toList();
          await fetchUserPlotData();
        },
      )
      ..subscribe();
  }

  //FETCHING OF DATA
  Future<void> fetchUserPlots() async {
    if (state.isFetchingUserPlots) return;
    state = state.copyWith(isFetchingUserPlots: true);

    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        NotifierHelper.logError('Current user is null during fetchUserPlots');
        return;
      }

      final String userId = supabase.auth.currentUser!.id;
      final userPlots = await soilDashboardService.userPlots(userId);

      state = state.copyWith(
        userPlots: userPlots,
        error: userPlots.isEmpty ? 'No plots found' : null,
      );

      if (!_listenersInitialized) {
        initRealtimeListeners();
        _listenersInitialized = true;
      }
    } catch (e) {
      NotifierHelper.logError(e);
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
          state.userPlots.map((plot) => plot['plot_id'].toString()).toList();

      final DateTime startDate =
          customStartDate ?? DateTime.now().subtract(const Duration(days: 90));
      final DateTime endDate = customEndDate ?? DateTime.now();

      final results = await Future.wait([
        soilDashboardService.userPlotMoistureData(plotIds, startDate, endDate),
        soilDashboardService.userPlotNutrientData(plotIds, startDate, endDate),
      ]);

      final rawMoistureData = results[0];
      final rawNutrientData = results[1];

      if (state.selectedTimeRangeFilter != 'Custom') {
        state = state.copyWith(
          rawPlotMoistureData: rawMoistureData,
          rawPlotNutrientData: rawNutrientData,
        );
      }

      await fetchLatestData(plotIds);
      await filterPlotData(rawMoistureData, rawNutrientData);
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      state = state.copyWith(isFetchingUserPlotData: false);
    }
  }

  Future<void> fetchLatestData(List<String> plotIds) async {
    try {
      final data = await Future.wait([
        soilDashboardService.fetchLatestMoistureReadings(plotIds),
        soilDashboardService.fetchLatestNutrientsReadings(plotIds),
      ]);

      final latestMoistureData = data[0];
      final latestNutrientData = data[1];

      DateTime? latestMoistureTimestamp =
          soilDashboardHelper.getLatestTimestamp(latestMoistureData);
      DateTime? latestNutrientTimestamp =
          soilDashboardHelper.getLatestTimestamp(latestNutrientData);

      DateTime? latestReadingDate;
      if (latestMoistureTimestamp != null && latestNutrientTimestamp != null) {
        latestReadingDate =
            latestMoistureTimestamp.isAfter(latestNutrientTimestamp)
                ? latestMoistureTimestamp
                : latestNutrientTimestamp;
      } else {
        latestReadingDate = latestMoistureTimestamp ?? latestNutrientTimestamp;
      }

      final messages = soilDashboardService.generateNutrientWarnings(
          state.userPlots, latestMoistureData, latestNutrientData);

      final nutrientWarnings =
          soilDashboardHelper.extractMessagesByType(messages, 'Warning');

      Map<int, String> plotConditions = {};
      for (var plot in state.userPlots) {
        int plotId = plot['plot_id'];
        plotConditions[plotId] =
            soilDashboardHelper.generatePlotCondition(plotId, nutrientWarnings);
      }

      final summary = soilDashboardHelper.generateOverallCondition(
          nutrientWarnings, state.userPlots.length);

      state = state.copyWith(
        latestPlotMoistureData: latestMoistureData,
        latestPlotNutrientData: latestNutrientData,
        overallCondition: summary,
        plotConditions: plotConditions,
        lastReadingTime: latestReadingDate,
        nutrientWarnings: nutrientWarnings,
        plotsSuggestion:
            soilDashboardHelper.extractMessagesByType(messages, 'Suggestion'),
        deviceWarnings: soilDashboardHelper.extractMessagesByType(
            messages, 'Device Warning'),
      );
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  Future<void> filterPlotData(List<Map<String, dynamic>> rawPlotMoistureData,
      List<Map<String, dynamic>> rawPlotNutrientData) async {
    DateTime startDate = soilDashboardHelper
        .getStartDateFromTimeRange(state.selectedTimeRangeFilter);

    DateTime endDate =
        DateTime.now().add(Duration(days: 1)).subtract(Duration(seconds: 1));

    if (state.selectedTimeRangeFilter == 'Custom' &&
        state.customStartDate != null &&
        state.customEndDate != null) {
      startDate = state.customStartDate!;
      endDate = state.customEndDate!;
    }

    final String aggregationInterval = state.selectedTimeRangeFilter == 'Custom'
        ? soilDashboardHelper.determineAggregationInterval(
            state.selectedTimeRangeFilter, startDate, endDate)
        : state.selectedTimeRangeFilter;

    List<Map<String, dynamic>> filteredMoistureData = rawPlotMoistureData;
    List<Map<String, dynamic>> filteredNutrientData = rawPlotNutrientData;

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
      userPlotMoistureData: soilDashboardHelper.aggregatedDataByInterval(
          filteredMoistureData, aggregationInterval, 'soil_moisture'),
      userPlotNutrientData: soilDashboardHelper.aggregatedDataByInterval(
          filteredNutrientData,
          aggregationInterval,
          'readed_nitrogen',
          'readed_phosphorus',
          'readed_potassium'),
      selectedTimeRangeFilter: aggregationInterval,
    );
  }

  //UPDATING OF DATA
  Future<void> uploadPolygon(BuildContext context, List<LatLng> points) async {
    NotifierHelper.showLoadingToast(context, 'Uploading polygon.');

    try {
      final coordinates = soilDashboardHelper.polygonToSimpleJson(points);
      final center = soilDashboardHelper.calculateCentroid(points);

      final address = await soilDashboardService.reverseGeocode(
          center.latitude, center.longitude);

      await supabase.from('user_plots').update({
        'polygons': coordinates,
        'plot_address': address,
      }).eq('plot_id', state.selectedPlotId);

      await fetchUserPlots();
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      NotifierHelper.closeToast(context);
    }
  }

  Future<void> saveNewCrop(BuildContext context) async {
    final cropState = ref.watch(cropProvider);
    NotifierHelper.showLoadingToast(context, 'Assigning crop to plot');
    try {
      await soilDashboardService.cropId(cropState.selectedCrop!);

      NotifierHelper.showSuccessToast(context, 'Crop assigned successfully');
      await fetchUserPlots();
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error assigning crop');
    } finally {
      state = state.copyWith(isSavingNewCrop: false);
    }
  }

  Future<void> editPlotName(BuildContext context, String newPlotName) async {
    NotifierHelper.showLoadingToast(context, 'Updating plot name');

    try {
      await soilDashboardService.editPlotName(
          newPlotName, state.selectedPlotId);
      fetchUserPlots();
      NotifierHelper.showSuccessToast(context, 'Plot name updated');
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error updating plot name');
    }
  }

  Future<void> saveNewThreshold(BuildContext context, String thresholdType,
      Map<String, int> updatedValues) async {
    NotifierHelper.showLoadingToast(context, 'Updating threshold');

    try {
      await soilDashboardService.saveNewThreshold(
          state.selectedPlotId, updatedValues);
      await fetchUserPlots();

      NotifierHelper.showSuccessToast(context, 'Threshold updated');
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error updating threshold');
    }
  }

  Future<void> assignNutrientSensor(BuildContext context, selectedNpkId) async {
    NotifierHelper.showLoadingToast(context, 'Assigning NPK sensor');
    final sensorNotifier = ref.read(sensorsProvider.notifier);
    final selectedPlotID = state.selectedPlotId;

    try {
      await supabase.from('user_plot_sensors').insert({
        'plot_id': selectedPlotID,
        'sensor_id': selectedNpkId,
      });

      await supabase.from('soil_sensors').update({
        'is_assigned': true,
      }).eq('sensor_id', selectedNpkId);

      await fetchUserPlots();
      await sensorNotifier.fetchSensors();

      NotifierHelper.showSuccessToast(context, 'NPK sensor assigned');
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error assigning NPK sensor');
    }
  }
}
