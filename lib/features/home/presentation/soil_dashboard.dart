import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/sensors_card.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class SoilDashboard extends ConsumerWidget {
  const SoilDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soilState = ref.watch(soilDashboardProvider);
    final soilNotifier = ref.read(soilDashboardProvider.notifier);

    if (soilState.userPlots.isEmpty && !soilState.isFetchingUserPlots) {
      Future.microtask(() => soilNotifier.fetchUserPlots());
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
                    if (soilState.isFetchingUserPlots)
                      Center(
                        child: LoadingAnimationWidget.beat(
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                    if (soilState.userPlots.isNotEmpty)
                      ...soilState.userPlots.map((plot) {
                        final soilSensors =
                            plot['soil_moisture_sensors'] as List<dynamic>?;

                        final cropName = plot['crops']?['crop_name'] as String?;
                        final plotName = plot['plot_name'] as String;
                        final nutrientSensors =
                            plot['soil_nutrient_sensors'] as List<dynamic>?;
                        return Column(
                          children: [
                            if (soilSensors != null)
                              ...soilSensors.map((sensor) {
                                return SensorCard(
                                  soilMoistureSensorId:
                                      sensor['soil_moisture_sensor_id'] as int,
                                  sensorName: plotName,
                                  sensorStatus:
                                      sensor['soil_moisture_status'] as String,
                                  assignedCrop: cropName ?? 'No assigned crop',
                                  nutrientSensors: nutrientSensors,
                                );
                              }),
                          ],
                        );
                      }),
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
