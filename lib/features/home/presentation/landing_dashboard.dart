import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/home/greeting_widget.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/home/soil_condition.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/home/weather_widget.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/weather_provider.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class LandingDashboard extends ConsumerWidget {
  const LandingDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final weatherState = ref.watch(weatherProvider);
    final userPlotState = ref.watch(soilDashboardProvider);
    final deviceState = ref.watch(deviceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hello, ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                height: 1.0,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            Text(
                              '${authState.userName} ${authState.userLastName}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                height: 1.0,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Manage your soil with care.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.5,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        context.pushNamed('notifications');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 30,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SoilCondition(),
                const SizedBox(height: 10),
                const WeatherWidget(),
                const SizedBox(height: 10),
                DynamicContainer(
                  backgroundColor: Colors.transparent,
                  borderColor: Colors.black12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TextGradient(text: 'Suggestions', fontSize: 20),
                          TextRoundedEnclose(
                              text: 'Based on weather data',
                              color: Colors.white,
                              textColor: Colors.grey[500]!),
                        ],
                      ),
                      const SizedBox(height: 40),
                      if (weatherState.suggestionData != null &&
                          weatherState.suggestionData!.isNotEmpty)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: weatherState.suggestionData!.length,
                          itemBuilder: (context, index) {
                            final suggestion =
                                weatherState.suggestionData![index];

                            return SizedBox(
                              width: 300,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestion[
                                        "title"], // Use the dynamic title
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          height: 0.8,
                                          color: const Color.fromARGB(
                                              255, 44, 44, 44),
                                        ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    suggestion[
                                        "message"], // Use the dynamic message
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: const Color.fromARGB(
                                              255, 97, 97, 97),
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const DividerWidget(verticalHeight: 5),
                        ),
                    ],
                  ),
                ),
                if (userPlotState.deviceWarnings.isNotEmpty ||
                    deviceState.isEspConnected == false)
                  DynamicContainer(
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
                          ...userPlotState.deviceWarnings.map((deviceWarning) {
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
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
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
                        ...userPlotState.nutrientWarnings.map((plotWarning) {
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
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
      ),
    );
  }
}
