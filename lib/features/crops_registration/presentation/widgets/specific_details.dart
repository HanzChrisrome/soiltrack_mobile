import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpecificDetails extends ConsumerWidget {
  const SpecificDetails(
      {super.key,
      required this.icon,
      required this.title,
      required this.details});

  final IconData icon;
  final String title;
  final String details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[700],
            size: 15,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
          ),
          const Spacer(),
          Text(
            details,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }
}
