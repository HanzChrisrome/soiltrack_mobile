import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/connection_indicator.dart';

class DeviceCard extends ConsumerWidget {
  final String deviceName;
  final String description;
  final String imagePath;
  final String imagePathDisconnected;
  final bool isConnected;
  final VoidCallback? onTap;

  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.description,
    required this.imagePath,
    required this.imagePathDisconnected,
    required this.isConnected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define dynamic sizes
    double imageHeight = screenWidth > 400 ? 200 : 150;
    double titleFontSize = screenWidth > 400 ? 25 : 20;
    double descFontSize = screenWidth > 400 ? 12 : 10;

    double arrowIconSize = screenWidth > 400 ? 20 : 18;

    double statusFontSize = screenWidth > 400 ? 14 : 10;
    double indicatorRadius = screenWidth > 400 ? 10 : 8;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
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
              height: imageHeight,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Image.asset(
                  isConnected ? imagePath : imagePathDisconnected,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Expanded(
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
                        Text(
                          description,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: descFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isConnected == false || deviceName != 'Water Pump')
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        ConnectionIndicator(isConnected: isConnected),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_right_sharp,
                            color: Colors.white,
                            size: arrowIconSize,
                          ),
                        ),
                      ],
                    ),
                  if (deviceName == 'Water Pump' && isConnected)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: indicatorRadius,
                                backgroundColor:
                                    isConnected ? Colors.green : Colors.red,
                                child: Icon(
                                  Icons.electric_bolt,
                                  color: Colors.white,
                                  size: indicatorRadius, // matches the radius
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isConnected ? 'Pump is off' : 'Disconnected',
                                style: TextStyle(
                                  color: isConnected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Colors.red,
                                  fontSize: statusFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
