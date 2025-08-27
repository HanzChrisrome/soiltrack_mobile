import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/ai_analysis_daily.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/ai_analysis_weekly.dart';

class AiAnalysisOverview extends ConsumerWidget {
  final String? analysisId;
  const AiAnalysisOverview({super.key, this.analysisId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(soilDashboardProvider);
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

    final analysisType = selectedAnalysis['analysis_type'];
    final analysis = selectedAnalysis['analysis']['AI_Analysis'];

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
                        if (analysisType == 'Daily')
                          AiAnalysisDaily(analysis: analysis)
                        else if (analysisType == 'Weekly')
                          AiAnalysisWeekly(analysis: analysis),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'End of Analysis',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.5,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                        const SizedBox(height: 30),
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
