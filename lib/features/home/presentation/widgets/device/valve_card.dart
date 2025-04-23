import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class ValveCard extends ConsumerWidget {
  final String deviceName;
  final String description;
  final String imagePath;
  final String imagePathDisconnected;
  final bool isConnected;
  final String? assignedTo;
  final VoidCallback? onTap;

  const ValveCard({
    super.key,
    required this.deviceName,
    required this.description,
    required this.imagePath,
    required this.imagePathDisconnected,
    required this.isConnected,
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
                    text: description,
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
                  const SizedBox(height: 5),
                  if (isConnected == false)
                    TextRoundedEnclose(
                      text: 'Disconnected',
                      color: Colors.red.withOpacity(0.1),
                      textColor: Colors.red,
                    ),
                  DynamicContainer(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    margin: const EdgeInsets.all(0),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    borderColor: Theme.of(context).colorScheme.surface,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextRoundedEnclose(
                          text: 'Valve is closed',
                          color: Colors.red.withOpacity(0.1),
                          textColor: Colors.red,
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.lock_open,
                            color: Colors.green,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
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
