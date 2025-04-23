import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

enum SensorType {
  moisture,
  nutrient,
}

class SensorDeviceCard extends ConsumerWidget {
  final String deviceName;
  final String description;
  final String imagePath;
  final String imagePathDisconnected;
  final bool isConnected;
  final SensorType sensorType;
  final String? assignedTo;
  final VoidCallback? onTap;

  const SensorDeviceCard({
    super.key,
    required this.deviceName,
    required this.description,
    required this.imagePath,
    required this.imagePathDisconnected,
    required this.isConnected,
    required this.sensorType,
    this.assignedTo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth > 400 ? 15 : 12;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  height: 100,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextRoundedEnclose(
                    text:
                        isConnected ? _connectedLabel() : _disconnectedLabel(),
                    color: isConnected
                        ? Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withOpacity(0.4)
                        : Colors.red.withOpacity(0.1),
                    textColor: isConnected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _connectedLabel() {
    switch (sensorType) {
      case SensorType.moisture:
        return 'Assigned to $assignedTo';
      case SensorType.nutrient:
        return 'Assigned to $assignedTo';
    }
  }

  String _disconnectedLabel() {
    switch (sensorType) {
      case SensorType.moisture:
        return 'Unassigned';
      case SensorType.nutrient:
        return 'Unassigned';
    }
  }
}
