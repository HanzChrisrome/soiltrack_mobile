import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FilledCustomButton extends StatelessWidget {
  const FilledCustomButton({
    super.key,
    required this.buttonText,
    this.onPressed,
    this.icon,
    this.isLoading = false, // Added isLoading parameter
    this.loadingText = "Loading...", // Added customizable loading text
  });

  final String buttonText;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final String loadingText;

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed:
              isLoading ? null : onPressed, // Disable button when loading
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: isLoading
                ? [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: LoadingAnimationWidget.beat(
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      loadingText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ]
                : [
                    Text(
                      buttonText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(width: 8.0),
                    if (icon != null) ...[
                      Icon(icon, color: Theme.of(context).colorScheme.primary),
                    ],
                  ],
          ),
        ),
      ),
    );
  }
}
