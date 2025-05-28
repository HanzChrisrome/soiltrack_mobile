import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/controller/user_plot_controller.dart';
import 'package:soiltrack_mobile/features/user_plots/helper/plant_analyzer.dart';
import 'package:soiltrack_mobile/features/user_plots/helper/user_plots_helper.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/polygon_map.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/ai_display_section.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/ai_toggle.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/ai_unready_card.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/custom_toggle_button.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/crop_threshold.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/line_chart.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_condition.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_details.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_suggestions.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_warnings.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/tools_section.dart';
import 'package:soiltrack_mobile/provider/shared_preferences.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
    final plotHelper = UserPlotsHelper();
    final userPlot = ref.watch(soilDashboardProvider);
    final controller =
        UserPlotController(state: userPlot, plotHelper: plotHelper);
    final userPlotNotifier = ref.read(soilDashboardProvider.notifier);
    final isGeneratingAi = userPlot.isGeneratingAi;
    final polygonList = controller.selectedPolygon;

    final selectedPlot = controller.selectedPlot;
    final plotName = controller.plotName;
    final plotId = controller.plotId;
    final soilType = controller.soilType;
    final assignedMoistureSensor = controller.assignedMoistureSensor;
    final assignedNutrientSensor = controller.assignedNutrientSensor;
    final selectedLanguage = LanguagePreferences.getLanguage();

    final aiAnalysisToday = controller.todayAiAnalysis;
    final hasSufficientDailyData = controller.hasSufficientDailyData;
    final hasSufficientWeeklyData = controller.hasSufficientWeeklyData;
    final aiAnalysisWeekly = controller.latestWeeklyAiAnalysis;
    // final plotWarningsData = controller.plotWarnings;
    // final plotSuggestions = controller.plotSuggestions;
    final currentToggle = controller.currentToggle;
    // final aiHistory = controller.aiHistory;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onRefresh: () async {
          await userPlotNotifier.fetchUserPlotData();
          await userPlotNotifier.fetchIrrigationLogs();
        },
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildSilverAppBar(context, plotName, selectedPlot,
                    userPlotNotifier, polygonList),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // CustomToggleButton(
                      //   options: ['en', 'tl'],
                      //   selectedOption: selectedLanguage,
                      //   onChanged: (lang) {
                      //     userPlotNotifier.setSelectedLanguage(lang);
                      //   },
                      // ),
                      // SizedBox(height: 12),
                      PlotCondition(
                        plotName: plotName,
                      ),
                      ToolsSectionWidget(
                        assignedSensor: assignedNutrientSensor,
                        plotName: plotName,
                        plotNameController: plotNameController,
                      ),
                      if (!isGeneratingAi)
                        Column(
                          children: [
                            AiToggle(plotId: plotId),
                            AiDisplaySection(
                              plotId: plotId,
                              hasSufficientDailyData: hasSufficientDailyData,
                              hasSufficientWeeklyData: hasSufficientWeeklyData,
                              aiAnalysisWeekly: aiAnalysisWeekly,
                              aiAnalysisDaily: aiAnalysisToday,
                              onViewAnalysis: () => context.pushNamed(
                                'ai-analysis-detail',
                                pathParameters: {
                                  'analysisId': (currentToggle == 'Daily'
                                          ? aiAnalysisToday['id']
                                          : aiAnalysisWeekly['id'])
                                      .toString(),
                                },
                                queryParameters: {
                                  'lang': selectedLanguage,
                                },
                              ),
                            ),
                          ],
                        ),

                      // if (aiHistory.isNotEmpty)
                      //   OutlineCustomButton(
                      //     buttonText: 'View AI Analysis History',
                      //     iconData: Icons.history,
                      //     onPressed: () {
                      //       context.pushNamed('ai-history');
                      //     },
                      //   ),
                      NutrientProgressChart(),
                      // PlotWarnings(plotWarningsData: plotWarningsData),
                      // PlotSuggestions(plotSuggestions: plotSuggestions),
                      PlotDetailsWidget(
                          assignedSensor: assignedMoistureSensor,
                          assignedNutrientSensor: assignedNutrientSensor,
                          soilType: soilType),
                      CropThresholdWidget(plotDetails: selectedPlot),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSilverAppBar(
      BuildContext context,
      String plotName,
      Map<String, dynamic> selectedPlot,
      SoilDashboardNotifier userPlotNotifier,
      List<LatLng> polygonList) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.green),
        ),
        onPressed: () {
          context.pop();
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
      expandedHeight: polygonList.isNotEmpty ? 200 : 0,
      flexibleSpace: polygonList.isNotEmpty
          ? FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PolygonMap(polygonPoints: polygonList),
                ),
              ),
            )
          : null,
    );
  }
}
