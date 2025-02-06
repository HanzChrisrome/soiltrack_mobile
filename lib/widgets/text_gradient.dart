import 'package:flutter/material.dart';

class TextGradient extends StatelessWidget {
  const TextGradient(
      {super.key, required this.text, required this.fontSize, this.textAlign});

  final String text;
  final double fontSize;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color.fromARGB(255, 9, 73, 14),
          Color.fromARGB(255, 10, 119, 19)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign ?? TextAlign.left,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              letterSpacing: -1.5,
              color: Colors.white,
              height: 1.1,
            ),
      ),
    );
  }
}
