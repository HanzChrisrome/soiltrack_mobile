// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class ExistingDeviceScreen extends ConsumerWidget {
  const ExistingDeviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Image.asset(
                    'assets/elements/sad_icon.png',
                    height: 230,
                  ),
                  const SizedBox(height: 50),
                  const TextGradient(
                    text: 'This device is connected to someone else.',
                    fontSize: 35,
                    letterSpacing: -2.5,
                    heightSpacing: 1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 350,
                    child: Text(
                      'For this device to be associated with your account, it must first be unbound from the other account.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.4,
                          ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        authState.isAuthenticated
                            ? context.go('/home')
                            : context.go('/setup');
                      },
                      label: Text(
                        'Return to setup screen',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
