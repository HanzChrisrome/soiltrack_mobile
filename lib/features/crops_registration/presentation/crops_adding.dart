import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/crops_card.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class AddingCropsScreen extends ConsumerWidget {
  const AddingCropsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropState = ref.watch(cropProvider);
    final cropNotifier = ref.watch(cropProvider.notifier);
    final sensorState = ref.watch(sensorsProvider);
    final sensorNotifier = ref.read(sensorsProvider.notifier);

    if (sensorState.sensors.isEmpty && !sensorState.isFetchingSensors) {
      Future.microtask(() => sensorNotifier.fetchSensors());
    }

    void addCustomCrop() {
      context.pushNamed('add-custom-crops');
    }

    Widget buildShimmerSkeleton() {
      return Column(
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Icon(
                        Icons.eco_outlined,
                        size: 50,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(height: 10),
                      TextGradient(
                        text: cropState.selectedCategory ?? '',
                        textAlign: TextAlign.start,
                        fontSize: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    if (cropState.isLoading)
                      buildShimmerSkeleton()
                    else
                      Column(
                        children: cropState.cropsList.map((crop) {
                          return GestureDetector(
                            onTap: () {
                              cropNotifier.selectCropName(crop.cropName);
                              context.pushNamed('assign-crops');
                            },
                            child: CropsCard(
                              cropName: crop.cropName,
                              minMoisture: crop.minMoisture.toString(),
                              maxMoisture: crop.maxMoisture.toString(),
                              minNitrogen: crop.minNitrogen.toString(),
                              maxNitrogen: crop.maxNitrogen.toString(),
                              minPotassium: crop.minPotassium.toString(),
                              maxPotassium: crop.maxPotassium.toString(),
                              minPhosphorus: crop.minPhosphorus.toString(),
                              maxPhosphorus: crop.maxPhosphorus.toString(),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 5),
                    OutlineCustomButton(
                        buttonText: 'Crops not listed?',
                        onPressed: addCustomCrop),
                    const SizedBox(height: 20),
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
