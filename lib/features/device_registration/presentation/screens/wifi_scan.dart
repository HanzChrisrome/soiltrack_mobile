// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';

class WifiScanScreen extends ConsumerStatefulWidget {
  const WifiScanScreen({super.key});

  @override
  _WifiScanScreenState createState() => _WifiScanScreenState();
}

class _WifiScanScreenState extends ConsumerState<WifiScanScreen> {
  @override
  void initState() {
    super.initState();

    final deviceState = ref.read(deviceProvider);
    if (deviceState.availableDevices.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final deviceNotifier = ref.read(deviceProvider.notifier);
        deviceNotifier.scanForDevices();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceProvider);
    final deviceNotifier = ref.read(deviceProvider.notifier);

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
                  Icon(
                    Icons.wifi,
                    size: 50.0,
                    color: Theme.of(context).colorScheme.onPrimary,
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
                        'Scanning for SoilTracker',
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
              Container(
                height: 300, // Set the desired height
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
                child: deviceState.isScanning
                    ? Center(
                        child: SpinKitWave(
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 50.0,
                        ),
                      )
                    : deviceState.availableDevices.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'No device found',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    letterSpacing: -0.4,
                                  ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: deviceState.availableDevices.length,
                            itemBuilder: (context, index) {
                              final ap = deviceState.availableDevices[index];
                              return ListTile(
                                title: Text(ap.ssid),
                                subtitle: Text(
                                  "Signal Strength: ${ap.level} dBm",
                                ),
                                onTap: () {
                                  deviceNotifier.selectDevice(ap.ssid);
                                  Navigator.pushNamed(context, "/connect");
                                },
                              );
                            },
                          ),
              ),
              const SizedBox(height: 30.0),
              deviceState.isScanning
                  ? SizedBox(
                      width: 300,
                      child: Text(
                        'Scanning for devices...',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              letterSpacing: -0.4,
                            ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          deviceNotifier.scanForDevices();
                        },
                        icon: Icon(
                          Icons.play_arrow,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(
                          'Rescan for Devices',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}
