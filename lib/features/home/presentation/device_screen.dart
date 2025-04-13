// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/device_card.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/esp32_card.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/nano_card.dart';
import 'package:soiltrack_mobile/widgets/text_header.dart';

class DeviceScreen extends ConsumerWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                leading: null,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/background/first_container.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            TextHeader(
                                text: 'My Devices',
                                fontSize: 35,
                                color: Colors.white),
                            Text(
                              'Your registered devices.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Column(
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final isConnected =
                                  ref.watch(deviceProvider).isEspConnected;
                              return DeviceCard(
                                deviceName: 'Espressif32',
                                description: 'Soil Data Transmitter',
                                imagePath: 'assets/hardware/esp_colored.png',
                                imagePathDisconnected:
                                    'assets/hardware/esp_not_connected.png',
                                isConnected:
                                    isConnected, // <-- This now updates correctly
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return Esp32Card();
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final isConnected =
                                  ref.watch(deviceProvider).isNanoConnected;
                              return DeviceCard(
                                deviceName: 'Arduino Nano',
                                description: 'Soiltracker and Updater',
                                imagePath: 'assets/hardware/nano_colored.png',
                                imagePathDisconnected:
                                    'assets/hardware/nano_not_connected.png',
                                isConnected: isConnected,
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return NanoCard(
                                        isConnected: isConnected,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
