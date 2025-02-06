import 'package:flutter/material.dart';

class OutlineCustomButton extends StatelessWidget {
  const OutlineCustomButton(
      {super.key, required this.buttonText, this.onPressed});

  final String buttonText;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            side: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
          ),
          onPressed: onPressed,
          child: Text(
            buttonText,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
        ),
      ),
    );
  }
}
