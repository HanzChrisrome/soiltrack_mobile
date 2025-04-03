import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class PasswordChangedSuccessfullyScreen extends ConsumerWidget {
  const PasswordChangedSuccessfullyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/elements/security.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 30),
            TextGradient(
              text: 'Password changed successfully',
              fontSize: 35,
              heightSpacing: 1.1,
              textAlign: TextAlign.center,
            ),
            if (!authState.isAuthenticated) _notAuthenticated(context, ref),
            if (authState.isAuthenticated) _authenticated(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _notAuthenticated(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Text(
            'Your password has been changed successfully. Please proceed to the login page to access your account.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 20),
          FilledCustomButton(
            buttonText: 'Proceed to Login',
            icon: Icons.login_outlined,
            onPressed: () {
              ref.read(authProvider.notifier).signOut(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _authenticated(context, ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        GoRouter.of(context).go('/home');
      });
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Text(
            'Your password has been changed successfully. You will be redirected to the home page in 3 seconds.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
