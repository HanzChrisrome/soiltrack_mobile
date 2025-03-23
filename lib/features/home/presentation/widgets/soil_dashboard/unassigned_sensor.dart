// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/sensor_tile.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class UnassignedSensor extends ConsumerWidget {
  const UnassignedSensor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPlot = ref.watch(soilDashboardProvider);
    final userPlotNotifier = ref.read(soilDashboardProvider.notifier);
    final sensorState = ref.watch(sensorsProvider);

    final unassignedNutrientSensors = sensorState.nutrientSensors
        .where((sensor) => sensor['is_assigned'] == false)
        .toList();

    final noNutrientSensorPlot = userPlot.userPlots.where((plot) {
      final plotSensors = plot['user_plot_sensors'] as List<dynamic>? ?? [];

      final hasNutrientSensor = plotSensors.any((sensor) {
        final soilSensor = sensor['soil_sensors'];
        return soilSensor != null &&
            soilSensor['sensor_category'] == 'NPK Sensor';
      });

      return !hasNutrientSensor;
    });

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[100]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextRoundedEnclose(
              text: 'Unassigned Nutrient Sensors',
              color: Colors.white,
              textColor: Colors.grey[500]!),
          const SizedBox(height: 15),
          ...unassignedNutrientSensors.map(
            (sensor) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border.all(color: const Color.fromARGB(255, 155, 31, 22)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Text(sensor['sensor_name']),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      showCustomizableBottomSheet(
                          height: 500,
                          context: context,
                          centerContent:
                              Consumer(builder: (context, ref, child) {
                            final plotState = ref.watch(soilDashboardProvider);

                            return Column(
                              children: [
                                const TextGradient(
                                    text: 'Select from plots', fontSize: 30),
                                const SizedBox(height: 30),
                                if (noNutrientSensorPlot.isNotEmpty)
                                  ...noNutrientSensorPlot.map(
                                    (plot) {
                                      final bool isSelected =
                                          plotState.selectedPlotId ==
                                              plot['plot_id'];

                                      return SensorTile(
                                          sensorName: plot['plot_name'],
                                          sensorId: plot['plot_id'],
                                          isAssigned: true,
                                          isSelected: isSelected,
                                          onTap: () {
                                            userPlotNotifier
                                                .setPlotId(plot['plot_id']);
                                          });
                                    },
                                  ),
                                FilledCustomButton(
                                  buttonText: 'Assign',
                                  onPressed: () async {
                                    await userPlotNotifier.assignNutrientSensor(
                                        context, sensor['sensor_id']);

                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          }),
                          buttonText: 'buttonText',
                          onPressed: () {},
                          showActionButton: false,
                          showCancelButton: false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Assign',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
