import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';

class PlotCondition extends ConsumerWidget {
  const PlotCondition({super.key, required this.plotName});

  final String plotName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPlotId = ref.watch(soilDashboardProvider).selectedPlotId;
    final plotConditions = ref.watch(soilDashboardProvider).plotConditions;
    final lastRead = ref.watch(soilDashboardProvider).lastReadingTime;
    final today = DateTime.now();
    final condition = plotConditions[selectedPlotId] ?? 'No data available';

    final aiAnalysis = ref.watch(soilDashboardProvider).aiAnalysis;
    final selectedAnalysis = aiAnalysis.firstWhere(
      (analysis) =>
          analysis['plot_id'] == selectedPlotId &&
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(25),
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
        ],
      ),
    );
  }
}
