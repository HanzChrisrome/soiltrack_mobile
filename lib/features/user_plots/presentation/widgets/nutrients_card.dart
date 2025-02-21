import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class NutrientsCard extends ConsumerWidget {
  const NutrientsCard(
      {super.key,
      required this.elementIcon,
      required this.percentage,
      required this.latestReading,
      required this.nutrientType});

  final IconData elementIcon;
  final String percentage;
  final String latestReading;
  final String nutrientType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimary,
                width: 1,
              ),
            ),
            child: Icon(
              elementIcon,
              size: 30,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextGradient(
                text: percentage,
                fontSize: 25,
                heightSpacing: 1,
              ),
              Text(
                '$nutrientType Reading as of $latestReading',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.grey[100]!,
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
