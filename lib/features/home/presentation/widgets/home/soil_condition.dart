import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
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

    final headline = summaryAnalysis.isNotEmpty
        ? summaryAnalysis.first['summary_analysis']['headline'] as String?
        : 'No headline available';
    final shortSummary = summaryAnalysis.isNotEmpty
        ? summaryAnalysis.first['summary_analysis']['summary'] as String?
        : 'No summary available';

    if (isGenerating)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: LoadingAnimationWidget.progressiveDots(
            color: Theme.of(context).colorScheme.primary,
            size: 50,
          ),
        ),
      );

    return DynamicContainer(
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
                lastRead != null
                    ? 'As of ${DateFormat('MMMM d, yyyy').format(lastRead)}'
                    : 'No recent data', // Handle null case
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
              text: '$headline.',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    height: 1.1,
                    letterSpacing: -1.0,
                    fontSize: 28,
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
