import 'package:flutter/material.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({
    super.key,
    required this.isConnected,
  });

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double statusFontSize = screenWidth > 400 ? 12 : 10;
    double indicatorRadius = screenWidth > 400 ? 10 : 8;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: indicatorRadius,
            backgroundColor: isConnected ? Colors.green : Colors.red,
            child: Icon(
              Icons.electric_bolt,
              color: Colors.white,
              size: indicatorRadius, // matches the radius
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              color: isConnected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Colors.red,
              fontSize: statusFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
