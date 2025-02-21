import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class SoilCard extends StatelessWidget {
  const SoilCard(
      {super.key,
      required this.soilType,
      required this.soilDescription,
      required this.soilImage,
      this.onTap});

  final String soilType;
  final String soilDescription;
  final String soilImage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[100]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(soilImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextGradient(
              text: soilType,
              fontSize: 25,
            ),
            const SizedBox(height: 10),
            Text(
              soilDescription,
              style: const TextStyle(
                fontSize: 15,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
