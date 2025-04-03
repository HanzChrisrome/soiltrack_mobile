import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class PlotWarnings extends StatefulWidget {
  const PlotWarnings({super.key, required this.plotWarningsData});

  final Map<String, dynamic> plotWarningsData;

  @override
  State<PlotWarnings> createState() => _PlotWarningsState();
}

class _PlotWarningsState extends State<PlotWarnings> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.plotWarningsData.isEmpty ||
        widget.plotWarningsData['warnings'] == null ||
        (widget.plotWarningsData['warnings'] as List).isEmpty) {
      return const SizedBox.shrink();
    }

    return DynamicContainer(
      backgroundColor: Colors.transparent,
      borderColor: Colors.black12,
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
                const Row(
                  children: [
                    Icon(Icons.warning_amber_outlined,
                        color: Colors.red, size: 20),
                    SizedBox(width: 5),
                    Text(
                      'Your plot have warnings!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0, // Smooth rotation for the arrow
                  duration: const Duration(milliseconds: 300),
                  child:
                      const Icon(Icons.keyboard_arrow_down, color: Colors.red),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      ...widget.plotWarningsData['warnings']
                          .map<Widget>((warning) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                warning,
                                style: Theme.of(context).textTheme.bodyMedium!,
                              ),
                            ),
                            if (widget.plotWarningsData['warnings']
                                    .indexOf(warning) !=
                                widget.plotWarningsData['warnings'].length - 1)
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
