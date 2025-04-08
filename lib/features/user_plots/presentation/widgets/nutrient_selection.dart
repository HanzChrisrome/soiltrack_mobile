// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class NutrientSelectionWidget extends StatelessWidget {
  final String selectedOption;
  final Function(String) onOptionSelected;

  const NutrientSelectionWidget({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> options = ['M', 'N', 'P', 'K'];
    final List<String> labels = [
      'Moisture',
      'Nitrogen',
      'Phosphorus',
      'Potassium'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextGradient(
          text: '${labels[options.indexOf(selectedOption)]} Trends:',
          fontSize: 16,
          letterSpacing: -0.5,
        ),
        Container(
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
                      onOptionSelected(option);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: selectedOption == option
                            ? Theme.of(context).colorScheme.onPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedOption == option
                              ? Colors.white
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
        ),
      ],
    );
  }
}
