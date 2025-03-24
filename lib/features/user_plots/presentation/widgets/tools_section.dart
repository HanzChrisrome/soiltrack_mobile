import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/tools_button.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class ToolsSectionWidget extends ConsumerWidget {
  const ToolsSectionWidget({super.key, required this.assignedSensor});

  final String assignedSensor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceState = ref.watch(deviceProvider);
    final deviceNotifier = ref.read(deviceProvider.notifier);
    final userPlot = ref.watch(soilDashboardProvider);
    final userPlotNotifier = ref.read(soilDashboardProvider.notifier);

    final userPlotList = userPlot.userPlots;

    final selectedPlot = userPlotList.firstWhere(
        (plot) => plot['plot_id'] == userPlot.selectedPlotId,
        orElse: () => {});

    final valveTagging = selectedPlot['valve_tagging'];
    final isValveOpen =
        deviceState.valveStates[selectedPlot['plot_id']] ?? false;

    return DynamicContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ToolsButton(
            buttonName: isValveOpen ? 'Close Valve' : 'Open Valve',
            icon: isValveOpen
                ? Icons.open_in_full_sharp
                : Icons.close_fullscreen_outlined,
            action: () {
              showCustomBottomSheet(
                  context: context,
                  title: isValveOpen ? 'Close Valve' : 'Open Valve',
                  description:
                      'Are you sure you want to ${isValveOpen ? 'close' : 'open'} the valve?',
                  icon: isValveOpen
                      ? Icons.close_fullscreen_sharp
                      : Icons.open_in_full_sharp,
                  buttonText: isValveOpen ? 'Close' : 'Open',
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (isValveOpen) {
                      deviceNotifier.openPump(context, "VLVE OFF", valveTagging,
                          selectedPlot['plot_id']);
                    } else {
                      deviceNotifier.openPump(context, "VLVE ON", valveTagging,
                          selectedPlot['plot_id']);
                    }
                  });
            },
          ),
          const SizedBox(width: 5),
          ToolsButton(
            buttonName: 'Change Soil',
            icon: Icons.layers_rounded,
            action: () {
              context.pushNamed('soil-assigning');
            },
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
            buttonName: 'Placeholder',
            icon: Icons.stay_primary_landscape_outlined,
            action: () {},
          ),
          const SizedBox(width: 5),
          ToolsButton(
            buttonName: 'Placeholder',
            icon: Icons.stay_primary_landscape_outlined,
            action: () {},
          ),
          // const SizedBox(width: 5),
          // ToolsButton(
          //   buttonName: assignedSensor == 'No sensor assigned'
          //       ? 'Assign Sensor'
          //       : 'Change Sensor',
          //   icon: Icons.sensors,
          //   action: () {
          //     showCustomizableBottomSheet(
          //       height: 500,
          //       context: context,
          //       centerContent: Consumer(builder: (context, ref, child) {
          //         final cropState = ref.watch(cropProvider);

          //         return Column(
          //           children: [
          //             TextGradient(
          //                 text: assignedSensor != 'No sensor assigned'
          //                     ? 'Change Sensor'
          //                     : 'Assign a Sensor',
          //                 fontSize: 35),
          //             const SizedBox(height: 20),
          //             if (sensorState.moistureSensors.isNotEmpty)
          //               ...sensorState.moistureSensors.map(
          //                 (sensor) {
          //                   final bool isSelected =
          //                       cropState.selectedSensor == sensor['sensor_id'];

          //                   return SensorTile(
          //                     sensorName: sensor['sensor_name'],
          //                     sensorId: sensor['sensor_id'],
          //                     isAssigned: sensor['is_assigned'] == true,
          //                     plotName: sensor['user_plot_sensors'][0]
          //                         ['user_plots']?['plot_name'],
          //                     isSelected: isSelected,
          //                     onTap: () {
          //                       cropNotifier.selectSensor(sensor['sensor_id']);
          //                     },
          //                   );
          //                 },
          //               ),
          //           ],
          //         );
          //       }),
          //       buttonText: 'Proceed',
          //       onPressed: () {},
          //     );
          //   },
          // ),
          // const SizedBox(width: 5),
          // ToolsButton(
          //   buttonName: 'Delete Plot',
          //   icon: Icons.delete_rounded,
          //   action: () {
          //     final String description;
          //     if (userPlot.userPlotMoistureData.isEmpty) {
          //       description = 'Are you sure you want to delete this plot?';
          //     } else {
          //       description =
          //           'Are you sure you want to delete this plot and all its data?';
          //     }

          //     showCustomBottomSheet(
          //       context: context,
          //       title: 'Delete Plot',
          //       description: description,
          //       icon: Icons.delete_rounded,
          //       buttonText: 'Delete',
          //       onPressed: () {
          //         Navigator.of(context).pop();
          //       },
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
