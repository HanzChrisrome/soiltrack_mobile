import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class AiReadyCard extends StatelessWidget {
  const AiReadyCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 190,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage('assets/elements/ai_ready.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextGradient(
                      text: 'AI analysis is ready for this plot', fontSize: 22),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_forward,
                      color: Theme.of(context).colorScheme.onPrimary),
                ],
              ),
              const SizedBox(height: 5),
              TextRoundedEnclose(
                  text: 'Tap to view AI detailed analysis about your plot',
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
