import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/registered_plots.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class UserPlotsScreen extends ConsumerWidget {
  const UserPlotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPlot = ref.watch(soilDashboardProvider);
    final cropsNotifier = ref.read(cropProvider.notifier);
    final TextEditingController plotNameController = TextEditingController();
    final FocusNode plotNameFocusNode = FocusNode();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: 300,
                  pinned: true,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Icon(
                            Icons.eco_outlined,
                            size: 50,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const SizedBox(height: 10),
                          const TextGradient(
                            text: 'View your Registered Plots',
                            textAlign: TextAlign.start,
                            fontSize: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Column(
                          children: userPlot.userPlots.map<Widget>((plot) {
                            final plotName = plot['plot_name'];
                            final soilMoistureSensors =
                                plot['soil_moisture_sensors'] as List<dynamic>?;
                            final soilNutrientSensors =
                                plot['soil_nutrient_sensors'] as List<dynamic>?;
                            final soilMoistureSensorName =
                                (plot['soil_moisture_sensors']
                                                as List<dynamic>?)
                                            ?.isNotEmpty ==
                                        true
                                    ? plot['soil_moisture_sensors'][0]
                                            ['soil_moisture_name'] as String? ??
                                        'No sensor assigned'
                                    : 'No sensor assigned';
                            final cropName =
                                plot['crops']?['crop_name'] as String? ??
                                    'No crop assigned';
                            final assignedCategory =
                                plot['crops']?['category'] as String? ??
                                    'No category assigned';

                            return RegisteredPlots(
                              plotName: plotName,
                              cropName: cropName,
                              assignedCategory: assignedCategory,
                              soilMoistureSensorName: soilMoistureSensorName,
                              isSoilMoistureSensorAssigned:
                                  (soilMoistureSensors?.length ?? 0) > 0
                                      ? true
                                      : false,
                              isSoilNutrientSensorAssigned:
                                  (soilNutrientSensors?.length ?? 0) > 0
                                      ? true
                                      : false,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: FilledCustomButton(
                icon: Icons.add,
                buttonText: 'Add Plot',
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
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
