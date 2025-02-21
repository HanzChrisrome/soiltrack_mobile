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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: 250,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                            textAlign: TextAlign.center,
                            fontSize: 40,
                            letterSpacing: -2.5,
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
                            final plotId = plot['plot_id'] as int;
                            final soilMoistureSensorName =
                                plot['soil_moisture_sensors']
                                        ?['soil_moisture_name'] as String? ??
                                    'No sensor assigned';
                            final soilNutrientSensorName =
                                plot['soil_nutrient_sensors']
                                        ?['soil_nutrient_name'] as String? ??
                                    'No sensor assigned';
                            final cropName =
                                plot['user_crops']?['crop_name'] as String? ??
                                    'No crop assigned';
                            final assignedCategory =
                                plot['user_crops']?['category'] as String? ??
                                    'No category assigned';

                            return RegisteredPlots(
                              plotId: plotId,
                              plotName: plotName,
                              cropName: cropName,
                              assignedCategory: assignedCategory,
                              soilMoistureSensorName: soilMoistureSensorName,
                              soilNutrientSensorName: soilNutrientSensorName,
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
