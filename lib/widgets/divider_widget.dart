import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key, this.verticalHeight = 15, this.color});

  final double? verticalHeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color newColor;

    if (color == null) {
      newColor = Colors.grey[200]!;
    } else {
      newColor = color!;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalHeight!),
      child: Divider(
        height: 20,
        thickness: 1,
        color: newColor,
      ),
    );
  }
}
