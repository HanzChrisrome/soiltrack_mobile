// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/helper/user_plots_helper.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/crop_threshold.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/line_chart.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_condition.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_details.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_suggestions.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/plot_warnings.dart';
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
    final UserPlotsHelper plotHelper = UserPlotsHelper();
    final userPlot = ref.watch(soilDashboardProvider);
    final userPlotNotifier = ref.read(soilDashboardProvider.notifier);
    final deviceState = ref.watch(deviceProvider);
    final deviceStateNotifier = ref.read(deviceProvider.notifier);

    final selectedPlot = userPlot.userPlots.firstWhere(
      (plot) => plot['plot_id'] == userPlot.selectedPlotId,
      orElse: () => {},
    );

    final plotName = selectedPlot['plot_name'] ?? 'No plot found';
    final sensors = selectedPlot['user_plot_sensors'] ?? [];

    final assignedMoistureSensor =
        plotHelper.getSensorName(sensors, 'Moisture Sensor');
    final assignedNutrientSensor =
        plotHelper.getSensorName(sensors, 'NPK Sensor');

    final plotWarningsData = userPlot.nutrientWarnings.firstWhere(
      (warning) => warning['plot_id'] == userPlot.selectedPlotId,
      orElse: () => {},
    );

    final plotSuggestions = userPlot.plotsSuggestion.firstWhere(
        (s) => s['plot_id'] == userPlot.selectedPlotId,
        orElse: () => {});

    final irrigationLogs =
        (selectedPlot['irrigation_log'] as List<dynamic>? ?? [])
            .where((log) => log['plot_id'] == userPlot.selectedPlotId)
            .map((log) => {
                  'mac_address': log['mac_address'],
                  'time_started':
                      plotHelper.formatTimestamp(log['time_started']),
                  'time_stopped': log['time_stopped'] != null
                      ? plotHelper.formatTimestamp(log['time_stopped'])
                      : 'Ongoing',
                })
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.axis == Axis.vertical) {
                _updateAppBarTitle(
                  scrollNotification.metrics.pixels,
                  200.0,
                );
              }
              return true;
            },
            child: CustomScrollView(
              slivers: [
                _buildSilverAppBar(
                    context, plotName, selectedPlot, userPlotNotifier),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      PlotCondition(
                        plotName: plotName,
                      ),
                      ToolsSectionWidget(
                          assignedSensor: assignedNutrientSensor),
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
                      PlotWarnings(plotWarningsData: plotWarningsData),
                      PlotSuggestions(plotSuggestions: plotSuggestions),
                      Column(
                        children: [
                          NutrientProgressChart(),
                          FilledCustomButton(
                            buttonText: 'View Detailed Analytics',
                            icon: Icons.remove_red_eye_outlined,
                            onPressed: () {
                              context.pushNamed('plot-analytics');
                            },
                          ),
                        ],
                      ),
                      PlotDetailsWidget(
                          assignedSensor: assignedMoistureSensor,
                          assignedNutrientSensor: assignedNutrientSensor,
                          soilType: selectedPlot['soil_type'] ??
                              'No soil type found'),
                      CropThresholdWidget(plotDetails: selectedPlot),
                      const SizedBox(height: 10),
                      if (irrigationLogs.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue, width: 1),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildSilverAppBar(
      BuildContext context,
      String plotName,
      Map<String, dynamic> selectedPlot,
      SoilDashboardNotifier userPlotNotifier) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Icon(Icons.arrow_back_ios_new_outlined,
              color: isAppBarCollapsed ? Colors.green : Colors.white),
        ),
        onPressed: () {
          context.go('/home?index=1');
        },
      ),
      pinned: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        title: isAppBarCollapsed
            ? Container(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  plotName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
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
                image: AssetImage('assets/background/first_container.png'),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextHeader(
                          text: plotName, fontSize: 35, color: Colors.white),
                      IconButton(
                        onPressed: () {
                          showCustomizableBottomSheet(
                            height: 300,
                            context: context,
                            centerContent: Column(
                              children: [
                                const TextGradient(
                                    text: 'Edit Plot', fontSize: 40),
                                const SizedBox(height: 20),
                                TextFieldWidget(
                                  label: plotName,
                                  controller: plotNameController,
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
                              plotNameFocusNode.requestFocus();
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Selected Crop: ${selectedPlot['user_crops']?['crop_name'] ?? 'No crop'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
