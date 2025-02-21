import 'package:flutter/material.dart';

class ActionsCard extends StatelessWidget {
  const ActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
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
