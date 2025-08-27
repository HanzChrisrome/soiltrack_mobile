import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class AiGeneratedCard extends StatelessWidget {
  const AiGeneratedCard({
    super.key,
    required this.onTap,
    required this.currentToggle,
  });

  final VoidCallback onTap;
  final String currentToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 400,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            width: 1,
          ),
          image: DecorationImage(
            image: AssetImage(
              currentToggle == 'Weekly'
                  ? 'assets/background/mascot_bg.png'
                  : 'assets/background/mascot_bg.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Background Lottie
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: Lottie.asset(
                'assets/elements/Live chatbot.json',
                repeat: true,
                width: 350,
                height: 350,
                fit: BoxFit.contain,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentToggle == 'Weekly'
                        ? 'Your Weekly AI analysis\nhas been generated!'
                        : 'Your Daily AI analysis\nhas been generated!',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 25,
                          color: Theme.of(context).colorScheme.secondary,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  DynamicContainer(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 5),
                    borderRadius: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Go to analysis page',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
