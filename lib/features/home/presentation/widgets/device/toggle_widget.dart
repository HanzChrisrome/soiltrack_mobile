import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class DeviceToggle extends ConsumerWidget {
  const DeviceToggle({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDeviceToggle =
        ref.watch(soilDashboardProvider).currentDeviceToggled;

    return DynamicContainer(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                ref
                    .read(soilDashboardProvider.notifier)
                    .setDeviceToggled('Moisture');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: currentDeviceToggle == 'Moisture'
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Moisture Sensor',
                    style: TextStyle(
                      color: currentDeviceToggle == 'Moisture'
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                ref
                    .read(soilDashboardProvider.notifier)
                    .setDeviceToggled('NPK');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: currentDeviceToggle == 'NPK'
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent, // Highlight 'Weekly' when selected
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'NPK Sensor',
                    style: TextStyle(
                      color: currentDeviceToggle == 'NPK'
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
