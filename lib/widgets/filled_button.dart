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
    this.backgroundColor, // ✅ Customizable background color
    this.textColor, // ✅ Customizable text color
    this.iconColor, // ✅ Customizable icon color
  });

  final String buttonText;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final String loadingText;
  final Color? backgroundColor; // Optional background color
  final Color? textColor; // Optional text color
  final Color? iconColor; // Optional icon color

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: backgroundColor ??
                theme.onPrimary, // ✅ Use custom color or default
          ),
          onPressed: isLoading ? null : onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: isLoading
                ? [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: LoadingAnimationWidget.beat(
                        color: textColor ??
                            theme.primary, // ✅ Custom or default color
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      loadingText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: textColor ??
                                theme.primary, // ✅ Custom or default
                          ),
                    ),
                  ]
                : [
                    Text(
                      buttonText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: textColor ??
                                theme.primary, // ✅ Custom or default
                          ),
                    ),
                    const SizedBox(width: 8.0),
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color:
                            iconColor ?? theme.primary, // ✅ Custom or default
                      ),
                    ],
                  ],
          ),
        ),
      ),
    );
  }
}
