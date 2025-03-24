import 'package:flutter/material.dart';

class DynamicContainer extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;

  const DynamicContainer(
      {super.key, required this.child, this.borderColor, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ??
              Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
