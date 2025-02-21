import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key, this.verticalHeight = 15});

  final double? verticalHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalHeight!),
      child: Divider(
        height: 20,
        thickness: 1,
        color: Colors.grey[200]!,
      ),
    );
  }
}
