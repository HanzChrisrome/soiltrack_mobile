import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/plot_tile.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/sensor_device_card.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class SensorAssignmentSheet extends StatefulWidget {
  const SensorAssignmentSheet({
    super.key,
    required this.userPlots,
    required this.onSelectPlot,
    required this.onAssign,
    required this.sensorType,
  });

  final List<Map<String, dynamic>> userPlots;
  final void Function(int) onSelectPlot;
  final VoidCallback onAssign;
  final SensorType sensorType;

  @override
  State<SensorAssignmentSheet> createState() => _SensorAssignmentSheetState();
}

class _SensorAssignmentSheetState extends State<SensorAssignmentSheet> {
  int? selectedPlotId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TextGradient(text: 'Select from your plot', fontSize: 30),
          SizedBox(
            width: 300,
            child: Text(
              'Click a plot to assign the sensor',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 15),
          if (widget.userPlots.isNotEmpty)
            ...widget.userPlots.map((plot) {
              final plotId = int.parse(plot['plot_id'].toString());
              return PlotTile(
                plotName: plot['plot_name'],
                plotId: plotId,
                isSelected: selectedPlotId == plotId,
                onTap: () {
                  setState(() {
                    selectedPlotId = plotId;
                  });
                  widget.onSelectPlot(plotId);
                },
                sensorDetails: (plot['user_plot_sensors'] as List)
                    .where((sensor) {
                      final sensorCategory =
                          sensor['soil_sensors']?['sensor_category'];
                      return sensorCategory ==
                          sensorCategoryForType(widget.sensorType);
                    })
                    .map((sensor) =>
                        sensor['soil_sensors']?['sensor_name'] ?? '')
                    .join(', '),
              );
            }),
          const SizedBox(height: 15),
          FilledCustomButton(
            buttonText: 'Assign',
            onPressed: widget.onAssign,
          ),
        ],
      ),
    );
  }

  String sensorCategoryForType(SensorType type) {
    switch (type) {
      case SensorType.moisture:
        return 'Moisture Sensor';
      case SensorType.nutrient:
        return 'NPK Sensor';
    }
  }
}
