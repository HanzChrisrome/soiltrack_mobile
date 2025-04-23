import 'package:flutter/material.dart';

class TextHeader extends StatelessWidget {
  const TextHeader({
    super.key,
    required this.text,
    required this.fontSize,
    this.textAlign,
    required this.color,
    this.letterSpacing = -1.5,
    this.heightSpacing = 1.2,
  });

  final String text;
  final double fontSize;
  final TextAlign? textAlign;
  final double letterSpacing;
  final Color color;
  final double heightSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.left,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            color: color,
            height: heightSpacing,
          ),
    );
  }
}
