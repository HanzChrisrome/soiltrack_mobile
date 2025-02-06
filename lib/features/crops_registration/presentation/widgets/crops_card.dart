import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class CropsCard extends ConsumerWidget {
  const CropsCard(
      {super.key,
      required this.cropName,
      required this.minMoisture,
      required this.maxMoisture,
      required this.minNitrogen,
      required this.maxNitrogen,
      required this.minPotassium,
      required this.maxPotassium,
      required this.minPhosphorus,
      required this.maxPhosphorus});

  final String cropName;
  final String minMoisture;
  final String maxMoisture;
  final String minNitrogen;
  final String maxNitrogen;
  final String minPotassium;
  final String maxPotassium;
  final String minPhosphorus;
  final String maxPhosphorus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.eco,
                color: Color.fromARGB(255, 53, 134, 56),
              ),
              const SizedBox(width: 10),
              TextGradient(text: cropName, fontSize: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(255, 172, 31, 21),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$minMoisture%',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: const Color.fromARGB(255, 182, 54, 54),
                        fontSize: 12,
                      ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(255, 17, 158, 17),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$maxMoisture%',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: const Color.fromARGB(255, 17, 158, 17),
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
          const DividerWidget(
            verticalHeight: 5,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$minNitrogen - $maxNitrogen',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          letterSpacing: -1.2,
                          fontSize: 18,
                          color: const Color.fromARGB(255, 59, 59, 59),
                        ),
                  ),
                  Text(
                    'Nitrogen',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$minPotassium - $maxPotassium',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          letterSpacing: -1.2,
                          fontSize: 18,
                          color: const Color.fromARGB(255, 59, 59, 59),
                        ),
                  ),
                  Text(
                    'Potassium',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$minPhosphorus - $maxPhosphorus',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          letterSpacing: -1.2,
                          fontSize: 18,
                          color: const Color.fromARGB(255, 59, 59, 59),
                        ),
                  ),
                  Text(
                    'Phosphorus',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
