import 'package:flutter/material.dart';

class DynamicContainer extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius; // Optional borderRadius parameter
  final double? width; // Optional width parameter
  final double? height;
  final DecorationImage? backgroundImage;

  const DynamicContainer({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.height,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height, // Add this
      margin: margin ?? const EdgeInsets.only(bottom: 10),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: backgroundImage == null
            ? (backgroundColor ?? Theme.of(context).colorScheme.surface)
            : null,
        image: backgroundImage,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
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
