import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/crops_type.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';

import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class CropsScreen extends ConsumerWidget {
  const CropsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPlotState = ref.watch(soilDashboardProvider);

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
                          const SizedBox(height: 20),
                          Icon(
                            Icons.eco_outlined,
                            size: 50,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const SizedBox(height: 10),
                          TextGradient(
                            text: userPlotState.isEditingUserPlot
                                ? 'Assign a new crop for your plot'
                                : 'Assign a crop for your plot',
                            textAlign: TextAlign.center,
                            fontSize: 40,
                            letterSpacing: -2.9,
                            heightSpacing: 1,
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
                        const Column(
                          children: [
                            CropsType(
                              textCategory: 'High Moisture, High Nutrients',
                              textDescription:
                                  'Crops that require a lot of water and nutrients.',
                              moistureLevel: 'VWC: 40-70%',
                              nitrogenLevel: 'N: 80-150',
                              phosphorusLevel: 'P: 40-80',
                              potassiumLevel: 'K: 100-200',
                            ),
                            SizedBox(height: 15),
                            CropsType(
                              textCategory: 'High Moisture, Moderate Nutrients',
                              textDescription:
                                  'Crops that require a lot of water and moderate nutrients.',
                              moistureLevel: 'VWC: 35-60%',
                              nitrogenLevel: 'N: 60-120',
                              phosphorusLevel: 'P: 30-60',
                              potassiumLevel: 'K: 80-180',
                            ),
                            SizedBox(height: 15),
                            CropsType(
                              textCategory: 'Moderate Moisture, High Nutrients',
                              textDescription:
                                  'Crops that require moderate water and a lot of nutrients.',
                              moistureLevel: 'VWC: 30-50%',
                              nitrogenLevel: 'N: 70-140',
                              phosphorusLevel: 'P: 40-80',
                              potassiumLevel: 'K: 90-190',
                            ),
                            SizedBox(height: 15),
                            CropsType(
                              textCategory:
                                  'Moderate Moisture, Moderate Nutrients',
                              textDescription:
                                  'Crops that require moderate water and nutrients.',
                              moistureLevel: 'VWC: 25-45%',
                              nitrogenLevel: 'N: 50-100',
                              phosphorusLevel: 'P: 30-60',
                              potassiumLevel: 'K: 70-160',
                            ),
                            SizedBox(height: 15),
                            CropsType(
                              textCategory: 'Low Moisture, High Nutrients',
                              textDescription:
                                  'Crops that require little water and a lot of nutrients.',
                              moistureLevel: 'VWC: 15-30%',
                              nitrogenLevel: 'N: 70-130',
                              phosphorusLevel: 'P: 30-60',
                              potassiumLevel: 'K: 80-150',
                            ),
                            SizedBox(height: 15),
                            CropsType(
                              textCategory: 'Low Moisture, Moderate Nutrients',
                              textDescription:
                                  'Crops that require little water and moderate nutrients.',
                              moistureLevel: 'VWC: 10-25%',
                              nitrogenLevel: 'N: 50-100',
                              phosphorusLevel: 'P: 20-50',
                              potassiumLevel: 'K: 60-140',
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
