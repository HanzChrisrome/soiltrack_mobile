import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FilledCustomButton extends StatelessWidget {
  const FilledCustomButton({
    super.key,
    required this.buttonText,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.loadingText = "Loading...",
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.width,
    this.height,
    this.fontSize, // ✅ New optional fontSize
  });

  final String buttonText;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final String loadingText;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? width;
  final double? height;
  final double? fontSize; // ✅ Optional font size

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: TextButton(
          style: TextButton.styleFrom(
            padding: height == null
                ? const EdgeInsets.symmetric(vertical: 13.0)
                : EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: backgroundColor ?? theme.onPrimary,
          ),
          onPressed: isLoading ? null : onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: isLoading
                ? [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: LoadingAnimationWidget.beat(
                        color: textColor ?? theme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      loadingText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: textColor ?? theme.primary,
                            fontSize: fontSize, // ✅ Use provided fontSize
                          ),
                    ),
                  ]
                : [
                    Text(
                      buttonText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: textColor ?? theme.primary,
                            fontSize: fontSize, // ✅ Use provided fontSize
                          ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 8.0),
                      Icon(
                        icon,
                        color: iconColor ?? theme.primary,
                        size: fontSize != null
                            ? fontSize! + 4
                            : null, // Icon adjusts slightly
                      ),
                    ],
                  ],
          ),
        ),
      ),
    );
  }
}
