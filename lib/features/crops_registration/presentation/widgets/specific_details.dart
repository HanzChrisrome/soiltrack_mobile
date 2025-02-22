import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpecificDetails extends ConsumerWidget {
  const SpecificDetails(
      {super.key,
      required this.icon,
      required this.title,
      required this.details,
      this.onPressed});

  final IconData icon;
  final String title;
  final String details;
  final VoidCallback? onPressed;

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
          if (onPressed != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onPressed,
              child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 15)),
            ),
          ],
        ],
      ),
    );
  }
}
