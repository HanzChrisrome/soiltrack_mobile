import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/actions_card.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/weather_widget.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:go_router/go_router.dart';

class LandingDashboard extends ConsumerWidget {
  const LandingDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authProvider.notifier);
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/logo/DARK HORIZONTAL.png',
                          height: 20,
                        ),
                        Text('Hello, Hanz',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface)
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 30,
                                  height: 1.3,
                                  letterSpacing: -1.8,
                                )),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 30),
                      onPressed: () {
                        authNotifier.signOut();
                      },
                    ),
                  ],
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
                  child: Row(
                    children: [
                      const TextGradient(text: 'View soil data', fontSize: 20),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          context.push('/home/soil-dashboard');
                        },
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromARGB(255, 44, 44, 44),
                        ),
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
                  child: Row(
                    children: [
                      const TextGradient(text: 'Specify Crop', fontSize: 20),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          context.push('/home/user-plots');
                        },
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromARGB(255, 44, 44, 44),
                        ),
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
