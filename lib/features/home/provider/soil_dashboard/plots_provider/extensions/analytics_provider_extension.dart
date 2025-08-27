// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
part of '../soil_dashboard_provider.dart';

extension AnalyticsProviderExtension on SoilDashboardNotifier {
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

  Future<void> generateDailyAnalysis() async {
    state = state.copyWith(isGeneratingAi: true);

    final plotHelper = UserPlotsHelper();
    final rawMoistureData = state.rawPlotMoistureData;
    final rawNutrientData = state.rawPlotNutrientData;
    final weatherReport =
        ref.read(weatherProvider).weatherReport ?? 'No report';
    final userId = ref.read(authProvider).userId;

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
          continue;
        }

        final filtered = plotHelper.getFilteredAiReadyData(
          selectedPlotId: plotId,
          rawMoistureData: rawMoistureData,
          rawNutrientData: rawNutrientData,
        );

        if (filtered != null) {
          final aiFormattedPrompt =
              plotHelper.getFormattedAiPrompt(data: filtered);

          final forPrompting = aiService.generateAIAnalysisPrompt(
            aiFormattedPrompt,
            cropType,
            soilType,
            plotName,
            weatherReport,
            language: 'en',
          );

          final aiResponse =
              await aiService.getAiAnalysis(forPrompting, language: 'en');

          final aiRaw = aiResponse['choices'][0]['message']['content'];
          final parsedJson = soilDashboardHelper.extractCleanAIJson(aiRaw);

          final newAnalysis = {
            "plot_id": plotId,
            "analysis_date": todayString,
            "analysis": parsedJson,
            "analysis_type": 'Daily',
            "language_type": 'en',
          };

          await supabase.from('ai_analysis').insert(newAnalysis);

          final tagalogPrompt = aiService.translateJsonToTagalog(parsedJson);
          final tagalogResponse =
              await aiService.getGeminiAnalysis(tagalogPrompt);
          final tagalogRaw =
              tagalogResponse['choices'][0]['message']['content'];
          final tagalogParsedJson =
              soilDashboardHelper.extractCleanAIJson(tagalogRaw);

          final tagalogAnalysis = {
            "plot_id": plotId,
            "analysis_date": todayString,
            "analysis": tagalogParsedJson,
            "analysis_type": 'Daily',
            "language_type": 'tl',
          };

          await supabase.from('ai_analysis').insert(tagalogAnalysis);
          NotifierHelper.logMessage(
              'AI Analysis data is ready for plot $plotId for daily analysis');
        } else {
          NotifierHelper.logMessage(
              'No data available for plot $plotId for daily analysis');
        }
      }

      final todaySummaries = state.aiSummaryHistory.where((entry) {
        final analysisDate = DateTime.parse(entry['analysis_date']).toLocal();
        return analysisDate.year == todayDate.year &&
            analysisDate.month == todayDate.month &&
            analysisDate.day == todayDate.day;
      }).toList();

      if (todaySummaries.isNotEmpty) {
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

      // if (forSummary != null) {
      //   NotifierHelper.logMessage('AI Summary data is ready');

      //   final aiSummaryPrompt = plotHelper.getFormattedSummaryPrompt(
      //     data: forSummary,
      //     plotMetadata: plotMetadata,
      //   );

      //   final aiSummaryPromptFinal =
      //       aiService.generateAISummaryPrompt(aiSummaryPrompt, weatherReport);

      //   final aiAnalysis = await aiService.getAiAnalysis(aiSummaryPromptFinal);
      //   final aiSummaryRaw = aiAnalysis['choices'][0]['message']['content'];
      //   final parsedSummary =
      //       soilDashboardHelper.extractCleanAIJson(aiSummaryRaw);

      //   await supabase.from('ai_summary').insert({
      //     "user_id": userId,
      //     "analysis_date": todayString,
      //     "summary_analysis": parsedSummary,
      //     "summary_type": 'Daily',
      //   });
      // }
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      fetchUserPlots();
      fetchUserAnalytics();
      state = state.copyWith(isGeneratingAi: false);
    }
  }

  Future<void> generateWeeklyAnalysis() async {
    state = state.copyWith(isGeneratingAi: true);

    final plotHelper = UserPlotsHelper();
    final rawMoistureData = state.rawPlotMoistureData;
    final rawNutrientData = state.rawPlotNutrientData;
    final weatherReport =
        ref.read(weatherProvider).weatherReport ?? 'No report';

    try {
      final now = DateTime.now();
      final weekEnd = DateTime(now.year, now.month, now.day);
      final weekStart = weekEnd.subtract(const Duration(days: 6));

      for (final plot in state.userPlots) {
        final plotId = plot['plot_id'];
        final cropType = plot['user_crops']?['crop_name'] ?? 'No crop assigned';
        final soilType = plot['soil_type'] ?? 'No soil type';
        final plotName = plot['plot_name'] ?? 'No plot name';

        final weeklyAnalyses = state.aiAnalysis.where((entry) {
          final entryDate = DateTime.parse(entry['analysis_date']);
          return entry['analysis_type'] == 'Weekly' &&
              entry['plot_id'] == plotId &&
              !entryDate.isBefore(weekStart) &&
              !entryDate.isAfter(weekEnd);
        }).toList();

        final hasEnglish =
            weeklyAnalyses.any((entry) => entry['language_type'] == 'en');
        final hasTagalog =
            weeklyAnalyses.any((entry) => entry['language_type'] == 'tl');

        if (hasEnglish && hasTagalog) continue;

        final filtered = plotHelper.getFilteredAiReadyWeeklyData(
            selectedPlotId: plotId,
            rawMoistureData: rawMoistureData,
            rawNutrientData: rawNutrientData);

        NotifierHelper.logMessage(
            'Generating weekly analysis for plot $plotId');

        if (filtered != null) {
          final aiFormattedPrompt =
              plotHelper.getFormattedAiWeeklyPrompt(data: filtered);

          final forPrompting = aiService.generateWeeklyAIAnalysisPrompt(
              aiFormattedPrompt, cropType, soilType, plotName, weatherReport,
              language: 'en');

          final aiResponse = await aiService.getAiAnalysis(forPrompting);

          final aiRaw = aiResponse['choices'][0]['message']['content'];
          final parsedJson = soilDashboardHelper.extractCleanAIJson(aiRaw);
          final today = DateTime.now().toIso8601String().split('T').first;

          final newAnalysis = {
            "plot_id": plotId,
            "analysis_date": today,
            "analysis": parsedJson,
            "analysis_type": 'Weekly',
            "language_type": 'en',
          };

          NotifierHelper.logMessage(
              'Generating tagalog analysis for plot $plotId');
          await supabase.from('ai_analysis').insert(newAnalysis);

          final tagalogPrompt = aiService.translateJsonToTagalog(parsedJson);

          final tagalogResponse =
              await aiService.getGeminiAnalysis(tagalogPrompt);
          final tagalogRaw =
              tagalogResponse['choices'][0]['message']['content'];
          final tagalogParsedJson =
              soilDashboardHelper.extractCleanAIJson(tagalogRaw);

          final tagalogAnalysis = {
            "plot_id": plotId,
            "analysis_date": today,
            "analysis": tagalogParsedJson,
            "analysis_type": 'Weekly',
            "language_type": 'tl',
          };

          await supabase.from('ai_analysis').insert(tagalogAnalysis);
        }
      }
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      fetchUserPlots();
      fetchUserAnalytics();
      state = state.copyWith(isGeneratingAi: false);
    }
  }

  Future<void> askSoilType(BuildContext context) async {
    try {
      final cropNotifier = ref.read(cropProvider.notifier);
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image == null) {
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
}
