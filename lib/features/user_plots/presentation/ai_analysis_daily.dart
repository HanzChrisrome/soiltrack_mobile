import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/ai_widgets/ai_chart.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/nutrient_selection.dart';
import 'package:soiltrack_mobile/widgets/custom_accordion.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_header.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

final _localNutrientProvider = StateProvider<String>((ref) => 'M');

class AiAnalysisDaily extends ConsumerWidget {
  final Map<String, dynamic> analysis;

  const AiAnalysisDaily({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = analysis['summary'];
    final findings = summary['findings'];
    final predictions = summary['predictions'];
    final recommendations = summary['recommendations'];

    //FOR CHARTS
    final moistureTrends = analysis['summary_of_findings']['moisture_trends'];
    final nutrientTrends = analysis['summary_of_findings']['nutrient_trends'];
    final nitrogenTrend = nutrientTrends['N'];
    final phosphorusTrend = nutrientTrends['P'];
    final potassiumTrend = nutrientTrends['K'];

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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextHeader(
                    text: 'Daily Analysis',
                    fontSize: 25,
                    letterSpacing: -0.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  TextRoundedEnclose(
                      text: 'Moderate',
                      color: Colors.grey.shade300,
                      textColor: Theme.of(context).colorScheme.secondary),
                ],
              ),
              DividerWidget(
                verticalHeight: 1,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              ),
              Text(
                findings,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
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
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
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
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
        DynamicContainer(
          backgroundColor: Theme.of(context).colorScheme.primary,
          borderColor: Colors.transparent,
          child: Column(
            children: [
              NutrientSelectionWidget(
                selectedOption: selectedNutrient,
                onOptionSelected: (option) {
                  ref.read(_localNutrientProvider.notifier).state = option;
                },
              ),
              const SizedBox(height: 10),
              AiChart(data: selectedData, label: chartLabel),
            ],
          ),
        ),
      ],
    );
  }
}
