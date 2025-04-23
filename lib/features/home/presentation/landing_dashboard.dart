import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/chat_bot/provider/chatbot_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/home/greeting_widget.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/home/soil_condition.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/home/weather_widget.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/weather_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_navigation_bar.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class LandingDashboard extends ConsumerStatefulWidget {
  const LandingDashboard({super.key});

  @override
  ConsumerState<LandingDashboard> createState() => _LandingDashboardState();
}

class _LandingDashboardState extends ConsumerState<LandingDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(deviceProvider.notifier).checkDeviceStatus(context);
      await ref.read(weatherProvider.notifier).fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userPlotState = ref.watch(soilDashboardProvider);
    final deviceState = ref.watch(deviceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content of the screen
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GreetingWidget(userName: authState.userName!),
                    const SizedBox(height: 10),
                    SoilCondition(),
                    const SizedBox(height: 10),
                    const WeatherWidget(),
                    if (userPlotState.deviceWarnings.isNotEmpty ||
                        deviceState.isEspConnected == false)
                      DynamicContainer(
                        backgroundColor: Colors.transparent,
                        borderColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextGradient(
                                text: 'Device Warnings', fontSize: 20),
                            if (!deviceState.isEspConnected)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const DividerWidget(verticalHeight: 5),
                                  Text(
                                    'Device Connection Warning',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          height: 0.8,
                                          color: const Color.fromARGB(
                                              255, 141, 19, 10),
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      'Your SoilTracker Device might not be connected to the internet. Please check the device connection.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: const Color.fromARGB(
                                                255, 97, 97, 97),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            if (userPlotState.deviceWarnings.isNotEmpty)
                              ...userPlotState.deviceWarnings
                                  .map((deviceWarning) {
                                final plotName = deviceWarning['plot_name'];
                                final warnings = List<String>.from(
                                    deviceWarning['device_warnings']);

                                if (warnings.isEmpty) return const SizedBox();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const DividerWidget(verticalHeight: 5),
                                    Text(
                                      '$plotName Warning',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            height: 0.8,
                                            color: const Color.fromARGB(
                                                255, 141, 19, 10),
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    ...warnings.map((warning) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        child: Text(
                                          warning,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                color: const Color.fromARGB(
                                                    255, 97, 97, 97),
                                              ),
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              }),
                          ],
                        ),
                      ),
                    if (userPlotState.nutrientWarnings.isNotEmpty)
                      DynamicContainer(
                        backgroundColor: Colors.transparent,
                        borderColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const TextGradient(
                                    text: 'Plot Warnings', fontSize: 20),
                                TextRoundedEnclose(
                                    text: 'Farm Related Warnings',
                                    color: Colors.white,
                                    textColor: Colors.grey[500]!),
                              ],
                            ),
                            ...userPlotState.nutrientWarnings
                                .map((plotWarning) {
                              final plotName = plotWarning['plot_name'];
                              final warnings =
                                  List<String>.from(plotWarning['warnings']);

                              if (warnings.isEmpty) return const SizedBox();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const DividerWidget(verticalHeight: 5),
                                  Text(
                                    '$plotName Warning',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          height: 0.8,
                                          color: const Color.fromARGB(
                                              255, 141, 19, 10),
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...warnings.map((warning) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Text(
                                        warning,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: const Color.fromARGB(
                                                  255, 97, 97, 97),
                                            ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // Bottom navigation bar
            Align(
                alignment: Alignment.bottomCenter,
                child: CustomNavBar(selectedIndex: 0)),
          ],
        ),
      ),
    );
  }
}
