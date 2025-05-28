import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_header.dart';

class LanguageSelectorTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageSelectorTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DynamicContainer(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.onSecondary.withOpacity(0.4)
            : null,
        borderColor: isSelected
            ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.2)
            : null,
        child: Row(
          children: [
            TextHeader(
              text: title,
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
          ],
        ),
      ),
    );
  }
}
