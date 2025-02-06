import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';

class SensorTile extends ConsumerWidget {
  const SensorTile({super.key, required this.sensorName});

  final String sensorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropState = ref.watch(cropProvider);
    final cropNotifier = ref.watch(cropProvider.notifier);

    final bool isSelected = cropState.selectedSensor == sensorName;

    return GestureDetector(
      onTap: () {
        cropNotifier.selectSensor(sensorName);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 226, 238, 227)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 33, 156, 17)
                : const Color.fromARGB(255, 200, 200, 200),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sensorName,
              style: TextStyle(
                fontSize: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : const Color.fromARGB(255, 126, 126, 126),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
