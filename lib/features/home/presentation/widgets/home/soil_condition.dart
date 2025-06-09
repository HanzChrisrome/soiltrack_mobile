import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class SoilCondition extends ConsumerWidget {
  const SoilCondition({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(soilDashboardProvider).overallCondition;
    final lastRead = ref.watch(soilDashboardProvider).lastReadingTime;
    final isGenerating = ref.watch(soilDashboardProvider).isGeneratingAi;
    final summaryAnalysis = ref.watch(soilDashboardProvider).aiSummaryHistory;

    final today = DateTime.now();
    final todayAnalyses = summaryAnalysis.where((entry) {
      final date = DateTime.parse(entry['analysis_date']);
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();

    final headline = todayAnalyses.isNotEmpty
        ? todayAnalyses.first['summary_analysis']['headline'] as String?
        : null;

    final shortSummary = todayAnalyses.isNotEmpty
        ? todayAnalyses.first['summary_analysis']['summary'] as String?
        : 'This summary is system generated and may not be accurate. The data for your plot might be incomplete for our analysis.';

    final summaryAnalysisDate = todayAnalyses.isNotEmpty
        ? DateFormat('MMM dd, yyyy')
            .format(DateTime.parse(todayAnalyses.first['analysis_date']))
        : 'No Analysis Available';

    if (isGenerating)
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(25),
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.asset(
          'assets/elements/soiltrack_loading.gif',
          fit: BoxFit.cover,
        ),
      );

    return DynamicContainer(
      backgroundImage: DecorationImage(
          image: AssetImage('assets/background/container_background_3.png'),
          fit: BoxFit.cover),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      child: Column(
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
                summaryAnalysisDate,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          RichText(
            text: TextSpan(
              text: (headline != null && headline.isNotEmpty)
                  ? headline
                  : (condition != null && condition.isNotEmpty
                      ? 'Your plots are $condition'
                      : 'No data is available for all your plots'),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    height: 1.1,
                    letterSpacing: -1.0,
                    fontSize: 25,
                  ),
            ),
          ),
          DividerWidget(
            verticalHeight: 1,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          SizedBox(
            width: 400,
            child: Text(
              shortSummary!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
