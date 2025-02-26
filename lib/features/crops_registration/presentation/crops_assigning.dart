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
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class AssignCrops extends ConsumerWidget {
  const AssignCrops({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropState = ref.watch(cropProvider);
    final cropNotifier = ref.watch(cropProvider.notifier);
    final sensorState = ref.watch(sensorsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 300,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Icon(
                        Icons.sensors_rounded,
                        size: 50,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(height: 10),
                      const TextGradient(
                        text: 'Assigning crop to your plot sensor',
                        textAlign: TextAlign.center,
                        fontSize: 40,
                        letterSpacing: -2.5,
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
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey[100]!,
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
                              const TextRoundedEnclose(
                                text: 'Selected Crop',
                                color: Colors.white,
                                textColor: Colors.black,
                              ),
                            ],
                          ),
                          const DividerWidget(verticalHeight: 5),
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
                    if (sensorState.moistureSensors.isNotEmpty)
                      ...sensorState.moistureSensors.map(
                        (sensor) {
                          final bool isAssigned = sensor['is_assigned'] == true;
                          final String? plotName = sensor['user_plot_sensors']
                              ?[0]['user_plots']?['plot_name'];

                          return SensorTile(
                            sensorName: sensor['sensor_name'],
                            sensorId: sensor['sensor_id'],
                            isAssigned: isAssigned,
                            plotName: plotName,
                            isSelected:
                                cropState.selectedSensor == sensor['sensor_id'],
                            onTap: () {
                              cropNotifier.selectSensor(sensor['sensor_id']);
                            },
                          );
                        },
                      ),
                    FilledCustomButton(
                      icon: Icons.verified_outlined,
                      buttonText: 'Proceed',
                      onPressed: cropState.isSaving
                          ? null
                          : () {
                              // Find the selected sensor
                              final selectedSensor =
                                  sensorState.moistureSensors.firstWhere(
                                (sensor) =>
                                    sensor['soil_moisture_sensor_id'] ==
                                    cropState.selectedSensor,
                                orElse: () => {},
                              );

                              final bool isAssigned =
                                  selectedSensor['is_assigned'] == true;

                              final String title = isAssigned
                                  ? 'This sensor is currently assigned.'
                                  : 'Save Configurations?';
                              final String description = isAssigned
                                  ? 'Are you sure you want to reassign this sensor?'
                                  : 'Are you sure you want to save the configurations?';

                              showCustomBottomSheet(
                                context: context,
                                title: title,
                                description: description,
                                icon: Icons.chevron_right,
                                buttonText: 'Continue',
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  cropNotifier.assignCrop(context);
                                },
                              );
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
