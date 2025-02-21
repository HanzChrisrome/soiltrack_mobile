import 'package:flutter/material.dart';

class TextGradient extends StatelessWidget {
  const TextGradient({
    super.key,
    required this.text,
    required this.fontSize,
    this.textAlign,
    this.letterSpacing = -1.5,
    this.heightSpacing = 1.2,
  });

  final String text;
  final double fontSize;
  final TextAlign? textAlign;
  final double letterSpacing;
  final double heightSpacing;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(colors: [
        Color.fromARGB(255, 9, 73, 14),
        Color.fromARGB(255, 8, 146, 19)
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)
          .createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign ?? TextAlign.left,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              letterSpacing: letterSpacing,
              color: Colors.white,
              height: heightSpacing,
            ),
      ),
    );
  }
}
