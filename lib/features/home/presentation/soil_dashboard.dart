import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/plot_card.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class SoilDashboard extends ConsumerWidget {
  const SoilDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soilState = ref.watch(soilDashboardProvider);
    final soilNotifier = ref.read(soilDashboardProvider.notifier);

    // Fetch user plots if not already fetched
    if (soilState.userPlots.isEmpty &&
        !soilState.isFetchingUserPlots &&
        soilState.error == null) {
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextGradient(text: 'Registered Plots', fontSize: 32),
                    const SizedBox(height: 20),

                    // Loading State
                    if (soilState.isFetchingUserPlots)
                      Center(
                        child: LoadingAnimationWidget.beat(
                          color: Colors.green,
                          size: 20,
                        ),
                      ),

                    // Empty State
                    if (soilState.userPlots.isEmpty &&
                        !soilState.isFetchingUserPlots)
                      Center(
                        child: Text(
                          'No plots available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),

                    // Plots Available
                    if (soilState.userPlots.isNotEmpty)
                      ...soilState.userPlots.map((plot) {
                        // Extract plot details
                        final soilMoistureSensor =
                            plot['soil_moisture_sensors'];
                        final cropName = plot['crops']?['crop_name'] as String?;
                        final plotName = plot['plot_name'] as String;
                        final moistureReadings = plot['soil_moisture_readings'];
                        print('Moisture Readings: $moistureReadings');
                        final nutrientSensors =
                            plot['soil_nutrient_sensors'] as List<dynamic>?;

                        // Check if there's no soil moisture sensor
                        final hasSoilMoistureSensor =
                            soilMoistureSensor != null;

                        // Assign default or fallback values
                        final soilMoistureStatus = hasSoilMoistureSensor
                            ? soilMoistureSensor['soil_moisture_status']
                                as String
                            : 'No sensor assigned';

                        // Build the UI for each plot
                        return Column(
                          children: [
                            PlotCard(
                              soilMoistureSensorId: hasSoilMoistureSensor
                                  ? soilMoistureSensor[
                                      'soil_moisture_sensor_id'] as int
                                  : 0,
                              sensorName: plotName,
                              sensorStatus: soilMoistureStatus,
                              assignedCrop: cropName ?? 'No assigned crop',
                              nutrientSensors: nutrientSensors,
                              moistureReadings: moistureReadings,
                            ),
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
