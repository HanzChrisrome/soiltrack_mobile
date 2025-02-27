// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/registered_plots.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/soil_dashboard/unassigned_sensor.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/text_header.dart';

class SoilDashboardScreen extends ConsumerStatefulWidget {
  const SoilDashboardScreen({super.key});

  @override
  _SoilDashboardScreenState createState() => _SoilDashboardScreenState();
}

class _SoilDashboardScreenState extends ConsumerState<SoilDashboardScreen> {
  final TextEditingController plotNameController = TextEditingController();
  final FocusNode plotNameFocusNode = FocusNode();

  @override
  void dispose() {
    plotNameController.dispose();
    plotNameFocusNode.dispose();
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     ref.read(weatherProvider.notifier).fetchWeather('Baliuag');

  //     final userPlots = ref.read(soilDashboardProvider).userPlots;
  //     if (userPlots.isEmpty) {
  //       ref.read(soilDashboardProvider.notifier).fetchUserPlots();
  //       ref.read(soilDashboardProvider.notifier).fetchUserPlotData();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final userPlot = ref.watch(soilDashboardProvider);
    final sensorState = ref.watch(sensorsProvider);
    final deviceState = ref.watch(deviceProvider);
    final deviceNotifier = ref.read(deviceProvider.notifier);

    final unassignedNutrientSensors = sensorState.nutrientSensors
        .where((sensor) => sensor['is_assigned'] == false)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: userPlot.isFetchingUserPlots
          ? Center(
              child: LoadingAnimationWidget.fallingDot(
                color: Colors.green,
                size: 50,
              ),
            )
          : Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      leading: null,
                      expandedHeight: 250,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
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
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 20),
                                  TextHeader(
                                      text: 'Registered Plots',
                                      fontSize: 35,
                                      color: Colors.white),
                                  Text(
                                    'Here are your registered plots',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
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
                          horizontal: 15, vertical: 10),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Column(
                              children: [
                                if (unassignedNutrientSensors.isNotEmpty)
                                  const UnassignedSensor(),
                                Column(
                                  children: userPlot.userPlots.map<Widget>(
                                    (plot) {
                                      final plotName = plot['plot_name'];
                                      final plotId = plot['plot_id'];
                                      final cropName = plot['user_crops']
                                              ?['crop_name'] as String? ??
                                          'No crop assigned';
                                      final category = plot['user_crops']
                                              ?['category'] as String? ??
                                          'No category assigned';

                                      final sensors =
                                          plot['user_plot_sensors'] ?? [];
                                      final soilMoistureSensor =
                                          sensors.firstWhere(
                                        (sensor) =>
                                            sensor['soil_sensors']
                                                ['sensor_category'] ==
                                            'Moisture Sensor',
                                        orElse: () => null,
                                      );

                                      final soilNutrientSensor =
                                          sensors.firstWhere(
                                        (sensor) =>
                                            sensor['soil_sensors']
                                                ['sensor_category'] ==
                                            'NPK Sensor',
                                        orElse: () => null,
                                      );

                                      final soilMoistureSensorName =
                                          soilMoistureSensor?['soil_sensors']
                                                  ['sensor_name'] as String? ??
                                              'No moisture sensor assigned';
                                      final soilNutrientSensorName =
                                          soilNutrientSensor?['soil_sensors']
                                                  ['sensor_name'] as String? ??
                                              'No nutrient sensor assigned';

                                      final plotWarningsData =
                                          userPlot.nutrientWarnings.firstWhere(
                                        (warning) =>
                                            warning['plot_id'] == plotId,
                                        orElse: () => {},
                                      );

                                      final warnings =
                                          plotWarningsData.isNotEmpty
                                              ? List<String>.from(
                                                  plotWarningsData['warnings'])
                                              : [];

                                      final warningsLength = warnings.length;

                                      return RegisteredPlots(
                                        plotName: plotName,
                                        cropName: cropName,
                                        assignedCategory: category,
                                        soilMoistureSensorName:
                                            soilMoistureSensorName,
                                        soilNutrientSensorName:
                                            soilNutrientSensorName,
                                        plotId: plotId,
                                        warnings: warningsLength,
                                      );
                                    },
                                  ).toList(),
                                ),
                                const SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () {
                                    showCustomBottomSheet(
                                      context: context,
                                      title: deviceState.isPumpOpen
                                          ? 'Close Pump and All Valves'
                                          : 'Open Pump and Valves',
                                      description:
                                          'Are you sure you want to do this action?',
                                      icon: Icons.arrow_forward_ios_outlined,
                                      buttonText: 'Proceed',
                                      onPressed: () {
                                        if (deviceState.isPumpOpen) {
                                          deviceNotifier.closeAll(context);
                                        } else {
                                          deviceNotifier.openAll(context);
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 20),
                                    decoration: BoxDecoration(
                                      color: deviceState.isPumpOpen
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: deviceState.isPumpOpen
                                            ? Colors.red
                                            : Colors.green,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        deviceState.isPumpOpen
                                            ? 'Close pump and all valves'
                                            : 'Open pump and all valves',
                                        style: TextStyle(
                                          color: deviceState.isPumpOpen
                                              ? Colors.red
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
