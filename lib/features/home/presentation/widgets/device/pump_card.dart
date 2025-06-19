import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/device_card.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/pump_valve_provider/pump_state_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';

class PumpCard extends ConsumerWidget {
  final bool isNanoConnected;

  const PumpCard({super.key, required this.isNanoConnected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceNotifier = ref.read(deviceProvider.notifier);
    final isPumpOn = ref.watch(pumpStateProvider);

    if (isPumpOn == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return DeviceCard(
      deviceName: 'Water Pump',
      description: 'Electronic Water Pump',
      imagePath: 'assets/hardware/waterpump_connected.png',
      imagePathDisconnected: 'assets/hardware/waterpump_connected.png',
      isConnected: isNanoConnected,
      isPumpOn: isPumpOn,
      onTap: () {
        if (!isNanoConnected) return;
        showCustomBottomSheet(
          context: context,
          title: isPumpOn ? 'Close Pump' : 'Open Pump',
          description:
              'Proceeding with this action will ${isPumpOn ? 'close' : 'open'} the pump.',
          icon: Icons.arrow_forward_ios_outlined,
          buttonText: 'Proceed',
          onPressed: () {
            deviceNotifier.controlPump(context, !isPumpOn);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
