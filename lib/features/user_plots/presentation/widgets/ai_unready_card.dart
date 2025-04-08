import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class AiUnreadyCard extends StatelessWidget {
  const AiUnreadyCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
          image: DecorationImage(
            image: AssetImage(
                'assets/elements/no_ai_reading.png'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 160,
                child: TextGradient(
                    text: 'Data is incomplete for this plot', fontSize: 22),
              ),
              const SizedBox(height: 10),
              TextRoundedEnclose(
                  text: 'AI Analysis can\'t be generated',
                  color: Theme.of(context).colorScheme.surface,
                  textColor: Theme.of(context).colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
