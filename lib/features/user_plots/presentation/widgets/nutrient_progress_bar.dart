import 'package:flutter/material.dart';

class NutrientProgressBar extends StatelessWidget {
  const NutrientProgressBar(
      {super.key,
      required this.label,
      required this.value,
      required this.maxValue,
      required this.color});

  final String label;
  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    double progress = (value / maxValue).clamp(0.0, 1.0);
    LinearGradient gradient = LinearGradient(
      colors: [color.withOpacity(0.7), color.withOpacity(1.0)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$label: ',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              Text(
                  label.toLowerCase() == "moisture" ? "$value%" : "$value mg/l",
                  style: const TextStyle(fontSize: 12, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 5),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 10,
                    width: constraints.maxWidth * progress,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(5)),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return gradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
