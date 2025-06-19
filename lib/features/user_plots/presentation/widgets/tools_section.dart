import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/pump_valve_provider/valve_state_provider.dart';

import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/tools_button.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/customizable_bottom_sheet.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class ToolsSectionWidget extends ConsumerWidget {
  const ToolsSectionWidget(
      {super.key,
      required this.assignedSensor,
      required this.plotName,
      required this.plotNameController});

  final String assignedSensor;
  final String plotName;
  final TextEditingController plotNameController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceNotifier = ref.read(deviceProvider.notifier);
    final userPlot = ref.watch(soilDashboardProvider);
    final userPlotNotifier = ref.read(soilDashboardProvider.notifier);

    final userPlotList = userPlot.userPlots;

    final selectedPlot = userPlotList.firstWhere(
        (plot) => plot['plot_id'] == userPlot.selectedPlotId,
        orElse: () => {});

    final valveTagging = selectedPlot['valve_tagging'];
    final plotId = selectedPlot['plot_id'];

    final valveStates = ref.watch(valveStatesProvider);
    final isValveOpen = valveStates[plotId] ?? false;

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
                    deviceNotifier.openOrCloseValve(
                        context, "VLVE OFF", valveTagging, plotId);
                  } else {
                    deviceNotifier.openOrCloseValve(
                        context, "VLVE ON", valveTagging, plotId);
                  }
                },
              );
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
              context.pushNamed('add-crops');
            },
          ),
          const SizedBox(width: 5),
          // ToolsButton(
          //   buttonName: 'Rename Plot',
          //   icon: Icons.published_with_changes_rounded,
          //   action: () {
          //     showCustomizableBottomSheet(
          //       height: 300,
          //       context: context,
          //       centerContent: Column(
          //         children: [
          //           const TextGradient(text: 'Edit Plot', fontSize: 40),
          //           const SizedBox(height: 20),
          //           TextFieldWidget(
          //             label: plotName,
          //             controller: plotNameController,
          //           ),
          //         ],
          //       ),
          //       buttonText: 'Proceed',
          //       onPressed: (bottomSheetContext) {
          //         Navigator.of(context).pop();
          //         userPlotNotifier.editPlotName(
          //           context,
          //           plotNameController.text,
          //         );
          //         plotNameController.clear();
          //       },
          //       onCancelPressed: (bottomSheetContext) {
          //         Navigator.of(context).pop();
          //         plotNameController.clear();
          //       },
          //     );
          //   },
          // ),
          // ToolsButton(
          //   buttonName: 'Irrigation Type',
          //   icon: Icons.water_drop_rounded,
          //   action: () {
          //     context.pushNamed('irrigation-schedule');
          //   },
          // ),
          ToolsButton(
            buttonName: 'Add Polygon',
            icon: Icons.add_location_alt_rounded,
            action: () {
              userPlotNotifier.setEditingUserPlot(true);
              context.pushNamed('polygon-maps');
            },
          ),
        ],
      ),
    );
  }
}
