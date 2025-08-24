import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/shared_preferences.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class PlotCondition extends ConsumerWidget {
  const PlotCondition({super.key, required this.plotName});

  final String plotName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPlotId = ref.watch(soilDashboardProvider).selectedPlotId;
    final plotConditions = ref.watch(soilDashboardProvider).plotConditions;
    final isGeneratingAi = ref.watch(soilDashboardProvider).isGeneratingAi;
    final selectedLanguage = LanguagePreferences.getLanguage();
    final lastRead = ref.watch(soilDashboardProvider).lastReadingTime;
    final today = DateTime.now();
    final condition = plotConditions[selectedPlotId] ?? 'No data available';

    final aiAnalysis = ref.watch(soilDashboardProvider).aiAnalysis;
    final selectedAnalysis = aiAnalysis.firstWhere(
      (analysis) =>
          analysis['plot_id'] == selectedPlotId &&
          analysis['language_type'] == selectedLanguage &&
          analysis['analysis_type'] == 'Daily' &&
          DateTime.parse(analysis['analysis_date']).year == today.year &&
          DateTime.parse(analysis['analysis_date']).month == today.month &&
          DateTime.parse(analysis['analysis_date']).day == today.day,
      orElse: () => {},
    );

    final headline = selectedAnalysis['analysis']?['AI_Analysis']
            ?['headline'] ??
        'Analysis has not been performed yet';
    final analysisDate = selectedAnalysis['analysis']?['AI_Analysis']?['date'];
    final formattedAnalysisDate = analysisDate != null
        ? DateFormat('MMMM d, yyyy').format(DateTime.parse(analysisDate))
        : 'No data available';

    final shortSummary = selectedAnalysis['analysis']?['AI_Analysis']
            ?['short_summary'] ??
        'Analysis has not been performed yet';

    if (isGeneratingAi) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(25),
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.asset(
          'assets/elements/soiltrack_loading2.gif',
          fit: BoxFit.cover,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        context.pushNamed('ai-history');
      },
      child: DynamicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        margin: const EdgeInsets.only(bottom: 10),
        backgroundImage: const DecorationImage(
          image: AssetImage('assets/background/container_background_2.png'),
          fit: BoxFit.cover,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Update:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  lastRead != null ? formattedAnalysisDate : '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (lastRead == null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No data available for this selected plot.',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        height: 1.1,
                        letterSpacing: -1.0,
                        fontSize: 28,
                      ),
                  textAlign: TextAlign.start,
                ),
              ),
            if (lastRead != null)
              Text('${headline}.',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        height: 1.1,
                        letterSpacing: -1.0,
                        fontSize: 28,
                      ),
                  textAlign: TextAlign.start),
            DividerWidget(
                verticalHeight: 2,
                color: Theme.of(context).colorScheme.onSecondary),
            SizedBox(
              width: 400,
              child: Text(
                shortSummary!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Text(
                  'VIEW YOUR ANALYSIS LIST',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
