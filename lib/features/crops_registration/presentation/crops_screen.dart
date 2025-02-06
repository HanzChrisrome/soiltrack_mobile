import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/crops_type.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:go_router/go_router.dart';

class CropsScreen extends ConsumerWidget {
  const CropsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextGradient(text: 'Setup your plot.', fontSize: 33),
                SizedBox(
                  child: RichText(
                    text: TextSpan(
                      text:
                          'Specify the type of crops you are growing for better recommendations. ',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey[700],
                            fontSize: 14,
                            height: 1.5,
                          ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Click the card to see more details.',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const CropsType(
                  textCategory: 'High Moisture, High Nutrients',
                  textDescription:
                      'Crops that require a lot of water and nutrients.',
                  moistureLevel: 'VWC: 40-70%',
                  nitrogenLevel: 'N: 80-150',
                  phosphorusLevel: 'P: 40-80',
                  potassiumLevel: 'K: 100-200',
                ),
                const SizedBox(height: 15),
                const CropsType(
                  textCategory: 'High Moisture, Moderate Nutrients',
                  textDescription:
                      'Crops that require a lot of water and moderate nutrients.',
                  moistureLevel: 'VWC: 35-60%',
                  nitrogenLevel: 'N: 60-120',
                  phosphorusLevel: 'P: 30-60',
                  potassiumLevel: 'K: 80-180',
                ),
                const SizedBox(height: 15),
                const CropsType(
                  textCategory: 'Moderate Moisture, High Nutrients',
                  textDescription:
                      'Crops that require moderate water and a lot of nutrients.',
                  moistureLevel: 'VWC: 30-50%',
                  nitrogenLevel: 'N: 70-140',
                  phosphorusLevel: 'P: 40-80',
                  potassiumLevel: 'K: 90-190',
                ),
                const SizedBox(height: 15),
                const CropsType(
                  textCategory: 'Moderate Moisture, Moderate Nutrients',
                  textDescription:
                      'Crops that require moderate water and nutrients.',
                  moistureLevel: 'VWC: 25-45%',
                  nitrogenLevel: 'N: 50-100',
                  phosphorusLevel: 'P: 30-60',
                  potassiumLevel: 'K: 70-160',
                ),
                const SizedBox(height: 15),
                const CropsType(
                  textCategory: 'Low Moisture, High Nutrients',
                  textDescription:
                      'Crops that require little water and a lot of nutrients.',
                  moistureLevel: 'VWC: 15-30%',
                  nitrogenLevel: 'N: 70-130',
                  phosphorusLevel: 'P: 30-60',
                  potassiumLevel: 'K: 80-150',
                ),
                const SizedBox(height: 15),
                const CropsType(
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
          ),
        ),
      ),
    );
  }
}
