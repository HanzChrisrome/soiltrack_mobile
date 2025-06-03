import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_card.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_chart.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/time_selection.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';

class PlotAnalyticsScreen extends ConsumerWidget {
  const PlotAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPlot = ref.watch(soilDashboardProvider);

    if (userPlot.isFetchingUserPlotData) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: LoadingAnimationWidget.progressiveDots(
            color: Theme.of(context).colorScheme.onPrimary,
            size: 50,
          ),
        ),
      );
    }

    final selectedPlot = userPlot.userPlots.firstWhere(
      (plot) => plot['plot_id'] == userPlot.selectedPlotId,
      orElse: () => {},
    );

    final plotName = selectedPlot['plot_name'] ?? 'No plot name';

    final nitrogenData = userPlot.userPlotNutrientData
        .where(
            (nutrient) => nutrient['plot_id'] as int == userPlot.selectedPlotId)
        .map((nutrient) => {
              'plot_id': nutrient['plot_id'],
              'read_time': nutrient['read_time'],
              'value': nutrient['readed_nitrogen']
            })
        .toList();

    final phosphorusData = userPlot.userPlotNutrientData
        .where(
            (nutrient) => nutrient['plot_id'] as int == userPlot.selectedPlotId)
        .map((nutrient) => {
              'plot_id': nutrient['plot_id'],
              'read_time': nutrient['read_time'],
              'value': nutrient['readed_phosphorus']
            })
        .toList();

    final potassiumData = userPlot.userPlotNutrientData
        .where(
            (nutrient) => nutrient['plot_id'] as int == userPlot.selectedPlotId)
        .map((nutrient) => {
              'plot_id': nutrient['plot_id'],
              'read_time': nutrient['read_time'],
              'value': nutrient['readed_potassium']
            })
        .toList();

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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const TimeSelectionWidget(),
                      const DividerWidget(verticalHeight: 5),
                      PlotCard(
                          selectedPlotId: userPlot.selectedPlotId,
                          moistureReadings: userPlot.userPlotMoistureData),
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
