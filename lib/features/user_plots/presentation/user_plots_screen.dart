// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/sensor_tile.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/specific_details.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/plot_card.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/edit_threshold.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/nutrients_card.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/tools_button.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_header.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class UserPlotScreen extends ConsumerStatefulWidget {
  const UserPlotScreen({super.key});

  @override
  _UserPlotScreenState createState() => _UserPlotScreenState();
}

class _UserPlotScreenState extends ConsumerState<UserPlotScreen> {
  final FocusNode plotNameFocusNode = FocusNode();
  final TextEditingController plotNameController = TextEditingController();
  final TextEditingController minMoisture = TextEditingController();
  final TextEditingController maxMoisture = TextEditingController();
  final TextEditingController minNitrogen = TextEditingController();
  final TextEditingController maxNitrogen = TextEditingController();
  final TextEditingController minPotassium = TextEditingController();
  final TextEditingController maxPotassium = TextEditingController();
  final TextEditingController minPhosphorus = TextEditingController();
  final TextEditingController maxPhosphorus = TextEditingController();

  @override
  void dispose() {
    plotNameController.dispose();
    plotNameFocusNode.dispose();
    minMoisture.dispose();
    maxMoisture.dispose();
    minNitrogen.dispose();
    maxNitrogen.dispose();
    minPotassium.dispose();
    maxPotassium.dispose();
    minPhosphorus.dispose();
    maxPhosphorus.dispose();
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
    final deviceState = ref.watch(deviceProvider);
    final deviceNotifier = ref.read(deviceProvider.notifier);
    final sensorState = ref.watch(sensorsProvider);
    final cropNotifier = ref.watch(cropProvider.notifier);

    final selectedPlot = userPlot.userPlots.firstWhere(
      (plot) => plot['plot_id'] == userPlot.selectedPlotId,
      orElse: () => {},
    );

    final plotName =
        selectedPlot.isNotEmpty ? selectedPlot['plot_name'] : 'No plot found';
    final selectedCrop =
        selectedPlot['user_crops']?['crop_name'] ?? 'No selected crop';
    final assignedSensor = selectedPlot['soil_moisture_sensors']
            ?['soil_moisture_name'] ??
        'No sensor assigned';
    final assignedNutrientSensor = selectedPlot['soil_nutrient_sensors']
            ?['soil_nutrient_name'] ??
        'No sensor assigned';
    final soilType = selectedPlot['soil_type'] ?? 'No soil type';

    final moistureMin = selectedPlot['user_crops']?['moisture_min'] ?? 0;
    final moistureMax = selectedPlot['user_crops']?['moisture_max'] ?? 0;
    final nitrogenMin = selectedPlot['user_crops']?['nitrogen_min'] ?? 0;
    final nitrogenMax = selectedPlot['user_crops']?['nitrogen_max'] ?? 0;
    final potassiumMin = selectedPlot['user_crops']?['potassium_min'] ?? 0;
    final potassiumMax = selectedPlot['user_crops']?['potassium_max'] ?? 0;
    final phosphorusMin = selectedPlot['user_crops']?['phosphorus_min'] ?? 0;
    final phosphorusMax = selectedPlot['user_crops']?['phosphorus_max'] ?? 0;

    if (!userPlot.isFetchingUserPlots &&
        userPlot.selectedPlotId != userPlot.loadedPlotId) {
      Future.microtask(() async {
        await userPlotNotifier.fetchUserPlotData();
      });
    }

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
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey[100]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ToolsButton(
                                    buttonName: deviceState.isPumpOpen
                                        ? 'Close Pump'
                                        : 'Open Pump',
                                    icon: deviceState.isPumpOpen
                                        ? Icons.open_in_full_sharp
                                        : Icons.close_fullscreen_outlined,
                                    action: () {
                                      showCustomBottomSheet(
                                        context: context,
                                        title: deviceState.isPumpOpen
                                            ? 'Close Pump'
                                            : 'Open Pump',
                                        description:
                                            'Are you sure you want to ${deviceState.isPumpOpen ? 'close' : 'open'} the pump?',
                                        icon: deviceState.isPumpOpen
                                            ? Icons.close_fullscreen_sharp
                                            : Icons.open_in_full_sharp,
                                        buttonText: deviceState.isPumpOpen
                                            ? 'Close'
                                            : 'Open',
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          if (deviceState.isPumpOpen) {
                                            deviceNotifier.openPump(
                                                context, "PUMP ON");
                                          } else {
                                            deviceNotifier.openPump(
                                                context, "PUMP OFF");
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 5),
                                  ToolsButton(
                                    buttonName: 'Change Soil',
                                    icon: Icons.layers_rounded,
                                    action: () {},
                                  ),
                                  const SizedBox(width: 5),
                                  ToolsButton(
                                    buttonName: 'Change Crop',
                                    icon: Icons.eco,
                                    action: () {
                                      userPlotNotifier.setEditingUserPlot(true);
                                      context.pushNamed('select-category');
                                    },
                                  ),
                                  const SizedBox(width: 5),
                                  ToolsButton(
                                    buttonName:
                                        assignedSensor == 'No sensor assigned'
                                            ? 'Assign Sensor'
                                            : 'Change Sensor',
                                    icon: Icons.sensors,
                                    action: () {
                                      showCustomizableBottomSheet(
                                        height: 500,
                                        context: context,
                                        centerContent: Consumer(
                                            builder: (context, ref, child) {
                                          final cropState =
                                              ref.watch(cropProvider);

                                          return Column(
                                            children: [
                                              TextGradient(
                                                  text: assignedSensor !=
                                                          'No sensor assigned'
                                                      ? 'Change Sensor'
                                                      : 'Assign a Sensor',
                                                  fontSize: 35),
                                              const SizedBox(height: 20),
                                              if (sensorState
                                                  .sensors.isNotEmpty)
                                                ...sensorState.sensors.map(
                                                  (sensor) {
                                                    final bool isSelected = cropState
                                                            .selectedSensor ==
                                                        sensor[
                                                            'soil_moisture_sensor_id'];

                                                    return SensorTile(
                                                      sensorName: sensor[
                                                          'soil_moisture_name'],
                                                      sensorId: sensor[
                                                          'soil_moisture_sensor_id'],
                                                      isAssigned: sensor[
                                                              'is_assigned'] ==
                                                          true,
                                                      plotName:
                                                          sensor['user_plots']
                                                              ?['plot_name'],
                                                      isSelected: isSelected,
                                                      onTap: () {
                                                        cropNotifier
                                                            .selectSensor(sensor[
                                                                'soil_moisture_sensor_id']);
                                                      },
                                                    );
                                                  },
                                                ),
                                            ],
                                          );
                                        }),
                                        buttonText: 'Proceed',
                                        onPressed: () {},
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey[100]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextRoundedEnclose(
                                          text: 'Plot Details',
                                          color: Colors.white,
                                          textColor: Colors.grey[500]!),
                                      const SizedBox(height: 15),
                                      SpecificDetails(
                                        icon: Icons.sensors,
                                        title: 'Moisture Sensor',
                                        details: assignedSensor,
                                      ),
                                      SpecificDetails(
                                        icon: Icons.sensors,
                                        title: 'Nutrient Sensor',
                                        details: assignedNutrientSensor,
                                      ),
                                      SpecificDetails(
                                        icon: Icons.grass,
                                        title: 'Soil Type',
                                        details: soilType,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey[100]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextRoundedEnclose(
                                    text:
                                        'Threshold for the Crop: $selectedCrop',
                                    color: Colors.white,
                                    textColor: Colors.grey[500]!,
                                  ),
                                  const SizedBox(height: 15),
                                  SpecificDetails(
                                    icon: Icons.eco_outlined,
                                    title: 'Moisture Level',
                                    details: '$moistureMin% - $moistureMax%',
                                    onPressed: () {
                                      editThreshold(
                                        context: context,
                                        title: 'Edit Moisture Threshold',
                                        minLabel: 'Moisture Min $moistureMin%',
                                        maxLabel: 'Moisture Max $moistureMax%',
                                        minController: minMoisture,
                                        maxController: maxMoisture,
                                        currentMin: moistureMin,
                                        currentMax: moistureMax,
                                        thresholdType: 'Moisture',
                                        soilDashboardNotifier: userPlotNotifier,
                                        minColumn: 'moisture_min',
                                        maxColumn: 'moisture_max',
                                      );
                                    },
                                  ),
                                  const DividerWidget(verticalHeight: 1),
                                  SpecificDetails(
                                    icon: Icons.grass,
                                    title: 'Nitrogen Level',
                                    details: '$nitrogenMin% - $nitrogenMax%',
                                    onPressed: () {
                                      editThreshold(
                                        context: context,
                                        title: 'Edit Nitrogen Threshold',
                                        minLabel: 'Nitrogen Min $nitrogenMin%',
                                        maxLabel: 'Nitrogen Max $nitrogenMax%',
                                        minController: minNitrogen,
                                        maxController: maxNitrogen,
                                        currentMin: nitrogenMin,
                                        currentMax: nitrogenMax,
                                        thresholdType: 'Nitrogen',
                                        soilDashboardNotifier: userPlotNotifier,
                                        minColumn: 'nitrogen_min',
                                        maxColumn: 'nitrogen_max',
                                      );
                                    },
                                  ),
                                  const DividerWidget(verticalHeight: 1),
                                  SpecificDetails(
                                    icon: Icons.local_florist,
                                    title: 'Potassium Level',
                                    details: '$potassiumMin% - $potassiumMax%',
                                    onPressed: () {
                                      editThreshold(
                                        context: context,
                                        title: 'Edit Potassium Threshold',
                                        minLabel:
                                            'Potassium Min $potassiumMin%',
                                        maxLabel:
                                            'Potassium Max $potassiumMax%',
                                        minController: minPotassium,
                                        maxController: maxPotassium,
                                        currentMin: potassiumMin,
                                        currentMax: potassiumMax,
                                        thresholdType: 'Potassium',
                                        soilDashboardNotifier: userPlotNotifier,
                                        minColumn: 'potassium_min',
                                        maxColumn: 'potassium_max',
                                      );
                                    },
                                  ),
                                  const DividerWidget(verticalHeight: 1),
                                  SpecificDetails(
                                    icon: Icons.science_outlined,
                                    title: 'Phosphorus Level',
                                    details:
                                        '$phosphorusMin% - $phosphorusMax%',
                                    onPressed: () {
                                      editThreshold(
                                        context: context,
                                        title: 'Edit Phosphorus Threshold',
                                        minLabel:
                                            'Phosphorus Min $phosphorusMin%',
                                        maxLabel:
                                            'Phosphorus Max $phosphorusMax%',
                                        minController: minPhosphorus,
                                        maxController: maxPhosphorus,
                                        currentMin: phosphorusMin,
                                        currentMax: phosphorusMax,
                                        thresholdType: 'Phosphorus',
                                        soilDashboardNotifier: userPlotNotifier,
                                        minColumn: 'phosphorus_min',
                                        maxColumn: 'phosphorus_max',
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            const NutrientsCard(
                                elementIcon: Icons.opacity_outlined,
                                percentage: '25%',
                                latestReading: '12:00PM',
                                nutrientType: 'Moisture'),
                            if (userPlot.userPlotData.isNotEmpty)
                              Column(
                                children: [
                                  PlotCard(
                                    soilMoistureSensorId: userPlot.userPlotData
                                        .first['soil_moisture_sensor_id'],
                                    sensorName:
                                        'Sensor ID: ${userPlot.userPlotData.first['soil_moisture_sensor_id']}',
                                    sensorStatus:
                                        'Moisture: ${userPlot.userPlotData.first['soil_moisture']}%',
                                    assignedCrop: selectedCrop,
                                    moistureReadings: userPlot.userPlotData,
                                  ),
                                ],
                              ),
                            if (userPlot.userPlotData.isEmpty)
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey[100]!,
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: TextGradient(
                                      text: 'No available data', fontSize: 20),
                                ),
                              ),
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
