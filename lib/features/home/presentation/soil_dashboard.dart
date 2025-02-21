// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/registered_plots.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
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
    final cropsNotifier = ref.read(cropProvider.notifier);
    final userPlot = ref.watch(soilDashboardProvider);
    final soilNotifier = ref.read(soilDashboardProvider.notifier);
    final soilSensorNotifier = ref.read(sensorsProvider.notifier);

    if (userPlot.userPlots.isEmpty &&
        !userPlot.isFetchingUserPlots &&
        userPlot.error == null) {
      Future.microtask(() {
        soilNotifier.fetchUserPlots();
        soilSensorNotifier.fetchSensors();
      });
    }

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
                          horizontal: 20, vertical: 10),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Column(
                              children: [
                                Column(
                                  children: userPlot.userPlots.map<Widget>(
                                    (plot) {
                                      final plotName = plot['plot_name'];
                                      final plotId = plot['plot_id'] as int;
                                      final soilMoistureSensorName =
                                          plot['soil_moisture_sensors']
                                                      ?['soil_moisture_name']
                                                  as String? ??
                                              'No sensor assigned';
                                      final soilNutrientSensorName =
                                          plot['soil_nutrient_sensors']
                                                      ?['soil_nutrient_name']
                                                  as String? ??
                                              'No sensor assigned';
                                      final cropName = plot['user_crops']
                                              ?['crop_name'] as String? ??
                                          'No crop assigned';
                                      final assignedCategory =
                                          plot['user_crops']?['category']
                                                  as String? ??
                                              'No category assigned';

                                      return RegisteredPlots(
                                        plotId: plotId,
                                        plotName: plotName,
                                        cropName: cropName,
                                        assignedCategory: assignedCategory,
                                        soilMoistureSensorName:
                                            soilMoistureSensorName,
                                        soilNutrientSensorName:
                                            soilNutrientSensorName,
                                      );
                                    },
                                  ).toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            OutlineCustomButton(
                              buttonText: 'Add Another Plot',
                              iconData: Icons.add_box_outlined,
                              onPressed: () {
                                showCustomizableBottomSheet(
                                  context: context,
                                  height: 590,
                                  centerContent: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const TextGradient(
                                          text: 'Name your plot', fontSize: 40),
                                      const SizedBox(height: 20),
                                      TextFieldWidget(
                                        label: 'Plot Name',
                                        controller: plotNameController,
                                        focusNode: plotNameFocusNode,
                                      ),
                                    ],
                                  ),
                                  buttonText: 'Proceed',
                                  onPressed: () {
                                    Navigator.pop(context);
                                    cropsNotifier.setPlotName(
                                        plotNameController.text, context);
                                  },
                                  onSheetCreated: () {
                                    plotNameFocusNode.requestFocus();
                                  },
                                );
                              },
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
