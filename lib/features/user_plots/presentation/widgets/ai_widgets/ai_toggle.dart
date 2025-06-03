import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class AiToggle extends ConsumerWidget {
  final int plotId;

  const AiToggle({
    super.key,
    required this.plotId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPlot = ref.watch(soilDashboardProvider);
    final toggle = userPlot.plotToggles[plotId] ?? 'Daily';

    return DynamicContainer(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      borderColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                ref
                    .read(soilDashboardProvider.notifier)
                    .setCurrentCardToggled(plotId, 'Daily');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: toggle == 'Daily'
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Daily',
                    style: TextStyle(
                      color: toggle == 'Daily'
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
                    .setCurrentCardToggled(plotId, 'Weekly');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: toggle == 'Weekly'
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent, // Highlight 'Weekly' when selected
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Weekly',
                    style: TextStyle(
                      color: toggle == 'Weekly'
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
