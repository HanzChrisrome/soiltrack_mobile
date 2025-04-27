import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/custom_accordion.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class UserPlotWarnings extends ConsumerWidget {
  const UserPlotWarnings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAnalysisList =
        ref.watch(soilDashboardProvider).aiSummaryHistory;
    final isGeneratingAi = ref.watch(soilDashboardProvider).isGeneratingAi;

    final userPlotWarnings = summaryAnalysisList.isNotEmpty
        ? (summaryAnalysisList[0]['summary_analysis']['warnings']
            as List<dynamic>?)
        : [];

    return CustomAccordion(
      initiallyExpanded: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      titleWidget: Row(
        children: [
          const TextGradient(text: 'User Plot Warnings', fontSize: 20),
          const SizedBox(width: 10),
          TextRoundedEnclose(
            text: 'Based on soil data',
            color: Colors.white,
            textColor: Colors.grey[500]!,
          ),
        ],
      ),
      content: isGeneratingAi
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.grey[300],
                    ),
                  );
                }),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userPlotWarnings != null && userPlotWarnings.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userPlotWarnings.length,
                    itemBuilder: (context, index) {
                      final warning = userPlotWarnings[index];
                      return SizedBox(
                        child: Text(
                          '• $warning', // Add a bullet before each warning
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                height: 1.5,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const DividerWidget(verticalHeight: 1),
                  )
                else
                  Text(
                    'No warnings available for your plots, analysis is not generated for this account.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(height: 1.2),
                  ),
              ],
            ),
    );
  }
}
