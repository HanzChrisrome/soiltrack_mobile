import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: _noNotification(context),
    );
  }

  Widget _noNotification(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Image.asset(
                  'assets/elements/no_notification.png',
                  height: 280,
                ),
                const SizedBox(height: 50),
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
