import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';

class SensorTile extends ConsumerWidget {
  const SensorTile({
    super.key,
    required this.sensorName,
    required this.sensorId,
  });

  final String sensorName;
  final int sensorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropState = ref.watch(cropProvider);
    final cropNotifier = ref.watch(cropProvider.notifier);
    final sensorState = ref.watch(sensorsProvider);

    final bool isSelected = cropState.selectedSensor == sensorId;

    // Find the sensor by sensorId
    final sensor = sensorState.sensors.firstWhere(
      (s) => s['soil_moisture_sensor_id'] == sensorId,
      orElse: () => {},
    );

    final bool isAssigned = sensor['is_assigned'] == true;

    final String? cropName =
        (isAssigned && sensor['plot_id'] != null && sensor['plot_id'] is int)
            ? (sensor['user_plots']?['crops']?['crop_name'] as String?)
            : null;

    return GestureDetector(
      onTap: () {
        cropNotifier.selectSensor(sensorId);
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
            const SizedBox(width: 15),
            if (isAssigned && cropName != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Assigned to: $cropName',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 173, 173, 173),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
