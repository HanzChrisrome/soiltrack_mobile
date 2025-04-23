import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/sensor_assignment_sheet.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/sensor_device_card.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/dynamic_bottom_sheet.dart';

class SensorGridView extends StatelessWidget {
  final List<Map<String, dynamic>> sensors;
  final SensorType sensorType;
  final List<Map<String, dynamic>> userPlots;
  final void Function(BuildContext context, int sensorId, int plotId)
      assignSensor;
  final void Function(BuildContext context, int sensorId) unassignSensor;

  const SensorGridView({
    super.key,
    required this.sensors,
    required this.sensorType,
    required this.userPlots,
    required this.assignSensor,
    required this.unassignSensor,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: 0.85,
      ),
      itemCount: sensors.length,
      itemBuilder: (context, index) {
        final sensor = sensors[index];
        return SensorDeviceCard(
          deviceName: sensor['sensor_name'],
          description: sensor['sensor_category'],
          imagePath: sensorType == SensorType.moisture
              ? 'assets/hardware/moisture_colored.png'
              : 'assets/hardware/npk_colored.png',
          imagePathDisconnected: '',
          isConnected: sensor['is_assigned'] == true,
          assignedTo: (sensor['user_plot_sensors'] as List).isNotEmpty
              ? sensor['user_plot_sensors'][0]['user_plots']['plot_name']
              : 'Unknown Plot',
          sensorType: sensorType,
          onTap: () {
            if (sensor['is_assigned'] == true) {
              showCustomBottomSheet(
                context: context,
                title: 'Unassign Sensor?',
                description:
                    'Unassigning this sensor will stop it from sending data.',
                icon: Icons.warning_amber_outlined,
                buttonText: 'Proceed',
                onPressed: () {
                  Navigator.of(context).pop();
                  unassignSensor(context, sensor['sensor_id']);
                },
              );
            } else {
              showCustomModalBottomSheet(
                context: context,
                builder: (modalContext, setState) {
                  int? selectedPlotId;
                  return SensorAssignmentSheet(
                    userPlots: userPlots,
                    sensorType: sensorType,
                    onSelectPlot: (plotId) => selectedPlotId = plotId,
                    onAssign: () async {
                      if (selectedPlotId != null) {
                        Navigator.of(modalContext).pop();
                        assignSensor(
                            context, sensor['sensor_id'], selectedPlotId!);
                      }
                    },
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
