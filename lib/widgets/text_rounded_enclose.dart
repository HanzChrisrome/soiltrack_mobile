import 'package:flutter/material.dart';

class TextRoundedEnclose extends StatelessWidget {
  const TextRoundedEnclose(
      {super.key,
      required this.text,
      required this.color,
      required this.textColor,
      this.fontSize = 12.0});

  final String text;
  final Color color;
  final Color textColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
