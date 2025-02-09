// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                  const SizedBox(height: 20.0),
                  const TextGradient(
                      text: 'Connect SoilTracker to the Internet',
                      fontSize: 30,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 5.0),
                  SizedBox(
                    child: Text(
                      'To continue, connect soiltracker to your internet connection',
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
                height: 400,
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: const Color.fromARGB(255, 223, 223, 223)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: deviceState.isScanning
                    ? Center(
                        child: SpinKitWave(
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 50.0,
                        ),
                      )
                    : deviceState.availableNetworks.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No device found',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      letterSpacing: -0.4,
                                    ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: deviceState.availableNetworks.length,
                            itemBuilder: (context, index) {
                              final ap = deviceState.availableNetworks[index];
                              return ListTile(
                                title: Text(ap.ssid),
                                subtitle: Text(
                                  "Signal Strength: ${ap.level} dBm",
                                ),
                                onTap: () {
                                  deviceNotifier.selectDevice(ap.ssid);
                                  context.pushNamed('wifi-password');
                                },
                              );
                            },
                          ),
              ),
              const SizedBox(height: 30.0),
              SizedBox(
                child: OutlinedButton.icon(
                  onPressed: deviceState.isScanning
                      ? null
                      : () {
                          deviceController.scanForAvailableWifi();
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
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}
