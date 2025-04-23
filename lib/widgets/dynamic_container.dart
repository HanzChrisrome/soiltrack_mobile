import 'package:flutter/material.dart';

class DynamicContainer extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius; // Optional borderRadius parameter
  final double? width; // Optional width parameter

  const DynamicContainer({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius, // Include borderRadius in constructor
    this.width, // Include width in constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // Set the width if provided
      margin: margin ?? const EdgeInsets.only(bottom: 10),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
            borderRadius ?? 20), // Use borderRadius if provided, otherwise 20
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
