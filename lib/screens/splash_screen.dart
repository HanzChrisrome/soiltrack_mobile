// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/provider/weather_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorNotifier = ref.read(sensorsProvider.notifier);
    final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);
    final weatherNotifier = ref.read(weatherProvider.notifier);

    Future.microtask(() async {
      await sensorNotifier.fetchSensors();
      await soilDashboardNotifier.fetchUserPlots();
      await weatherNotifier.fetchWeather('Baliuag');

      final prefs = await SharedPreferences.getInstance();
      final isSetupCompleted = prefs.getBool('device_setup_completed') ?? false;

      if (context.mounted) {
        final authState = ref.read(authProvider);
        final isAuth = authState.isAuthenticated;

        if (!isAuth) {
          context.go('/login');
        } else if (!isSetupCompleted) {
          context.go('/setup');
        } else {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background/background_splash.png',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo/soiltrack gradient.png',
                  height: 230,
                ),
                LoadingAnimationWidget.progressiveDots(
                    color: Theme.of(context).colorScheme.onPrimary, size: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
