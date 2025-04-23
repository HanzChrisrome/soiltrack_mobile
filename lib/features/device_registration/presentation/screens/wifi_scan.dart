import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/device_registration/controller/device_controller.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class WifiScanScreen extends ConsumerStatefulWidget {
  const WifiScanScreen({super.key});

  @override
  _WifiScanScreenState createState() => _WifiScanScreenState();
}

class _WifiScanScreenState extends ConsumerState<WifiScanScreen> {
  late DeviceController deviceController;

  @override
  void initState() {
    super.initState();
    deviceController = DeviceController(context, ref);
    Future.microtask(() => deviceController.scanForDevice());
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceProvider);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenHeight <= 650 || screenWidth <= 360;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 40),
              child: Container(
                width: isSmallScreen ? 35 : 50,
                height: isSmallScreen ? 3 : 4,
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios, size: isSmallScreen ? 16 : 20),
                    Text(
                      'Go back',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Image.asset(
                    'assets/elements/handphone.png',
                    height: isSmallScreen ? 180 : 250,
                  ),
                  const SizedBox(height: 20),
                  TextGradient(
                    text: 'Connect to your',
                    fontSize: isSmallScreen ? 35 : 42,
                    letterSpacing: -2.5,
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextGradient(
                        text: 'SoilTracker',
                        fontSize: isSmallScreen ? 35 : 42,
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
                    width: isSmallScreen ? 300 : 350,
                    child: Text(
                      'Please wait while we scan for your SoilTracker device and connect it to the internet.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            letterSpacing: -0.4,
                          ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    child: OutlinedButton.icon(
                      onPressed: deviceState.isScanning
                          ? null
                          : () {
                              deviceController.scanForDevice();
                            },
                      icon: deviceState.isScanning
                          ? SizedBox(
                              width: 15,
                              height: 15,
                              child: LoadingAnimationWidget.beat(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 20),
                            )
                          : Icon(Icons.play_arrow,
                              color: Theme.of(context).colorScheme.onPrimary),
                      label: Text(
                        deviceState.isScanning
                            ? 'Scanning for Devices'
                            : 'Rescan for Devices',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
