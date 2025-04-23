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

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenHeight <= 650 || screenWidth <= 360;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 20,
              vertical: isSmallScreen ? 10 : 20,
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios, size: isSmallScreen ? 16 : 20),
                      SizedBox(width: 4),
                      Text(
                        'Go back',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextGradient(
                  text: 'Connect SoilTracker',
                  fontSize: isSmallScreen ? 32 : 36,
                  letterSpacing: -2.5,
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextGradient(
                      text: 'to your Wi-Fi',
                      fontSize: isSmallScreen ? 32 : 36,
                      letterSpacing: -2.5,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Device',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: isSmallScreen ? screenWidth * 0.60 : 350,
                  child: Text(
                    'To proceed, please connect your SoilTracker device to your Wi-Fi network.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Theme.of(context).colorScheme.onPrimary,
                          letterSpacing: -0.4,
                        ),
                  ),
                ),
                const SizedBox(height: 30),
                deviceState.isScanning
                    ? Center(
                        child: SizedBox(
                          height: isSmallScreen ? 250 : 350,
                          child: LoadingAnimationWidget.fallingDot(
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: isSmallScreen ? 60 : 90),
                        ),
                      )
                    : SizedBox(
                        height: isSmallScreen ? 250 : 350,
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
                              signalIcon = Icons.signal_cellular_4_bar_outlined;
                              signalColor = Colors.amber;
                            } else {
                              signalIcon = Icons.signal_wifi_0_bar_outlined;
                              signalColor = Colors.red;
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
                              child: Card(
                                elevation: 0,
                                color: Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 12 : 16,
                                      vertical: 8),
                                  leading: Icon(
                                    signalIcon,
                                    color: signalColor,
                                    size: isSmallScreen ? 24 : 30,
                                  ),
                                  title: Text(
                                    ap.ssid,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Signal Strength: $signalStrength dBm",
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 10 : 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: isSmallScreen ? 16 : 20,
                                  ),
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
                OutlinedButton.icon(
                  onPressed: deviceState.isScanning
                      ? null
                      : () {
                          deviceController.scanForAvailableWifi();
                        },
                  icon: Icon(
                    Icons.play_arrow,
                    size: isSmallScreen ? 18 : 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    deviceState.isScanning
                        ? 'Scanning for Internet'
                        : 'Rescan for Internet Connections',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 24,
                      vertical: isSmallScreen ? 10 : 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
