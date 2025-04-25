// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/device_card.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/esp32_card.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/main_toggle.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/nano_card.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/sensor_device_card.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/sensor_grid_view.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/toggle_widget.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/valve_grid_view.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/device/warning_widget.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/hardware_provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/bottom_navigation_bar.dart';
import 'package:soiltrack_mobile/widgets/collapsible_appbar.dart';
import 'package:soiltrack_mobile/widgets/collapsible_scaffold.dart';

class DeviceScreen extends ConsumerWidget {
  const DeviceScreen({super.key});

  static final scrollController = ScrollController();

  static void scrollToSensors() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorsState = ref.watch(sensorsProvider);
    final sensorNotifier = ref.read(sensorsProvider.notifier);

    final userPlot = ref.watch(soilDashboardProvider);
    final userPlotDetails = userPlot.userPlots;

    final moistureSensors = sensorsState.moistureSensors;
    final npkSensors = sensorsState.nutrientSensors;
    final toggle = userPlot.currentDeviceToggled;
    final mainToggle = userPlot.mainDeviceToggled;

    final deviceState = ref.watch(deviceProvider);
    final deviceNotifier = ref.read(deviceProvider.notifier);

    final isNanoConnected = deviceState.isNanoConnected;
    final valveState = deviceState.valveStates;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Main content of the screen
          CollapsibleSliverScaffold(
            headerBuilder: (context, isCollapsed) {
              return CollapsibleSliverAppBar(
                isCollapsed: isCollapsed,
                collapsedTitle: 'Registered Devices',
                title: 'Registered \nDevices',
                backgroundColor: Theme.of(context).colorScheme.surface,
                showCollapsedBack: false,
              );
            },
            bodySlivers: [
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      MainToggle(),
                      if (mainToggle == 'Controller')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WarningWidget(
                              headerText: 'ESP32 AND ARDUINO NANO',
                              bodyText:
                                  'If your ESP32 or Arduino Nano is not connected, the functionality of the whole hardware and system will be affected.',
                            ),
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
                                  isConnected: isConnected,
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
                                return DeviceCard(
                                  deviceName: 'Arduino Nano',
                                  description: 'Soiltracker and Updater',
                                  imagePath: 'assets/hardware/nano_colored.png',
                                  imagePathDisconnected:
                                      'assets/hardware/nano_not_connected.png',
                                  isConnected: isNanoConnected,
                                  onTap: () {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return NanoCard();
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      if (mainToggle == 'Pump')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WarningWidget(
                                headerText: 'WATER PUMP AND VALVES',
                                bodyText:
                                    'If your ESP32 or Arduino Nano is not connected, '
                                    'the water pump and valves will not be able to connect and function automatically or manually.'),
                            Consumer(
                              builder: (context, ref, child) {
                                return DeviceCard(
                                  deviceName: 'Water Pump',
                                  description: 'Electronic Water Pump',
                                  imagePath:
                                      'assets/hardware/waterpump_connected.png',
                                  imagePathDisconnected:
                                      'assets/hardware/waterpump_connected.png',
                                  isConnected: isNanoConnected,
                                  onTap: () {
                                    if (isNanoConnected)
                                      showCustomBottomSheet(
                                        context: context,
                                        title: deviceState.isPumpOpen
                                            ? 'Close Pump and All Valves'
                                            : 'Open Pump and \nAll Valves',
                                        description:
                                            'Proceeding with this action will open the pump and all valves associated with this device.',
                                        icon: Icons.arrow_forward_ios_outlined,
                                        buttonText: 'Proceed',
                                        onPressed: () {
                                          if (deviceState.isPumpOpen) {
                                            deviceNotifier.closeAll(context);
                                          } else {
                                            deviceNotifier.openAll(context);
                                          }
                                          Navigator.of(context).pop();
                                        },
                                      );
                                  },
                                );
                              },
                            ),
                            ValveGridView(
                                userPlots: userPlotDetails, isConnected: true),
                            const SizedBox(height: 10),
                          ],
                        ),
                      WarningWidget(
                        headerText: 'MOISTURE AND NUTRIENT SENSOR',
                        bodyText:
                            'If your ESP32 or Arduino Nano is not connected, '
                            'the moisture and nutrient sensors will not be able to connect and send data.',
                      ),
                      DeviceToggle(),
                      SensorGridView(
                        sensors:
                            toggle == 'Moisture' ? moistureSensors : npkSensors,
                        sensorType: toggle == 'Moisture'
                            ? SensorType.moisture
                            : SensorType.nutrient,
                        userPlots: userPlotDetails,
                        assignSensor: (context, sensorId, plotId) {
                          sensorNotifier.assignSensor(
                              context, sensorId, plotId);
                        },
                        unassignSensor: (context, sensorId) {
                          sensorNotifier.unassignSensor(context, sensorId);
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(
              selectedIndex: 2,
            ),
          ),
        ],
      ),
    );
  }
}
