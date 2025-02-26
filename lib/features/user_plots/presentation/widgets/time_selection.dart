// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class TimeSelectionWidget extends StatefulWidget {
  const TimeSelectionWidget({super.key});

  @override
  _TimeSelectionWidgetState createState() => _TimeSelectionWidgetState();
}

class _TimeSelectionWidgetState extends State<TimeSelectionWidget> {
  String selectedOption = '1D';
  final List<String> options = ['1D', '1W', '1M', '3M'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: options.map((option) {
          return Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = option;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: selectedOption == option
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selectedOption == option
                          ? Colors.black
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ),
              if (option != options.last)
                SizedBox(
                  height: 10,
                  child: VerticalDivider(
                    color: Colors.grey[300]!,
                    thickness: 1,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
