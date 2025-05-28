import 'package:flutter/material.dart';

class CustomToggleButton extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onChanged;

  const CustomToggleButton({
    Key? key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: options.map((option) {
        final isSelected = option == selectedOption;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GestureDetector(
            onTap: () => onChanged(option),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                option.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
