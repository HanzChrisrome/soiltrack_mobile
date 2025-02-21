// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/device_registration/controller/device_controller.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class WifiSetupScreen extends ConsumerStatefulWidget {
  const WifiSetupScreen({super.key});

  @override
  _WifiSetupScreenState createState() => _WifiSetupScreenState();
}

class _WifiSetupScreenState extends ConsumerState<WifiSetupScreen> {
  late DeviceController deviceController;

  @override
  void initState() {
    super.initState();
    deviceController = DeviceController(context, ref);
    Future.microtask(() => deviceController.scanForAvailableWifi());
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceProvider);
    final deviceNotifier = ref.read(deviceProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 40),
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 20),
                    Text('Go back'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const TextGradient(
                    text: 'Connect SoilTracker',
                    fontSize: 35,
                    letterSpacing: -2.5,
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TextGradient(
                        text: 'to your Wi-Fi',
                        fontSize: 35,
                        letterSpacing: -2.5,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Device',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 350,
                    child: Text(
                      'To proceed, please connect your SoilTracker device to your Wi-Fi network.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            letterSpacing: -0.4,
                          ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  deviceState.isScanning
                      ? Center(
                          child: SizedBox(
                            height: 350,
                            child: LoadingAnimationWidget.fallingDot(
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 90),
                          ),
                        )
                      : SizedBox(
                          height: 350,
                          child: ListView.builder(
                            itemCount: deviceState.availableNetworks.length,
                            itemBuilder: (context, index) {
                              final ap = deviceState.availableNetworks[index];
                              final signalStrength = ap.level;

                              IconData signalIcon;
                              Color signalColor;
                              if (signalStrength >= -50) {
                                signalIcon = Icons.signal_wifi_4_bar;
                                signalColor = Colors.green;
                              } else if (signalStrength >= -70) {
                                signalIcon =
                                    Icons.signal_cellular_4_bar_outlined;
                                signalColor = Colors.amber;
                              } else {
                                signalIcon = Icons.signal_wifi_0_bar_outlined;
                                signalColor = Colors.red;
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Card(
                                  elevation: 0,
                                  color: Theme.of(context).colorScheme.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      signalIcon,
                                      color: signalColor,
                                      size: 30,
                                    ),
                                    title: Text(
                                      ap.ssid,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Signal Strength: $signalStrength dBm",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20),
                                    onTap: () {
                                      deviceNotifier.selectDevice(ap.ssid);
                                      context.pushNamed('wifi-password');
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 20),
                  SizedBox(
                    child: OutlinedButton.icon(
                      onPressed: deviceState.isScanning
                          ? null
                          : () {
                              deviceController.scanForAvailableWifi();
                            },
                      icon: Icon(Icons.play_arrow,
                          color: Theme.of(context).colorScheme.onPrimary),
                      label: Text(
                        deviceState.isScanning
                            ? 'Scanning for Internet'
                            : 'Rescan for Internet Connections',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
