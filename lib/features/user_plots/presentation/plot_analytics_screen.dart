import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_card.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_chart.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/time_selection.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';

class PlotAnalyticsScreen extends ConsumerWidget {
  const PlotAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPlot = ref.watch(soilDashboardProvider);

    final selectedPlot = userPlot.userPlots.firstWhere(
      (plot) => plot['plot_id'] == userPlot.selectedPlotId,
      orElse: () => {},
    );

    final plotName = selectedPlot['plot_name'] ?? 'No plot name';

    final sensors = selectedPlot['user_plot_sensors'] ?? [];

    final soilNutrientSensors = sensors.firstWhere(
      (sensor) => sensor['soil_sensors']['sensor_category'] == 'NPK Sensor',
      orElse: () => {},
    );

    final assignedNutrientSensor =
        soilNutrientSensors?['soil_sensors']?['sensor_name'] ?? 'No sensor';

    final nitrogenData = userPlot.userPlotNutrientData
        .where((nutrient) => nutrient['plot_id'] == userPlot.selectedPlotId)
        .map((nutrient) => {
              'plot_id': nutrient['plot_id'],
              'sensor_id': nutrient['sensor_id'],
              'read_time': nutrient['read_time'],
              'value': nutrient['readed_nitrogen']
            })
        .toList();

    final phosphorusData = userPlot.userPlotNutrientData
        .where((nutrient) => nutrient['plot_id'] == userPlot.selectedPlotId)
        .map((nutrient) => {
              'plot_id': nutrient['plot_id'],
              'sensor_id': nutrient['sensor_id'],
              'read_time': nutrient['read_time'],
              'value': nutrient['readed_phosphorus']
            })
        .toList();

    final potassiumData = userPlot.userPlotNutrientData
        .where((nutrient) => nutrient['plot_id'] == userPlot.selectedPlotId)
        .map((nutrient) => {
              'plot_id': nutrient['plot_id'],
              'sensor_id': nutrient['sensor_id'],
              'read_time': nutrient['read_time'],
              'value': nutrient['readed_potassium']
            })
        .toList();

    final plotWarnings = userPlot.nutrientWarnings.firstWhere(
        (w) => w['plot_id'] == userPlot.selectedPlotId,
        orElse: () => {});

    final plotSuggestions = userPlot.plotsSuggestion.firstWhere(
        (s) => s['plot_id'] == userPlot.selectedPlotId,
        orElse: () => {});

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Icon(Icons.arrow_back_ios_new_outlined,
                        color: Colors.green),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                pinned: true,
                title: Text(
                  '$plotName Analytics',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (assignedNutrientSensor != 'No sensor')
                        if (plotWarnings['warnings'].isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red
                                  .withOpacity(0.1), // Light red with opacity
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.red, width: 1), // Red border
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.warning_amber_outlined,
                                        color: Colors.red, size: 20),
                                    SizedBox(width: 5),
                                    Text(
                                      'Warnings!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                ...plotWarnings['warnings'].map((warning) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        warning,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!,
                                      ),
                                      if (plotWarnings['warnings']
                                              .indexOf(warning) !=
                                          plotWarnings['warnings'].length - 1)
                                        const DividerWidget(
                                            verticalHeight: 1,
                                            color: Colors.red),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TimeSelectionWidget(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Custom'),
                                SizedBox(width: 30),
                                Icon(Icons.keyboard_arrow_down_rounded),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const DividerWidget(verticalHeight: 5),
                      PlotCard(
                          selectedPlotId: userPlot.selectedPlotId,
                          moistureReadings: userPlot.userPlotMoistureData),
                      if (assignedNutrientSensor != 'No sensor')
                        Column(
                          children: [
                            PlotChart(
                                selectedPlotId: userPlot.selectedPlotId,
                                readings: nitrogenData,
                                readingType: 'readed_nitrogen'),
                            PlotChart(
                                selectedPlotId: userPlot.selectedPlotId,
                                readings: phosphorusData,
                                readingType: 'readed_phosphorus'),
                            PlotChart(
                                selectedPlotId: userPlot.selectedPlotId,
                                readings: potassiumData,
                                readingType: 'readed_potassium'),
                          ],
                        ),
                      if (plotSuggestions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.green, width: 1), // Red border
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.warning_amber_outlined,
                                      color: Colors.green, size: 20),
                                  SizedBox(width: 5),
                                  Text(
                                    'Suggestions',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ...plotSuggestions['suggestions']
                                  .map((suggestions) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      suggestions,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!,
                                    ),
                                    if (plotSuggestions['suggestions']
                                            .indexOf(suggestions) !=
                                        plotSuggestions['suggestions'].length -
                                            1)
                                      DividerWidget(
                                          verticalHeight: 1,
                                          color: Colors.grey[300]!),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
