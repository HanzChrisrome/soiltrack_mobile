import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class PlotSuggestions extends StatelessWidget {
  const PlotSuggestions({super.key, required this.plotSuggestions});

  final Map<String, dynamic> plotSuggestions;

  @override
  Widget build(BuildContext context) {
    if (plotSuggestions.isEmpty ||
        plotSuggestions['suggestions'] == null ||
        (plotSuggestions['suggestions'] as List).isEmpty) {
      return const SizedBox.shrink();
    }

    return DynamicContainer(
      borderColor: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.green, size: 20),
              SizedBox(width: 5),
              Text(
                'Suggestions',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...plotSuggestions['suggestions'].map<Widget>((suggestion) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion,
                  style: Theme.of(context).textTheme.bodyMedium!,
                ),
                if (plotSuggestions['suggestions'].indexOf(suggestion) !=
                    plotSuggestions['suggestions'].length - 1)
                  DividerWidget(verticalHeight: 1, color: Colors.grey[300]!),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
