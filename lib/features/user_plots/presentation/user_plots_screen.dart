// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/crop_threshold.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/line_chart.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_details.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/tools_section.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
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
    final deviceState = ref.watch(deviceProvider);
    final deviceStateNotifier = ref.read(deviceProvider.notifier);

    final selectedPlot = userPlot.userPlots.firstWhere(
      (plot) => plot['plot_id'] == userPlot.selectedPlotId,
      orElse: () => {},
    );

    final plotName = selectedPlot['plot_name'] ?? 'No plot found';
    final soilType = selectedPlot['soil_type'] ?? 'No soil type found';
    final selectedCrop = selectedPlot['user_crops']?['crop_name'] ?? 'No crop';

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

    final moistureData = userPlot.rawPlotMoistureData
        .where((moisture) => moisture['plot_id'] == userPlot.selectedPlotId)
        .map((moisture) => {
              'plot_id': moisture['plot_id'],
              'sensor_id': moisture['sensor_id'],
              'read_time': moisture['read_time'],
              'value': moisture['soil_moisture']
            })
        .toList();

    final nitrogenData = userPlot.rawPlotNutrientData
        .where((nutrient) => nutrient['plot_id'] == userPlot.selectedPlotId)
        .map((nutrient) => {
              'plot_id': nutrient['plot_id'],
              'sensor_id': nutrient['sensor_id'],
              'read_time': nutrient['read_time'],
              'value': nutrient['readed_nitrogen']
            })
        .toList();

    final phosphorusData = userPlot.rawPlotNutrientData
        .where((nutrient) => nutrient['plot_id'] == userPlot.selectedPlotId)
        .map((nutrient) => {
              'plot_id': nutrient['plot_id'],
              'sensor_id': nutrient['sensor_id'],
              'read_time': nutrient['read_time'],
              'value': nutrient['readed_phosphorus']
            })
        .toList();

    final potassiumData = userPlot.rawPlotNutrientData
        .where((nutrient) => nutrient['plot_id'] == userPlot.selectedPlotId)
        .map((nutrient) => {
              'plot_id': nutrient['plot_id'],
              'sensor_id': nutrient['sensor_id'],
              'read_time': nutrient['read_time'],
              'value': nutrient['readed_potassium']
            })
        .toList();

    final plotWarningsData = userPlot.nutrientWarnings.firstWhere(
      (warning) => warning['plot_id'] == userPlot.selectedPlotId,
      orElse: () => {},
    );

    final plotSuggestions = userPlot.plotsSuggestion.firstWhere(
        (s) => s['plot_id'] == userPlot.selectedPlotId,
        orElse: () => {});

    String formatTimestamp(String timestamp) {
      try {
        DateTime dateTime = DateTime.parse(timestamp);

        if (!dateTime.isUtc) {
          dateTime = dateTime.toUtc();
        }

        DateTime localTime = dateTime.toLocal();

        return DateFormat('hh:mm a').format(localTime); // Only show time
      } catch (e) {
        return 'Invalid date';
      }
    }

    final irrigationLogs =
        (selectedPlot['irrigation_log'] as List<dynamic>? ?? [])
            .map((log) => {
                  'mac_address': log['mac_address'],
                  'time_started': formatTimestamp(log['time_started']),
                  'time_stopped': log['time_stopped'] != null
                      ? formatTimestamp(log['time_stopped'])
                      : 'Ongoing',
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
                            horizontal: 15, vertical: 10),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            PlotDetailsWidget(
                                assignedSensor: assignedMoistureSensor,
                                assignedNutrientSensor: assignedNutrientSensor,
                                soilType: soilType),
                            const SizedBox(height: 5),
                            if (deviceState.isPumpOpen)
                              GestureDetector(
                                onTap: () {
                                  deviceStateNotifier.closeAll(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 30),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                        'Pump is currently open, close the pump?'),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 5),
                            ToolsSectionWidget(
                                assignedSensor: assignedNutrientSensor),
                            const SizedBox(height: 5),
                            CropThresholdWidget(plotDetails: selectedPlot),
                            const SizedBox(height: 10),
                            if (plotWarningsData['warnings'] != null &&
                                plotWarningsData['warnings'].isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(
                                      0.1), // Light red with opacity
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.red,
                                      width: 1), // Red border
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
                                          'Warning!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    ...plotWarningsData['warnings']
                                        .map((warning) {
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
                                          if (plotWarningsData['warnings']
                                                  .indexOf(warning) !=
                                              plotWarningsData['warnings']
                                                      .length -
                                                  1)
                                            const DividerWidget(
                                                verticalHeight: 1,
                                                color: Colors.red),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
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
                                      color: Colors.green,
                                      width: 1), // Red border
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            suggestions,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!,
                                          ),
                                          if (plotSuggestions['suggestions']
                                                  .indexOf(suggestions) !=
                                              plotSuggestions['suggestions']
                                                      .length -
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
                            Column(
                              children: [
                                NutrientProgressChart(
                                  nitrogenData: nitrogenData,
                                  phosphorusData: phosphorusData,
                                  potassiumData: potassiumData,
                                  moistureData: moistureData,
                                ),
                                const SizedBox(height: 5),
                                FilledCustomButton(
                                  buttonText: 'View Analytics',
                                  icon: Icons.remove_red_eye_outlined,
                                  onPressed: () {
                                    context.pushNamed('plot-analytics');
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (irrigationLogs.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.blue, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.water_drop_outlined,
                                            color: Colors.blue, size: 20),
                                        const SizedBox(width: 5),
                                        const Text(
                                          'Irrigation Log',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        ),
                                        const Spacer(),
                                        TextRoundedEnclose(
                                            text: DateFormat('MMMM d, yyyy')
                                                .format(DateTime.now()),
                                            color: Colors.white,
                                            textColor: Colors.grey[500]!),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    ...irrigationLogs.map((log) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Started: ${log['time_started']}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!,
                                              ),
                                              const SizedBox(width: 30),
                                              Text(
                                                'Stopped: ${log['time_stopped'] ?? 'Ongoing'}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!,
                                              ),
                                            ],
                                          ),
                                          if (irrigationLogs.indexOf(log) !=
                                              irrigationLogs.length - 1)
                                            DividerWidget(
                                                verticalHeight: 1,
                                                color: Colors.grey[300]!),
                                        ],
                                      );
                                    }),
                                  ],
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
