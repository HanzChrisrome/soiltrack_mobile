import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/ai_chart.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/grouped_nutrient_bar.dart';
import 'package:soiltrack_mobile/widgets/custom_accordion.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/nutrient_selection.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_header.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

final _localNutrientProvider = StateProvider<String>((ref) => 'M');

class AiAnalysisOverview extends ConsumerWidget {
  final String? analysisId;
  const AiAnalysisOverview({super.key, this.analysisId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(soilDashboardProvider);
    final userPlot = dashboardState.userPlots;
    final selectedPlotId = dashboardState.selectedPlotId;
    final aiAnalysisList = dashboardState.aiAnalysis;
    Map<String, dynamic> selectedAnalysis = {};

    final today = DateTime.now();
    if (analysisId != null) {
      selectedAnalysis = aiAnalysisList.firstWhere(
        (analysis) =>
            analysis['plot_id'] == selectedPlotId &&
            analysis['id'] == int.tryParse(analysisId!),
        orElse: () => {},
      );
    } else {
      selectedAnalysis = aiAnalysisList.firstWhere(
        (analysis) =>
            analysis['plot_id'] == selectedPlotId &&
            DateTime.parse(analysis['analysis_date']).year == today.year &&
            DateTime.parse(analysis['analysis_date']).month == today.month &&
            DateTime.parse(analysis['analysis_date']).day == today.day,
        orElse: () => {},
      );
    }

    final selectedPlot = userPlot.firstWhere(
      (plot) => plot['plot_id'] == selectedPlotId,
      orElse: () => {},
    );

    final plotName = selectedPlot['plot_name'] ?? 'No plot found';

    if (selectedAnalysis.isEmpty) {
      return const Center(
        child: Text("No AI analysis available for this plot today."),
      );
    }

    final analysisDate = DateTime.parse(selectedAnalysis['analysis_date']);
    final formattedDate = DateFormat('MMMM d').format(analysisDate);
    final analysisType = selectedAnalysis['analysis_type'];
    final analysis = selectedAnalysis['analysis']['AI_Analysis'];

    // FOR SUMMARIES
    final dateRange = analysis['date_range'];
    final shortSummary = analysis['short_summary'];
    final summary = analysis['summary'];
    final findings = summary['findings'];
    final predictions = summary['predictions'];
    final recommendations = summary['recommendations'];

    // FOR CHARTS
    final moistureTrends = analysis['summary_of_findings']['moisture_trends'];
    final nutrientTrends = analysis['summary_of_findings']['nutrient_trends'];
    final nitrogenTrend = nutrientTrends['N'];
    final phosphorusTrend = nutrientTrends['P'];
    final potassiumTrend = nutrientTrends['K'];

    final nitrogenCondition = nutrientTrends['N']['condition'];
    final phosphorusCondition = nutrientTrends['P']['condition'];
    final potassiumCondition = nutrientTrends['K']['condition'];

    final selectedNutrient = ref.watch(_localNutrientProvider);
    late Map<String, dynamic> selectedData;
    late String chartLabel;

    switch (selectedNutrient) {
      case 'N':
        selectedData = nitrogenTrend;
        chartLabel = 'Nitrogen';
        break;
      case 'P':
        selectedData = phosphorusTrend;
        chartLabel = 'Phosphorus';
        break;
      case 'K':
        selectedData = potassiumTrend;
        chartLabel = 'Potassium';
        break;
      default:
        selectedData = moistureTrends;
        chartLabel = 'Soil Moisture';
    }

    Map<String, Map<String, double>> groupedData = {};

    for (final date in nitrogenTrend.keys) {
      if (RegExp(r'\d{4}-\d{2}-\d{2}').hasMatch(date)) {
        groupedData[date] = {
          'N': (nitrogenTrend[date] as num).toDouble(),
          'P': (phosphorusTrend[date] as num).toDouble(),
          'K': (potassiumTrend[date] as num).toDouble(),
        };
      }
    }

    // FOR WARNINGS
    final warnings = analysis['warnings'];

    // RECOMMENDED FERTILIZERS
    final recommendedFertilizers =
        analysis['recommended_fertilizers'] as Map<String, dynamic>;
    final nutrientNames = {
      'N': 'Nitrogen',
      'P': 'Phosphorus',
      'K': 'Potassium',
    };

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('assets/background/ai_background.png'),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  pinned: true,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  actions: [
                    // TextButton.icon(
                    //   icon: Icon(Icons.history, color: Colors.green),
                    //   label: Text(
                    //     'History',
                    //     style:
                    //         Theme.of(context).textTheme.titleMedium!.copyWith(
                    //               color: Colors.green,
                    //               fontSize: 16,
                    //               letterSpacing: -0.5,
                    //             ),
                    //   ),
                    //   onPressed: () {
                    //     context.pushNamed('ai-history');
                    //   },
                    // ),
                  ],
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextHeader(
                                        text: analysisType == 'Daily'
                                            ? formattedDate
                                            : dateRange,
                                        fontSize:
                                            analysisType == 'Daily' ? 25 : 20,
                                        letterSpacing: -0.5,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      TextRoundedEnclose(
                                          text: 'Moderate',
                                          color: Colors.grey.shade300,
                                          textColor: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ],
                                  ),
                                  DividerWidget(
                                    verticalHeight: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.1),
                                  ),
                                  if (analysisType == 'Weekly')
                                    Column(
                                      children: [
                                        Text(
                                          shortSummary,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                fontSize: 22,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                fontWeight: FontWeight.w300,
                                                height: 1.2,
                                                letterSpacing: -0.9,
                                              ),
                                        ),
                                        const SizedBox(height: 10),
                                        DynamicContainer(
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Nitrogen',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                  TextRoundedEnclose(
                                                    text: nitrogenCondition,
                                                    color: Colors.blue,
                                                    textColor: Theme.of(context)
                                                        .colorScheme
                                                        .surface,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              GroupedNutrientBarChart(
                                                  groupedData: groupedData),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  Text(
                                    findings,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w400,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            CustomAccordion(
                              borderColor: Colors.transparent,
                              titleWidget: TextGradient(
                                text: 'Predictions:',
                                fontSize: 16,
                                letterSpacing: -0.5,
                              ),
                              icon: Icons.analytics,
                              initiallyExpanded: true,
                              content: Text(
                                predictions,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 15,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ),
                            CustomAccordion(
                              borderColor: Colors.transparent,
                              titleWidget: TextGradient(
                                text: 'Recommendations:',
                                fontSize: 16,
                                letterSpacing: -0.5,
                              ),
                              icon: Icons.recommend,
                              initiallyExpanded: true,
                              content: Text(
                                recommendations,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 15,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ),
                            DynamicContainer(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              borderColor: Colors.transparent,
                              child: Column(
                                children: [
                                  NutrientSelectionWidget(
                                    selectedOption: selectedNutrient,
                                    onOptionSelected: (option) {
                                      ref
                                          .read(_localNutrientProvider.notifier)
                                          .state = option;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  AiChart(
                                      data: selectedData, label: chartLabel),
                                ],
                              ),
                            ),
                            CustomAccordion(
                              borderColor: Colors.transparent,
                              titleWidget: TextGradient(
                                text: ' ${plotName} Warnings:',
                                fontSize: 16,
                                letterSpacing: -0.5,
                              ),
                              icon: Icons.warning_rounded,
                              initiallyExpanded: false,
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...warnings.entries.map((entry) {
                                    final title = entry.key
                                        .replaceAll('_', ' ')
                                        .replaceFirst(entry.key[0],
                                            entry.key[0].toUpperCase());
                                    final message = entry.value;
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                      color: Colors.red[800],
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              Text(
                                                message,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                              ),
                                              if (entry.key !=
                                                  warnings.entries.last.key)
                                                DividerWidget(
                                                  verticalHeight: 1,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                            if (recommendedFertilizers.isNotEmpty)
                              CustomAccordion(
                                borderColor: Colors.transparent,
                                titleWidget: TextGradient(
                                  text: 'Recommended Fertilizers:',
                                  fontSize: 16,
                                  letterSpacing: -0.5,
                                ),
                                icon: Icons.eco,
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: recommendedFertilizers.entries
                                      .map((entry) {
                                    final nutrient = entry.key;
                                    final data = entry.value;
                                    final type = data['type'];
                                    final instructions =
                                        data['application_instructions'];

                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '$type',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                  TextRoundedEnclose(
                                                      text:
                                                          '${nutrientNames[nutrient] ?? nutrient}',
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .surface,
                                                      textColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                instructions,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                              ),
                                              if (entry.key !=
                                                  recommendedFertilizers
                                                      .entries.last.key)
                                                DividerWidget(
                                                  verticalHeight: 1,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
