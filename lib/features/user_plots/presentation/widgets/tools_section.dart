import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
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
            buttonName: 'Rename Plot',
            icon: Icons.published_with_changes_rounded,
            action: () {
              showCustomizableBottomSheet(
                height: 300,
                context: context,
                centerContent: Column(
                  children: [
                    const TextGradient(text: 'Edit Plot', fontSize: 40),
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
              );
            },
          ),
        ],
      ),
    );
  }
}
