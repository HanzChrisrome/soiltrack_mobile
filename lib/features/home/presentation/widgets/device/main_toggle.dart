import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class MainToggle extends ConsumerWidget {
  const MainToggle({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainDeviceToggle = ref.watch(soilDashboardProvider).mainDeviceToggled;

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
                    .setMainDeviceToggle('Controller');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: mainDeviceToggle == 'Controller'
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Controller',
                    style: TextStyle(
                      color: mainDeviceToggle == 'Controller'
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
                    .setMainDeviceToggle('Pump');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: mainDeviceToggle == 'Pump'
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent, // Highlight 'Weekly' when selected
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Pump and Valves',
                    style: TextStyle(
                      color: mainDeviceToggle == 'Pump'
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
