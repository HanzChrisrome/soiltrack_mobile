import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/home/greeting_widget.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/home/soil_condition.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/home/user_plot_warnings.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/home/weather_suggestions.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/home/weather_widget.dart';
import 'package:soiltrack_mobile/features/home/provider/notifications/notifications_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/weather_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_navigation_bar.dart';
import 'package:soiltrack_mobile/widgets/custom_accordion.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

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
      await ref.watch(soilDashboardProvider.notifier).fetchUserPlots();
      await ref.watch(soilDashboardProvider.notifier).fetchUserAnalytics();
      await ref.watch(notificationProvider);
      await ref.watch(soilDashboardProvider.notifier).generateWeeklyAnalysis();
      await ref.watch(soilDashboardProvider.notifier).generateDailyAnalysis();
      await ref.watch(deviceProvider.notifier).checkDeviceStatus(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.read(authProvider);
    final userPlotState = ref.read(soilDashboardProvider);
    final deviceState = ref.watch(deviceProvider);
    final weatherState = ref.watch(weatherProvider);

    NotifierHelper.logMessage('Building LandingDashboard');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GreetingWidget(userName: authState.userName!),
                    const SizedBox(height: 10),
                    // FilledCustomButton(
                    //   buttonText: 'Testing',
                    //   onPressed: () async {
                    //     NotifierHelper.logMessage(
                    //         'Summary: ${userPlotState.aiSummaryHistory}');
                    //   },
                    // ),
                    const WeatherWidget(),
                    SoilCondition(),
                    if (weatherState.weatherData != null) WeatherSuggestions(),
                    if (userPlotState.nutrientWarnings.isNotEmpty)
                      UserPlotWarnings(),
                    if (userPlotState.deviceWarnings.isNotEmpty ||
                        deviceState.isEspConnected == false)
                      CustomAccordion(
                        initiallyExpanded: true,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        titleWidget: const TextGradient(
                            text: 'Device Warnings', fontSize: 20),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!deviceState.isEspConnected)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
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
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // Bottom navigation bar
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomNavBar(selectedIndex: 0),
            ),
          ],
        ),
      ),
    );
  }
}
