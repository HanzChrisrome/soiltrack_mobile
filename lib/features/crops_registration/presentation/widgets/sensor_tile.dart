import 'package:flutter/material.dart';

class SensorTile extends StatelessWidget {
  const SensorTile({
    super.key,
    required this.sensorName,
    required this.sensorId,
    required this.isAssigned,
    this.plotName,
    required this.isSelected,
    required this.onTap,
  });

  final String sensorName;
  final int sensorId;
  final bool isAssigned;
  final String? plotName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 226, 238, 227)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 33, 156, 17)
                : Colors.grey[100]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sensorName,
              style: TextStyle(
                fontSize: 16,
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : const Color.fromARGB(255, 126, 126, 126),
              ),
            ),
            if (isAssigned && plotName != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Assigned to: $plotName',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 173, 173, 173),
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
