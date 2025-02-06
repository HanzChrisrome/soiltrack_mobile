import 'package:flutter/material.dart';

class OutlineStats extends StatelessWidget {
  const OutlineStats({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 12,
        ),
      ),
    );
  }
}
