import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/helper/user_plots_helper.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_generated.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_ready_card.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_toggle.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_unready_card.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/crop_threshold.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/line_chart.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_condition.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_details.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_suggestions.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_warnings.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/tools_section.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class UserPlotScreen extends ConsumerStatefulWidget {
  const UserPlotScreen({super.key});

  @override
  _UserPlotScreenState createState() => _UserPlotScreenState();
}

class _UserPlotScreenState extends ConsumerState<UserPlotScreen> {
  final FocusNode plotNameFocusNode = FocusNode();
  final TextEditingController plotNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final soilDashboard = ref.read(soilDashboardProvider.notifier);
      final soilDashboardState = ref.watch(soilDashboardProvider);
      if (soilDashboardState.irrigationLogs.isEmpty) {
        soilDashboard.fetchIrrigationLogs();
      }
    });
  }

  @override
  void dispose() {
    plotNameController.dispose();
    plotNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserPlotsHelper plotHelper = UserPlotsHelper();
    final userPlot = ref.watch(soilDashboardProvider);
    final userPlotNotifier = ref.read(soilDashboardProvider.notifier);
    final deviceState = ref.watch(deviceProvider);
    final deviceStateNotifier = ref.read(deviceProvider.notifier);
    final today = DateTime.now().toIso8601String().split('T').first;
    String aiStatus = 'No generated AI Data yet';
    String dailyAiPrompt = "";
    String weeklyAiPrompt = "";

    final selectedPlot = userPlot.userPlots.firstWhere(
      (plot) => plot['plot_id'] == userPlot.selectedPlotId,
      orElse: () => {},
    );

    final plotName = selectedPlot['plot_name'] ?? 'No plot found';
    final plotId = selectedPlot['plot_id'] ?? 0;
    final sensors = selectedPlot['user_plot_sensors'] ?? [];
    final soilType = selectedPlot['soil_type'] ?? null;
    final cropType = selectedPlot['user_crops']?['crop_name'] ?? null;

    final assignedMoistureSensor =
        plotHelper.getSensorName(sensors, 'Moisture Sensor');
    final assignedNutrientSensor =
        plotHelper.getSensorName(sensors, 'NPK Sensor');

    final plotWarningsData = userPlot.nutrientWarnings.firstWhere(
      (warning) => warning['plot_id'] == userPlot.selectedPlotId,
      orElse: () => {},
    );

    final plotSuggestions = userPlot.plotsSuggestion.firstWhere(
        (s) => s['plot_id'] == userPlot.selectedPlotId,
        orElse: () => {});

    final aiAnalysisToday = userPlot.aiAnalysis.firstWhere(
      (entry) =>
          entry['plot_id'] == plotId &&
          entry['analysis_date'] == today &&
          entry['analysis_type'] == 'Daily',
      orElse: () => {},
    );

    //FOR DAILY
    if (aiAnalysisToday.isEmpty) {
      final filtered = plotHelper.getFilteredAiReadyData(
        selectedPlotId: userPlot.selectedPlotId,
        rawMoistureData: userPlot.rawPlotMoistureData,
        rawNutrientData: userPlot.rawPlotNutrientData,
      );

      if (filtered != null) {
        dailyAiPrompt = plotHelper.getFormattedAiPrompt(data: filtered);
        aiStatus = 'AI Ready for analysis';
      }
    } else {
      aiStatus = 'AI is generated';
    }

    // FOR WEEKLY
    final startOfWeek = DateTime.now().subtract(Duration(days: 7));

    Set<String> moistureDataDays = Set();
    Set<String> nutrientDataDays = Set();

    for (var data in userPlot.rawPlotMoistureData) {
      final dataDate = DateTime.parse(data['read_time']);
      if (data['plot_id'] == plotId &&
          dataDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
          dataDate.isBefore(DateTime.now())) {
        moistureDataDays.add(DateFormat('yyyy-MM-dd').format(dataDate));
      }
    }

    for (var data in userPlot.rawPlotNutrientData) {
      final dataDate = DateTime.parse(data['read_time']);
      if (data['plot_id'] == plotId &&
          dataDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
          dataDate.isBefore(DateTime.now())) {
        nutrientDataDays.add(DateFormat('yyyy-MM-dd').format(dataDate));
      }
    }

    bool hasSufficientData =
        (moistureDataDays.length >= 7 || nutrientDataDays.length >= 7);

    if (hasSufficientData) {
      final filtered = plotHelper.getWeeklyAiReadyData(
        selectedPlotId: plotId,
        rawMoistureData: userPlot.rawPlotMoistureData,
        rawNutrientData: userPlot.rawPlotNutrientData,
      );

      weeklyAiPrompt = plotHelper.getFormattedWeeklyPrompt(data: filtered!);
    }

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 7));

    final weeklyAnalyses = userPlot.aiAnalysis.where((entry) {
      final entryDate = DateTime.parse(entry['analysis_date']);
      return entry['plot_id'] == plotId &&
          entry['analysis_type'] == 'Weekly' &&
          entryDate.isAfter(sevenDaysAgo) &&
          entryDate.isBefore(now);
    }).toList();

    weeklyAnalyses.sort((a, b) => DateTime.parse(b['analysis_date'])
        .compareTo(DateTime.parse(a['analysis_date'])));

    final aiAnalysisWeekly =
        weeklyAnalyses.isNotEmpty ? weeklyAnalyses.first : {};

    final currentToggle = userPlot.plotToggles[plotId] ?? 'Daily';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSilverAppBar(
                  context, plotName, selectedPlot, userPlotNotifier),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    PlotCondition(
                      plotName: plotName,
                    ),
                    ToolsSectionWidget(
                      assignedSensor: assignedNutrientSensor,
                      plotName: plotName,
                      plotNameController: plotNameController,
                    ),
                    if (deviceState.isPumpOpen)
                      GestureDetector(
                        onTap: () {
                          deviceStateNotifier.closeAll(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 30),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child:
                                Text('Pump is currently open, close the pump?'),
                          ),
                        ),
                      ),
                    AiToggle(plotId: plotId),
                    _showAiDisplay(
                      context: context,
                      aiStatus: aiStatus,
                      plotId: plotId,
                      hasSufficientData: hasSufficientData,
                      aiAnalysisWeekly: aiAnalysisWeekly,
                      onGenerateTap: userPlot.isGeneratingAi
                          ? null
                          : () {
                              if (currentToggle == 'Daily') {
                                if (dailyAiPrompt.isNotEmpty) {
                                  userPlotNotifier.fetchAi(dailyAiPrompt,
                                      cropType, soilType, plotName, plotId);
                                }
                              } else if (currentToggle == 'Weekly') {
                                if (weeklyAiPrompt.isNotEmpty) {
                                  userPlotNotifier.fetchWeeklyAnalysis(
                                      weeklyAiPrompt,
                                      cropType,
                                      soilType,
                                      plotName,
                                      plotId);
                                }
                              }
                            },
                      onViewAnalysis: () => context.pushNamed(
                          'ai-analysis-detail',
                          pathParameters: currentToggle == 'Daily'
                              ? {'analysisId': aiAnalysisToday['id'].toString()}
                              : {
                                  'analysisId':
                                      aiAnalysisWeekly['id'].toString()
                                }),
                    ),
                    if (aiAnalysisToday.isEmpty && aiAnalysisWeekly.isEmpty)
                      OutlineCustomButton(
                        buttonText: 'View AI Analysis History',
                        iconData: Icons.history,
                        onPressed: () {
                          context.pushNamed('ai-history');
                        },
                      ),
                    Column(
                      children: [
                        NutrientProgressChart(),
                        FilledCustomButton(
                          buttonText: 'View Statistics',
                          icon: Icons.remove_red_eye_outlined,
                          onPressed: () {
                            context.pushNamed('plot-analytics');
                          },
                        ),
                      ],
                    ),
                    PlotWarnings(plotWarningsData: plotWarningsData),
                    PlotSuggestions(plotSuggestions: plotSuggestions),
                    PlotDetailsWidget(
                        assignedSensor: assignedMoistureSensor,
                        assignedNutrientSensor: assignedNutrientSensor,
                        soilType: soilType ?? 'No soil type found'),
                    CropThresholdWidget(plotDetails: selectedPlot),
                    OutlineCustomButton(
                      buttonText: 'View Irrigation Logs',
                      iconData: Icons.history,
                      onPressed: () {
                        context.pushNamed('irrigation-logs');
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _showAiDisplay({
    required BuildContext context,
    required String aiStatus,
    required int plotId,
    required bool hasSufficientData,
    required Map<dynamic, dynamic> aiAnalysisWeekly,
    VoidCallback? onGenerateTap,
    VoidCallback? onViewAnalysis,
  }) {
    final currentToggle =
        ref.watch(soilDashboardProvider).plotToggles[plotId] ?? 'Daily';

    NotifierHelper.logMessage('Current Toggle: $currentToggle');
    if (currentToggle == 'Weekly') {
      if (aiAnalysisWeekly.isEmpty) {
        if (hasSufficientData) {
          return AiReadyCard(
            onTap: onGenerateTap ?? () {},
            currentToggle: currentToggle,
          );
        } else {
          return const AiUnreadyCard();
        }
      } else {
        return AiGeneratedCard(
          onTap: onViewAnalysis ?? () {},
          currentToggle: currentToggle,
        );
      }
    } else if (currentToggle == 'Daily') {
      if (aiStatus == 'AI Ready for analysis') {
        return AiReadyCard(
          onTap: onGenerateTap ?? () {},
          currentToggle: currentToggle,
        );
      } else if (aiStatus == 'AI is generated') {
        return AiGeneratedCard(
          onTap: onViewAnalysis ?? () {},
          currentToggle: currentToggle,
        );
      } else {
        return const AiUnreadyCard();
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildSilverAppBar(
      BuildContext context,
      String plotName,
      Map<String, dynamic> selectedPlot,
      SoilDashboardNotifier userPlotNotifier) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.green),
        ),
        onPressed: () {
          context.go('/home?index=1');
        },
      ),
      pinned: true,
      title: Container(
        padding: const EdgeInsets.only(bottom: 5),
        child: TextGradient(
          text: plotName,
          fontSize: 20,
        ),
      ),
    );
  }
}
