import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/valve_card.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/pump_valve_provider/valve_state_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';

class ValveGridView extends ConsumerWidget {
  final List<Map<String, dynamic>> userPlots;
  final bool isConnected;

  const ValveGridView({
    super.key,
    required this.userPlots,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceNotifier = ref.read(deviceProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = 2;
        final spacing = 5 * (crossAxisCount - 1);
        final itemWidth = (screenWidth - spacing) / crossAxisCount;
        final itemHeight = itemWidth * (isConnected ? 1.5 : 1.5);
        final aspectRatio = itemWidth / itemHeight;

        return GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: aspectRatio,
          ),
          itemCount: userPlots.length,
          itemBuilder: (context, index) {
            final plot = userPlots[index];
            final plotId = plot['plot_id'] as int;
            final valveTagging = plot['valve_tagging'];

            return Consumer(
              builder: (context, ref, _) {
                final isValveOn = ref.watch(valveStatesProvider.select(
                  (valves) => valves[plotId] ?? false,
                ));

                return ValveCard(
                  deviceName: 'Valve ($valveTagging)',
                  description: 'Bounded: ${plot['plot_name']}',
                  imagePath: 'assets/hardware/valves.png',
                  imagePathDisconnected: 'imagePathDisconnected',
                  isConnected: isConnected,
                  isOpen: isValveOn,
                  onTap: () {
                    showCustomBottomSheet(
                      context: context,
                      title: isValveOn ? 'Close Valve' : 'Open Valve',
                      icon: isValveOn
                          ? Icons.close_fullscreen_sharp
                          : Icons.open_in_full_sharp,
                      buttonText: isValveOn ? 'Close' : 'Open',
                      onPressed: () {
                        Navigator.of(context).pop();
                        deviceNotifier.openOrCloseValve(
                          context,
                          isValveOn ? "VLVE OFF" : "VLVE ON",
                          valveTagging,
                          plotId,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
