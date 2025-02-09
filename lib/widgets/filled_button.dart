import 'package:flutter/material.dart';

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
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white, // Adjust color as needed
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
                    if (icon != null) ...[
                      Icon(icon, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8.0),
                    ],
                    Text(
                      buttonText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
