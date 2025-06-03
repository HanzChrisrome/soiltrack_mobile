import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/soil_card.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/helper/plant_analyzer.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class SoilAssigningScreen extends ConsumerWidget {
  const SoilAssigningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsNotifier = ref.read(cropProvider.notifier);
    final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: 250,
                  pinned: true,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
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
                            Icons.layers_rounded,
                            size: 50,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const SizedBox(height: 10),
                          const TextGradient(
                            text: 'Assign a soil type for your plot',
                            textAlign: TextAlign.center,
                            fontSize: 40,
                            letterSpacing: -2.5,
                            heightSpacing: 1.1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Column(
                          children: [
                            SoilCard(
                              soilType: 'Loam Soil',
                              soilImage: 'assets/soil_images/loam_soil.png',
                              soilDescription:
                                  'Loam soil is a mixture of sand, silt, and clay soil that is combined to avoid the negative effects of each type. It is the best soil for gardening and farming.',
                              onTap: () {
                                showCustomBottomSheet(
                                  context: context,
                                  title: 'Pick this kind of soil?',
                                  description:
                                      'You can edit this later in the settings.',
                                  icon: Icons.arrow_forward_ios_outlined,
                                  buttonText: 'Proceed',
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    cropsNotifier.setSoilType('Loam', context);
                                  },
                                );
                              },
                            ),
                            SoilCard(
                              soilType: 'Clay Soil',
                              soilImage: 'assets/soil_images/clay_soil.png',
                              soilDescription:
                                  'Clay soil is a heavy soil type that is rich in nutrients. It is best for plants that require a lot of water.',
                              onTap: () {
                                showCustomBottomSheet(
                                  context: context,
                                  title: 'Pick this kind of soil?',
                                  description:
                                      'You can edit this later in the settings.',
                                  icon: Icons.arrow_forward_ios_outlined,
                                  buttonText: 'Proceed',
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    cropsNotifier.setSoilType('Clay', context);
                                  },
                                );
                              },
                            ),
                            SoilCard(
                              soilType: 'Sandy Soil',
                              soilImage: 'assets/soil_images/sandy_soil.png',
                              soilDescription:
                                  'Sandy soil is a light soil type that is easy to work with. It is best for plants that require good drainage.',
                              onTap: () {
                                showCustomBottomSheet(
                                  context: context,
                                  title: 'Pick this kind of soil?',
                                  description:
                                      'You can edit this later in the settings.',
                                  icon: Icons.arrow_forward_ios_outlined,
                                  buttonText: 'Proceed',
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    cropsNotifier.setSoilType('Sandy', context);
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                              child: GestureDetector(
                                onTap: () {
                                  soilDashboardNotifier.askSoilType(context);
                                },
                                child: DynamicContainer(
                                  margin: const EdgeInsets.all(0),
                                  padding: const EdgeInsets.all(20),
                                  backgroundColor: Colors.transparent,
                                  borderColor: Colors.transparent,
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        size: 50,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Take a photo of your soil',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
