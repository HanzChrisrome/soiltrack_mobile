import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/actions_card.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/weather_widget.dart';
import 'package:soiltrack_mobile/provider/weather_provider.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class LandingDashboard extends ConsumerWidget {
  const LandingDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final weatherState = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/logo/DARK HORIZONTAL.png',
                      height: 30,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.notifications_rounded,
                        size: 30,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 120,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/weather/night.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good evening!",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            letterSpacing: -1.5,
                            height: 1,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text('Welcome back, ${authState.userName}!',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const WeatherWidget(),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey[100]!,
                      width: 1.0,
                    ),
                  ),
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
                        ListView.builder(
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
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey[100]!,
                      width: 1.0,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextGradient(text: 'Actions needed', fontSize: 20),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Color.fromARGB(255, 44, 44, 44),
                          )
                        ],
                      ),
                      SizedBox(height: 40),
                      ActionsCard(),
                      DividerWidget(),
                      ActionsCard(),
                      DividerWidget(),
                      ActionsCard(),
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
