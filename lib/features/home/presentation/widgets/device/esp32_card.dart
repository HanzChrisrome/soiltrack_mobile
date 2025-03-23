import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class Esp32Card extends ConsumerWidget {
  const Esp32Card({super.key, required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      height: 700,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragIndicator(),
          const SizedBox(height: 35),
          _buildDeviceStatus(context),
          const SizedBox(height: 15),
          TextGradient(
            text: 'Espressif32',
            fontSize: 40,
          ),
          const Text(
            'Soil Data Transmitter and Receiver',
            style: TextStyle(fontSize: 12),
          ),
          const Spacer(),
          _buildDeviceImage(),
          const Spacer(),
          isConnected ? _buildToolOptions(context) : _connectionTools(context),
          isConnected ? SizedBox(height: 30) : SizedBox.shrink(),
          isConnected
              ? Text('Device ID: 1234567890', style: TextStyle(fontSize: 12))
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildDragIndicator() {
    return Center(
      child: Container(
        width: 80,
        height: 5,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 202, 202, 202),
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }

  Widget _buildDeviceStatus(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          isConnected
              ? 'assets/elements/power.png'
              : 'assets/elements/no_power.png',
          height: 15,
          width: 15,
        ),
        const SizedBox(width: 5),
        Text(
          isConnected ? 'Device Connected' : 'Device Disconnected',
          style: TextStyle(
            color: isConnected
                ? Theme.of(context).colorScheme.onPrimary
                : Colors.red,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildToolOptions(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _buildOption(
          context,
          icon: Icons.wifi,
          label: 'Change Wi-Fi Connection',
        ),
        _buildOption(
          context,
          icon: Icons.wifi_off_rounded,
          label: 'Disconnect from Wi-Fi',
        ),
      ],
    );
  }

  Widget _buildDeviceImage() {
    return Center(
      child: Image.asset(
        isConnected
            ? 'assets/hardware/esp32_with_shadow.png'
            : 'assets/hardware/esp_not_connected_with_shadow.png',
        height: 250,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required IconData icon, required String label}) {
    return Container(
      height: 150,
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 35,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _connectionTools(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.onPrimary,
            const Color.fromARGB(255, 19, 100, 23)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pair Device',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: Text(
                'Make sure your device is turn on and located within the connection range. Follow on-screen instructions if necessary.',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary, fontSize: 14),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          FilledCustomButton(
            buttonText: 'Connect your Device',
            backgroundColor: const Color.fromARGB(255, 26, 109, 29),
            onPressed: () {
              Navigator.of(context).pop();
              context.pushNamed('wifi-scan');
            },
          )
        ],
      ),
    );
  }
}
