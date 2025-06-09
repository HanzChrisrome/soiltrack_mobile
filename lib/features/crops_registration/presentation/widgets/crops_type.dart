import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/widgets/outline_stats.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:go_router/go_router.dart';

class CropsType extends ConsumerWidget {
  const CropsType({
    super.key,
    required this.textCategory,
    required this.textDescription,
    required this.moistureLevel,
    required this.nitrogenLevel,
    required this.phosphorusLevel,
    required this.potassiumLevel,
  });

  final String textCategory;
  final String textDescription;
  final String moistureLevel;
  final String nitrogenLevel;
  final String phosphorusLevel;
  final String potassiumLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('add-crops');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[100]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextGradient(text: textCategory, fontSize: 18),
                  const SizedBox(height: 5),
                  Text(
                    textDescription,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.grey[700],
                          fontSize: 14,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            OutlineStats(text: 'Soil Moisture Threshold: $moistureLevel'),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlineStats(text: nitrogenLevel),
                const SizedBox(width: 3),
                OutlineStats(text: phosphorusLevel),
                const SizedBox(width: 3),
                OutlineStats(text: potassiumLevel),
                const SizedBox(width: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PPM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
