// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/device_registration/controller/device_controller.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/elements/handphone.png',
                    height: 350,
                  ),
                  const SizedBox(height: 20.0),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 9, 73, 14),
                        Color.fromARGB(255, 54, 201, 24)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Connect to SoilTracker',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontSize: 25,
                                letterSpacing: -1.3,
                                color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  SizedBox(
                    width: 300,
                    child: Text(
                      'Wait for the SoilTracker device to show and connect it to the internet.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            letterSpacing: -0.4,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
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
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
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
      ),
    );
  }
}
