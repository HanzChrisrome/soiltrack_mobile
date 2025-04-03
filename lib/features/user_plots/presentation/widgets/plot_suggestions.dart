import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class PlotSuggestions extends StatefulWidget {
  const PlotSuggestions({super.key, required this.plotSuggestions});

  final Map<String, dynamic> plotSuggestions;

  @override
  State<PlotSuggestions> createState() => _PlotSuggestionsState();
}

class _PlotSuggestionsState extends State<PlotSuggestions> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.plotSuggestions.isEmpty ||
        widget.plotSuggestions['suggestions'] == null ||
        (widget.plotSuggestions['suggestions'] as List).isEmpty) {
      return const SizedBox.shrink();
    }

    return DynamicContainer(
      borderColor: Colors.black12,
      backgroundColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_outlined,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20),
                    SizedBox(width: 5),
                    Text(
                      'Plot Suggestions',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ],
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Column(
                    children: [
                      const SizedBox(height: 15),
                      ...widget.plotSuggestions['suggestions']
                          .map<Widget>((suggestion) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion,
                              style: Theme.of(context).textTheme.bodyMedium!,
                            ),
                            if (widget.plotSuggestions['suggestions']
                                    .indexOf(suggestion) !=
                                widget.plotSuggestions['suggestions'].length -
                                    1)
                              DividerWidget(
                                  verticalHeight: 1, color: Colors.grey[300]!),
                          ],
                        );
                      }).toList(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
