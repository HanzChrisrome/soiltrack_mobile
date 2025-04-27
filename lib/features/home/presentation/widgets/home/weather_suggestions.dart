import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/custom_accordion.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class WeatherSuggestions extends ConsumerWidget {
  const WeatherSuggestions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGeneratingAi = ref.watch(soilDashboardProvider).isGeneratingAi;
    final summaryAnalysisList =
        ref.watch(soilDashboardProvider).aiSummaryHistory;

    final weatherSuggestions = summaryAnalysisList.isNotEmpty
        ? (summaryAnalysisList[0]['summary_analysis']['weather_suggestions']
            as List<dynamic>?)
        : [];

    return CustomAccordion(
      initiallyExpanded: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      titleWidget: Row(
        children: [
          const TextGradient(text: 'Suggestions', fontSize: 20),
          const SizedBox(width: 10),
          TextRoundedEnclose(
              text: 'Based on weather data',
              color: Colors.white,
              textColor: Colors.grey[500]!),
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
                const SizedBox(height: 5),
                if (weatherSuggestions != null && weatherSuggestions.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: weatherSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = weatherSuggestions[index];
                      return SizedBox(
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion["header"],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color:
                                        const Color.fromARGB(255, 44, 44, 44),
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              suggestion["suggestion"],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontSize: 14,
                                    color:
                                        const Color.fromARGB(255, 97, 97, 97),
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const DividerWidget(verticalHeight: 10),
                  ),
                if (weatherSuggestions == null || weatherSuggestions.isEmpty)
                  Text(
                    'No weather suggestions available. No analysis has been done yet for this account.',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
              ],
            ),
    );
  }
}
