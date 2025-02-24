import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/sensor_tile.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/tools_button.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class ToolsSectionWidget extends ConsumerWidget {
  const ToolsSectionWidget({super.key, required this.assignedSensor});

  final String assignedSensor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceState = ref.watch(deviceProvider);
    final deviceNotifier = ref.read(deviceProvider.notifier);
    final sensorState = ref.watch(sensorsProvider);
    final cropNotifier = ref.watch(cropProvider.notifier);
    final userPlot = ref.watch(soilDashboardProvider);
    final userPlotNotifier = ref.read(soilDashboardProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ToolsButton(
            buttonName: deviceState.isPumpOpen ? 'Close Pump' : 'Open Pump',
            icon: deviceState.isPumpOpen
                ? Icons.open_in_full_sharp
                : Icons.close_fullscreen_outlined,
            action: () {
              showCustomBottomSheet(
                context: context,
                title: deviceState.isPumpOpen ? 'Close Pump' : 'Open Pump',
                description:
                    'Are you sure you want to ${deviceState.isPumpOpen ? 'close' : 'open'} the pump?',
                icon: deviceState.isPumpOpen
                    ? Icons.close_fullscreen_sharp
                    : Icons.open_in_full_sharp,
                buttonText: deviceState.isPumpOpen ? 'Close' : 'Open',
                onPressed: () {
                  Navigator.of(context).pop();
                  if (deviceState.isPumpOpen) {
                    deviceNotifier.openPump(context, "PUMP ON");
                  } else {
                    deviceNotifier.openPump(context, "PUMP OFF");
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
            buttonName: assignedSensor == 'No sensor assigned'
                ? 'Assign Sensor'
                : 'Change Sensor',
            icon: Icons.sensors,
            action: () {
              showCustomizableBottomSheet(
                height: 500,
                context: context,
                centerContent: Consumer(builder: (context, ref, child) {
                  final cropState = ref.watch(cropProvider);

                  return Column(
                    children: [
                      TextGradient(
                          text: assignedSensor != 'No sensor assigned'
                              ? 'Change Sensor'
                              : 'Assign a Sensor',
                          fontSize: 35),
                      const SizedBox(height: 20),
                      if (sensorState.moistureSensors.isNotEmpty)
                        ...sensorState.moistureSensors.map(
                          (sensor) {
                            final bool isSelected = cropState.selectedSensor ==
                                sensor['soil_moisture_sensor_id'];

                            return SensorTile(
                              sensorName: sensor['soil_moisture_name'],
                              sensorId: sensor['soil_moisture_sensor_id'],
                              isAssigned: sensor['is_assigned'] == true,
                              plotName: sensor['user_plots']?['plot_name'],
                              isSelected: isSelected,
                              onTap: () {
                                cropNotifier.selectSensor(
                                    sensor['soil_moisture_sensor_id']);
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
          const SizedBox(width: 5),
          ToolsButton(
            buttonName: 'Delete Plot',
            icon: Icons.delete_rounded,
            action: () {
              final String description;
              if (userPlot.userPlotData.isEmpty) {
                description = 'Are you sure you want to delete this plot?';
              } else {
                description =
                    'Are you sure you want to delete this plot and all its data?';
              }

              showCustomBottomSheet(
                context: context,
                title: 'Delete Plot',
                description: description,
                icon: Icons.delete_rounded,
                buttonText: 'Delete',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
