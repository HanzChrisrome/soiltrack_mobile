import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class PlotWarnings extends StatelessWidget {
  const PlotWarnings({super.key, required this.plotWarningsData});

  final Map<String, dynamic> plotWarningsData;

  @override
  Widget build(BuildContext context) {
    if (plotWarningsData.isEmpty ||
        plotWarningsData['warnings'] == null ||
        (plotWarningsData['warnings'] as List).isEmpty) {
      return const SizedBox.shrink();
    }

    return DynamicContainer(
      borderColor: Colors.red,
      backgroundColor: Colors.red.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.red, size: 20),
              SizedBox(width: 5),
              Text(
                'Warning!',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...plotWarningsData['warnings'].map((warning) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warning,
                  style: Theme.of(context).textTheme.bodyMedium!,
                ),
                if (plotWarningsData['warnings'].indexOf(warning) !=
                    plotWarningsData['warnings'].length - 1)
                  const DividerWidget(verticalHeight: 1, color: Colors.red),
              ],
            );
          }),
        ],
      ),
    );
  }
}
