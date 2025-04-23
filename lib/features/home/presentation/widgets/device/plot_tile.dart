import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/custom_accordion.dart';

class PlotTile extends StatelessWidget {
  const PlotTile({
    super.key,
    required this.plotName,
    required this.plotId,
    required this.isSelected,
    required this.onTap,
    required this.sensorDetails,
  });

  final String plotName;
  final int plotId;
  final bool isSelected;
  final VoidCallback onTap;
  final String sensorDetails;

  @override
  Widget build(BuildContext context) {
    final displaySensorDetails =
        sensorDetails.isEmpty ? 'No Sensors Assigned' : sensorDetails;

    return GestureDetector(
      onTap: onTap,
      child: CustomAccordion(
        borderColor: isSelected
            ? Theme.of(context).colorScheme.onSecondary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.onSecondary.withOpacity(0.2)
            : Colors.transparent,
        titleText: plotName,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sensors: $displaySensorDetails',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
