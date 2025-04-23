// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/registered_plots.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/warning_widget.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/soil_dashboard/unassigned_sensor.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/hardware_provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_navigation_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    final userPlot = ref.watch(soilDashboardProvider);
    final sensorState = ref.watch(sensorsProvider);

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
                      automaticallyImplyLeading: false,
                      leading: null,
                      expandedHeight: 200,
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
                          horizontal: 10, vertical: 10),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Column(
                              children: [
                                if (unassignedNutrientSensors.isNotEmpty)
                                  WarningWidget(
                                      headerText: 'UNASSIGNED SENSORS',
                                      bodyText:
                                          'Assigning sensors to plots is important for data collection and monitoring. Please assign the available sensors to your plots.'),
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
                              ],
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomNavBar(
                    selectedIndex: 1,
                  ),
                ),
              ],
            ),
    );
  }
}
