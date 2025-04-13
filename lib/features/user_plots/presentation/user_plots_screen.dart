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
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_unready_card.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/crop_threshold.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/line_chart.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_condition.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_details.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_suggestions.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_warnings.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/tools_section.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class UserPlotScreen extends ConsumerStatefulWidget {
  const UserPlotScreen({super.key});

  @override
  _UserPlotScreenState createState() => _UserPlotScreenState();
}

class _UserPlotScreenState extends ConsumerState<UserPlotScreen> {
  final FocusNode plotNameFocusNode = FocusNode();
  final TextEditingController plotNameController = TextEditingController();

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
    String aiPrompt = "";

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

    final irrigationLogs = plotHelper.getIrrigationLogs(
        selectedPlot, userPlot.selectedPlotId, plotHelper);

    final aiAnalysisToday = userPlot.aiAnalysis.firstWhere(
      (entry) => entry['plot_id'] == plotId && entry['analysis_date'] == today,
      orElse: () => {},
    );

    if (aiAnalysisToday.isEmpty) {
      final filtered = plotHelper.getFilteredAiReadyData(
        selectedPlotId: userPlot.selectedPlotId,
        rawMoistureData: userPlot.rawPlotMoistureData,
        rawNutrientData: userPlot.rawPlotNutrientData,
      );

      if (filtered != null) {
        aiPrompt = plotHelper.getFormattedAiPrompt(data: filtered);
        aiStatus = 'AI Ready for analysis';
      }
    } else {
      aiStatus = 'AI is generated';
    }

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
                    OutlineCustomButton(
                      buttonText: 'Generate Weekly AI Analysis',
                      onPressed: () {
                        final weeklyData = plotHelper.getWeeklyAiReadyData(
                            selectedPlotId: userPlot.selectedPlotId,
                            rawMoistureData: userPlot.rawPlotMoistureData,
                            rawNutrientData: userPlot.rawPlotNutrientData);
                        if (weeklyData != null) {
                          final aiPrompt = plotHelper.getFormattedWeeklyPrompt(
                              data: weeklyData);
                          NotifierHelper.logMessage('AI Prompt: $aiPrompt');
                        }
                      },
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
                    if (aiStatus == 'AI Ready for analysis')
                      AiReadyCard(
                        onTap: userPlot.isGeneratingAi
                            ? null
                            : () {
                                if (aiPrompt != "") {
                                  userPlotNotifier.fetchAi(aiPrompt, cropType,
                                      soilType, plotName, plotId);
                                }
                              },
                      ),
                    if (aiStatus == 'No generated AI Data yet')
                      AiUnreadyCard(
                        onTap: () {},
                      ),
                    if (aiStatus == 'AI is generated')
                      AiGeneratedCard(
                        onTap: () {
                          context.pushNamed('ai-analytics');
                        },
                      ),
                    PlotWarnings(plotWarningsData: plotWarningsData),
                    PlotSuggestions(plotSuggestions: plotSuggestions),
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
                    PlotDetailsWidget(
                        assignedSensor: assignedMoistureSensor,
                        assignedNutrientSensor: assignedNutrientSensor,
                        soilType: soilType ?? 'No soil type found'),
                    CropThresholdWidget(plotDetails: selectedPlot),
                    const SizedBox(height: 10),
                    if (irrigationLogs.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.water_drop_outlined,
                                    color: Colors.blue, size: 20),
                                const SizedBox(width: 5),
                                const Text(
                                  'Irrigation Log',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                                const Spacer(),
                                TextRoundedEnclose(
                                    text: DateFormat('MMMM d, yyyy')
                                        .format(DateTime.now()),
                                    color: Colors.white,
                                    textColor: Colors.grey[500]!),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ...irrigationLogs.map((log) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Started: ${log['time_started']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!,
                                      ),
                                      const SizedBox(width: 30),
                                      Text(
                                        'Stopped: ${log['time_stopped'] ?? 'Ongoing'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!,
                                      ),
                                    ],
                                  ),
                                  if (irrigationLogs.indexOf(log) !=
                                      irrigationLogs.length - 1)
                                    DividerWidget(
                                        verticalHeight: 1,
                                        color: Colors.grey[300]!),
                                ],
                              );
                            }),
                          ],
                        ),
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
