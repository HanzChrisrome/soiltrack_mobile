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
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 226, 238, 227)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 33, 156, 17)
                : const Color.fromARGB(255, 200, 200, 200),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              sensorName,
              style: TextStyle(
                fontSize: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : const Color.fromARGB(255, 126, 126, 126),
              ),
            ),
            const SizedBox(width: 15),
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
                    fontSize: 12.0,
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
