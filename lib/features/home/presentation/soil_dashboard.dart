import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/sensors_card.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class SoilDashboard extends ConsumerWidget {
  const SoilDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final soilState = ref.watch(sensorsProvider);
    final soilNotifier = ref.read(sensorsProvider.notifier);

    if (authState.isAuthenticated &&
        soilState.sensors.isEmpty &&
        !soilState.isFetchingSensors) {
      Future.microtask(() => soilNotifier.fetchSensors());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextGradient(text: 'Registered Plots', fontSize: 32),
                    const SizedBox(height: 20),
                    if (soilState.isFetchingSensors)
                      Center(
                        child: LoadingAnimationWidget.beat(
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                    if (soilState.sensors.isNotEmpty)
                      ...soilState.sensors.map((sensor) => SensorCard(
                          sensorName: sensor['soil_moisture_name'],
                          sensorStatus: sensor['soil_moisture_status'])),
                    if (!soilState.isFetchingSensors &&
                        soilState.sensors.isEmpty)
                      Center(
                        child: Text(
                          soilState.error ?? 'No registered plots',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
