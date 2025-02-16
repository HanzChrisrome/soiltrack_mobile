import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsItem extends ConsumerWidget {
  const SettingsItem({
    super.key,
    required this.settingsText,
    required this.settingsIcon,
    this.onTap,
  });

  final String settingsText;
  final IconData settingsIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color.fromARGB(255, 214, 214, 214),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            children: [
              Icon(
                settingsIcon,
                size: 30,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 15),
              Text(
                settingsText,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Color.fromARGB(255, 59, 59, 59),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
