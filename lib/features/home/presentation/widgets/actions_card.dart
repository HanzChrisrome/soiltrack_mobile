import 'package:flutter/material.dart';

class ActionsCard extends StatelessWidget {
  const ActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check soil moisture levels',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 0.8,
                      color: const Color.fromARGB(255, 44, 44, 44),
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                'Make sure to check. Ensure optimal growth conditions for your plants.',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: const Color.fromARGB(255, 97, 97, 97),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
