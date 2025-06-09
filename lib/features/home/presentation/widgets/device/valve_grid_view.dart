import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/sensor_assignment_sheet.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/sensor_device_card.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/valve_card.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/dynamic_bottom_sheet.dart';

class ValveGridView extends StatelessWidget {
  final List<Map<String, dynamic>> userPlots;
  final bool isConnected;

  const ValveGridView({
    super.key,
    required this.userPlots,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.1 : 0.75,
      ),
      itemCount: userPlots.length,
      itemBuilder: (context, index) {
        final plot = userPlots[index];
        return ValveCard(
          deviceName: 'Valve (${plot['valve_tagging']})',
          description: 'Bounded: ${plot['plot_name']}',
          imagePath: 'assets/hardware/valves.png',
          imagePathDisconnected: 'imagePathDisconnected',
          isConnected: isConnected,
          onTap: () {},
        );
      },
    );
  }
}
