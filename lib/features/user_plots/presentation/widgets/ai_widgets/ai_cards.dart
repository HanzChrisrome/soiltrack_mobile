import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class AiCard extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? borderColor;

  const AiCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DynamicContainer(
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      borderColor: borderColor ?? theme.colorScheme.onSurface.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor ?? theme.colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontSize: 20,
                    color: textColor ?? theme.colorScheme.onSurface,
                    letterSpacing: -1.5,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: textColor ?? theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
