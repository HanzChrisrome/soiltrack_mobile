import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ToolsButton extends ConsumerWidget {
  const ToolsButton(
      {super.key,
      required this.buttonName,
      required this.icon,
      required this.action});

  final String buttonName;
  final IconData icon;
  final VoidCallback action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: action,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              size: 35,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            buttonName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
