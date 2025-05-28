import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/helper/user_plots_helper.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/nutrient_progress_bar.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class NutrientProgressChart extends ConsumerWidget {
  const NutrientProgressChart({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserPlotsHelper plotHelper = UserPlotsHelper();
    final userPlot = ref.watch(soilDashboardProvider);
    final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);

    final moistureData = plotHelper.filterData(
      userPlot.latestPlotMoistureData,
      userPlot.selectedPlotId,
      'soil_moisture',
    );

    final nitrogenData = plotHelper.filterData(userPlot.latestPlotNutrientData,
        userPlot.selectedPlotId, 'readed_nitrogen');
    final phosphorusData = plotHelper.filterData(
        userPlot.latestPlotNutrientData,
        userPlot.selectedPlotId,
        'readed_phosphorus');
    final potassiumData = plotHelper.filterData(userPlot.latestPlotNutrientData,
        userPlot.selectedPlotId, 'readed_potassium');

    String lastUpdated = plotHelper.getLatestTimestamp(
      nitrogenData,
      phosphorusData,
      potassiumData,
      moistureData,
    );

    int nitrogenValue = plotHelper.extractLatestValue(nitrogenData);
    int phosphorusValue = plotHelper.extractLatestValue(phosphorusData);
    int potassiumValue = plotHelper.extractLatestValue(potassiumData);
    int moistureValue = plotHelper.extractLatestValue(moistureData);

    const int nutrientMaxValue = 200;
    const int moistureMaxValue = 100;

    return lastUpdated == "No data available"
        ? const SizedBox.shrink()
        : DynamicContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextRoundedEnclose(
                      text: 'Readings as of $lastUpdated',
                      color: Colors.white,
                      textColor: Colors.grey[500]!,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        soilDashboardNotifier.fetchUserPlotData();
                      },
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                NutrientProgressBar(
                    label: 'Moisture',
                    value: moistureValue,
                    maxValue: moistureMaxValue,
                    color: Colors.blue),
                if (nitrogenValue != 0 ||
                    phosphorusValue != 0 ||
                    potassiumValue != 0)
                  Column(
                    children: [
                      NutrientProgressBar(
                          label: 'Nitrogen',
                          value: nitrogenValue,
                          maxValue: nutrientMaxValue,
                          color: Colors.green),
                      NutrientProgressBar(
                          label: 'Phosphorus',
                          value: phosphorusValue,
                          maxValue: nutrientMaxValue,
                          color: Colors.orange),
                      NutrientProgressBar(
                          label: 'Potassium',
                          value: potassiumValue,
                          maxValue: nutrientMaxValue,
                          color: Colors.red),
                    ],
                  ),
                const SizedBox(height: 10),
                FilledCustomButton(
                  buttonText: 'View Statistics',
                  icon: Icons.remove_red_eye_outlined,
                  onPressed: () {
                    context.pushNamed('plot-analytics');
                  },
                ),
              ],
            ),
          );
  }
}
