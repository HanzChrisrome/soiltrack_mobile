import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class NotificationEmpty extends StatelessWidget {
  const NotificationEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Lottie.asset(
                  'assets/elements/no-result.json',
                  width: 250,
                  height: 250,
                  repeat: true, // keep looping
                ),
                const SizedBox(height: 10),
                const TextGradient(
                  text: 'No notifications yet',
                  fontSize: 35,
                  letterSpacing: -2.5,
                  heightSpacing: 1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 230,
                  child: Text(
                    'Your notification will appear here once you have received them',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.4,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),
          const Spacer(),
        ],
      ),
    );
  }
}
