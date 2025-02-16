import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/sensor_tile.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/specific_details.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';

class AssignCrops extends ConsumerWidget {
  const AssignCrops({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropState = ref.watch(cropProvider);
    final cropNotifier = ref.watch(cropProvider.notifier);
    final sensorState = ref.watch(sensorsProvider);
    final sensorNotifier = ref.watch(sensorsProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 280,
              pinned: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sensors_rounded,
                        size: 50,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(height: 10),
                      const TextGradient(
                        text: 'Assigning crop to your plot sensor',
                        textAlign: TextAlign.center,
                        fontSize: 35,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 20),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color.fromARGB(255, 236, 236, 236),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextGradient(
                                text: cropState.selectedCrop as String,
                                fontSize: 25,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Selected Crop',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 126, 126, 126),
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const DividerWidget(
                            verticalHeight: 5,
                          ),
                          if (cropState.isLoading)
                            Column(
                              children: List.generate(
                                4, // Number of placeholders
                                (index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: double.infinity,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: [
                                SpecificDetails(
                                  icon: Icons.eco_outlined,
                                  title: 'Moisture Level',
                                  details:
                                      '${cropState.specificCropDetails[0]['moisture_min']}% - ${cropState.specificCropDetails[0]['moisture_max']}%',
                                ),
                                SpecificDetails(
                                  icon: Icons.grass,
                                  title: 'Nitrogen Level',
                                  details:
                                      '${cropState.specificCropDetails[0]['nitrogen_min']}% - ${cropState.specificCropDetails[0]['nitrogen_max']}%',
                                ),
                                SpecificDetails(
                                  icon: Icons.local_florist,
                                  title: 'Potassium Level',
                                  details:
                                      '${cropState.specificCropDetails[0]['potassium_min']}% - ${cropState.specificCropDetails[0]['potassium_max']}%',
                                ),
                                SpecificDetails(
                                  icon: Icons.science_outlined,
                                  title: 'Phosphorus Level',
                                  details:
                                      '${cropState.specificCropDetails[0]['phosphorus_min']}% - ${cropState.specificCropDetails[0]['phosphorus_max']}%',
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (sensorState.sensors.isNotEmpty)
                      ...sensorState.sensors.map(
                        (sensor) => SensorTile(
                          sensorName: sensor['soil_moisture_name'],
                          sensorId: sensor['soil_moisture_sensor_id'],
                        ),
                      ),
                    FilledCustomButton(
                      icon: Icons.verified_outlined,
                      buttonText: 'Proceed',
                      onPressed: cropState.isSaving
                          ? null
                          : () {
                              showCustomBottomSheet(
                                  context: context,
                                  title: 'Assign Crop',
                                  description:
                                      'Are you sure you want to assign this crop?',
                                  icon: Icons.chevron_right,
                                  buttonText: 'Continue',
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    cropNotifier.assignCrop(context);
                                  });
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
