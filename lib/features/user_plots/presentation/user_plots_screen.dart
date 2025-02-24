// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/crop_threshold.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_chart.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_details.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/tools_section.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_header.dart';

class UserPlotScreen extends ConsumerStatefulWidget {
  const UserPlotScreen({super.key});

  @override
  _UserPlotScreenState createState() => _UserPlotScreenState();
}

class _UserPlotScreenState extends ConsumerState<UserPlotScreen> {
  final FocusNode plotNameFocusNode = FocusNode();
  final TextEditingController plotNameController = TextEditingController();

  @override
  void dispose() {
    plotNameController.dispose();
    plotNameFocusNode.dispose();
    super.dispose();
  }

  bool isAppBarCollapsed = false;

  void _updateAppBarTitle(double scrollOffset, double expandedHeight) {
    bool shouldCollapse = scrollOffset > expandedHeight - kToolbarHeight;

    if (shouldCollapse != isAppBarCollapsed) {
      setState(() {
        isAppBarCollapsed = shouldCollapse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPlot = ref.watch(soilDashboardProvider);
    final userPlotNotifier = ref.read(soilDashboardProvider.notifier);

    final selectedPlot = userPlot.userPlots.firstWhere(
      (plot) => plot['plot_id'] == userPlot.selectedPlotId,
      orElse: () => {},
    );

    final int plotId = selectedPlot['plot_id'] ?? 0;
    final plotName = selectedPlot['plot_name'] ?? 'No plot found';
    final soilType = selectedPlot['soil_type'] ?? 'No soil type found';
    final selectedCrop = selectedPlot['user_crops']['crop_name'] ?? 'No crop';

    final sensors = selectedPlot['user_plot_sensors'] ?? [];
    final soilMoistureSensors = sensors.firstWhere(
      (sensor) =>
          sensor['soil_sensors']['sensor_category'] == 'Moisture Sensor',
      orElse: () => {},
    );

    final soilNutrientSensors = sensors.firstWhere(
      (sensor) => sensor['soil_sensors']['sensor_category'] == 'NPK Sensor',
      orElse: () => {},
    );

    final assignedMoistureSensor =
        soilMoistureSensors?['soil_sensors']?['sensor_name'] ?? 'No sensor';
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: userPlot.isFetchingUserPlotData
          ? Center(
              child: LoadingAnimationWidget.fallingDot(
                color: Theme.of(context).colorScheme.onPrimary,
                size: 90,
              ),
            )
          : Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification.metrics.axis == Axis.vertical) {
                      _updateAppBarTitle(
                        scrollNotification.metrics.pixels,
                        250.0,
                      );
                    }
                    return true;
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        leading: IconButton(
                          icon: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Icon(Icons.arrow_back_ios_new_outlined,
                                color: isAppBarCollapsed
                                    ? Colors.green
                                    : Colors.white),
                          ),
                          onPressed: () {
                            context.go('/home?index=1');
                          },
                        ),
                        pinned: true,
                        expandedHeight: 250,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          title: isAppBarCollapsed
                              ? Container(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Text(
                                    plotName,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 20,
                                      letterSpacing: -1.3,
                                    ),
                                  ),
                                )
                              : null,
                          background: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Container(
                              height: 250,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/background/first_container.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextHeader(
                                            text: plotName,
                                            fontSize: 35,
                                            color: Colors.white),
                                        IconButton(
                                          onPressed: () {
                                            showCustomizableBottomSheet(
                                              height: 300,
                                              context: context,
                                              centerContent: Column(
                                                children: [
                                                  const TextGradient(
                                                      text: 'Edit Plot',
                                                      fontSize: 40),
                                                  const SizedBox(height: 20),
                                                  TextFieldWidget(
                                                    label: plotName,
                                                    controller:
                                                        plotNameController,
                                                  ),
                                                ],
                                              ),
                                              buttonText: 'Proceed',
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                userPlotNotifier.editPlotName(
                                                  context,
                                                  plotNameController.text,
                                                );
                                                plotNameController.clear();
                                              },
                                              onSheetCreated: () {
                                                plotNameFocusNode
                                                    .requestFocus();
                                              },
                                            );
                                          },
                                          icon: const Icon(Icons.edit_outlined,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Selected Crop: $selectedCrop',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            PlotDetailsWidget(
                                assignedSensor: assignedMoistureSensor,
                                assignedNutrientSensor: assignedNutrientSensor,
                                soilType: soilType),
                            const SizedBox(height: 5),
                            ToolsSectionWidget(
                                assignedSensor: assignedNutrientSensor),
                            const SizedBox(height: 5),
                            CropThresholdWidget(plotDetails: selectedPlot),
                            const SizedBox(height: 10),
                            PlotChart(
                              selectedPlotId: plotId,
                              readings: userPlot.userPlotMoistureData,
                              readingType: 'soil_moisture',
                            ),
                            if (assignedNutrientSensor != 'No sensor')
                              Column(
                                children: [
                                  PlotChart(
                                      selectedPlotId: plotId,
                                      readings: nitrogenData,
                                      readingType: 'readed_nitrogen'),
                                  PlotChart(
                                      selectedPlotId: plotId,
                                      readings: phosphorusData,
                                      readingType: 'readed_phosphorus'),
                                  PlotChart(
                                      selectedPlotId: plotId,
                                      readings: potassiumData,
                                      readingType: 'readed_potassium'),
                                ],
                              ),
                            const SizedBox(height: 15),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
