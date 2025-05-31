import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/home/helper/soilDashboardHelper.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_state.dart';
import 'package:soiltrack_mobile/features/home/service/ai_service.dart';
import 'package:soiltrack_mobile/features/home/service/soil_dashboard_service.dart';
import 'package:soiltrack_mobile/features/home/provider/hardware_provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/controller/user_plot_controller.dart';
import 'package:soiltrack_mobile/features/user_plots/helper/user_plots_helper.dart';
import 'package:soiltrack_mobile/provider/weather_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/dynamic_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SoilDashboardNotifier extends Notifier<SoilDashboardState> {
  final SoilDashboardService soilDashboardService = SoilDashboardService();
  final SoilDashboardHelper soilDashboardHelper = SoilDashboardHelper();
  final AiService aiService = AiService();

  late final RealtimeChannel _moistureChannel;
  late final RealtimeChannel _nutrientChannel;

  bool _listenersInitialized = false;

  @override
  SoilDashboardState build() {
    return SoilDashboardState();
  }

  Future<void> initRealtimeListeners() async {
    await Future.delayed(Duration(seconds: 5));

    NotifierHelper.logMessage('Initializing realtime listeners');

    _moistureChannel = supabase.channel('public:moisture_readings')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'moisture_readings',
        callback: (payload) async {
          NotifierHelper.logMessage('Moisture data updated');

          final ids = state.userPlots
              .map((plot) => plot['plot_id'].toString())
              .toList();

          NotifierHelper.logMessage(
              'Real-time fetch triggered for plot IDs: $ids');

          await fetchLatestData(ids);
        },
      )
      ..subscribe();
  }

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

      await fetchUserPlotData();
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
      await fetchUserAnalytics();
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      state = state.copyWith(isFetchingUserPlotData: false);
    }
  }

  Future<void> fetchLatestData(List<String> plotIds) async {
    NotifierHelper.logMessage('Fetching latest data for plots: $plotIds');

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

  Future<void> fetchUserAnalytics(
      {DateTime? customStartDate, DateTime? customEndDate}) async {
    state = state.copyWith(isFetchingHistoryData: true);
    final userId = ref.watch(authProvider).userId;

    try {
      final List<String> plotIds =
          state.userPlots.map((plot) => plot['plot_id'].toString()).toList();

      final DateTime startDate =
          customStartDate ?? DateTime.now().subtract(const Duration(days: 90));

      final DateTime endDate = customEndDate ??
          DateTime.now().add(Duration(days: 1)).subtract(Duration(seconds: 1));

      final results = await Future.wait([
        soilDashboardService.fetchLatestAiAnalyses(plotIds, startDate, endDate),
        soilDashboardService.fetchSummaryAnalysis(userId!),
      ]);
      final aiAnalysis = results[0];
      final summaryAnalysis = results[1];

      if (state.selectedHistoryFilter != 'Custom') {
        state = state.copyWith(
            aiAnalysis: aiAnalysis,
            aiSummaryHistory: summaryAnalysis,
            filteredAnalysis: aiAnalysis);
      } else {
        state = state.copyWith(
          filteredAnalysis: aiAnalysis,
        );
      }
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      state = state.copyWith(isFetchingHistoryData: false);
    }
  }

  Future<void> fetchIrrigationLogs(
      {DateTime? customStartDate, DateTime? customEndDate}) async {
    try {
      final List<String> plotIds =
          state.userPlots.map((plot) => plot['plot_id'].toString()).toList();

      final DateTime startDate =
          customStartDate ?? DateTime.now().subtract(const Duration(days: 90));

      final DateTime endDate = customEndDate ??
          DateTime.now().add(Duration(days: 1)).subtract(Duration(seconds: 1));

      final results = await soilDashboardService.fetchIrrigationLogs(
          plotIds, startDate, endDate);

      state = state.copyWith(
        irrigationLogs: results,
      );
    } catch (e) {
      NotifierHelper.logError(e);
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

  Future<void> generateDailyAnalysis() async {
    if (state.isGeneratingAi) return;
    state = state.copyWith(isGeneratingAi: true);

    final plotHelper = UserPlotsHelper();
    final rawMoistureData = state.rawPlotMoistureData;
    final rawNutrientData = state.rawPlotNutrientData;
    final weatherReport =
        ref.read(weatherProvider).weatherReport ?? 'No report';
    final userId = ref.read(authProvider).userId;
    final languages = ['en', 'tl'];

    final DateTime todayDate = DateTime.now().toLocal();
    final String todayString = DateFormat('yyyy-MM-dd').format(todayDate);

    try {
      for (final plot in state.userPlots) {
        final plotId = plot['plot_id'];
        final cropType = plot['user_crops']?['crop_name'] ?? 'No crop assigned';
        final soilType = plot['soil_type'] ?? 'No soil type';
        final plotName = plot['plot_name'] ?? 'No plot name';

        final plotHasTodayAnalysis = state.aiAnalysis.any((entry) =>
            entry['analysis_date'] == todayString &&
            entry['analysis_type'] == 'Daily' &&
            state.userPlots.any((plot) => plot['plot_id'] == entry['plot_id']));

        if (plotHasTodayAnalysis) {
          NotifierHelper.logMessage(
              'Daily AI analysis already exists for plot $plotId.');
          continue;
        }

        // Get the filtered data for this plot
        final filtered = plotHelper.getFilteredAiReadyData(
          selectedPlotId: plotId,
          rawMoistureData: rawMoistureData,
          rawNutrientData: rawNutrientData,
        );

        if (filtered != null) {
          NotifierHelper.logMessage('Daily Analysis for plot $plotId is ready');

          final aiFormattedPrompt =
              plotHelper.getFormattedAiPrompt(data: filtered);

          for (final lang in languages) {
            final forPrompting = aiService.generateAIAnalysisPrompt(
              aiFormattedPrompt,
              cropType,
              soilType,
              plotName,
              weatherReport,
              language: lang,
            );

            final aiResponse =
                await aiService.getAiAnalysis(forPrompting, language: lang);

            final aiRaw = aiResponse['choices'][0]['message']['content'];
            final parsedJson = soilDashboardHelper.extractCleanAIJson(aiRaw);

            final newAnalysis = {
              "plot_id": plotId,
              "analysis_date": todayString,
              "analysis": parsedJson,
              "analysis_type": 'Daily',
              "language_type": lang,
            };

            await supabase.from('ai_analysis').insert(newAnalysis);
          }
        } else {
          NotifierHelper.logMessage(
              'No valid moisture or nutrient data for plot $plotId');
        }
      }

      final todaySummaries = state.aiSummaryHistory.where((entry) {
        final analysisDate = DateTime.parse(entry['analysis_date']).toLocal();
        return analysisDate.year == todayDate.year &&
            analysisDate.month == todayDate.month &&
            analysisDate.day == todayDate.day;
      }).toList();

      if (todaySummaries.isNotEmpty) {
        NotifierHelper.logMessage(
            'AI Summary for today already exists in memory. Skipping generation.');
        return;
      }

      final validPlotIds = {
        ...rawMoistureData.map((data) => data['plot_id']),
        ...rawNutrientData.map((data) => data['plot_id']),
      };

      final threeDaysAgo = todayDate.subtract(const Duration(days: 3));
      final plotsWithRecentData = rawMoistureData
          .where((data) {
            final readTime = DateTime.parse(data['read_time']).toLocal();
            return readTime.isAfter(threeDaysAgo);
          })
          .map((data) => data['plot_id'])
          .toSet();

      final validPlotIdsWithRecentData =
          validPlotIds.intersection(plotsWithRecentData);

      final Map<int, Map<String, dynamic>> plotMetadata = {};
      for (var plot in state.userPlots) {
        final int plotId = plot['plot_id'];
        if (!validPlotIdsWithRecentData.contains(plotId)) continue;

        final crop = plot['user_crops']?['crop_name'] ?? 'No crop assigned';
        final soil = plot['soil_type'] ?? 'No soil type';
        final plotName = plot['plot_name'] ?? 'No plot name';

        plotMetadata[plotId] = {
          'crop': crop,
          'soil': soil,
          'plotName': plotName,
        };
      }

      final forSummary = plotHelper.getDataForSummary(
        rawMoistureData: rawMoistureData,
        rawNutrientData: rawNutrientData,
      );

      if (forSummary != null) {
        NotifierHelper.logMessage('AI Summary data is ready');

        final aiSummaryPrompt = plotHelper.getFormattedSummaryPrompt(
          data: forSummary,
          plotMetadata: plotMetadata,
        );

        final aiSummaryPromptFinal =
            aiService.generateAISummaryPrompt(aiSummaryPrompt, weatherReport);

        final aiAnalysis = await aiService.getAiAnalysis(aiSummaryPromptFinal);
        final aiSummaryRaw = aiAnalysis['choices'][0]['message']['content'];
        final parsedSummary =
            soilDashboardHelper.extractCleanAIJson(aiSummaryRaw);

        await supabase.from('ai_summary').insert({
          "user_id": userId,
          "analysis_date": todayString,
          "summary_analysis": parsedSummary,
          "summary_type": 'Daily',
        });
      }

      fetchUserAnalytics();
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      state = state.copyWith(isGeneratingAi: false);
    }
  }

  Future<void> generateWeeklyAnalysis() async {
    if (state.isGeneratingAi) return;
    state = state.copyWith(isGeneratingAi: true);

    final plotHelper = UserPlotsHelper();
    final rawMoistureData = state.rawPlotMoistureData;
    final rawNutrientData = state.rawPlotNutrientData;
    final weatherReport =
        ref.read(weatherProvider).weatherReport ?? 'No report';
    final languages = ['en', 'tl'];

    try {
      final now = DateTime.now();
      final weekEnd = DateTime(now.year, now.month, now.day); // Today
      final weekStart = weekEnd.subtract(const Duration(days: 6));

      for (final plot in state.userPlots) {
        final plotId = plot['plot_id'];
        final cropType = plot['user_crops']?['crop_name'] ?? 'No crop assigned';
        final soilType = plot['soil_type'] ?? 'No soil type';
        final plotName = plot['plot_name'] ?? 'No plot name';

        final plotHasWeeklyAnalysis = state.aiAnalysis.any((entry) {
          final entryDate = DateTime.parse(entry['analysis_date']);
          return entry['analysis_type'] == 'Weekly' &&
              entry['plot_id'] == plotId &&
              !entryDate.isBefore(weekStart) &&
              !entryDate.isAfter(weekEnd);
        });

        if (plotHasWeeklyAnalysis) {
          NotifierHelper.logMessage(
              'Weekly AI analysis already exists for plot $plotId.');
          continue;
        }

        final filtered = plotHelper.getFilteredAiReadyWeeklyData(
            selectedPlotId: plotId,
            rawMoistureData: rawMoistureData,
            rawNutrientData: rawNutrientData);

        if (filtered != null) {
          NotifierHelper.logMessage(
              'Weekly Analysis for plot $plotId is ready');

          final aiFormattedPrompt =
              plotHelper.getFormattedAiWeeklyPrompt(data: filtered);

          for (final lang in languages) {
            final forPrompting = aiService.generateWeeklyAIAnalysisPrompt(
                aiFormattedPrompt, cropType, soilType, plotName, weatherReport,
                language: lang);

            // Continue with AI analysis
            // final aiResponse = await aiService.getAiAnalysis(forPrompting);

            // final aiRaw = aiResponse['choices'][0]['message']['content'];
            // final parsedJson = soilDashboardHelper.extractCleanAIJson(aiRaw);
            // final today = DateTime.now().toIso8601String().split('T').first;

            // final newAnalysis = {
            //   "plot_id": plotId,
            //   "analysis_date": today,
            //   "analysis": parsedJson,
            //   "analysis_type": 'Weekly',
            //   "language_type": lang,
            // };

            // await supabase.from('ai_analysis').insert(newAnalysis);
          }
        } else {
          NotifierHelper.logMessage(
              'No valid moisture or nutrient weekly data for plot $plotId');
        }
      }

      fetchUserAnalytics();
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      state = state.copyWith(isGeneratingAi: false);
    }
  }

  Future<void> askSoilType(BuildContext context) async {
    try {
      final cropNotifier = ref.read(cropProvider.notifier);
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image == null) {
        NotifierHelper.logMessage('No image selected');
        return;
      }

      NotifierHelper.showLoadingToast(context, 'Analyzing image.');
      final soilResult = await aiService.analyzeSoil(context, image);
      final parsedResult = soilDashboardHelper.extractCleanAIJson(soilResult);

      final isAboutSoil =
          (parsedResult['is_about_soil']?.toLowerCase() == 'yes');

      NotifierHelper.closeToast(context);
      showCustomizableBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: false,
        centerContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isAboutSoil
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextGradient(
                        text: 'Confirm and assign your soil type.',
                        fontSize: 35,
                        heightSpacing: 1,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your soil type is ${parsedResult['soil_type']}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 20,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Explanation: ${parsedResult['explanation']}',
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextGradient(
                        text: 'Error in analyzing soil type.',
                        fontSize: 35,
                        heightSpacing: 1,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'The image you provided does not contain soil, and we cannot analyze it as soil type.',
                      ),
                    ],
                  ),
          ],
        ),
        showActionButton: isAboutSoil ? true : false,
        buttonText: 'Assign',
        onCancelPressed: (bottomSheetContext) {
          Navigator.of(bottomSheetContext).pop();
        },
        onPressed: (bottomSheetContext) {
          Navigator.of(bottomSheetContext).pop();
          cropNotifier.setSoilType(parsedResult['soil_type'], context);
        },
      );
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  Future<void> uploadPolygon(BuildContext context, List<LatLng> points) async {
    NotifierHelper.showLoadingToast(context, 'Uploading polygon.');

    try {
      final coordinates = soilDashboardHelper.polygonToSimpleJson(points);
      final center = soilDashboardHelper.calculateCentroid(points);

      final address = await soilDashboardService.reverseGeocode(
          center.latitude, center.longitude);

      NotifierHelper.logMessage('Polygon address: $address');

      await supabase.from('user_plots').update({
        'polygons': coordinates,
        'plot_address': address,
      }).eq('plot_id', state.selectedPlotId);
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      NotifierHelper.closeToast(context);
    }
  }

  Future<void> saveDeviceToken(String token) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from("users").upsert({
      'user_id': userId,
      'device_token': token,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
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
    NotifierHelper.logMessage('Selected plot id: $plotId');
    state = state.copyWith(selectedPlotId: plotId);
  }

  void setNutrientSensorId(npkSensorId) {
    NotifierHelper.logMessage('Selected NPK sensor id: $npkSensorId');
  }

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

final soilDashboardProvider =
    NotifierProvider<SoilDashboardNotifier, SoilDashboardState>(
        () => SoilDashboardNotifier());
